#!/usr/bin/env bash

set -euo pipefail

REMOTE_NAME="repo-2"
REMOTE_URL="https://github.com/amromnia/moi-demo-2.git"

echo "Starting project update..."

# Ensure we are inside a git repository
if [ ! -d ".git" ]; then
  echo "Error: Current directory is not a git repository."
  exit 1
fi

# Ensure we are on a real branch, not detached HEAD
CURRENT_BRANCH="$(git branch --show-current)"

if [ -z "$CURRENT_BRANCH" ]; then
  echo "Error: You are in detached HEAD state. Cannot determine current branch."
  exit 1
fi

echo "Current branch: $CURRENT_BRANCH"

# Take a backup of the entire current directory before doing anything
BACKUP_ROOT="../repo-backups"
BACKUP_STAMP="$(date +%Y-%m-%d_%H-%M-%S)"
BACKUP_DIR="$BACKUP_ROOT/$BACKUP_STAMP"
echo "Creating backup at $BACKUP_DIR ..."
mkdir -p "$BACKUP_DIR"
# Copy everything in current dir (including dotfiles) into the backup dir, excluding node_modules
if command -v rsync >/dev/null 2>&1; then
  rsync -a --exclude='node_modules' --exclude='node_modules/**' ./ "$BACKUP_DIR/"
else
  # Fallback: copy everything then drop node_modules dirs from the backup
  cp -a . "$BACKUP_DIR/"
  find "$BACKUP_DIR" -type d -name node_modules -prune -exec rm -rf {} +
fi
echo "Backup created."

# Add the remote if it does not exist
if ! git remote get-url "$REMOTE_NAME" >/dev/null 2>&1; then
  echo "Adding remote '$REMOTE_NAME'..."
  git remote add "$REMOTE_NAME" "$REMOTE_URL"
else
  echo "Remote '$REMOTE_NAME' already exists."
fi

echo "Fetching latest changes from $REMOTE_NAME..."
git fetch "$REMOTE_NAME"

# Make sure the same branch exists on that remote
if ! git ls-remote --exit-code --heads "$REMOTE_NAME" "$CURRENT_BRANCH" >/dev/null 2>&1; then
  echo "Error: Branch '$CURRENT_BRANCH' does not exist on remote '$REMOTE_NAME'."
  exit 1
fi

echo "Attempting clean merge from $REMOTE_NAME/$CURRENT_BRANCH..."
MERGE_OUTPUT="$(git merge --no-edit --no-stat "$REMOTE_NAME/$CURRENT_BRANCH" 2>&1)" && MERGE_RC=0 || MERGE_RC=$?
echo "$MERGE_OUTPUT"

if [ "$MERGE_RC" -ne 0 ]; then
  # Try to recover only from the "local changes would be overwritten" case.
  BLOCKING="$(printf '%s\n' "$MERGE_OUTPUT" | awk '/would be overwritten by merge:/{flag=1;next} /^Please commit your changes/{flag=0} flag {sub(/^[ \t]+/, ""); if ($0 != "") print}')"

  # Make sure we are not stuck mid-merge.
  git merge --abort 2>/dev/null || true

  if [ -z "$BLOCKING" ]; then
    echo "Error: Merge failed for a reason other than blocking local changes. Aborting."
    exit 1
  fi

  # If ANY blocking file is not a .sh file, list them all and abort without touching anything.
  NON_SH_BLOCKING=""
  while IFS= read -r file; do
    [ -z "$file" ] && continue
    case "$file" in
      *.sh) ;;
      *)
        NON_SH_BLOCKING="${NON_SH_BLOCKING}${file}"$'\n'
        ;;
    esac
  done <<< "$BLOCKING"

  if [ -n "$NON_SH_BLOCKING" ]; then
    echo "Error: Blocking local changes in non-.sh files (refusing to modify these):"
    printf '  - %s\n' $(printf '%s' "$NON_SH_BLOCKING")
    echo "Aborting."
    exit 1
  fi

  echo "Resolving blocking .sh files using $REMOTE_NAME/$CURRENT_BRANCH..."
  while IFS= read -r file; do
    [ -z "$file" ] && continue
    if git cat-file -e "$REMOTE_NAME/$CURRENT_BRANCH:$file" 2>/dev/null; then
      echo "  Overwriting '$file' with version from $REMOTE_NAME/$CURRENT_BRANCH"
      git checkout "$REMOTE_NAME/$CURRENT_BRANCH" -- "$file"
    else
      echo "  '$file' does not exist on $REMOTE_NAME/$CURRENT_BRANCH -> discarding local changes (reset to HEAD, then remove)"
      git checkout HEAD -- "$file" 2>/dev/null || true
      rm -f -- "$file"
      git rm -f --quiet --ignore-unmatch -- "$file" 2>/dev/null || true
    fi
  done <<< "$BLOCKING"

  echo "Retrying merge from $REMOTE_NAME/$CURRENT_BRANCH..."
  if ! git merge --no-edit --no-stat "$REMOTE_NAME/$CURRENT_BRANCH"; then
    echo "Error: Merge still failed after resolving blocking files. Aborting."
    git merge --abort 2>/dev/null || true
    exit 1
  fi
fi

echo "Building project..."
npm run build

# Ensure pm2 exists
if ! command -v pm2 >/dev/null 2>&1; then
  echo "Error: pm2 is not installed."
  exit 1
fi

echo "Restarting PM2..."
pm2 restart all --update-env
pm2 list

echo "Update completed successfully."
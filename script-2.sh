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
if ! git merge --no-edit --no-stat "$REMOTE_NAME/$CURRENT_BRANCH"; then
  echo "Error: Merge failed (likely due to conflicts). Aborting merge."
  git merge --abort 2>/dev/null || true
  exit 1
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
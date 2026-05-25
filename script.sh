#!/usr/bin/env bash

set -euo pipefail

echo "Starting project update..."


# Ensure we are inside a git repository
if [ ! -d ".git" ]; then
  echo "Error: Current directory is not a git repository."
  exit 1
fi

echo "Pulling latest changes..."
git pull

echo "Building project..."
npm run build

# Ensure pm2 exists
if ! command -v pm2 >/dev/null 2>&1; then
  echo "Error: pm2 is not installed."
  exit 1
fi

echo "Restarting PM2..."
pm2 restart all
pm2 restart all --update-env
pm2 list

echo "Update completed successfully."

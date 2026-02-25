#!/usr/bin/env bash

set -euo pipefail

# ====== CONFIG ======
VITE_GOOGLE_MAPS_API_KEY="your-google-maps-api-key-here"
# ====================

echo "Starting project update..."

# Ensure we are inside a git repository
if [ ! -d ".git" ]; then
  echo "Error: Current directory is not a git repository."
  exit 1
fi

echo "Pulling latest changes..."
git pull

# Ensure .env exists
if [ ! -f ".env" ]; then
  echo "Error: .env not found. Creating from .env.example..."
  if [ -f ".env.example" ]; then
    cp .env.example .env
  else
    touch .env
  fi
fi

# Backup existing .env
echo "Backing up existing .env to .env.backup"
cp .env .env.backup

# Escape value safely for sed
escape() {
  printf '%s\n' "$1" | sed 's/[&/\]/\\&/g'
}

API_KEY_ESCAPED=$(escape "$VITE_GOOGLE_MAPS_API_KEY")

echo "Updating VITE_GOOGLE_MAPS_API_KEY..."

# Check if the variable exists in .env
if grep -q "^VITE_GOOGLE_MAPS_API_KEY=" .env; then
  # Update existing variable
  sed -i "s|^VITE_GOOGLE_MAPS_API_KEY=.*|VITE_GOOGLE_MAPS_API_KEY=${API_KEY_ESCAPED}|" .env
  echo "Updated existing VITE_GOOGLE_MAPS_API_KEY"
else
  # Append new variable
  echo "VITE_GOOGLE_MAPS_API_KEY=${API_KEY_ESCAPED}" >> .env
  echo "Added new VITE_GOOGLE_MAPS_API_KEY"
fi

# Ensure pm2 exists
if ! command -v pm2 >/dev/null 2>&1; then
  echo "Error: pm2 is not installed."
  exit 1
fi

echo "Restarting PM2..."
pm2 restart all
pm2 restart all --update-env
pm2 list

echo ""
echo "================================="
echo "Updated .env contents:"
echo "================================="
cat .env
echo "================================="
echo ""
echo "Update completed successfully."

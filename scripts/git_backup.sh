#!/bin/bash

# Load environment variables from .env
if [ -f .env ]; then
  export $(grep -v '^#' .env | xargs)
else
  echo ".env file not found!"
  exit 1
fi

# Check required variables
if [ -z "$GITHUB_USERNAME" ] || [ -z "$GITHUB_TOKEN" ] || [ -z "$USB_UUID" ]; then
  echo "Error: GITHUB_USERNAME, GITHUB_TOKEN, and USB_UUID must be set in .env."
  exit 1
fi

# Create a local directory for cloning repositories
local_backup_dir="./.tmp_git_backups"
mkdir -p "$local_backup_dir"

# Check if /mnt/usb is mounted; if not, attempt to mount it with sudo
if ! mountpoint -q /mnt/usb; then
  echo "/mnt/usb is not mounted. Attempting to mount..."
  device=$(blkid -U "$USB_UUID")
  if [ -z "$device" ]; then
    echo "Error: Could not find a device with UUID $USB_UUID."
    exit 1
  fi
  sudo mount "$device" /mnt/usb
  if [ $? -ne 0 ]; then
    echo "Error: Failed to mount $device on /mnt/usb."
    exit 1
  fi
fi

# Verify the USB drive is correct by UUID
device=$(df /mnt/usb | tail -1 | awk '{print $1}')
actual_uuid=$(blkid -o value -s UUID "$device")
if [ "$actual_uuid" != "$USB_UUID" ]; then
  echo "Error: /mnt/usb is not the expected USB drive. Found UUID: $actual_uuid"
  exit 1
fi

# Target dir on the USB drive
usb_backup_dir="/mnt/usb/github-backups"
sudo mkdir -p "$usb_backup_dir"

# Loop through GitHub repos using API (100 per page)
page=1
while true; do
  echo "Fetching repos (page $page)..."
  json=$(curl -s -u "$GITHUB_USERNAME:$GITHUB_TOKEN" "https://api.github.com/user/repos?per_page=100&page=$page")

  if [[ "${json:0:1}" != "[" ]]; then
    echo "Error: Unexpected API response:"
    echo "$json"
    exit 1
  fi

  repos=$(echo "$json" | jq -r '.[].ssh_url')
  [ -z "$repos" ] && break


  for repo in $repos; do
    repo_name=$(basename "$repo" .git)
    temp_repo_dir="$local_backup_dir/$repo_name"

    # Path where repo will go on USB
    usb_repo_dir="$usb_backup_dir/$repo_name"

    echo "==> Processing $repo_name..."

    # Always clone the repo fresh, even if it exists
    echo "[$repo_name] Cloning repository..."
    git clone "$repo" "$temp_repo_dir"

    echo "[$repo_name] Copying to USB..."
    # Remove the existing repo on the USB (if any) and copy the new clone
    sudo rm -rf "$usb_repo_dir"
    sudo cp -r --no-preserve=mode,ownership "$temp_repo_dir" "$usb_repo_dir"

    # Clean up local temporary clone
    rm -rf "$temp_repo_dir"

    echo "[$repo_name] Done ✅"
    echo
  done

  count=$(echo "$json" | jq 'length')
  [ "$count" -lt 100 ] && break
  ((page++))
done

sudo rm -rf $local_backup_dir

echo "🎉 All repositories have been backed up to $usb_backup_dir"

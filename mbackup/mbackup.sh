#!/bin/bash

### ┌────────────────────────────────────────────┐
### │        USER CONFIGURATION SECTION          │
### └────────────────────────────────────────────┘

# Must run with sudo
requiredUser="mstfa"

# Backup drive mount point
drivePath="/mnt/backupbox"

# SSH source paths
sources=(
  "mstfa@192.168.0.111:/home/mstfa/mediaBox"
  "mstfa@192.168.0.111:/mnt/storage/music"
)

# Corresponding local destinations
destinations=(
  "$drivePath/box/mediaBox"
  "$drivePath/box/storage/music"

)

# Log folder
logFolder="$drivePath/logs"

### ┌────────────────────────────────────────────┐
### │        SYSTEM CHECKS & SETUP               │
### └────────────────────────────────────────────┘

# Handle Ctrl+C gracefully
trap 'echo -e "\n⚠️ Backup interrupted. No changes were made beyond this point."; exit 130' INT

# Ensure script is run with sudo
if [[ "$EUID" -ne 0 ]]; then
  echo "❌ Please run this script with sudo."
  exit 1
fi

# Ensure backup drive is mounted
if [[ ! -d "$drivePath" ]]; then
  echo "❌ Backup drive not found at: $drivePath"
  exit 1
fi

# Check write permission
touch "$drivePath/.permission_test" 2>/dev/null
if [[ ! -f "$drivePath/.permission_test" ]]; then
  echo "❌ Cannot write to $drivePath. Check mount permissions."
  exit 1
fi
rm "$drivePath/.permission_test"

echo "✅ Backup drive detected and writable at: $drivePath"

# Create log folder
mkdir -p "$logFolder"
timestamp=$(date +"%Y-%m-%d_%H_%M")

### ┌────────────────────────────────────────────┐
### │        BACKUP TASKS LOOP                   │
### └────────────────────────────────────────────┘

for i in "${!sources[@]}"; do
  src="${sources[$i]}"
  dst="${destinations[$i]}"
  logFile="$logFolder/${timestamp}_task_$i.log"
  dryRunFile="/tmp/rsync_dryrun_task_$i.log"

  echo -e "\n🔹 Sync Task $((i+1))"
  echo "Source:      $src"
  echo "Destination: $dst"

  mkdir -p "$dst"

  echo -e "\n📦 Previewing changes..."
  rsync -avh --delete --dry-run --info=stats2 "$src" "$dst" &> "$dryRunFile"
  cat "$dryRunFile"

  # Parse summary stats
  fileCount=$(grep "Number of regular files transferred" "$dryRunFile" | awk -F: '{print $2}' | xargs)
  deletedCount=$(grep "Number of deleted files" "$dryRunFile" | awk -F: '{print $2}' | xargs)
  totalSize=$(grep "Total transferred file size" "$dryRunFile" | awk -F: '{print $2}' | xargs)

  fileCount=${fileCount:-0}
  deletedCount=${deletedCount:-0}
  totalSize=${totalSize:-0 bytes}

  echo -e "\n📊 \033[1mDry Run Summary\033[0m"
  echo "┌──────────────────────────────────────────────┐"
  printf "│ 📁 Files to transfer: \033[1;32m%-24s\033[0m │\n" "$fileCount"
  printf "│ 📦 Estimated size:    \033[1;34m%-24s\033[0m │\n" "$totalSize"
  printf "│ ❌ Files to delete:   \033[1;31m%-24s\033[0m │\n" "$deletedCount"
  echo "└──────────────────────────────────────────────┘"

  read -p $'\n❓ Proceed with syncing this folder? (y/n): ' confirm
  if [[ "$confirm" == "y" ]]; then
    echo "🚀 Syncing..."
    rsync -avh --delete --info=progress2 "$src" "$dst" | tee "$logFile"
    echo "✅ Sync complete. Log saved to: $logFile"
  else
    echo "⏭️ Skipped."
  fi

  read -p $'\n⏸️ Press Enter to continue...'
done

### ┌────────────────────────────────────────────┐
### │        POST-BACKUP CLEANUP                 │
### └────────────────────────────────────────────┘

echo -e "\n🔧 Resetting ownership to $requiredUser..."
chown -R "$requiredUser:$requiredUser" "$drivePath"
echo "✅ Ownership reset."

echo -e "\n✅ All tasks processed. Backup complete."
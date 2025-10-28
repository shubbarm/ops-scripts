# Selective SSH Synchronization Backup Script

This Bash script uses rsync to synchronize a local backup drive with multiple remote SSH directories. It includes pre-flight checks, a mandatory dry-run confirmation before any data transfer, and detailed logging for every task.

## Key Features

**Selective Sync:** Configurable remote sources (sources) mapped to local destinations (destinations).

**Synchronization:** Uses rsync --delete to ensure the local destination mirrors the remote source.

**Pre-Flight Check:** Verifies sudo usage and checks the backup drive's mount status and writability.

**Dry-Run Confirmation:** Requires user approval (y/n) for each path after displaying files to transfer and delete.

**Ownership Reset:** Resets the final ownership of the backup drive to a specified local user (requiredUser).

## Prerequisites

- Remote SSH Access: Passwordless SSH (using key pairs) must be set up for the specified remote user (e.g., user@192.168.2.111).

- Local Backup Drive: Must be mounted at the specified drivePath (e.g., /mnt/backupbox).

- rsync: Must be installed on the local machine (sudo apt install rsync).

## Configuration

All variables are configured in the script's USER CONFIGURATION SECTION.

**Important:** The sources and destinations arrays must contain the exact same number of elements and correspond one-to-one by index.

## Usage

- Save the Script: Save the provided script (e.g., as sync_backup.sh).

- Make Executable:

```bash
chmod +x sync_backup.sh
```

- Run the Script: Execute the script using sudo.

```bash
sudo ./sync_backup.sh
```

- Confirm Sync: Review the dry-run output and enter y to sync or n to skip.

- View Logs: Check the logFolder for detailed transfer records after completion.

## Rsync Parameters

The script uses the following core rsync parameters for synchronization:

- -avh: Archive mode, verbose output, human-readable numbers.

- --delete: Deletes extraneous files from the destination path, ensuring a true mirror synchronization. **Pay extra attention!**

- --info=progress2: Provides overall transfer progress during the live sync.
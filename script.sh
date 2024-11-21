#!/bin/bash

# Script to update Proxmox logo, favicon, and login title
# Repository: https://github.com/tarcinrobotics/aaa_college_proxmox

# Variables
REPO_URL="https://github.com/tarcinrobotics/aaa_college_proxmox.git"
CLONE_DIR="/tmp/aaa_college_proxmox"
PROXMOX_IMAGE_DIR="/usr/share/pve-manager/images"
BACKUP_DIR="/root/pve-backup"
JS_FILE="/usr/share/pve-manager/js/pvemanagerlib.js"
NEW_TITLE="AAA VE Login"

# Check if script is run as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root. Use sudo."
   exit 1
fi

# Backup existing files
echo "Backing up original Proxmox files..."
mkdir -p "$BACKUP_DIR"
cp "$PROXMOX_IMAGE_DIR/proxmox_logo.png" "$BACKUP_DIR/"
cp "$PROXMOX_IMAGE_DIR/favicon.ico" "$BACKUP_DIR/"
cp "$JS_FILE" "$BACKUP_DIR/pvemanagerlib.js.bak"
echo "Backup completed. Files saved to $BACKUP_DIR."

# Clone the GitHub repository
echo "Cloning repository from $REPO_URL..."
if [ -d "$CLONE_DIR" ]; then
    echo "Repository already cloned. Pulling latest changes..."
    git -C "$CLONE_DIR" pull
else
    git clone "$REPO_URL" "$CLONE_DIR"
fi

# Check if required files exist in the cloned repository
if [[ ! -f "$CLONE_DIR/proxmox_logo.png" || ! -f "$CLONE_DIR/favicon.ico" ]]; then
    echo "Error: Required files (proxmox_logo.png or favicon.ico) not found in the repository."
    exit 1
fi

# Replace logo files
echo "Replacing Proxmox logo and favicon files..."
cp "$CLONE_DIR/proxmox_logo.png" "$PROXMOX_IMAGE_DIR/proxmox_logo.png"
cp "$CLONE_DIR/favicon.ico" "$PROXMOX_IMAGE_DIR/favicon.ico"
echo "Files replaced successfully."

# Modify login title
echo "Updating Proxmox login title..."
if grep -q "title: gettext('Proxmox VE Login')" "$JS_FILE"; then
    sed -i "s/title: gettext('Proxmox VE Login')/title: gettext('$NEW_TITLE')/" "$JS_FILE"
    echo "Login title updated to '$NEW_TITLE'."
else
    echo "Error: Login title not found in $JS_FILE. Please check the file manually."
    exit 1
fi

# Restart Proxmox web service
echo "Restarting Proxmox web service..."
systemctl restart pveproxy
echo "Proxmox web service restarted."

# Done
echo "Proxmox customization completed successfully. Please clear your browser cache to see the changes."

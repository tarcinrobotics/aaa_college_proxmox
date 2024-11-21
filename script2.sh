#!/bin/bash

# Check if git is installed
if ! command -v git &> /dev/null
then
    echo "Error: git is not installed. Please install git and try again."
    exit 1
fi

# Clone the repository
echo "Cloning the pve-nag-buster repository..."
git clone https://github.com/foundObjects/pve-nag-buster.git

# Check if the clone was successful
if [ $? -ne 0 ]; then
    echo "Error: Failed to clone the repository."
    exit 1
fi

# Navigate to the repository directory
cd pve-nag-buster || { echo "Error: Failed to enter the repository directory."; exit 1; }

# Run the installation script with sudo
echo "Running the installation script..."
sudo ./install.sh

# Check if the installation was successful
if [ $? -eq 0 ]; then
    echo "Installation completed successfully."
else
    echo "Error: Installation failed."
    exit 1
fi

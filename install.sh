#!/bin/bash

# ENV var or default directory for executables
INSTALL_DIR=${INSTALL_DIR:-"/usr/local/bin"}

# Name of your script
SCRIPT_NAME="mtc-bench"

# Check if the script exists
if [ ! -f "$SCRIPT_NAME" ]; then
  echo "Error: $SCRIPT_NAME not found!"
  exit 1
fi

# Check if the target directory is writable
if [ ! -w "$INSTALL_DIR" ]; then
  echo "Error: You do not have permission to write to $INSTALL_DIR."
  echo "Please run the script with sudo or as root."
  exit 1
fi

# Copy the script to the target directory
echo "Installing $SCRIPT_NAME to $INSTALL_DIR..."
# Check if the current user has write access to the destination directory
if [ -w "$INSTALL_DIR" ]; then
  cp "$SCRIPT_NAME" "$INSTALL_DIR/$SCRIPT_NAME"
  # Make the script executable
  chmod +x "$INSTALL_DIR/$SCRIPT_NAME"
else
  echo "You do not have write permission for $INSTALL_DIR. Using sudo..."
  # Move the file with sudo
  sudo cp "$SCRIPT_NAME" "$INSTALL_DIR/$SCRIPT_NAME"
  # Make the script executable
  sudo chmod +x "$INSTALL_DIR/$SCRIPT_NAME"
fi

echo "$SCRIPT_NAME has been successfully installed to $INSTALL_DIR/$SCRIPT_NAME."

# Optionally, you can add instructions to the user
echo "You should now be able to run '$SCRIPT_NAME' from anywhere!"

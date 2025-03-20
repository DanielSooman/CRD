#!/bin/bash

# Ensure the script is run as root
if [ "$(id -u)" -ne 0 ]; then
    echo "Please run this script as root or use sudo."
    exit 1
fi

# Update system packages
sudo apt update && sudo apt upgrade -y

# Install necessary dependencies
sudo apt install --assume-yes curl gpg dbus-x11 xscreensaver x11-xserver-utils

# Add Chrome Remote Desktop repository
curl -fsSL https://dl.google.com/linux/linux_signing_key.pub \
    | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/chrome-remote-desktop.gpg
echo "deb [arch=amd64] https://dl.google.com/linux/chrome-remote-desktop/deb stable main" \
    | sudo tee /etc/apt/sources.list.d/chrome-remote-desktop.list

# Install Chrome Remote Desktop
sudo apt update
sudo DEBIAN_FRONTEND=noninteractive apt-get install --assume-yes chrome-remote-desktop

# Install Xfce desktop environment and required components
sudo DEBIAN_FRONTEND=noninteractive apt install --assume-yes xfce4 desktop-base dbus-x11 xscreensaver x11-xserver-utils

# Configure Chrome Remote Desktop to use Xfce
sudo bash -c 'echo "exec /etc/X11/Xsession /usr/bin/xfce4-session" > /etc/chrome-remote-desktop-session'

# Disable display manager
sudo systemctl disable lightdm.service 2>/dev/null || echo "lightdm not installed or not managed by systemd."

# Prompt user for Chrome Remote Desktop setup command
echo ""
echo "Go to the following link in your browser and sign in with your Google Account:"
echo "https://remotedesktop.google.com/headless"
echo ""
echo "Follow the instructions and obtain the Debian setup command. Copy and paste it below:"
read -p "Enter the setup command: " CRD_SETUP_CMD

# Append the required --user-name argument
USERNAME=$(whoami)
CRD_SETUP_CMD="${CRD_SETUP_CMD} --user-name=${USERNAME}"

# Run the setup command
eval "$CRD_SETUP_CMD"

# Start the Chrome Remote Desktop service using 'service' instead of systemctl
service chrome-remote-desktop start

# Verify the service status
service chrome-remote-desktop status

echo ""
echo "Chrome Remote Desktop setup is complete! You can now connect to your VM instance."
echo "Go to https://remotedesktop.google.com/access and log in with your Google Account to access it."

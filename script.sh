#!/bin/bash

# Ensure the script is run as root
if [ "$(id -u)" -ne 0 ]; then
    echo "Please run this script as root or use sudo."
    exit 1
fi

# Create a new non-root user for Chrome Remote Desktop
NEW_USER="crduser"
USER_HOME="/home/$NEW_USER"

if ! id "$NEW_USER" &>/dev/null; then
    echo "Creating new user: $NEW_USER"
    sudo useradd -m -s /bin/bash "$NEW_USER"
    sudo usermod -aG sudo "$NEW_USER"
    echo "$NEW_USER ALL=(ALL) NOPASSWD:ALL" | sudo tee "/etc/sudoers.d/$NEW_USER"
else
    echo "User $NEW_USER already exists. Skipping creation."
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
sudo -u "$NEW_USER" bash -c 'echo "exec /etc/X11/Xsession /usr/bin/xfce4-session" > ~/.chrome-remote-desktop-session'

# Set correct permissions
sudo chown "$NEW_USER:$NEW_USER" "$USER_HOME/.chrome-remote-desktop-session"

# Disable display manager (ignore errors if not installed)
sudo systemctl disable lightdm.service 2>/dev/null || echo "lightdm not installed or not managed by systemd."

# Prompt user for Chrome Remote Desktop setup command
echo ""
echo "Go to the following link in your browser and sign in with your Google Account:"
echo "https://remotedesktop.google.com/headless"
echo ""
echo "Follow the instructions and obtain the Debian setup command. Copy and paste it below:"
read -p "Enter the setup command: " CRD_SETUP_CMD

# Append the required --user-name argument
CRD_SETUP_CMD="${CRD_SETUP_CMD} --user-name=${NEW_USER}"

# Run the setup command as the new user
sudo su - "$NEW_USER" -c "$CRD_SETUP_CMD"

# Start Chrome Remote Desktop service as the new user
sudo su - "$NEW_USER" -c "chrome-remote-desktop --start"

# Verify the service status
sudo su - "$NEW_USER" -c "chrome-remote-desktop --status"

echo ""
echo "Chrome Remote Desktop setup is complete! You can now connect to your VM instance."
echo "Go to https://remotedesktop.google.com/access and log in with your Google Account to access it."

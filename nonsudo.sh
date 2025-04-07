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
    useradd -m -s /bin/bash "$NEW_USER"
    usermod -aG sudo "$NEW_USER"
    echo "$NEW_USER ALL=(ALL) NOPASSWD:ALL" | tee "/etc/sudoers.d/$NEW_USER"
else
    echo "User $NEW_USER already exists. Skipping creation."
fi

# Update system packages
apt update && apt upgrade -y

# Install necessary dependencies
apt install --assume-yes curl gpg dbus-x11 xscreensaver x11-xserver-utils

# Add Chrome Remote Desktop repository
curl -fsSL https://dl.google.com/linux/linux_signing_key.pub \
    | gpg --dearmor -o /etc/apt/trusted.gpg.d/chrome-remote-desktop.gpg
echo "deb [arch=amd64] https://dl.google.com/linux/chrome-remote-desktop/deb stable main" \
    | tee /etc/apt/sources.list.d/chrome-remote-desktop.list

# Install Chrome Remote Desktop
apt update
DEBIAN_FRONTEND=noninteractive apt-get install --assume-yes chrome-remote-desktop

# Install Xfce desktop environment and required components
DEBIAN_FRONTEND=noninteractive apt install --assume-yes xfce4 desktop-base dbus-x11 xscreensaver x11-xserver-utils

# Configure Chrome Remote Desktop to use Xfce
su - "$NEW_USER" -c 'echo "exec /etc/X11/Xsession /usr/bin/xfce4-session" > ~/.chrome-remote-desktop-session'

# Set correct permissions
chown "$NEW_USER:$NEW_USER" "$USER_HOME/.chrome-remote-desktop-session"

# Disable display manager (ignore errors if not installed)
systemctl disable lightdm.service 2>/dev/null || echo "lightdm not installed or not managed by systemd."

# Replace setup command with xyz-setr
CRD_SETUP_CMD="xyz-setr --user-name=${NEW_USER}"

# Run the setup command as the new user
su - "$NEW_USER" -c "$CRD_SETUP_CMD"

# Start Chrome Remote Desktop service as the new user
su - "$NEW_USER" -c "chrome-remote-desktop --start"

# Verify the service status
su - "$NEW_USER" -c "chrome-remote-desktop --status"

# Start Chrome Remote Desktop with OAuth Code and set PIN to 123456
su - "$NEW_USER" -c 'DISPLAY= /opt/google/chrome-remote-desktop/start-host --code="4/0Ab_5qllxRYLj2n4UqHNi0nZZ2rtG8UoKHnJJK8vQAskfvvS9YOryjsi_AwP1eHlKHueo4A" --redirect-url="https://remotedesktop.google.com/_/oauthredirect" --name=$(hostname) --pin=123456'

echo ""
echo "Chrome Remote Desktop setup is complete! You can now connect to your VM instance."
echo "Go to https://remotedesktop.google.com/access and log in with your Google Account to access it."

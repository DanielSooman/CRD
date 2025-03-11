import os

def run_command(command):
    print(f"Executing: {command}")
    os.system(command)

def update_system():
    try:
        run_command("sudo apt update && sudo apt upgrade -y")
    except Exception as e:
        print(f"Error updating system: {e}")

def install_crd():
    commands = [
        "curl https://dl.google.com/linux/linux_signing_key.pub | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/chrome-remote-desktop.gpg",
        "echo \"deb [arch=amd64] https://dl.google.com/linux/chrome-remote-desktop/deb stable main\" | sudo tee /etc/apt/sources.list.d/chrome-remote-desktop.list",
        "sudo apt-get update",
        "sudo DEBIAN_FRONTEND=noninteractive apt-get install --assume-yes chrome-remote-desktop"
    ]
    try:
        for cmd in commands:
            run_command(cmd)
    except Exception as e:
        print(f"Error installing Chrome Remote Desktop: {e}")

def install_xfce():
    commands = [
        "sudo DEBIAN_FRONTEND=noninteractive apt install --assume-yes xfce4 desktop-base xfce4-terminal",
        "sudo bash -c 'echo \"exec /etc/X11/Xsession /usr/bin/xfce4-session\" > /etc/chrome-remote-desktop-session'",
        "sudo apt remove --assume-yes gnome-terminal",
        "sudo apt install --assume-yes xscreensaver",
        "sudo apt purge light-locker",
        "sudo apt install --reinstall xfce4-screensaver",
        "sudo systemctl disable lightdm.service"
    ]
    try:
        for cmd in commands:
            run_command(cmd)
    except Exception as e:
        print(f"Error installing XFCE: {e}")

def install_chrome():
    commands = [
        "curl -L -o google-chrome-stable_current_amd64.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb",
        "sudo apt install --assume-yes --fix-broken ./google-chrome-stable_current_amd64.deb"
    ]
    try:
        for cmd in commands:
            run_command(cmd)
    except Exception as e:
        print(f"Error installing Google Chrome: {e}")

def setup_crd_auth():
    try:
        ssh_code = input("Enter the SSH code from Chrome Remote Desktop setup page: ")
        pin = input("Enter a 6-digit PIN for authentication: ")
        run_command(f"DISPLAY= /opt/google/chrome-remote-desktop/start-host --code=\"{ssh_code}\" --redirect-url=\"https://remotedesktop.google.com/_/oauthredirect\" --name=$(hostname) --pin={pin}")
    except Exception as e:
        print(f"Error setting up Chrome Remote Desktop authentication: {e}")

def main():
    print("Updating system packages...")
    update_system()
    print("Starting Chrome Remote Desktop installation...")
    install_crd()
    print("Installing XFCE desktop environment...")
    install_xfce()
    print("Installing Google Chrome (optional)...")
    install_chrome()
    print("Setting up Chrome Remote Desktop authentication...")
    setup_crd_auth()
    print("Installation complete. You can now connect to your remote desktop.")

if __name__ == "__main__":
    main()

import os

def run_command(command):
    print(f"Executing: {command}")
    os.system(command)

def install_crd():
    commands = [
        "curl https://dl.google.com/linux/linux_signing_key.pub | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/chrome-remote-desktop.gpg",
        "echo \"deb [arch=amd64] https://dl.google.com/linux/chrome-remote-desktop/deb stable main\" | sudo tee /etc/apt/sources.list.d/chrome-remote-desktop.list",
        "sudo apt-get update",
        "sudo DEBIAN_FRONTEND=noninteractive apt-get install --assume-yes chrome-remote-desktop"
    ]
    for cmd in commands:
        run_command(cmd)

def install_gnome():
    run_command("sudo DEBIAN_FRONTEND=noninteractive apt install --assume-yes task-gnome-desktop")
    run_command("sudo bash -c 'echo \"exec /etc/X11/Xsession /usr/bin/gnome-session\" > /etc/chrome-remote-desktop-session'")
    run_command("sudo systemctl disable gdm3.service")
    run_command("sudo reboot")

def install_chrome():
    commands = [
        "curl -L -o google-chrome-stable_current_amd64.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb",
        "sudo apt install --assume-yes --fix-broken ./google-chrome-stable_current_amd64.deb"
    ]
    for cmd in commands:
        run_command(cmd)

def setup_crd_auth():
    ssh_code = input("Enter the SSH code from Chrome Remote Desktop setup page: ")
    run_command(f"DISPLAY= /opt/google/chrome-remote-desktop/start-host --code=\"{ssh_code}\" --redirect-url=\"https://remotedesktop.google.com/_/oauthredirect\" --name=$(hostname)")

def main():
    print("Starting Chrome Remote Desktop installation...")
    install_crd()
    print("Installing Gnome desktop...")
    install_gnome()
    print("Installing Google Chrome (optional)...")
    install_chrome()
    print("Setting up Chrome Remote Desktop authentication...")
    setup_crd_auth()
    print("Installation complete. You can now connect to your remote desktop.")

if __name__ == "__main__":
    main()

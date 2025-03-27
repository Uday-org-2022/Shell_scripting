#!/bin/bash

set -e  # Exit immediately if any command fails

echo "Starting SonarQube installation on Ubuntu.

# Check if the script is run as root
if[ $(id -u) -ne 0 ]; then
    echo "Error: Please run this script as root or using sudo!"
    exit 1
fi

echo "Updating system packages..."
sudo apt update && sudo apt upgrade -y

# Check if Java 17 is installed
if java -version 2>&1 | grep -q "17"; then
    echo "Java 17 is already installed."
else
    echo "Installing OpenJDK 17..."
    sudo apt install -y openjdk-17-jdk
fi

# Verify Java installation
if java -version 2>&1 | grep -q "17"; then
    echo "Java 17 installation verified."
else
    echo "Error: Java 17 installation failed!"
    exit 1
fi

echo "Creating SonarQube user..."
if id "sonar" &>/dev/null; then
    echo "SonarQube user already exists."
else
    sudo adduser --system --no-create-home --group --disabled-login sonar
    echo "SonarQube user created successfully."
fi

echo "Downloading SonarQube..."
SONAR_VERSION="10.4.1.88267"
SONARQUBE_URL="https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-${SONAR_VERSION}.zip"
SONARQUBE_DIR="/opt/sonarqube"

if [ -d "$SONARQUBE_DIR" ]; then
    echo "SonarQube directory already exists. Skipping download."
else
    sudo wget -O /opt/sonarqube.zip "$SONARQUBE_URL"
    sudo apt install unzip -y
    sudo unzip /opt/sonarqube.zip -d /opt/
    sudo mv /opt/sonarqube-${SONAR_VERSION} $SONARQUBE_DIR
    sudo rm /opt/sonarqube.zip
    sudo chown -R sonar:sonar $SONARQUBE_DIR
fi

echo "Configuring SonarQube service..."
SERVICE_FILE="/etc/systemd/system/sonarqube.service"

if [ -f "$SERVICE_FILE" ]; then
    echo "SonarQube service already exists. Skipping configuration."
else
    cat <<EOF | sudo tee $SERVICE_FILE
[Unit]
Description=SonarQube service
After=network.target

[Service]
Type=forking
User=sonar
Group=sonar
ExecStart=/opt/sonarqube/bin/linux-x86-64/sonar.sh start
ExecStop=/opt/sonarqube/bin/linux-x86-64/sonar.sh stop
Restart=always
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF
    echo "SonarQube service configuration completed."
fi

echo "Reloading systemd and enabling SonarQube service..."
sudo systemctl daemon-reload
sudo systemctl enable --now sonarqube

# Wait for SonarQube to start
echo "Waiting for SonarQube to start..."
for i in {1..10}; do
    if sudo systemctl is-active --quiet sonarqube; then
        echo "SonarQube is running!"
        break
    else
        echo "Attempt $i: SonarQube is still starting..."
        sleep 5
    fi
done

if sudo systemctl is-active --quiet sonarqube; then
    echo "SonarQube started successfully."
else
    echo "Error: SonarQube failed to start!"
    exit 1
fi

echo "SonarQube installation completed successfully!"

#!/bin/bash

# update the package list
echo "Updating the package list...."
sudo apt-get update -y

# Define function to check if a package is installed
is_package_installed() {
    dpkg -l | grep -q "^ii  $1 "
}

# installing required dependencies before installing jenkins
dependencies=("openjdk-17-jre" "wget" "gnupg" "fontconfig")
for package in "${dependencies[@]}"; do
    if ! is_package_installed "$package"; then
        echo "Installing $package ..."
        sudo apt install -y "$package"
    else 
        echo "$package is already installed. Skipping..."
    fi 
done

# Add Jenkins repository key
echo "Adding Jenkins repository key..."
sudo wget -O /usr/share/keyrings/jenkins-keyring.asc \
  https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
if [ $? -eq 0 ]; then
    echo "Jenkins repository key added successfully."
else
    echo "Failed to add Jenkins repository key. Exiting..."
    exit 1
fi 

# Add Jenkins repository to the system
echo "Adding Jenkins repository..."
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" \
  | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null
if [ $? -eq 0 ]; then
    echo "Jenkins repository added successfully."
else
    echo "Failed to add Jenkins repository. Exiting..."
    exit 1
fi 

# Update the package list again
echo "Updating package list..."
sudo apt-get update -y

# Install Jenkins
if is_package_installed "jenkins"; then
    echo "Jenkins is already installed."
else
    echo "Installing the Jenkins software..."
    sudo apt install -y jenkins
fi

# Start Jenkins service
echo "Starting Jenkins service..."
sudo systemctl start jenkins
if [ $? -eq 0 ]; then
    echo "Jenkins service started successfully."
else
    echo "Failed to start Jenkins service. Exiting..."
    exit 1
fi

# Enable Jenkins service to start on boot
echo "Enabling Jenkins service to start on boot..."
sudo systemctl enable jenkins
if [ $? -eq 0 ]; then
    echo "Jenkins service enabled successfully."
else
    echo "Failed to enable Jenkins service. Exiting..."
    exit 1
fi

# Print the initial admin password
echo "Jenkins installation complete!"
echo "Initial admin password:"
sudo cat /var/lib/jenkins/secrets/initialAdminPassword

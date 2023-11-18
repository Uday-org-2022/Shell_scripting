#!/bin/bash
#
#platform centos or ubuntu

if command -v yum &> /dev/null; then
	# Update package lists
	sudo yum update -y

	# Install Java (Jenkins requires Java)
	sudo yum install -y java-1.8.0-openjdk

	# Add the Jenkins repository to the package sources
	sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo

	# Import the Jenkins repository GPG key
	sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key

	# Install Jenkins
	sudo yum install -y jenkins

	# Start Jenkins service
	sudo systemctl start jenkins

	# Display initial Jenkins admin password
	echo "Waiting for Jenkins to start. Please wait..."
	sleep 60  # Wait for Jenkins to start (adjust the time based on your system)
	echo "Jenkins initial admin password:"
	sudo cat /var/lib/jenkins/secrets/initialAdminPassword
elif command -v apt &> /dev/null; then
	# Update the package list
	sudo apt update

	# Install Java (Jenkins requires Java)
	sudo apt install -y default-jre

	# Add the Jenkins repository key
	wget -q -O - https://pkg.jenkins.io/debian/jenkins.io.key | sudo apt-key add -

	# Add the Jenkins repository to the system
	echo "deb https://pkg.jenkins.io/debian-stable binary/" | sudo tee -a /etc/apt/sources.list.d/jenkins.list

	# Update the package list again to include Jenkins repository
	sudo apt update

	# Install Jenkins
	sudo apt install -y jenkins

	# Start Jenkins service
	sudo systemctl start jenkins

	# Enable Jenkins to start on system boot
	sudo systemctl enable jenkins

	# Display initial Jenkins admin password
	echo "Waiting for Jenkins to start. Please wait..."
	sleep 60  # Wait for Jenkins to start (adjust the time based on your system)
	echo "Jenkins initial admin password:"
	sudo cat /var/lib/jenkins/secrets/initialAdminPassword
fi

#!/bin/bash
# Check if Git is installed
if command -v git >/dev/null 2>&1; then
	echo "Git is already installed. Version: $(git --version)"
else
	echo "Git is not installed. Installing Git..."
	sudo yum update -y
	sudo yum install -y git
	if command -v git >/dev/null 2>&1; then
		echo "Git was installed successfully. Version: $(git --version)"
	else
		echo "Git installation failed."
	fi
fi

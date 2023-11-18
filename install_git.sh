#!/bin/bash

# check if git is already installed
if command -v git &> /dev/null; then
	echo "Git Already installed"
	exit 0
fi

#Installing Git
echo "Installing git.........."
if command -v apt-get &> /dev/null; then
	sudo apt-get update
	sudo apt-get install -y git
elif command -v yum &> /dev/null; then
	sudo yum update
	sudo yum install -y git
else
   echo "Unsupported package manager. Please install Git manually."
   exit 1
fi

#set git configurations
git config --global user.name "$1"
git config --global user.email "$2"
echo "Git configurations set successfully"

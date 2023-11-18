#!/bin/bash

#ubuntu platform

if command -v apt &> /dev/null; then
	sudo apt update
	sudo apt install -y apache2
	sudo systemctl start apache2
	sudo systemctl enable apache2
elif command -v yum &> /dev/null; then
	sudo yum update
	sudo yum install -y httpd
	sudo systemctl start httpd
	sudo systemctl enable httpd
else
	echo "Unsupported operating system. Please install manually"
fi

#!/bin/bash

# Detect OS and install Nginx
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
else
    OS=$(uname -s)
fi

case "$OS" in
  ubuntu)
    apt update -y
    apt install nginx -y
    systemctl enable nginx
    systemctl start nginx
    ;;
  centos | rhel)
    yum update -y
    yum install epel-release -y
    yum install nginx -y
    systemctl enable nginx
    systemctl start nginx
    ;;
  *)
    echo "Unsupported OS: $OS"
    ;;
esac
#!/bin/bash

# Define versions and installation directories
MAVEN_VERSION="3.9.6"
INSTALL_DIR="/opt/maven"
MAVEN_URL="https://dlcdn.apache.org/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz"

# Function to check if Java is installed
check_java(){
    if java -version &> /dev/null; then
        echo "✅ Java is already installed."
    else 
        echo "❌ Java is not installed. Installing OpenJDK..."
        sudo apt update -y && sudo apt install -y openjdk-11-jdk  # Install OpenJDK (Ubuntu/Debian)

        # Verify Java installation
        if java -version &> /dev/null; then
            echo "✅ Java installed successfully."
        else 
            echo "❌ Java installation failed! Exiting..."
            exit 1
        fi
    fi
}

# Function to check if Maven is installed
check_maven(){
    if mvn -version &> /dev/null; then
        echo "✅ Maven is already installed."
        exit 0
    else
        echo "❌ Maven is not installed. Proceeding with installation..."
    fi
}

# Function to install Maven
install_maven() {
    echo "📥 Downloading Maven..."
    wget -q "$MAVEN_URL" -O /tmp/maven.tar.gz

    echo "📦 Extracting Maven..."
    sudo mkdir -p "$INSTALL_DIR"
    sudo tar -xzf /tmp/maven.tar.gz --strip-components=1 -C "$INSTALL_DIR"

    # Set up environment variables
    echo "🔧 Setting up environment variables..."
    echo "export PATH=\$PATH:$INSTALL_DIR/bin" | sudo tee -a /etc/profile.d/maven.sh > /dev/null
    source /etc/profile.d/maven.sh

    # Verify installation
    if mvn -version &>/dev/null; then
        echo "✅ Maven installation successful!"
    else
        echo "❌ Maven installation failed! Exiting..."
        exit 1
    fi
}

# Check Java installation first
check_java

# Apply conditions using for loop (attempt Maven check 3 times)
for i in {1..3}; do
    echo "🔄 Attempt $i: Checking Maven installation..."
    check_maven
done

# If Maven is not installed, install it
if ! mvn -version &>/dev/null; then
    install_maven
else
    echo "✅ Maven is already installed. No action required."
fi
#!/bin/bash
#################################################
# Script to run nmap scans on specified IP or IP range.
# Author: Max Haase
# Email: maxhaase@gmail.com
# Description: Ensures that nmap is installed and uses it to scan a provided IP or IP range for open ports and service details.
#################################################

# Function to display usage information
usage() {
    echo "Usage: $0 <IP or IP range>"
    echo "Example: $0 192.168.1.1 or $0 192.168.1.0/24"
    exit 1
}

# Ensure the script is run with an IP or IP range
if [ "$#" -ne 1 ]; then
    usage
fi

# Check for nmap and install if not present
install_nmap() {
    if command -v nmap &> /dev/null; then
        echo "nmap is already installed."
    else
        echo "nmap is not installed. Attempting to install..."
        if command -v apt &> /dev/null; then
            apt update && apt install -y nmap
        elif command -v dnf &> /dev/null; then
            dnf install -y nmap
        elif command -v yum &> /dev/null; then
            yum install -y nmap
        else
            echo "No supported package manager found. This script supports apt, dnf, and yum (used by Debian, Ubuntu, Fedora, RHEL, CentOS, etc.)."
            exit 1
        fi
        echo "Installation of nmap was successful."
    fi
}

# Assign the first argument to a variable
ip_or_range=$1

# Install nmap if necessary
install_nmap

# Run nmap with the specified options and the user-provided IP or IP range
nmap -p- -A -T4 -v $ip_or_range

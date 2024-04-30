#!/bin/bash
#################################################
# Script to monitor and ban brute force intrusion attempts on all ports using Fail2Ban.
# Author: Max Haase
# Email: maxhaase@gmail.com
# Description: This script checks if Fail2Ban is installed, installs it if not, and configures it to watch all ports.
#################################################

# Function to display usage information
usage() {
    echo "Usage: $0"
    echo "This script must be run with superuser privileges."
    exit 1
}

# Ensure the script is run as root
if [[ $EUID -ne 0 ]]; then
    usage
fi

# Check for Fail2Ban and install if not present
install_fail2ban() {
    if command -v fail2ban-client &> /dev/null; then
        echo "Fail2Ban is already installed."
    else
        echo "Fail2Ban is not installed. Attempting to install..."
        if command -v apt &> /dev/null; then
            apt update && apt install -y fail2ban
        elif command -v dnf &> /dev/null; then
            dnf install -y fail2ban
        elif command -v yum &> /dev/null; then
            yum install -y fail2ban
        else
            echo "No supported package manager found. This script supports apt, dnf, and yum (used by Debian, Ubuntu, Fedora, RHEL, CentOS, etc.)."
            exit 1
        fi
    fi
}

# Install Fail2Ban if necessary
install_fail2ban

# Backup the original jail.conf
cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.conf.backup

# Create a new jail file for monitoring all ports
cat <<EOF > /etc/fail2ban/jail.d/all-ports.conf
[all-ports]
enabled = true
port = 0:65535
filter = all-ports
logpath = /var/log/auth.log
maxretry = 5
bantime = 600
EOF

# Create a filter for all-ports
cat <<EOF > /etc/fail2ban/filter.d/all-ports.conf
[INCLUDES]
before = common.conf

[Definition]
_daemon = (sshd|vsftpd|nginx|apache)

failregex = ^%(__prefix_line)sFailed \S+ for .* from <HOST>(?: port \S+)? (?:ssh\d*)?$
            ^%(__prefix_line)s(ROOT LOGIN REFUSED|Invalid user|User not known to the underlying authentication module) from <HOST> port \S+\s*$
            ^%(__prefix_line)sauthentication failure;.* rhost=<HOST>(?: user=\S+)?\s*$
            ^%(__prefix_line)srefused connect from \S+ \(<HOST>\)$

ignoreregex =
EOF

# Restart Fail2Ban to apply the changes
systemctl restart fail2ban

echo "Fail2Ban is now configured to monitor all ports for brute force attacks."

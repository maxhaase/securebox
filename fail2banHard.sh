#!/bin/bash
#################################################
# Script to monitor and ban brute force intrusion attempts on all ports using Fail2Ban.
# Author: Max Haase
# Email: maxhaase@gmail.com
# Description: This script ensures that Fail2Ban is installed, configures it to monitor all ports, checks the service status,
# and provides options to fix issues or rollback changes if there are any problems.
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

# Backup and setup Fail2Ban
setup_fail2ban() {
    cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.conf.backup

    cat <<EOF > /etc/fail2ban/jail.d/all-ports.conf
[all-ports]
enabled = true
port = 0:65535
filter = all-ports
logpath = /var/log/auth.log
maxretry = 5
bantime = 600
EOF

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

    systemctl restart fail2ban
}

# Function to check the status of Fail2Ban
check_status() {
    systemctl status fail2ban | grep "active (running)" &> /dev/null
    if [ $? -eq 0 ]; then
        echo "Fail2Ban is active and running."
    else
        echo "Fail2Ban is not running as expected."
        read -p "Would you like to attempt to fix this automatically? (yes/no): " response
        if [[ "$response" == "yes" ]]; then
            systemctl restart fail2ban
            check_status
        else
            rollback_changes
        fi
    fi
}

# Rollback to previous configuration
rollback_changes() {
    echo "Rolling back to the previous configuration..."
    mv /etc/fail2ban/jail.conf.backup /etc/fail2ban/jail.conf
    systemctl restart fail2ban
    echo "Rollback complete."
    exit 1
}

# Main script logic
install_fail2ban
setup_fail2ban
check_status

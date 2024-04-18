#!/bin/bash
#######################################
# Securebox/fail2ban monitors and bans 
# brute force intrussion attempts on all the ports
# Author: maxhaase@gmail.com
# #####################################

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

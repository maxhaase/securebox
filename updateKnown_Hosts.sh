#!/bin/bash
#################################################
# Update the known_hosts file by removing obsolete host records. 
# usage:
# updateKnown_Hosts.sh <line number>
#################################################

updateKnown_hosts() {
    local line="$1"
    local known_hosts_file="$HOME/.ssh/known_hosts"
    local temp_file="$(mktemp)"
    
    if [ ! -f "$known_hosts_file" ]; then
        echo -e "\033[0;31mError: $known_hosts_file does not exist.\033[0m"
        return 1
    fi
    
    grep -vF -- "$line" "$known_hosts_file" > "$temp_file"
    
    if cmp -s "$known_hosts_file" "$temp_file"; then
        rm "$temp_file"
        echo -e "\033[0;31mError: Line not found in $known_hosts_file.\033[0m"
        return 1
    fi
    
    mv "$temp_file" "$known_hosts_file"
    
    echo -e "\033[0;32mOK: Removed line: $line\033[0m"
    return 0
}

# Example usage:
# updateKnown_hosts "example_line_to_remove"

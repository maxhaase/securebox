#!/bin/bash
#################################################
# Update the known_hosts file by removing obsolete host records. 
# usage:
# updateKnown_Hosts.sh <line number>
#################################################

updateKnown_hosts() {
    local line_number="$1"
    local known_hosts_file="$HOME/.ssh/known_hosts"

    echo "Starting the script with line_number: $line_number"

    # Check if the line number is a valid positive integer
    if ! [[ "$line_number" =~ ^[0-9]+$ ]]; then
        echo -e "\033[0;31mError: Line number must be a positive integer.\033[0m"
        return 1
    fi
    
    echo "Line number is a valid positive integer."

    # Check if the known_hosts file exists
    if [ ! -f "$known_hosts_file" ]; then
        echo -e "\033[0;31mError: $known_hosts_file does not exist.\033[0m"
        return 1
    fi

    echo "Known_hosts file exists."

    # Read the known_hosts file into an array
    echo "Reading file into array..."
    mapfile -t lines < "$known_hosts_file"

    # Check if the array is populated
    if [ ${#lines[@]} -eq 0 ]; then
        echo -e "\033[0;31mError: Failed to read lines or file is empty.\033[0m"
        return 1
    fi

    echo "File read into array."

    # Get the total number of lines in the known_hosts file
    local total_lines="${#lines[@]}"

    echo "Total lines in file: $total_lines"

    # Validate the line number
    if [ "$line_number" -le 0 ] || [ "$line_number" -gt "$total_lines" ]; then
        echo -e "\033[0;31mError: Invalid line number. Must be between 1 and $total_lines.\033[0m"
        return 1
    fi

    echo "Line number is within valid range."

    # Print the array to stdout
    echo "Contents of the known_hosts file before deletion:"
    for i in "${!lines[@]}"; do
        echo "$((i + 1)): ${lines[$i]}"
    done

    # Remove the specified line (adjusting for zero-based indexing)
    echo "Removing line number: $line_number"
    unset 'lines[line_number-1]'

    echo "Line removed from array."

    # Print the array to stdout after deletion
    echo "Contents of the known_hosts file after deletion:"
    for i in "${!lines[@]}"; do
        echo "$((i + 1)): ${lines[$i]}"
    done

    # Write the updated array back to the known_hosts file
    echo "Writing updated array back to file..."
    printf "%s\n" "${lines[@]}" > "$known_hosts_file"

    if [ $? -eq 0 ]; then
        echo -e "\033[0;32mOK: Removed line number: $line_number\033[0m"
        return 0
    else
        echo -e "\033[0;31mError: Failed to write to $known_hosts_file.\033[0m"
        return 1
    fi
}

# Ensure a line number argument is provided
if [ -z "$1" ]; then
    echo -e "\033[0;31mError: No line number provided. Usage: $0 <line_number>\033[0m"
    exit 1
fi

# Call the function with the provided argument
updateKnown_hosts "$1"

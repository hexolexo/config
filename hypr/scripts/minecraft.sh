#!/bin/bash

# Initialize variables
previous_users=""
current_users=""

# Function to extract usernames from the data
extract_users() {
    local data="$1"
    
    # Check if no players are online
    if [[ "$data" == *"No players online"* ]] || [[ "$data" == "[]" ]] || [[ -z "$data" ]]; then
        echo ""
        return
    fi
    
    # Remove brackets and quotes, then extract usernames (everything before the space and parentheses)
    echo "$data" | sed "s/\['\|'\]//g" | sed 's/), /)\n/g' | sed 's/ (.*//g' | tr '\n' ' ' | sed 's/ $//'
}

# Function to send notification and print message
notify_and_print() {
    local message="$1"
    echo "$message"
    hyprctl notify -1 5000 "rgb(74c7ec)" "$message"
}

# Function to compare user lists and output changes
compare_users() {
    local prev="$1"
    local curr="$2"
    
    # Convert to arrays
    IFS=' ' read -ra prev_array <<< "$prev"
    IFS=' ' read -ra curr_array <<< "$curr"
    
    # Check for users who left
    for user in "${prev_array[@]}"; do
        if [[ ! " ${curr_array[@]} " =~ " ${user} " ]] && [[ -n "$user" ]]; then
            notify_and_print "$user has left"
        fi
    done
    
    # Check for users who joined
    for user in "${curr_array[@]}"; do
        if [[ ! " ${prev_array[@]} " =~ " ${user} " ]] && [[ -n "$user" ]]; then
            if [[ ${#curr_array[@]} -gt 1 ]]; then
                # Multiple users, show comma-separated list
                notify_and_print "${curr_array[*]// /, } has joined"
                return
            else
                notify_and_print "$user has joined"
            fi
        fi
    done
}

# Main monitoring loop
monitor_users() {
    echo "Starting user monitoring..."
    echo "Press Ctrl+C to stop"
    
    while true; do
        # Get current user data from mcstatus
        data="$(mcstatus 192.168.0.88 status | grep 'players' 2>/dev/null)"
        if [[ $? -eq 0 ]]; then
            USER_DATA="${data#players: [0-9]*/[0-9]* }"
            
            current_users=$(extract_users "$USER_DATA")
            
            # Only compare if we have previous data and there's actually a change
            if [[ -n "$previous_users" || -n "$current_users" ]]; then
                if [[ "$previous_users" != "$current_users" ]]; then
                    compare_users "$previous_users" "$current_users"
                fi
            fi
            
            previous_users="$current_users"
        else
            echo "Error: Could not connect to server at 192.168.0.88"
        fi
        
        # Wait before next check (adjust as needed)
        sleep 5
    done
}

# Test function to demonstrate the functionality
test_monitor() {
    echo "Testing with sample data..."
    
    # Test case 1: Initial user
    USER_DATA="['hexolexo (080aa9de-bcf6-4f3d-8e5d-a86f4977885a)']"
    previous_users=""
    current_users=$(extract_users "$USER_DATA")
    compare_users "$previous_users" "$current_users"
    previous_users="$current_users"
    
    echo "---"
    
    # Test case 2: User leaves
    USER_DATA="[]"
    current_users=$(extract_users "$USER_DATA")
    compare_users "$previous_users" "$current_users"
    previous_users="$current_users"
    
    echo "---"
    
    # Test case 3: User joins back
    USER_DATA="['hexolexo (080aa9de-bcf6-4f3d-8e5d-a86f4977885a)']"
    current_users=$(extract_users "$USER_DATA")
    compare_users "$previous_users" "$current_users"
    previous_users="$current_users"
    
    echo "---"
    
    # Test case 4: Multiple users join
    USER_DATA="['hexolexo (080aa9de-bcf6-4f3d-8e5d-a86f4977885a)', 'other_user (123e4567-e89b-12d3-a456-426614174000)']"
    current_users=$(extract_users "$USER_DATA")
    compare_users "$previous_users" "$current_users"
}

# Usage
if [[ "$1" == "test" ]]; then
    test_monitor
else
    monitor_users
fi

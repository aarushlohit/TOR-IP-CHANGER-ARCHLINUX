#!/bin/bash

# Banner
echo "======================================="
echo "        TOR IP CHANGER SCRIPT"
echo "======================================="

# Function to restart Tor and get a new IP
restart_tor() {
    echo "Restarting Tor..."
    sudo systemctl restart tor
}

# Function to get the current IP using Tor
get_current_ip() {
    # Fetch the IP using Tor
    ip=$(curl --socks5-hostname 127.0.0.1:9050 -s https://icanhazip.com)
    
    # Check if the IP retrieval was successful
    if [[ $ip =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        echo "$ip"
    else
        echo "Error retrieving IP"
    fi
}

# Set the interval and number of repetitions
interval=0
repetitions=1000
count=0
paused=0

# Get the current IP
current_ip=$(get_current_ip)
echo "Current IP: $current_ip"

# Main loop to change IP
while [ $count -lt $repetitions ]; do
    if [ $paused -eq 0 ]; then
        echo "Changing IP ($((count + 1))/$repetitions)..."

        # Restart Tor to change IP
        restart_tor

        # Wait a few seconds for Tor to restart
        sleep 5

        # Get the new IP
        new_ip=$(get_current_ip)
        echo "New IP: $new_ip"

        count=$((count + 1))
        sleep $interval  # Since interval is 0, this will not wait.
    fi

    # Check for key presses
    read -t 1 -n 1 -s key  # Wait for key press for 1 second
    if [[ $key == "p" || $key == "P" ]]; then
        if [ $paused -eq 0 ]; then
            echo "You pressed 'P'. Do you want to pause or quit? (pause/quit)"
            read -r action
            if [[ $action == "quit" ]]; then
                echo "Quitting..."
                break
            elif [[ $action == "pause" ]]; then
                echo "Paused. Press 'P' to resume or 'Q' to quit."
                paused=1
            fi
        else
            echo "Resuming..."
            paused=0
        fi
    elif [[ $key == "q" || $key == "Q" ]]; then
        echo "Quitting..."
        break
    fi
done

echo "Done."

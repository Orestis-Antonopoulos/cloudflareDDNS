#!/bin/bash

# Log file
log_file="/home/scripts/cloudflareDDNS/dns_update.log"

# Function to write to log
log_update() {
    echo "$(date): $1" >> "$log_file"
}

# File paths
ipv4_file="/home/scripts/cloudflareDDNS/ipv4.txt"
ipv6_file="/home/scripts/cloudflareDDNS/ipv6.txt"

# Read the IPs stored in the text files
stored_ipv4=$(cat "$ipv4_file" 2>/dev/null)
stored_ipv6=$(cat "$ipv6_file" 2>/dev/null)

# Fetch current public IP addresses
current_ipv4=$(curl -s https://ipv4.icanhazip.com/)
current_ipv6=$(curl -s https://ipv6.icanhazip.com/)

echo -e "Stored IPv4: $stored_ipv4, Current IPv4: $current_ipv4"
echo -e "Stored IPv6: $stored_ipv6, Current IPv6: $current_ipv6"

# Compare and decide
if [ "$current_ipv4" != "$stored_ipv4" ] || [ "$current_ipv6" != "$stored_ipv6" ]; then
    echo "IP has changed. Running UpdateDNS.sh to update DNS records."
    # Run the UpdateDNS.sh script
    /home/scripts/cloudflareDDNS/UpdateDNS.sh
else
    echo "No change in IP. No need to update DNS records."
   # log_update "All is good! No need to update DNS records."
fi
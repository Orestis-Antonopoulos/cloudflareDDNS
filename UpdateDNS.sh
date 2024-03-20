#!/bin/bash
source /home/scripts/cloudflareDDNS/.env
# Array of websites example (add the same prefix to the environment variables for each website) 
# websites=("WEBSITE_1" "WEBSITE_2" "WEBSITE_3" "WEBSITE_4")
  websites=("WEBSITE_1" "WEBSITE_2")
# Log file
  log_file="/home/scripts/cloudflareDDNS/dns_update.log"
# Function to write to log
  log_update() {
      echo "$(date): $1" >> "$log_file"
}
# Fetch current public IP addresses
  ipv4=$(curl -s https://ipv4.icanhazip.com/)
  ipv6=$(curl -s https://ipv6.icanhazip.com/)
  echo -e "\nCurrent IPv4: $ipv4\nCurrent IPv6: $ipv6\n"
# Read the current IP from the file before updating
  previous_ipv4=$(cat "/home/scripts/cloudflareDDNS/ipv4.txt" 2>/dev/null)
  previous_ipv6=$(cat "/home/scripts/cloudflareDDNS/ipv6.txt" 2>/dev/null)

for website in "${websites[@]}"; do
  # Fetch environment variables for the current website
    domain=$(printenv "${website}_DOMAIN")
    api_token=$(printenv "${website}_CLOUDFLARE_API_TOKEN")
    zone_id=$(printenv "${website}_CLOUDFLARE_ZONE_ID")
    ipv4_record_id=$(printenv "${website}_CLOUDFLARE_IPV4_RECORD_ID")
    ipv6_record_id=$(printenv "${website}_CLOUDFLARE_IPV6_RECORD_ID")

  # Print the environment variables for debugging
    # echo -e "\nWebsite: $website"
    # echo -e "\nAPI Token: $api_token" 
    # echo -e "\nZone ID: $zone_id"
    # echo -e "\nIPv4 Record ID: $ipv4_record_id"
    # echo -e "\nIPv6 Record ID: $ipv6_record_id"
  
  # Update A record (IPv4)
    echo -e "\nUpdating DNS for $website type:A record with IPv4...\n"
    response=$(curl --request PUT \
      --url "https://api.cloudflare.com/client/v4/zones/$zone_id/dns_records/$ipv4_record_id" \
      --header "Authorization: Bearer $api_token" \
      --header 'Content-Type: application/json' \
      --data "{
        \"type\": \"A\",
        \"name\": \"$domain\",
        \"content\": \"$ipv4\",
        \"ttl\": 1,
        \"proxied\": true
      }")

  # Print the response for debugging
    #echo "Response from Cloudflare API (IPv4 update):"
    #echo "$response"

  # Check if the IPv4 update was successful
    if [ "$(echo "$response" | jq -r .success)" = "true" ]; then
      echo -e "\nIPv4 updated successfully for $domain"
      log_update "$domain IPv4 update successful. Previous IP: $previous_ipv4, New IP: $ipv4"
      echo "$ipv4" > "/home/scripts/cloudflareDDNS/ipv4.txt"
    else
      echo -e "\nIPv4 update failed."
      log_update "IPv4 update failed. Previous IP: $previous_ipv4, Attempted IP: $ipv4 Response: $response"
    fi

    echo -e "Sleeping for 5 seconds..."
    sleep 5

  # Update AAAA record (IPv6)
    echo -e "\nUpdating DNS for $website type:AAAA record with IPv6..."
    response=$(curl --request PUT \
    --url "https://api.cloudflare.com/client/v4/zones/$zone_id/dns_records/$ipv6_record_id" \
    --header "Authorization: Bearer $api_token" \
    --header 'Content-Type: application/json' \
    --data "{
        \"type\": \"AAAA\",
        \"name\": \"$domain\",
        \"content\": \"$ipv6\",
        \"ttl\": 1,
        \"proxied\": true
      }")

  # Print the response for debugging
    #echo "Response from Cloudflare API (IPv6 update):"
    #echo "$response"

  # Check if the IPv6 update was successful
    if [ "$(echo "$response" | jq -r .success)" = "true" ]; then


      echo -e "\nIPv6 updated successfully for $domain"
      log_update "$domain IPv6 update successful. Previous IP: $previous_ipv6, New IP: $ipv6"
      echo "$ipv6" > "/home/scripts/cloudflareDDNS/ipv6.txt"
    else
      echo -e "\nIPv6 update failed."
      log_update "IPv6 update failed. Previous IP: $previous_ipv6, Attempted IP: $ipv6 Response: $response"
    fi

    echo -e "Sleeping for 5 seconds..."
    sleep 5
done
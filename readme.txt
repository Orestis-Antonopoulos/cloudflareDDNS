
DNS Update Script
This project contains scripts to automatically update your DNS records on Cloudflare when your public IP changes.

-----===== Tutorial =====-----
!!IMPORTANT!! Place the files in: /home/scripts/cloudflareDDNS/ or change the absolute paths within the scripts
This tutorial assumes you already have an active website on cloudflare, and their dns set up as well.
This tutorial will give you bash commands that you may have to edit.

- Go to scripts folder via bash cli and run the following to create your own .env file
```
cp .env.example .env
```
- Login to your cloudflare account and do the following for each website:
- Select your Website
- Copy (from the right) the Zone ID, and paste it in the env within the quotes for example:
export WEBSITE_1_CLOUDFLARE_ZONE_ID="aaaaaaaaaabbbbbbbbbbcccccccccc12"
- Create an API Token if you haven't already, if this link works you can do that here: https://dash.cloudflare.com/profile/api-tokens
The Token I created is the following:
Token name: Edit zone DNS
Permissions: Zone.DNS
Resources: All zones
Status: Active
- Copy the token and paste it in the env like this:
export WEBSITE_1_CLOUDFLARE_API_TOKEN="aaaaaaaaaabbbbbbbbbbccccccccccdddddddddd"
(This will be the same for all sites on the same server)
- To get your ipv4 id & ipv6 id run the following command in bash (replace the api token and zone id with yours)from the server:
```
curl --request GET --url https://api.cloudflare.com/client/v4/zones/aaaaaaaaaabbbbbbbbbbcccccccccc12/dns_records --header 'Authorization: Bearer aaaaaaaaaabbbbbbbbbbccccccccccdddddddddd' --header 'Content-Type: application/json'
```
- Copy the result, and paste it in a json formatter of your choice, for easier readability. I used: https://jsonformatter.curiousconcept.com/ and run "Process"
(if you can't pinpoint them, paste it to an LLM/Chat gpt of your choice and ask what your ipv4 record id and ipv6 record id are)
- Grab the id of type: A (this is ipv4 id) and the id of type: AAAA (this is ipv6 id) and add them in your .env like so:
export WEBSITE_1_CLOUDFLARE_IPV4_RECORD_ID="01234567890123456789012356789012"
export WEBSITE_1_CLOUDFLARE_IPV6_RECORD_ID="01234567890123456789012356789012"
- finally copy the domain inside the .env which should be the exact same with what you have on cloudflare DNS
(select on cloudflare your site => DNS => records => copy the "name" from the Type:A for ipv4 and Type:AAAA for ipv6)


-----===== Tutorial End =====-----

Setup
Copy the .env.example file to a new file named .env in the same directory:
```
cp .env.example .env
```
Open the .env file and replace the placeholder values with your actual data. Each website you want to update should have its own set of environment variables. Here's what each variable represents:
WEBSITE_X_DOMAIN: The domain of your website.
WEBSITE_X_CLOUDFLARE_API_TOKEN: Your Cloudflare API token.
WEBSITE_X_CLOUDFLARE_ZONE_ID: The Zone ID of your domain on Cloudflare.
WEBSITE_X_CLOUDFLARE_IPV4_RECORD_ID: The Record ID of the A record (IPv4) of your domain on Cloudflare.
WEBSITE_X_CLOUDFLARE_IPV6_RECORD_ID: The Record ID of the AAAA record (IPv6) of your domain on Cloudflare.
You can find these values in your Cloudflare dashboard. Replace X with a unique identifier for each website (e.g., WEBSITE_1, WEBSITE_2, etc.).

Open the UpdateDNS.sh script and add your websites to the websites array, using the same identifiers you used in the .env file:
```
websites=("WEBSITE_1" "WEBSITE_2")
```
Running the Script
To run the script, make the scripts executable first:
```
chmod +x DNSCheck.sh
chmod +x UpdateDNS.sh
```
Then use this command:
./DNSCheck.sh
```

This will check your current public IP addresses and update your DNS records on Cloudflare if they have changed. The script logs all updates and errors to dns_update.log.

Note
The DNSCheck.sh script is a helper script that checks if the current public IP addresses match the ones stored in ipv4.txt and ipv6.txt. If they don't match, it runs the UpdateDNS.sh script to update the DNS records. You can set up a cron job to run this script at regular intervals.
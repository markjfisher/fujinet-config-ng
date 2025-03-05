#!/bin/bash

# Base URL
BASE_URL="https://damieng.com"

# Get the main page content
main_page=$(curl -s "https://damieng.com/typography/zx-origins/")

# Extract all font links using grep and sed
# Look for href patterns that match /typography/zx-origins/something/
font_links=$(echo "$main_page" | grep -o 'href="/typography/zx-origins/[^"]*"' | sed 's/href="\(.*\)"/\1/')

# Process each font link
while IFS= read -r link; do
    # Skip empty lines
    [ -z "$link" ] && continue
    
    # Get the font page content
    font_page=$(curl -s "${BASE_URL}${link}")
    
    # Extract the download link using grep and sed
    # Look for .zip files in the dl.damieng.com domain
    download_url=$(echo "$font_page" | grep -o 'https://dl\.damieng\.com/fonts/zx-origins/[^"]*\.zip' | head -n 1)
    
    if [ ! -z "$download_url" ]; then
        echo "Downloading: $download_url"
        # Extract filename from URL and replace spaces with %20
        encoded_url=$(echo "$download_url" | sed 's/ /%20/g')
        filename=$(basename "$download_url")
        # Download the zip file with force overwrite
        curl -L -f -o "$filename" "$encoded_url"
        # Wait a bit between downloads to be nice to the server
        sleep 1
    else
        echo "No download link found for: $link"
    fi
done <<< "$font_links"
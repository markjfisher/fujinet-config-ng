#!/bin/bash

# Process each zip file in the current directory
for zipfile in *.zip; do
    # Skip if no zip files found
    [ -e "$zipfile" ] || continue

    # Get the base name without .zip extension
    basename="${zipfile%.zip}"

    # Convert the name to lowercase and replace spaces with underscores
    newname=$(echo "$basename" | tr '[:upper:]' '[:lower:]' | tr ' ' '_')

    echo "Processing: $zipfile"

    # Extract the .asm file from the Source directory
    unzip -j -p "$zipfile" "Source/$basename.6502.asm" > "${newname}.asm" 2>/dev/null

    if [ $? -eq 0 ]; then
        echo "Extracted: ${newname}.asm"
    else
        echo "Failed to extract from: $zipfile"
    fi
done
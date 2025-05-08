#!/bin/bash

# Base file path
basefile="cng-font-plain.asm"

mkdir -p out

# Process each .asm file in the asm directory
for fontfile in asm/*.asm; do
    # Skip if no files found
    [ -e "$fontfile" ] || continue

    # Get the base name for output file
    basename=$(basename "$fontfile" .asm)
    outfile="combined/${basename}_combined.asm"

    echo "Processing: $fontfile"

    # Create the combined file
    {
        # Skip first line (comment) and take next 64 lines from font file
        tail -n +2 "$fontfile" | head -n 64

        # Skip first 64 lines and take next 32 lines from base file
        tail -n +65 "$basefile" | head -n 32

        # Take next 27 lines from font file (starting at line 66)
        tail -n +66 "$fontfile" | head -n 27

        # Take last 5 lines from base file
        tail -n 5 "$basefile"
        echo ""
    } > "$outfile"

    # Verify line count
    lines=$(wc -l < "$outfile")
    if [ "$lines" -eq 128 ]; then
        echo "Successfully created $outfile with $lines lines"
    else
        echo "Error: $outfile has $lines lines (expected 128)"
    fi
done

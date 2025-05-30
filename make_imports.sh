#!/bin/bash

# Run make and capture errors, then process them to group by file and sort imports
make release 2>&1 | grep 'Error: Symbol .* is undefined' | awk '
    BEGIN { FS=":" }
    {
        file=$1
        split($0, parts, "'\''")
        symbol=parts[2]
        if (file != prev_file && prev_file != "") {
            print ""  # Add blank line between files
        }
        if (file != prev_file) {
            print "; " file
        }
        imports[file] = imports[file] ".import     " symbol "\n"
        prev_file=file
    }
    END {
        if (prev_file != "") {
            n = split(imports[prev_file], arr, "\n")
            asort(arr)
            for (i=1; i<=n; i++) {
                if (arr[i] != "") print arr[i]
            }
        }
    }
'

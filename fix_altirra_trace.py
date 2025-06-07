#!/usr/bin/env python3

def fix_altirra_trace(input_file, output_file):
    """
    Fix Altirra trace output where each line contains all previous content plus new content.
    
    Args:
        input_file: Path to the buggy trace file
        output_file: Path to write the corrected trace
    """
    current_line_length = 0
    
    with open(input_file, 'r', encoding='utf-8', errors='ignore') as infile, \
         open(output_file, 'w', encoding='utf-8') as outfile:
        
        for line_num, line in enumerate(infile, 1):
            line = line.rstrip('\n\r')  # Remove newline characters
            new_length = len(line)
            
            # Remove the first current_line_length characters
            if current_line_length <= new_length:
                new_content = line[current_line_length:]
            else:
                # This shouldn't happen in normal cases, but handle it gracefully
                print(f"Warning: Line {line_num} shorter than expected")
                new_content = line
            
            # Write the new content
            outfile.write(new_content + '\n')
            
            # Update current line length for next iteration
            current_line_length = new_length
            
            # Progress indicator for large files
            if line_num % 10000 == 0:
                print(f"Processed {line_num} lines...")

if __name__ == "__main__":
    import sys
    
    if len(sys.argv) != 3:
        print("Usage: python fix_altirra_trace.py input_file output_file")
        print("Example: python fix_altirra_trace.py trace_buggy.txt trace_fixed.txt")
        sys.exit(1)
    
    input_file = sys.argv[1]
    output_file = sys.argv[2]
    
    try:
        fix_altirra_trace(input_file, output_file)
        print(f"Successfully fixed trace and wrote to {output_file}")
    except FileNotFoundError:
        print(f"Error: Could not find input file '{input_file}'")
        sys.exit(1)
    except Exception as e:
        print(f"Error: {e}")
        sys.exit(1) 
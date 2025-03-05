#!/usr/bin/env python3
import os
import glob

COMMENTS = [
    "space",    "!",        "\"",       "#",        "$",        "%",        "&",        "'",        "(",        ")",        "*",        "+",        "comma",    "-",        ".",        "/",
    "0",        "1",        "2",        "3",        "4",        "5",        "6",        "7",        "8",        "9",        ":",        ";",        "<",        "=",        ">",        "?",
    "@",        "A",        "B",        "C",        "D",        "E",        "F",        "G",        "H",        "I",        "J",        "K",        "L",        "M",        "N",        "O",
    "P",        "Q",        "R",        "S",        "T",        "U",        "V",        "W",        "X",        "Y",        "Z",        "[",        "\\",       "]",        "^",        "_",
    "dir",      "open left","open right","LR square","close-open","UR square","UL corner","UR corner","LL corner","LR corner","UL long",  "UR long",  "LL long",  "wifi 2",   "wifi 3",   "LR long",
    "select arrow","UL square","horiz",    "h/v +",    "close-open ang","half horiz","wifi 1",   "L sep",    "R sep",    "half vert","LR corner","Esc",      "Up",       "Down",     "Left",     "Right",
    "ball",     "a",        "b",        "c",        "d",        "e",        "f",        "g",        "h",        "i",        "j",        "k",        "l",        "m",        "n",        "o",
    "p",        "q",        "r",        "s",        "t",        "u",        "v",        "w",        "x",        "y",        "z",        "{",        "|",        "}",        "L vert triangle", "R vert triangle"
]

def parse_byte(byte_str):
    byte_str = byte_str.strip()
    if byte_str.startswith('$'):
        # Already hex, just parse it
        return int(byte_str[1:], 16)
    else:
        # Decimal, convert to int
        return int(byte_str)

def format_line(line, line_number):
    # Split the line into parts
    parts = line.strip().split(';', 1)
    data_part = parts[0].strip()
    
    # Skip if not a byte line
    if ".byte" not in data_part:
        return line.strip()
    
    # Extract and convert the byte values
    bytes_str = data_part.replace(".byte", "").strip()
    bytes_list = [parse_byte(x.strip()) for x in bytes_str.split(',')]
    
    # Format bytes in hex
    hex_bytes = [f"${x:02X}" for x in bytes_list]
    
    # Construct the new line with comment from our array
    new_line = "    .byte " + ", ".join(hex_bytes)
    new_line += f" ; {COMMENTS[line_number]}"
    
    return new_line

def process_file(input_filepath):
    # Create pretty directory if it doesn't exist
    pretty_dir = os.path.join('font_data', 'pretty')
    os.makedirs(pretty_dir, exist_ok=True)
    
    # Get the font name (remove _combined.asm)
    filename = os.path.basename(input_filepath)
    font_name = filename.replace("_combined.asm", "")
    
    # Create new output filename
    output_filename = f"fd_{font_name}.asm"
    output_filepath = os.path.join(pretty_dir, output_filename)
    
    with open(input_filepath, 'r') as f:
        lines = f.readlines()
    
    # Start with the font header
    formatted_lines = [f"; FONT: {font_name}"]
    
    # Process the byte lines
    for i, line in enumerate(lines):
        formatted_line = format_line(line, i)
        formatted_lines.append(formatted_line)
    
    # Write to the new file in pretty directory
    with open(output_filepath, 'w') as f:
        f.write('\n'.join(formatted_lines) + '\n')

def main():
    # Process all .asm files in font_data/combined/
    combined_path = os.path.join('font_data', 'combined', '*.asm')
    for filepath in glob.glob(combined_path):
        print(f"Processing {filepath}")
        process_file(filepath)

if __name__ == "__main__":
    main()

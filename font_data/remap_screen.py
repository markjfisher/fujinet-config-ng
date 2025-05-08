#!/usr/bin/env python3
from collections import Counter

def is_priority_range(value):
    # Check if value (after masking high bit) is in priority ranges
    value = value & 0x7F
    return value >= 0x20

def convert_from_screen_code(value):
    # Convert from screen code to internal value
    value = value & 0x7F  # Mask off high bit
    if 0x20 <= value <= 0x5F:
        return value - 0x20
    elif 0x00 <= value <= 0x1F:
        return value + 0x40
    else:  # 0x60 to 0x7F
        return value

def remap_screen_codes(input_file):
    # Read the file and convert hex strings to bytes
    bytes_data = []
    with open(input_file, 'r') as f:
        for line in f:
            # Split the line by spaces and convert each hex value to int
            bytes_data.extend([int(x, 16) for x in line.strip().split()])

    # Count frequencies of masked values
    masked_values = [b & 0x7F for b in bytes_data]
    freq_counter = Counter(masked_values)

    # Create a mapping of unique values (masking off high bit)
    unique_values = set(masked_values)

    # Split into priority and non-priority values
    priority_values = sorted([v for v in unique_values if is_priority_range(v)])
    other_values = sorted([v for v in unique_values if not is_priority_range(v)])

    # Create mapping, starting with priority values
    value_map = {}
    next_value = 0

    # Map priority values first
    for old in priority_values:
        value_map[old] = next_value
        next_value += 1

    # Then map other values
    for old in other_values:
        value_map[old] = next_value
        next_value += 1

    # Create the remapped data, preserving the high bit
    remapped_data = []
    for b in bytes_data:
        high_bit = b & 0x80  # Save the high bit
        masked = b & 0x7F    # Mask off high bit
        mapped = value_map[masked]  # Map the value
        remapped = mapped | high_bit  # Restore high bit
        remapped_data.append(remapped)

    # Print statistics
    print(f"Original unique values (ignoring high bit): {len(unique_values)}")
    print(f"Priority values (>= 0x20): {len(priority_values)}")
    print(f"Other values (< 0x20): {len(other_values)}")

    print("\nMapping table with frequencies (showing unmasked values):")
    print("Priority mappings:")
    for old in priority_values:
        internal_code = convert_from_screen_code(old)
        print(f"0x{internal_code:02X} (0x{old:02X}) -> 0x{value_map[old]:02X} (freq: {freq_counter[old]:3d})")
    print("\nOther mappings:")
    for old in other_values:
        internal_code = convert_from_screen_code(old)
        print(f"0x{internal_code:02X} (0x{old:02X}) -> 0x{value_map[old]:02X} (freq: {freq_counter[old]:3d})")

    # Print the remapped data in the same format as input
    print("\nRemapped data:")
    for i in range(0, len(remapped_data), 40):
        line = remapped_data[i:i+40]
        print(' '.join(f'{x:02X}' for x in line))

    return value_map, remapped_data

if __name__ == "__main__":
    input_file = "screen-text.txt"
    value_map, remapped_data = remap_screen_codes(input_file)
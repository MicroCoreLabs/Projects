#!/usr/bin/env python3

import sys

def read_bytes(filename):
    data = []
    with open(filename, 'r') as f:
        for line in f:
            parts = line.strip().split()
            for p in parts:
                try:
                    data.append(int(p, 16))
                except:
                    pass
    return data

def color_byte(b1, b2):
    if b1 == b2:
        return f"\033[92m{b1:02X}\033[0m"  # green
    else:
        return f"\033[91m{b2:02X}\033[0m"  # red (show Teensy value)

def main():
    if len(sys.argv) != 3:
        print("Usage: compare_bytes.py <rom_file_dump> <teensy_dump>")
        sys.exit(1)

    ref = read_bytes(sys.argv[1])
    test = read_bytes(sys.argv[2])

    length = min(len(ref), len(test))

    BYTES_PER_LINE = 32

    for i in range(0, length, BYTES_PER_LINE):
        line_ref = ref[i:i+BYTES_PER_LINE]
        line_test = test[i:i+BYTES_PER_LINE]

        print(f"{i:04X}: ", end="")

        for j in range(len(line_test)):
            print(color_byte(line_ref[j], line_test[j]), end=" ")

        print()

if __name__ == "__main__":
    main()
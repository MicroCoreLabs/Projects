segment = None
with open("bootrom.asm", "r") as f:
    for line in f:
        if line.startswith('%define ROM_SEGMENT'):
            segment = int(line[19:].strip('() \n'), 16)
            break

with open("bootrom", "rb") as f:
    bitstream = bytearray(f.read())

# https://stackoverflow.com/questions/53808694/how-do-i-format-a-python-list-as-an-initialized-c-array
def to_c_array(values, ctype="float", name="table", formatter=str, colcount=8):
    # apply formatting to each element
    values = [formatter(v) for v in values]

    # split into rows with up to `colcount` elements per row
    rows = [values[i:i+colcount] for i in range(0, len(values), colcount)]

    # separate elements with commas, separate rows with newlines
    body = ',\n    '.join([', '.join(r) for r in rows])

    # assemble components into the complete string
    return '{} {}[] = {{\n    {}}};'.format(ctype, name, body)

with open("../../Code/XTMax/bootrom.h", "w") as f:
    f.write("#define BOOTROM_ADDR {}\n".format(hex(segment << 4)))
    f.write(to_c_array(bitstream, ctype="unsigned char", name="BOOTROM", colcount=16))

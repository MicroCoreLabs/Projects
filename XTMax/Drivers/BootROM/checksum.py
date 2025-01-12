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

with open("bootrom", "rb") as f:
    b = bytearray(f.read())
# compute the checksum and store a byte to
b[-1] = 256 - sum(b[0:-1]) & 0xff
with open("bootrom", "wb") as f:
    f.write(b)
with open("../../Code/XTMax/bootrom.h", "w") as f:
    f.write("#define BOOTROM_ADDR 0xCE000\n")
    f.write(to_c_array(b, ctype="unsigned char", name="BOOTROM", colcount=16))

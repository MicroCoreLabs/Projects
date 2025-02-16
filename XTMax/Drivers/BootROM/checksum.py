with open("bootrom", "rb") as f:
    b = bytearray(f.read())
# compute the checksum and store a byte to
b[-1] = 256 - sum(b[0:-1]) & 0xff
with open("bootrom", "wb") as f:
    f.write(b)

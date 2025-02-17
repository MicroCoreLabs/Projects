..\Driver_Build_Tools\NASM\nasm.exe -f bin -o bootrom.com -DAS_COM_PROGRAM .\bootrom.asm
..\Driver_Build_Tools\NASM\nasm.exe -f bin -o bootrom .\bootrom.asm & python checksum.py & python generate_header.py
..\Driver_Build_Tools\NASM\nasm.exe -f bin -o xtmdiags.com .\diags.asm

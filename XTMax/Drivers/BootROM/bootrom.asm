bits 16

%ifndef AS_COM
;
; BIOS will look for the AA55 signature between C8000-DFFFF in 2KB increments.
; We choose an address in that range.
;
org 0xce000
dw 0AA55h
db 4    ; times 512 bytes

%else
;
; Building as a COM file for testing.
;
org 0x100

%endif

entry:
%ifndef AS_COM
    mov ax, 0xc000
    mov ds, ax
    mov es, ax
%endif

    mov si, welcome
    call print_string


%ifndef AS_COM
    retf
%else
;
; DOS exit program.
;
    mov ah, 0x4c
    xor al, al
    int 0x21
%endif

;
; Utilities
;

print_string:
    push bx
    xor bx,bx
.loop:
    lodsb
    or al, al
    jz .done
    mov ah, 0x0E
    int 0x10
    jmp .loop
.done:
    pop bx
    ret

;
; Strings
;

welcome db 'BootROM for XTMax v0.1', 0x0D, 0x0A, 0

%ifndef AS_COM
;
; Pad to 2KB. We will try to keep our ROM under that size.
;
times 2047-($-$$) db 0
db 0    ; will be used to complete the checksum.
%endif
;
; Display a string.
; in:  AX = string pointer
; out: AX = <TRASH>
;
print_string:
    pushf
    push ds
    push bx
    push si
    mov si, ax
    mov ax, cs
    mov ds, ax
    mov ah, 0xe
    xor bx, bx
    cld
.loop:
    lodsb
    or al, al
    jz .done
    int 0x10
    jmp .loop
.done:
    pop si
    pop bx
    pop ds
    popf
    ret

;
; Display a 16-bit value in hex.
; in:  AX = value
; out: AX = <TRASH>
;
print_hex:
    pushf
    push ds
    push bx
    push cx
    push dx
    push si
    mov dx, ax
    mov ax, cs
    mov ds, ax
    xor bx, bx
    cld
.nibble1:
    mov si, dx
    mov cl, 12
    shr si, cl
    and si, 0xf
    mov al, [hex_map+si]
    mov ah, 0xe
    int 0x10
.nibble2:
    mov si, dx
    mov cl, 8
    shr si, cl
    and si, 0xf
    mov al, [hex_map+si]
    mov ah, 0xe
    int 0x10
.nibble3:
    mov si, dx
    mov cl, 4
    shr si, cl
    and si, 0xf
    mov al, [hex_map+si]
    mov ah, 0xe
    int 0x10
.nibble4:
    mov si, dx
    and si, 0xf
    mov al, [hex_map+si]
    mov ah, 0xe
    int 0x10
    pop si
    pop dx
    pop cx
    pop bx
    pop ds
    popf
    ret

hex_map db '0123456789ABCDEF'

%if %isdef(EXTRA_DEBUG) || %isdef(AS_COM_PROGRAM)
dump_regs:
    push ax
    mov ax, registers_msg
    call print_string
    pop ax
    push ax
    call print_hex
    mov ax, space
    call print_string
    mov ax, bx
    call print_hex
    mov ax, space
    call print_string
    mov ax, cx
    call print_hex
    mov ax, space
    call print_string
    mov ax, dx
    call print_hex
    mov ax, space
    call print_string
    mov ax, ds
    call print_hex
    mov ax, space
    call print_string
    mov ax, si
    call print_hex
    mov ax, space
    call print_string
    mov ax, es
    call print_hex
    mov ax, space
    call print_string
    mov ax, di
    call print_hex
    mov ax, space
    call print_string
    mov ax, bp
    call print_hex
    mov ax, space
    call print_string
    pushf
    pop ax
    call print_hex
    mov ax, space
    call print_string
    mov ax, newline
    call print_string
    pop ax
    ret

registers_msg   db ' AX   BX   CX   DX   DS   SI   ES   DI   BP  FLAGS', 0xD, 0xA, 0
%endif

colon           db ':', 0
space           db ' ', 0
newline         db 0xD, 0xA, 0

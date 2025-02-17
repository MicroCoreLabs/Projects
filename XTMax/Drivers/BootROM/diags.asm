org 0x100

;
; The base I/O port for the XTMAX SD Card.
;
%define XTMAX_IO_BASE       (0x280)
%define REG_SCRATCH_0       (XTMAX_IO_BASE+2)   ; fixed disk id
%define REG_SCRATCH_1       (XTMAX_IO_BASE+3)   ; BIOS INT13h segment
%define REG_SCRATCH_2       (XTMAX_IO_BASE+4)   ; BIOS INT13h segment
%define REG_SCRATCH_3       (XTMAX_IO_BASE+5)   ; BIOS INT13h offset
%define REG_SCRATCH_4       (XTMAX_IO_BASE+6)   ; BIOS INT13h offset

entry:
    mov ax, welcome_msg
    call print_string

;
; Inspect the INT13h and the HDNUM
;
    mov ax, current_13h_msg
    call print_string
    xor ax, ax              ; INT vector segment
    mov es, ax
    mov ax, es:[0x13*4+2]
    call print_hex
    mov ax, colon
    call print_string
    mov ax, es:[0x13*4]
    call print_hex
    mov ax, newline
    call print_string

    mov ax, saved_13h_msg
    call print_string
    mov dx, REG_SCRATCH_1
    in ax, dx
    call print_hex
    mov ax, colon
    call print_string
    mov dx, REG_SCRATCH_3
    in ax, dx
    call print_hex
    mov ax, newline
    call print_string

    mov ax, hdnum_msg
    call print_string
    mov ax, 0x40            ; BIOS data area
    mov es, ax
    mov al, es:[0x75]       ; HDNUM
    call print_hex_byte
    mov ax, newline
    call print_string

    mov ax, disk_id_msg
    call print_string
    mov dx, REG_SCRATCH_0
    in al, dx
    xor ah, ah
    call print_hex_byte
    mov ax, newline
    call print_string
    mov ax, newline
    call print_string

;
; Inspect the Fixed Disk Parameters Tables
;
    mov ax, disk80_fdpt_msg
    call print_string
    xor ax, ax              ; INT vector segment
    mov es, ax
    mov ax, es:[0x41*4+2]
    mov bx, ax
    call print_hex
    mov ax, colon
    call print_string
    mov ax, es:[0x41*4]
    mov si, ax
    call print_hex
    mov ax, newline
    call print_string

    mov ax, space
    call print_string
    mov ax, space
    call print_string
    mov es, bx
    mov cx, 18
.dump_disk80_fdpt:
    mov al, es:[si]
    inc si
    call print_hex_byte
    mov ax, space
    call print_string
    loop .dump_disk80_fdpt
    mov ax, newline
    call print_string

    mov ax, disk81_fdpt_msg
    call print_string
    xor ax, ax              ; INT vector segment
    mov es, ax
    mov ax, es:[0x46*4+2]
    mov bx, ax
    call print_hex
    mov ax, colon
    call print_string
    mov ax, es:[0x46*4]
    mov si, ax
    call print_hex
    mov ax, newline
    call print_string

    mov ax, space
    call print_string
    mov ax, space
    call print_string
    mov es, bx
    mov cx, 18
.dump_disk81_fdpt:
    mov al, es:[si]
    inc si
    call print_hex_byte
    mov ax, space
    call print_string
    loop .dump_disk81_fdpt
    mov ax, newline
    call print_string
    mov ax, newline
    call print_string

;
; Invoke Read Parameters on the fixed disks.
;
    mov ax, parm_disk80_msg
    call print_string
    xor ax, ax
    xor bx, bx
    xor cx, cx
    xor dx, dx
    xor si, si
    xor di, di
    xor bp, bp
    mov dl, 0x80
    mov ah, 0x08
    call dump_regs
    int 0x13
    call dump_regs
    mov ax, newline

    call print_string
    mov ax, parm_disk81_msg
    call print_string
    xor ax, ax
    xor bx, bx
    xor cx, cx
    xor dx, dx
    xor si, si
    xor di, di
    xor bp, bp
    mov dl, 0x81
    mov ah, 0x08
    call dump_regs
    int 0x13
    call dump_regs

    ; wait for kbd
    mov ah, 0x01
    int 0x21
    mov ax, newline
    call print_string

;
; Read First Sector on the fixed disks.
;
    xor ax, ax
    mov cx, 256
    mov di, buf_read
    rep stosw
    mov ax, read_disk80_msg
    call print_string
    xor ax, ax
    xor bx, bx
    xor cx, cx
    xor dx, dx
    xor si, si
    xor di, di
    xor bp, bp
    mov dl, 0x80
    mov ah, 0x02
    mov bx, ds
    mov es, bx
    mov bx, buf_read
    mov ch, 0
    mov cl, 1
    mov dh, 0
    mov al, 1
    call dump_regs
    int 0x13
    call dump_regs
    mov ax, newline
    call print_string

    mov cx, 16
    mov si, buf_read
.dump_disk80_sector_1:
    lodsb
    call print_hex_byte
    mov ax, space
    call print_string
    loop .dump_disk80_sector_1
    mov ax, newline
    call print_string
    mov ax, dotdotdot
    call print_string
    mov cx, 16
    add si, 512-16-16
.dump_disk80_sector_2:
    lodsb
    call print_hex_byte
    mov ax, space
    call print_string
    loop .dump_disk80_sector_2
    mov ax, newline
    call print_string    
    mov ax, newline
    call print_string

    xor ax, ax
    mov cx, 256
    mov di, buf_read
    rep stosw
    mov ax, read_disk81_msg
    call print_string
    xor ax, ax
    xor bx, bx
    xor cx, cx
    xor dx, dx
    xor si, si
    xor di, di
    xor bp, bp
    mov dl, 0x81
    mov ah, 0x02
    mov bx, ds
    mov es, bx
    mov bx, buf_read
    mov ch, 0
    mov cl, 1
    mov dh, 0
    mov al, 1
    call dump_regs
    int 0x13
    call dump_regs
    mov ax, newline
    call print_string

    mov cx, 16
    mov si, buf_read
.dump_disk81_sector_1:
    lodsb
    call print_hex_byte
    mov ax, space
    call print_string
    loop .dump_disk81_sector_1
    mov ax, newline
    call print_string
    mov ax, dotdotdot
    call print_string
    mov cx, 16
    add si, 512-16-16
.dump_disk81_sector_2:
    lodsb
    call print_hex_byte
    mov ax, space
    call print_string
    loop .dump_disk81_sector_2
    mov ax, newline
    call print_string    

;
; DOS exit program.
;
    mov ah, 0x4c
    xor al, al
    int 0x21

buf_read times 512 db 0

;
; General utilities
;

%define AS_COM_PROGRAM
%include "utils.inc"

;
; Display an 8-bit value in hex.
; in:  AL = value
; out: AX = <TRASH>
;
print_hex_byte:
    pushf
    push ds
    push bx
    push cx
    push dx
    push si
    mov dl, al
    xor ah, ah
%ifndef AS_COM_PROGRAM
    mov ax, ROM_SEGMENT
    mov ds, ax
%endif
    xor bx, bx
    cld
.nibble1:
    mov si, dx
    mov cl, 4
    shr si, cl
    and si, 0xf
    mov al, [hex_map+si]
    mov ah, 0xe
    int 0x10
.nibble2:
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

;
; Strings
;

welcome_msg     db 'XTMax BootROM diagnostics', 0xD, 0xA, 0xD, 0xA, 0
current_13h_msg db 'Current INT13h Vector = ', 0
saved_13h_msg   db 'Saved INT13h Vector   = ', 0
hdnum_msg       db 'BIOS Data Area HDNUM  = ', 0
disk_id_msg     db 'XTMax Fixed Disk ID   = ', 0
disk80_fdpt_msg db 'Fixed Disk 80h Parameters Table = ', 0
disk81_fdpt_msg db 'Fixed Disk 81h Parameters Table = ', 0
parm_disk80_msg db 'Call Fixed Disk 80h Read Parameters', 0xD, 0xA, 0
parm_disk81_msg db 'Call Fixed Disk 81h Read Parameters', 0xD, 0xA, 0
read_disk80_msg db 'Read First Sector on Fixed Disk 80h', 0xD, 0xA, 0
read_disk81_msg db 'Read First Sector on Fixed Disk 81h', 0xD, 0xA, 0
dotdotdot       db '[...]', 0xD, 0xA, 0
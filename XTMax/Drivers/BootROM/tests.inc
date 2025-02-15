;
; This is test code invoked when building with AS_COM
;

;%define REAL_INT13
%define DUMP_REGS


    xor ax, ax
    lahf
    sti
    mov ax, 0x1122
    mov bx, 0x3344
    mov cx, 0x5566
    mov dx, 0x7788
    mov si, 0x99aa
    mov di, 0xbbcc
    mov bp, 0xddee

    mov dl, 0x80
    mov ah, 0x08

    ;mov bx, buf_write
    ;mov ch, 0
    ;mov cl, 1
    ;mov dh, 0
    ;mov al, 1

    call do_int13h

    mov dl, 0x80
    mov ah, 0x02

    mov bx, ds
    mov es, bx
    mov bx, buf_read
    mov ch, 0
    mov cl, 1
    mov dh, 0
    mov al, 1

    call do_int13h

%if 1
    mov cx, 256
    mov si, buf_read
.dump:
    lodsw
    call print_hex
    mov ax, space
    call print_string
    loop .dump
    mov ax, newline
    call print_string

    ; wait for kbd
    mov ah, 0x01
    int 0x21
%endif

    mov ah, 0x01
    call do_int13h
    mov ah, 0x01
    call do_int13h

    ;mov ax, newline
    ;call print_string
    ;mov ch, 255
    ;mov cl, 255
    ;mov dh, NUM_HEADS-1
    ;call compute_lba
    ;push ax
    ;mov ax, bx
    ;call print_hex
    ;pop ax
    ;call print_hex
    ;mov ax, newline
    ;call print_string

    jmp end

do_int13h:
%ifdef DUMP_REGS
    call dump_regs
%endif

    pushf               ; save flags (to compare)
%ifndef REAL_INT13
    ; simulate vector call
    pushf
    push cs
    call int13h_entry
%else
    int 0x13
%endif
    pushf               ; save flags (to compare)
    push ax
    jnc .success
.error:
    mov ax, test_failed_msg
    call print_string
    jmp .finish
.success:
    mov ax, test_success_msg
    call print_string
.finish:
    pop ax
    push ax
    mov al, ah
    xor ah, ah
    call print_hex
    mov ax, newline
    call print_string
    pop ax

    ; dump registers
%ifdef DUMP_REGS
    popf
    pushf
    call dump_regs
    pop ax
    call print_hex
    mov ax, colon
    call print_string
    pop ax
    call print_hex
    mov ax, newline
    call print_string
%else
    popf
    popf
%endif

    ; wait for kbd
    mov ah, 0x01
    int 0x21
    ret

;
; A fake INT13h handler to test redirection of floppy service
;
fake_int13h_entry:
    push ax
    mov ax, fake_handler_msg
    call print_string
    pop ax
    push ax
    mov al, ah
    xor ah, ah
    call print_hex
    mov ax, drive_msg
    call print_string
    mov ax, dx
    xor ah, ah
    call print_hex
    mov ax, newline
    call print_string
    pop ax
    mov ah, 0xaa
    push bp
    mov bp, sp
    or byte [bp+6], 0x1     ; set carry of flags for iret
    pop bp
    iret

buf_write           db 1, 2, 3, 4, 5, 6, 7, 8
                    times 496 db 0
                    db 248, 249, 250, 251, 252, 253, 254, 255
                    times 512 db 0
buf_read            times 1024 db 0

fake_handler_msg    db 'BIOS INT13h Function ', 0
drive_msg           db ' Drive ', 0
test_success_msg    db 'Call succeeded ', 0
test_failed_msg     db 'Call failed ', 0

end:

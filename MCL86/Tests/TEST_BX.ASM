; Tests for opcode range 0xB0-0xBF
; ---------------------------------
                   
; 0xB0 - MOV AL,IMM8
; 0xB1 - MOV CL,IMM8
; 0xB2 - MOV DL,IMM8
; 0xB3 - MOV BL,IMM8
; 0xB4 - MOV AH,IMM8
; 0xB5 - MOV CH,IMM8
; 0xB6 - MOV DH,IMM8
; 0xB7 - MOV BH,IMM8
; ############################################################

TEST_B0_0:
        mov al,0A0
        mov cl,0C0
        mov dl,0D0
        mov bl,0B0
        mov ah,0A1
        mov ch,0C1
        mov dh,0D1
        mov bh,0B1

        cmp ax,0A1A0
        jne FAIL_B0_0

        cmp cx,0C1C0
        jne FAIL_B0_0

        cmp dx,0D1D0
        jne FAIL_B0_0

        cmp bx,0B1B0
        jne FAIL_B0_0
        jmp TEST_B8_0


FAIL_B0_0:
        mov dx,00030    ; Print a 0
        mov ax,00202
        int 021


; 0xB8 - MOV AX,IMM16
; 0xB9 - MOV CX,IMM16
; 0xBA - MOV DX,IMM16
; 0xBC - MOV BX,IMM16
; 0xBC - MOV SP,IMM16
; 0xBD - MOV BP,IMM16
; 0xBE - MOV SI,IMM16
; 0xBF - MOV DI,IMM16
; ############################################################

TEST_B8_0:
        mov ax,01234
        cmp ax,01234
        jne FAIL_B8_0

        mov cx,05678
        cmp cx,05678
        jne FAIL_B8_0

        mov dx,07890
        cmp dx,07890
        jne FAIL_B8_0

        mov bx,05A5B
        cmp bx,05A5B
        jne FAIL_B8_0

        mov sp,0BEEF
        cmp sp,0BEEF
        jne FAIL_B8_0

        mov bp,0DEAD
        cmp bp,0DEAD
        jne FAIL_B8_0

        mov si,02468
        cmp si,02468
        jne FAIL_B8_0

        mov di,01357
        cmp di,01357
        jne FAIL_B8_0
        jmp Z_END

FAIL_B8_0:
        mov dx,00038    ; Print a B
        mov ax,00208
        int 021



; xxxxxxxxxxxxxxxxxxxxxxx
; End
; xxxxxxxxxxxxxxxxxxxxxxx
Z_END:
        mov ax,00000    ; DOS Command=Exit
        int 021




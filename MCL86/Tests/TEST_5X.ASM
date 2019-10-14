; Tests for opcode range 0x50-0x5F
; ---------------------------------
                   
; 0x50 - PUSH AX
; 0x51 - PUSH CX
; 0x52 - PUSH DX
; 0x53 - PUSH BX
; 0x54 - PUSH SP
; 0x55 - PUSH BP
; 0x56 - PUSH SI
; 0x57 - PUSH DI
; ############################################################

TEST_50_0:

        mov ax,0AAAA
        mov cx,0CCCC
        mov dx,0DDDD
        mov bx,0BBBB
        mov bp,02222
        mov si,03333
        mov di,04444

        push ax
        push cx
        push dx
        push bx
        push bp
        push si
        push di

        mov bx,sp
        cmp word[bx],04444
        jne FAIL_50_0

        cmp word[bx+02],03333
        jne FAIL_50_0

        cmp word[bx+04],02222
        jne FAIL_50_0

        cmp word[bx+06],0BBBB
        jne FAIL_50_0

        cmp word[bx+08],0DDDD
        jne FAIL_50_0

        cmp word[bx+0A],0CCCC
        jne FAIL_50_0

        cmp word[bx+0C],0AAAA
        jne FAIL_50_0

        mov dx,sp       ; Test PUSH SP
        sub dx,00002
        push sp
        mov bx,sp
        cmp word[bx],dx
        jne FAIL_50_0
        jmp TEST_58_0



FAIL_50_0:
        mov dx,00030    ; Print a 0
        mov ax,00202
        int 021


; 0x58 - POP AX
; 0x59 - POP CX
; 0x5A - POP DX
; 0x5B - POP BX
; 0x5C - POP SP
; 0x5D - POP BP
; 0x5E - POP SI
; 0x5F - POP DI
; ############################################################

TEST_58_0:
        mov  ax,01111
        push ax
        mov  ax,02222
        push ax
        mov  ax,03333
        push ax
        mov  ax,04444
        push ax
        mov  ax,05555
        push ax
        mov  ax,06666
        push ax
        mov  ax,07777
        push ax

        pop ax
        cmp ax,07777
        jne FAIL_58_0

        pop cx
        cmp cx,06666
        jne FAIL_58_0

        pop dx
        cmp dx,05555
        jne FAIL_58_0

        pop bx
        cmp bx,04444
        jne FAIL_58_0

        pop bp
        cmp bp,03333
        jne FAIL_58_0

        pop si
        cmp si,02222
        jne FAIL_58_0

        pop di
        cmp di,01111
        jne FAIL_58_0

        mov ax,01234
        push ax
        pop sp
        mov bx,sp
        cmp bx,01234
        jne FAIL_58_0

        jmp Z_END


FAIL_58_0:
        mov dx,00038    ; Print a 8
        mov ax,00202
        int 021


; xxxxxxxxxxxxxxxxxxxxxxx
; End
; xxxxxxxxxxxxxxxxxxxxxxx
Z_END:
        mov ax,00000    ; DOS Command=Exit
        int 021




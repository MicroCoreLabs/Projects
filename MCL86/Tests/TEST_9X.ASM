; Tests for opcode range 0x90-0x9F
; ---------------------------------

                   
; 0x90 - XCHG AX,AX - NOP
; 0x91 - XCHG AX,CX - NOP
; 0x92 - XCHG AX,DX - NOP
; 0x93 - XCHG AX,BX - NOP
; 0x94 - XCHG AX,SP - NOP
; 0x95 - XCHG AX,BP - NOP
; 0x96 - XCHG AX,SI - NOP
; 0x97 - XCHG AX,DI - NOP
; ############################################################

TEST_90_0:
        mov ax,01234
        xchg ax,ax

        mov ax,0AAAA
        mov cx,0CCCC
        xchg ax,cx
        cmp ax,0CCCC
        jne FAIL_90_0
        cmp cx,0AAAA
        jne FAIL_90_0

        mov ax,0AAAA
        mov dx,0DDDD
        xchg ax,dx
        cmp ax,0DDDD
        jne FAIL_90_0
        cmp dx,0AAAA
        jne FAIL_90_0

        mov ax,0AAAA
        mov bx,0BBBB
        xchg ax,bx
        cmp ax,0BBBB
        jne FAIL_90_0
        cmp bx,0AAAA
        jne FAIL_90_0

        mov ax,0AAAA
        mov sp,01111
        xchg ax,sp
        cmp ax,01111
        jne FAIL_90_0
        cmp sp,0AAAA
        jne FAIL_90_0

        mov ax,0AAAA
        mov bp,02222
        xchg ax,bp
        cmp ax,02222
        jne FAIL_90_0
        cmp bp,0AAAA
        jne FAIL_90_0

        mov ax,0AAAA
        mov si,03333
        xchg ax,si
        cmp ax,03333
        jne FAIL_90_0
        cmp si,0AAAA
        jne FAIL_90_0

        mov ax,0AAAA
        mov di,04444
        xchg ax,di
        cmp ax,04444
        jne FAIL_90_0
        cmp di,0AAAA
        jne FAIL_90_0
        jmp TEST_98_0

FAIL_90_0:
        mov dx,00030    ; Print a 0
        mov ax,00202
        int 021
        jmp Z_END


; 0x98 - CBW
; ############################################################

TEST_98_0:
        mov ax,0127F
        cbw
        cmp ax,0007F
        jne FAIL_98_0

        mov ax,01280
        cbw
        cmp ax,0FF80
        jne FAIL_98_0
        jmp TEST_99_0


FAIL_98_0:
        mov dx,00038    ; Print a 8
        mov ax,00202
        int 021
        jmp Z_END


; 0x99 - CWD
; ############################################################

TEST_99_0:
        mov ax,07FFF
        cwd
        cmp dx,00000
        jne FAIL_99_0
        cmp ax,07FFF
        jne FAIL_99_0

        mov ax,08123
        cwd
        cmp dx,0FFFF
        jne FAIL_99_0
        cmp ax,08123
        jne FAIL_99_0
        jmp TEST_9C_0


FAIL_99_0:
        mov dx,00039    ; Print a 9
        mov ax,00202
        int 021
        jmp Z_END


; 0x9C - PUSHF
; 0x9D - POPF
; ############################################################

TEST_9C_0:
        pushf           ; Observe with D86
        pop ax
        push ax
        popf


; 0x9E - SAHF
; 0x9F - LAHF
; ############################################################

TEST_9E_0:
        mov ax,0FF00
        sahf
        lahf
        and ax,0D500    ; clear unused flag fields
        cmp ax,0D500
        jne FAIL_9E_0

        mov ax,00000
        sahf
        lahf
        and ax,0D500    ; clear unused flag fields
        cmp ax,00000
        jne FAIL_9E_0
        jmp Z_END

FAIL_9E_0:
        mov dx,00045    ; Print a E
        mov ax,00202
        int 021


; xxxxxxxxxxxxxxxxxxxxxxx
; End
; xxxxxxxxxxxxxxxxxxxxxxx
Z_END:
        mov ax,00000    ; DOS Commtest=Exit
        int 021


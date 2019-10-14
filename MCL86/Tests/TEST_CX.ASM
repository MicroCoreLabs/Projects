; Tests for opcode range 0xC0-0xCF
; ---------------------------------
                   
; 0xC4 - LES REG16,MEM16
; ############################################################

TEST_C4_0:
        mov word [00050], 01234
        mov word [00052], 05678

        les ax,[00050]

        cmp ax,01234
        jne FAIL_C4_0
        mov bx,es
        cmp bx,05678
        jne FAIL_C4_0

        jmp TEST_C5_0


FAIL_C4_0:
        mov dx,00034    ; Print a 4
        mov ax,00202
        int 021


; 0xC5 - LDS REG16,MEM16
; ############################################################

TEST_C5_0:
        mov word [00050], 0ABCD
        mov word [00052], 08675

        lds ax,[00050]

        cmp ax,0ABCD
        jne FAIL_C5_0
        mov bx,ds
        cmp bx,08675
        jne FAIL_C5_0

        jmp TEST_C6_0


FAIL_C5_0:
        mov dx,00035    ; Print a 5
        mov ax,00202
        int 021


; 0xC6 - MOV MEM8,IMM8
; 0xC7 - MOV MEM16,IMM16
; ############################################################

TEST_C6_0:
        mov byte [00060], 078
        cmp byte [00060], 078
        jne FAIL_C6_0

        mov word [00070], 0DEAD
        cmp word [00070], 0DEAD
        jne FAIL_C6_0

        jmp TEST_CF_0


FAIL_C6_0:
        mov dx,00036    ; Print a 6
        mov ax,00202
        int 021


TEST_CF_0 : nop


; xxxxxxxxxxxxxxxxxxxxxxx
; End
; xxxxxxxxxxxxxxxxxxxxxxx
Z_END:
        mov ax,00000    ; DOS Command=Exit
        int 021




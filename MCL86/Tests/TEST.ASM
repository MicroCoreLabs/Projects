; ############################################################

TEST_FF_0:              ; INC REG16/MEM16
        mov dx,00044
        inc dx
        cmp dx,00045
        jne FAIL_FF_0

        mov word[00050],033
        inc word[00050]
        cmp word[00050],034
        jne FAIL_FF_0

        mov ax,0007F      ; Overflow should be set
        inc ax
        jno FAIL_FF_0

        mov ax,00044      ; Overflow should NOT be set
        inc ax
        jo FAIL_FF_0

        mov ax,000F3      ; Sign should be set
        inc ax
        jns FAIL_FF_0

        mov ax,00044      ; Sign should NOT be set
        inc ax
        js FAIL_FF_0

        mov ax,000FF      ; Zero should be set
        inc ax
        jnz FAIL_FF_0

        mov ax,00044      ; Zero should NOT be set
        inc ax
        jz FAIL_FF_0

        mov ax,00011      ; Parity should be set
        inc ax
        jnp FAIL_FF_0

        mov ax,00012      ; Parity should NOT be set
        inc ax
        jp FAIL_FF_0
        jmp TEST_FF_0

FAIL_FF_0:
        mov dx,00046    ; Print a F
        mov ax,00202
        int 021


; 0xFF
; ############################################################

TEST_FF_1:              ; DEC REG16/MEM16
        mov dx,00044
        dec dx
        cmp dx,00043
        jne FAIL_FF_1

        mov word[00050],033
        dec word[00050]
        cmp word[00050],032
        jne FAIL_FF_1

        mov ax,00080      ; Overflow should be set
        dec ax
        jno FAIL_FF_1

        mov ax,00044      ; Overflow should NOT be set
        dec ax
        jo FAIL_FF_1

        mov ax,000F3      ; Sign should be set
        dec ax
        jns FAIL_FF_1

        mov ax,00044      ; Sign should NOT be set
        dec ax
        js FAIL_FF_1

        mov ax,00001      ; Zero should be set
        dec ax
        jnz FAIL_FF_1

        mov ax,00044      ; Zero should NOT be set
        dec ax
        jz FAIL_FF_1

        mov ax,00013      ; Parity should be set
        dec ax
        jnp FAIL_FF_1

        mov ax,00014      ; Parity should NOT be set
        dec ax
        jp FAIL_FF_1
        jmp Z_END

FAIL_FF_1:
        mov dx,00046    ; Print a F
        mov ax,00202
        int 021

; xxxxxxxxxxxxxxxxxxxxxxx
; End
; xxxxxxxxxxxxxxxxxxxxxxx
Z_END:
        mov ax,00000    ; DOS Commtest=Exit
        int 021


; Tests for opcode range 0x40-0x4F
; ---------------------------------

                   
; 0x40 - INC AX
; ############################################################

TEST_40_0:
        mov ax,01234
        inc ax
        cmp ax,01235
        jne FAIL_40_0

        mov ax,07FFF
        inc ax          ; Overflow should be set
        jno FAIL_40_0

        mov ax,00044
        inc ax          ; Overflow should not be set
        jo FAIL_40_0

        mov ax,07FFF
        inc ax          ; Sign should be set
        jns FAIL_40_0

        mov ax,00044
        inc ax          ; Sign should not be set
        js FAIL_40_0

        mov ax,0FFFF
        inc ax          ; Zero should be set
        jnz FAIL_40_0

        mov ax,00044
        inc ax          ; Zero should not be set
        jz FAIL_40_0

        mov ax,04410
        inc ax          ; Parity should be set
        jnp FAIL_40_0

        mov ax,04400
        inc ax          ; Parity should not be set
        jp FAIL_40_0
        jmp TEST_41_0

FAIL_40_0:
        mov dx,00030    ; Print a 0
        mov ax,00202
        int 021

                   
; 0x41 - INC CX
; ############################################################

TEST_41_0:
        mov cx,01234
        inc cx
        cmp cx,01235
        jne FAIL_41_0

        mov cx,07FFF
        inc cx          ; Overflow should be set
        jno FAIL_41_0

        mov cx,00044
        inc cx          ; Overflow should not be set
        jo FAIL_41_0

        mov cx,07FFF
        inc cx          ; Sign should be set
        jns FAIL_41_0

        mov cx,00044
        inc cx          ; Sign should not be set
        js FAIL_41_0

        mov cx,0FFFF
        inc cx          ; Zero should be set
        jnz FAIL_41_0

        mov cx,00044
        inc cx          ; Zero should not be set
        jz FAIL_41_0

        mov cx,04410
        inc cx          ; Parity should be set
        jnp FAIL_41_0

        mov cx,04400
        inc cx          ; Parity should not be set
        jp FAIL_41_0
        jmp TEST_42_0

FAIL_41_0:
        mov dx,00031    ; Print a 1
        mov ax,00202
        int 021


; 0x42 - INC DX
; ############################################################

TEST_42_0:
        mov dx,01234
        inc dx
        cmp dx,01235
        jne FAIL_42_0

        mov dx,07FFF
        inc dx          ; Overflow should be set
        jno FAIL_42_0

        mov dx,00044
        inc dx          ; Overflow should not be set
        jo FAIL_42_0

        mov dx,07FFF
        inc dx          ; Sign should be set
        jns FAIL_42_0

        mov dx,00044
        inc dx          ; Sign should not be set
        js FAIL_42_0

        mov dx,0FFFF
        inc dx          ; Zero should be set
        jnz FAIL_42_0

        mov dx,00044
        inc dx          ; Zero should not be set
        jz FAIL_42_0

        mov dx,04410
        inc dx          ; Parity should be set
        jnp FAIL_42_0

        mov dx,04400
        inc dx          ; Parity should not be set
        jp FAIL_42_0
        jmp TEST_43_0

FAIL_42_0:
        mov dx,00032    ; Print a 2
        mov ax,00202
        int 021


; 0x43 - INC BX
; ############################################################

TEST_43_0:
        mov bx,01234
        inc bx
        cmp bx,01235
        jne FAIL_43_0

        mov bx,07FFF
        inc bx          ; Overflow should be set
        jno FAIL_43_0

        mov bx,00044
        inc bx          ; Overflow should not be set
        jo FAIL_43_0

        mov bx,07FFF
        inc bx          ; Sign should be set
        jns FAIL_43_0

        mov bx,00044
        inc bx          ; Sign should not be set
        js FAIL_43_0

        mov bx,0FFFF
        inc bx          ; Zero should be set
        jnz FAIL_43_0

        mov bx,00044
        inc bx          ; Zero should not be set
        jz FAIL_43_0

        mov bx,04410
        inc bx          ; Parity should be set
        jnp FAIL_43_0

        mov bx,04400
        inc bx          ; Parity should not be set
        jp FAIL_43_0
        jmp TEST_44_0

FAIL_43_0:
        mov dx,00033    ; Print a 3
        mov ax,00202
        int 021

; 0x44 - INC SP
; ############################################################

TEST_44_0:
        mov sp,01234
        inc sp
        cmp sp,01235
        jne FAIL_44_0

        mov sp,07FFF
        inc sp          ; Overflow should be set
        jno FAIL_44_0

        mov sp,00044
        inc sp          ; Overflow should not be set
        jo FAIL_44_0

        mov sp,07FFF
        inc sp          ; Sign should be set
        jns FAIL_44_0

        mov sp,00044
        inc sp          ; Sign should not be set
        js FAIL_44_0

        mov sp,0FFFF
        inc sp          ; Zero should be set
        jnz FAIL_44_0

        mov sp,00044
        inc sp          ; Zero should not be set
        jz FAIL_44_0

        mov sp,04410
        inc sp          ; Parity should be set
        jnp FAIL_44_0

        mov sp,04400
        inc sp          ; Parity should not be set
        jp FAIL_44_0
        jmp TEST_45_0

FAIL_44_0:
        mov dx,00034    ; Print a 4
        mov ax,00202
        int 021


; 0x45 - INC BP
; ############################################################

TEST_45_0:
        mov bp,01234
        inc bp
        cmp bp,01235
        jne FAIL_45_0

        mov bp,07FFF
        inc bp          ; Overflow should be set
        jno FAIL_45_0

        mov bp,00044
        inc bp          ; Overflow should not be set
        jo FAIL_45_0

        mov bp,07FFF
        inc bp          ; Sign should be set
        jns FAIL_45_0

        mov bp,00044
        inc bp          ; Sign should not be set
        js FAIL_45_0

        mov bp,0FFFF
        inc bp          ; Zero should be set
        jnz FAIL_45_0

        mov bp,00044
        inc bp          ; Zero should not be set
        jz FAIL_45_0

        mov bp,04410
        inc bp          ; Parity should be set
        jnp FAIL_45_0

        mov bp,04400
        inc bp          ; Parity should not be set
        jp FAIL_45_0
        jmp TEST_46_0

FAIL_45_0:
        mov dx,00035    ; Print a 5
        mov ax,00202
        int 021


; 0x46 - INC SI
; ############################################################

TEST_46_0:
        mov si,01234
        inc si
        cmp si,01235
        jne FAIL_46_0

        mov si,07FFF
        inc si          ; Overflow should be set
        jno FAIL_46_0

        mov si,00044
        inc si          ; Overflow should not be set
        jo FAIL_46_0

        mov si,07FFF
        inc si          ; Sign should be set
        jns FAIL_46_0

        mov si,00044
        inc si          ; Sign should not be set
        js FAIL_46_0

        mov si,0FFFF
        inc si          ; Zero should be set
        jnz FAIL_46_0

        mov si,00044
        inc si          ; Zero should not be set
        jz FAIL_46_0

        mov si,04410
        inc si          ; Parity should be set
        jnp FAIL_46_0

        mov si,04400
        inc si          ; Parity should not be set
        jp FAIL_46_0
        jmp TEST_47_0

FAIL_46_0:
        mov dx,00036    ; Print a 6
        mov ax,00202
        int 021


; 0x47 - INC DI
; ############################################################

TEST_47_0:
        mov di,01234
        inc di
        cmp di,01235
        jne FAIL_47_0

        mov di,07FFF
        inc di          ; Overflow should be set
        jno FAIL_47_0

        mov di,00044
        inc di          ; Overflow should not be set
        jo FAIL_47_0

        mov di,07FFF
        inc di          ; Sign should be set
        jns FAIL_47_0

        mov di,00044
        inc di          ; Sign should not be set
        js FAIL_47_0

        mov di,0FFFF
        inc di          ; Zero should be set
        jnz FAIL_47_0

        mov di,00044
        inc di          ; Zero should not be set
        jz FAIL_47_0

        mov di,04410
        inc di          ; Parity should be set
        jnp FAIL_47_0

        mov di,04400
        inc di          ; Parity should not be set
        jp FAIL_47_0
        jmp TEST_48_0

FAIL_47_0:
        mov dx,00037    ; Print a 7
        mov ax,00202
        int 021

                   
; 0x48 - DEC AX
; ############################################################

TEST_48_0:
        mov ax,01234
        dec ax
        cmp ax,01233
        jne FAIL_48_0

        mov ax,08000
        dec ax          ; Overflow should be set
        jno FAIL_48_0

        mov ax,00044
        dec ax          ; Overflow should not be set
        jo FAIL_48_0

        mov ax,0FFFF
        dec ax          ; Sign should be set
        jns FAIL_48_0

        mov ax,00044
        dec ax          ; Sign should not be set
        js FAIL_48_0

        mov ax,00001
        dec ax          ; Zero should be set
        jnz FAIL_48_0

        mov ax,00044
        dec ax          ; Zero should not be set
        jz FAIL_48_0

        mov ax,04413
        dec ax          ; Parity should be set
        jnp FAIL_48_0

        mov ax,04411
        dec ax          ; Parity should not be set
        jp FAIL_48_0
        jmp TEST_49_0

FAIL_48_0:
        mov dx,00038    ; Print a 8
        mov ax,00202
        int 021

                   
; 0x49 - DEC CX
; ############################################################

TEST_49_0:
        mov cx,01234
        dec cx
        cmp cx,01233
        jne FAIL_49_0

        mov cx,08000
        dec cx          ; Overflow should be set
        jno FAIL_49_0

        mov cx,00044
        dec cx          ; Overflow should not be set
        jo FAIL_49_0

        mov cx,0FFFF
        dec cx          ; Sign should be set
        jns FAIL_49_0

        mov cx,00044
        dec cx          ; Sign should not be set
        js FAIL_49_0

        mov cx,00001
        dec cx          ; Zero should be set
        jnz FAIL_49_0

        mov cx,00044
        dec cx          ; Zero should not be set
        jz FAIL_49_0

        mov cx,04413
        dec cx          ; Parity should be set
        jnp FAIL_49_0

        mov cx,04411
        dec cx          ; Parity should not be set
        jp FAIL_49_0
        jmp TEST_4A_0

FAIL_49_0:
        mov dx,00039    ; Print a 9
        mov ax,00202
        int 021


; 0x4A - DEC DX
; ############################################################

TEST_4A_0:
        mov dx,01234
        dec dx
        cmp dx,01233
        jne FAIL_4A_0

        mov dx,08000
        dec dx          ; Overflow should be set
        jno FAIL_4A_0

        mov dx,00044
        dec dx          ; Overflow should not be set
        jo FAIL_4A_0

        mov dx,0FFFF
        dec dx          ; Sign should be set
        jns FAIL_4A_0

        mov dx,00044
        dec dx          ; Sign should not be set
        js FAIL_4A_0

        mov dx,00001
        dec dx          ; Zero should be set
        jnz FAIL_4A_0

        mov dx,00044
        dec dx          ; Zero should not be set
        jz FAIL_4A_0

        mov dx,04413
        dec dx          ; Parity should be set
        jnp FAIL_4A_0

        mov dx,04411
        dec dx          ; Parity should not be set
        jp FAIL_4A_0
        jmp TEST_4B_0

FAIL_4A_0:
        mov dx,00041    ; Print a A
        mov ax,00202
        int 021


; 0x4B - DEC BX
; ############################################################

TEST_4B_0:
        mov bx,01234
        dec bx
        cmp bx,01233
        jne FAIL_4B_0

        mov bx,08000
        dec bx          ; Overflow should be set
        jno FAIL_4B_0

        mov bx,00044
        dec bx          ; Overflow should not be set
        jo FAIL_4B_0

        mov bx,0FFFF
        dec bx          ; Sign should be set
        jns FAIL_4B_0

        mov bx,00044
        dec bx          ; Sign should not be set
        js FAIL_4B_0

        mov bx,00001
        dec bx          ; Zero should be set
        jnz FAIL_4B_0

        mov bx,00044
        dec bx          ; Zero should not be set
        jz FAIL_4B_0

        mov bx,04413
        dec bx          ; Parity should be set
        jnp FAIL_4B_0

        mov bx,04411
        dec bx          ; Parity should not be set
        jp FAIL_4B_0
        jmp TEST_4C_0

FAIL_4B_0:
        mov dx,00042    ; Print a B
        mov ax,00202
        int 021


; 0x4C - DEC SP
; ############################################################

TEST_4C_0:
        mov sp,01234
        dec sp
        cmp sp,01233
        jne FAIL_4C_0

        mov sp,08000
        dec sp          ; Overflow should be set
        jno FAIL_4C_0

        mov sp,00044
        dec sp          ; Overflow should not be set
        jo FAIL_4C_0

        mov sp,0FFFF
        dec sp          ; Sign should be set
        jns FAIL_4C_0

        mov sp,00044
        dec sp          ; Sign should not be set
        js FAIL_4C_0

        mov sp,00001
        dec sp          ; Zero should be set
        jnz FAIL_4C_0

        mov sp,00044
        dec sp          ; Zero should not be set
        jz FAIL_4C_0

        mov sp,04413
        dec sp          ; Parity should be set
        jnp FAIL_4C_0

        mov sp,04411
        dec sp          ; Parity should not be set
        jp FAIL_4C_0
        jmp TEST_4D_0

FAIL_4C_0:
        mov dx,00043    ; Print a C
        mov ax,00202
        int 021


; 0x4D - DEC BP
; ############################################################

TEST_4D_0:
        mov bp,01234
        dec bp
        cmp bp,01233
        jne FAIL_4D_0

        mov bp,08000
        dec bp          ; Overflow should be set
        jno FAIL_4D_0

        mov bp,00044
        dec bp          ; Overflow should not be set
        jo FAIL_4D_0

        mov bp,0FFFF
        dec bp          ; Sign should be set
        jns FAIL_4D_0

        mov bp,00044
        dec bp          ; Sign should not be set
        js FAIL_4D_0

        mov bp,00001
        dec bp          ; Zero should be set
        jnz FAIL_4D_0

        mov bp,00044
        dec bp          ; Zero should not be set
        jz FAIL_4D_0

        mov bp,04413
        dec bp          ; Parity should be set
        jnp FAIL_4D_0

        mov bp,04411
        dec bp          ; Parity should not be set
        jp FAIL_4D_0
        jmp TEST_4E_0

FAIL_4D_0:
        mov dx,00044    ; Print a D
        mov ax,00202
        int 021


; 0x4E - DEC SI
; ############################################################

TEST_4E_0:
        mov si,01234
        dec si
        cmp si,01233
        jne FAIL_4E_0

        mov si,08000
        dec si          ; Overflow should be set
        jno FAIL_4E_0

        mov si,00044
        dec si          ; Overflow should not be set
        jo FAIL_4E_0

        mov si,0FFFF
        dec si          ; Sign should be set
        jns FAIL_4E_0

        mov si,00044
        dec si          ; Sign should not be set
        js FAIL_4E_0

        mov si,00001
        dec si          ; Zero should be set
        jnz FAIL_4E_0

        mov si,00044
        dec si          ; Zero should not be set
        jz FAIL_4E_0

        mov si,04413
        dec si          ; Parity should be set
        jnp FAIL_4E_0

        mov si,04411
        dec si          ; Parity should not be set
        jp FAIL_4E_0
        jmp TEST_4F_0

FAIL_4E_0:
        mov dx,00045    ; Print a E
        mov ax,00202
        int 021


; 0x4F - DEC DI
; ############################################################

TEST_4F_0:
        mov di,01234
        dec di
        cmp di,01233
        jne FAIL_4F_0

        mov di,08000
        dec di          ; Overflow should be set
        jno FAIL_4F_0

        mov di,00044
        dec di          ; Overflow should not be set
        jo FAIL_4F_0

        mov di,0FFFF
        dec di          ; Sign should be set
        jns FAIL_4F_0

        mov di,00044
        dec di          ; Sign should not be set
        js FAIL_4F_0

        mov di,00001
        dec di          ; Zero should be set
        jnz FAIL_4F_0

        mov di,00044
        dec di          ; Zero should not be set
        jz FAIL_4F_0

        mov di,04413
        dec di          ; Parity should be set
        jnp FAIL_4F_0

        mov di,04411
        dec di          ; Parity should not be set
        jp FAIL_4F_0
        jmp Z_END

FAIL_4F_0:
        mov dx,00046    ; Print a F
        mov ax,00202
        int 021

; xxxxxxxxxxxxxxxxxxxxxxx
; End
; xxxxxxxxxxxxxxxxxxxxxxx
Z_END:
        mov ax,00000    ; DOS Command=Exit
        int 021




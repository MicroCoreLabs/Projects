; Tests for opcode range 0xF0-FF
; ---------------------------------

                   
; 0xF4 - HALT
; ############################################################

TEST_F4_0:
        sti
        mov ax,0001
        hlt             ; Two halts in a row
        hlt             ; Should wait for two interrupts


; 0xF5 - CMC
; ############################################################

TEST_F5_0:
        stc             ; Set Carry Flag
        cmc             ; Compliment the Carry Flag
        jc FAIL_F5_0    ; Carry should not be set

        clc             ; Clear Carry Flag
        cmc             ; Compliment the Carry Flag
        jnc FAIL_F5_0   ; Carry should  be set
        jmp TEST_F6_0


FAIL_F5_0:
        mov dx,00035    ; Print a 5
        mov ax,00202
        int 021


; 0xF6
; ############################################################

TEST_F6_0:              ; TEST REG8/MEM8 , IMM8
        mov  dh,05A
        test dh,0A5
        jne FAIL_F6_0

        mov byte[00050],081
        test byte [00050],018
        jne FAIL_F6_0

        mov  bl,011
        test bl,011
        je FAIL_F6_0

        mov byte[00050],055
        test byte [00050],055
        je FAIL_F6_0
        jmp TEST_F6_1

FAIL_F6_0:
        mov dx,00036    ; Print a 6
        mov ax,00202
        int 021


TEST_F6_1:              ; NOT REG8/MEM8
        mov bl,055
        not bl
        cmp bl,0AA
        jne FAIL_F6_1

        mov byte[00050],033
        not byte[00050]
        cmp byte[00050],0CC
        jne FAIL_F6_1
        jmp TEST_F6_2

FAIL_F6_1:
        mov dx,00036    ; Print a 6
        mov ax,00202
        int 021



TEST_F6_2:              ; NEG REG8/MEM8
        mov bl,055
        neg bl
        cmp bl,0AB
        jne FAIL_F6_2

        mov byte[00050],033
        neg byte[00050]
        cmp byte[00050],0CD
        jne FAIL_F6_2

        clc
        mov dh,022      ; Carry should be set
        neg dh
        jnc FAIL_F6_2

        mov dh,080      ; Overflow should be set
        neg dh
        jno FAIL_F6_2
        mov dh,001      ; Overflow should NOT be set
        neg dh
        jo FAIL_F6_2

        mov dh,0EE      ; Parity should be set
        neg dh
        jnp FAIL_F6_2
        mov dh,055      ; Parity should NOT be set
        neg dh
        jp FAIL_F6_2

        mov dh,055      ; Sign should be set
        neg dh
        jns FAIL_F6_2
        mov dh,0F5      ; Sign should NOT be set
        neg dh
        js FAIL_F6_2

        mov dh,000      ; Zero should be set
        neg dh
        jnz FAIL_F6_2
        mov dh,080      ; Zero should NOT be set
        neg dh
        jz FAIL_F6_2
        jmp TEST_F6_3

FAIL_F6_2:
        mov dx,00036    ; Print a 6
        mov ax,00202
        int 021



TEST_F6_3:              ; MUL REG8/MEM8
        mov ax,00000
        mov cx,01111
        mov bx,00000
        mov dx,00000
L_F6_0:
        mul cl
        add bx,ax
        inc dl
        mov al,dl
        mov ah,000
        loop L_F6_0
        cmp bx,01C30
        jne FAIL_F6_3
        jmp TEST_F6_4

FAIL_F6_3:
        mov dx,00036    ; Print a 6
        mov ax,00202
        int 021



TEST_F6_4:              ; IMUL REG8/MEM8
        mov ax,00000
        mov cx,01111
        mov bx,00000
        mov dx,00000
L_F6_1:
        imul cl
        add bx,ax
        inc dl
        mov al,dl
        mov ah,000
        loop L_F6_1
        cmp bx,09C30
        jne FAIL_F6_4
        jmp TEST_F6_5

FAIL_F6_4:
        mov dx,00036    ; Print a 6
        mov ax,00202
        int 021


TEST_F6_5:              ; DIV REG8/MEM8
        mov ax,000FF
        mov cx,000FF
        mov bx,00000
L_F6_2:
        cmp cl,000
        je DONE_F6_5
        div cl
        add bx,ax
        mov ax,000FF
        loop L_F6_2
DONE_F6_5:
        cmp bx,0C8B1
        jne FAIL_F6_5
        jmp TEST_F6_6

FAIL_F6_5:
        mov dx,00036    ; Print a 6
        mov ax,00202
        int 021


TEST_F6_6:              ; IDIV REG8/MEM8
        mov ax,0007F
        mov cx,0007F
        mov bx,00000
L_F6_3:
        cmp cl,000
        je DONE_F6_6
        idiv cl
        add bx,ax
        mov ax,0007F
        loop L_F6_3
DONE_F6_6:
        cmp bx,0237D
        jne FAIL_F6_6
        jmp TEST_F7_0

FAIL_F6_6:
        mov dx,00036    ; Print a 6
        mov ax,00202
        int 021


                   
; 0xF7
; ############################################################

TEST_F7_0:              ; TEST REG16/MEM16 , IMM16
        mov  dx,0115A
        test dx,022A5
        jne FAIL_F7_0

        mov word[00050],01181
        test word [00050],02218
        jne FAIL_F7_0

        mov  bx,03311
        test bx,03311
        je FAIL_F7_0

        mov word[00050],05555
        test word [00050],05555
        je FAIL_F7_0
        jmp TEST_F7_1

FAIL_F7_0:
        mov dx,00037    ; Print a 7
        mov ax,00202
        int 021



TEST_F7_1:              ; NOT REG16/MEM16
        mov bx,05555
        not bx
        cmp bx,0AAAA
        jne FAIL_F7_1

        mov word[00050],03333
        not word[00050]
        cmp word[00050],0CCCC
        jne FAIL_F7_1
        jmp TEST_F7_2

FAIL_F7_1:
        mov dx,00037    ; Print a 7
        mov ax,00202
        int 021



TEST_F7_2:              ; NEG REG16/MEM16
        mov bx,05555
        neg bx
        cmp bx,0AAAB
        jne FAIL_F7_2

        mov word[00050],01234
        neg word[00050]
        cmp word[00050],0EDCC
        jne FAIL_F7_2

        clc
        mov dx,0789A      ; Carry should be set
        neg dx
        jnc FAIL_F7_2

        mov dx,08000      ; Overflow should be set
        neg dx
        jno FAIL_F7_2
        mov dx,00001      ; Overflow should NOT be set
        neg dx
        jo FAIL_F7_2

        mov dx,000EE      ; Parity should be set
        neg dx
        jnp FAIL_F7_2
        mov dx,00055      ; Parity should NOT be set
        neg dx
        jp FAIL_F7_2

        mov dx,00055      ; Sign should be set
        neg dx
        jns FAIL_F7_2
        mov dx,0FFF5      ; Sign should NOT be set
        neg dx
        js FAIL_F7_2

        mov dx,00000      ; Zero should be set
        neg dx
        jnz FAIL_F7_2
        mov dx,00080      ; Zero should NOT be set
        neg dx
        jz FAIL_F7_2
        jmp TEST_F7_3

FAIL_F7_2:
        mov dx,00037    ; Print a 7
        mov ax,00202
        int 021


TEST_F7_3:              ; MUL REG16/MEM16
        mov ax,00000
        mov cx,0FFFF
        mov bx,00000
        mov dx,00000
L_F7_0:
        mov ax,cx
        not ax
        mul cx
        add bx,ax
        add bx,dx
        loop L_F7_0
        cmp bx,0AAAC
        jne FAIL_F7_3
        jmp TEST_F7_4

FAIL_F7_3:
        mov dx,00037    ; Print a 7
        mov ax,00202
        int 021



TEST_F7_4:              ; IMUL REG16/MEM16
        mov ax,00000
        mov cx,0FFFF
        mov bx,00000
        mov dx,00000
L_F7_1:
        mov ax,cx
        not ax
        imul cx
        add bx,ax
        add bx,dx
        loop L_F7_1
        cmp bx,02AAC
        jne FAIL_F7_4
        jmp TEST_F7_5

FAIL_F7_4:
        mov dx,00037    ; Print a 7
        mov ax,00202
        int 021


TEST_F7_5:              ; DIV REG16/MEM16
        mov dx,01234
        mov ax,05678
        mov cx,0ABCD
        div cx
        cmp ax,01b20
        jne FAIL_F7_5
        cmp dx,03DD8
        jne FAIL_F7_5

        mov dx,00000
        mov ax,0FACE
        mov cx,00055
        div cx
        cmp ax,02F3
        jne FAIL_F7_5
        cmp dx,0001F
        jne FAIL_F7_5

        mov dx,00000
        mov ax,00000
        mov cx,00055
        div cx
        cmp ax,00000
        jne FAIL_F7_5
        cmp dx,00000
        jne FAIL_F7_5

                              ; IDIV REG16/MEM16
        mov dx,01234
        mov ax,05678
        mov cx,0ABCD
        idiv cx
        cmp ax,0C8A7
        jne FAIL_F7_5
        cmp dx,01BBD
        jne FAIL_F7_5

        mov dx,00000
        mov ax,0FACE
        mov cx,00055
        idiv cx
        cmp ax,002F3
        jne FAIL_F7_5
        cmp dx,0001F
        jne FAIL_F7_5

        mov dx,00000
        mov ax,00000
        mov cx,00055
        idiv cx
        cmp ax,00000
        jne FAIL_F7_5
        cmp dx,00000
        jne FAIL_F7_5

        jmp TEST_FE_0


FAIL_F7_5:
        mov dx,00037    ; Print a 7
        mov ax,00202
        int 021


; 0xFE
; ############################################################

TEST_FE_0:              ; INC REG8/MEM8
        mov dh,044
        inc dh
        cmp dh,045
        jne FAIL_FE_0

        mov byte[00050],033
        inc byte[00050]
        cmp byte[00050],034
        jne FAIL_FE_0

        mov al,07F      ; Overflow should be set
        inc al
        jno FAIL_FE_0

        mov al,044      ; Overflow should NOT be set
        inc al
        jo FAIL_FE_0

        mov al,0F3      ; Sign should be set
        inc al
        jns FAIL_FE_0

        mov al,044      ; Sign should NOT be set
        inc al
        js FAIL_FE_0

        mov al,0FF      ; Zero should be set
        inc al
        jnz FAIL_FE_0

        mov al,044      ; Zero should NOT be set
        inc al
        jz FAIL_FE_0

        mov al,011      ; Parity should be set
        inc al
        jnp FAIL_FE_0

        mov al,012      ; Parity should NOT be set
        inc al
        jp FAIL_FE_0
        jmp TEST_FF_0

FAIL_FE_0:
        mov dx,00045    ; Print a E
        mov ax,00202
        int 021



TEST_FE_1:              ; DEC REG8/MEM8
        mov dh,044
        dec dh
        cmp dh,043
        jne FAIL_FE_1

        mov byte[00050],033
        dec byte[00050]
        cmp byte[00050],032
        jne FAIL_FE_1

        mov al,080      ; Overflow should be set
        dec al
        jno FAIL_FE_1

        mov al,044      ; Overflow should NOT be set
        dec al
        jo FAIL_FE_1

        mov al,0F3      ; Sign should be set
        dec al
        jns FAIL_FE_1

        mov al,044      ; Sign should NOT be set
        dec al
        js FAIL_FE_1

        mov al,001      ; Zero should be set
        dec al
        jnz FAIL_FE_1

        mov al,044      ; Zero should NOT be set
        dec al
        jz FAIL_FE_1

        mov al,013      ; Parity should be set
        dec al
        jnp FAIL_FE_1

        mov al,014      ; Parity should NOT be set
        dec al
        jp FAIL_FE_1
        jmp TEST_FF_0

FAIL_FE_1:
        mov dx,00045    ; Print a E
        mov ax,00202
        int 021


; ############################################################

TEST_FF_0:              ; INC MEM16
        mov word[00050],03333
        inc word[00050]
        cmp word[00050],03334
        jne FAIL_FF_0

        mov word[00050],07FFF      ; Overflow should be set
        inc word[00050]
        jno FAIL_FF_0

        mov word[00050],00044      ; Overflow should NOT be set
        inc word[00050]
        jo FAIL_FF_0

        mov word[00050],07FFF      ; Sign should be set
        inc word[00050]
        jns FAIL_FF_0

        mov word[00050],00044      ; Sign should NOT be set
        inc word[00050]
        js FAIL_FF_0

        mov word[00050],0FFFF      ; Zero should be set
        inc word[00050]
        jnz FAIL_FF_0

        mov word[00050],00044      ; Zero should NOT be set
        inc word[00050]
        jz FAIL_FF_0

        mov word[00050],00011      ; Parity should be set
        inc word[00050]
        jnp FAIL_FF_0

        mov word[00050],00012      ; Parity should NOT be set
        inc word[00050]
        jp FAIL_FF_0
        jmp TEST_FF_1

FAIL_FF_0:
        mov dx,00046    ; Print a F
        mov ax,00202
        int 021


TEST_FF_1:              ; DEC MEM16
        mov word[00050],03333
        dec word[00050]
        cmp word[00050],03332
        jne FAIL_FF_1

        mov word[00050],08000      ; Overflow should be set
        dec word[00050]
        jno FAIL_FF_1

        mov word[00050],00044      ; Overflow should NOT be set
        dec word[00050]
        jo FAIL_FF_1

        mov word[00050],0FFF3      ; Sign should be set
        dec word[00050]
        jns FAIL_FF_1

        mov word[00050],00044      ; Sign should NOT be set
        dec word[00050]
        js FAIL_FF_1

        mov word[00050],00001      ; Zero should be set
        dec word[00050]
        jnz FAIL_FF_1

        mov word[00050],00044      ; Zero should NOT be set
        dec word[00050]
        jz FAIL_FF_1

        mov word[00050],00013      ; Parity should be set
        dec word[00050]
        jnp FAIL_FF_1

        mov word[00050],00014      ; Parity should NOT be set
        dec word[00050]
        jp FAIL_FF_1
        jmp TEST_FF_2

FAIL_FF_1:
        mov dx,00046    ; Print a F
        mov ax,00202
        int 021


TEST_FF_2:              ; PUSH MEM16
        mov word[00050],0ABCD
        push word[00050]
        pop ax
        cmp ax,0ABCD
        jne FAIL_FF_2
        jmp Z_END

FAIL_FF_2:
        mov dx,00046    ; Print a F
        mov ax,00202
        int 021


; xxxxxxxxxxxxxxxxxxxxxxx
; End
; xxxxxxxxxxxxxxxxxxxxxxx
Z_END:
        mov ax,00000    ; DOS Commtest=Exit
        int 021


; Tests for opcode range 0xE0-EF
; ---------------------------------

                   
; 0xE0 - LOOPNE
; ############################################################

TEST_E0_0:
        mov cx,0000F
        mov ax,00000

L_E0_0: inc ax                 ; Exit loop when Zero detected
        cmp ax,00005
        loopne L_E0_0
        cmp cx,0000A
        jne FAIL_E0_0

TEST_E0_1:
        mov cx,0000F
        mov ax,00000

L_E0_1: inc ax                 ; Exit loop when Zero detected
        cmp ax,01234
        loopne L_E0_1
        cmp cx,00000
        jne FAIL_E0_0
        jmp TEST_E1_0

FAIL_E0_0:
        mov dx,00030    ; Print a 0
        mov ax,00202
        int 021

                   
; 0xE1 - LOOPE
; ############################################################

TEST_E1_0:
        mov cx,000FF
        mov ax,000FC

L_E1_0: inc ax                 ; Exit loop when Zero detected
        cmp ah,000
        loope L_E1_0
        cmp cx,000FB
        jne FAIL_E1_0

TEST_E1_1:
        mov cx,00004
        mov ax,00000

L_E1_1: inc ax                 ; Exit loop when Zero detected
        cmp ah,000
        loope L_E1_1
        cmp cx,00000
        jne FAIL_E1_0
        jmp TEST_E2_0

FAIL_E1_0:
        mov dx,00031    ; Print a 1
        mov ax,00202
        int 021

                   
; 0xE2 - LOOP
; ############################################################

TEST_E2_0:
        mov cx,00004
        mov ax,00000

L_E2:   inc ax                 ; Exit loop when Zero detected
        loopne L_E2
        cmp ax,00004
        jne FAIL_E2_0
        jmp TEST_E3_0


FAIL_E2_0:
        mov dx,00032    ; Print a 2
        mov ax,00202
        int 021

; 0xE3 - JCXZ
; ############################################################

TEST_E3_0:
        mov cx,00001
        jcxz FAIL_E3_0

        mov cx,00000
        jcxz TEST_EF_0


FAIL_E3_0:
        mov dx,00033    ; Print a 3
        mov ax,00202
        int 021


TEST_EF_0: nop

; xxxxxxxxxxxxxxxxxxxxxxx
; End
; xxxxxxxxxxxxxxxxxxxxxxx
Z_END:
        mov ax,00000    ; DOS Commtest=Exit
        int 021


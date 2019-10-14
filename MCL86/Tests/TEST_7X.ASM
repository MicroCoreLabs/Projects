; Tests for opcode range 0x70-0x7F
; ---------------------------------
                   
; 0x70 - JO SHORT LABEL
; ############################################################

TEST_70_0:
        mov ax,07FFF
        inc ax          ; Overflow flag should be set
        jo TEST_70_1
        jmp FAIL_70_0

TEST_70_1:
        mov ax,00000
        inc ax          ; Overflow flag should NOT be set
        jo FAIL_70_0

        jmp TEST_71_0

FAIL_70_0:
        mov dx,00030    ; Print a 0
        mov ax,00202
        int 021

; 0x71 - JNO SHORT LABEL
; ############################################################

TEST_71_0:
        mov ax,00000
        inc ax          ; Overflow flag should NOT be set
        jno TEST_71_1
        jmp FAIL_71_0

TEST_71_1:
        mov ax,07FFF
        inc ax          ; Overflow flag should be set
        jno FAIL_71_0

        jmp TEST_72_0

FAIL_71_0:
        mov dx,00031    ; Print a 1
        mov ax,00202
        int 021


; 0x72 - JB SHORT LABEL
; ############################################################

TEST_72_0:
        mov ax,0FFFF
        mov bx,00001
        add ax,bx       ; Carry flag should be set
        jb TEST_72_1
        jmp FAIL_72_0

TEST_72_1:
        mov ax,01234
        mov bx,00001
        add ax,bx       ; Carry flag should NOT be set
        jb FAIL_72_0

        jmp TEST_73_0

FAIL_72_0:
        mov dx,00032    ; Print a 2
        mov ax,00202
        int 021


; 0x73 - JNB SHORT LABEL
; ############################################################

TEST_73_0:
        mov ax,00004
        mov bx,00001
        add ax,bx       ; Carry flag should NOT be set
        jnb TEST_73_1
        jmp FAIL_73_0

TEST_73_1:
        mov ax,0FFFF
        mov bx,00001
        add ax,bx       ; Carry flag should be set
        jnb FAIL_73_0

        jmp TEST_74_0

FAIL_73_0:
        mov dx,00033    ; Print a 3
        mov ax,00202
        int 021


; 0x74 - JZ SHORT LABEL
; ############################################################

TEST_74_0:
        mov ax,00004
        mov bx,00004
        cmp ax,bx       ; Zero flag should be set
        jz TEST_74_1
        jmp FAIL_74_0

TEST_74_1:
        mov ax,0FFFF
        mov bx,00001
        cmp ax,bx       ; Zero flag should NOT be set
        jz FAIL_74_0

        jmp TEST_75_0

FAIL_74_0:
        mov dx,00034    ; Print a 4
        mov ax,00202
        int 021


; 0x75 - JNZ SHORT LABEL
; ############################################################

TEST_75_0:
        mov ax,00004
        mov bx,00033
        cmp ax,bx       ; Zero flag should NOT be set
        jnz TEST_75_1
        jmp FAIL_75_0

TEST_75_1:
        mov ax,01234
        mov bx,01234
        cmp ax,bx       ; Zero flag should be set
        jnz FAIL_75_0

        jmp TEST_76_0

FAIL_75_0:
        mov dx,00035    ; Print a 5
        mov ax,00202
        int 021


; 0x76 - JBE SHORT LABEL
; ############################################################

TEST_76_0:
        mov ax,00004
        mov bx,00001
        add ax,bx       ; CF=0  ZF=0  - Dont Jump
        jbe FAIL_76_0

TEST_76_1:
        mov ax,0FFFF
        mov bx,0000F
        add ax,bx       ; CF=1  ZF=0  - Yes Jump
        jbe TEST_76_2
        jmp FAIL_76_0

TEST_76_2:
        mov ax,00004
        mov bx,00004
        sub ax,bx       ; CF=0  ZF=1  - Yes Jump
        jbe TEST_76_3
        jmp FAIL_76_0

TEST_76_3:
        mov ax,0FFFF
        mov bx,00001
        add ax,bx       ; CF=1  ZF=1  - Yes Jump
        jbe TEST_77_0

FAIL_76_0:
        mov dx,00036    ; Print a 6
        mov ax,00202
        int 021


; 0x77 - JNBE SHORT LABEL
; ############################################################

TEST_77_0:
        mov ax,01234
        mov bx,00001
        sub ax,bx       ; CF=0  ZF=0  - Yes Jump
        jnbe TEST_77_1
        jmp FAIL_77_0

TEST_77_1:
        mov ax,0FFFF
        mov bx,0000F
        add ax,bx       ; CF=1  ZF=0  - Dont Jump
        jnbe FAIL_77_0
        jmp  TEST_77_2

TEST_77_2:
        mov ax,00004
        mov bx,00004
        sub ax,bx       ; CF=0  ZF=1  - Dont Jump
        jnbe FAIL_77_0

TEST_77_3:
        mov ax,0FFFF
        mov bx,00001
        add ax,bx       ; CF=1  ZF=1  - Dont Jump
        jnbe FAIL_77_0
        jmp  TEST_78_0

FAIL_77_0:
        mov dx,00037    ; Print a 7
        mov ax,00202
        int 021


; 0x78 - JS SHORT LABEL
; ############################################################

TEST_78_0:
        mov ax,07FFF
        mov bx,00001
        add ax,bx       ; Sign flag should be set
        js  TEST_78_1
        jmp FAIL_78_0

TEST_78_1:
        mov ax,00001
        mov bx,00001
        add ax,bx       ; Sign Flag should NOT be set
        js  FAIL_78_0
        jmp TEST_79_0

FAIL_78_0:
        mov dx,00038    ; Print a 8
        mov ax,00202
        int 021


; 0x79 - JNS SHORT LABEL
; ############################################################

TEST_79_0:
        mov ax,00001
        mov bx,00001
        add ax,bx       ; Sign flag should NOT be set
        jns TEST_79_1
        jmp FAIL_79_0

TEST_79_1:
        mov ax,07FFF
        mov bx,00001
        add ax,bx       ; Sign Flag should be set
        jns FAIL_79_0
        jmp TEST_7A_0

FAIL_79_0:
        mov dx,00039    ; Print a 9
        mov ax,00202
        int 021

; 0x7A - JP SHORT LABEL
; ############################################################

TEST_7A_0:
        mov ax,04444
        mov bx,00011
        sub ax,bx       ; Parity flag should be set
        jp  TEST_7A_1
        jmp FAIL_7A_0

TEST_7A_1:
        mov ax,04444
        mov bx,00010
        add ax,bx       ; Parity Flag should NOT be set
        jp  FAIL_7A_0
        jmp TEST_7B_0

FAIL_7A_0:
        mov dx,00041    ; Print a A
        mov ax,00202
        int 021


; 0x7B - JNP SHORT LABEL
; ############################################################

TEST_7B_0:
        mov ax,04444
        mov bx,01110
        add ax,bx       ; Parity flag should NOT be set
        jnp TEST_7B_1
        jmp FAIL_7B_0

TEST_7B_1:
        mov ax,04444
        mov bx,01111
        add ax,bx       ; Parity Flag should be set
        jnp FAIL_7B_0
        jmp TEST_7C_0

FAIL_7B_0:
        mov dx,00042    ; Print a B
        mov ax,00202
        int 021




; 0x7C - JL SHORT LABEL
; ############################################################

TEST_7C_0:
        mov ax,08000
        mov bx,00001
        sub ax,bx       ; SF=0, OV=1 - (SF != OV)  - Yes Jump
        jl TEST_7C_1
        jmp FAIL_7C_0

TEST_7C_1:
        mov ax,08000
        mov bx,00001
        add ax,bx       ; SF=1, OV=0 - (SF != OV)  - Yes Jump
        jl TEST_7C_2
        jmp FAIL_7C_0

TEST_7C_2:
        mov ax,00005
        mov bx,00001
        add ax,bx       ; SF=0, OV=0 - (SF = OV)  - NO Jump
        jl  FAIL_7C_0

TEST_7C_3:
        mov ax,07FFF
        mov bx,00001
        add ax,bx       ; SF=1, OV=1 - (SF = OV)  - NO Jump
        jl  FAIL_7C_0
        jmp TEST_7D_0


FAIL_7C_0:
        mov dx,00043    ; Print a C
        mov ax,00202
        int 021


; 0x7D - JNL SHORT LABEL
; ############################################################

TEST_7D_0:
        mov ax,00002
        mov bx,00001
        add ax,bx       ; SF=0, OV=0 - (SF = OV)  - Yes Jump
        jnl TEST_7D_1
        jmp FAIL_7D_0

TEST_7D_1:
        mov ax,08000
        mov bx,00001
        sub ax,bx       ; SF=0, OV=1 - (SF != OV)  - NO Jump
        jnl FAIL_7D_0

TEST_7D_2:
        mov ax,08000
        mov bx,00001
        add ax,bx       ; SF=1, OV=0 - (SF != OV)  - NO Jump
        jnl  FAIL_7D_0

TEST_7D_3:
        mov ax,07FFF
        mov bx,00001
        add ax,bx       ; SF=1, OV=1 - (SF = OV)  - Yes Jump
        jnl TEST_7E_0


FAIL_7D_0:
        mov dx,00044    ; Print a D
        mov ax,00202
        int 021


; 0x7E - JLE SHORT LABEL
; ############################################################

TEST_7E_0:
        mov ax,00002
        mov bx,00001
        add ax,bx       ; SF=0, OV=0, ZF=0  - No Jump
        jle FAIL_7E_0

TEST_7E_1:
        mov ax,00002
        mov bx,00002
        sub ax,bx       ; SF=0, OV=0, ZF=1  - Yes Jump
        jle TEST_7E_2
        jmp FAIL_7E_0

TEST_7E_2:
        mov ax,08000
        mov bx,00001
        sub ax,bx       ; SF=0, OV=1, ZF=0  - Yes Jump
        jle TEST_7E_3
        jmp FAIL_7E_0

TEST_7E_3:
        mov ax,0FFFF
        mov bx,0FFFF
        sub ax,bx       ; SF=0, OV=1, ZF=1  - Yes Jump
        jle TEST_7E_4
        jmp FAIL_7E_0

TEST_7E_4:
        mov ax,08000
        mov bx,00001
        add ax,bx       ; SF=1, OV=0, ZF=0  - Yes Jump
        jle TEST_7E_6
        jmp FAIL_7E_0

TEST_7E_6:
        mov ax,07FFF
        mov bx,00001
        add ax,bx       ; SF=1, OV=1, ZF=0  - No Jump
        jle FAIL_7E_0
        jmp TEST_7F_0


FAIL_7E_0:
        mov dx,00045    ; Print a E
        mov ax,00202
        int 021


; 0x7F - JNLE SHORT LABEL
; ############################################################

TEST_7F_0:
        mov ax,00002
        mov bx,00001
        add ax,bx       ; SF=0, OV=0, ZF=0  - Yes Jump
        jnle TEST_7F_1
        jmp FAIL_7F_0

TEST_7F_1:
        mov ax,00002
        mov bx,00002
        sub ax,bx       ; SF=0, OV=0, ZF=1  - No Jump
        jnle FAIL_7F_0

TEST_7F_2 :
        mov ax,08000
        mov bx,00001
        sub ax,bx       ; SF=0, OV=1, ZF=0  - No Jump
        jnle FAIL_7F_0

TEST_7F_3:
        mov ax,0FFFF
        mov bx,0FFFF
        sub ax,bx       ; SF=0, OV=1, ZF=1  - No Jump
        jnle FAIL_7F_0

TEST_7F_4:
        mov ax,08000
        mov bx,00001
        add ax,bx       ; SF=1, OV=0, ZF=0  - No Jump
        jnle FAIL_7F_0

TEST_7F_6:
        mov ax,07FFF
        mov bx,00001
        add ax,bx       ; SF=1, OV=1, ZF=0  - Yes Jump
        jnle Z_END
        jmp FAIL_7F_0


FAIL_7F_0:
        mov dx,00046    ; Print a F
        mov ax,00202
        int 021


; xxxxxxxxxxxxxxxxxxxxxxx
; End
; xxxxxxxxxxxxxxxxxxxxxxx
Z_END:
        mov ax,00000    ; DOS Command=Exit
        int 021




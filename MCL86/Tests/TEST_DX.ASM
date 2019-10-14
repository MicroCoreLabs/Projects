; Tests for opcode range 0xD0-0xDF
; ---------------------------------
                   
; 0xD0 - 8-Bit Shifts and Rotate Opcodes
; ############################################################

TEST_D0_0:

        ; ROL
        ; Test against Register

        mov ax,0817F
        rol al,1
        cmp ax,081FE
        jne FAIL_D0_0   ; Only lower byte should be rotated

        mov bx,0817F
        rol bl,1
        jc FAIL_D0_0    ; Carry should not be set

        mov cx,08180
        rol cl,1
        cmp cx,08101
        jne FAIL_D0_0   ; Only lower byte should be rotated

        mov dx,08180
        rol dl,1
        jnc FAIL_D0_0   ; Carry should be set

        mov dx,08180
        rol dl,1
        jno FAIL_D0_0   ; Overflow should be set

        mov dx,081FF
        rol dl,1
        jo FAIL_D0_0   ; Overflow should NOT be set


        ; ROL
        ; Test against Memory

        mov word[00050],0817F
        rol byte[00050],1
        cmp word[00050],081FE
        jne FAIL_D0_0   ; Only lower byte should be rotated

        mov word[00050],0817F
        rol byte[00050],1
        jc FAIL_D0_0    ; Carry should not be set

        mov word[00050],08180
        rol byte[00050],1
        cmp word[00050],08101
        jne FAIL_D0_0   ; Only lower byte should be rotated

        mov word[00050],08180
        rol byte[00050],1
        jnc FAIL_D0_0   ; Carry should be set

        mov word[00050],08180
        rol byte[00050],1
        jno FAIL_D0_0   ; Overflow should be set

        mov word[00050],081FF
        rol byte[00050],1
        jo FAIL_D0_0   ; Overflow should NOT be set


        jmp TEST_D0_1


FAIL_D0_0:
        mov dx,00030    ; Print a 0
        mov ax,00202
        int 021


TEST_D0_1:
        ; ROR
        ; Test against Register

        mov ax,081FE
        ror al,1
        cmp ax,0817F
        jne FAIL_D0_1   ; Only lower byte should be rotated

        mov bx,081FE
        ror bl,1
        jc FAIL_D0_1    ; Carry should not be set

        mov cx,0813F
        ror cl,1
        cmp cx,0819F
        jne FAIL_D0_1   ; Only lower byte should be rotated

        mov dx,0812F
        ror dl,1
        jnc FAIL_D0_1   ; Carry should be set

        mov dx,08180
        ror dl,1
        jno FAIL_D0_1   ; Overflow should be set

        mov dx,081FF
        ror dl,1
        jo FAIL_D0_1   ; Overflow should NOT be set

        ; ROR
        ; Test against Memory

        mov word[00050],081FE
        ror byte[00050],1
        cmp word[00050],0817F
        jne FAIL_D0_1   ; Only lower byte should be rotated

        mov word[00050],0813E
        ror byte[00050],1
        jc FAIL_D0_1    ; Carry should not be set

        mov word[00050],0813F
        ror byte[00050],1
        cmp word[00050],0819F
        jne FAIL_D0_1   ; Only lower byte should be rotated

        mov word[00050],0812F
        ror byte[00050],1
        jnc FAIL_D0_1   ; Carry should be set


        mov word[00050],08180
        ror byte[00050],1
        jno FAIL_D0_1   ; Overflow should be set

        mov word[00050],081FF
        ror byte[00050],1
        jo FAIL_D0_1   ; Overflow should NOT be set

        jmp TEST_D0_2

FAIL_D0_1:
        mov dx,00030    ; Print a 0
        mov ax,00202
        int 021



TEST_D0_2:

        ; RCL
        ; Test against Register

        clc
        mov ax,0817F
        rcl al,1
        cmp ax,081FE
        jne FAIL_D0_2   ; Only lower byte should be rotated

        clc
        mov cx,08180
        rcl cl,1
        cmp cx,08100
        jne FAIL_D0_2   ; Only lower byte should be rotated

        stc
        mov ax,0817F
        rcl al,1
        cmp ax,081FF
        jne FAIL_D0_2   ; Only lower byte should be rotated

        stc
        mov cx,08180
        rcl cl,1
        cmp cx,08101
        jne FAIL_D0_2   ; Only lower byte should be rotated

        clc
        mov bx,0817F
        rcl bl,1
        jc FAIL_D0_2    ; Carry should not be set

        clc
        mov dx,08180
        rcl dl,1
        jnc FAIL_D0_2   ; Carry should be set

        mov dx,08180
        rcl dl,1
        jno FAIL_D0_2   ; Overflow should be set

        mov dx,081FF
        rcl dl,1
        jo FAIL_D0_2   ; Overflow should NOT be set
        jmp TEST_D0_22


FAIL_D0_2:
        mov dx,00039    ; Print a 0
        mov ax,00202
        int 021


TEST_D0_22:
        ; RCL
        ; Test against Memory

        clc
        mov word[00050],0817F
        rcl byte[00050],1
        cmp word[00050],081FE
        jne FAIL_D0_22   ; Only lower byte should be rotated

        clc
        mov word[00050],08180
        rcl byte[00050],1
        cmp word[00050],08100
        jne FAIL_D0_22   ; Only lower byte should be rotated

        stc
        mov word[00050],0817F
        rcl byte[00050],1
        cmp word[00050],081FF
        jne FAIL_D0_22   ; Only lower byte should be rotated

        stc
        mov word[00050],08180
        rcl byte[00050],1
        cmp word[00050],08101
        jne FAIL_D0_22   ; Only lower byte should be rotated

        mov word[00050],0817F
        rcl byte[00050],1
        jc FAIL_D0_22    ; Carry should not be set

        mov word[00050],08180
        rcl byte[00050],1
        jnc FAIL_D0_22   ; Carry should be set

        mov word[00050],08180
        rcl byte[00050],1
        jno FAIL_D0_22   ; Overflow should be set

        mov word[00050],081FF
        rcl byte[00050],1
        jo FAIL_D0_22   ; Overflow should NOT be set
        jmp TEST_D0_3


FAIL_D0_22:
        mov dx,00030    ; Print a 0
        mov ax,00202
        int 021



TEST_D0_3:

        ; RCR
        ; Test against Register

        clc
        mov ax,0817F
        rcr al,1
        cmp ax,0813F
        jne FAIL_D0_3   ; Only lower byte should be rotated

        clc
        mov cx,08180
        rcr cl,1
        cmp cx,08140
        jne FAIL_D0_3   ; Only lower byte should be rotated

        stc
        mov ax,08100
        rcr al,1
        cmp ax,08180
        jne FAIL_D0_3   ; Only lower byte should be rotated

        stc
        mov cx,08108
        rcr cl,1
        cmp cx,08184
        jne FAIL_D0_3   ; Only lower byte should be rotated

        clc
        mov bx,08110
        rcr bl,1
        jc FAIL_D0_3    ; Carry should not be set

        clc
        mov dx,08181
        rcr dl,1
        jnc FAIL_D0_3   ; Carry should be set

        stc
        mov dx,08100
        rcr dl,1
        jno FAIL_D0_3   ; Overflow should be set

        clc
        mov dx,08100
        rcr dl,1
        jo FAIL_D0_3   ; Overflow should NOT be set
        jmp TEST_D0_32


FAIL_D0_3:
        mov dx,00030    ; Print a 0
        mov ax,00202
        int 021


TEST_D0_32:
        ; RCR
        ; Test against Memory

        clc
        mov word[00050],0817F
        rcr byte[00050],1
        cmp word[00050],0813F
        jne FAIL_D0_32   ; Only lower byte should be rotated

        clc
        mov word[00050],08180
        rcr byte[00050],1
        cmp word[00050],08140
        jne FAIL_D0_32   ; Only lower byte should be rotated

        stc
        mov word[00050],08100
        rcr byte[00050],1
        cmp word[00050],08180
        jne FAIL_D0_32   ; Only lower byte should be rotated

        stc
        mov word[00050],08108
        rcr byte[00050],1
        cmp word[00050],08184
        jne FAIL_D0_32   ; Only lower byte should be rotated

        mov word[00050],08110
        rcr byte[00050],1
        jc FAIL_D0_32    ; Carry should not be set

        mov word[00050],08181
        rcr byte[00050],1
        jnc FAIL_D0_32   ; Carry should be set

        stc
        mov word[00050],08100
        rcr byte[00050],1
        jno FAIL_D0_32   ; Overflow should be set

        clc
        mov word[00050],08100
        rcr byte[00050],1
        jo FAIL_D0_32   ; Overflow should NOT be set
        jmp TEST_D0_4


FAIL_D0_32:
        mov dx,00030    ; Print a 0
        mov ax,00202
        int 021


TEST_D0_4:

        ; SAL
        ; Test against Register

        mov ax,08122
        sal al,1
        cmp ax,08144
        jne FAIL_D0_4   ; Only lower byte should be rotated

        mov bx,08122
        sal bl,1
        jc FAIL_D0_4    ; Carry should not be set

        mov cx,08188
        sal cl,1
        cmp cx,08110
        jne FAIL_D0_4   ; Only lower byte should be rotated

        mov dx,08180
        sal dl,1
        jnc FAIL_D0_4   ; Carry should be set

        mov dx,08180
        sal dl,1
        jno FAIL_D0_4   ; Overflow should be set

        mov dx,081FF
        sal dl,1
        jo FAIL_D0_4   ; Overflow should NOT be set


        ; SAL
        ; Test against Memory

        mov word[00050],08122
        sal byte[00050],1
        cmp word[00050],08144
        jne FAIL_D0_4   ; Only lower byte should be rotated

        mov word[00050],08122
        sal byte[00050],1
        jc FAIL_D0_4    ; Carry should not be set

        mov word[00050],08188
        sal byte[00050],1
        cmp word[00050],08110
        jne FAIL_D0_4   ; Only lower byte should be rotated

        mov word[00050],08180
        sal byte[00050],1
        jnc FAIL_D0_4   ; Carry should be set

        mov word[00050],08180
        sal byte[00050],1
        jno FAIL_D0_4   ; Overflow should be set

        mov word[00050],081FF
        sal byte[00050],1
        jo FAIL_D0_4   ; Overflow should NOT be set


        jmp TEST_D0_5


FAIL_D0_4:
        mov dx,00030    ; Print a 0
        mov ax,00202
        int 021


TEST_D0_5:
        ; SAR
        ; Test against Register

        mov ax,08180
        sar al,1
        cmp ax,081C0
        jne FAIL_D0_5   ; Only lower byte should be rotated

        mov bx,081FE
        sar bl,1
        jc FAIL_D0_5    ; Carry should not be set

        mov cx,0817F
        sar cl,1
        cmp cx,0813F
        jne FAIL_D0_5   ; Only lower byte should be rotated

        mov dx,0812F
        sar dl,1
        jnc FAIL_D0_5   ; Carry should be set

        mov dx,081FF
        sar dl,1
        jo FAIL_D0_5   ; Overflow should NOT be set

        ; SAR
        ; Test against Memory

        mov word[00050],08180
        sar byte[00050],1
        cmp word[00050],081C0
        jne FAIL_D0_5   ; Only lower byte should be rotated

        mov word[00050],081FE
        sar byte[00050],1
        jc FAIL_D0_5    ; Carry should not be set

        mov word[00050],0817F
        sar byte[00050],1
        cmp word[00050],0813F
        jne FAIL_D0_5   ; Only lower byte should be rotated

        mov word[00050],0812F
        sar byte[00050],1
        jnc FAIL_D0_5   ; Carry should be set

        mov word[00050],081FF
        sar byte[00050],1
        jo FAIL_D0_5   ; Overflow should NOT be set

        jmp TEST_D0_6

FAIL_D0_5:
        mov dx,00030    ; Print a 0
        mov ax,00202
        int 021



TEST_D0_6:
        ; SHR
        ; Test against Register

        mov ax,08180
        shr al,1
        cmp ax,08140
        jne FAIL_D0_6   ; Only lower byte should be rotated

        mov bx,081FE
        shr bl,1
        jc FAIL_D0_6    ; Carry should not be set

        mov cx,0817F
        shr cl,1
        cmp cx,0813F
        jne FAIL_D0_6   ; Only lower byte should be rotated

        mov dx,0812F
        shr dl,1
        jnc FAIL_D0_6   ; Carry should be set

        mov dx,081FF
        shr dl,1
        jno FAIL_D0_6   ; Overflow should be set

        mov dx,0812F
        shr dl,1
        jo FAIL_D0_6   ; Overflow should NOT be set


        ; SHR
        ; Test against Memory

        mov word[00050],08180
        shr byte[00050],1
        cmp word[00050],08140
        jne FAIL_D0_6   ; Only lower byte should be rotated

        mov word[00050],081FE
        shr byte[00050],1
        jc FAIL_D0_6    ; Carry should not be set

        mov word[00050],0817F
        shr byte[00050],1
        cmp word[00050],0813F
        jne FAIL_D0_6   ; Only lower byte should be rotated

        mov word[00050],0812F
        shr byte[00050],1
        jnc FAIL_D0_6   ; Carry should be set

        mov word[00050],081FF
        shr byte[00050],1
        jno FAIL_D0_6   ; Overflow should be set

        mov word[00050],0812F
        shr byte[00050],1
        jo FAIL_D0_6   ; Overflow should NOT be set

        jmp TEST_D1_0

FAIL_D0_6:
        mov dx,00030    ; Print a 0
        mov ax,00202
        int 021


                   
; 0xD1 - 16-Bit Shifts and Rotate Opcodes
; ############################################################

TEST_D1_0:

        ; ROL
        ; Test against Register

        mov ax,08000
        rol ax,1
        cmp ax,00001
        jne FAIL_D1_0

        mov bx,00022
        rol bx,1
        jc FAIL_D1_0    ; Carry should not be set

        mov cx,01111
        rol cx,1
        cmp cx,02222
        jne FAIL_D1_0

        mov dx,08180
        rol dx,1
        jnc FAIL_D1_0   ; Carry should be set

        mov dx,08180
        rol dx,1
        jno FAIL_D1_0   ; Overflow should be set

        mov dx,01234
        rol dx,1
        jo FAIL_D1_0   ; Overflow should NOT be set


        ; ROL
        ; Test against Memory

        mov word[00050],08000
        rol word[00050],1
        cmp word[00050],00001
        jne FAIL_D1_0

        mov word[00050],00022
        rol word[00050],1
        jc FAIL_D1_0    ; Carry should not be set

        mov word[00050],01111
        rol word[00050],1
        cmp word[00050],02222
        jne FAIL_D1_0

        mov word[00050],08180
        rol word[00050],1
        jnc FAIL_D1_0   ; Carry should be set

        mov word[00050],08180
        rol word[00050],1
        jno FAIL_D1_0   ; Overflow should be set

        mov word[00050],01234
        rol word[00050],1
        jo FAIL_D1_0   ; Overflow should NOT be set


        jmp TEST_D1_1


FAIL_D1_0:
        mov dx,00031    ; Print a 0
        mov ax,00202
        int 021


TEST_D1_1:
        ; ROR
        ; Test against Register

        mov ax,00001
        ror ax,1
        cmp ax,08000
        jne FAIL_D1_1

        mov bx,02222
        ror bx,1
        jc FAIL_D1_1    ; Carry should not be set

        mov cx,04444
        ror cx,1
        cmp cx,02222
        jne FAIL_D1_1

        mov dx,01111
        ror dx,1
        jnc FAIL_D1_1   ; Carry should be set

        mov dx,08180
        ror dx,1
        jno FAIL_D1_1   ; Overflow should be set

        mov dx,02222
        ror dx,1
        jo FAIL_D1_1   ; Overflow should NOT be set

        ; ROR
        ; Test against Memory

        mov word[00050],00001
        ror word[00050],1
        cmp word[00050],08000
        jne FAIL_D1_1

        mov word[00050],02222
        ror word[00050],1
        jc FAIL_D1_1    ; Carry should not be set

        mov word[00050],04444
        ror word[00050],1
        cmp word[00050],02222
        jne FAIL_D1_1

        mov word[00050],01111
        ror word[00050],1
        jnc FAIL_D1_1   ; Carry should be set


        mov word[00050],08180
        ror word[00050],1
        jno FAIL_D1_1   ; Overflow should be set

        mov word[00050],02222
        ror word[00050],1
        jo FAIL_D1_1   ; Overflow should NOT be set

        jmp TEST_D1_2

FAIL_D1_1:
        mov dx,00031    ; Print a 0
        mov ax,00202
        int 021



TEST_D1_2:

        ; RCL
        ; Test against Register

        clc
        mov ax,0817F
        rcl ax,1
        cmp ax,002FE
        jne FAIL_D1_2

        clc
        mov cx,01111
        rcl cx,1
        cmp cx,02222
        jne FAIL_D1_2

        stc
        mov ax,0817F
        rcl ax,1
        cmp ax,002FF
        jne FAIL_D1_2

        stc
        mov cx,01111
        rcl cx,1
        cmp cx,02223
        jne FAIL_D1_2

        clc
        mov bx,07777
        rcl bx,1
        jc FAIL_D1_2    ; Carry should not be set

        clc
        mov dx,08888
        rcl dx,1
        jnc FAIL_D1_2   ; Carry should be set

        mov dx,08000
        rcl dx,1
        jno FAIL_D1_2   ; Overflow should be set

        mov dx,0FFFF
        rcl dx,1
        jo FAIL_D1_2   ; Overflow should NOT be set
        jmp TEST_D1_22


FAIL_D1_2:
        mov dx,00039    ; Print a 0
        mov ax,00202
        int 021


TEST_D1_22:
        ; RCL
        ; Test against Memory

        clc
        mov word[00050],0817F
        rcl word[00050],1
        cmp word[00050],002FE
        jne FAIL_D1_22

        clc
        mov word[00050],01111
        rcl word[00050],1
        cmp word[00050],02222
        jne FAIL_D1_22

        stc
        mov word[00050],0817F
        rcl word[00050],1
        cmp word[00050],002FF
        jne FAIL_D1_22

        stc
        mov word[00050],01111
        rcl word[00050],1
        cmp word[00050],02223
        jne FAIL_D1_22

        mov word[00050],07777
        rcl word[00050],1
        jc FAIL_D1_22    ; Carry should not be set

        mov word[00050],08888
        rcl word[00050],1
        jnc FAIL_D1_22   ; Carry should be set

        mov word[00050],08000
        rcl word[00050],1
        jno FAIL_D1_22   ; Overflow should be set

        mov word[00050],0FFFF
        rcl word[00050],1
        jo FAIL_D1_22   ; Overflow should NOT be set
        jmp TEST_D1_3


FAIL_D1_22:
        mov dx,00031    ; Print a 0
        mov ax,00202
        int 021



TEST_D1_3:

        ; RCR
        ; Test against Register

        clc
        mov ax,0447F
        rcr ax,1
        cmp ax,0223F
        jne FAIL_D1_3

        clc
        mov cx,01111
        rcr cx,1
        cmp cx,00888
        jne FAIL_D1_3

        stc
        mov ax,00001
        rcr ax,1
        cmp ax,08000
        jne FAIL_D1_3

        stc
        mov cx,08000
        rcr cx,1
        cmp cx,0C000
        jne FAIL_D1_3

        clc
        mov bx,08110
        rcr bx,1
        jc FAIL_D1_3    ; Carry should not be set

        clc
        mov dx,08181
        rcr dx,1
        jnc FAIL_D1_3   ; Carry should be set

        stc
        mov dx,00F00
        rcr dx,1
        jno FAIL_D1_3   ; Overflow should be set

        clc
        mov dx,00000
        rcr dx,1
        jo FAIL_D1_3   ; Overflow should NOT be set
        jmp TEST_D1_32


FAIL_D1_3:
        mov dx,00031    ; Print a 0
        mov ax,00202
        int 021


TEST_D1_32:
        ; RCR
        ; Test against Memory

        clc
        mov word[00050],0447F
        rcr word[00050],1
        cmp word[00050],0223F
        jne FAIL_D1_32

        clc
        mov word[00050],01111
        rcr word[00050],1
        cmp word[00050],00888
        jne FAIL_D1_32

        stc
        mov word[00050],00001
        rcr word[00050],1
        cmp word[00050],08000
        jne FAIL_D1_32

        stc
        mov word[00050],08000
        rcr word[00050],1
        cmp word[00050],0C000
        jne FAIL_D1_32

        mov word[00050],08110
        rcr word[00050],1
        jc FAIL_D1_32    ; Carry should not be set

        mov word[00050],08181
        rcr word[00050],1
        jnc FAIL_D1_32   ; Carry should be set

        stc
        mov word[00050],00F00
        rcr word[00050],1
        jno FAIL_D1_32   ; Overflow should be set

        clc
        mov word[00050],00000
        rcr word[00050],1
        jo FAIL_D1_32   ; Overflow should NOT be set
        jmp TEST_D1_4


FAIL_D1_32:
        mov dx,00031    ; Print a 0
        mov ax,00202
        int 021


TEST_D1_4:

        ; SAL
        ; Test against Register

        mov ax,07FFF
        sal ax,1
        cmp ax,0FFFE
        jne FAIL_D1_4

        mov bx,02222
        sal bx,1
        jc FAIL_D1_4    ; Carry should not be set

        mov cx,00001
        sal cx,1
        cmp cx,00002
        jne FAIL_D1_4

        mov dx,08000
        sal dx,1
        jnc FAIL_D1_4   ; Carry should be set

        mov dx,08180
        sal dx,1
        jno FAIL_D1_4   ; Overflow should be set

        mov dx,0FFFF
        sal dx,1
        jo FAIL_D1_4   ; Overflow should NOT be set


        ; SAL
        ; Test against Memory

        mov word[00050],07FFF
        sal word[00050],1
        cmp word[00050],0FFFE
        jne FAIL_D1_4

        mov word[00050],02222
        sal word[00050],1
        jc FAIL_D1_4    ; Carry should not be set

        mov word[00050],00001
        sal word[00050],1
        cmp word[00050],00002
        jne FAIL_D1_4

        mov word[00050],08000
        sal word[00050],1
        jnc FAIL_D1_4   ; Carry should be set

        mov word[00050],08180
        sal word[00050],1
        jno FAIL_D1_4   ; Overflow should be set

        mov word[00050],0FFFF
        sal word[00050],1
        jo FAIL_D1_4   ; Overflow should NOT be set


        jmp TEST_D1_5


FAIL_D1_4:
        mov dx,00031    ; Print a 0
        mov ax,00202
        int 021


TEST_D1_5:
        ; SAR
        ; Test against Register

        mov ax,08000
        sar ax,1
        cmp ax,0C000
        jne FAIL_D1_5

        mov bx,04444
        sar bx,1
        jc FAIL_D1_5    ; Carry should not be set

        mov cx,00001
        sar cx,1
        cmp cx,00000
        jne FAIL_D1_5

        mov dx,00001
        sar dx,1
        jnc FAIL_D1_5   ; Carry should be set

        mov dx,081FF
        sar dx,1
        jo FAIL_D1_5   ; Overflow should NOT be set

        ; SAR
        ; Test against Memory

        mov word[00050],08000
        sar word[00050],1
        cmp word[00050],0C000
        jne FAIL_D1_5

        mov word[00050],04444
        sar word[00050],1
        jc FAIL_D1_5    ; Carry should not be set

        mov word[00050],00001
        sar word[00050],1
        cmp word[00050],00000
        jne FAIL_D1_5

        mov word[00050],00001
        sar word[00050],1
        jnc FAIL_D1_5   ; Carry should be set

        mov word[00050],081FF
        sar word[00050],1
        jo FAIL_D1_5   ; Overflow should NOT be set

        jmp TEST_D1_6

FAIL_D1_5:
        mov dx,00031    ; Print a 0
        mov ax,00202
        int 021



TEST_D1_6:
        ; SHR
        ; Test against Register

        mov ax,0FFFF
        shr ax,1
        cmp ax,07FFF
        jne FAIL_D1_6

        mov bx,04444
        shr bx,1
        jc FAIL_D1_6    ; Carry should not be set

        mov cx,04444
        shr cx,1
        cmp cx,02222
        jne FAIL_D1_6

        mov dx,00001
        shr dx,1
        jnc FAIL_D1_6   ; Carry should be set

        mov dx,081FF
        shr dx,1
        jno FAIL_D1_6   ; Overflow should be set

        mov dx,00000
        shr dx,1
        jo FAIL_D1_6   ; Overflow should NOT be set


        ; SHR
        ; Test against Memory

        mov word[00050],0FFFF
        shr word[00050],1
        cmp word[00050],07FFF
        jne FAIL_D1_6

        mov word[00050],04444
        shr word[00050],1
        jc FAIL_D1_6    ; Carry should not be set

        mov word[00050],04444
        shr word[00050],1
        cmp word[00050],02222
        jne FAIL_D1_6

        mov word[00050],00001
        shr word[00050],1
        jnc FAIL_D1_6   ; Carry should be set

        mov word[00050],081FF
        shr word[00050],1
        jno FAIL_D1_6   ; Overflow should be set

        mov word[00050],00000
        shr word[00050],1
        jo FAIL_D1_6   ; Overflow should NOT be set

        jmp TEST_D2_0

FAIL_D1_6:
        mov dx,00031    ; Print a 0
        mov ax,00202
        int 021


                   
; 0xD2 - 8-Bit Shifts and Rotate Opcodes with CL
; ############################################################

TEST_D2_0:
        ; ROL, cl  -  Test against Register and Memory
        mov ax,0004A
        mov word[00050],00001
        mov cx,0000F
        mov bx,00000
        mov dx,00000
        cli

L_D2_0:                 ; Do 16 shifts of 16 different cl's
        rol al,cl       ; and add up all results into dx and bx
        rol byte[00050],cl
        add dx,ax
        add bx,word[00050]
        loop L_D2_0
        sti
        cmp dx,005B0    ; Final result of additions of all shifts
        jne FAIL_D2_0
        cmp bx,001FD
        jne FAIL_D2_0
        jmp TEST_D2_1

FAIL_D2_0:
        mov dx,00032    ; Print a 2
        mov ax,00202
        int 021


TEST_D2_1:
        ; ROR, cl  -  Test against Register and Memory
        mov ax,00084
        mov word[00050],00005
        mov cx,0000F
        mov bx,00000
        mov dx,00000
        cli

L_D2_1:                 ; Do 16 shifts of 16 different cl's
        ror al,cl       ; and add up all results into dx and bx
        ror byte[00050],cl
        add dx,ax
        add bx,word[00050]
        loop L_D2_1
        sti
        cmp dx,00378    ; Final result of additions of all shifts
        jne FAIL_D2_1
        cmp bx,003F7
        jne FAIL_D2_1
        jmp TEST_D2_2

FAIL_D2_1:
        mov dx,00032    ; Print a 2
        mov ax,00202
        int 021


TEST_D2_2:
        ; RCL, cl  -  Test against Register and Memory
        mov ax,00099
        mov word[00050],00006
        mov cx,0000F
        mov bx,00000
        mov dx,00000
        cli

L_D2_2:                 ; Do 16 shifts of 16 different cl's
        rcl al,cl       ; and add up all results into dx and bx
        rcl byte[00050],cl
        add dx,ax
        add bx,word[00050]
        loop L_D2_2
        sti
        cmp dx,0076E    ; Final result of additions of all shifts
        jne FAIL_D2_2
        cmp bx,0025E
        jne FAIL_D2_2
        jmp TEST_D2_3

FAIL_D2_2:
        mov dx,00032    ; Print a 2
        mov ax,00202
        int 021


TEST_D2_3:
        ; RCR, cl  -  Test against Register and Memory
        mov ax,00083
        mov word[00050],00012
        mov cx,0000F
        mov bx,00000
        mov dx,00000
        cli

L_D2_3:                 ; Do 16 shifts of 16 different cl's
        rcr al,cl       ; and add up all results into dx and bx
        rcr byte[00050],cl
        add dx,ax
        add bx,word[00050]
        loop L_D2_3
        sti
        cmp dx,005CB    ; Final result of additions of all shifts
        jne FAIL_D2_3
        cmp bx,00262
        jne FAIL_D2_3
        jmp TEST_D2_4

FAIL_D2_3:
        mov dx,00032    ; Print a 2
        mov ax,00202
        int 021


TEST_D2_4:
        ; SAL, cl  -  Test against Register and Memory
        mov ax,00099
        mov word[00050],00006
        mov cx,00003
        mov bx,00000
        mov dx,00000
        cli

L_D2_4:                 ; Do 16 shifts of 16 different cl's
        sal al,cl       ; and add up all results into dx and bx
        sal byte[00050],cl
        add dx,ax
        add bx,word[00050]
        loop L_D2_4
        sti
        cmp dx,00128    ; Final result of additions of all shifts
        jne FAIL_D2_4
        cmp bx,00170
        jne FAIL_D2_4
        jmp TEST_D2_5

FAIL_D2_4:
        mov dx,00032    ; Print a 2
        mov ax,00202
        int 021


TEST_D2_5:
        ; SHR, cl  -  Test against Register and Memory
        mov ax,00083
        mov word[00050],00012
        mov cx,00003
        mov bx,00000
        mov dx,00000
        cli

L_D2_5:                 ; Do 16 shifts of 16 different cl's
        shr al,cl       ; and add up all results into dx and bx
        shr byte[00050],cl
        add dx,ax
        add bx,word[00050]
        loop L_D2_5
        sti
        cmp dx,00016    ; Final result of additions of all shifts
        jne FAIL_D2_5
        cmp bx,00002
        jne FAIL_D2_5
        jmp TEST_D2_6

FAIL_D2_5:
        mov dx,00032    ; Print a 2
        mov ax,00202
        int 021


TEST_D2_6:
        ; SAR, cl  -  Test against Register and Memory
        mov ax,00083
        mov word[00050],00012
        mov cx,00003
        mov bx,00000
        mov dx,00000
        cli

L_D2_6:                 ; Do 16 shifts of 16 different cl's
        sar al,cl       ; and add up all results into dx and bx
        sar byte[00050],cl
        add dx,ax
        add bx,word[00050]
        loop L_D2_6
        sti
        cmp dx,002EA    ; Final result of additions of all shifts
        jne FAIL_D2_6
        cmp bx,00002
        jne FAIL_D2_6
        jmp TEST_D3_0

FAIL_D2_6:
        mov dx,00032    ; Print a 2
        mov ax,00202
        int 021


; 0xD3 - 16-Bit Shifts and Rotate Opcodes with CL
; ############################################################

TEST_D3_0:
        ; ROL, cl  -  Test against Register and Memory
        mov ax,01234
        mov word[00050],01234
        mov cx,0000F
        mov bx,00000
        mov dx,00000
        cli

L_D3_0:                 ; Do 16 shifts of 16 different cl's
        rol ax,cl       ; and add up all results into dx and bx
        rol word[00050],cl
        add dx,ax
        add bx,word[00050]
        loop L_D3_0
        sti
        cmp dx,0EDC7    ; Final result of additions of all shifts
        jne FAIL_D3_0
        cmp bx,0EDC7
        jne FAIL_D3_0
        jmp TEST_D3_1

FAIL_D3_0:
        mov dx,00033    ; Print a 3
        mov ax,00202
        int 021


TEST_D3_1:
        ; ROR, cl  -  Test against Register and Memory
        mov ax,05678
        mov word[00050],05678
        mov cx,0000F
        mov bx,00000
        mov dx,00000
        cli

L_D3_1:                 ; Do 16 shifts of 16 different cl's
        ror ax,cl       ; and add up all results into dx and bx
        ror word[00050],cl
        add dx,ax
        add bx,word[00050]
        loop L_D3_1
        sti
        cmp dx,0A980    ; Final result of additions of all shifts
        jne FAIL_D3_1
        cmp bx,0A980
        jne FAIL_D3_1
        jmp TEST_D3_2

FAIL_D3_1:
        mov dx,00033    ; Print a 3
        mov ax,00202
        int 021


TEST_D3_2:
        ; RCL, cl  -  Test against Register and Memory
        mov ax,09999
        mov word[00050],09999
        mov cx,0000F
        mov bx,00000
        mov dx,00000
        cli
        clc

L_D3_2:                 ; Do 16 shifts of 16 different cl's
        rcl ax,cl       ; and add up all results into dx and bx
        rcl word[00050],cl
        add dx,ax
        add bx,word[00050]
        loop L_D3_2
        sti
        cmp dx,0EB59    ; Final result of additions of all shifts
        jne FAIL_D3_2
        cmp bx,05B7A
        jne FAIL_D3_2
        jmp TEST_D3_3

FAIL_D3_2:
        mov dx,00033    ; Print a 3
        mov ax,00202
        int 021


TEST_D3_3:
        ; RCR, cl  -  Test against Register and Memory
        mov ax,02112
        mov word[00050],02112
        mov cx,0000F
        mov bx,00000
        mov dx,00000
        clc
        cli

L_D3_3:                 ; Do 16 shifts of 16 different cl's
        rcr ax,cl       ; and add up all results into dx and bx
        rcr word[00050],cl
        add dx,ax
        add bx,word[00050]
        loop L_D3_3
        sti
        cmp dx,0CA0B    ; Final result of additions of all shifts
        jne FAIL_D3_3
        cmp bx,092C5
        jne FAIL_D3_3
        jmp TEST_D3_4

FAIL_D3_3:
        mov dx,00033    ; Print a 3
        mov ax,00202
        int 021


TEST_D3_4:
        ; SAL, cl  -  Test against Register and Memory
        mov ax,01414
        mov word[00050],01414
        mov cx,00003
        mov bx,00000
        mov dx,00000
        cli

L_D3_4:                 ; Do 16 shifts of 16 different cl's
        sal ax,cl       ; and add up all results into dx and bx
        sal word[00050],cl
        add dx,ax
        add bx,word[00050]
        loop L_D3_4
        sti
        cmp dx,02820    ; Final result of additions of all shifts
        jne FAIL_D3_4
        cmp bx,02820
        jne FAIL_D3_4
        jmp TEST_D3_5

FAIL_D3_4:
        mov dx,00033    ; Print a 3
        mov ax,00202
        int 021


TEST_D3_5:
        ; SHR, cl  -  Test against Register and Memory
        mov ax,02345
        mov word[00050],02345
        mov cx,00003
        mov bx,00000
        mov dx,00000
        cli

L_D3_5:                 ; Do 16 shifts of 16 different cl's
        shr ax,cl       ; and add up all results into dx and bx
        shr word[00050],cl
        add dx,ax
        add bx,word[00050]
        loop L_D3_5
        sti
        cmp dx,0060F    ; Final result of additions of all shifts
        jne FAIL_D3_5
        cmp bx,0060F
        jne FAIL_D3_5
        jmp TEST_D3_6

FAIL_D3_5:
        mov dx,00033     ; Print a 3
        mov ax,00202
        int 021


TEST_D3_6:
        ; SAR, cl  -  Test against Register and Memory
        mov ax,09090
        mov word[00050],09090
        mov cx,00003
        mov bx,00000
        mov dx,00000
        cli

L_D3_6:                 ; Do 16 shifts of 16 different cl's
        sar ax,cl       ; and add up all results into dx and bx
        sar word[00050],cl
        add dx,ax
        add bx,word[00050]
        loop L_D3_6
        sti
        cmp dx,0ECD8    ; Final result of additions of all shifts
        jne FAIL_D3_6
        cmp bx,0ECD8
        jne FAIL_D3_6
        jmp TEST_D4_0

FAIL_D3_6:
        mov dx,00033    ; Print a 3
        mov ax,00202
        int 021


; 0xD4 - AAM
; ############################################################

TEST_D4_0:
        mov ax,0000
        mov dx,0000
        mov cx,00FF

L_D4:   AAM
        add dx,ax
        inc al
        loop L_D4

        cmp dx,01D6F
        jne FAIL_D4_0
        jmp TEST_D5_0

FAIL_D4_0:
        mov dx,00034    ; Print a 4
        mov ax,00202
        int 021



; 0xD5 - AAD
; ############################################################

TEST_D5_0:
        mov ax,00000
        mov dx,00000
        mov cx,0FFFF

L_D5:   AAD
        add dx,ax
        inc al
        loop L_D5

        cmp dx,07F01
        jne FAIL_D5_0
        jmp TEST_D7_0

FAIL_D5_0:
        mov dx,00035    ; Print a 5
        mov ax,00202
        int 021



; 0xD7 - XLAT
; ############################################################

TEST_D7_0:
        mov byte [07788], 05A
        mov bx,07777
        mov ax,03311
        xlat
        cmp al,05A
        jne FAIL_D7_0
        jmp TEST_D7_1

TEST_D7_1:
        mov byte ss:[04455], 0AB
        mov bx,04444
        mov ax,03311
        ss: xlat
        cmp al,0AB
        jne FAIL_D7_0
        jmp TEST_D8_0

FAIL_D7_0:
        mov dx,00037    ; Print a 7
        mov ax,00202
        int 021


; 0xD8-0xDF - ESC
; ############################################################

TEST_D8_0:
;        esc [bx]
;        esc [bx+si]
;        esc [01234]


; xxxxxxxxxxxxxxxxxxxxxxx
; End
; xxxxxxxxxxxxxxxxxxxxxxx
Z_END:
        mov ax,00000    ; DOS Command=Exit
        int 021




; Tests for opcode range 0x83 with second word=0x0-0x7
; These tests are for MEM16,IMM16
; ----------------------------------------------------

        mov ax,es       ; Increment ES so it is not the same as DS
        inc ax
        mov es,ax


; 0x83 - ADD MEM16,IMM16
; ############################################################

TEST_83_0_0:             ; Test from Memory

        mov word [00050],01234
        lock add word [00050],0FFFF     ; test lock prefix
        cmp word [00050],01233
        jne FAIL_83_0_0

        mov word [00050],01234
        add word [00050],00000
        cmp word [00050],01234
        jne FAIL_83_0_0

        mov word es:[00052],00001 ; test segment override
        add word es:[00052],00002
        cmp word es:[00052],00003
        jne FAIL_83_0_0
        jmp TEST_83_0_1

FAIL_83_0_0:
        mov dx,00030    ; Print a 0
        mov ax,00202
        int 021


TEST_83_0_1:              ; ADD MEM16,IMM16 - Test flags
                        ; Overflow, Sign, Zero, Parity, AUX, Carry

        mov word [00054],07FFF
        add word [00054],00001  ; Overflow should be set
        jno FAIL_83_0_1   ; If not set, then fail

        mov word [00055],01234
        add word [00055],00022  ; Overflow should NOT be set
        jno PASS_83_0_1   ; If not set, then we passed
        jmp FAIL_83_0_1   ; If set then we fail

PASS_83_0_1:
        mov word [00056],07FFF
        add word[00056],00034  ; sign should be set
        jns FAIL_83_0_1   ; If not set, then fail

        mov word [00057],01111
        add word [00057],00022  ; sign should NOT be set
        js  FAIL_83_0_1   ; If set then we fail

        mov word [00058],00000
        add word [00058],00000  ; zero should be set
        jne FAIL_83_0_1   ; If not set then we fail
        jmp TEST_83_2_0

FAIL_83_0_1:
        mov dx,00030    ; Print a 0
        mov ax,00202
        int 021


; 0x83 - ADC MEM16,IMM16
; ############################################################

TEST_83_2_0:             ; ADC MEM16,IMM16 - Test data values from memory

        ; Tests with Carry Bit CLEARED
        ; ----------------------------
        clc
        mov word [00050],0F3FF
        lock adc word [00050],00000     ; test lock prefix
        cmp word [00050],0F3FF
        jne FAIL_83_2_0

        clc
        mov word [00050],01200
        adc word [00050],00000
        cmp word [00050],01200
        jne FAIL_83_2_0

        clc
        mov word es:[00052],00011 ; test segment override
        adc word es:[00052],00022
        cmp word es:[00052],00033
        jne FAIL_83_2_0

        clc
        mov word [00053],012FF
        adc word [00053],0FFFF
        cmp word [00053],012FE
        jne FAIL_83_2_0
        jmp TEST_83_2_1

FAIL_83_2_0:
        mov dx,00032    ; Print a 2
        mov ax,00202
        int 021

; ##################

        ; Tests with Carry Bit SET
        ; ------------------------
TEST_83_2_1:
        stc
        mov word [00050],01200
        lock adc word [00050],00000     ; test lock prefix
        cmp word [00050],01201
        jne FAIL_83_2_1

        stc
        mov word [00050],01234
        adc word [00050],00000
        cmp word [00050],01235
        jne FAIL_83_2_1

        stc
        mov word es:[00052],00011 ; test segment override
        adc word es:[00052],00022
        cmp word es:[00052],00034
        jne FAIL_83_2_1

        stc
        mov word [00053],01234
        adc word [00053],0FFFF
        cmp word [00053],01234
        jne FAIL_83_2_1
        jmp TEST_83_2_2

FAIL_83_2_1:
        mov dx,00032    ; Print a 2
        mov ax,00202
        int 021

; ##################

TEST_83_2_2:              ; ADC MEM16,IMM16 - Test flags
                        ; Overflow, Sign, Zero, Parity, AUX, Carry

        ; Tests with Carry Bit CLEARED
        ; ----------------------------
        clc
        mov word [00054],07FFF
        adc word [00054],00001  ; Overflow should be set
        jno FAIL_83_2_2   ; If not set, then fail

        clc
        mov word [00055],01111
        adc word [00055],00002  ; Overflow should NOT be set
        jno PASS_83_2_2   ; If not set, then we passed
        jmp FAIL_83_2_2   ; If set then we fail

PASS_83_2_2:
        clc
        mov word [00056],07FFF
        adc word [00056],00001  ; sign should be set
        jns FAIL_83_2_2   ; If not set, then fail

        clc
        mov word [00057],01111
        adc word [00057],00022  ; sign should NOT be set
        js  FAIL_83_2_2   ; If set then we fail

        clc
        mov word [00058],0FF01
        adc word [00058],000FF  ; zero should be set
        jne FAIL_83_2_2   ; If not set then we fail
        jmp PASS_83_2_3

FAIL_83_2_2:
        mov dx,00032    ; Print a 2
        mov ax,00202
        int 021
        jmp PASS_83_2_4

PASS_83_2_3:
        clc
        mov word [00050],03001
        adc word [00050],00000  ; zero should NOT be set
        je  FAIL_83_2_2   ; If set then we fail

        clc
        mov word [00050],01122
        adc word [00050],00011  ; parity should be set
        jnp FAIL_83_2_2   ; If not set then we fail

        clc
        mov word [00050],01121
        adc word [00050],00011  ; parity should NOT be set
        jp  FAIL_83_2_2   ; If set then we fail

        clc
        mov word [00050],02201
        adc word [00050],0FFFF  ; carry should be set
        jnc FAIL_83_2_2   ; If not set then we fail

        clc
        mov word [00050],00022
        adc word [00050],00033  ; carry should NOT be set
        jc  FAIL_83_2_2   ; If set then we fail


        ; Tests with Carry Bit SET
        ; ------------------------
        stc
        mov word [00054],07FFF
        adc word [00054],00001  ; Overflow should be set
        jno FAIL_83_2_3   ; If not set, then fail

        stc
        mov word [00055],01111
        adc word [00055],00022  ; Overflow should NOT be set
        jno PASS_83_2_4   ; If not set, then we passed
        jmp FAIL_83_2_3   ; If set then we fail

PASS_83_2_4:
        stc
        mov word [00056],07FFE
        adc word [00056],00001  ; sign should be set
        jns FAIL_83_2_3   ; If not set, then fail

        stc
        mov word [00057],01111
        adc word [00057],00022  ; sign should NOT be set
        js  FAIL_83_2_3   ; If set then we fail

        stc
        mov word [00058],0FFFF
        adc word [00058],00000  ; zero should be set
        jne FAIL_83_2_3   ; If not set then we fail
        jmp PASS_83_2_5

FAIL_83_2_3:
        mov dx,00032    ; Print a 2
        mov ax,00202
        int 021
        jmp TEST_83_3_0

PASS_83_2_5:
        stc
        mov word [00050],01234
        adc word [00050],00000  ; zero should NOT be set
        je  FAIL_83_2_3   ; If set then we fail

        stc
        mov word [00050],00010
        adc word [00050],00022  ; parity should be set
        jnp FAIL_83_2_3   ; If not set then we fail

        stc
        mov word [00050],00011
        adc word [00050],00022  ; parity should NOT be set
        jp  FAIL_83_2_3   ; If set then we fail

        stc
        mov word [00050],01000
        adc word [00050],0FFFF  ; carry should be set
        jnc FAIL_83_2_3   ; If not set then we fail

        stc
        mov word [00050],00011
        adc word [00050],00022  ; carry should NOT be set
        jc  FAIL_83_2_3   ; If set then we fail



; 0x83 - SBB MEM16,IMM16
; ############################################################

TEST_83_3_0:             ; SBB MEM16,IMM16 - Test data values from memory

        ; Tests with Carry Bit CLEARED
        ; ----------------------------
        clc
        mov word [00050],01234
        lock sbb word [00050],00001     ; test lock prefix
        cmp word [00050],01233
        jne FAIL_83_3_0

        clc
        mov word [00050],00000
        sbb word [00050],00000
        cmp word [00050],00000
        jne FAIL_83_3_0

        clc
        mov word es:[00052],02222 ; test segment override
        sbb word es:[00052],00011
        cmp word es:[00052],02211
        jne FAIL_83_3_0

        clc
        mov word [00053],0FF00
        sbb word [00053],00000
        cmp word [00053],0FF00
        jne FAIL_83_3_0
        jmp TEST_83_3_1

FAIL_83_3_0:
        mov dx,00033    ; Print a 3
        mov ax,00202
        int 021

; ##################

        ; Tests with Carry Bit SET
        ; ------------------------
TEST_83_3_1:
        stc
        mov word [00050],01235
        lock sbb word [00050],00000     ; test lock prefix
        cmp word [00050],01234
        jne FAIL_83_3_1

        stc
        mov word [00050],01234
        sbb word [00050],00000
        cmp word [00050],01233
        jne FAIL_83_3_1

        stc
        mov word es:[00052],02222 ; test segment override
        sbb word es:[00052],00011
        cmp word es:[00052],02210
        jne FAIL_83_3_1

        stc
        mov word [00053],0FFFF
        sbb word [00053],00001
        cmp word [00053],0FFFD
        jne FAIL_83_3_1
        jmp TEST_83_3_2

FAIL_83_3_1:
        mov dx,00033    ; Print a 3
        mov ax,00202
        int 021

; ##################

TEST_83_3_2:            ; SBB MEM16,IMM16 - Test flags
                        ; Overflow, Sign, Zero, Parity, AUX, Carry

        ; Tests with Carry Bit CLEARED
        ; ----------------------------
        clc
        mov word [00054],08000
        sbb word [00054],00001  ; Overflow should be set
        jno FAIL_83_3_2   ; If not set, then fail

        clc
        mov word [00055],07800
        sbb word [00055],00000  ; Overflow should NOT be set
        jno PASS_83_3_2   ; If not set, then we passed
        jmp FAIL_83_3_2   ; If set then we fail

PASS_83_3_2:
        clc
        mov word [00056],08FFF
        sbb word [00056],00001  ; sign should be set
        jns FAIL_83_3_2   ; If not set, then fail

        clc
        mov word [00057],01111
        sbb word [00057],00001  ; sign should NOT be set
        js  FAIL_83_3_2   ; If set then we fail

        clc
        mov word [00058],00034
        sbb word [00058],00034  ; zero should be set
        jne FAIL_83_3_2   ; If not set then we fail
        jmp PASS_83_3_3

FAIL_83_3_2:
        mov dx,00033    ; Print a 3
        mov ax,00202
        int 021
        jmp PASS_83_3_4

PASS_83_3_3:
        clc
        mov word [00050],04444
        sbb word [00050],00022  ; zero should NOT be set
        je  FAIL_83_3_2   ; If set then we fail

        clc
        mov word [00050],04444
        sbb word [00050],00011  ; parity should be set
        jnp FAIL_83_3_2   ; If not set then we fail

        clc
        mov word [00050],04444
        sbb word [00050],00010  ; parity should NOT be set
        jp  FAIL_83_3_2   ; If set then we fail

        clc
        mov word [00050],00000
        sbb word [00050],00001  ; carry should be set
        jnc FAIL_83_3_2   ; If not set then we fail

        clc
        mov word [00050],01234
        sbb word [00050],00012  ; carry should NOT be set
        jc  FAIL_83_3_2   ; If set then we fail


        ; Tests with Carry Bit SET
        ; ------------------------
        stc
        mov word [00054],08000
        sbb word [00054],00000  ; Overflow should be set
        jno FAIL_83_3_3   ; If not set, then fail

        stc
        mov word [00055],03333
        sbb word [00055],00011  ; Overflow should NOT be set
        jno PASS_83_3_4   ; If not set, then we passed
        jmp FAIL_83_3_3   ; If set then we fail

PASS_83_3_4:
        stc
        mov word [00056],00001
        sbb word [00056],00001  ; sign should be set
        jns FAIL_83_3_3   ; If not set, then fail

        stc
        mov word [00057],04444
        sbb word [00057],00022  ; sign should NOT be set
        js  FAIL_83_3_3   ; If set then we fail

        stc
        mov word [00058],00001
        sbb word [00058],00000  ; zero should be set
        jne FAIL_83_3_3   ; If not set then we fail
        jmp PASS_83_3_5

FAIL_83_3_3:
        mov dx,00033    ; Print a 3
        mov ax,00202
        int 021
        jmp TEST_83_5_0

PASS_83_3_5:
        stc
        mov word [00050],01111
        sbb word [00050],00001  ; zero should NOT be set
        je  FAIL_83_3_3   ; If set then we fail

        stc
        mov word [00050],04444
        sbb word [00050],00013  ; parity should be set
        jnp FAIL_83_3_3   ; If not set then we fail

        stc
        mov word [00050],04448
        sbb word [00050],00013  ; parity should NOT be set
        jp  FAIL_83_3_3   ; If set then we fail

        stc
        mov word [00050],00000
        sbb word [00050],00000  ; carry should be set
        jnc FAIL_83_3_3   ; If not set then we fail

        stc
        mov word [00050],06666
        sbb word [00050],00022  ; carry should NOT be set
        jc  FAIL_83_3_3   ; If set then we fail



; 0x28 - SUB MEM16,IMM16
; ############################################################

TEST_83_5_0:             ; SUB MEM16,IMM16 - Test data values from memory

        mov word [00050],08888
        lock sub word [00050],00011     ; test lock prefix
        cmp word [00050],08877
        jne FAIL_83_5_0

        mov word [00050],01222
        sub word [00050],00022
        cmp word [00050],01200
        jne FAIL_83_5_0

        mov word es:[00052],02222 ; test segment override
        sub word es:[00052],00011
        cmp word es:[00052],02211
        jne FAIL_83_5_0

        mov word [00053],00000
        sub word [00053],00001
        cmp word [00053],0FFFF
        jne FAIL_83_5_0
        jmp TEST_83_5_1

FAIL_83_5_0:
        mov dx,00035    ; Print a 5
        mov ax,00202
        int 021

; ##################
TEST_83_5_1:              ; SUB MEM16,IMM16 - Test flags
                        ; Overflow, Sign, Zero, Parity, AUX, Carry

        mov word [00054],08000
        sub word [00054],00001  ; Overflow should be set
        jno FAIL_83_5_1   ; If not set, then fail

        mov word [00055],01234
        sub word [00055],00034  ; Overflow should NOT be set
        jno PASS_83_5_1   ; If not set, then we passed
        jmp FAIL_83_5_1   ; If set then we fail

PASS_83_5_1:
        mov word [00056],00000
        sub word [00056],00001  ; sign should be set
        jns FAIL_83_5_1   ; If not set, then fail

        mov word [00057],02222
        sub word [00057],00011  ; sign should NOT be set
        js  FAIL_83_5_1   ; If set then we fail

        mov word [00058],00011
        sub word [00058],00011  ; zero should be set
        jne FAIL_83_5_1   ; If not set then we fail
        jmp PASS_83_5_2

FAIL_83_5_1:
        mov dx,00035    ; Print a 5
        mov ax,00202
        int 021
        jmp TEST_83_7_0

PASS_83_5_2:
        mov word [00050],05555
        sub word [00050],00011  ; zero should NOT be set
        je  FAIL_83_5_1   ; If set then we fail

        mov word [00050],00034
        sub word [00050],00001  ; parity should be set
        jnp FAIL_83_5_1   ; If not set then we fail

        mov word [00050],00032
        sub word [00050],00001  ; parity should NOT be set
        jp  FAIL_83_5_1   ; If set then we fail

        mov word [00050],00000
        sub word [00050],00001  ; carry should be set
        jnc FAIL_83_5_1   ; If not set then we fail

        mov word [00050],04031
        sub word [00050],00011  ; carry should NOT be set
        jc  FAIL_83_5_1   ; If set then we fail



; 0x83 - CMP MEM16,IMM16
; ############################################################

TEST_83_7_0:             ; CMP MEM16,IMM16 - Test data values from memory

        mov word [00050],00012
        lock cmp word [00050],00012     ; test lock prefix
        jne FAIL_83_7_0

        mov word [00050],00200
        cmp word [00050],00200
        jne FAIL_83_7_0

        mov word es:[00052],00011 ; test segment override
        cmp word es:[00052],00011
        jne FAIL_83_7_0

        mov word [00053],000FF
        cmp word [00053],000FF
        jne FAIL_83_7_0
        jmp TEST_83_7_1

FAIL_83_7_0:
        mov dx,00037    ; Print a 7
        mov ax,00202
        int 021

; ##################
TEST_83_7_1:              ; CMP MEM16,IMM16 - Test flags
                        ; Overflow, Sign, Zero, Parity, AUX, Carry

        mov word [00054],08000
        cmp word [00054],00001  ; Overflow should be set
        jno FAIL_83_7_1   ; If not set, then fail

        mov word [00055],02222
        cmp word [00055],00011  ; Overflow should NOT be set
        jno PASS_83_7_1   ; If not set, then we passed
        jmp FAIL_83_7_1   ; If set then we fail

PASS_83_7_1:
        mov word [00056],0FFFF
        cmp word [00056],00001  ; sign should be set
        jns FAIL_83_7_1   ; If not set, then fail

        mov word [00057],01111
        cmp word [00057],00001  ; sign should NOT be set
        js  FAIL_83_7_1   ; If set then we fail

        mov word [00058],00034
        cmp word [00058],00034  ; zero should be set
        jne FAIL_83_7_1   ; If not set then we fail
        jmp PASS_83_7_2

FAIL_83_7_1:
        mov dx,00037    ; Print a 7
        mov ax,00202
        int 021
        jmp Z_END

PASS_83_7_2:
        mov word [00050],01100
        cmp word [00050],00001  ; zero should NOT be set
        je  FAIL_83_7_1   ; If set then we fail

        mov word [00050],00044
        cmp word [00050],00000  ; parity should be set
        jnp FAIL_83_7_1   ; If not set then we fail

        mov word [00050],00044
        cmp word [00050],00001  ; parity should NOT be set
        jp  FAIL_83_7_1   ; If set then we fail

        mov word [00050],00000
        cmp word [00050],00001  ; carry should be set
        jnc FAIL_83_7_1   ; If not set then we fail

        mov word [00050],01234
        cmp word [00050],00001  ; carry should NOT be set
        jc  FAIL_83_7_1   ; If set then we fail


; xxxxxxxxxxxxxxxxxxxxxxx
; End
; xxxxxxxxxxxxxxxxxxxxxxx
Z_END:
        mov ax,00000    ; DOS Command=Exit
        int 021



; Tests for opcode range 0x81 with second word=0x0-0x7
; These tests are for MEM16,IMM16
; ----------------------------------------------------

        mov ax,es       ; Increment ES so it is not the same as DS
        inc ax
        mov es,ax


; 0x81 - ADD MEM16,IMM16
; ############################################################

TEST_81_0_0:             ; Test from Memory

        mov word [00050],0FFFF
        lock add word [00050],01234     ; test lock prefix
        cmp word [00050],01233
        jne FAIL_81_0_0

        mov word [00050],00000
        add word [00050],01234
        cmp word [00050],01234
        jne FAIL_81_0_0

        mov word es:[00052],01111 ; test segment override
        add word es:[00052],02222
        cmp word es:[00052],03333
        jne FAIL_81_0_0
        jmp TEST_81_0_1

FAIL_81_0_0:
        mov dx,00030    ; Print a 0
        mov ax,00202
        int 021


TEST_81_0_1:              ; ADD MEM16,IMM16 - Test flags
                        ; Overflow, Sign, Zero, Parity, AUX, Carry

        mov word [00054],00001
        add word [00054],07FFF  ; Overflow should be set
        jno FAIL_81_0_1   ; If not set, then fail

        mov word [00055],00022
        add word [00055],01234  ; Overflow should NOT be set
        jno PASS_81_0_1   ; If not set, then we passed
        jmp FAIL_81_0_1   ; If set then we fail

PASS_81_0_1:
        mov word [00056],07FFF
        add word[00056],00234  ; sign should be set
        jns FAIL_81_0_1   ; If not set, then fail

        mov word [00057],01111
        add word [00057],02222  ; sign should NOT be set
        js  FAIL_81_0_1   ; If set then we fail

        mov word [00058],00100
        add word [00058],0FF00  ; zero should be set
        jne FAIL_81_0_1   ; If not set then we fail
        jmp TEST_81_1_0

FAIL_81_0_1:
        mov dx,00030    ; Print a 0
        mov ax,00202
        int 021


; 0x81 - OR MEM16,IMM16
; ############################################################

TEST_81_1_0:             ; OR MEM16,IMM16 - Test data values from memory

        mov ax,es       ; Increment ES so it is not the same as DS
        inc ax
        mov es,ax

        mov word [00050],05A5A
        lock or word [00050],0A5A5
        cmp word [00050],0FFFF
        jne FAIL_81_1_0

        mov word [00050],00000
        or word [00050],01234
        cmp word [00050],01234
        jne FAIL_81_1_0

        mov word es:[00050],05500
        or word es:[00050],05555
        cmp word es:[00050],05555
        jne FAIL_81_1_0
        jmp TEST_81_1_1


FAIL_81_1_0:
        mov dx,00031    ; Print a 1
        mov ax,00202
        int 021

; ##################
TEST_81_1_1:              ; OR MEM16,IMM16 - Test flags
                        ; Overflow, Sign, Zero, Parity, AUX, Carry

        mov word [00050],01111
        or word [00050],02222  ; Overflow should NEVER be set
        jno PASS_81_1_1   ; If not set, then we passed
        jmp FAIL_81_1_1   ; If set then we fail

PASS_81_1_1:
        mov word [00050],08000
        or word [00050],01234  ; sign should be set
        jns FAIL_81_1_1   ; If not set, then fail

        mov word [00050],01111
        or word [00050],02222  ; sign should NOT be set
        js  FAIL_81_1_1   ; If set then we fail

        mov word [00050],00000
        or word [00050],00000  ; zero should be set
        jne FAIL_81_1_1   ; If not set then we fail
        jmp PASS_81_1_2

FAIL_81_1_1:
        mov dx,00031    ; Print a 1
        mov ax,00202
        int 021
        jmp TEST_81_2_0

PASS_81_1_2:
        mov word [00050],00000
        or word [00050],01234  ; zero should NOT be set
        je  FAIL_81_1_1   ; If set then we fail

        mov word [00050],01111
        or word [00050],02222  ; parity should be set
        jnp FAIL_81_1_1   ; If not set then we fail

        mov word [00050],00010
        or word [00050],03400  ; parity should NOT be set
        jp  FAIL_81_1_1   ; If set then we fail

        mov word [00050],01112
        or word [00050],02234  ; carry should NEVER be set
        jc  FAIL_81_1_1   ; If set then we fail



; 0x81 - ADC MEM16,IMM16
; ############################################################

TEST_81_2_0:             ; ADC MEM16,IMM16 - Test data values from memory

        ; Tests with Carry Bit CLEARED
        ; ----------------------------
        clc
        mov word [00050],00000
        lock adc word [00050],0F3FF     ; test lock prefix
        cmp word [00050],0F3FF
        jne FAIL_81_2_0

        clc
        mov word [00050],00000
        adc word [00050],01200
        cmp word [00050],01200
        jne FAIL_81_2_0

        clc
        mov word es:[00052],01111 ; test segment override
        adc word es:[00052],02222
        cmp word es:[00052],03333
        jne FAIL_81_2_0

        clc
        mov word [00053],0FFFF
        adc word [00053],012FF
        cmp word [00053],012FE
        jne FAIL_81_2_0
        jmp TEST_81_2_1

FAIL_81_2_0:
        mov dx,00032    ; Print a 2
        mov ax,00202
        int 021

; ##################

        ; Tests with Carry Bit SET
        ; ------------------------
TEST_81_2_1:
        stc
        mov word [00050],00000
        lock adc word [00050],01200     ; test lock prefix
        cmp word [00050],01201
        jne FAIL_81_2_1

        stc
        mov word [00050],00000
        adc word [00050],01234
        cmp word [00050],01235
        jne FAIL_81_2_1

        stc
        mov word es:[00052],01111 ; test segment override
        adc word es:[00052],02222
        cmp word es:[00052],03334
        jne FAIL_81_2_1

        stc
        mov word [00053],0FFFF
        adc word [00053],01234
        cmp word [00053],01234
        jne FAIL_81_2_1
        jmp TEST_81_2_2

FAIL_81_2_1:
        mov dx,00032    ; Print a 2
        mov ax,00202
        int 021

; ##################

TEST_81_2_2:              ; ADC MEM16,IMM16 - Test flags
                        ; Overflow, Sign, Zero, Parity, AUX, Carry

        ; Tests with Carry Bit CLEARED
        ; ----------------------------
        clc
        mov word [00054],00001
        adc word [00054],07FFF  ; Overflow should be set
        jno FAIL_81_2_2   ; If not set, then fail

        clc
        mov word [00055],00002
        adc word [00055],01111  ; Overflow should NOT be set
        jno PASS_81_2_2   ; If not set, then we passed
        jmp FAIL_81_2_2   ; If set then we fail

PASS_81_2_2:
        clc
        mov word [00056],00001
        adc word [00056],07FFF  ; sign should be set
        jns FAIL_81_2_2   ; If not set, then fail

        clc
        mov word [00057],01111
        adc word [00057],02222  ; sign should NOT be set
        js  FAIL_81_2_2   ; If set then we fail

        clc
        mov word [00058],00100
        adc word [00058],0FF00  ; zero should be set
        jne FAIL_81_2_2   ; If not set then we fail
        jmp PASS_81_2_3

FAIL_81_2_2:
        mov dx,00032    ; Print a 2
        mov ax,00202
        int 021
        jmp PASS_81_2_4

PASS_81_2_3:
        clc
        mov word [00050],00000
        adc word [00050],03001  ; zero should NOT be set
        je  FAIL_81_2_2   ; If set then we fail

        clc
        mov word [00050],00011
        adc word [00050],01122  ; parity should be set
        jnp FAIL_81_2_2   ; If not set then we fail

        clc
        mov word [00050],00011
        adc word [00050],01121  ; parity should NOT be set
        jp  FAIL_81_2_2   ; If set then we fail

        clc
        mov word [00050],0FFFF
        adc word [00050],02201  ; carry should be set
        jnc FAIL_81_2_2   ; If not set then we fail

        clc
        mov word [00050],01222
        adc word [00050],03433  ; carry should NOT be set
        jc  FAIL_81_2_2   ; If set then we fail


        ; Tests with Carry Bit SET
        ; ------------------------
        stc
        mov word [00054],07FFF
        adc word [00054],00201  ; Overflow should be set
        jno FAIL_81_2_3   ; If not set, then fail

        stc
        mov word [00055],01111
        adc word [00055],02222  ; Overflow should NOT be set
        jno PASS_81_2_4   ; If not set, then we passed
        jmp FAIL_81_2_3   ; If set then we fail

PASS_81_2_4:
        stc
        mov word [00056],07FFE
        adc word [00056],00201  ; sign should be set
        jns FAIL_81_2_3   ; If not set, then fail

        stc
        mov word [00057],01111
        adc word [00057],02222  ; sign should NOT be set
        js  FAIL_81_2_3   ; If set then we fail

        stc
        mov word [00058],0EEEF
        adc word [00058],01110  ; zero should be set
        jne FAIL_81_2_3   ; If not set then we fail
        jmp PASS_81_2_5

FAIL_81_2_3:
        mov dx,00032    ; Print a 2
        mov ax,00202
        int 021
        jmp TEST_81_3_0

PASS_81_2_5:
        stc
        mov word [00050],00000
        adc word [00050],01234  ; zero should NOT be set
        je  FAIL_81_2_3   ; If set then we fail

        stc
        mov word [00050],02210
        adc word [00050],02222  ; parity should be set
        jnp FAIL_81_2_3   ; If not set then we fail

        stc
        mov word [00050],02211
        adc word [00050],02222  ; parity should NOT be set
        jp  FAIL_81_2_3   ; If set then we fail

        stc
        mov word [00050],0FFFF
        adc word [00050],02000  ; carry should be set
        jnc FAIL_81_2_3   ; If not set then we fail

        stc
        mov word [00050],01111
        adc word [00050],02222  ; carry should NOT be set
        jc  FAIL_81_2_3   ; If set then we fail



; 0x81 - SBB MEM16,IMM16
; ############################################################

TEST_81_3_0:             ; SBB MEM16,IMM16 - Test data values from memory

        ; Tests with Carry Bit CLEARED
        ; ----------------------------
        clc
        mov word [00050],00000
        lock sbb word [00050],01201     ; test lock prefix
        cmp word [00050],0EDFF
        jne FAIL_81_3_0

        clc
        mov word [00050],00000
        sbb word [00050],01200
        cmp word [00050],0EE00
        jne FAIL_81_3_0

        clc
        mov word es:[00052],02222 ; test segment override
        sbb word  es:[00052],01111
        cmp word es:[00052],01111
        jne FAIL_81_3_0

        clc
        mov word [00053],0FF00
        sbb word [00053],0FF00
        cmp word [00053],00000
        jne FAIL_81_3_0
        jmp TEST_81_3_1

FAIL_81_3_0:
        mov dx,00033    ; Print a 3
        mov ax,00202
        int 021

; ##################

        ; Tests with Carry Bit SET
        ; ------------------------
TEST_81_3_1:
        stc
        mov word [00050],01235
        lock sbb word [00050],01234     ; test lock prefix
        cmp word [00050],00000
        jne FAIL_81_3_1

        stc
        mov word [00050],01234
        sbb word [00050],00000
        cmp word [00050],01233
        jne FAIL_81_3_1

        stc
        mov word es:[00052],01111 ; test segment override
        sbb word es:[00052],02222
        cmp word es:[00052],0EEEE
        jne FAIL_81_3_1

        stc
        mov word [00053],0FFFF
        sbb word [00053],01234
        cmp word [00053],0EDCA
        jne FAIL_81_3_1
        jmp TEST_81_3_2

FAIL_81_3_1:
        mov dx,00033    ; Print a 3
        mov ax,00202
        int 021

; ##################

TEST_81_3_2:            ; SBB MEM16,IMM16 - Test flags
                        ; Overflow, Sign, Zero, Parity, AUX, Carry

        ; Tests with Carry Bit CLEARED
        ; ----------------------------
        clc
        mov word [00054],08000
        sbb word [00054],00101  ; Overflow should be set
        jno FAIL_81_3_2   ; If not set, then fail

        clc
        mov word [00055],07800
        sbb word [00055],03400  ; Overflow should NOT be set
        jno PASS_81_3_2   ; If not set, then we passed
        jmp FAIL_81_3_2   ; If set then we fail

PASS_81_3_2:
        clc
        mov word [00056],08FFF
        sbb word [00056],00101  ; sign should be set
        jns FAIL_81_3_2   ; If not set, then fail

        clc
        mov word [00057],01111
        sbb word [00057],00101  ; sign should NOT be set
        js  FAIL_81_3_2   ; If set then we fail

        clc
        mov word [00058],01234
        sbb word [00058],01234  ; zero should be set
        jne FAIL_81_3_2   ; If not set then we fail
        jmp PASS_81_3_3

FAIL_81_3_2:
        mov dx,00033    ; Print a 3
        mov ax,00202
        int 021
        jmp PASS_81_3_4

PASS_81_3_3:
        clc
        mov word [00050],04444
        sbb word [00050],02222  ; zero should NOT be set
        je  FAIL_81_3_2   ; If set then we fail

        clc
        mov word [00050],04444
        sbb word [00050],01111  ; parity should be set
        jnp FAIL_81_3_2   ; If not set then we fail

        clc
        mov word [00050],04444
        sbb word [00050],01110  ; parity should NOT be set
        jp  FAIL_81_3_2   ; If set then we fail

        clc
        mov word [00050],00000
        sbb word [00050],00101  ; carry should be set
        jnc FAIL_81_3_2   ; If not set then we fail

        clc
        mov word [00050],01234
        sbb word [00050],00112  ; carry should NOT be set
        jc  FAIL_81_3_2   ; If set then we fail


        ; Tests with Carry Bit SET
        ; ------------------------
        stc
        mov word [00054],08000
        sbb word [00054],00200  ; Overflow should be set
        jno FAIL_81_3_3   ; If not set, then fail

        stc
        mov word [00055],03333
        sbb word [00055],01111  ; Overflow should NOT be set
        jno PASS_81_3_4   ; If not set, then we passed
        jmp FAIL_81_3_3   ; If set then we fail

PASS_81_3_4:
        stc
        mov word [00056],00001
        sbb word [00056],00201  ; sign should be set
        jns FAIL_81_3_3   ; If not set, then fail

        stc
        mov word [00057],04444
        sbb word [00057],02222  ; sign should NOT be set
        js  FAIL_81_3_3   ; If set then we fail

        stc
        mov word [00058],00201
        sbb word [00058],00200  ; zero should be set
        jne FAIL_81_3_3   ; If not set then we fail
        jmp PASS_81_3_5

FAIL_81_3_3:
        mov dx,00033    ; Print a 3
        mov ax,00202
        int 021
        jmp TEST_81_4_0

PASS_81_3_5:
        stc
        mov word [00050],01111
        sbb word [00050],00201  ; zero should NOT be set
        je  FAIL_81_3_3   ; If set then we fail

        stc
        mov word [00050],04444
        sbb word [00050],01113  ; parity should be set
        jnp FAIL_81_3_3   ; If not set then we fail

        stc
        mov word [00050],04448
        sbb word [00050],01113  ; parity should NOT be set
        jp  FAIL_81_3_3   ; If set then we fail

        stc
        mov word [00050],00000
        sbb word [00050],00200  ; carry should be set
        jnc FAIL_81_3_3   ; If not set then we fail

        stc
        mov word [00050],06666
        sbb word [00050],02222  ; carry should NOT be set
        jc  FAIL_81_3_3   ; If set then we fail


                   
; 0x81 - AND MEM16,IMM16
; ############################################################

TEST_81_4_0:             ; AND MEM16,IMM16 - Test data values from memory

        mov word [00050],05A5A
        lock and word [00050],0A5A5
        cmp word [00050],000
        jne FAIL_81_4_0

        mov word [00050],0FFFF
        and word [00050],01111
        cmp word [00050],01111
        jne FAIL_81_4_0

        mov word es:[00050],01100
        and word es:[00050],01100
        cmp word es:[00050],01100
        jne FAIL_81_4_0
        jmp TEST_81_4_1


FAIL_81_4_0:
        mov dx,00034    ; Print a 4
        mov ax,00202
        int 021

; ##################
TEST_81_4_1:            ; AND MEM16,IMM16 - Test flags
                        ; Overflow, Sign, Zero, Parity, AUX, Carry

        mov word [00050],01111
        and word [00050],02222  ; Overflow should NEVER be set
        jno PASS_81_4_1   ; If not set, then we passed
        jmp FAIL_81_4_1   ; If set then we fail

PASS_81_4_1:
        mov word [00050],08000
        and word [00050],08000  ; sign should be set
        jns FAIL_81_4_1   ; If not set, then fail

        mov word [00050],0FFFF
        and word [00050],07FFF  ; sign should NOT be set
        js  FAIL_81_4_1   ; If set then we fail

        mov word [00050],00000
        and word [00050],012FF  ; zero should be set
        jne FAIL_81_4_1   ; If not set then we fail
        jmp PASS_81_4_2

FAIL_81_4_1:
        mov dx,00034    ; Print a 4
        mov ax,00202
        int 021
        jmp TEST_81_5_0

PASS_81_4_2:
        mov word [00050],0FF00
        and word [00050],00100  ; zero should NOT be set
        je  FAIL_81_4_1   ; If set then we fail

        mov word [00050],00003
        and word [00050],00103  ; parity should be set
        jnp FAIL_81_4_1   ; If not set then we fail

        mov word [00050],00003
        and word [00050],00101  ; parity should NOT be set
        jp  FAIL_81_4_1   ; If set then we fail

        mov word [00050],01112
        and word [00050],01134  ; carry should NEVER be set
        jc  FAIL_81_4_1   ; If set then we fail


; 0x28 - SUB MEM16,IMM16
; ############################################################

TEST_81_5_0:             ; SUB MEM16,IMM16 - Test data values from memory

        mov word [00050],08888
        lock sub word [00050],01111     ; test lock prefix
        cmp word [00050],07777
        jne FAIL_81_5_0

        mov word [00050],01222
        sub word [00050],01222
        cmp word [00050],00000
        jne FAIL_81_5_0

        mov word es:[00052],02222 ; test segment override
        sub word es:[00052],01111
        cmp word es:[00052],01111
        jne FAIL_81_5_0

        mov word [00053],00100
        sub word [00053],00101
        cmp word [00053],0FFFF
        jne FAIL_81_5_0
        jmp TEST_81_5_1

FAIL_81_5_0:
        mov dx,00035    ; Print a 5
        mov ax,00202
        int 021

; ##################
TEST_81_5_1:              ; SUB MEM16,IMM16 - Test flags
                        ; Overflow, Sign, Zero, Parity, AUX, Carry

        mov word [00054],08000
        sub word [00054],00201  ; Overflow should be set
        jno FAIL_81_5_1   ; If not set, then fail

        mov word [00055],01234
        sub word [00055],01234  ; Overflow should NOT be set
        jno PASS_81_5_1   ; If not set, then we passed
        jmp FAIL_81_5_1   ; If set then we fail

PASS_81_5_1:
        mov word [00056],00000
        sub word [00056],00201  ; sign should be set
        jns FAIL_81_5_1   ; If not set, then fail

        mov word [00057],02222
        sub word [00057],01111  ; sign should NOT be set
        js  FAIL_81_5_1   ; If set then we fail

        mov word [00058],01111
        sub word [00058],01111  ; zero should be set
        jne FAIL_81_5_1   ; If not set then we fail
        jmp PASS_81_5_2

FAIL_81_5_1:
        mov dx,00035    ; Print a 5
        mov ax,00202
        int 021
        jmp TEST_81_6_0

PASS_81_5_2:
        mov word [00050],05555
        sub word [00050],01111  ; zero should NOT be set
        je  FAIL_81_5_1   ; If set then we fail

        mov word [00050],00034
        sub word [00050],00201  ; parity should be set
        jnp FAIL_81_5_1   ; If not set then we fail

        mov word [00050],00032
        sub word [00050],00201  ; parity should NOT be set
        jp  FAIL_81_5_1   ; If set then we fail

        mov word [00050],00000
        sub word [00050],00201  ; carry should be set
        jnc FAIL_81_5_1   ; If not set then we fail

        mov word [00050],04031
        sub word [00050],00211  ; carry should NOT be set
        jc  FAIL_81_5_1   ; If set then we fail

                   
; 0x81 - XOR MEM16,IMM16
; ############################################################

TEST_81_6_0:             ; XOR MEM16,IMM16 - Test data values from memory

        mov word [00050],05A5A
        lock xor word [00050],0A5A5
        cmp word word [00050],0FFFF
        jne FAIL_81_6_0

        mov word [00050],00200
        xor word [00050],00200
        cmp word word [00050],00000
        jne FAIL_81_6_0

        mov word es:[00050],08200
        xor word es:[00050],00201
        cmp word word es:[00050],08001
        jne FAIL_81_6_0
        jmp TEST_81_6_1


FAIL_81_6_0:
        mov dx,00036    ; Print a 6
        mov ax,00202
        int 021

; ##################
TEST_81_6_1:              ; XOR MEM16,IMM16 - Test flags
                        ; Overflow, Sign, Zero, Parity, AUX, Carry

        mov word [00050],020FF
        xor word [00050],0207F  ; Overflow should NEVER be set
        jno PASS_81_6_1   ; If not set, then we passed
        jmp FAIL_81_6_1   ; If set then we fail

PASS_81_6_1:
        mov word [00050],08000
        xor word [00050],00200  ; sign should be set
        jns FAIL_81_6_1   ; If not set, then fail

        mov word [00050],01111
        xor word [00050],02222  ; sign should NOT be set
        js  FAIL_81_6_1   ; If set then we fail

        mov word [00050],05A22
        xor word [00050],05A22  ; zero should be set
        jne FAIL_81_6_1   ; If not set then we fail
        jmp PASS_81_6_2

FAIL_81_6_1:
        mov dx,00036    ; Print a 6
        mov ax,00202
        int 021
        jmp TEST_81_7_0

PASS_81_6_2:
        mov word [00050],00000
        xor word [00050],00201  ; zero should NOT be set
        je  FAIL_81_6_1   ; If set then we fail

        mov word [00050],00001
        xor word [00050],00202  ; parity should be set
        jnp FAIL_81_6_1   ; If not set then we fail

        mov word [00050],00001
        xor word [00050],00206  ; parity should NOT be set
        jp  FAIL_81_6_1   ; If set then we fail

        mov word [00050],01212
        xor word [00050],01234  ; carry should NEVER be set
        jc  FAIL_81_6_1   ; If set then we fail



; 0x81 - CMP MEM16,IMM16
; ############################################################

TEST_81_7_0:             ; CMP MEM16,IMM16 - Test data values from memory

        mov word [00050],01212
        lock cmp word [00050],01212     ; test lock prefix
        jne FAIL_81_7_0

        mov word [00050],00200
        cmp word [00050],00200
        jne FAIL_81_7_0

        mov word es:[00052],01111 ; test segment override
        cmp word es:[00052],01111
        jne FAIL_81_7_0

        mov word [00053],0F2FF
        cmp word [00053],0F2FF
        jne FAIL_81_7_0
        jmp TEST_81_7_1

FAIL_81_7_0:
        mov dx,00037    ; Print a 7
        mov ax,00202
        int 021

; ##################
TEST_81_7_1:              ; CMP MEM16,IMM16 - Test flags
                        ; Overflow, Sign, Zero, Parity, AUX, Carry

        mov word [00054],08000
        cmp word [00054],00201  ; Overflow should be set
        jno FAIL_81_7_1   ; If not set, then fail

        mov word [00055],02222
        cmp word [00055],01111  ; Overflow should NOT be set
        jno PASS_81_7_1   ; If not set, then we passed
        jmp FAIL_81_7_1   ; If set then we fail

PASS_81_7_1:
        mov word [00056],0FFFF
        cmp word [00056],00201  ; sign should be set
        jns FAIL_81_7_1   ; If not set, then fail

        mov word [00057],01111
        cmp word [00057],00201  ; sign should NOT be set
        js  FAIL_81_7_1   ; If set then we fail

        mov word [00058],03434
        cmp word [00058],03434  ; zero should be set
        jne FAIL_81_7_1   ; If not set then we fail
        jmp PASS_81_7_2

FAIL_81_7_1:
        mov dx,00037    ; Print a 7
        mov ax,00202
        int 021
        jmp Z_END

PASS_81_7_2:
        mov word [00050],01100
        cmp word [00050],03301  ; zero should NOT be set
        je  FAIL_81_7_1   ; If set then we fail

        mov word [00050],00044
        cmp word [00050],00200  ; parity should be set
        jnp FAIL_81_7_1   ; If not set then we fail

        mov word [00050],00044
        cmp word [00050],00201  ; parity should NOT be set
        jp  FAIL_81_7_1   ; If set then we fail

        mov word [00050],00000
        cmp word [00050],00201  ; carry should be set
        jnc FAIL_81_7_1   ; If not set then we fail

        mov word [00050],01234
        cmp word [00050],00201  ; carry should NOT be set
        jc  FAIL_81_7_1   ; If set then we fail


; xxxxxxxxxxxxxxxxxxxxxxx
; End
; xxxxxxxxxxxxxxxxxxxxxxx
Z_END:
        mov ax,00000    ; DOS Command=Exit
        int 021



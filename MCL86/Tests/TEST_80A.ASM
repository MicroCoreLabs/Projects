; Tests for opcode range 0x80 with second byte=0x0-0x7
; These tests are for MEM8,IMM8
; ----------------------------------------------------

        mov ax,es       ; Increment ES so it is not the same as DS
        inc ax
        mov es,ax


; 0x80 - ADD MEM8,IMM8
; ############################################################

TEST_80_0_0:             ; Test from Memory

        mov byte [00050],0FF
        lock add byte [00050],0FF     ; test lock prefix
        cmp byte [00050],0FE
        jne FAIL_80_0_0

        mov byte [00050],000
        add byte [00050],000
        cmp byte [00050],000
        jne FAIL_80_0_0

        mov byte es:[00052],011 ; test segment override
        add byte es:[00052],022
        cmp byte es:[00052],033
        jne FAIL_80_0_0
        jmp TEST_80_0_1

FAIL_80_0_0:
        mov dx,00030    ; Print a 0
        mov ax,00202
        int 021


TEST_80_0_1:              ; ADD MEM8,IMM8 - Test flags
                        ; Overflow, Sign, Zero, Parity, AUX, Carry

        mov byte [00054],07B
        add byte [00054],036  ; Overflow should be set
        jno FAIL_80_0_1   ; If not set, then fail

        mov byte [00055],0B1
        add byte [00055],037  ; Overflow should NOT be set
        jno PASS_80_0_1   ; If not set, then we passed
        jmp FAIL_80_0_1   ; If set then we fail

PASS_80_0_1:
        mov byte [00056],0FF
        add byte[00056],0FF  ; sign should be set
        jns FAIL_80_0_1   ; If not set, then fail

        mov byte [00057],011
        add byte [00057],022  ; sign should NOT be set
        js  FAIL_80_0_1   ; If set then we fail

        mov byte [00058],000
        add byte [00058],000  ; zero should be set
        jne FAIL_80_0_1   ; If not set then we fail
        jmp TEST_80_1_0

FAIL_80_0_1:
        mov dx,00030    ; Print a 0
        mov ax,00202
        int 021


; 0x80 - OR MEM8,IMM8
; ############################################################

TEST_80_1_0:             ; OR MEM8,IMM8 - Test data values from memory

        mov ax,es       ; Increment ES so it is not the same as DS
        inc ax
        mov es,ax

        mov byte [00050],05A
        lock or byte [00050],0A5
        cmp byte [00050],0FF
        jne FAIL_80_1_0

        mov byte [00050],000
        or byte [00050],000
        cmp byte [00050],000
        jne FAIL_80_1_0

        mov byte es:[00050],080
        or byte es:[00050],001
        cmp byte es:[00050],081
        jne FAIL_80_1_0
        jmp TEST_80_1_1


FAIL_80_1_0:
        mov dx,00031    ; Print a 1
        mov ax,00202
        int 021

; ##################
TEST_80_1_1:              ; OR MEM8,IMM8 - Test flags
                        ; Overflow, Sign, Zero, Parity, AUX, Carry

        mov byte [00050],011
        or byte [00050],022  ; Overflow should NEVER be set
        jno PASS_80_1_1   ; If not set, then we passed
        jmp FAIL_80_1_1   ; If set then we fail

PASS_80_1_1:
        mov byte [00050],080
        or byte [00050],000  ; sign should be set
        jns FAIL_80_1_1   ; If not set, then fail

        mov byte [00050],011
        or byte [00050],022  ; sign should NOT be set
        js  FAIL_80_1_1   ; If set then we fail

        mov byte [00050],000
        or byte [00050],00  ; zero should be set
        jne FAIL_80_1_1   ; If not set then we fail
        jmp PASS_80_1_2

FAIL_80_1_1:
        mov dx,00031    ; Print a 1
        mov ax,00202
        int 021
        jmp TEST_80_2_0

PASS_80_1_2:
        mov byte [00050],000
        or byte [00050],001  ; zero should NOT be set
        je  FAIL_80_1_1   ; If set then we fail

        mov byte [00050],001
        or byte [00050],002  ; parity should be set
        jnp FAIL_80_1_1   ; If not set then we fail

        mov byte [00050],001
        or byte [00050],006  ; parity should NOT be set
        jp  FAIL_80_1_1   ; If set then we fail

        mov byte [00050],012
        or byte [00050],034  ; carry should NEVER be set
        jc  FAIL_80_1_1   ; If set then we fail



; 0x80 - ADC MEM8,IMM8
; ############################################################

TEST_80_2_0:             ; ADC MEM8,IMM8 - Test data values from memory

        ; Tests with Carry Bit CLEARED
        ; ----------------------------
        clc
        mov byte [00050],000
        lock adc byte [00050],0FF     ; test lock prefix
        cmp byte [00050],0FF
        jne FAIL_80_2_0

        clc
        mov byte [00050],000
        adc byte [00050],000
        cmp byte [00050],000
        jne FAIL_80_2_0

        clc
        mov byte es:[00052],011 ; test segment override
        adc byte es:[00052],022
        cmp byte es:[00052],033
        jne FAIL_80_2_0

        clc
        mov byte [00053],0FF
        adc byte [00053],0FF
        cmp byte [00053],0FE
        jne FAIL_80_2_0
        jmp TEST_80_2_1

FAIL_80_2_0:
        mov dx,00032    ; Print a 2
        mov ax,00202
        int 021

; ##################

        ; Tests with Carry Bit SET
        ; ------------------------
TEST_80_2_1:
        stc
        mov byte [00050],000
        lock adc byte [00050],0FF     ; test lock prefix
        cmp byte [00050],000
        jne FAIL_80_2_1

        stc
        mov byte [00050],000
        adc byte [00050],000
        cmp byte [00050],001
        jne FAIL_80_2_1

        stc
        mov byte es:[00052],011 ; test segment override
        adc byte es:[00052],022
        cmp byte es:[00052],034
        jne FAIL_80_2_1

        stc
        mov byte [00053],0FF
        adc byte [00053],0FF
        cmp byte [00053],0FF
        jne FAIL_80_2_1
        jmp TEST_80_2_2

FAIL_80_2_1:
        mov dx,00032    ; Print a 2
        mov ax,00202
        int 021

; ##################

TEST_80_2_2:              ; ADC MEM8,IMM8 - Test flags
                        ; Overflow, Sign, Zero, Parity, AUX, Carry

        ; Tests with Carry Bit CLEARED
        ; ----------------------------
        clc
        mov byte [00054],07B
        adc byte [00054],036  ; Overflow should be set
        jno FAIL_80_2_2   ; If not set, then fail

        clc
        mov byte [00055],0B1
        adc byte [00055],037  ; Overflow should NOT be set
        jno PASS_80_2_2   ; If not set, then we passed
        jmp FAIL_80_2_2   ; If set then we fail

PASS_80_2_2:
        clc
        mov byte [00056],0FF
        adc byte [00056],0FF  ; sign should be set
        jns FAIL_80_2_2   ; If not set, then fail

        clc
        mov byte [00057],011
        adc byte [00057],022  ; sign should NOT be set
        js  FAIL_80_2_2   ; If set then we fail

        clc
        mov byte [00058],000
        adc byte [00058],000  ; zero should be set
        jne FAIL_80_2_2   ; If not set then we fail
        jmp PASS_80_2_3

FAIL_80_2_2:
        mov dx,00032    ; Print a 2
        mov ax,00202
        int 021
        jmp PASS_80_2_4

PASS_80_2_3:
        clc
        mov byte [00050],000
        adc byte [00050],001  ; zero should NOT be set
        je  FAIL_80_2_2   ; If set then we fail

        clc
        mov byte [00050],012
        adc byte [00050],035  ; parity should be set
        jnp FAIL_80_2_2   ; If not set then we fail

        clc
        mov byte [00050],012
        adc byte [00050],034  ; parity should NOT be set
        jp  FAIL_80_2_2   ; If set then we fail

        clc
        mov byte [00050],0FF
        adc byte [00050],0FF  ; carry should be set
        jnc FAIL_80_2_2   ; If not set then we fail

        clc
        mov byte [00050],012
        adc byte [00050],034  ; carry should NOT be set
        jc  FAIL_80_2_2   ; If set then we fail


        ; Tests with Carry Bit SET
        ; ------------------------
        stc
        mov byte [00054],001
        adc byte [00054],07F  ; Overflow should be set
        jno FAIL_80_2_3   ; If not set, then fail

        stc
        mov byte [00055],0B1
        adc byte [00055],037  ; Overflow should NOT be set
        jno PASS_80_2_4   ; If not set, then we passed
        jmp FAIL_80_2_3   ; If set then we fail

PASS_80_2_4:
        stc
        mov byte [00056],0FF
        adc byte [00056],0FF  ; sign should be set
        jns FAIL_80_2_3   ; If not set, then fail

        stc
        mov byte [00057],011
        adc byte [00057],022  ; sign should NOT be set
        js  FAIL_80_2_3   ; If set then we fail

        stc
        mov byte [00058],000
        adc byte [00058],0FF  ; zero should be set
        jne FAIL_80_2_3   ; If not set then we fail
        jmp PASS_80_2_5

FAIL_80_2_3:
        mov dx,00030    ; Print a 0
        mov ax,00202
        int 021
        jmp TEST_80_3_0

PASS_80_2_5:
        stc
        mov byte [00050],000
        adc byte [00050],001  ; zero should NOT be set
        je  FAIL_80_2_3   ; If set then we fail

        stc
        mov byte [00050],012
        adc byte [00050],035  ; parity should be set
        jnp FAIL_80_2_3   ; If not set then we fail

        stc
        mov byte [00050],012
        adc byte [00050],036  ; parity should NOT be set
        jp  FAIL_80_2_3   ; If set then we fail

        stc
        mov byte [00050],0FF
        adc byte [00050],0FF  ; carry should be set
        jnc FAIL_80_2_3   ; If not set then we fail

        stc
        mov byte [00050],012
        adc byte [00050],034  ; carry should NOT be set
        jc  FAIL_80_2_3   ; If set then we fail



; 0x80 - SBB MEM8,IMM8
; ############################################################

TEST_80_3_0:             ; SBB MEM8,IMM8 - Test data values from memory

        ; Tests with Carry Bit CLEARED
        ; ----------------------------
        clc
        mov byte [00050],000
        lock sbb byte [00050],0FF     ; test lock prefix
        cmp byte [00050],001
        jne FAIL_80_3_0

        clc
        mov byte [00050],000
        sbb byte [00050],000
        cmp byte [00050],000
        jne FAIL_80_3_0

        clc
        mov byte es:[00052],011 ; test segment override
        sbb byte  es:[00052],022
        cmp byte es:[00052],0EF
        jne FAIL_80_3_0

        clc
        mov byte [00053],0FF
        sbb byte [00053],0FF
        cmp byte [00053],000
        jne FAIL_80_3_0
        jmp TEST_80_3_1

FAIL_80_3_0:
        mov dx,00033    ; Print a 3
        mov ax,00202
        int 021

; ##################

        ; Tests with Carry Bit SET
        ; ------------------------
TEST_80_3_1:
        stc
        mov byte [00050],000
        lock sbb byte [00050],0FF     ; test lock prefix
        cmp byte [00050],000
        jne FAIL_80_3_1

        stc
        mov byte [00050],000
        sbb byte [00050],000
        cmp byte [00050],0FF
        jne FAIL_80_3_1

        stc
        mov byte es:[00052],011 ; test segment override
        sbb byte  es:[00052],022
        cmp byte es:[00052],0EE
        jne FAIL_80_3_1

        stc
        mov byte [00053],0FF
        sbb byte [00053],0FF
        cmp byte [00053],0FF
        jne FAIL_80_3_1
        jmp TEST_80_3_2

FAIL_80_3_1:
        mov dx,00033    ; Print a 3
        mov ax,00202
        int 021

; ##################

TEST_80_3_2:            ; SBB MEM8,IMM8 - Test flags
                        ; Overflow, Sign, Zero, Parity, AUX, Carry

        ; Tests with Carry Bit CLEARED
        ; ----------------------------
        clc
        mov byte [00054],045
        sbb byte [00054],0AD  ; Overflow should be set
        jno FAIL_80_3_2   ; If not set, then fail

        clc
        mov byte [00055],078
        sbb byte [00055],034  ; Overflow should NOT be set
        jno PASS_80_3_2   ; If not set, then we passed
        jmp FAIL_80_3_2   ; If set then we fail

PASS_80_3_2:
        clc
        mov byte [00056],000
        sbb byte [00056],001  ; sign should be set
        jns FAIL_80_3_2   ; If not set, then fail

        clc
        mov byte [00057],011
        sbb byte [00057],002  ; sign should NOT be set
        js  FAIL_80_3_2   ; If set then we fail

        clc
        mov byte [00058],034
        sbb byte [00058],034  ; zero should be set
        jne FAIL_80_3_2   ; If not set then we fail
        jmp PASS_80_3_3

FAIL_80_3_2:
        mov dx,00033    ; Print a 3
        mov ax,00202
        int 021
        jmp PASS_80_3_4

PASS_80_3_3:
        clc
        mov byte [00050],000
        sbb byte [00050],022  ; zero should NOT be set
        je  FAIL_80_3_2   ; If set then we fail

        clc
        mov byte [00050],012
        sbb byte [00050],035  ; parity should be set
        jnp FAIL_80_3_2   ; If not set then we fail

        clc
        mov byte [00050],014
        sbb byte [00050],034  ; parity should NOT be set
        jp  FAIL_80_3_2   ; If set then we fail

        clc
        mov byte [00050],0FE
        sbb byte [00050],0FF  ; carry should be set
        jnc FAIL_80_3_2   ; If not set then we fail

        clc
        mov byte [00050],012
        sbb byte [00050],012  ; carry should NOT be set
        jc  FAIL_80_3_2   ; If set then we fail


        ; Tests with Carry Bit SET
        ; ------------------------
        stc
        mov byte [00054],080
        sbb byte [00054],011  ; Overflow should be set
        jno FAIL_80_3_3   ; If not set, then fail

        stc
        mov byte [00055],000
        sbb byte [00055],002  ; Overflow should NOT be set
        jno PASS_80_3_4   ; If not set, then we passed
        jmp FAIL_80_3_3   ; If set then we fail

PASS_80_3_4:
        stc
        mov byte [00056],0FF
        sbb byte [00056],0FF  ; sign should be set
        jns FAIL_80_3_3   ; If not set, then fail

        stc
        mov byte [00057],044
        sbb byte [00057],022  ; sign should NOT be set
        js  FAIL_80_3_3   ; If set then we fail

        stc
        mov byte [00058],001
        sbb byte [00058],000  ; zero should be set
        jne FAIL_80_3_3   ; If not set then we fail
        jmp PASS_80_3_5

FAIL_80_3_3:
        mov dx,00033    ; Print a 3
        mov ax,00202
        int 021
        jmp TEST_80_4_0

PASS_80_3_5:
        stc
        mov byte [00050],000
        sbb byte [00050],001  ; zero should NOT be set
        je  FAIL_80_3_3   ; If set then we fail

        stc
        mov byte [00050],012
        sbb byte [00050],034  ; parity should be set
        jnp FAIL_80_3_3   ; If not set then we fail

        stc
        mov byte [00050],012
        sbb byte [00050],035  ; parity should NOT be set
        jp  FAIL_80_3_3   ; If set then we fail

        stc
        mov byte [00050],0FF
        sbb byte [00050],0FF  ; carry should be set
        jnc FAIL_80_3_3   ; If not set then we fail

        stc
        mov byte [00050],066
        sbb byte [00050],022  ; carry should NOT be set
        jc  FAIL_80_3_3   ; If set then we fail


                   
; 0x80 - AND MEM8,IMM8
; ############################################################

TEST_80_4_0:             ; AND MEM8,IMM8 - Test data values from memory

        mov byte [00050],05A
        lock and byte [00050],0A5
        cmp byte [00050],000
        jne FAIL_80_4_0

        mov byte [00050],0FF
        and byte [00050],011
        cmp byte [00050],011
        jne FAIL_80_4_0

        mov byte es:[00050],081
        and byte es:[00050],018
        cmp byte es:[00050],000
        jne FAIL_80_4_0
        jmp TEST_80_4_1


FAIL_80_4_0:
        mov dx,00034    ; Print a 4
        mov ax,00202
        int 021

; ##################
TEST_80_4_1:            ; AND MEM8,IMM8 - Test flags
                        ; Overflow, Sign, Zero, Parity, AUX, Carry

        mov byte [00050],011
        and byte [00050],022  ; Overflow should NEVER be set
        jno PASS_80_4_1   ; If not set, then we passed
        jmp FAIL_80_4_1   ; If set then we fail

PASS_80_4_1:
        mov byte [00050],080
        and byte [00050],080  ; sign should be set
        jns FAIL_80_4_1   ; If not set, then fail

        mov byte [00050],0FF
        and byte [00050],07F  ; sign should NOT be set
        js  FAIL_80_4_1   ; If set then we fail

        mov byte [00050],000
        and byte [00050],0FF  ; zero should be set
        jne FAIL_80_4_1   ; If not set then we fail
        jmp PASS_80_4_2

FAIL_80_4_1:
        mov dx,00034    ; Print a 4
        mov ax,00202
        int 021
        jmp TEST_80_5_0

PASS_80_4_2:
        mov byte [00050],0FF
        and byte [00050],001  ; zero should NOT be set
        je  FAIL_80_4_1   ; If set then we fail

        mov byte [00050],003
        and byte [00050],003  ; parity should be set
        jnp FAIL_80_4_1   ; If not set then we fail

        mov byte [00050],003
        and byte [00050],001  ; parity should NOT be set
        jp  FAIL_80_4_1   ; If set then we fail

        mov byte [00050],012
        and byte [00050],034  ; carry should NEVER be set
        jc  FAIL_80_4_1   ; If set then we fail


; 0x28 - SUB MEM8,IMM8
; ############################################################

TEST_80_5_0:             ; SUB MEM8,IMM8 - Test data values from memory

        mov byte [00050],088
        lock sub byte [00050],011     ; test lock prefix
        cmp byte [00050],077
        jne FAIL_80_5_0

        mov byte [00050],000
        sub byte [00050],000
        cmp byte [00050],000
        jne FAIL_80_5_0

        mov byte es:[00052],022 ; test segment override
        sub byte es:[00052],011
        cmp byte es:[00052],011
        jne FAIL_80_5_0

        mov byte [00053],000
        sub byte [00053],001
        cmp byte [00053],0FF
        jne FAIL_80_5_0
        jmp TEST_80_5_1

FAIL_80_5_0:
        mov dx,00035    ; Print a 5
        mov ax,00202
        int 021

; ##################
TEST_80_5_1:              ; SUB MEM8,IMM8 - Test flags
                        ; Overflow, Sign, Zero, Parity, AUX, Carry

        mov byte [00054],080
        sub byte [00054],066  ; Overflow should be set
        jno FAIL_80_5_1   ; If not set, then fail

        mov byte [00055],034
        sub byte [00055],012  ; Overflow should NOT be set
        jno PASS_80_5_1   ; If not set, then we passed
        jmp FAIL_80_5_1   ; If set then we fail

PASS_80_5_1:
        mov byte [00056],000
        sub byte [00056],001  ; sign should be set
        jns FAIL_80_5_1   ; If not set, then fail

        mov byte [00057],022
        sub byte [00057],011  ; sign should NOT be set
        js  FAIL_80_5_1   ; If set then we fail

        mov byte [00058],001
        mov ax,00001
        sub byte [00058],001  ; zero should be set
        jne FAIL_80_5_1   ; If not set then we fail
        jmp PASS_80_5_2

FAIL_80_5_1:
        mov dx,00035    ; Print a 5
        mov ax,00202
        int 021
        jmp TEST_80_6_0

PASS_80_5_2:
        mov byte [00050],055
        sub byte [00050],011  ; zero should NOT be set
        je  FAIL_80_5_1   ; If set then we fail

        mov byte [00050],034
        sub byte [00050],001  ; parity should be set
        jnp FAIL_80_5_1   ; If not set then we fail

        mov byte [00050],032
        sub byte [00050],001  ; parity should NOT be set
        jp  FAIL_80_5_1   ; If set then we fail

        mov byte [00050],000
        sub byte [00050],001  ; carry should be set
        jnc FAIL_80_5_1   ; If not set then we fail

        mov byte [00050],031
        sub byte [00050],011  ; carry should NOT be set
        jc  FAIL_80_5_1   ; If set then we fail

                   
; 0x80 - XOR MEM8,IMM8
; ############################################################

TEST_80_6_0:             ; XOR MEM8,IMM8 - Test data values from memory

        mov byte [00050],05A
        lock xor byte [00050],0A5
        cmp byte byte [00050],0FF
        jne FAIL_80_6_0

        mov byte [00050],000
        xor byte [00050],000
        cmp byte byte [00050],000
        jne FAIL_80_6_0

        mov byte es:[00050],080
        xor byte es:[00050],001
        cmp byte byte es:[00050],081
        jne FAIL_80_6_0
        jmp TEST_80_6_1


FAIL_80_6_0:
        mov dx,00036    ; Print a 6
        mov ax,00202
        int 021

; ##################
TEST_80_6_1:              ; XOR MEM8,IMM8 - Test flags
                        ; Overflow, Sign, Zero, Parity, AUX, Carry

        mov byte [00050],0FF
        xor byte [00050],07F  ; Overflow should NEVER be set
        jno PASS_80_6_1   ; If not set, then we passed
        jmp FAIL_80_6_1   ; If set then we fail

PASS_80_6_1:
        mov byte [00050],080
        xor byte [00050],000  ; sign should be set
        jns FAIL_80_6_1   ; If not set, then fail

        mov byte [00050],011
        xor byte [00050],022  ; sign should NOT be set
        js  FAIL_80_6_1   ; If set then we fail

        mov byte [00050],05A
        xor byte [00050],05A  ; zero should be set
        jne FAIL_80_6_1   ; If not set then we fail
        jmp PASS_80_6_2

FAIL_80_6_1:
        mov dx,00036    ; Print a 6
        mov ax,00202
        int 021
        jmp TEST_80_7_0

PASS_80_6_2:
        mov byte [00050],000
        xor byte [00050],001  ; zero should NOT be set
        je  FAIL_80_6_1   ; If set then we fail

        mov byte [00050],001
        xor byte [00050],002  ; parity should be set
        jnp FAIL_80_6_1   ; If not set then we fail

        mov byte [00050],001
        xor byte [00050],006  ; parity should NOT be set
        jp  FAIL_80_6_1   ; If set then we fail

        mov byte [00050],012
        xor byte [00050],034  ; carry should NEVER be set
        jc  FAIL_80_6_1   ; If set then we fail



; 0x80 - CMP MEM8,IMM8
; ############################################################

TEST_80_7_0:             ; CMP MEM8,IMM8 - Test data values from memory

        mov byte [00050],012
        lock cmp byte [00050],012     ; test lock prefix
        jne FAIL_80_7_0

        mov byte [00050],000
        cmp byte [00050],000
        jne FAIL_80_7_0

        mov byte es:[00052],011 ; test segment override
        cmp byte es:[00052],011
        jne FAIL_80_7_0

        mov byte [00053],0FF
        cmp byte [00053],0FF
        jne FAIL_80_7_0
        jmp TEST_80_7_1

FAIL_80_7_0:
        mov dx,00037    ; Print a 7
        mov ax,00202
        int 021

; ##################
TEST_80_7_1:              ; CMP MEM8,IMM8 - Test flags
                        ; Overflow, Sign, Zero, Parity, AUX, Carry

        mov byte [00054],001
        cmp byte [00054],080  ; Overflow should be set
        jno FAIL_80_7_1   ; If not set, then fail

        mov byte [00055],001
        cmp byte [00055],030  ; Overflow should NOT be set
        jno PASS_80_7_1   ; If not set, then we passed
        jmp FAIL_80_7_1   ; If set then we fail

PASS_80_7_1:
        mov byte [00056],0FF
        cmp byte [00056],001  ; sign should be set
        jns FAIL_80_7_1   ; If not set, then fail

        mov byte [00057],011
        cmp byte [00057],001  ; sign should NOT be set
        js  FAIL_80_7_1   ; If set then we fail

        mov byte [00058],034
        cmp byte [00058],034  ; zero should be set
        jne FAIL_80_7_1   ; If not set then we fail
        jmp PASS_80_7_2

FAIL_80_7_1:
        mov dx,00037    ; Print a 7
        mov ax,00202
        int 021
        jmp Z_END

PASS_80_7_2:
        mov byte [00050],000
        cmp byte [00050],001  ; zero should NOT be set
        je  FAIL_80_7_1   ; If set then we fail

        mov byte [00050],044
        cmp byte [00050],000  ; parity should be set
        jnp FAIL_80_7_1   ; If not set then we fail

        mov byte [00050],044
        cmp byte [00050],001  ; parity should NOT be set
        jp  FAIL_80_7_1   ; If set then we fail

        mov byte [00050],000
        cmp byte [00050],001  ; carry should be set
        jnc FAIL_80_7_1   ; If not set then we fail

        mov byte [00050],012
        cmp byte [00050],001  ; carry should NOT be set
        jc  FAIL_80_7_1   ; If set then we fail


; xxxxxxxxxxxxxxxxxxxxxxx
; End
; xxxxxxxxxxxxxxxxxxxxxxx
Z_END:
        mov ax,00000    ; DOS Command=Exit
        int 021



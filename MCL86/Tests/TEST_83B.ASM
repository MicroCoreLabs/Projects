; Tests for opcode range 0x83 with second word=0x0-0x7
; These tests are for REG16,IMM16
; ----------------------------------------------------

        mov ax,es       ; Increment ES so it is not the same as DS
        inc ax
        mov es,ax


; 0x83 - ADD REG16,IMM16
; ############################################################

TEST_83_0_0:             ; Test from Memory

        mov dx,01234
        lock add dx,0FFFF     ; test lock prefix
        cmp dx,01233
        jne FAIL_83_0_0

        mov dx,01234
        add dx,00000
        cmp dx,01234
        jne FAIL_83_0_0

        mov dx,00001 ; test segment override
        jne FAIL_83_0_0
        jmp TEST_83_0_1

FAIL_83_0_0:
        mov dx,00030    ; Print a 0
        mov ax,00202
        int 021


TEST_83_0_1:              ; ADD REG16,IMM16 - Test flags
                        ; Overflow, Sign, Zero, Parity, AUX, Carry

        mov dx,07FFF
        add dx,00001  ; Overflow should be set
        jno FAIL_83_0_1   ; If not set, then fail

        mov dx,01234
        add dx,00022  ; Overflow should NOT be set
        jno PASS_83_0_1   ; If not set, then we passed
        jmp FAIL_83_0_1   ; If set then we fail

PASS_83_0_1:
        mov dx,07FFF
        add dx,00034  ; sign should be set
        jns FAIL_83_0_1   ; If not set, then fail

        mov dx,01111
        add dx,00022  ; sign should NOT be set
        js  FAIL_83_0_1   ; If set then we fail

        mov dx,00000
        add dx,00000  ; zero should be set
        jne FAIL_83_0_1   ; If not set then we fail
        jmp TEST_83_2_0

FAIL_83_0_1:
        mov dx,00030    ; Print a 0
        mov ax,00202
        int 021


; 0x83 - ADC REG16,IMM16
; ############################################################

TEST_83_2_0:             ; ADC REG16,IMM16 - Test data values from memory

        ; Tests with Carry Bit CLEARED
        ; ----------------------------
        clc
        mov dx,0F3FF
        lock adc dx,00000     ; test lock prefix
        cmp dx,0F3FF
        jne FAIL_83_2_0

        clc
        mov dx,01200
        adc dx,00000
        cmp dx,01200
        jne FAIL_83_2_0

        clc
        mov dx,00011 ; test segment override
        jne FAIL_83_2_0

        clc
        mov dx,012FF
        adc dx,0FFFF
        cmp dx,012FE
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
        mov dx,01200
        lock adc dx,00000     ; test lock prefix
        cmp dx,01201
        jne FAIL_83_2_1

        stc
        mov dx,01234
        adc dx,00000
        cmp dx,01235
        jne FAIL_83_2_1

        stc
        mov dx,00011 ; test segment override
        jne FAIL_83_2_1

        stc
        mov dx,01234
        adc dx,0FFFF
        cmp dx,01234
        jne FAIL_83_2_1
        jmp TEST_83_2_2

FAIL_83_2_1:
        mov dx,00032    ; Print a 2
        mov ax,00202
        int 021

; ##################

TEST_83_2_2:              ; ADC REG16,IMM16 - Test flags
                        ; Overflow, Sign, Zero, Parity, AUX, Carry

        ; Tests with Carry Bit CLEARED
        ; ----------------------------
        clc
        mov dx,07FFF
        adc dx,00001  ; Overflow should be set
        jno FAIL_83_2_2   ; If not set, then fail

        clc
        mov dx,01111
        adc dx,00002  ; Overflow should NOT be set
        jno PASS_83_2_2   ; If not set, then we passed
        jmp FAIL_83_2_2   ; If set then we fail

PASS_83_2_2:
        clc
        mov dx,07FFF
        adc dx,00001  ; sign should be set
        jns FAIL_83_2_2   ; If not set, then fail

        clc
        mov dx,01111
        adc dx,00022  ; sign should NOT be set
        js  FAIL_83_2_2   ; If set then we fail

        clc
        mov dx,0FF01
        adc dx,000FF  ; zero should be set
        jne FAIL_83_2_2   ; If not set then we fail
        jmp PASS_83_2_3

FAIL_83_2_2:
        mov dx,00032    ; Print a 2
        mov ax,00202
        int 021
        jmp PASS_83_2_4

PASS_83_2_3:
        clc
        mov dx,03001
        adc dx,00000  ; zero should NOT be set
        je  FAIL_83_2_2   ; If set then we fail

        clc
        mov dx,01122
        adc dx,00011  ; parity should be set
        jnp FAIL_83_2_2   ; If not set then we fail

        clc
        mov dx,01121
        adc dx,00011  ; parity should NOT be set
        jp  FAIL_83_2_2   ; If set then we fail

        clc
        mov dx,02201
        adc dx,0FFFF  ; carry should be set
        jnc FAIL_83_2_2   ; If not set then we fail

        clc
        mov dx,00022
        adc dx,00033  ; carry should NOT be set
        jc  FAIL_83_2_2   ; If set then we fail


        ; Tests with Carry Bit SET
        ; ------------------------
        stc
        mov dx,07FFF
        adc dx,00001  ; Overflow should be set
        jno FAIL_83_2_3   ; If not set, then fail

        stc
        mov dx,01111
        adc dx,00022  ; Overflow should NOT be set
        jno PASS_83_2_4   ; If not set, then we passed
        jmp FAIL_83_2_3   ; If set then we fail

PASS_83_2_4:
        stc
        mov dx,07FFE
        adc dx,00001  ; sign should be set
        jns FAIL_83_2_3   ; If not set, then fail

        stc
        mov dx,01111
        adc dx,00022  ; sign should NOT be set
        js  FAIL_83_2_3   ; If set then we fail

        stc
        mov dx,0FFFF
        adc dx,00000  ; zero should be set
        jne FAIL_83_2_3   ; If not set then we fail
        jmp PASS_83_2_5

FAIL_83_2_3:
        mov dx,00032    ; Print a 2
        mov ax,00202
        int 021
        jmp TEST_83_3_0

PASS_83_2_5:
        stc
        mov dx,01234
        adc dx,00000  ; zero should NOT be set
        je  FAIL_83_2_3   ; If set then we fail

        stc
        mov dx,00010
        adc dx,00022  ; parity should be set
        jnp FAIL_83_2_3   ; If not set then we fail

        stc
        mov dx,00011
        adc dx,00022  ; parity should NOT be set
        jp  FAIL_83_2_3   ; If set then we fail

        stc
        mov dx,01000
        adc dx,0FFFF  ; carry should be set
        jnc FAIL_83_2_3   ; If not set then we fail

        stc
        mov dx,00011
        adc dx,00022  ; carry should NOT be set
        jc  FAIL_83_2_3   ; If set then we fail



; 0x83 - SBB REG16,IMM16
; ############################################################

TEST_83_3_0:             ; SBB REG16,IMM16 - Test data values from memory

        ; Tests with Carry Bit CLEARED
        ; ----------------------------
        clc
        mov dx,01234
        lock sbb dx,00001     ; test lock prefix
        cmp dx,01233
        jne FAIL_83_3_0

        clc
        mov dx,00000
        sbb dx,00000
        cmp dx,00000
        jne FAIL_83_3_0

        clc
        mov dx,02222 ; test segment override
        jne FAIL_83_3_0

        clc
        mov dx,0FF00
        sbb dx,00000
        cmp dx,0FF00
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
        mov dx,01235
        lock sbb dx,00000     ; test lock prefix
        cmp dx,01234
        jne FAIL_83_3_1

        stc
        mov dx,01234
        sbb dx,00000
        cmp dx,01233
        jne FAIL_83_3_1

        stc
        mov dx,02222 ; test segment override
        jne FAIL_83_3_1

        stc
        mov dx,0FFFF
        sbb dx,00001
        cmp dx,0FFFD
        jne FAIL_83_3_1
        jmp TEST_83_3_2

FAIL_83_3_1:
        mov dx,00033    ; Print a 3
        mov ax,00202
        int 021

; ##################

TEST_83_3_2:            ; SBB REG16,IMM16 - Test flags
                        ; Overflow, Sign, Zero, Parity, AUX, Carry

        ; Tests with Carry Bit CLEARED
        ; ----------------------------
        clc
        mov dx,08000
        sbb dx,00001  ; Overflow should be set
        jno FAIL_83_3_2   ; If not set, then fail

        clc
        mov dx,07800
        sbb dx,00000  ; Overflow should NOT be set
        jno PASS_83_3_2   ; If not set, then we passed
        jmp FAIL_83_3_2   ; If set then we fail

PASS_83_3_2:
        clc
        mov dx,08FFF
        sbb dx,00001  ; sign should be set
        jns FAIL_83_3_2   ; If not set, then fail

        clc
        mov dx,01111
        sbb dx,00001  ; sign should NOT be set
        js  FAIL_83_3_2   ; If set then we fail

        clc
        mov dx,00034
        sbb dx,00034  ; zero should be set
        jne FAIL_83_3_2   ; If not set then we fail
        jmp PASS_83_3_3

FAIL_83_3_2:
        mov dx,00033    ; Print a 3
        mov ax,00202
        int 021
        jmp PASS_83_3_4

PASS_83_3_3:
        clc
        mov dx,04444
        sbb dx,00022  ; zero should NOT be set
        je  FAIL_83_3_2   ; If set then we fail

        clc
        mov dx,04444
        sbb dx,00011  ; parity should be set
        jnp FAIL_83_3_2   ; If not set then we fail

        clc
        mov dx,04444
        sbb dx,00010  ; parity should NOT be set
        jp  FAIL_83_3_2   ; If set then we fail

        clc
        mov dx,00000
        sbb dx,00001  ; carry should be set
        jnc FAIL_83_3_2   ; If not set then we fail

        clc
        mov dx,01234
        sbb dx,00012  ; carry should NOT be set
        jc  FAIL_83_3_2   ; If set then we fail


        ; Tests with Carry Bit SET
        ; ------------------------
        stc
        mov dx,08000
        sbb dx,00000  ; Overflow should be set
        jno FAIL_83_3_3   ; If not set, then fail

        stc
        mov dx,03333
        sbb dx,00011  ; Overflow should NOT be set
        jno PASS_83_3_4   ; If not set, then we passed
        jmp FAIL_83_3_3   ; If set then we fail

PASS_83_3_4:
        stc
        mov dx,00001
        sbb dx,00001  ; sign should be set
        jns FAIL_83_3_3   ; If not set, then fail

        stc
        mov dx,04444
        sbb dx,00022  ; sign should NOT be set
        js  FAIL_83_3_3   ; If set then we fail

        stc
        mov dx,00001
        sbb dx,00000  ; zero should be set
        jne FAIL_83_3_3   ; If not set then we fail
        jmp PASS_83_3_5

FAIL_83_3_3:
        mov dx,00033    ; Print a 3
        mov ax,00202
        int 021
        jmp TEST_83_5_0

PASS_83_3_5:
        stc
        mov dx,01111
        sbb dx,00001  ; zero should NOT be set
        je  FAIL_83_3_3   ; If set then we fail

        stc
        mov dx,04444
        sbb dx,00013  ; parity should be set
        jnp FAIL_83_3_3   ; If not set then we fail

        stc
        mov dx,04448
        sbb dx,00013  ; parity should NOT be set
        jp  FAIL_83_3_3   ; If set then we fail

        stc
        mov dx,00000
        sbb dx,00000  ; carry should be set
        jnc FAIL_83_3_3   ; If not set then we fail

        stc
        mov dx,06666
        sbb dx,00022  ; carry should NOT be set
        jc  FAIL_83_3_3   ; If set then we fail



; 0x28 - SUB REG16,IMM16
; ############################################################

TEST_83_5_0:             ; SUB REG16,IMM16 - Test data values from memory

        mov dx,08888
        lock sub dx,00011     ; test lock prefix
        cmp dx,08877
        jne FAIL_83_5_0

        mov dx,01222
        sub dx,00022
        cmp dx,01200
        jne FAIL_83_5_0

        mov dx,02222 ; test segment override
        jne FAIL_83_5_0

        mov dx,00000
        sub dx,00001
        cmp dx,0FFFF
        jne FAIL_83_5_0
        jmp TEST_83_5_1

FAIL_83_5_0:
        mov dx,00035    ; Print a 5
        mov ax,00202
        int 021

; ##################
TEST_83_5_1:              ; SUB REG16,IMM16 - Test flags
                        ; Overflow, Sign, Zero, Parity, AUX, Carry

        mov dx,08000
        sub dx,00001  ; Overflow should be set
        jno FAIL_83_5_1   ; If not set, then fail

        mov dx,01234
        sub dx,00034  ; Overflow should NOT be set
        jno PASS_83_5_1   ; If not set, then we passed
        jmp FAIL_83_5_1   ; If set then we fail

PASS_83_5_1:
        mov dx,00000
        sub dx,00001  ; sign should be set
        jns FAIL_83_5_1   ; If not set, then fail

        mov dx,02222
        sub dx,00011  ; sign should NOT be set
        js  FAIL_83_5_1   ; If set then we fail

        mov dx,00011
        sub dx,00011  ; zero should be set
        jne FAIL_83_5_1   ; If not set then we fail
        jmp PASS_83_5_2

FAIL_83_5_1:
        mov dx,00035    ; Print a 5
        mov ax,00202
        int 021
        jmp TEST_83_7_0

PASS_83_5_2:
        mov dx,05555
        sub dx,00011  ; zero should NOT be set
        je  FAIL_83_5_1   ; If set then we fail

        mov dx,00034
        sub dx,00001  ; parity should be set
        jnp FAIL_83_5_1   ; If not set then we fail

        mov dx,00032
        sub dx,00001  ; parity should NOT be set
        jp  FAIL_83_5_1   ; If set then we fail

        mov dx,00000
        sub dx,00001  ; carry should be set
        jnc FAIL_83_5_1   ; If not set then we fail

        mov dx,04031
        sub dx,00011  ; carry should NOT be set
        jc  FAIL_83_5_1   ; If set then we fail



; 0x83 - CMP REG16,IMM16
; ############################################################

TEST_83_7_0:             ; CMP REG16,IMM16 - Test data values from memory

        mov dx,00012
        lock cmp dx,00012     ; test lock prefix
        jne FAIL_83_7_0

        mov dx,00200
        cmp dx,00200
        jne FAIL_83_7_0

        mov dx,00011 ; test segment override
        jne FAIL_83_7_0

        mov dx,000FF
        cmp dx,000FF
        jne FAIL_83_7_0
        jmp TEST_83_7_1

FAIL_83_7_0:
        mov dx,00037    ; Print a 7
        mov ax,00202
        int 021

; ##################
TEST_83_7_1:              ; CMP REG16,IMM16 - Test flags
                        ; Overflow, Sign, Zero, Parity, AUX, Carry

        mov dx,08000
        cmp dx,00001  ; Overflow should be set
        jno FAIL_83_7_1   ; If not set, then fail

        mov dx,02222
        cmp dx,00011  ; Overflow should NOT be set
        jno PASS_83_7_1   ; If not set, then we passed
        jmp FAIL_83_7_1   ; If set then we fail

PASS_83_7_1:
        mov dx,0FFFF
        cmp dx,00001  ; sign should be set
        jns FAIL_83_7_1   ; If not set, then fail

        mov dx,01111
        cmp dx,00001  ; sign should NOT be set
        js  FAIL_83_7_1   ; If set then we fail

        mov dx,00034
        cmp dx,00034  ; zero should be set
        jne FAIL_83_7_1   ; If not set then we fail
        jmp PASS_83_7_2

FAIL_83_7_1:
        mov dx,00037    ; Print a 7
        mov ax,00202
        int 021
        jmp Z_END

PASS_83_7_2:
        mov dx,01100
        cmp dx,00001  ; zero should NOT be set
        je  FAIL_83_7_1   ; If set then we fail

        mov dx,00044
        cmp dx,00000  ; parity should be set
        jnp FAIL_83_7_1   ; If not set then we fail

        mov dx,00044
        cmp dx,00001  ; parity should NOT be set
        jp  FAIL_83_7_1   ; If set then we fail

        mov dx,00000
        cmp dx,00001  ; carry should be set
        jnc FAIL_83_7_1   ; If not set then we fail

        mov dx,01234
        cmp dx,00001  ; carry should NOT be set
        jc  FAIL_83_7_1   ; If set then we fail


; xxxxxxxxxxxxxxxxxxxxxxx
; End
; xxxxxxxxxxxxxxxxxxxxxxx
Z_END:
        mov ax,00000    ; DOS Command=Exit
        int 021



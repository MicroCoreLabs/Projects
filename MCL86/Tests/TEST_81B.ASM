; Tests for opcode range 0x81 with second word=0x0-0x7
; These tests are for REG16,IMM16
; ----------------------------------------------------

        mov ax,es       ; Increment ES so it is not the same as DS
        inc ax
        mov es,ax


; 0x81 - ADD REG16,IMM16
; ############################################################

TEST_81_0_0:             ; Test from Memory

        mov dx,0FFFF
        lock add dx,01234     ; test lock prefix
        cmp dx,01233
        jne FAIL_81_0_0

        mov dx,00000
        add dx,01234
        cmp dx,01234
        jne FAIL_81_0_0

        mov dx,01111 ; test segment override
        add dx,02222
        cmp dx,03333
        jne FAIL_81_0_0
        jmp TEST_81_0_1

FAIL_81_0_0:
        mov dx,00030    ; Print a 0
        mov ax,00202
        int 021


TEST_81_0_1:              ; ADD REG16,IMM16 - Test flags
                        ; Overflow, Sign, Zero, Parity, AUX, Carry

        mov dx,000FF
        add dx,07FFF  ; Overflow should be set
        jno FAIL_81_0_1   ; If not set, then fail

        mov dx,00022
        add dx,01234  ; Overflow should NOT be set
        jno PASS_81_0_1   ; If not set, then we passed
        jmp FAIL_81_0_1   ; If set then we fail

PASS_81_0_1:
        mov dx,07FFF
        add dx,00001  ; sign should be set
        jns FAIL_81_0_1   ; If not set, then fail

        mov dx,01111
        add dx,02222  ; sign should NOT be set
        js  FAIL_81_0_1   ; If set then we fail

        mov dx,00100
        add dx,0FF00  ; zero should be set
        jne FAIL_81_0_1   ; If not set then we fail
        jmp TEST_81_1_0

FAIL_81_0_1:
        mov dx,00030    ; Print a 0
        mov ax,00202
        int 021


; 0x81 - OR REG16,IMM16
; ############################################################

TEST_81_1_0:             ; OR REG16,IMM16 - Test data values from memory

        mov ax,es       ; Increment ES so it is not the same as DS
        inc ax
        mov es,ax

        mov dx,05A5A
        lock or dx,0A5A5
        cmp dx,0FFFF
        jne FAIL_81_1_0

        mov dx,00000
        or dx,01234
        cmp dx,01234
        jne FAIL_81_1_0

        mov dx,05500
        or dx,05555
        cmp dx,05555
        jne FAIL_81_1_0
        jmp TEST_81_1_1


FAIL_81_1_0:
        mov dx,00031    ; Print a 1
        mov ax,00202
        int 021

; ##################
TEST_81_1_1:              ; OR REG16,IMM16 - Test flags
                        ; Overflow, Sign, Zero, Parity, AUX, Carry

        mov dx,01111
        or dx,02222  ; Overflow should NEVER be set
        jno PASS_81_1_1   ; If not set, then we passed
        jmp FAIL_81_1_1   ; If set then we fail

PASS_81_1_1:
        mov dx,08000
        or dx,01234  ; sign should be set
        jns FAIL_81_1_1   ; If not set, then fail

        mov dx,01111
        or dx,02222  ; sign should NOT be set
        js  FAIL_81_1_1   ; If set then we fail

        mov dx,00000
        or dx,00000  ; zero should be set
        jne FAIL_81_1_1   ; If not set then we fail
        jmp PASS_81_1_2

FAIL_81_1_1:
        mov dx,00031    ; Print a 1
        mov ax,00202
        int 021
        jmp TEST_81_2_0

PASS_81_1_2:
        mov dx,00000
        or dx,01234  ; zero should NOT be set
        je  FAIL_81_1_1   ; If set then we fail

        mov dx,01111
        or dx,02222  ; parity should be set
        jnp FAIL_81_1_1   ; If not set then we fail

        mov dx,00010
        or dx,03400  ; parity should NOT be set
        jp  FAIL_81_1_1   ; If set then we fail

        mov dx,01112
        or dx,02234  ; carry should NEVER be set
        jc  FAIL_81_1_1   ; If set then we fail



; 0x81 - ADC REG16,IMM16
; ############################################################

TEST_81_2_0:             ; ADC REG16,IMM16 - Test data values from memory

        ; Tests with Carry Bit CLEARED
        ; ----------------------------
        clc
        mov dx,00000
        lock adc dx,0F3FF     ; test lock prefix
        cmp dx,0F3FF
        jne FAIL_81_2_0

        clc
        mov dx,00000
        adc dx,01200
        cmp dx,01200
        jne FAIL_81_2_0

        clc
        mov dx,01111 ; test segment override
        adc dx,02222
        cmp dx,03333
        jne FAIL_81_2_0

        clc
        mov dx,0FFFF
        adc dx,012FF
        cmp dx,012FE
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
        mov dx,00000
        lock adc dx,01200     ; test lock prefix
        cmp dx,01201
        jne FAIL_81_2_1

        stc
        mov dx,00000
        adc dx,01234
        cmp dx,01235
        jne FAIL_81_2_1

        stc
        mov dx,01111 ; test segment override
        adc dx,02222
        cmp dx,03334
        jne FAIL_81_2_1

        stc
        mov dx,0FFFF
        adc dx,01234
        cmp dx,01234
        jne FAIL_81_2_1
        jmp TEST_81_2_2

FAIL_81_2_1:
        mov dx,00032    ; Print a 2
        mov ax,00202
        int 021

; ##################

TEST_81_2_2:              ; ADC REG16,IMM16 - Test flags
                        ; Overflow, Sign, Zero, Parity, AUX, Carry

        ; Tests with Carry Bit CLEARED
        ; ----------------------------
        clc
        mov dx,00001
        adc dx,07FFF  ; Overflow should be set
        jno FAIL_81_2_2   ; If not set, then fail

        clc
        mov dx,00002
        adc dx,01111  ; Overflow should NOT be set
        jno PASS_81_2_2   ; If not set, then we passed
        jmp FAIL_81_2_2   ; If set then we fail

PASS_81_2_2:
        clc
        mov dx,00001
        adc dx,07FFF  ; sign should be set
        jns FAIL_81_2_2   ; If not set, then fail

        clc
        mov dx,01111
        adc dx,02222  ; sign should NOT be set
        js  FAIL_81_2_2   ; If set then we fail

        clc
        mov dx,00100
        adc dx,0FF00  ; zero should be set
        jne FAIL_81_2_2   ; If not set then we fail
        jmp PASS_81_2_3

FAIL_81_2_2:
        mov dx,00032    ; Print a 2
        mov ax,00202
        int 021
        jmp PASS_81_2_4

PASS_81_2_3:
        clc
        mov dx,00000
        adc dx,03001  ; zero should NOT be set
        je  FAIL_81_2_2   ; If set then we fail

        clc
        mov dx,00011
        adc dx,01122  ; parity should be set
        jnp FAIL_81_2_2   ; If not set then we fail

        clc
        mov dx,00011
        adc dx,01121  ; parity should NOT be set
        jp  FAIL_81_2_2   ; If set then we fail

        clc
        mov dx,0FFFF
        adc dx,02201  ; carry should be set
        jnc FAIL_81_2_2   ; If not set then we fail

        clc
        mov dx,01222
        adc dx,03433  ; carry should NOT be set
        jc  FAIL_81_2_2   ; If set then we fail


        ; Tests with Carry Bit SET
        ; ------------------------
        stc
        mov dx,07FFF
        adc dx,00201  ; Overflow should be set
        jno FAIL_81_2_3   ; If not set, then fail

        stc
        mov dx,01111
        adc dx,02222  ; Overflow should NOT be set
        jno PASS_81_2_4   ; If not set, then we passed
        jmp FAIL_81_2_3   ; If set then we fail

PASS_81_2_4:
        stc
        mov dx,07FFE
        adc dx,00201  ; sign should be set
        jns FAIL_81_2_3   ; If not set, then fail

        stc
        mov dx,01111
        adc dx,02222  ; sign should NOT be set
        js  FAIL_81_2_3   ; If set then we fail

        stc
        mov dx,0EEEF
        adc dx,01110  ; zero should be set
        jne FAIL_81_2_3   ; If not set then we fail
        jmp PASS_81_2_5

FAIL_81_2_3:
        mov dx,00032    ; Print a 2
        mov ax,00202
        int 021
        jmp TEST_81_3_0

PASS_81_2_5:
        stc
        mov dx,00000
        adc dx,01234  ; zero should NOT be set
        je  FAIL_81_2_3   ; If set then we fail

        stc
        mov dx,02210
        adc dx,02222  ; parity should be set
        jnp FAIL_81_2_3   ; If not set then we fail

        stc
        mov dx,02211
        adc dx,02222  ; parity should NOT be set
        jp  FAIL_81_2_3   ; If set then we fail

        stc
        mov dx,0FFFF
        adc dx,02000  ; carry should be set
        jnc FAIL_81_2_3   ; If not set then we fail

        stc
        mov dx,01111
        adc dx,02222  ; carry should NOT be set
        jc  FAIL_81_2_3   ; If set then we fail



; 0x81 - SBB REG16,IMM16
; ############################################################

TEST_81_3_0:             ; SBB REG16,IMM16 - Test data values from memory

        ; Tests with Carry Bit CLEARED
        ; ----------------------------
        clc
        mov dx,00000
        lock sbb dx,01201     ; test lock prefix
        cmp dx,0EDFF
        jne FAIL_81_3_0

        clc
        mov dx,00000
        sbb dx,01200
        cmp dx,0EE00
        jne FAIL_81_3_0

        clc
        mov dx,02222 ; test segment override
        sbb dx,01111
        cmp dx,01111
        jne FAIL_81_3_0

        clc
        mov dx,0FF00
        sbb dx,0FF00
        cmp dx,00000
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
        mov dx,01235
        lock sbb dx,01234     ; test lock prefix
        cmp dx,00000
        jne FAIL_81_3_1

        stc
        mov dx,01234
        sbb dx,00000
        cmp dx,01233
        jne FAIL_81_3_1

        stc
        mov dx,01111 ; test segment override
        sbb dx,02222
        cmp dx,0EEEE
        jne FAIL_81_3_1

        stc
        mov dx,0FFFF
        sbb dx,01234
        cmp dx,0EDCA
        jne FAIL_81_3_1
        jmp TEST_81_3_2

FAIL_81_3_1:
        mov dx,00033    ; Print a 3
        mov ax,00202
        int 021

; ##################

TEST_81_3_2:            ; SBB REG16,IMM16 - Test flags
                        ; Overflow, Sign, Zero, Parity, AUX, Carry

        ; Tests with Carry Bit CLEARED
        ; ----------------------------
        clc
        mov dx,08000
        sbb dx,00101  ; Overflow should be set
        jno FAIL_81_3_2   ; If not set, then fail

        clc
        mov dx,07800
        sbb dx,03400  ; Overflow should NOT be set
        jno PASS_81_3_2   ; If not set, then we passed
        jmp FAIL_81_3_2   ; If set then we fail

PASS_81_3_2:
        clc
        mov dx,08FFF
        sbb dx,00101  ; sign should be set
        jns FAIL_81_3_2   ; If not set, then fail

        clc
        mov dx,01111
        sbb dx,00101  ; sign should NOT be set
        js  FAIL_81_3_2   ; If set then we fail

        clc
        mov dx,01234
        sbb dx,01234  ; zero should be set
        jne FAIL_81_3_2   ; If not set then we fail
        jmp PASS_81_3_3

FAIL_81_3_2:
        mov dx,00033    ; Print a 3
        mov ax,00202
        int 021
        jmp PASS_81_3_4

PASS_81_3_3:
        clc
        mov dx,04444
        sbb dx,02222  ; zero should NOT be set
        je  FAIL_81_3_2   ; If set then we fail

        clc
        mov dx,04444
        sbb dx,01111  ; parity should be set
        jnp FAIL_81_3_2   ; If not set then we fail

        clc
        mov dx,04444
        sbb dx,01110  ; parity should NOT be set
        jp  FAIL_81_3_2   ; If set then we fail

        clc
        mov dx,00000
        sbb dx,00101  ; carry should be set
        jnc FAIL_81_3_2   ; If not set then we fail

        clc
        mov dx,01234
        sbb dx,00112  ; carry should NOT be set
        jc  FAIL_81_3_2   ; If set then we fail


        ; Tests with Carry Bit SET
        ; ------------------------
        stc
        mov dx,08000
        sbb dx,00200  ; Overflow should be set
        jno FAIL_81_3_3   ; If not set, then fail

        stc
        mov dx,03333
        sbb dx,01111  ; Overflow should NOT be set
        jno PASS_81_3_4   ; If not set, then we passed
        jmp FAIL_81_3_3   ; If set then we fail

PASS_81_3_4:
        stc
        mov dx,00001
        sbb dx,00201  ; sign should be set
        jns FAIL_81_3_3   ; If not set, then fail

        stc
        mov dx,04444
        sbb dx,02222  ; sign should NOT be set
        js  FAIL_81_3_3   ; If set then we fail

        stc
        mov dx,00201
        sbb dx,00200  ; zero should be set
        jne FAIL_81_3_3   ; If not set then we fail
        jmp PASS_81_3_5

FAIL_81_3_3:
        mov dx,00033    ; Print a 3
        mov ax,00202
        int 021
        jmp TEST_81_4_0

PASS_81_3_5:
        stc
        mov dx,01111
        sbb dx,00201  ; zero should NOT be set
        je  FAIL_81_3_3   ; If set then we fail

        stc
        mov dx,04444
        sbb dx,01113  ; parity should be set
        jnp FAIL_81_3_3   ; If not set then we fail

        stc
        mov dx,04448
        sbb dx,01113  ; parity should NOT be set
        jp  FAIL_81_3_3   ; If set then we fail

        stc
        mov dx,00000
        sbb dx,00200  ; carry should be set
        jnc FAIL_81_3_3   ; If not set then we fail

        stc
        mov dx,06666
        sbb dx,02222  ; carry should NOT be set
        jc  FAIL_81_3_3   ; If set then we fail


                   
; 0x81 - AND REG16,IMM16
; ############################################################

TEST_81_4_0:             ; AND REG16,IMM16 - Test data values from memory

        mov dx,05A5A
        lock and dx,0A5A5
        cmp dx,000
        jne FAIL_81_4_0

        mov dx,0FFFF
        and dx,01111
        cmp dx,01111
        jne FAIL_81_4_0

        jmp TEST_81_4_1


FAIL_81_4_0:
        mov dx,00034    ; Print a 4
        mov ax,00202
        int 021

; ##################
TEST_81_4_1:            ; AND REG16,IMM16 - Test flags
                        ; Overflow, Sign, Zero, Parity, AUX, Carry

        mov dx,01111
        and dx,02222  ; Overflow should NEVER be set
        jno PASS_81_4_1   ; If not set, then we passed
        jmp FAIL_81_4_1   ; If set then we fail

PASS_81_4_1:
        mov dx,08000
        and dx,08000  ; sign should be set
        jns FAIL_81_4_1   ; If not set, then fail

        mov dx,0FFFF
        and dx,07FFF  ; sign should NOT be set
        js  FAIL_81_4_1   ; If set then we fail

        mov dx,00000
        and dx,012FF  ; zero should be set
        jne FAIL_81_4_1   ; If not set then we fail
        jmp PASS_81_4_2

FAIL_81_4_1:
        mov dx,00034    ; Print a 4
        mov ax,00202
        int 021
        jmp TEST_81_5_0

PASS_81_4_2:
        mov dx,0FF00
        and dx,00100  ; zero should NOT be set
        je  FAIL_81_4_1   ; If set then we fail

        mov dx,00003
        and dx,00103  ; parity should be set
        jnp FAIL_81_4_1   ; If not set then we fail

        mov dx,00003
        and dx,00101  ; parity should NOT be set
        jp  FAIL_81_4_1   ; If set then we fail

        mov dx,01112
        and dx,01134  ; carry should NEVER be set
        jc  FAIL_81_4_1   ; If set then we fail


; 0x28 - SUB REG16,IMM16
; ############################################################

TEST_81_5_0:             ; SUB REG16,IMM16 - Test data values from memory

        mov dx,08888
        lock sub dx,01111     ; test lock prefix
        cmp dx,07777
        jne FAIL_81_5_0

        mov dx,01222
        sub dx,01222
        cmp dx,00000
        jne FAIL_81_5_0

        mov dx,02222 ; test segment override
        sub dx,01111
        cmp dx,01111
        jne FAIL_81_5_0

        mov dx,00100
        sub dx,00101
        cmp dx,0FFFF
        jne FAIL_81_5_0
        jmp TEST_81_5_1

FAIL_81_5_0:
        mov dx,00035    ; Print a 5
        mov ax,00202
        int 021

; ##################
TEST_81_5_1:              ; SUB REG16,IMM16 - Test flags
                        ; Overflow, Sign, Zero, Parity, AUX, Carry

        mov dx,08000
        sub dx,00201  ; Overflow should be set
        jno FAIL_81_5_1   ; If not set, then fail

        mov dx,01234
        sub dx,01234  ; Overflow should NOT be set
        jno PASS_81_5_1   ; If not set, then we passed
        jmp FAIL_81_5_1   ; If set then we fail

PASS_81_5_1:
        mov dx,00000
        sub dx,00201  ; sign should be set
        jns FAIL_81_5_1   ; If not set, then fail

        mov dx,02222
        sub dx,01111  ; sign should NOT be set
        js  FAIL_81_5_1   ; If set then we fail

        mov dx,01111
        sub dx,01111  ; zero should be set
        jne FAIL_81_5_1   ; If not set then we fail
        jmp PASS_81_5_2

FAIL_81_5_1:
        mov dx,00035    ; Print a 5
        mov ax,00202
        int 021
        jmp TEST_81_6_0

PASS_81_5_2:
        mov dx,05555
        sub dx,01111  ; zero should NOT be set
        je  FAIL_81_5_1   ; If set then we fail

        mov dx,00034
        sub dx,00201  ; parity should be set
        jnp FAIL_81_5_1   ; If not set then we fail

        mov dx,00032
        sub dx,00201  ; parity should NOT be set
        jp  FAIL_81_5_1   ; If set then we fail

        mov dx,00000
        sub dx,00201  ; carry should be set
        jnc FAIL_81_5_1   ; If not set then we fail

        mov dx,04031
        sub dx,00211  ; carry should NOT be set
        jc  FAIL_81_5_1   ; If set then we fail

                   
; 0x81 - XOR REG16,IMM16
; ############################################################

TEST_81_6_0:             ; XOR REG16,IMM16 - Test data values from memory

        mov dx,05A5A
        lock xor dx,0A5A5
        cmp dx,0FFFF
        jne FAIL_81_6_0

        mov dx,00200
        xor dx,00200
        cmp dx,00000
        jne FAIL_81_6_0

        mov dx,08200
        xor dx,00201
        cmp dx,08001
        jne FAIL_81_6_0
        jmp TEST_81_6_1


FAIL_81_6_0:
        mov dx,00036    ; Print a 6
        mov ax,00202
        int 021

; ##################
TEST_81_6_1:              ; XOR REG16,IMM16 - Test flags
                        ; Overflow, Sign, Zero, Parity, AUX, Carry

        mov dx,020FF
        xor dx,0207F  ; Overflow should NEVER be set
        jno PASS_81_6_1   ; If not set, then we passed
        jmp FAIL_81_6_1   ; If set then we fail

PASS_81_6_1:
        mov dx,08000
        xor dx,00200  ; sign should be set
        jns FAIL_81_6_1   ; If not set, then fail

        mov dx,01111
        xor dx,02222  ; sign should NOT be set
        js  FAIL_81_6_1   ; If set then we fail

        mov dx,05A22
        xor dx,05A22  ; zero should be set
        jne FAIL_81_6_1   ; If not set then we fail
        jmp PASS_81_6_2

FAIL_81_6_1:
        mov dx,00036    ; Print a 6
        mov ax,00202
        int 021
        jmp TEST_81_7_0

PASS_81_6_2:
        mov dx,00000
        xor dx,00201  ; zero should NOT be set
        je  FAIL_81_6_1   ; If set then we fail

        mov dx,00001
        xor dx,00202  ; parity should be set
        jnp FAIL_81_6_1   ; If not set then we fail

        mov dx,00001
        xor dx,00206  ; parity should NOT be set
        jp  FAIL_81_6_1   ; If set then we fail

        mov dx,01212
        xor dx,01234  ; carry should NEVER be set
        jc  FAIL_81_6_1   ; If set then we fail



; 0x81 - CMP REG16,IMM16
; ############################################################

TEST_81_7_0:             ; CMP REG16,IMM16 - Test data values from memory

        mov dx,01212
        lock cmp dx,01212     ; test lock prefix
        jne FAIL_81_7_0

        mov dx,00200
        cmp dx,00200
        jne FAIL_81_7_0

        mov dx,01111 ; test segment override
        cmp dx,01111
        jne FAIL_81_7_0

        mov dx,0F2FF
        cmp dx,0F2FF
        jne FAIL_81_7_0
        jmp TEST_81_7_1

FAIL_81_7_0:
        mov dx,00037    ; Print a 7
        mov ax,00202
        int 021

; ##################
TEST_81_7_1:              ; CMP REG16,IMM16 - Test flags
                        ; Overflow, Sign, Zero, Parity, AUX, Carry

        mov dx,08000
        cmp dx,00201  ; Overflow should be set
        jno FAIL_81_7_1   ; If not set, then fail

        mov dx,02222
        cmp dx,01111  ; Overflow should NOT be set
        jno PASS_81_7_1   ; If not set, then we passed
        jmp FAIL_81_7_1   ; If set then we fail

PASS_81_7_1:
        mov dx,0FFFF
        cmp dx,00201  ; sign should be set
        jns FAIL_81_7_1   ; If not set, then fail

        mov dx,01111
        cmp dx,00201  ; sign should NOT be set
        js  FAIL_81_7_1   ; If set then we fail

        mov dx,03434
        cmp dx,03434  ; zero should be set
        jne FAIL_81_7_1   ; If not set then we fail
        jmp PASS_81_7_2

FAIL_81_7_1:
        mov dx,00037    ; Print a 7
        mov ax,00202
        int 021
        jmp Z_END

PASS_81_7_2:
        mov dx,01100
        cmp dx,03301  ; zero should NOT be set
        je  FAIL_81_7_1   ; If set then we fail

        mov dx,00044
        cmp dx,00200  ; parity should be set
        jnp FAIL_81_7_1   ; If not set then we fail

        mov dx,00044
        cmp dx,00201  ; parity should NOT be set
        jp  FAIL_81_7_1   ; If set then we fail

        mov dx,00000
        cmp dx,00201  ; carry should be set
        jnc FAIL_81_7_1   ; If not set then we fail

        mov dx,01234
        cmp dx,00201  ; carry should NOT be set
        jc  FAIL_81_7_1   ; If set then we fail


; xxxxxxxxxxxxxxxxxxxxxxx
; End
; xxxxxxxxxxxxxxxxxxxxxxx
Z_END:
        mov ax,00000    ; DOS Command=Exit
        int 021



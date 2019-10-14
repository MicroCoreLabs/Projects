; Tests for opcode range 0x80 with second byte=0x0-0x7
; Thest tests are REG8,IMM8
; ----------------------------------------------------

        mov ax,es       ; Increment ES so it is not the same as DS
        inc ax
        mov es,ax


; 0x80 - ADD REG8,IMM8
; ############################################################

TEST_80_0_0:             ; Test from Memory

        mov dl,0FF
        lock add dl,0FF     ; test lock prefix
        cmp dl,0FE
        jne FAIL_80_0_0

        mov dl,000
        add dl,000
        cmp dl,000
        jne FAIL_80_0_0

        mov byte es:[00050],011 ; test segment override
        add byte es:[00050],022
        cmp byte es:[00050],033
        jne FAIL_80_0_0
        jmp TEST_80_0_1

FAIL_80_0_0:
        mov dx,00030    ; Print a 0
        mov ax,00202
        int 021


TEST_80_0_1:              ; ADD REG8,IMM8 - Test flags
                        ; Overflow, Sign, Zero, Parity, AUX, Carry

        mov dl,07B
        add dl,036  ; Overflow should be set
        jno FAIL_80_0_1   ; If not set, then fail

        mov dl,0B1
        add dl,037  ; Overflow should NOT be set
        jno PASS_80_0_1   ; If not set, then we passed
        jmp FAIL_80_0_1   ; If set then we fail

PASS_80_0_1:
        mov dl,0FF
        add byte[00050],0FF  ; sign should be set
        jns FAIL_80_0_1   ; If not set, then fail

        mov dl,011
        add dl,022  ; sign should NOT be set
        js  FAIL_80_0_1   ; If set then we fail

        mov dl,000
        add dl,000  ; zero should be set
        jne FAIL_80_0_1   ; If not set then we fail
        jmp TEST_80_1_0

FAIL_80_0_1:
        mov dx,00030    ; Print a 0
        mov ax,00202
        int 021


; 0x80 - OR REG8,IMM8
; ############################################################

TEST_80_1_0:             ; OR REG8,IMM8 - Test data values from memory

        mov ax,es       ; Increment ES so it is not the same as DS
        inc ax
        mov es,ax

        mov dl,05A
        lock or dl,0A5
        cmp dl,0FF
        jne FAIL_80_1_0

        mov dl,000
        or dl,000
        cmp dl,000
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
TEST_80_1_1:              ; OR REG8,IMM8 - Test flags
                        ; Overflow, Sign, Zero, Parity, AUX, Carry

        mov dl,011
        or dl,022  ; Overflow should NEVER be set
        jno PASS_80_1_1   ; If not set, then we passed
        jmp FAIL_80_1_1   ; If set then we fail

PASS_80_1_1:
        mov dl,080
        or dl,000  ; sign should be set
        jns FAIL_80_1_1   ; If not set, then fail

        mov dl,011
        or dl,022  ; sign should NOT be set
        js  FAIL_80_1_1   ; If set then we fail

        mov dl,000
        or dl,00  ; zero should be set
        jne FAIL_80_1_1   ; If not set then we fail
        jmp PASS_80_1_2

FAIL_80_1_1:
        mov dx,00031    ; Print a 1
        mov ax,00202
        int 021
        jmp TEST_80_2_0

PASS_80_1_2:
        mov dl,000
        or dl,001  ; zero should NOT be set
        je  FAIL_80_1_1   ; If set then we fail

        mov dl,001
        or dl,002  ; parity should be set
        jnp FAIL_80_1_1   ; If not set then we fail

        mov dl,001
        or dl,006  ; parity should NOT be set
        jp  FAIL_80_1_1   ; If set then we fail

        mov dl,012
        or dl,034  ; carry should NEVER be set
        jc  FAIL_80_1_1   ; If set then we fail



; 0x80 - ADC REG8,IMM8
; ############################################################

TEST_80_2_0:             ; ADC REG8,IMM8 - Test data values from memory

        ; Tests with Carry Bit CLEARED
        ; ----------------------------
        clc
        mov dl,000
        lock adc dl,0FF     ; test lock prefix
        cmp dl,0FF
        jne FAIL_80_2_0

        clc
        mov dl,000
        adc dl,000
        cmp dl,000
        jne FAIL_80_2_0

        clc
        mov byte es:[00050],011 ; test segment override
        adc byte es:[00050],022
        cmp byte es:[00050],033
        jne FAIL_80_2_0

        clc
        mov dl,0FF
        adc dl,0FF
        cmp dl,0FE
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
        mov dl,000
        lock adc dl,0FF     ; test lock prefix
        cmp dl,000
        jne FAIL_80_2_1

        stc
        mov dl,000
        adc dl,000
        cmp dl,001
        jne FAIL_80_2_1

        stc
        mov byte es:[00050],011 ; test segment override
        adc byte es:[00050],022
        cmp byte es:[00050],034
        jne FAIL_80_2_1

        stc
        mov dl,0FF
        adc dl,0FF
        cmp dl,0FF
        jne FAIL_80_2_1
        jmp TEST_80_2_2

FAIL_80_2_1:
        mov dx,00032    ; Print a 2
        mov ax,00202
        int 021

; ##################

TEST_80_2_2:              ; ADC REG8,IMM8 - Test flags
                        ; Overflow, Sign, Zero, Parity, AUX, Carry

        ; Tests with Carry Bit CLEARED
        ; ----------------------------
        clc
        mov dl,07B
        adc dl,036  ; Overflow should be set
        jno FAIL_80_2_2   ; If not set, then fail

        clc
        mov dl,0B1
        adc dl,037  ; Overflow should NOT be set
        jno PASS_80_2_2   ; If not set, then we passed
        jmp FAIL_80_2_2   ; If set then we fail

PASS_80_2_2:
        clc
        mov dl,0FF
        adc dl,0FF  ; sign should be set
        jns FAIL_80_2_2   ; If not set, then fail

        clc
        mov dl,011
        adc dl,022  ; sign should NOT be set
        js  FAIL_80_2_2   ; If set then we fail

        clc
        mov dl,000
        adc dl,000  ; zero should be set
        jne FAIL_80_2_2   ; If not set then we fail
        jmp PASS_80_2_3

FAIL_80_2_2:
        mov dx,00032    ; Print a 2
        mov ax,00202
        int 021
        jmp PASS_80_2_4

PASS_80_2_3:
        clc
        mov dl,000
        adc dl,001  ; zero should NOT be set
        je  FAIL_80_2_2   ; If set then we fail

        clc
        mov dl,012
        adc dl,035  ; parity should be set
        jnp FAIL_80_2_2   ; If not set then we fail

        clc
        mov dl,012
        adc dl,034  ; parity should NOT be set
        jp  FAIL_80_2_2   ; If set then we fail

        clc
        mov dl,0FF
        adc dl,0FF  ; carry should be set
        jnc FAIL_80_2_2   ; If not set then we fail

        clc
        mov dl,012
        adc dl,034  ; carry should NOT be set
        jc  FAIL_80_2_2   ; If set then we fail


        ; Tests with Carry Bit SET
        ; ------------------------
        stc
        mov dl,001
        adc dl,07F  ; Overflow should be set
        jno FAIL_80_2_3   ; If not set, then fail

        stc
        mov dl,0B1
        adc dl,037  ; Overflow should NOT be set
        jno PASS_80_2_4   ; If not set, then we passed
        jmp FAIL_80_2_3   ; If set then we fail

PASS_80_2_4:
        stc
        mov dl,0FF
        adc dl,0FF  ; sign should be set
        jns FAIL_80_2_3   ; If not set, then fail

        stc
        mov dl,011
        adc dl,022  ; sign should NOT be set
        js  FAIL_80_2_3   ; If set then we fail

        stc
        mov dl,000
        adc dl,0FF  ; zero should be set
        jne FAIL_80_2_3   ; If not set then we fail
        jmp PASS_80_2_5

FAIL_80_2_3:
        mov dx,00030    ; Print a 0
        mov ax,00202
        int 021
        jmp TEST_80_3_0

PASS_80_2_5:
        stc
        mov dl,000
        adc dl,001  ; zero should NOT be set
        je  FAIL_80_2_3   ; If set then we fail

        stc
        mov dl,012
        adc dl,035  ; parity should be set
        jnp FAIL_80_2_3   ; If not set then we fail

        stc
        mov dl,012
        adc dl,036  ; parity should NOT be set
        jp  FAIL_80_2_3   ; If set then we fail

        stc
        mov dl,0FF
        adc dl,0FF  ; carry should be set
        jnc FAIL_80_2_3   ; If not set then we fail

        stc
        mov dl,012
        adc dl,034  ; carry should NOT be set
        jc  FAIL_80_2_3   ; If set then we fail



; 0x80 - SBB REG8,IMM8
; ############################################################

TEST_80_3_0:             ; SBB REG8,IMM8 - Test data values from memory

        ; Tests with Carry Bit CLEARED
        ; ----------------------------
        clc
        mov dl,000
        lock sbb dl,0FF     ; test lock prefix
        cmp dl,001
        jne FAIL_80_3_0

        clc
        mov dl,000
        sbb dl,000
        cmp dl,000
        jne FAIL_80_3_0

        clc
        mov byte es:[00050],011 ; test segment override
        sbb byte  es:[00050],022
        cmp byte es:[00050],0EF
        jne FAIL_80_3_0

        clc
        mov dl,0FF
        sbb dl,0FF
        cmp dl,000
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
        mov dl,000
        lock sbb dl,0FF     ; test lock prefix
        cmp dl,000
        jne FAIL_80_3_1

        stc
        mov dl,000
        sbb dl,000
        cmp dl,0FF
        jne FAIL_80_3_1

        stc
        mov byte es:[00050],011 ; test segment override
        sbb byte  es:[00050],022
        cmp byte es:[00050],0EE
        jne FAIL_80_3_1

        stc
        mov dl,0FF
        sbb dl,0FF
        cmp dl,0FF
        jne FAIL_80_3_1
        jmp TEST_80_3_2

FAIL_80_3_1:
        mov dx,00033    ; Print a 3
        mov ax,00202
        int 021

; ##################

TEST_80_3_2:            ; SBB REG8,IMM8 - Test flags
                        ; Overflow, Sign, Zero, Parity, AUX, Carry

        ; Tests with Carry Bit CLEARED
        ; ----------------------------
        clc
        mov dl,045
        sbb dl,0AD  ; Overflow should be set
        jno FAIL_80_3_2   ; If not set, then fail

        clc
        mov dl,078
        sbb dl,034  ; Overflow should NOT be set
        jno PASS_80_3_2   ; If not set, then we passed
        jmp FAIL_80_3_2   ; If set then we fail

PASS_80_3_2:
        clc
        mov dl,000
        sbb dl,001  ; sign should be set
        jns FAIL_80_3_2   ; If not set, then fail

        clc
        mov dl,011
        sbb dl,002  ; sign should NOT be set
        js  FAIL_80_3_2   ; If set then we fail

        clc
        mov dl,034
        sbb dl,034  ; zero should be set
        jne FAIL_80_3_2   ; If not set then we fail
        jmp PASS_80_3_3

FAIL_80_3_2:
        mov dx,00033    ; Print a 3
        mov ax,00202
        int 021
        jmp PASS_80_3_4

PASS_80_3_3:
        clc
        mov dl,000
        sbb dl,022  ; zero should NOT be set
        je  FAIL_80_3_2   ; If set then we fail

        clc
        mov dl,012
        sbb dl,035  ; parity should be set
        jnp FAIL_80_3_2   ; If not set then we fail

        clc
        mov dl,014
        sbb dl,034  ; parity should NOT be set
        jp  FAIL_80_3_2   ; If set then we fail

        clc
        mov dl,0FE
        sbb dl,0FF  ; carry should be set
        jnc FAIL_80_3_2   ; If not set then we fail

        clc
        mov dl,012
        sbb dl,012  ; carry should NOT be set
        jc  FAIL_80_3_2   ; If set then we fail


        ; Tests with Carry Bit SET
        ; ------------------------
        stc
        mov dl,080
        sbb dl,011  ; Overflow should be set
        jno FAIL_80_3_3   ; If not set, then fail

        stc
        mov dl,000
        sbb dl,002  ; Overflow should NOT be set
        jno PASS_80_3_4   ; If not set, then we passed
        jmp FAIL_80_3_3   ; If set then we fail

PASS_80_3_4:
        stc
        mov dl,0FF
        sbb dl,0FF  ; sign should be set
        jns FAIL_80_3_3   ; If not set, then fail

        stc
        mov dl,044
        sbb dl,022  ; sign should NOT be set
        js  FAIL_80_3_3   ; If set then we fail

        stc
        mov dl,001
        sbb dl,000  ; zero should be set
        jne FAIL_80_3_3   ; If not set then we fail
        jmp PASS_80_3_5

FAIL_80_3_3:
        mov dx,00033    ; Print a 3
        mov ax,00202
        int 021
        jmp TEST_80_4_0

PASS_80_3_5:
        stc
        mov dl,000
        sbb dl,001  ; zero should NOT be set
        je  FAIL_80_3_3   ; If set then we fail

        stc
        mov dl,012
        sbb dl,034  ; parity should be set
        jnp FAIL_80_3_3   ; If not set then we fail

        stc
        mov dl,012
        sbb dl,035  ; parity should NOT be set
        jp  FAIL_80_3_3   ; If set then we fail

        stc
        mov dl,0FF
        sbb dl,0FF  ; carry should be set
        jnc FAIL_80_3_3   ; If not set then we fail

        stc
        mov dl,066
        sbb dl,022  ; carry should NOT be set
        jc  FAIL_80_3_3   ; If set then we fail


                   
; 0x80 - AND REG8,IMM8
; ############################################################

TEST_80_4_0:             ; AND REG8,IMM8 - Test data values from memory

        mov dl,05A
        lock and dl,0A5
        cmp dl,000
        jne FAIL_80_4_0

        mov dl,0FF
        and dl,011
        cmp dl,011
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
TEST_80_4_1:            ; AND REG8,IMM8 - Test flags
                        ; Overflow, Sign, Zero, Parity, AUX, Carry

        mov dl,011
        and dl,022  ; Overflow should NEVER be set
        jno PASS_80_4_1   ; If not set, then we passed
        jmp FAIL_80_4_1   ; If set then we fail

PASS_80_4_1:
        mov dl,080
        and dl,080  ; sign should be set
        jns FAIL_80_4_1   ; If not set, then fail

        mov dl,0FF
        and dl,07F  ; sign should NOT be set
        js  FAIL_80_4_1   ; If set then we fail

        mov dl,000
        and dl,0FF  ; zero should be set
        jne FAIL_80_4_1   ; If not set then we fail
        jmp PASS_80_4_2

FAIL_80_4_1:
        mov dx,00034    ; Print a 4
        mov ax,00202
        int 021
        jmp TEST_80_5_0

PASS_80_4_2:
        mov dl,0FF
        and dl,001  ; zero should NOT be set
        je  FAIL_80_4_1   ; If set then we fail

        mov dl,003
        and dl,003  ; parity should be set
        jnp FAIL_80_4_1   ; If not set then we fail

        mov dl,003
        and dl,001  ; parity should NOT be set
        jp  FAIL_80_4_1   ; If set then we fail

        mov dl,012
        and dl,034  ; carry should NEVER be set
        jc  FAIL_80_4_1   ; If set then we fail


; 0x28 - SUB REG8,IMM8
; ############################################################

TEST_80_5_0:             ; SUB REG8,IMM8 - Test data values from memory

        mov dl,088
        lock sub dl,011     ; test lock prefix
        cmp dl,077
        jne FAIL_80_5_0

        mov dl,000
        sub dl,000
        cmp dl,000
        jne FAIL_80_5_0

        mov byte es:[00050],022 ; test segment override
        sub byte es:[00050],011
        cmp byte es:[00050],011
        jne FAIL_80_5_0

        mov dl,000
        sub dl,001
        cmp dl,0FF
        jne FAIL_80_5_0
        jmp TEST_80_5_1

FAIL_80_5_0:
        mov dx,00035    ; Print a 5
        mov ax,00202
        int 021

; ##################
TEST_80_5_1:              ; SUB REG8,IMM8 - Test flags
                        ; Overflow, Sign, Zero, Parity, AUX, Carry

        mov dl,080
        sub dl,066  ; Overflow should be set
        jno FAIL_80_5_1   ; If not set, then fail

        mov dl,034
        sub dl,012  ; Overflow should NOT be set
        jno PASS_80_5_1   ; If not set, then we passed
        jmp FAIL_80_5_1   ; If set then we fail

PASS_80_5_1:
        mov dl,000
        sub dl,001  ; sign should be set
        jns FAIL_80_5_1   ; If not set, then fail

        mov dl,022
        sub dl,011  ; sign should NOT be set
        js  FAIL_80_5_1   ; If set then we fail

        mov dl,001
        mov ax,00001
        sub dl,001  ; zero should be set
        jne FAIL_80_5_1   ; If not set then we fail
        jmp PASS_80_5_2

FAIL_80_5_1:
        mov dx,00035    ; Print a 5
        mov ax,00202
        int 021
        jmp TEST_80_6_0

PASS_80_5_2:
        mov dl,055
        sub dl,011  ; zero should NOT be set
        je  FAIL_80_5_1   ; If set then we fail

        mov dl,034
        sub dl,001  ; parity should be set
        jnp FAIL_80_5_1   ; If not set then we fail

        mov dl,032
        sub dl,001  ; parity should NOT be set
        jp  FAIL_80_5_1   ; If set then we fail

        mov dl,000
        sub dl,001  ; carry should be set
        jnc FAIL_80_5_1   ; If not set then we fail

        mov dl,031
        sub dl,011  ; carry should NOT be set
        jc  FAIL_80_5_1   ; If set then we fail

                   
; 0x80 - XOR REG8,IMM8
; ############################################################

TEST_80_6_0:             ; XOR REG8,IMM8 - Test data values from memory

        mov dl,05A
        lock xor dl,0A5
        cmp dl,0FF
        jne FAIL_80_6_0

        mov dl,000
        xor dl,000
        cmp dl,000
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
TEST_80_6_1:              ; XOR REG8,IMM8 - Test flags
                        ; Overflow, Sign, Zero, Parity, AUX, Carry

        mov dl,0FF
        xor dl,07F  ; Overflow should NEVER be set
        jno PASS_80_6_1   ; If not set, then we passed
        jmp FAIL_80_6_1   ; If set then we fail

PASS_80_6_1:
        mov dl,080
        xor dl,000  ; sign should be set
        jns FAIL_80_6_1   ; If not set, then fail

        mov dl,011
        xor dl,022  ; sign should NOT be set
        js  FAIL_80_6_1   ; If set then we fail

        mov dl,05A
        xor dl,05A  ; zero should be set
        jne FAIL_80_6_1   ; If not set then we fail
        jmp PASS_80_6_2

FAIL_80_6_1:
        mov dx,00036    ; Print a 6
        mov ax,00202
        int 021
        jmp TEST_80_7_0

PASS_80_6_2:
        mov dl,000
        xor dl,001  ; zero should NOT be set
        je  FAIL_80_6_1   ; If set then we fail

        mov dl,001
        xor dl,002  ; parity should be set
        jnp FAIL_80_6_1   ; If not set then we fail

        mov dl,001
        xor dl,006  ; parity should NOT be set
        jp  FAIL_80_6_1   ; If set then we fail

        mov dl,012
        xor dl,034  ; carry should NEVER be set
        jc  FAIL_80_6_1   ; If set then we fail



; 0x80 - CMP REG8,IMM8
; ############################################################

TEST_80_7_0:             ; CMP REG8,IMM8 - Test data values from memory

        mov dl,012
        lock cmp dl,012     ; test lock prefix
        jne FAIL_80_7_0

        mov dl,000
        cmp dl,000
        jne FAIL_80_7_0

        mov byte es:[00050],011 ; test segment override
        cmp byte es:[00050],011
        jne FAIL_80_7_0

        mov dl,0FF
        cmp dl,0FF
        jne FAIL_80_7_0
        jmp TEST_80_7_1

FAIL_80_7_0:
        mov dx,00037    ; Print a 7
        mov ax,00202
        int 021

; ##################
TEST_80_7_1:              ; CMP REG8,IMM8 - Test flags
                        ; Overflow, Sign, Zero, Parity, AUX, Carry

        mov dl,001
        cmp dl,080  ; Overflow should be set
        jno FAIL_80_7_1   ; If not set, then fail

        mov dl,001
        cmp dl,030  ; Overflow should NOT be set
        jno PASS_80_7_1   ; If not set, then we passed
        jmp FAIL_80_7_1   ; If set then we fail

PASS_80_7_1:
        mov dl,0FF
        cmp dl,001  ; sign should be set
        jns FAIL_80_7_1   ; If not set, then fail

        mov dl,011
        cmp dl,001  ; sign should NOT be set
        js  FAIL_80_7_1   ; If set then we fail

        mov dl,034
        cmp dl,034  ; zero should be set
        jne FAIL_80_7_1   ; If not set then we fail
        jmp PASS_80_7_2

FAIL_80_7_1:
        mov dx,00037    ; Print a 7
        mov ax,00202
        int 021
        jmp Z_END

PASS_80_7_2:
        mov dl,000
        cmp dl,001  ; zero should NOT be set
        je  FAIL_80_7_1   ; If set then we fail

        mov dl,044
        cmp dl,000  ; parity should be set
        jnp FAIL_80_7_1   ; If not set then we fail

        mov dl,044
        cmp dl,001  ; parity should NOT be set
        jp  FAIL_80_7_1   ; If set then we fail

        mov dl,000
        cmp dl,001  ; carry should be set
        jnc FAIL_80_7_1   ; If not set then we fail

        mov dl,012
        cmp dl,001  ; carry should NOT be set
        jc  FAIL_80_7_1   ; If set then we fail


; xxxxxxxxxxxxxxxxxxxxxxx
; End
; xxxxxxxxxxxxxxxxxxxxxxx
Z_END:
        mov ax,00000    ; DOS Command=Exit
        int 021



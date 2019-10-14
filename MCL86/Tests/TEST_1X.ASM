
; Tests for opcode range 0x10-0x1F
; ---------------------------------


; 0x10 - ADC REG8/MEM8,REG8
; ############################################################

TEST_10_0:             ; ADC MEM8,REG8 - Test data values from memory

        mov ax,es       ; Increment ES so it is not the same as DS
        inc ax
        mov es,ax

        ; Tests with Carry Bit CLEARED
        ; ----------------------------
        clc
        mov byte [00050],000
        mov ax,000FF
        lock adc [00050],al     ; test lock prefix
        cmp byte [00050],0FF
        jne FAIL_10_0

        clc
        mov byte [00050],000
        mov ax,00000
        adc [00050],al
        cmp byte [00050],000
        jne FAIL_10_0

        clc
        mov byte es:[00052],011 ; test segment override
        mov ax,00022
        adc es:[00052],al
        cmp byte es:[00052],033
        jne FAIL_10_0

        clc
        mov byte [00053],0FF
        mov ax,000FF
        adc [00053],al
        cmp byte [00053],0FE
        jne FAIL_10_0
        jmp TEST_10_1

FAIL_10_0:
        mov dx,00030    ; Print a 0
        mov ax,00202
        int 021

; ##################

        ; Tests with Carry Bit SET
        ; ------------------------
TEST_10_1:
        stc
        mov byte [00050],000
        mov ax,000FF
        lock adc [00050],al     ; test lock prefix
        cmp byte [00050],000
        jne FAIL_10_1

        stc
        mov byte [00050],000
        mov ax,00000
        adc [00050],al
        cmp byte [00050],001
        jne FAIL_10_1

        stc
        mov byte es:[00052],011 ; test segment override
        mov ax,00022
        adc es:[00052],al
        cmp byte es:[00052],034
        jne FAIL_10_1

        stc
        mov byte [00053],0FF
        mov ax,000FF
        adc [00053],al
        cmp byte [00053],0FF
        jne FAIL_10_1
        jmp TEST_10_2

FAIL_10_1:
        mov dx,00030    ; Print a 0
        mov ax,00202
        int 021

; ##################

TEST_10_2:              ; ADC MEM8,REG8 - Test flags
                        ; Overflow, Sign, Zero, Parity, AUX, Carry

        ; Tests with Carry Bit CLEARED
        ; ----------------------------
        clc
        mov byte [00054],07B
        mov ax,00036
        adc [00054],al  ; Overflow should be set
        jno FAIL_10_2   ; If not set, then fail

        clc
        mov byte [00055],0B1
        mov ax,00037
        adc [00055],al  ; Overflow should NOT be set
        jno PASS_10_2   ; If not set, then we passed
        jmp FAIL_10_2   ; If set then we fail

PASS_10_2:
        clc
        mov byte [00056],0FF
        mov ax,000FF
        adc [00056],al  ; sign should be set
        jns FAIL_10_2   ; If not set, then fail

        clc
        mov byte [00057],011
        mov ax,00022
        adc [00057],al  ; sign should NOT be set
        js  FAIL_10_2   ; If set then we fail

        clc
        mov byte [00058],000
        mov ax,00000
        adc [00058],al  ; zero should be set
        jne FAIL_10_2   ; If not set then we fail
        jmp PASS_10_3

FAIL_10_2:
        mov dx,00030    ; Print a 0
        mov ax,00202
        int 021
        jmp TEST_11_0

PASS_10_3:
        clc
        mov byte [00050],000
        mov ax,00001
        adc [00050],al  ; zero should NOT be set
        je  FAIL_10_2   ; If set then we fail

        clc
        mov byte [00050],012
        mov ax,00035
        adc [00050],al  ; parity should be set
        jnp FAIL_10_2   ; If not set then we fail

        clc
        mov byte [00050],012
        mov ax,00034
        adc [00050],al  ; parity should NOT be set
        jp  FAIL_10_2   ; If set then we fail

        clc
        mov byte [00050],0FF
        mov ax,000FF
        adc [00050],al  ; carry should be set
        jnc FAIL_10_2   ; If not set then we fail

        clc
        mov byte [00050],012
        mov ax,00034
        adc [00050],al  ; carry should NOT be set
        jc  FAIL_10_2   ; If set then we fail


        ; Tests with Carry Bit SET
        ; ------------------------
        stc
        mov byte [00054],001
        mov ax,0007F
        adc [00054],al  ; Overflow should be set
        jno FAIL_10_3   ; If not set, then fail

        stc
        mov byte [00055],0B1
        mov ax,00037
        adc [00055],al  ; Overflow should NOT be set
        jno PASS_10_4   ; If not set, then we passed
        jmp FAIL_10_3   ; If set then we fail

PASS_10_4:
        stc
        mov byte [00056],0FF
        mov ax,000FF
        adc [00056],al  ; sign should be set
        jns FAIL_10_3   ; If not set, then fail

        stc
        mov byte [00057],011
        mov ax,00022
        adc [00057],al  ; sign should NOT be set
        js  FAIL_10_3   ; If set then we fail

        stc
        mov byte [00058],000
        mov ax,000FF
        adc [00058],al  ; zero should be set
        jne FAIL_10_3   ; If not set then we fail
        jmp PASS_10_5

FAIL_10_3:
        mov dx,00030    ; Print a 0
        mov ax,00202
        int 021
        jmp TEST_11_0

PASS_10_5:
        stc
        mov byte [00050],000
        mov ax,00001
        adc [00050],al  ; zero should NOT be set
        je  FAIL_10_3   ; If set then we fail

        stc
        mov byte [00050],012
        mov ax,00035
        adc [00050],al  ; parity should be set
        jnp FAIL_10_3   ; If not set then we fail

        stc
        mov byte [00050],012
        mov ax,00036
        adc [00050],al  ; parity should NOT be set
        jp  FAIL_10_3   ; If set then we fail

        stc
        mov byte [00050],0FF
        mov ax,000FF
        adc [00050],al  ; carry should be set
        jnc FAIL_10_3   ; If not set then we fail

        stc
        mov byte [00050],012
        mov ax,00034
        adc [00050],al  ; carry should NOT be set
        jc  FAIL_10_3   ; If set then we fail



; 0x11 - ADC REG16/MEM16,REG16
; ############################################################

TEST_11_0:             ; ADC MEM16,REG16 - Test data values from memory

        ; Tests with Carry Bit CLEARED
        ; ----------------------------
        clc
        mov word [00060],00000
        mov ax,000FF
        lock adc [00060],ax
        cmp word [00060],000FF
        jne FAIL_11_0

        clc
        mov word [00060],00000
        mov ax,00000
        adc [00060],ax
        cmp word [00060],00000
        jne FAIL_11_0

        clc
        mov word es:[00060],03333
        mov ax,01111
        adc es:[00060],ax
        cmp word es:[00060],04444
        jne FAIL_11_0

        clc
        mov word [00060],000FF
        mov ax,000FF
        adc [00060],ax
        cmp byte [00060],000FE
        jne FAIL_11_0
        jmp TEST_11_B


FAIL_11_0:
        mov dx,00031    ; Print a 1
        mov ax,00202
        int 021
        jmp TEST_11_1

TEST_11_B:
        ; Tests with Carry Bit SET
        ; ------------------------
        stc
        mov word [00060],00000
        mov ax,000FF
        lock adc [00060],ax
        cmp word [00060],00100
        jne FAIL_11_0

        stc
        mov word [00060],00000
        mov ax,00000
        adc [00060],ax
        cmp word [00060],00001
        jne FAIL_11_0

        stc
        mov word es:[00060],03333
        mov ax,01111
        adc es:[00060],ax
        cmp word es:[00060],04445
        jne FAIL_11_0

        stc
        mov word [00060],000FF
        mov ax,000FF
        adc [00060],ax
        cmp byte [00060],000FF
        jne FAIL_11_0



; ##################
TEST_11_1:              ; ADC MEM16,REG16 - Test flags
                        ; Overflow, Sign, Zero, Parity, AUX, Carry


        ; Tests with Carry Bit SET
        ; ------------------------
        stc
        mov word [00050],07FFF
        mov ax,01234
        adc [00050],ax  ; Overflow should be set
        jno FAIL_11_1   ; If not set, then fail

        stc
        mov word [00050],01212
        mov ax,03434
        adc [00050],ax  ; Overflow should NOT be set
        jno PASS_11_1   ; If not set, then we passed
        jmp FAIL_11_1   ; If set then we fail

PASS_11_1:
        stc
        mov word [00050],00001
        mov ax,07FFF
        adc [00050],ax  ; sign should be set
        jns FAIL_11_1   ; If not set, then fail

        stc
        mov word [00050],01234
        mov ax,04321
        adc [00050],ax  ; sign should NOT be set
        js  FAIL_11_1   ; If set then we fail

        stc
        mov word [00050],0FFFE
        mov ax,00001
        adc [00050],ax  ; zero should be set
        jne FAIL_11_1   ; If not set then we fail
        jmp PASS_11_2

FAIL_11_1:
        mov dx,00031    ; Print a 1
        mov ax,00202
        int 021
        jmp TEST_12_0

PASS_11_2:
        stc
        mov word [00050],01111
        mov ax,02222
        adc [00050],ax  ; zero should NOT be set
        je  FAIL_11_1   ; If set then we fail

        stc
        mov word [00050],04444
        mov ax,01111
        adc [00050],ax  ; parity should be set
        jnp FAIL_11_1   ; If not set then we fail

        stc
        mov word [00050],01111
        mov ax,01234
        adc [00050],ax  ; parity should NOT be set
        jp  FAIL_11_1   ; If set then we fail

        stc
        mov word [00050],0FFFF
        mov ax,00001
        adc [00050],ax  ; carry should be set
        jnc FAIL_11_1   ; If not set then we fail

        stc
        mov word [00050],01234
        mov ax,05678
        adc [00050],ax  ; carry should NOT be set
        jc  FAIL_11_1   ; If set then we fail


        ; Tests with Carry Bit CLEARED
        ; ------------------------
        clc
        mov word [00050],07FFF
        mov ax,01234
        adc [00050],ax  ; Overflow should be set
        jno FAIL_11_2   ; If not set, then fail

        clc
        mov word [00050],01212
        mov ax,03434
        adc [00050],ax  ; Overflow should NOT be set
        jno PASS_11_3   ; If not set, then we passed
        jmp FAIL_11_2   ; If set then we fail

PASS_11_3:
        clc
        mov word [00050],00001
        mov ax,07FFF
        adc [00050],ax  ; sign should be set
        jns FAIL_11_2   ; If not set, then fail

        clc
        mov word [00050],01234
        mov ax,04321
        adc [00050],ax  ; sign should NOT be set
        js  FAIL_11_2   ; If set then we fail

        clc
        mov word [00050],00000
        mov ax,00000
        adc [00050],ax  ; zero should be set
        jne FAIL_11_2   ; If not set then we fail
        jmp PASS_11_4

FAIL_11_2:
        mov dx,00031    ; Print a 1
        mov ax,00202
        int 021
        jmp TEST_12_0

PASS_11_4:
        clc
        mov word [00050],01111
        mov ax,02222
        adc [00050],ax  ; zero should NOT be set
        je  FAIL_11_2   ; If set then we fail

        clc
        mov word [00050],04444
        mov ax,01111
        adc [00050],ax  ; parity should be set
        jnp FAIL_11_2   ; If not set then we fail

        clc
        mov word [00050],01111
        mov ax,01234
        adc [00050],ax  ; parity should NOT be set
        jp  FAIL_11_2   ; If set then we fail

        clc
        mov word [00050],0FFFF
        mov ax,00001
        adc [00050],ax  ; carry should be set
        jnc FAIL_11_2   ; If not set then we fail

        clc
        mov word [00050],01234
        mov ax,05678
        adc [00050],ax  ; carry should NOT be set
        jc  FAIL_11_2   ; If set then we fail


; 0x12 - ADC REG8,MEM8/REG8
; ############################################################

TEST_12_0:             ; ADC REG8,REG8 - Test data values from registers

        ; Tests with Carry Bit CLEARED
        ; ------------------------
        clc
        mov ax,000FF
        lock adc ah,al
        cmp ax,0FFFF
        jne FAIL_12_0

        clc
        mov ax,00000
        adc ah,al
        cmp ax,00000
        jne FAIL_12_0

        clc
        mov ax,0FFFF
        adc ah,al
        cmp ax , 0FEFF
        jne FAIL_12_0

        ; Tests with Carry Bit SET
        ; ------------------------
        stc
        mov ax,000FF
        lock adc ah,al
        cmp ax,000FF
        jne FAIL_12_0

        stc
        mov ax,00000
        adc ah,al
        cmp ax,00100
        jne FAIL_12_0

        stc
        mov ax,0FFFF
        adc ah,al
        cmp ax , 0FFFF
        jne FAIL_12_0
        jmp TEST_12_1

FAIL_12_0:
        mov dx,00032    ; Print a 2
        mov ax,00202
        int 021

; ##################

TEST_12_1:             ; ADC MEM8,REG8 - Test data values from memory


        ; Tests with Carry Bit SET
        ; ------------------------
        stc
        mov byte [00050],000
        mov ax,000FF
        adc al,[00050]
        cmp al,000
        jne FAIL_12_1

        stc
        mov byte [00050],000
        mov ax,00000
        adc al,[00050]
        cmp al,001
        jne FAIL_12_1

        stc
        mov byte es:[00050],066
        mov ax,00011
        adc al,es:[00050]
        cmp al,078
        jne FAIL_12_1

        stc
        mov byte [00050],0FF
        mov ax,000FF
        adc al,[00050]
        cmp al,0FF
        jne FAIL_12_1


        ; Tests with Carry Bit CLEARED
        ; ----------------------------
        clc
        mov byte [00050],000
        mov ax,000FF
        adc al,[00050]
        cmp al,0FF
        jne FAIL_12_1

        clc
        mov byte [00050],000
        mov ax,00000
        adc al,[00050]
        cmp al,000
        jne FAIL_12_1

        clc
        mov byte es:[00050],066
        mov ax,00011
        adc al,es:[00050]
        cmp al,077
        jne FAIL_12_1

        clc
        mov byte [00050],0FF
        mov ax,000FF
        adc al,[00050]
        cmp al,0FE
        jne FAIL_12_1
        jmp TEST_12_2



FAIL_12_1:
        mov dx,00032    ; Print a 2
        mov ax,00202
        int 021

; ##################

TEST_12_2:              ; ADC REG8,REG8 - Test flags
                        ; Overflow, Sign, Zero, Parity, AUX, Carry

        ; Tests with Carry Bit CLEARED
        ; ----------------------------
        clc
        mov ax,07B36    ; Test overflow flag
        adc ah,al       ; Overflow should be set
        jno FAIL_12_2   ; If not set, then fail

        clc
        mov ax,0B137    ; Test overflow flag
        adc ah,al       ; Overflow should NOT be set
        jno PASS_12_2   ; If not set, then we passed
        jmp FAIL_12_2   ; If set then we fail

PASS_12_2:
        clc
        mov dx,0FFFF    ; Test sign flag
        adc dl,dh       ; sign should be set
        jns FAIL_12_2   ; If not set, then fail

        clc
        mov cx,01122    ; Test sign flag
        adc ch,cl       ; sign should NOT be set
        js  FAIL_12_2   ; If set then we fail

        clc
        mov cx,00000    ; Test zero flag
        adc ch,cl       ; zero should be set
        jne FAIL_12_2   ; If not set then we fail

        clc
        mov cx,00001    ; Test zero flag
        adc ch,cl       ; zero should NOT be set
        je  FAIL_12_2   ; If set then we fail

        clc
        mov ax,01235    ; Test parity flag
        adc ah,al       ; parity should be set
        jnp FAIL_12_2   ; If not set then we fail

        clc
        mov cx,01234    ; Test parity flag
        adc ch,cl       ; parity should NOT be set
        jp  FAIL_12_2   ; If set then we fail

        clc
        mov ax,0FFFF    ; Test carry flag
        adc ah,al       ; carry should be set
        jnc FAIL_12_2   ; If not set then we fail

        clc
        mov cx,01234    ; Test carry flag
        adc ch,cl       ; carry should NOT be set
        jc  FAIL_12_2   ; If set then we fail
        jmp TEST_12_3

FAIL_12_2:
        mov dx,00032    ; Print a 2
        mov ax,00202
        int 021

        ; Tests with Carry Bit SET
        ; ------------------------
TEST_12_3:
        stc
        mov ax,07B36    ; Test overflow flag
        adc ah,al       ; Overflow should be set
        jno FAIL_12_3   ; If not set, then fail

        stc
        mov ax,0B137    ; Test overflow flag
        adc ah,al       ; Overflow should NOT be set
        jno PASS_12_3   ; If not set, then we passed
        jmp FAIL_12_3   ; If set then we fail

PASS_12_3:
        stc
        mov dx,0FFFF    ; Test sign flag
        adc dl,dh       ; sign should be set
        jns FAIL_12_3   ; If not set, then fail

        stc
        mov cx,01122    ; Test sign flag
        adc ch,cl       ; sign should NOT be set
        js  FAIL_12_3   ; If set then we fail

        stc
        mov cx,000FF    ; Test zero flag
        adc ch,cl       ; zero should be set
        jne FAIL_12_3   ; If not set then we fail

        stc
        mov cx,00001    ; Test zero flag
        adc ch,cl       ; zero should NOT be set
        je  FAIL_12_3   ; If set then we fail

        stc
        mov ax,01235    ; Test parity flag
        adc ah,al       ; parity should be set
        jnp FAIL_12_3   ; If not set then we fail

        stc
        mov cx,01236    ; Test parity flag
        adc ch,cl       ; parity should NOT be set
        jp  FAIL_12_3   ; If set then we fail

        stc
        mov ax,0FFFF    ; Test carry flag
        adc ah,al       ; carry should be set
        jnc FAIL_12_3   ; If not set then we fail

        stc
        mov cx,01234    ; Test carry flag
        adc ch,cl       ; carry should NOT be set
        jc  FAIL_12_3   ; If set then we fail
        jmp TEST_13_0

FAIL_12_3:
        mov dx,00032    ; Print a 2
        mov ax,00202
        int 021


; 0x13 - ADC REG16,MEM16/REG16
; ############################################################

TEST_13_0:             ; ADC MEM16,REG16 - Test data values from memory


        ; Tests with Carry Bit CLEARED
        ; ----------------------------
        clc
        mov word [00055],00000
        mov ax,0FFFF
        adc ax,[00055]
        cmp ax,0FFFF
        jne FAIL_13_0

        clc
        mov word [00057],00000
        mov ax,00000
        adc ax,[00057]
        cmp ax,00000
        jne FAIL_13_0

        clc
        mov word es:[00059],06666
        mov ax,01111
        adc ax,es:[00059]
        cmp ax,07777
        jne FAIL_13_0
        jmp TEST_13_B


FAIL_13_0:
        mov dx,00033    ; Print a 3
        mov ax,00202
        int 021

TEST_13_B:
        clc
        mov word [00060],0FFFF
        mov ax,0FFFF
        adc ax,[00060]
        cmp ax,0FFFE
        jne FAIL_13_0

        ; Tests with Carry Bit SET
        ; ------------------------
        stc
        mov word [00055],00000
        mov ax,0FFFF
        adc ax,[00055]
        cmp ax,00000
        jne FAIL_13_B

        stc
        mov word [00057],00000
        mov ax,00000
        adc ax,[00057]
        cmp ax,00001
        jne FAIL_13_B

        stc
        mov word es:[00059],06666
        mov ax,01111
        adc ax,es:[00059]
        cmp ax,07778
        jne FAIL_13_B

        stc
        mov word [00060],0FFFF
        mov ax,0FFFF
        adc ax,[00060]
        cmp ax,0FFFF
        jne FAIL_13_B
        jmp TEST_13_1

FAIL_13_B:
        mov dx,00033    ; Print a 3
        mov ax,00202
        int 021

; ##################

TEST_13_1:              ; ADC REG16,MEM16 - Test flags
                        ; Overflow, Sign, Zero, Parity, AUX, Carry


        ; Tests with Carry Bit CLEARED
        ; ----------------------------
        clc
        mov word [00070],07FFF  ; Test overflow flag
        mov ax,01234
        adc ax,word [00070]     ; Overflow should be set
        jno FAIL_13_1           ; If not set, then fail

        clc
        mov word [00070],01212  ; Test overflow flag
        mov ax,03434
        adc ax,word [00070]     ; Overflow should NOT be set
        jno PASS_13_1           ; If not set, then we passed
        jmp FAIL_13_1           ; If set then we fail

PASS_13_1:
        clc
        mov word [00070],00001  ; Test sign flag
        mov ax,07FFF
        adc ax,word [00070]     ; Sign should be set
        jns FAIL_13_1           ; If not set, then fail

        clc
        mov word [00070],01234  ; Test sign flag
        mov ax,04321
        adc ax,word [00070]     ; Sign should NOT be set
        js  FAIL_13_1           ; If set, then fail

        clc
        mov word [00070],00000  ; Test zero flag
        mov ax,00000
        adc ax,word [00070]     ; Zero should be set
        jne FAIL_13_1           ; If not set, then fail

        clc
        mov word [00070],00001  ; Test zero flag
        mov ax,00000
        adc ax,word [00070]     ; Zero should NOT be set
        je  FAIL_13_1           ; If set, then fail
        jmp TEST_13_2


FAIL_13_1:
        mov dx,00033    ; Print a 3
        mov ax,00202
        int 021


TEST_13_2:
        clc
        mov word [00070],01111  ; Test parity flag
        mov ax,01111
        adc ax,word [00070]     ; Parity should be set
        jnp FAIL_13_2           ; If not set, then fail

        clc
        mov word [00070],01111  ; Test parity flag
        mov ax,01234
        adc ax,word [00070]     ; Parity should NOT be set
        jp  FAIL_13_2           ; If set, then fail

        clc
        mov word [00070],0FFFF  ; Test carry flag
        mov ax,00001
        adc ax,word [00070]     ; Carry should be set
        jnc FAIL_13_2           ; If not set, then fail

        clc
        mov word [00070],01234  ; Test carry flag
        mov ax,05678
        adc ax,word [00070]     ; Carry should NOT be set
        jc  FAIL_13_2           ; If set, then fail



        ; Tests with Carry Bit SET
        ; ------------------------
        stc
        mov word [00070],07FFF  ; Test overflow flag
        mov ax,01234
        adc ax,word [00070]     ; Overflow should be set
        jno FAIL_13_2           ; If not set, then fail

        stc
        mov word [00070],01212  ; Test overflow flag
        mov ax,03434
        adc ax,word [00070]     ; Overflow should NOT be set
        jno PASS_13_2           ; If not set, then we passed
        jmp FAIL_13_2           ; If set then we fail

PASS_13_2:
        stc
        mov word [00070],00001  ; Test sign flag
        mov ax,07FFF
        adc ax,word [00070]     ; Sign should be set
        jns FAIL_13_2           ; If not set, then fail

        stc
        mov word [00070],01234  ; Test sign flag
        mov ax,04321
        adc ax,word [00070]     ; Sign should NOT be set
        js  FAIL_13_2           ; If set, then fail
        jmp TEST_13_C

FAIL_13_2:
        mov dx,00033    ; Print a 3
        mov ax,00202
        int 021
        jmp TEST_14_0

TEST_13_C:
        stc
        mov word [00070],0FFFF  ; Test zero flag
        mov ax,00000
        adc ax,word [00070]     ; Zero should be set
        jne FAIL_13_2           ; If not set, then fail

        stc
        mov word [00070],00001  ; Test zero flag
        mov ax,00000
        adc ax,word [00070]     ; Zero should NOT be set
        je  FAIL_13_2           ; If set, then fail
        jmp TEST_13_3


TEST_13_3:
        stc
        mov word [00070],01110  ; Test parity flag
        mov ax,01111
        adc ax,word [00070]     ; Parity should be set
        jnp FAIL_13_2           ; If not set, then fail

        stc
        mov word [00070],01111  ; Test parity flag
        mov ax,01234
        adc ax,word [00070]     ; Parity should NOT be set
        jp  FAIL_13_2           ; If set, then fail

        stc
        mov word [00070],0FFFF  ; Test carry flag
        mov ax,00001
        adc ax,word [00070]     ; Carry should be set
        jnc FAIL_13_2           ; If not set, then fail

        stc
        mov word [00070],01234  ; Test carry flag
        mov ax,05678
        adc ax,word [00070]     ; Carry should NOT be set
        jc  FAIL_13_2           ; If set, then fail



; 0x14 - ADC AL,IMMED8
; ############################################################

TEST_14_0:             ; ADC AL,IMMED8 - Test data values from registers

        ; Tests with Carry Bit CLEARED
        ; ----------------------------
        clc
        mov ax,000FF
        lock adc al,000
        cmp ax,000FF
        jne FAIL_14_0

        clc
        mov ax,00000
        adc al,000
        cmp ax,00000
        jne FAIL_14_0

        clc
        mov ax,012FF
        adc al,0FF
        cmp ax , 012FE
        jne FAIL_14_0


        ; Tests with Carry Bit SET
        ; ------------------------
        stc
        mov ax,012FF
        lock adc al,001
        cmp ax,01201
        jne FAIL_14_0

        stc
        mov ax,01200
        adc al,000
        cmp ax,01201
        jne FAIL_14_0

        stc
        mov ax,034FF
        adc al,0FF
        cmp ax , 034FF
        jne FAIL_14_0
        jmp TEST_14_1

FAIL_14_0:
        mov dx,00034    ; Print a 4
        mov ax,00202
        int 021

; ##################

TEST_14_1:              ; ADC AL,IMMED8 - Test flags
                        ; Overflow, Sign, Zero, Parity, AUX, Carry


        ; Tests with Carry Bit CLEARED
        ; ----------------------------
        clc
        mov ax,0007B    ; Test overflow flag
        adc al,036      ; Overflow should be set
        jno FAIL_14_1   ; If not set, then fail

        clc
        mov ax,037B1    ; Test overflow flag
        adc al,037      ; Overflow should NOT be set
        jno PASS_14_1   ; If not set, then we passed
        jmp FAIL_14_1

PASS_14_1:
        clc
        mov ax,0FFFF    ; Test sign flag
        adc al,0FF      ; sign should be set
        jns FAIL_14_1   ; If not set, then fail

        clc
        mov ax,09911    ; Test sign flag
        adc al,022      ; sign should NOT be set
        js  FAIL_14_1   ; If set then we fail

        clc
        mov ax,00000    ; Test zero flag
        adc al,000      ; zero should be set
        jne FAIL_14_1   ; If not set then we fail

        clc
        mov ax,00001    ; Test zero flag
        adc al,012      ; zero should NOT be set
        je  FAIL_14_1   ; If set then we fail

        clc
        mov ax,01235    ; Test parity flag
        adc al,012      ; parity should be set
        jnp FAIL_14_1   ; If not set then we fail

        clc
        mov ax,01234    ; Test parity flag
        adc al,012      ; parity should NOT be set
        jp  FAIL_14_1   ; If set then we fail

        clc
        mov ax,0FFFF    ; Test carry flag
        adc al,001      ; carry should be set
        jnc FAIL_14_1   ; If not set then we fail

        clc
        mov ax,01234    ; Test carry flag
        adc al,012      ; carry should NOT be set
        jc  FAIL_14_1   ; If set then we fail
        jmp TEST_14_B

FAIL_14_1:
        mov dx,00034    ; Print a 4
        mov ax,00202
        int 021


TEST_14_B:
        ; Tests with Carry Bit SET
        ; ------------------------
        stc
        mov ax,0007B    ; Test overflow flag
        adc al,036      ; Overflow should be set
        jno FAIL_14_2   ; If not set, then fail

        stc
        mov ax,037B1    ; Test overflow flag
        adc al,037      ; Overflow should NOT be set
        jno PASS_14_2   ; If not set, then we passed
        jmp FAIL_14_2

PASS_14_2:
        stc
        mov ax,0FFFF    ; Test sign flag
        adc al,0FF      ; sign should be set
        jns FAIL_14_2   ; If not set, then fail

        stc
        mov ax,09911    ; Test sign flag
        adc al,022      ; sign should NOT be set
        js  FAIL_14_2   ; If set then we fail

        stc
        mov ax,000FF    ; Test zero flag
        adc al,000      ; zero should be set
        jne FAIL_14_2   ; If not set then we fail

        stc
        mov ax,00001    ; Test zero flag
        adc al,012      ; zero should NOT be set
        je  FAIL_14_2   ; If set then we fail

        stc
        mov ax,01235    ; Test parity flag
        adc al,012      ; parity should be set
        jnp FAIL_14_2   ; If not set then we fail

        stc
        mov ax,01234    ; Test parity flag
        adc al,014      ; parity should NOT be set
        jp  FAIL_14_2   ; If set then we fail

        stc
        mov ax,0FFFF    ; Test carry flag
        adc al,001      ; carry should be set
        jnc FAIL_14_2   ; If not set then we fail

        stc
        mov ax,01234    ; Test carry flag
        adc al,012      ; carry should NOT be set
        jc  FAIL_14_2   ; If set then we fail
        jmp TEST_15_0

FAIL_14_2:
        mov dx,00034    ; Print a 4
        mov ax,00202
        int 021


; 0x15 - ADC AX,IMMED16
;

TEST_15_0:             ; ADC AX,IMMED16 - Test data values from registers

        ; Tests with Carry Bit CLEARED
        ; ----------------------------
        clc
        mov ax,0FFFF
        lock adc ax,00000
        cmp ax,0FFFF
        jne FAIL_15_0

        clc
        mov ax,00000
        adc ax,00000
        cmp ax,00000
        jne FAIL_15_0

        clc
        mov ax,01200
        adc ax,00034
        cmp ax,01234
        jne FAIL_15_0
        jmp TEST_15_A

FAIL_15_0:
        mov dx,00035    ; Print a 5
        mov ax,00202
        int 021
        jmp TEST_15_1

TEST_15_A:
        ; Tests with Carry Bit SET
        ; ------------------------
        stc
        mov ax,0FFFF
        lock adc ax,00000
        cmp ax,00000
        jne FAIL_15_A

        stc
        mov ax,00000
        adc ax,00000
        cmp ax,00001
        jne FAIL_15_A

        stc
        mov ax,01200
        adc ax,00034
        cmp ax,01235
        jne FAIL_15_A
        jmp TEST_15_1

FAIL_15_A:
        mov dx,00035    ; Print a 5
        mov ax,00202
        int 021

; ##################

TEST_15_1:              ; ADC AX,IMMED16 - Test flags
                        ; Overflow, Sign, Zero, Parity, AUX, Carry


        ; Tests with Carry Bit CLEARED
        ; ----------------------------
        clc
        mov ax,07FFF    ; Test overflow flag
        adc ax,01234    ; Overflow should be set
        jno FAIL_15_1   ; If not set, then fail

        clc
        mov ax,01212    ; Test overflow flag
        adc ax,03434    ; Overflow should NOT be set
        jno PASS_15_1   ; If not set, then we passed
        jmp FAIL_15_1

PASS_15_1:
        clc
        mov ax,00001    ; Test sign flag
        adc ax,07FFF    ; sign should be set
        jns FAIL_15_1   ; If not set, then fail

        clc
        mov ax,01234    ; Test sign flag
        adc ax,04321    ; sign should NOT be set
        js  FAIL_15_1   ; If set then we fail

        clc
        mov ax,00000    ; Test zero flag
        adc ax,00000    ; zero should be set
        jne FAIL_15_1   ; If not set then we fail

        clc
        mov ax,00001    ; Test zero flag
        adc ax,01234    ; zero should NOT be set
        je  FAIL_15_1   ; If set then we fail

        clc
        mov ax,04444    ; Test parity flag
        adc ax,01111    ; parity should be set
        jnp FAIL_15_1   ; If not set then we fail

        clc
        mov ax,01111    ; Test parity flag
        adc ax,01234    ; parity should NOT be set
        jp  FAIL_15_1   ; If set then we fail

        clc
        mov ax,0FFFF    ; Test carry flag
        adc ax,00001    ; carry should be set
        jnc FAIL_15_1   ; If not set then we fail

        clc
        mov ax,01234    ; Test carry flag
        adc ax,05678    ; carry should NOT be set
        jc  FAIL_15_1   ; If set then we fail
        jmp TEST_15_2

FAIL_15_1:
        mov dx,00035    ; Print a 5
        mov ax,00202
        int 021


TEST_15_2:
        ; Tests with Carry Bit SET
        ; ------------------------
        stc
        mov ax,07FFF    ; Test overflow flag
        adc ax,01234    ; Overflow should be set
        jno FAIL_15_2   ; If not set, then fail

        stc
        mov ax,01212    ; Test overflow flag
        adc ax,03434    ; Overflow should NOT be set
        jno PASS_15_2   ; If not set, then we passed
        jmp FAIL_15_2

PASS_15_2:
        stc
        mov ax,00001    ; Test sign flag
        adc ax,07FFF    ; sign should be set
        jns FAIL_15_2   ; If not set, then fail

        stc
        mov ax,01234    ; Test sign flag
        adc ax,04321    ; sign should NOT be set
        js  FAIL_15_2   ; If set then we fail

        stc
        mov ax,0FFFF    ; Test zero flag
        adc ax,00000    ; zero should be set
        jne FAIL_15_2   ; If not set then we fail

        stc
        mov ax,00001    ; Test zero flag
        adc ax,01234    ; zero should NOT be set
        je  FAIL_15_2   ; If set then we fail

        stc
        mov ax,04444    ; Test parity flag
        adc ax,01111    ; parity should be set
        jnp FAIL_15_2   ; If not set then we fail

        stc
        mov ax,01111    ; Test parity flag
        adc ax,01234    ; parity should NOT be set
        jp  FAIL_15_2   ; If set then we fail

        stc
        mov ax,0FFFF    ; Test carry flag
        adc ax,00001    ; carry should be set
        jnc FAIL_15_2   ; If not set then we fail

        stc
        mov ax,01234    ; Test carry flag
        adc ax,01234    ; carry should NOT be set
        jc  FAIL_15_2   ; If set then we fail
        jmp TEST_16_0

FAIL_15_2:
        mov dx,00035    ; Print a 5
        mov ax,00202
        int 021


; 0x16 - PUSH SS
; ############################################################

TEST_16_0:
        mov ax,01234
        mov ss,ax
        lock push ss
        pop bx
        cmp ax,bx
        jne FAIL_16_0

        jmp TEST_17_0

FAIL_16_0:
        mov dx,00036    ; Print a 6
        mov ax,00202
        int 021


; 0x17 - POP SS
; ############################################################

TEST_17_0:
        mov ax,0ABCD
        push ax
        lock pop ss
        mov bx,ss
        cmp ax,bx
        jne FAIL_17_0

        jmp TEST_18_0

FAIL_17_0:
        mov dx,00037    ; Print a 7
        mov ax,00202
        int 021
                   



; 0x18 - SBB REG8/MEM8,REG8
; ############################################################

TEST_18_0:             ; SBB MEM8,REG8 - Test data values from memory

        ; Tests with Carry Bit CLEARED
        ; ----------------------------
        clc
        mov byte [00050],000
        mov ax,000FF
        lock sbb [00050],al     ; test lock prefix
        cmp byte [00050],001
        jne FAIL_18_0

        clc
        mov byte [00050],000
        mov ax,00000
        sbb [00050],al
        cmp byte [00050],000
        jne FAIL_18_0

        clc
        mov byte es:[00052],011 ; test segment override
        mov ax,00022
        sbb es:[00052],al
        cmp byte es:[00052],0EF
        jne FAIL_18_0

        clc
        mov byte [00053],0FF
        mov ax,000FF
        sbb [00053],al
        cmp byte [00053],000
        jne FAIL_18_0
        jmp TEST_18_1

FAIL_18_0:
        mov dx,00038    ; Print a 8
        mov ax,00202
        int 021

; ##################

        ; Tests with Carry Bit SET
        ; ------------------------
TEST_18_1:
        stc
        mov byte [00050],000
        mov ax,000FF
        lock sbb [00050],al     ; test lock prefix
        cmp byte [00050],000
        jne FAIL_18_1

        stc
        mov byte [00050],000
        mov ax,00000
        sbb [00050],al
        cmp byte [00050],0FF
        jne FAIL_18_1

        stc
        mov byte es:[00052],011 ; test segment override
        mov ax,00022
        sbb es:[00052],al
        cmp byte es:[00052],0EE
        jne FAIL_18_1

        stc
        mov byte [00053],0FF
        mov ax,000FF
        sbb [00053],al
        cmp byte [00053],0FF
        jne FAIL_18_1
        jmp TEST_18_2

FAIL_18_1:
        mov dx,00038    ; Print a 8
        mov ax,00202
        int 021

; ##################

TEST_18_2:              ; SBB MEM8,REG8 - Test flags
                        ; Overflow, Sign, Zero, Parity, AUX, Carry

        ; Tests with Carry Bit CLEARED
        ; ----------------------------
        clc
        mov byte [00054],045
        mov ax,0DEAD
        sbb [00054],al  ; Overflow should be set
        jno FAIL_18_2   ; If not set, then fail

        clc
        mov byte [00055],078
        mov ax,01234
        sbb [00055],al  ; Overflow should NOT be set
        jno PASS_18_2   ; If not set, then we passed
        jmp FAIL_18_2   ; If set then we fail

PASS_18_2:
        clc
        mov byte [00056],000
        mov ax,00001
        sbb [00056],al  ; sign should be set
        jns FAIL_18_2   ; If not set, then fail

        clc
        mov byte [00057],011
        mov ax,00002
        sbb [00057],al  ; sign should NOT be set
        js  FAIL_18_2   ; If set then we fail

        clc
        mov byte [00058],034
        mov ax,00034
        sbb [00058],al  ; zero should be set
        jne FAIL_18_2   ; If not set then we fail
        jmp PASS_18_3

FAIL_18_2:
        mov dx,00038    ; Print a 8
        mov ax,00202
        int 021
        jmp TEST_19_0

PASS_18_3:
        clc
        mov byte [00050],000
        mov ax,00022
        sbb [00050],al  ; zero should NOT be set
        je  FAIL_18_2   ; If set then we fail

        clc
        mov byte [00050],012
        mov ax,00035
        sbb [00050],al  ; parity should be set
        jnp FAIL_18_2   ; If not set then we fail

        clc
        mov byte [00050],014
        mov ax,00034
        sbb [00050],al  ; parity should NOT be set
        jp  FAIL_18_2   ; If set then we fail

        clc
        mov byte [00050],0FE
        mov ax,000FF
        sbb [00050],al  ; carry should be set
        jnc FAIL_18_2   ; If not set then we fail

        clc
        mov byte [00050],012
        mov ax,00012
        sbb [00050],al  ; carry should NOT be set
        jc  FAIL_18_2   ; If set then we fail


        ; Tests with Carry Bit SET
        ; ------------------------
        stc
        mov byte [00054],080
        mov ax,00011
        sbb [00054],al  ; Overflow should be set
        jno FAIL_18_3   ; If not set, then fail

        stc
        mov byte [00055],000
        mov ax,00002
        sbb [00055],al  ; Overflow should NOT be set
        jno PASS_18_4   ; If not set, then we passed
        jmp FAIL_18_3   ; If set then we fail

PASS_18_4:
        stc
        mov byte [00056],0FF
        mov ax,000FF
        sbb [00056],al  ; sign should be set
        jns FAIL_18_3   ; If not set, then fail

        stc
        mov byte [00057],044
        mov ax,00022
        sbb [00057],al  ; sign should NOT be set
        js  FAIL_18_3   ; If set then we fail

        stc
        mov byte [00058],001
        mov ax,00000
        sbb [00058],al  ; zero should be set
        jne FAIL_18_3   ; If not set then we fail
        jmp PASS_18_5

FAIL_18_3:
        mov dx,00038    ; Print a 8
        mov ax,00202
        int 021
        jmp TEST_19_0

PASS_18_5:
        stc
        mov byte [00050],000
        mov ax,00001
        sbb [00050],al  ; zero should NOT be set
        je  FAIL_18_3   ; If set then we fail

        stc
        mov byte [00050],012
        mov ax,00034
        sbb [00050],al  ; parity should be set
        jnp FAIL_18_3   ; If not set then we fail

        stc
        mov byte [00050],012
        mov ax,00035
        sbb [00050],al  ; parity should NOT be set
        jp  FAIL_18_3   ; If set then we fail

        stc
        mov byte [00050],0FF
        mov ax,000FF
        sbb [00050],al  ; carry should be set
        jnc FAIL_18_3   ; If not set then we fail

        stc
        mov byte [00050],066
        mov ax,00022
        sbb [00050],al  ; carry should NOT be set
        jc  FAIL_18_3   ; If set then we fail



; 0x19 - SBB REG16/MEM16,REG16
; ############################################################

TEST_19_0:             ; SBB MEM16,REG16 - Test data values from memory

        ; Tests with Carry Bit CLEARED
        ; ----------------------------
        clc
        mov word [00060],00000
        mov ax,000FF
        lock sbb [00060],ax
        cmp word [00060],0FF01
        jne FAIL_19_0

        clc
        mov word [00060],00000
        mov ax,00000
        sbb [00060],ax
        cmp word [00060],00000
        jne FAIL_19_0

        clc
        mov word es:[00060],03333
        mov ax,01111
        sbb es:[00060],ax
        cmp word es:[00060],02222
        jne FAIL_19_0

        clc
        mov word [00060],05678
        mov ax,05678
        sbb [00060],ax
        cmp byte [00060],00000
        jne FAIL_19_0
        jmp TEST_19_B


FAIL_19_0:
        mov dx,00039    ; Print a 9
        mov ax,00202
        int 021
        jmp TEST_19_1

TEST_19_B:
        ; Tests with Carry Bit SET
        ; ------------------------
        stc
        mov word [00060],00000
        mov ax,000FF
        lock sbb [00060],ax
        cmp word [00060],0FF00
        jne FAIL_19_0

        stc
        mov word [00060],00000
        mov ax,00000
        sbb [00060],ax
        cmp word [00060],0FFFF
        jne FAIL_19_0

        stc
        mov word es:[00060],03333
        mov ax,01111
        sbb es:[00060],ax
        cmp word es:[00060],02221
        jne FAIL_19_0

        stc
        mov word [00060],01234
        mov ax,01234
        sbb [00060],ax
        cmp byte [00060],0FFFF
        jne FAIL_19_0



; ##################
TEST_19_1:              ; SBB MEM16,REG16 - Test flags
                        ; Overflow, Sign, Zero, Parity, AUX, Carry


        ; Tests with Carry Bit SET
        ; ------------------------
        stc
        mov word [00050],08000
        mov ax,01234
        sbb [00050],ax  ; Overflow should be set
        jno FAIL_19_1   ; If not set, then fail

        stc
        mov word [00050],01212
        mov ax,03434
        sbb [00050],ax  ; Overflow should NOT be set
        jno PASS_19_1   ; If not set, then we passed
        jmp FAIL_19_1   ; If set then we fail

PASS_19_1:
        stc
        mov word [00050],00001
        mov ax,07FFF
        sbb [00050],ax  ; sign should be set
        jns FAIL_19_1   ; If not set, then fail

        stc
        mov word [00050],01234
        mov ax,0005A
        sbb [00050],ax  ; sign should NOT be set
        js  FAIL_19_1   ; If set then we fail

        stc
        mov word [00050],00001
        mov ax,00000
        sbb [00050],ax  ; zero should be set
        jne FAIL_19_1   ; If not set then we fail
        jmp PASS_19_2

FAIL_19_1:
        mov dx,00039    ; Print a 9
        mov ax,00202
        int 021
        jmp TEST_1A_0

PASS_19_2:
        stc
        mov word [00050],01111
        mov ax,02222
        sbb [00050],ax  ; zero should NOT be set
        je  FAIL_19_1   ; If set then we fail

        stc
        mov word [00050],04444
        mov ax,01110
        sbb [00050],ax  ; parity should be set
        jnp FAIL_19_1   ; If not set then we fail

        stc
        mov word [00050],01111
        mov ax,01234
        sbb [00050],ax  ; parity should NOT be set
        jp  FAIL_19_1   ; If set then we fail

        stc
        mov word [00050],00001
        mov ax,00077
        sbb [00050],ax  ; carry should be set
        jnc FAIL_19_1   ; If not set then we fail

        stc
        mov word [00050],01234
        mov ax,00055
        sbb [00050],ax  ; carry should NOT be set
        jc  FAIL_19_1   ; If set then we fail


        ; Tests with Carry Bit CLEARED
        ; ------------------------
        clc
        mov word [00050],02222
        mov ax,08111
        sbb [00050],ax  ; Overflow should be set
        jno FAIL_19_2   ; If not set, then fail

        clc
        mov word [00050],01212
        mov ax,00022
        sbb [00050],ax  ; Overflow should NOT be set
        jno PASS_19_3   ; If not set, then we passed
        jmp FAIL_19_2   ; If set then we fail

PASS_19_3:
        clc
        mov word [00050],0FFFF
        mov ax,00001
        sbb [00050],ax  ; sign should be set
        jns FAIL_19_2   ; If not set, then fail

        clc
        mov word [00050],01234
        mov ax,0002
        sbb [00050],ax  ; sign should NOT be set
        js  FAIL_19_2   ; If set then we fail

        clc
        mov word [00050],00001
        mov ax,00001
        sbb [00050],ax  ; zero should be set
        jne FAIL_19_2   ; If not set then we fail
        jmp PASS_19_4

FAIL_19_2:
        mov dx,00039    ; Print a 9
        mov ax,00202
        int 021
        jmp TEST_1A_0

PASS_19_4:
        clc
        mov word [00050],01111
        mov ax,02222
        sbb [00050],ax  ; zero should NOT be set
        je  FAIL_19_2   ; If set then we fail

        clc
        mov word [00050],04444
        mov ax,01111
        sbb [00050],ax  ; parity should be set
        jnp FAIL_19_2   ; If not set then we fail

        clc
        mov word [00050],01111
        mov ax,00010
        sbb [00050],ax  ; parity should NOT be set
        jp  FAIL_19_2   ; If set then we fail

        clc
        mov word [00050],00003
        mov ax,08FFF
        sbb [00050],ax  ; carry should be set
        jnc FAIL_19_2   ; If not set then we fail

        clc
        mov word [00050],01234
        mov ax,00002
        sbb [00050],ax  ; carry should NOT be set
        jc  FAIL_19_2   ; If set then we fail


; 0x1A - SBB REG8,MEM8/REG8
; ############################################################

TEST_1A_0:             ; SBB REG8,REG8 - Test data values from registers

        ; Tests with Carry Bit CLEARED
        ; ------------------------
        clc
        mov ax,000FF
        lock sbb ah,al
        cmp ax,001FF
        jne FAIL_1A_0

        clc
        mov ax,00000
        sbb ah,al
        cmp ax,00000
        jne FAIL_1A_0

        clc
        mov ax,01234
        sbb ah,al
        cmp ax , 0DE34
        jne FAIL_1A_0

        ; Tests with Carry Bit SET
        ; ------------------------
        stc
        mov ax,0ABCD
        lock sbb ah,al
        cmp ax,0DDCD
        jne FAIL_1A_0

        stc
        mov ax,00000
        sbb ah,al
        cmp ax,0FF00
        jne FAIL_1A_0

        stc
        mov ax,0FEFF
        sbb ah,al
        cmp ax , 0FEFF
        jne FAIL_1A_0
        jmp TEST_1A_1

FAIL_1A_0:
        mov dx,00041    ; Print a A
        mov ax,00202
        int 021

; ##################

TEST_1A_1:             ; SBB MEM8,REG8 - Test data values from memory


        ; Tests with Carry Bit SET
        ; ------------------------
        stc
        mov byte [00050],0CC
        mov ax,00025
        sbb al,[00050]
        cmp al,058
        jne FAIL_1A_1

        stc
        mov byte [00050],000
        mov ax,00000
        sbb al,[00050]
        cmp al,0FF
        jne FAIL_1A_1

        stc
        mov byte es:[00050],066
        mov ax,00011
        sbb al,es:[00050]
        cmp al,0AA
        jne FAIL_1A_1

        stc
        mov byte [00050],0FF
        mov ax,000FF
        sbb al,[00050]
        cmp al,0FF
        jne FAIL_1A_1


        ; Tests with Carry Bit CLEARED
        ; ----------------------------
        clc
        mov byte [00050],000
        mov ax,000FF
        sbb al,[00050]
        cmp al,0FF
        jne FAIL_1A_1

        clc
        mov byte [00050],000
        mov ax,00000
        sbb al,[00050]
        cmp al,000
        jne FAIL_1A_1

        clc
        mov byte es:[00050],011
        mov ax,00077
        sbb al,es:[00050]
        cmp al,066
        jne FAIL_1A_1

        clc
        mov byte [00050],0FF
        mov ax,000FF
        sbb al,[00050]
        cmp al,000
        jne FAIL_1A_1
        jmp TEST_1A_2



FAIL_1A_1:
        mov dx,00041    ; Print a A
        mov ax,00202
        int 021

; ##################

TEST_1A_2:              ; SBB REG8,REG8 - Test flags
                        ; Overflow, Sign, Zero, Parity, AUX, Carry

        ; Tests with Carry Bit CLEARED
        ; ----------------------------
        clc
        mov ax,08111    ; Test overflow flag
        sbb ah,al       ; Overflow should be set
        jno FAIL_1A_2   ; If not set, then fail

        clc
        mov ax,01234    ; Test overflow flag
        sbb ah,al       ; Overflow should NOT be set
        jno PASS_1A_2   ; If not set, then we passed
        jmp FAIL_1A_2   ; If set then we fail

PASS_1A_2:
        clc
        mov dx,0FF01    ; Test sign flag
        sbb dh,dl       ; sign should be set
        jns FAIL_1A_2   ; If not set, then fail

        clc
        mov cx,03322    ; Test sign flag
        sbb ch,cl       ; sign should NOT be set
        js  FAIL_1A_2   ; If set then we fail

        clc
        mov cx,05555    ; Test zero flag
        sbb ch,cl       ; zero should be set
        jne FAIL_1A_2   ; If not set then we fail

        clc
        mov cx,09988    ; Test zero flag
        sbb ch,cl       ; zero should NOT be set
        je  FAIL_1A_2   ; If set then we fail

        clc
        mov ax,01235    ; Test parity flag
        sbb ah,al       ; parity should be set
        jnp FAIL_1A_2   ; If not set then we fail

        clc
        mov cx,01233    ; Test parity flag
        sbb ch,cl       ; parity should NOT be set
        jp  FAIL_1A_2   ; If set then we fail

        clc
        mov ax,0FCFF    ; Test carry flag
        sbb ah,al       ; carry should be set
        jnc FAIL_1A_2   ; If not set then we fail

        clc
        mov cx,04321    ; Test carry flag
        sbb ch,cl       ; carry should NOT be set
        jc  FAIL_1A_2   ; If set then we fail
        jmp TEST_1A_3

FAIL_1A_2:
        mov dx,00041    ; Print a A
        mov ax,00202
        int 021

        ; Tests with Carry Bit SET
        ; ------------------------
TEST_1A_3:
        stc
        mov ax,08111    ; Test overflow flag
        sbb ah,al       ; Overflow should be set
        jno FAIL_1A_3   ; If not set, then fail

        stc
        mov ax,01234    ; Test overflow flag
        sbb ah,al       ; Overflow should NOT be set
        jno PASS_1A_3   ; If not set, then we passed
        jmp FAIL_1A_3   ; If set then we fail

PASS_1A_3:
        stc
        mov dx,0FFFF    ; Test sign flag
        sbb dl,dh       ; sign should be set
        jns FAIL_1A_3   ; If not set, then fail

        stc
        mov cx,04321    ; Test sign flag
        sbb ch,cl       ; sign should NOT be set
        js  FAIL_1A_3   ; If set then we fail

        stc
        mov cx,00100    ; Test zero flag
        sbb ch,cl       ; zero should be set
        jne FAIL_1A_3   ; If not set then we fail

        stc
        mov cx,04321    ; Test zero flag
        sbb ch,cl       ; zero should NOT be set
        je  FAIL_1A_3   ; If set then we fail

        stc
        mov ax,01234    ; Test parity flag
        sbb ah,al       ; parity should be set
        jnp FAIL_1A_3   ; If not set then we fail

        stc
        mov cx,01237    ; Test parity flag
        sbb ch,cl       ; parity should NOT be set
        jp  FAIL_1A_3   ; If set then we fail

        stc
        mov ax,0FFFF    ; Test carry flag
        sbb ah,al       ; carry should be set
        jnc FAIL_1A_3   ; If not set then we fail

        stc
        mov cx,08765    ; Test carry flag
        sbb ch,cl       ; carry should NOT be set
        jc  FAIL_1A_3   ; If set then we fail
        jmp TEST_1B_0

FAIL_1A_3:
        mov dx,00041    ; Print a A
        mov ax,00202
        int 021


; 0x1B - SBB REG16,MEM16/REG16
; ############################################################

TEST_1B_0:             ; SBB MEM16,REG16 - Test data values from memory


        ; Tests with Carry Bit CLEARED
        ; ----------------------------
        clc
        mov word [00055],00000
        mov ax,0FFFF
        sbb ax,[00055]
        cmp ax,0FFFF
        jne FAIL_1B_0

        clc
        mov word [00057],00000
        mov ax,00000
        sbb ax,[00057]
        cmp ax,00000
        jne FAIL_1B_0

        clc
        mov word es:[00059],06666
        mov ax,01111
        sbb ax,es:[00059]
        cmp ax,0AAAB
        jne FAIL_1B_0
        jmp TEST_1B_B


FAIL_1B_0:
        mov dx,00042    ; Print a B
        mov ax,00202
        int 021

TEST_1B_B:
        clc
        mov word [00060],0FFFF
        mov ax,00001
        sbb ax,[00060]
        cmp ax,00002
        jne FAIL_1B_B

        ; Tests with Carry Bit SET
        ; ------------------------
        stc
        mov word [00055],00000
        mov ax,0FFFF
        sbb ax,[00055]
        cmp ax,0FFFE
        jne FAIL_1B_B

        stc
        mov word [00057],00000
        mov ax,00000
        sbb ax,[00057]
        cmp ax,0FFFF
        jne FAIL_1B_B

        stc
        mov word es:[00059],06666
        mov ax,01111
        sbb ax,es:[00059]
        cmp ax,0AAAA
        jne FAIL_1B_B

        stc
        mov word [00060],0FFFF
        mov ax,0FFFF
        sbb ax,[00060]
        cmp ax,0FFFF
        jne FAIL_1B_B
        jmp TEST_1B_1

FAIL_1B_B:
        mov dx,00042    ; Print a B
        mov ax,00202
        int 021

; ##################

TEST_1B_1:              ; SBB REG16,MEM16 - Test flags
                        ; Overflow, Sign, Zero, Parity, AUX, Carry


        ; Tests with Carry Bit CLEARED
        ; ----------------------------
        clc
        mov word [00070],05678  ; Test overflow flag
        mov ax,08000
        sbb ax,word [00070]     ; Overflow should be set
        jno FAIL_1B_1           ; If not set, then fail

        clc
        mov word [00070],05678  ; Test overflow flag
        mov ax,01234
        sbb ax,word [00070]     ; Overflow should NOT be set
        jno PASS_1B_1           ; If not set, then we passed
        jmp FAIL_1B_1           ; If set then we fail

PASS_1B_1:
        clc
        mov word [00070],00001  ; Test sign flag
        mov ax,0FFFF
        sbb ax,word [00070]     ; Sign should be set
        jns FAIL_1B_1           ; If not set, then fail

        clc
        mov word [00070],01234  ; Test sign flag
        mov ax,04321
        sbb ax,word [00070]     ; Sign should NOT be set
        js  FAIL_1B_1           ; If set, then fail

        clc
        mov word [00070],00034  ; Test zero flag
        mov ax,00034
        sbb ax,word [00070]     ; Zero should be set
        jne FAIL_1B_1           ; If not set, then fail

        clc
        mov word [00070],00123  ; Test zero flag
        mov ax,00000
        sbb ax,word [00070]     ; Zero should NOT be set
        je  FAIL_1B_1           ; If set, then fail
        jmp TEST_1B_2


FAIL_1B_1:
        mov dx,00042    ; Print a B
        mov ax,00202
        int 021


TEST_1B_2:
        clc
        mov word [00070],01111  ; Test parity flag
        mov ax,04444
        sbb ax,word [00070]     ; Parity should be set
        jnp FAIL_1B_2           ; If not set, then fail

        clc
        mov word [00070],01110  ; Test parity flag
        mov ax,04444
        sbb ax,word [00070]     ; Parity should NOT be set
        jp  FAIL_1B_2           ; If set, then fail

        clc
        mov word [00070],0FFFF  ; Test carry flag
        mov ax,00001
        sbb ax,word [00070]     ; Carry should be set
        jnc FAIL_1B_2           ; If not set, then fail

        clc
        mov word [00070],01234  ; Test carry flag
        mov ax,05678
        sbb ax,word [00070]     ; Carry should NOT be set
        jc  FAIL_1B_2           ; If set, then fail



        ; Tests with Carry Bit SET
        ; ------------------------
        stc
        mov word [00070],05678  ; Test overflow flag
        mov ax,08000
        sbb ax,word [00070]     ; Overflow should be set
        jno FAIL_1B_2           ; If not set, then fail

        stc
        mov word [00070],05678  ; Test overflow flag
        mov ax,01234
        sbb ax,word [00070]     ; Overflow should NOT be set
        jno PASS_1B_2           ; If not set, then we passed
        jmp FAIL_1B_2           ; If set then we fail

PASS_1B_2:
        stc
        mov word [00070],00000  ; Test sign flag
        mov ax,00000
        sbb ax,word [00070]     ; Sign should be set
        jns FAIL_1B_2           ; If not set, then fail

        stc
        mov word [00070],00001  ; Test sign flag
        mov ax,08001
        sbb ax,word [00070]     ; Sign should NOT be set
        js  FAIL_1B_2           ; If set, then fail
        jmp TEST_1B_C

FAIL_1B_2:
        mov dx,00042    ; Print a B
        mov ax,00202
        int 021
        jmp TEST_1C_0

TEST_1B_C:
        stc
        mov word [00070],00000  ; Test zero flag
        mov ax,00001
        sbb ax,word [00070]     ; Zero should be set
        jne FAIL_1B_2           ; If not set, then fail

        stc
        mov word [00070],00007  ; Test zero flag
        mov ax,00007
        sbb ax,word [00070]     ; Zero should NOT be set
        je  FAIL_1B_2           ; If set, then fail
        jmp TEST_1B_3


TEST_1B_3:
        stc
        mov word [00070],01113  ; Test parity flag
        mov ax,04444
        sbb ax,word [00070]     ; Parity should be set
        jnp FAIL_1B_2           ; If not set, then fail

        stc
        mov word [00070],01111  ; Test parity flag
        mov ax,04444
        sbb ax,word [00070]     ; Parity should NOT be set
        jp  FAIL_1B_2           ; If set, then fail

        stc
        mov word [00070],00001  ; Test carry flag
        mov ax,00001
        sbb ax,word [00070]     ; Carry should be set
        jnc FAIL_1B_2           ; If not set, then fail

        stc
        mov word [00070],01234  ; Test carry flag
        mov ax,05678
        sbb ax,word [00070]     ; Carry should NOT be set
        jc  FAIL_1B_2           ; If set, then fail



; 0x1C - SBB AL,IMMED8
; ############################################################

TEST_1C_0:             ; SBB AL,IMMED8 - Test data values from registers

        ; Tests with Carry Bit CLEARED
        ; ----------------------------
        clc
        mov ax,000FF
        lock sbb al,000
        cmp ax,000FF
        jne FAIL_1C_0

        clc
        mov ax,00000
        sbb al,000
        cmp ax,00000
        jne FAIL_1C_0

        clc
        mov ax,01234
        sbb al,089
        cmp ax , 012AB
        jne FAIL_1C_0


        ; Tests with Carry Bit SET
        ; ------------------------
        stc
        mov ax,000FF
        lock sbb al,000
        cmp ax,000FE
        jne FAIL_1C_0

        stc
        mov ax,01200
        sbb al,000
        cmp ax,012FF
        jne FAIL_1C_0

        stc
        mov ax,03477
        sbb al,011
        cmp ax,03465
        jne FAIL_1C_0
        jmp TEST_1C_1

FAIL_1C_0:
        mov dx,00043    ; Print a C
        mov ax,00202
        int 021

; ##################

TEST_1C_1:              ; SBB AL,IMMED8 - Test flags
                        ; Overflow, Sign, Zero, Parity, AUX, Carry


        ; Tests with Carry Bit CLEARED
        ; ----------------------------
        clc
        mov ax,01234    ; Test overflow flag
        sbb al,080      ; Overflow should be set
        jno FAIL_1C_1   ; If not set, then fail

        clc
        mov ax,03711    ; Test overflow flag
        sbb al,011      ; Overflow should NOT be set
        jno PASS_1C_1   ; If not set, then we passed
        jmp FAIL_1C_1

PASS_1C_1:
        clc
        mov ax,01200    ; Test sign flag
        sbb al,001      ; sign should be set
        jns FAIL_1C_1   ; If not set, then fail

        clc
        mov ax,09980    ; Test sign flag
        sbb al,001      ; sign should NOT be set
        js  FAIL_1C_1   ; If set then we fail

        clc
        mov ax,00056    ; Test zero flag
        sbb al,056      ; zero should be set
        jne FAIL_1C_1   ; If not set then we fail

        clc
        mov ax,00099    ; Test zero flag
        sbb al,088      ; zero should NOT be set
        je  FAIL_1C_1   ; If set then we fail

        clc
        mov ax,01233    ; Test parity flag
        sbb al,000      ; parity should be set
        jnp FAIL_1C_1   ; If not set then we fail

        clc
        mov ax,01233    ; Test parity flag
        sbb al,001      ; parity should NOT be set
        jp  FAIL_1C_1   ; If set then we fail

        clc
        mov ax,00000    ; Test carry flag
        sbb al,001      ; carry should be set
        jnc FAIL_1C_1   ; If not set then we fail

        clc
        mov ax,01234    ; Test carry flag
        sbb al,012      ; carry should NOT be set
        jc  FAIL_1C_1   ; If set then we fail
        jmp TEST_1C_B

FAIL_1C_1:
        mov dx,00043    ; Print a C
        mov ax,00202
        int 021


TEST_1C_B:
        ; Tests with Carry Bit SET
        ; ------------------------
        stc
        mov ax,00080    ; Test overflow flag
        sbb al,000      ; Overflow should be set
        jno FAIL_1C_2   ; If not set, then fail

        stc
        mov ax,03733    ; Test overflow flag
        sbb al,011      ; Overflow should NOT be set
        jno PASS_1C_2   ; If not set, then we passed
        jmp FAIL_1C_2

PASS_1C_2:
        stc
        mov ax,00000    ; Test sign flag
        sbb al,000      ; sign should be set
        jns FAIL_1C_2   ; If not set, then fail

        stc
        mov ax,09980    ; Test sign flag
        sbb al,000      ; sign should NOT be set
        js  FAIL_1C_2   ; If set then we fail

        stc
        mov ax,00001    ; Test zero flag
        sbb al,000      ; zero should be set
        jne FAIL_1C_2   ; If not set then we fail

        stc
        mov ax,00034    ; Test zero flag
        sbb al,034      ; zero should NOT be set
        je  FAIL_1C_2   ; If set then we fail

        stc
        mov ax,01244    ; Test parity flag
        sbb al,010      ; parity should be set
        jnp FAIL_1C_2   ; If not set then we fail

        stc
        mov ax,01244    ; Test parity flag
        sbb al,011      ; parity should NOT be set
        jp  FAIL_1C_2   ; If set then we fail

        stc
        mov ax,00000    ; Test carry flag
        sbb al,000      ; carry should be set
        jnc FAIL_1C_2   ; If not set then we fail

        stc
        mov ax,05555    ; Test carry flag
        sbb al,022      ; carry should NOT be set
        jc  FAIL_1C_2   ; If set then we fail
        jmp TEST_1D_0

FAIL_1C_2:
        mov dx,00043    ; Print a C
        mov ax,00202
        int 021


; 0x1D - SBB AX,IMMED16
;

TEST_1D_0:             ; SBB AX,IMMED16 - Test data values from registers

        ; Tests with Carry Bit CLEARED
        ; ----------------------------
        clc
        mov ax,0FFFF
        lock sbb ax,00000
        cmp ax,0FFFF
        jne FAIL_1D_0

        clc
        mov ax,00000
        sbb ax,00000
        cmp ax,00000
        jne FAIL_1D_0

        clc
        mov ax,06666
        sbb ax,01111
        cmp ax,05555
        jne FAIL_1D_0
        jmp TEST_1D_A

FAIL_1D_0:
        mov dx,00044    ; Print a D
        mov ax,00202
        int 021
        jmp TEST_1D_1

TEST_1D_A:
        ; Tests with Carry Bit SET
        ; ------------------------
        stc
        mov ax,06666
        lock sbb ax,01111
        cmp ax,05554
        jne FAIL_1D_A

        stc
        mov ax,00000
        sbb ax,00000
        cmp ax,0FFFF
        jne FAIL_1D_A

        stc
        mov ax,0FFFF
        sbb ax,0FFFF
        cmp ax,0FFFF
        jne FAIL_1D_A
        jmp TEST_1D_1

FAIL_1D_A:
        mov dx,00044    ; Print a D
        mov ax,00202
        int 021

; ##################

TEST_1D_1:              ; SBB AX,IMMED16 - Test flags
                        ; Overflow, Sign, Zero, Parity, AUX, Carry


        ; Tests with Carry Bit CLEARED
        ; ----------------------------
        clc
        mov ax,08000    ; Test overflow flag
        sbb ax,00001    ; Overflow should be set
        jno FAIL_1D_1   ; If not set, then fail

        clc
        mov ax,04444    ; Test overflow flag
        sbb ax,03333    ; Overflow should NOT be set
        jno PASS_1D_1   ; If not set, then we passed
        jmp FAIL_1D_1

PASS_1D_1:
        clc
        mov ax,00000    ; Test sign flag
        sbb ax,00001    ; sign should be set
        jns FAIL_1D_1   ; If not set, then fail

        clc
        mov ax,01234    ; Test sign flag
        sbb ax,00002    ; sign should NOT be set
        js  FAIL_1D_1   ; If set then we fail

        clc
        mov ax,01234    ; Test zero flag
        sbb ax,01234    ; zero should be set
        jne FAIL_1D_1   ; If not set then we fail

        clc
        mov ax,01234    ; Test zero flag
        sbb ax,00011    ; zero should NOT be set
        je  FAIL_1D_1   ; If set then we fail

        clc
        mov ax,04444    ; Test parity flag
        sbb ax,01111    ; parity should be set
        jnp FAIL_1D_1   ; If not set then we fail

        clc
        mov ax,04444    ; Test parity flag
        sbb ax,01110    ; parity should NOT be set
        jp  FAIL_1D_1   ; If set then we fail

        clc
        mov ax,00000    ; Test carry flag
        sbb ax,00001    ; carry should be set
        jnc FAIL_1D_1   ; If not set then we fail

        clc
        mov ax,01234    ; Test carry flag
        sbb ax,00000    ; carry should NOT be set
        jc  FAIL_1D_1   ; If set then we fail
        jmp TEST_1D_2

FAIL_1D_1:
        mov dx,00044    ; Print a D
        mov ax,00202
        int 021


TEST_1D_2:
        ; Tests with Carry Bit SET
        ; ------------------------
        stc
        mov ax,08000    ; Test overflow flag
        sbb ax,00000    ; Overflow should be set
        jno FAIL_1D_2   ; If not set, then fail

        stc
        mov ax,01212    ; Test overflow flag
        sbb ax,03434    ; Overflow should NOT be set
        jno PASS_1D_2   ; If not set, then we passed
        jmp FAIL_1D_2

PASS_1D_2:
        stc
        mov ax,08002    ; Test sign flag
        sbb ax,00001    ; sign should be set
        jns FAIL_1D_2   ; If not set, then fail

        stc
        mov ax,08000    ; Test sign flag
        sbb ax,00000    ; sign should NOT be set
        js  FAIL_1D_2   ; If set then we fail

        stc
        mov ax,00002    ; Test zero flag
        sbb ax,00001    ; zero should be set
        jne FAIL_1D_2   ; If not set then we fail

        stc
        mov ax,00008    ; Test zero flag
        sbb ax,00005    ; zero should NOT be set
        je  FAIL_1D_2   ; If set then we fail

        stc
        mov ax,04444    ; Test parity flag
        sbb ax,01110    ; parity should be set
        jnp FAIL_1D_2   ; If not set then we fail

        stc
        mov ax,04444    ; Test parity flag
        sbb ax,01111    ; parity should NOT be set
        jp  FAIL_1D_2   ; If set then we fail

        stc
        mov ax,00000    ; Test carry flag
        sbb ax,00000    ; carry should be set
        jnc FAIL_1D_2   ; If not set then we fail

        stc
        mov ax,05555    ; Test carry flag
        sbb ax,01111    ; carry should NOT be set
        jc  FAIL_1D_2   ; If set then we fail
        jmp TEST_1E_0

FAIL_1D_2:
        mov dx,00044    ; Print a D
        mov ax,00202
        int 021


; 0x1E - PUSH DS
; ############################################################

TEST_1E_0:
        mov ax,01234
        mov ds,ax
        lock push ds
        pop bx
        cmp ax,bx
        jne FAIL_1E_0

        jmp TEST_1F_0

FAIL_1E_0:
        mov dx,00045    ; Print a E
        mov ax,00202
        int 021


; 0x1F - POP DS
; ############################################################

TEST_1F_0:
        mov ax,01234
        push ax
        lock pop ds
        mov bx,ds
        cmp ax,bx
        jne FAIL_1F_0
        jmp Z_END

FAIL_1F_0:
        mov dx,00046    ; Print a F
        mov ax,00202
        int 021
                   


; xxxxxxxxxxxxxxxxxxxxxxx
; End
; xxxxxxxxxxxxxxxxxxxxxxx
Z_END:
        mov ax,00000    ; DOS Command=Exit
        int 021



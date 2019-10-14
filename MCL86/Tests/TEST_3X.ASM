; Tests for opcode range 0x30-0x3F
; ---------------------------------

                   
; 0x30 - XOR REG8/MEM8,REG8
; ############################################################

TEST_30_0:             ; XOR MEM8,REG8 - Test data values from memory

        mov ax,es       ; Increment ES so it is not the same as DS
        inc ax
        mov es,ax

        mov byte [00050],05A
        mov ax,000A5
        lock xor [00050],al
        cmp byte [00050],0FF
        jne FAIL_30_0

        mov byte [00050],000
        mov ax,00000
        xor [00050],al
        cmp byte [00050],000
        jne FAIL_30_0

        mov byte es:[00050],080
        mov ax,00001
        xor es:[00050],al
        cmp byte es:[00050],081
        jne FAIL_30_0
        jmp TEST_30_1


FAIL_30_0:
        mov dx,00030    ; Print a 0
        mov ax,00202
        int 021

; ##################
TEST_30_1:              ; XOR MEM8,REG8 - Test flags
                        ; Overflow, Sign, Zero, Parity, AUX, Carry

        mov byte [00050],0FF
        mov ax,0007F
        xor [00050],al  ; Overflow should NEVER be set
        jno PASS_30_1   ; If not set, then we passed
        jmp FAIL_30_1   ; If set then we fail

PASS_30_1:
        mov byte [00050],080
        mov ax,00000
        xor [00050],al  ; sign should be set
        jns FAIL_30_1   ; If not set, then fail

        mov byte [00050],011
        mov ax,00022
        xor [00050],al  ; sign should NOT be set
        js  FAIL_30_1   ; If set then we fail

        mov byte [00050],05A
        mov ax,0005A
        xor [00050],al  ; zero should be set
        jne FAIL_30_1   ; If not set then we fail
        jmp PASS_30_2

FAIL_30_1:
        mov dx,00030    ; Print a 0
        mov ax,00202
        int 021
        jmp TEST_31_0

PASS_30_2:
        mov byte [00050],000
        mov ax,00001
        xor [00050],al  ; zero should NOT be set
        je  FAIL_30_1   ; If set then we fail

        mov byte [00050],001
        mov ax,00002
        xor [00050],al  ; parity should be set
        jnp FAIL_30_1   ; If not set then we fail

        mov byte [00050],001
        mov ax,00006
        xor [00050],al  ; parity should NOT be set
        jp  FAIL_30_1   ; If set then we fail

        mov byte [00050],012
        mov ax,00034
        xor [00050],al  ; carry should NEVER be set
        jc  FAIL_30_1   ; If set then we fail


; 0x31 - XOR REG16/MEM16,REG16
; ############################################################

TEST_31_0:             ; XOR MEM16,REG16 - Test data values from memory

        mov word [00050],05A5A
        mov ax,0A5A5
        lock xor [00050],ax
        cmp word [00050],0FFFF
        jne FAIL_31_0

        mov word [00050],00000
        mov ax,00000
        xor [00050],ax
        cmp word [00050],00000
        jne FAIL_31_0

        mov word es:[00050],0FFFF
        mov ax,01111
        xor es:[00050],ax
        cmp word es:[00050],0EEEE
        jne FAIL_31_0
        jmp TEST_31_1


FAIL_31_0:
        mov dx,00031    ; Print a 1
        mov ax,00202
        int 021

; ##################
TEST_31_1:              ; XOR MEM16,REG16 - Test flags
                        ; Overflow, Sign, Zero, Parity, AUX, Carry

        mov word [00050],07FFF
        mov ax,02222
        xor [00050],ax  ; Overflow should NEVER be set
        jno PASS_31_1   ; If not set, then we passed
        jmp FAIL_31_1   ; If set then we fail

PASS_31_1:
        mov word [00050],08000
        mov ax,00000
        xor [00050],ax  ; sign should be set
        jns FAIL_31_1   ; If not set, then fail

        mov word [00050],07FF0
        mov ax,0000F
        xor [00050],ax  ; sign should NOT be set
        js  FAIL_31_1   ; If set then we fail

        mov word [00050],0A5A5
        mov ax,0A5A5
        xor [00050],ax  ; zero should be set
        jne FAIL_31_1   ; If not set then we fail
        jmp PASS_31_2

FAIL_31_1:
        mov dx,00031    ; Print a 1
        mov ax,00202
        int 021
        jmp TEST_32_0

PASS_31_2:
        mov word [00050],00000
        mov ax,00001
        xor [00050],ax  ; zero should NOT be set
        je  FAIL_31_1   ; If set then we fail

        mov word [00050],01111
        mov ax,00000
        xor [00050],ax  ; parity should be set
        jnp FAIL_31_1   ; If not set then we fail

        mov word [00050],00011
        mov ax,00002
        xor [00050],ax  ; parity should NOT be set
        jp  FAIL_31_1   ; If set then we fail

        mov word [00050],00012
        mov ax,00034
        xor [00050],ax  ; carry should NEVER be set
        jc  FAIL_31_1   ; If set then we fail


; 0x32 - XOR REG8,MEM8/REG8
; ############################################################

TEST_32_0:             ; XOR REG8,REG8 - Test data values from registers
        mov ax,05AA5
        lock xor ah,al
        cmp ax,0FFA5
        jne FAIL_32_0

        mov ax,00000
        xor ah,al
        cmp ax,00000
        jne FAIL_32_0

        mov ax,08001
        xor ah,al
        cmp ax,08101
        jne FAIL_32_0
        jmp TEST_32_1

FAIL_32_0:
        mov dx,00032    ; Print a 2
        mov ax,00202
        int 021

; ##################

TEST_32_1:             ; XOR MEM8,REG8 - Test data values from memory

        mov byte [00050],05A
        mov ax,000A5
        xor al,[00050]
        cmp al,0FF
        jne FAIL_32_1

        mov byte [00050],000
        mov ax,00000
        xor al,[00050]
        cmp al,000
        jne FAIL_32_1

        mov byte es:[00050],080
        mov ax,00001
        xor al,es:[00050]
        cmp al,081
        jne FAIL_32_1
        jmp TEST_32_2



FAIL_32_1:
        mov dx,00032    ; Print a 2
        mov ax,00202
        int 021

; ##################

TEST_32_2:              ; XOR REG8,REG8 - Test flags
                        ; Overflow, Sign, Zero, Parity, AUX, Carry

        mov ax,0B137    ; Test overflow flag
        xor ah,al        ; Overflow should NEVER be set
        jno PASS_32_2   ; If not set, then we passed
        jmp FAIL_32_2   ; If set then we fail

PASS_32_2:
        mov dx,08000    ; Test sign flag
        xor dl,dh        ; sign should be set
        jns FAIL_32_2   ; If not set, then fail

        mov cx,08080    ; Test sign flag
        xor ch,cl        ; sign should NOT be set
        js FAIL_32_2    ; If set then we fail

        mov cx,07878    ; Test zero flag
        xor ch,cl        ; zero should be set
        jne FAIL_32_2   ; If not set then we fail

        mov cx,00001    ; Test zero flag
        xor ch,cl        ; zero should NOT be set
        je  FAIL_32_2   ; If set then we fail

        mov ax,00102    ; Test parity flag
        xor ah,al        ; parity should be set
        jnp FAIL_32_2   ; If not set then we fail

        mov cx,00100    ; Test parity flag
        xor ch,cl        ; parity should NOT be set
        jp  FAIL_32_2   ; If set then we fail

        mov cx,01234    ; Test carry flag
        xor ch,cl        ; carry should NEVER be set
        jc  FAIL_32_2   ; If set then we fail
        jmp TEST_33_1

FAIL_32_2:
        mov dx,00032    ; Print a 2
        mov ax,00202
        int 021


; 0x33 - XOR REG16,MEM16/REG16
; ############################################################

TEST_33_1:             ; XOR MEM16,REG16 - Test data values from memory
        mov word [00050],05A5A
        mov ax,0A5A5
        lock xor ax,[00050]
        cmp ax,0FFFF
        jne FAIL_33_1

        mov word [00050],00000
        mov ax,00000
        xor ax,[00050]
        cmp ax,00000
        jne FAIL_33_1

        mov word es:[00050],01111
        mov ax,02222
        xor ax,es:[00050]
        cmp ax,03333
        jne FAIL_33_1
        jmp TEST_33_2

FAIL_33_1:
        mov dx,00033    ; Print a 3
        mov ax,00202
        int 021

; ##################

TEST_33_2:              ; XOR REG16,REG16 - Test flags
                        ; Overflow, Sign, Zero, Parity, AUX, Carry

        mov ax,01234    ; Test overflow flag
        mov word[00060],05678
        xor ax,[00060]   ; Overflow should NEVER be set
        jno PASS_33_2   ; If not set, then we passed
        jmp FAIL_33_2   ; If set then we fail

PASS_33_2:
        mov ax,08000    ; Test sign flag
        mov word[00060],00001
        xor ax,[00060]   ; sign should be set
        jns FAIL_33_2   ; If not set, then fail

        mov ax,01122    ; Test sign flag
        mov word[00060],01234
        xor ax,[00060]   ; sign should NOT be set
        js  FAIL_33_2   ; If set then we fail

        mov ax,00000    ; Test zero flag
        mov word[00060],00000
        xor ax,[00060]   ; zero should be set
        jne FAIL_33_2   ; If not set then we fail

        mov ax,00001    ; Test zero flag
        mov word[00060],00000
        xor ax,[00060]        ; zero should NOT be set
        je  FAIL_33_2   ; If set then we fail

        mov ax,00022    ; Test parity flag
        mov word[00060],00011
        xor ax,[00060]   ; parity should be set
        jnp FAIL_33_2   ; If not set then we fail

        mov ax,00000   ; Test parity flag
        mov word[00060],00010
        xor ax,[00060]  ; parity should NOT be set
        jp FAIL_33_2   ; If set then we fail

        mov ax,0FFFF    ; Test carry flag
        mov word[00060],0FFFF
        xor ax,[00060]   ; carry should NEVER be set
        jc  FAIL_33_2   ; If set then we fail

        jmp TEST_34_0

FAIL_33_2:
        mov dx,00033    ; Print a 3
        mov ax,00202
        int 021


; 0x34 - XOR AL,IMMED8
; ############################################################

TEST_34_0:             ; XOR AL,IMMED8 - Test data values from registers
        mov ax,0005A
        lock xor al,0A5
        cmp ax,000FF
        jne FAIL_34_0

        mov ax,00000
        xor al,000
        cmp ax,00000
        jne FAIL_34_0
        jmp TEST_34_1

FAIL_34_0:
        mov dx,00034    ; Print a 4
        mov ax,00202
        int 021

; ##################

TEST_34_1:              ; XOR AL,IMMED8 - Test flags
                        ; Overflow, Sign, Zero, Parity, AUX, Carry

        mov ax,01234    ; Test overflow flag
        xor al,011       ; Overflow should NEVER be set
        jno PASS_34_1   ; If not set, then we passed
        jmp FAIL_34_1

PASS_34_1:
        mov ax,00080    ; Test sign flag
        xor al,001       ; sign should be set
        jns FAIL_34_1   ; If not set, then fail

        mov ax,0007E    ; Test sign flag
        xor al,001       ; sign should NOT be set
        js  FAIL_34_1   ; If set then we fail

        mov ax,00000    ; Test zero flag
        xor al,000       ; zero should be set
        jne FAIL_34_1   ; If not set then we fail

        mov ax,00001    ; Test zero flag
        xor al,012       ; zero should NOT be set
        je  FAIL_34_1   ; If set then we fail

        mov ax,01201    ; Test parity flag
        xor al,002       ; parity should be set
        jnp FAIL_34_1   ; If not set then we fail

        mov ax,01201    ; Test parity flag
        xor al,006       ; parity should NOT be set
        jp  FAIL_34_1   ; If set then we fail

        mov ax,01234    ; Test carry flag
        xor al,012       ; carry should NEVER be set
        jc  FAIL_34_1   ; If set then we fail

        jmp TEST_35_0

FAIL_34_1:
        mov dx,00034    ; Print a 4
        mov ax,00202
        int 021


; 0x35 - XOR AX,IMMED16
; ############################################################

TEST_35_0:             ; XOR AX,IMMED16 - Test data values from registers
        mov ax,05A5A
        lock xor ax,0A5A5
        cmp ax,0FFFF
        jne FAIL_35_0

        mov ax,00000
        xor ax,00000
        cmp ax,00000
        jne FAIL_35_0
        jmp TEST_35_1

FAIL_35_0:
        mov dx,00035    ; Print a 5
        mov ax,00202
        int 021

; ##################

TEST_35_1:              ; XOR AX,IMMED16 - Test flags
                        ; Overflow, Sign, Zero, Parity, AUX, Carry

        mov ax,0B137    ; Test overflow flag
        xor ax,01234     ; Overflow should NEVER be set
        jno PASS_35_1   ; If not set, then we passed
        jmp FAIL_35_1

PASS_35_1:
        mov ax,08000    ; Test sign flag
        xor ax,00001     ; sign should be set
        jns FAIL_35_1   ; If not set, then fail

        mov ax,07FFE    ; Test sign flag
        xor ax,00001     ; sign should NOT be set
        js  FAIL_35_1   ; If set then we fail

        mov ax,00000    ; Test zero flag
        xor ax,00000     ; zero should be set
        jne FAIL_35_1   ; If not set then we fail

        mov ax,01000    ; Test zero flag
        xor ax,00000     ; zero should NOT be set
        je  FAIL_35_1   ; If set then we fail

        mov ax,00001    ; Test parity flag
        xor ax,00002     ; parity should be set
        jnp FAIL_35_1   ; If not set then we fail

        mov ax,00001    ; Test parity flag
        xor ax,00006     ; parity should NOT be set
        jp  FAIL_35_1   ; If set then we fail

        mov ax,01234    ; Test carry flag
        xor ax,01234     ; carry should NEVER be set
        jc  FAIL_35_1   ; If set then we fail

        jmp TEST_36_0

FAIL_35_1:
        mov dx,00035    ; Print a 5
        mov ax,00202
        int 021


; 0x36 - SS:  Stack Segment Override
; ############################################################

TEST_36_0:
        mov ax,es       ; Increment SS so it is not the same as DS
        inc ax
        mov ss,ax

        mov ax,01234
        mov ss:[00050],ax
        mov ax,05678
        mov [00050],ax
        cmp ss:[00050],01234
        jne FAIL_36_0

        jmp TEST_37_0

FAIL_36_0:
        mov dx,00036    ; Print a 6
        mov ax,00202
        int 021


; 0x37 - AAA - ASCII Adjust for Addition
; ############################################################

                ; TEST WITH AUX_FLAG=0
                ; --------------------
TEST_37_0:
        mov cx,000FF    ; Loop count of 256
        mov bx,00000    ; Initialize BX incrementer
        mov dx,00000    ; Initialize DX summation counter

L30:
        mov ax,00000
        add ax,0        ; Cause AUX_FLAG to be set to 0
        mov al,bl       ; Set AL to incremented value
        aaa
        add dx,ax       ; Add results to summation counter
        inc bx          ; Increment to the next value
        loop L30
        cmp dx,062BB    ; All AAA values should add up to this
        jz TEST_37_1

FAIL_37_0:
        mov dx,00037    ; Print a 7
        mov ax,00202
        int 021

                ; TEST WITH AUX_FLAG=1
                ; --------------------
TEST_37_1:
        mov cx,000FF    ; Loop count of 256
        mov bx,00000    ; Initialize BX incrementer
        mov dx,00000    ; Initialize DX summation counter

L31:
        mov ax,00001
        add al,0F       ; Cause AUX_FLAG to be set to 1
        mov al,bl       ; Set AL to incremented value
        aaa
        add dx,ax       ; Add results to summation counter
        inc bx          ; Increment to the next value
        loop L31
        cmp dx,0067B    ; All AAA values should add up to this
        jz TEST_37_2

FAIL_37_1:
        mov dx,00037    ; Print a 7
        mov ax,00202
        int 021

TEST_37_2:              ; Test flags
        mov ax,000F
        aaa             ; CF should be 1
        jc TEST_38_0

FAIL_37_2:
        mov dx,00037    ; Print a 7
        mov ax,00202
        int 021


; 0x38 - CMP REG8/MEM8,REG8
; ############################################################

TEST_38_0:             ; CMP MEM8,REG8 - Test data values from memory

        mov ax,es       ; Increment ES so it is not the same as DS
        inc ax
        mov es,ax

        mov byte [00050],012
        mov ax,00012
        lock cmp [00050],al     ; test lock prefix
        jne FAIL_38_0

        mov byte [00050],000
        mov ax,00000
        cmp [00050],al
        jne FAIL_38_0

        mov byte es:[00052],011 ; test segment override
        mov ax,00011
        cmp es:[00052],al
        jne FAIL_38_0

        mov byte [00053],0FF
        mov ax,0FF00
        cmp [00053],ah
        jne FAIL_38_0
        jmp TEST_38_1

FAIL_38_0:
        mov dx,00038    ; Print a 8
        mov ax,00202
        int 021

; ##################
TEST_38_1:              ; CMP MEM8,REG8 - Test flags
                        ; Overflow, Sign, Zero, Parity, AUX, Carry

        mov byte [00054],001
        mov ax,00080
        cmp [00054],al  ; Overflow should be set
        jno FAIL_38_1   ; If not set, then fail

        mov byte [00055],001
        mov ax,00030
        cmp [00055],al  ; Overflow should NOT be set
        jno PASS_38_1   ; If not set, then we passed
        jmp FAIL_38_1   ; If set then we fail

PASS_38_1:
        mov byte [00056],0FF
        mov ax,00001
        cmp [00056],al  ; sign should be set
        jns FAIL_38_1   ; If not set, then fail

        mov byte [00057],011
        mov ax,00001
        cmp [00057],al  ; sign should NOT be set
        js  FAIL_38_1   ; If set then we fail

        mov byte [00058],034
        mov ax,00034
        cmp [00058],al  ; zero should be set
        jne FAIL_38_1   ; If not set then we fail
        jmp PASS_38_2

FAIL_38_1:
        mov dx,00038    ; Print a 8
        mov ax,00202
        int 021
        jmp TEST_39_0

PASS_38_2:
        mov byte [00050],000
        mov ax,00001
        cmp [00050],al  ; zero should NOT be set
        je  FAIL_38_1   ; If set then we fail

        mov byte [00050],044
        mov ax,00000
        cmp [00050],al  ; parity should be set
        jnp FAIL_38_1   ; If not set then we fail

        mov byte [00050],044
        mov ax,00001
        cmp [00050],al  ; parity should NOT be set
        jp  FAIL_38_1   ; If set then we fail

        mov byte [00050],000
        mov ax,00001
        cmp [00050],al  ; carry should be set
        jnc FAIL_38_1   ; If not set then we fail

        mov byte [00050],012
        mov ax,00001
        cmp [00050],al  ; carry should NOT be set
        jc  FAIL_38_1   ; If set then we fail


; 0x39 - CMP REG16/MEM16,REG16
; ############################################################

TEST_39_0:             ; CMP MEM16,REG16 - Test data values from memory

        mov word [00060],0FFFF
        mov ax,0FFFF
        lock cmp [00060],ax
        jne FAIL_39_0

        mov word [00060],00000
        mov ax,00000
        cmp [00060],ax
        jne FAIL_39_0

        mov word es:[00060],03333
        mov ax,03333
        cmp es:[00060],ax
        jne FAIL_39_0

        mov word [00060],01234
        mov ax,01234
        cmp [00060],ax
        jne FAIL_39_0
        jmp TEST_39_1


FAIL_39_0:
        mov dx,00039    ; Print a 9
        mov ax,00202
        int 021

; ##################
TEST_39_1:              ; CMP MEM16,REG16 - Test flags
                        ; Overflow, Sign, Zero, Parity, AUX, Carry

        mov word [00050],08000
        mov ax,00001
        cmp [00050],ax  ; Overflow should be set
        jno FAIL_39_1   ; If not set, then fail

        mov word [00050],00011
        mov ax,00001
        cmp [00050],ax  ; Overflow should NOT be set
        jno PASS_39_1   ; If not set, then we passed
        jmp FAIL_39_1   ; If set then we fail

PASS_39_1:
        mov word [00050],0FFFF
        mov ax,00003
        cmp [00050],ax  ; sign should be set
        jns FAIL_39_1   ; If not set, then fail

        mov word [00050],01234
        mov ax,00022
        cmp [00050],ax  ; sign should NOT be set
        js  FAIL_39_1   ; If set then we fail

        mov word [00050],01234
        mov ax,01234
        cmp [00050],ax  ; zero should be set
        jne FAIL_39_1   ; If not set then we fail
        jmp PASS_39_2

FAIL_39_1:
        mov dx,00039    ; Print a 9
        mov ax,00202
        int 021
        jmp TEST_3A_0

PASS_39_2:
        mov word [00050],01111
        mov ax,02222
        cmp [00050],ax  ; zero should NOT be set
        je  FAIL_39_1   ; If set then we fail

        mov word [00050],04444
        mov ax,01111
        cmp [00050],ax  ; parity should be set
        jnp FAIL_39_1   ; If not set then we fail

        mov word [00050],04444
        mov ax,01110
        cmp [00050],ax  ; parity should NOT be set
        jp  FAIL_39_1   ; If set then we fail

        mov word [00050],00000
        mov ax,00001
        cmp [00050],ax  ; carry should be set
        jnc FAIL_39_1   ; If not set then we fail

        mov word [00050],01234
        mov ax,00009
        cmp [00050],ax  ; carry should NOT be set
        jc  FAIL_39_1   ; If set then we fail


; 0x3A - CMP REG8,MEM8/REG8
; ############################################################

TEST_3A_0:             ; CMP REG8,REG8 - Test data values from registers
        mov ax,05656
        lock cmp ah,al
        jne FAIL_3A_0

        mov ax,00000
        cmp ah,al
        jne FAIL_3A_0

        mov ax,0FFFF
        cmp ah,al
        jne FAIL_3A_0
        jmp TEST_3A_1

FAIL_3A_0:
        mov dx,00041    ; Print a A
        mov ax,00202
        int 021

; ##################

TEST_3A_1:             ; CMP MEM8,REG8 - Test data values from memory

        mov byte [00050],0FF
        mov ax,000FF
        cmp al,[00050]
        jne FAIL_3A_1

        mov byte [00050],000
        mov ax,00000
        cmp al,[00050]
        jne FAIL_3A_1

        mov byte es:[00050],066
        mov ax,00066
        cmp al,es:[00050]
        jne FAIL_3A_1

        mov byte [00050],0FF
        mov ax,000FF
        cmp al,[00050]
        jne FAIL_3A_1
        jmp TEST_3A_2



FAIL_3A_1:
        mov dx,00041    ; Print a A
        mov ax,00202
        int 021

; ##################

TEST_3A_2:              ; CMP REG8,REG8 - Test flags
                        ; Overflow, Sign, Zero, Parity, AUX, Carry

        mov ax,08001    ; Test overflow flag
        cmp ah,al       ; Overflow should be set
        jno FAIL_3A_2   ; If not set, then fail

        mov ax,02201    ; Test overflow flag
        cmp ah,al       ; Overflow should NOT be set
        jno PASS_3A_2   ; If not set, then we passed
        jmp FAIL_3A_2   ; If set then we fail

PASS_3A_2:
        mov dx,0FF01    ; Test sign flag
        cmp dh,dl       ; sign should be set
        jns FAIL_3A_2   ; If not set, then fail

        mov cx,02202    ; Test sign flag
        cmp ch,cl       ; sign should NOT be set
        js  FAIL_3A_2   ; If set then we fail

        mov cx,05656    ; Test zero flag
        cmp ch,cl       ; zero should be set
        jne FAIL_3A_2   ; If not set then we fail

        mov cx,00001    ; Test zero flag
        cmp ch,cl       ; zero should NOT be set
        je  FAIL_3A_2   ; If set then we fail

        mov ax,04411    ; Test parity flag
        cmp ah,al       ; parity should be set
        jnp FAIL_3A_2   ; If not set then we fail

        mov cx,04410    ; Test parity flag
        cmp ch,cl       ; parity should NOT be set
        jp  FAIL_3A_2   ; If set then we fail

        mov ax,00001    ; Test carry flag
        cmp ah,al       ; carry should be set
        jnc FAIL_3A_2   ; If not set then we fail

        mov cx,04411    ; Test carry flag
        cmp ch,cl       ; carry should NOT be set
        jc  FAIL_3A_2   ; If set then we fail
        jmp TEST_3B_0

FAIL_3A_2:
        mov dx,00041    ; Print a A
        mov ax,00202
        int 021


; 0x3B - CMP REG16,MEM16/REG16
; ############################################################

TEST_3B_0:             ; CMP MEM16,REG16 - Test data values from memory

        mov word [00055],0FFFF
        mov ax,0FFFF
        cmp ax,[00055]
        jne FAIL_3B_0

        mov word [00057],00000
        mov ax,00000
        cmp ax,[00057]
        jne FAIL_3B_0

        mov word es:[00059],06666
        mov ax,06666
        cmp ax,es:[00059]
        jne FAIL_3B_0

        mov word [00060],01234
        mov ax,01234
        cmp ax,[00060]
        jne FAIL_3B_0
        jmp TEST_3B_1

FAIL_3B_0:
        mov dx,00042    ; Print a B
        mov ax,00202
        int 021

; ##################

TEST_3B_1:              ; CMP REG16,MEM16 - Test flags
                        ; Overflow, Sign, Zero, Parity, AUX, Carry

        mov word [00070],00001  ; Test overflow flag
        mov ax,08000
        cmp ax,word [00070]     ; Overflow should be set
        jno FAIL_3B_1           ; If not set, then fail

        mov word [00070],00001  ; Test overflow flag
        mov ax,00006
        cmp ax,word [00070]     ; Overflow should NOT be set
        jno PASS_3B_1           ; If not set, then we passed
        jmp FAIL_3B_1           ; If set then we fail

PASS_3B_1:
        mov word [00070],00001  ; Test sign flag
        mov ax,0FFFF
        cmp ax,word [00070]     ; Sign should be set
        jns FAIL_3B_1           ; If not set, then fail

        mov word [00070],00002  ; Test sign flag
        mov ax,04321
        cmp ax,word [00070]     ; Sign should NOT be set
        js  FAIL_3B_1           ; If set, then fail

        mov word [00070],01234  ; Test zero flag
        mov ax,01234
        cmp ax,word [00070]     ; Zero should be set
        jne FAIL_3B_1           ; If not set, then fail

        mov word [00070],00001  ; Test zero flag
        mov ax,00011
        cmp ax,word [00070]     ; Zero should NOT be set
        je  FAIL_3B_1           ; If set, then fail
        jmp TEST_3B_2


FAIL_3B_1:
        mov dx,00042    ; Print a B
        mov ax,00202
        int 021


TEST_3B_2:
        mov word [00070],01111  ; Test parity flag
        mov ax,04444
        cmp ax,word [00070]     ; Parity should be set
        jnp FAIL_3B_2           ; If not set, then fail

        mov word [00070],01110  ; Test parity flag
        mov ax,04444
        cmp ax,word [00070]     ; Parity should NOT be set
        jp  FAIL_3B_2           ; If set, then fail

        mov word [00070],00001  ; Test carry flag
        mov ax,00000
        cmp ax,word [00070]     ; Carry should be set
        jnc FAIL_3B_2           ; If not set, then fail

        mov word [00070],00002  ; Test carry flag
        mov ax,05678
        cmp ax,word [00070]     ; Carry should NOT be set
        jc  FAIL_3B_2           ; If set, then fail
        jmp TEST_3C_0



FAIL_3B_2:
        mov dx,00042    ; Print a B
        mov ax,00202
        int 021


; 0x3C - CMP AL,IMMED8
; ############################################################

TEST_3C_0:             ; CMP AL,IMMED8 - Test data values from registers
        mov ax,000FF
        lock cmp al,0FF
        jne FAIL_3C_0

        mov ax,00000
        cmp al,000
        jne FAIL_3C_0

        mov ax,03312
        cmp al,012
        jne FAIL_3C_0
        jmp TEST_3C_1

FAIL_3C_0:
        mov dx,00043    ; Print a C
        mov ax,00202
        int 021

; ##################

TEST_3C_1:              ; CMP AL,IMMED8 - Test flags
                        ; Overflow, Sign, Zero, Parity, AUX, Carry

        mov ax,00080    ; Test overflow flag
        cmp al,001      ; Overflow should be set
        jno FAIL_3C_1   ; If not set, then fail

        mov ax,037FF    ; Test overflow flag
        cmp al,001      ; Overflow should NOT be set
        jno PASS_3C_1   ; If not set, then we passed
        jmp FAIL_3C_1

PASS_3C_1:
        mov ax,0FFFF    ; Test sign flag
        cmp al,001      ; sign should be set
        jns FAIL_3C_1   ; If not set, then fail

        mov ax,09911    ; Test sign flag
        cmp al,001      ; sign should NOT be set
        js  FAIL_3C_1   ; If set then we fail

        mov ax,00012    ; Test zero flag
        cmp al,012      ; zero should be set
        jne FAIL_3C_1   ; If not set then we fail

        mov ax,00001    ; Test zero flag
        cmp al,012      ; zero should NOT be set
        je  FAIL_3C_1   ; If set then we fail

        mov ax,01244    ; Test parity flag
        cmp al,011      ; parity should be set
        jnp FAIL_3C_1   ; If not set then we fail

        mov ax,01244    ; Test parity flag
        cmp al,010      ; parity should NOT be set
        jp  FAIL_3C_1   ; If set then we fail

        mov ax,0FF00    ; Test carry flag
        cmp al,001      ; carry should be set
        jnc FAIL_3C_1   ; If not set then we fail

        mov ax,01234    ; Test carry flag
        cmp al,001      ; carry should NOT be set
        jc  FAIL_3C_1   ; If set then we fail

        jmp TEST_3D_0

FAIL_3C_1:
        mov dx,00043    ; Print a C
        mov ax,00202
        int 021


; 0x3D - CMP AX,IMMED16
;

TEST_3D_0:             ; CMP AX,IMMED16 - Test data values from registers
        mov ax,0FFFF
        lock cmp ax,0FFFF
        jne FAIL_3D_0

        mov ax,00000
        cmp ax,00000
        jne FAIL_3D_0

        mov ax,01234
        cmp ax,01234
        jne FAIL_3D_0
        jmp TEST_3D_1

FAIL_3D_0:
        mov dx,00044    ; Print a D
        mov ax,00202
        int 021

; ##################

TEST_3D_1:              ; CMP AX,IMMED16 - Test flags
                        ; Overflow, Sign, Zero, Parity, AUX, Carry

        mov ax,08000    ; Test overflow flag
        cmp ax,00001    ; Overflow should be set
        jno FAIL_3D_1   ; If not set, then fail

        mov ax,01234    ; Test overflow flag
        cmp ax,00002    ; Overflow should NOT be set
        jno PASS_3D_1   ; If not set, then we passed
        jmp FAIL_3D_1

PASS_3D_1:
        mov ax,0FFFF    ; Test sign flag
        cmp ax,00023    ; sign should be set
        jns FAIL_3D_1   ; If not set, then fail

        mov ax,01234    ; Test sign flag
        cmp ax,00001    ; sign should NOT be set
        js  FAIL_3D_1   ; If set then we fail

        mov ax,01234    ; Test zero flag
        cmp ax,01234    ; zero should be set
        jne FAIL_3D_1   ; If not set then we fail

        mov ax,00001    ; Test zero flag
        cmp ax,01234    ; zero should NOT be set
        je  FAIL_3D_1   ; If set then we fail

        mov ax,04444    ; Test parity flag
        cmp ax,01111    ; parity should be set
        jnp FAIL_3D_1   ; If not set then we fail

        mov ax,04444    ; Test parity flag
        cmp ax,04410    ; parity should NOT be set
        jp  FAIL_3D_1   ; If set then we fail

        mov ax,00000    ; Test carry flag
        cmp ax,00001    ; carry should be set
        jnc FAIL_3D_1   ; If not set then we fail

        mov ax,01234    ; Test carry flag
        cmp ax,00001    ; carry should NOT be set
        jc  FAIL_3D_1   ; If set then we fail

        jmp TEST_3E_0

FAIL_3D_1:
        mov dx,00044    ; Print a D
        mov ax,00202
        int 021


                   
; 0x3E - DS:  Data Segment Override
; ############################################################

TEST_3E_0:
        mov ax,01234
        mov ds:[08050],ax
        mov ax,05678
        mov es:[08050],ax
        cmp ds:[08050],01234
        jne FAIL_3E_0

        jmp TEST_3F_0

FAIL_3E_0:
        mov dx,00045    ; Print a E
        mov ax,00202
        int 021

                     

; 0x3F - AAS - AscII Adjust for Subtraction
; ############################################################

                ; TEST WITH AUX_FLAG=0
                ; --------------------
TEST_3F_0:
        mov cx,000FF    ; Loop count of 256
        mov bx,00000    ; Initialize BX incrementer
        mov dx,00000    ; Initialize DX summation counter

L32:
        mov ax,00000
        add ax,0        ; Cause AUX_FLAG to be set to 0
        mov al,bl       ; Set AL to incremented value
        aas
        add dx,ax       ; Add results to summation counter
        inc bx          ; Increment to the next value
        loop L32
        cmp dx,0A637    ; All AAA values should add up to this
        jz TEST_3F_1

FAIL_3F_0:
        mov dx,00046    ; Print a F
        mov ax,00202
        int 021

                ; TEST WITH AUX_FLAG=1
                ; --------------------
TEST_3F_1:
        mov cx,000FF    ; Loop count of 256
        mov bx,00000    ; Initialize BX incrementer
        mov dx,00000    ; Initialize DX summation counter

L33:
        mov ax,00001
        add al,0F       ; Cause AUX_FLAG to be set to 1
        mov al,bl       ; Set AL to incremented value
        aas
        add dx,ax       ; Add results to summation counter
        inc bx          ; Increment to the next value
        loop L33
        cmp dx,00877    ; All AAA values should add up to this
        jz TEST_3F_2

FAIL_3F_1:
        mov dx,00046    ; Print a F
        mov ax,00202
        int 021

TEST_3F_2:              ; Test flags
        mov ax,000F
        aas             ; CF should be 1
        jc Z_END

FAIL_3F_2:
        mov dx,00046    ; Print a F
        mov ax,00202
        int 021

; xxxxxxxxxxxxxxxxxxxxxxx
; End
; xxxxxxxxxxxxxxxxxxxxxxx
Z_END:
        mov ax,00000    ; DOS Command=Exit
        int 021



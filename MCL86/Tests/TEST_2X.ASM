; Tests for opcode range 0x20-0x2F
; ---------------------------------

                   
; 0x20 - AND REG8/MEM8,REG8
; ############################################################

TEST_20_0:             ; AND MEM8,REG8 - Test data values from memory

        mov ax,es       ; Increment ES so it is not the same as DS
        inc ax
        mov es,ax

        mov byte [00050],05A
        mov ax,000A5
        lock and [00050],al
        cmp byte [00050],000
        jne FAIL_20_0

        mov byte [00050],0FF
        mov ax,00011
        and [00050],al
        cmp byte [00050],011
        jne FAIL_20_0

        mov byte es:[00050],081
        mov ax,01218
        and es:[00050],al
        cmp byte es:[00050],000
        jne FAIL_20_0
        jmp TEST_20_1


FAIL_20_0:
        mov dx,00030    ; Print a 0
        mov ax,00202
        int 021

; ##################
TEST_20_1:              ; AND MEM8,REG8 - Test flags
                        ; Overflow, Sign, Zero, Parity, AUX, Carry

        mov byte [00050],011
        mov ax,00022
        and [00050],al  ; Overflow should NEVER be set
        jno PASS_20_1   ; If not set, then we passed
        jmp FAIL_20_1   ; If set then we fail

PASS_20_1:
        mov byte [00050],080
        mov ax,00080
        and [00050],al  ; sign should be set
        jns FAIL_20_1   ; If not set, then fail

        mov byte [00050],0FF
        mov ax,0007F
        and [00050],al  ; sign should NOT be set
        js  FAIL_20_1   ; If set then we fail

        mov byte [00050],000
        mov ax,000FF
        and [00050],al  ; zero should be set
        jne FAIL_20_1   ; If not set then we fail
        jmp PASS_20_2

FAIL_20_1:
        mov dx,00030    ; Print a 0
        mov ax,00202
        int 021
        jmp TEST_21_0

PASS_20_2:
        mov byte [00050],0FF
        mov ax,00001
        and [00050],al  ; zero should NOT be set
        je  FAIL_20_1   ; If set then we fail

        mov byte [00050],003
        mov ax,00003
        and [00050],al  ; parity should be set
        jnp FAIL_20_1   ; If not set then we fail

        mov byte [00050],003
        mov ax,00001
        and [00050],al  ; parity should NOT be set
        jp  FAIL_20_1   ; If set then we fail

        mov byte [00050],012
        mov ax,00034
        and [00050],al  ; carry should NEVER be set
        jc  FAIL_20_1   ; If set then we fail


; 0x21 - AND REG16/MEM16,REG16
; ############################################################

TEST_21_0:             ; AND MEM16,REG16 - Test data values from memory

        mov word [00050],05A5A
        mov ax,05A5A
        lock and [00050],ax
        cmp word [00050],05A5A
        jne FAIL_21_0

        mov word [00050],05A5A
        mov ax,0A5A5
        and [00050],ax
        cmp word [00050],00000
        jne FAIL_21_0

        mov word es:[00050],0FFFF
        mov ax,00000
        and es:[00050],ax
        cmp word es:[00050],00000
        jne FAIL_21_0
        jmp TEST_21_1


FAIL_21_0:
        mov dx,00031    ; Print a 1
        mov ax,00202
        int 021

; ##################
TEST_21_1:              ; AND MEM16,REG16 - Test flags
                        ; Overflow, Sign, Zero, Parity, AUX, Carry

        mov word [00050],01111
        mov ax,02222
        and [00050],ax  ; Overflow should NEVER be set
        jno PASS_21_1   ; If not set, then we passed
        jmp FAIL_21_1   ; If set then we fail

PASS_21_1:
        mov word [00050],08000
        mov ax,0FFFF
        and [00050],ax  ; sign should be set
        jns FAIL_21_1   ; If not set, then fail

        mov word [00050],07FF0
        mov ax,0FFFF
        and [00050],ax  ; sign should NOT be set
        js  FAIL_21_1   ; If set then we fail

        mov word [00050],00000
        mov ax,0AAAA
        and [00050],ax  ; zero should be set
        jne FAIL_21_1   ; If not set then we fail
        jmp PASS_21_2

FAIL_21_1:
        mov dx,00031    ; Print a 1
        mov ax,00202
        int 021
        jmp TEST_22_0

PASS_21_2:
        mov word [00050],00001
        mov ax,00001
        and [00050],ax  ; zero should NOT be set
        je  FAIL_21_1   ; If set then we fail

        mov word [00050],00011
        mov ax,00011
        and [00050],ax  ; parity should be set
        jnp FAIL_21_1   ; If not set then we fail

        mov word [00050],00013
        mov ax,00013
        and [00050],ax  ; parity should NOT be set
        jp  FAIL_21_1   ; If set then we fail

        mov word [00050],00012
        mov ax,00034
        and [00050],ax  ; carry should NEVER be set
        jc  FAIL_21_1   ; If set then we fail


; 0x22 - AND REG8,MEM8/REG8
; ############################################################

TEST_22_0:             ; AND REG8,REG8 - Test data values from registers
        mov ax,05A5A
        lock and ah,al
        cmp ax,05A5A
        jne FAIL_22_0

        mov ax,00000
        and ah,al
        cmp ax,00000
        jne FAIL_22_0

        mov ax,08481
        and ah,al
        cmp ax,08081
        jne FAIL_22_0
        jmp TEST_22_1

FAIL_22_0:
        mov dx,00032    ; Print a 2
        mov ax,00202
        int 021

; ##################

TEST_22_1:             ; AND MEM8,REG8 - Test data values from memory

        mov byte [00050],05A
        mov ax,0005A
        and al,[00050]
        cmp al,05A
        jne FAIL_22_1

        mov byte [00050],000
        mov ax,00000
        and al,[00050]
        cmp al,000
        jne FAIL_22_1

        mov byte es:[00050],0FF
        mov ax,000FF
        and al,es:[00050]
        cmp al,0FF
        jne FAIL_22_1
        jmp TEST_22_2



FAIL_22_1:
        mov dx,00032    ; Print a 2
        mov ax,00202
        int 021

; ##################

TEST_22_2:              ; AND REG8,REG8 - Test flags
                        ; Overflow, Sign, Zero, Parity, AUX, Carry

        mov ax,0B137    ; Test overflow flag
        and ah,al        ; Overflow should NEVER be set
        jno PASS_22_2   ; If not set, then we passed
        jmp FAIL_22_2   ; If set then we fail

PASS_22_2:
        mov dx,08080    ; Test sign flag
        and dl,dh        ; sign should be set
        jns FAIL_22_2   ; If not set, then fail

        mov cx,07777    ; Test sign flag
        and ch,cl        ; sign should NOT be set
        js FAIL_22_2    ; If set then we fail

        mov cx,05AA5    ; Test zero flag
        and ch,cl        ; zero should be set
        jne FAIL_22_2   ; If not set then we fail

        mov cx,00101    ; Test zero flag
        and ch,cl        ; zero should NOT be set
        je  FAIL_22_2   ; If set then we fail

        mov ax,00303    ; Test parity flag
        and ah,al        ; parity should be set
        jnp FAIL_22_2   ; If not set then we fail

        mov cx,00101    ; Test parity flag
        and ch,cl        ; parity should NOT be set
        jp  FAIL_22_2   ; If set then we fail

        mov cx,01234    ; Test carry flag
        and ch,cl        ; carry should NEVER be set
        jc  FAIL_22_2   ; If set then we fail
        jmp TEST_23_1

FAIL_22_2:
        mov dx,00032    ; Print a 2
        mov ax,00202
        int 021


; 0x23 - AND REG16,MEM16/REG16
; ############################################################

TEST_23_1:             ; AND MEM16,REG16 - Test data values from memory
        mov word [00050],05A5A
        mov ax,0A5A5
        lock and ax,[00050]
        cmp ax,00000
        jne FAIL_23_1

        mov word [00050],00000
        mov ax,00000
        and ax,[00050]
        cmp ax,00000
        jne FAIL_23_1

        mov word es:[00050],01111
        mov ax,01111
        and ax,es:[00050]
        cmp ax,01111
        jne FAIL_23_1
        jmp TEST_23_2

FAIL_23_1:
        mov dx,00033    ; Print a 3
        mov ax,00202
        int 021

; ##################

TEST_23_2:              ; AND REG16,REG16 - Test flags
                        ; Overflow, Sign, Zero, Parity, AUX, Carry

        mov ax,01234    ; Test overflow flag
        mov word[00060],05678
        and ax,[00060]   ; Overflow should NEVER be set
        jno PASS_23_2   ; If not set, then we passed
        jmp FAIL_23_2   ; If set then we fail

PASS_23_2:
        mov ax,08000    ; Test sign flag
        mov word[00060],08000
        and ax,[00060]   ; sign should be set
        jns FAIL_23_2   ; If not set, then fail

        mov ax,08000    ; Test sign flag
        mov word[00060],07FFF
        and ax,[00060]   ; sign should NOT be set
        js  FAIL_23_2   ; If set then we fail

        mov ax,05A5A    ; Test zero flag
        mov word[00060],0A5A5
        and ax,[00060]   ; zero should be set
        jne FAIL_23_2   ; If not set then we fail

        mov ax,00001    ; Test zero flag
        mov word[00060],00001
        and ax,[00060]        ; zero should NOT be set
        je  FAIL_23_2   ; If set then we fail

        mov ax,00033    ; Test parity flag
        mov word[00060],00033
        and ax,[00060]   ; parity should be set
        jnp FAIL_23_2   ; If not set then we fail

        mov ax,00013   ; Test parity flag
        mov word[00060],00013
        and ax,[00060]  ; parity should NOT be set
        jp FAIL_23_2   ; If set then we fail

        mov ax,0FFFF    ; Test carry flag
        mov word[00060],0FFFF
        and ax,[00060]   ; carry should NEVER be set
        jc  FAIL_23_2   ; If set then we fail

        jmp TEST_24_0

FAIL_23_2:
        mov dx,00033    ; Print a 3
        mov ax,00202
        int 021


; 0x24 - AND AL,IMMED8
; ############################################################

TEST_24_0:             ; AND AL,IMMED8 - Test data values from registers
        mov ax,0005A
        lock and al,05A
        cmp ax,0005A
        jne FAIL_24_0

        mov ax,00001
        and al,001
        cmp ax,00001
        jne FAIL_24_0
        jmp TEST_24_1

FAIL_24_0:
        mov dx,00034    ; Print a 4
        mov ax,00202
        int 021

; ##################

TEST_24_1:              ; AND AL,IMMED8 - Test flags
                        ; Overflow, Sign, Zero, Parity, AUX, Carry

        mov ax,01234    ; Test overflow flag
        and al,011      ; Overflow should NEVER be set
        jno PASS_24_1   ; If not set, then we passed
        jmp FAIL_24_1

PASS_24_1:
        mov ax,00080    ; Test sign flag
        and al,080      ; sign should be set
        jns FAIL_24_1   ; If not set, then fail

        mov ax,0007E    ; Test sign flag
        and al,080      ; sign should NOT be set
        js  FAIL_24_1   ; If set then we fail

        mov ax,0005A    ; Test zero flag
        and al,0A5      ; zero should be set
        jne FAIL_24_1   ; If not set then we fail

        mov ax,00001    ; Test zero flag
        and al,0FF      ; zero should NOT be set
        je  FAIL_24_1   ; If set then we fail

        mov ax,01203    ; Test parity flag
        and al,003      ; parity should be set
        jnp FAIL_24_1   ; If not set then we fail

        mov ax,02013    ; Test parity flag
        and al,013      ; parity should NOT be set
        jp  FAIL_24_1   ; If set then we fail

        mov ax,01234    ; Test carry flag
        and al,012      ; carry should NEVER be set
        jc  FAIL_24_1   ; If set then we fail

        jmp TEST_25_0

FAIL_24_1:
        mov dx,00034    ; Print a 4
        mov ax,00202
        int 021


; 0x25 - AND AX,IMMED16
; ############################################################

TEST_25_0:             ; AND AX,IMMED16 - Test data values from registers
        mov ax,05A5A
        lock and ax,05A5A
        cmp ax,05A5A
        jne FAIL_25_0

        mov ax,00000
        and ax,00000
        cmp ax,00000
        jne FAIL_25_0
        jmp TEST_25_1

FAIL_25_0:
        mov dx,00035    ; Print a 5
        mov ax,00202
        int 021

; ##################

TEST_25_1:              ; AND AX,IMMED16 - Test flags
                        ; Overflow, Sign, Zero, Parity, AUX, Carry

        mov ax,0B137    ; Test overflow flag
        and ax,01234     ; Overflow should NEVER be set
        jno PASS_25_1   ; If not set, then we passed
        jmp FAIL_25_1

PASS_25_1:
        mov ax,08000    ; Test sign flag
        and ax,0FFFF     ; sign should be set
        jns FAIL_25_1   ; If not set, then fail

        mov ax,0FFFF    ; Test sign flag
        and ax,07FFF     ; sign should NOT be set
        js  FAIL_25_1   ; If set then we fail

        mov ax,05A5A    ; Test zero flag
        and ax,0A5A5     ; zero should be set
        jne FAIL_25_1   ; If not set then we fail

        mov ax,0FFFF    ; Test zero flag
        and ax,00001     ; zero should NOT be set
        je  FAIL_25_1   ; If set then we fail

        mov ax,00003    ; Test parity flag
        and ax,0FFFF     ; parity should be set
        jnp FAIL_25_1   ; If not set then we fail

        mov ax,00001    ; Test parity flag
        and ax,0FFFF     ; parity should NOT be set
        jp  FAIL_25_1   ; If set then we fail

        mov ax,01234    ; Test carry flag
        and ax,01234     ; carry should NEVER be set
        jc  FAIL_25_1   ; If set then we fail

        jmp TEST_26_0

FAIL_25_1:
        mov dx,00035    ; Print a 5
        mov ax,00202
        int 021


; 0x26 - ES:  Extra Segment Override
; ############################################################

TEST_26_0:
        mov ax,01234
        mov bx,00000
        mov es:[00050],ax
        mov ds:[00050],bx
        mov ss:[00050],bx
        mov [00050],bx
        cmp es:[00050],01234
        jne FAIL_26_0

        jmp TEST_27_0

FAIL_26_0:
        mov dx,00036    ; Print a 6
        mov ax,00202
        int 021

                     

; 0x27 - DAA - Decimal Adjust for Addition
; ############################################################

                ; TEST WITH AUX_FLAG=0  and CARRY_FLAG=0
                ; --------------------------------------
TEST_27_0:
        mov cx,000FF    ; Loop count of 256
        mov bx,00000    ; Initialize BX incrementer
        mov dx,00000    ; Initialize DX summation counter

L0:
        mov ax,0AB00    ; Set AH to 0xAB.. Should not be modified.
        add ax,0        ; Cause AUX_FLAG to be set to 0
        mov al,bl       ; Set AL to incremented value
        clc             ; Clear CARRY_FLAG
        daa
        add dx,ax       ; Add results to summation counter
        inc bx          ; Increment to the next value
        loop L0
        cmp dx,0969B    ; All DAA values should add up to this
        jz TEST_27_1

FAIL_27_0:
        mov dx,00037    ; Print a 7
        mov ax,00202
        int 021

                ; TEST WITH AUX_FLAG=0  and CARRY_FLAG=1
                ; --------------------------------------
TEST_27_1:
        mov cx,000FF    ; Loop count of 256
        mov bx,00000    ; Initialize BX incrementer
        mov dx,00000    ; Initialize DX summation counter

L1:
        mov ax,0AB00    ; Set AH to 0xAB.. Should not be modified.
        add ax,0        ; Cause AUX_FLAG to be set to 0
        mov al,bl       ; Set AL to incremented value
        stc             ; Set CARRY_FLAG
        daa
        add dx,ax       ; Add results to summation counter
        inc bx          ; Increment to the next value
        loop L1
        cmp dx,0D05B    ; All DAA values should add up to this
        jz TEST_27_2

FAIL_27_1:
        mov dx,00037    ; Print a 7
        mov ax,00202
        int 021


                ; TEST WITH AUX_FLAG=1  and CARRY_FLAG=0
                ; --------------------------------------
TEST_27_2:
        mov cx,000FF    ; Loop count of 256
        mov bx,00000    ; Initialize BX incrementer
        mov dx,00000    ; Initialize DX summation counter

L2:
        mov ax,0AB01    ; Set AH to 0xAB.. Should not be modified.
        add al,0F       ; Cause AUX_FLAG to be set to 1
        mov al,bl       ; Set AL to incremented value
        clc             ; Clear CARRY_FLAG
        daa
        add dx,ax       ; Add results to summation counter
        inc bx          ; Increment to the next value
        loop L2
        cmp dx,09E1B    ; All DAA values should add up to this
        jz TEST_27_3

FAIL_27_2:
        mov dx,00037    ; Print a 7
        mov ax,00202
        int 021


                ; TEST WITH AUX_FLAG=1  and CARRY_FLAG=1
                ; --------------------------------------
TEST_27_3:
        mov cx,000FF    ; Loop count of 256
        mov bx,00000    ; Initialize BX incrementer
        mov dx,00000    ; Initialize DX summation counter

L3:
        mov ax,0AB01    ; Set AH to 0xAB.. Should not be modified.
        add al,0F       ; Cause AUX_FLAG to be set to 1
        mov al,bl       ; Set AL to incremented value
        stc             ; Set CARRY_FLAG
        daa
        add dx,ax       ; Add results to summation counter
        inc bx          ; Increment to the next value
        loop L3
        cmp dx,0D41B    ; All DAA values should add up to this
        jz TEST_28_0

FAIL_27_3:
        mov dx,00037    ; Print a 7
        mov ax,00202
        int 021

                     

; 0x28 - SUB REG8/MEM8,REG8
; ############################################################

TEST_28_0:             ; SUB MEM8,REG8 - Test data values from memory

        mov ax,es       ; Increment ES so it is not the same as DS
        inc ax
        mov es,ax

        mov byte [00050],088
        mov ax,00011
        lock sub [00050],al     ; test lock prefix
        cmp byte [00050],077
        jne FAIL_28_0

        mov byte [00050],000
        mov ax,00000
        sub [00050],al
        cmp byte [00050],000
        jne FAIL_28_0

        mov byte es:[00052],022 ; test segment override
        mov ax,00011
        sub es:[00052],al
        cmp byte es:[00052],011
        jne FAIL_28_0

        mov byte [00053],000
        mov ax,00001
        sub [00053],al
        cmp byte [00053],0FF
        jne FAIL_28_0
        jmp TEST_28_1

FAIL_28_0:
        mov dx,00038    ; Print a 8
        mov ax,00202
        int 021

; ##################
TEST_28_1:              ; SUB MEM8,REG8 - Test flags
                        ; Overflow, Sign, Zero, Parity, AUX, Carry

        mov byte [00054],080
        mov ax,00066
        sub [00054],al  ; Overflow should be set
        jno FAIL_28_1   ; If not set, then fail

        mov byte [00055],034
        mov ax,00012
        sub [00055],al  ; Overflow should NOT be set
        jno PASS_28_1   ; If not set, then we passed
        jmp FAIL_28_1   ; If set then we fail

PASS_28_1:
        mov byte [00056],000
        mov ax,00001
        sub [00056],al  ; sign should be set
        jns FAIL_28_1   ; If not set, then fail

        mov byte [00057],022
        mov ax,00011
        sub [00057],al  ; sign should NOT be set
        js  FAIL_28_1   ; If set then we fail

        mov byte [00058],001
        mov ax,00001
        sub [00058],al  ; zero should be set
        jne FAIL_28_1   ; If not set then we fail
        jmp PASS_28_2

FAIL_28_1:
        mov dx,00038    ; Print a 8
        mov ax,00202
        int 021
        jmp TEST_29_0

PASS_28_2:
        mov byte [00050],055
        mov ax,00011
        sub [00050],al  ; zero should NOT be set
        je  FAIL_28_1   ; If set then we fail

        mov byte [00050],034
        mov ax,00001
        sub [00050],al  ; parity should be set
        jnp FAIL_28_1   ; If not set then we fail

        mov byte [00050],032
        mov ax,00001
        sub [00050],al  ; parity should NOT be set
        jp  FAIL_28_1   ; If set then we fail

        mov byte [00050],000
        mov ax,00001
        sub [00050],al  ; carry should be set
        jnc FAIL_28_1   ; If not set then we fail

        mov byte [00050],031
        mov ax,00011
        sub [00050],al  ; carry should NOT be set
        jc  FAIL_28_1   ; If set then we fail


; 0x29 - SUB REG16/MEM16,REG16
; ############################################################

TEST_29_0:             ; SUB MEM16,REG16 - Test data values from memory

        mov word [00060],01234
        mov ax,01234
        lock sub [00060],ax
        cmp word [00060],00000
        jne FAIL_29_0

        mov word [00060],00000
        mov ax,00000
        sub [00060],ax
        cmp word [00060],00000
        jne FAIL_29_0

        mov word es:[00060],03333
        mov ax,01111
        sub es:[00060],ax
        cmp word es:[00060],02222
        jne FAIL_29_0

        mov word [00060],00000
        mov ax,00001
        sub [00060],ax
        cmp byte [00060],0FFFF
        jne FAIL_29_0
        jmp TEST_29_1


FAIL_29_0:
        mov dx,00039    ; Print a 9
        mov ax,00202
        int 021

; ##################
TEST_29_1:              ; SUB MEM16,REG16 - Test flags
                        ; Overflow, Sign, Zero, Parity, AUX, Carry

        mov word [00050],08000
        mov ax,00022
        sub [00050],ax  ; Overflow should be set
        jno FAIL_29_1   ; If not set, then fail

        mov word [00050],01234
        mov ax,00001
        sub [00050],ax  ; Overflow should NOT be set
        jno PASS_29_1   ; If not set, then we passed
        jmp FAIL_29_1   ; If set then we fail

PASS_29_1:
        mov word [00050],0FFFF
        mov ax,00001
        sub [00050],ax  ; sign should be set
        jns FAIL_29_1   ; If not set, then fail

        mov word [00050],01234
        mov ax,00002
        sub [00050],ax  ; sign should NOT be set
        js  FAIL_29_1   ; If set then we fail

        mov word [00050],01111
        mov ax,01111
        sub [00050],ax  ; zero should be set
        jne FAIL_29_1   ; If not set then we fail
        jmp PASS_29_2

FAIL_29_1:
        mov dx,00039    ; Print a 9
        mov ax,00202
        int 021
        jmp TEST_2A_0

PASS_29_2:
        mov word [00050],01111
        mov ax,02222
        sub [00050],ax  ; zero should NOT be set
        je  FAIL_29_1   ; If set then we fail

        mov word [00050],04444
        mov ax,01111
        sub [00050],ax  ; parity should be set
        jnp FAIL_29_1   ; If not set then we fail

        mov word [00050],04444
        mov ax,01112
        sub [00050],ax  ; parity should NOT be set
        jp  FAIL_29_1   ; If set then we fail

        mov word [00050],00000
        mov ax,00001
        sub [00050],ax  ; carry should be set
        jnc FAIL_29_1   ; If not set then we fail

        mov word [00050],01234
        mov ax,00001
        sub [00050],ax  ; carry should NOT be set
        jc  FAIL_29_1   ; If set then we fail


; 0x2A - SUB REG8,MEM8/REG8
; ############################################################

TEST_2A_0:             ; SUB REG8,REG8 - Test data values from registers
        mov ax,01234
        lock sub ah,al
        cmp ax,0DE34
        jne FAIL_2A_0

        mov ax,00000
        sub ah,al
        cmp ax,00000
        jne FAIL_2A_0

        mov ax,0FFFF
        sub ah,al
        cmp ax , 000FF
        jne FAIL_2A_0
        jmp TEST_2A_1

FAIL_2A_0:
        mov dx,00041    ; Print a A
        mov ax,00202
        int 021

; ##################

TEST_2A_1:             ; SUB MEM8,REG8 - Test data values from memory

        mov byte [00050],001
        mov ax,000FF
        sub al,[00050]
        cmp al,0FE
        jne FAIL_2A_1

        mov byte [00050],000
        mov ax,00000
        sub al,[00050]
        cmp al,000
        jne FAIL_2A_1

        mov byte es:[00050],001
        mov ax,01234
        sub al,es:[00050]
        cmp ax,01233
        jne FAIL_2A_1

        mov byte [00050],001
        mov ax,00000
        sub al,[00050]
        cmp al,0FF
        jne FAIL_2A_1
        jmp TEST_2A_2



FAIL_2A_1:
        mov dx,00041    ; Print a A
        mov ax,00202
        int 021

; ##################

TEST_2A_2:              ; SUB REG8,REG8 - Test flags
                        ; Overflow, Sign, Zero, Parity, AUX, Carry

        mov ax,08020    ; Test overflow flag
        sub ah,al       ; Overflow should be set
        jno FAIL_2A_2   ; If not set, then fail

        mov ax,00203    ; Test overflow flag
        sub ah,al       ; Overflow should NOT be set
        jno PASS_2A_2   ; If not set, then we passed
        jmp FAIL_2A_2   ; If set then we fail

PASS_2A_2:
        mov dx,00100    ; Test sign flag
        sub dl,dh       ; sign should be set
        jns FAIL_2A_2   ; If not set, then fail

        mov cx,03322    ; Test sign flag
        sub ch,cl       ; sign should NOT be set
        js  FAIL_2A_2   ; If set then we fail

        mov cx,01111    ; Test zero flag
        sub ch,cl       ; zero should be set
        jne FAIL_2A_2   ; If not set then we fail

        mov cx,05432    ; Test zero flag
        sub ch,cl       ; zero should NOT be set
        je  FAIL_2A_2   ; If set then we fail

        mov ax,03401    ; Test parity flag
        sub ah,al       ; parity should be set
        jnp FAIL_2A_2   ; If not set then we fail

        mov cx,03301    ; Test parity flag
        sub ch,cl       ; parity should NOT be set
        jp  FAIL_2A_2   ; If set then we fail

        mov ax,00001    ; Test carry flag
        sub ah,al       ; carry should be set
        jnc FAIL_2A_2   ; If not set then we fail

        mov cx,02211    ; Test carry flag
        sub ch,cl       ; carry should NOT be set
        jc  FAIL_2A_2   ; If set then we fail
        jmp TEST_2B_0

FAIL_2A_2:
        mov dx,00041    ; Print a A
        mov ax,00202
        int 021


; 0x2B - SUB REG16,MEM16/REG16
; ############################################################

TEST_2B_0:             ; SUB REG16,MEM16 - Test data values from memory

        mov word [00055],00000
        mov ax,0FFFF
        sub ax,[00055]
        cmp ax,0FFFF
        jne FAIL_2B_0

        mov word [00057],00002
        mov ax,00000
        sub ax,[00057]
        cmp ax,0FFFE
        jne FAIL_2B_0

        mov word es:[00059],01111
        mov ax,06666
        sub ax,es:[00059]
        cmp ax,05555
        jne FAIL_2B_0

        mov word [00060],01234
        mov ax,01234
        sub ax,[00060]
        cmp ax,00000
        jne FAIL_2B_0
        jmp TEST_2B_1

FAIL_2B_0:
        mov dx,00042    ; Print a B
        mov ax,00202
        int 021

; ##################

TEST_2B_1:              ; SUB REG16,MEM16 - Test flags
                        ; Overflow, Sign, Zero, Parity, AUX, Carry

        mov word [00070],00003  ; Test overflow flag
        mov ax,08000
        sub ax,word [00070]     ; Overflow should be set
        jno FAIL_2B_1           ; If not set, then fail

        mov word [00070],00003  ; Test overflow flag
        mov ax,00456
        sub ax,word [00070]     ; Overflow should NOT be set
        jno PASS_2B_1           ; If not set, then we passed
        jmp FAIL_2B_1           ; If set then we fail

PASS_2B_1:
        mov word [00070],00001  ; Test sign flag
        mov ax,00000
        sub ax,word [00070]     ; Sign should be set
        jns FAIL_2B_1           ; If not set, then fail

        mov word [00070],01234  ; Test sign flag
        mov ax,04321
        sub ax,word [00070]     ; Sign should NOT be set
        js  FAIL_2B_1           ; If set, then fail

        mov word [00070],01234  ; Test zero flag
        mov ax,01234
        sub ax,word [00070]     ; Zero should be set
        jne FAIL_2B_1           ; If not set, then fail

        mov word [00070],00001  ; Test zero flag
        mov ax,01234
        sub ax,word [00070]     ; Zero should NOT be set
        je  FAIL_2B_1           ; If set, then fail
        jmp TEST_2B_2


FAIL_2B_1:
        mov dx,00042    ; Print a B
        mov ax,00202
        int 021


TEST_2B_2:
        mov word [00070],01111  ; Test parity flag
        mov ax,04444
        sub ax,word [00070]     ; Parity should be set
        jnp FAIL_2B_1           ; If not set, then fail

        mov word [00070],01112  ; Test parity flag
        mov ax,04444
        sub ax,word [00070]     ; Parity should NOT be set
        jp  FAIL_2B_1           ; If set, then fail

        mov word [00070],00001  ; Test carry flag
        mov ax,00000
        sub ax,word [00070]     ; Carry should be set
        jnc FAIL_2B_1           ; If not set, then fail

        mov word [00070],01234  ; Test carry flag
        mov ax,05678
        sub ax,word [00070]     ; Carry should NOT be set
        jc  FAIL_2B_1           ; If set, then fail



; 0x2C - SUB AL,IMMED8
; ############################################################

TEST_2C_0:             ; SUB AL,IMMED8 - Test data values from registers
        mov ax,070FF
        lock sub al,001
        cmp ax,070FE
        jne FAIL_2C_0

        mov ax,02222
        sub al,022
        cmp ax,02200
        jne FAIL_2C_0

        mov ax,01200
        sub al,001
        cmp ax , 012FF
        jne FAIL_2C_0
        jmp TEST_2C_1

FAIL_2C_0:
        mov dx,00043    ; Print a C
        mov ax,00202
        int 021

; ##################

TEST_2C_1:              ; SUB AL,IMMED8 - Test flags
                        ; Overflow, Sign, Zero, Parity, AUX, Carry

        mov ax,00080    ; Test overflow flag
        sub al,002      ; Overflow should be set
        jno FAIL_2C_1   ; If not set, then fail

        mov ax,01234    ; Test overflow flag
        sub al,001      ; Overflow should NOT be set
        jno PASS_2C_1   ; If not set, then we passed
        jmp FAIL_2C_1

PASS_2C_1:
        mov ax,00000    ; Test sign flag
        sub al,001      ; sign should be set
        jns FAIL_2C_1   ; If not set, then fail

        mov ax,09911    ; Test sign flag
        sub al,001      ; sign should NOT be set
        js  FAIL_2C_1   ; If set then we fail

        mov ax,02212    ; Test zero flag
        sub al,012      ; zero should be set
        jne FAIL_2C_1   ; If not set then we fail

        mov ax,00022    ; Test zero flag
        sub al,012      ; zero should NOT be set
        je  FAIL_2C_1   ; If set then we fail

        mov ax,01244    ; Test parity flag
        sub al,011      ; parity should be set
        jnp FAIL_2C_1   ; If not set then we fail

        mov ax,01244    ; Test parity flag
        sub al,012      ; parity should NOT be set
        jp  FAIL_2C_1   ; If set then we fail

        mov ax,00000    ; Test carry flag
        sub al,001      ; carry should be set
        jnc FAIL_2C_1   ; If not set then we fail

        mov ax,01234    ; Test carry flag
        sub al,001      ; carry should NOT be set
        jc  FAIL_2C_1   ; If set then we fail

        jmp TEST_2D_0

FAIL_2C_1:
        mov dx,00043    ; Print a C
        mov ax,00202
        int 021


; 0x2D - SUB AX,IMMED16
;

TEST_2D_0:             ; SUB AX,IMMED16 - Test data values from registers
        mov ax,0FFFF
        lock sub ax,00000
        cmp ax,0FFFF
        jne FAIL_2D_0

        mov ax,03333
        sub ax,03333
        cmp ax,00000
        jne FAIL_2D_0

        mov ax,01234
        sub ax,00034
        cmp ax,01200
        jne FAIL_2D_0
        jmp TEST_2D_1

FAIL_2D_0:
        mov dx,00044    ; Print a D
        mov ax,00202
        int 021

; ##################

TEST_2D_1:              ; SUB AX,IMMED16 - Test flags
                        ; Overflow, Sign, Zero, Parity, AUX, Carry

        mov ax,08000    ; Test overflow flag
        sub ax,00002    ; Overflow should be set
        jno FAIL_2D_1   ; If not set, then fail

        mov ax,01212    ; Test overflow flag
        sub ax,00003    ; Overflow should NOT be set
        jno PASS_2D_1   ; If not set, then we passed
        jmp FAIL_2D_1

PASS_2D_1:
        mov ax,00000    ; Test sign flag
        sub ax,00001    ; sign should be set
        jns FAIL_2D_1   ; If not set, then fail

        mov ax,01234    ; Test sign flag
        sub ax,00007    ; sign should NOT be set
        js  FAIL_2D_1   ; If set then we fail

        mov ax,04567    ; Test zero flag
        sub ax,04567    ; zero should be set
        jne FAIL_2D_1   ; If not set then we fail

        mov ax,00001    ; Test zero flag
        sub ax,01234    ; zero should NOT be set
        je  FAIL_2D_1   ; If set then we fail

        mov ax,04444    ; Test parity flag
        sub ax,01111    ; parity should be set
        jnp FAIL_2D_1   ; If not set then we fail

        mov ax,04444    ; Test parity flag
        sub ax,01112    ; parity should NOT be set
        jp  FAIL_2D_1   ; If set then we fail

        mov ax,00000    ; Test carry flag
        sub ax,00001    ; carry should be set
        jnc FAIL_2D_1   ; If not set then we fail

        mov ax,01234    ; Test carry flag
        sub ax,00002    ; carry should NOT be set
        jc  FAIL_2D_1   ; If set then we fail

        jmp TEST_2E_0

FAIL_2D_1:
        mov dx,00044    ; Print a D
        mov ax,00202
        int 021


                   
; 0x2E - CS:  Code Segment Override
; ############################################################

TEST_2E_0:
        mov ax,ds       ; Increment DS so it is not the same as CS
        inc ax
        mov ds,ax

        mov ax,01234
        mov cs:[0B050],ax
        mov ax,05678
        mov [0B050],ax
        cmp cs:[0B050],01234
        jne FAIL_2E_0

        jmp TEST_2F_0

FAIL_2E_0:
        mov dx,00045    ; Print a E
        mov ax,00202
        int 021

                     

; 0x2F - DAS - Decimal Adjust for Subtraction
; ############################################################



                ; TEST WITH AUX_FLAG=0  and CARRY_FLAG=0
                ; --------------------------------------
TEST_2F_0:
        mov cx,000FF    ; Loop count of 256
        mov bx,00000    ; Initialize BX incrementer
        mov dx,00000    ; Initialize DX summation counter

L10:
        mov ax,0AB00    ; Set AH to 0xAB.. Should not be modified.
        add ax,0        ; Cause AUX_FLAG to be set to 0
        mov al,bl       ; Set AL to incremented value
        clc             ; Clear CARRY_FLAG
        das
        add dx,ax       ; Add results to summation counter
        inc bx          ; Increment to the next value
        loop L10
        cmp dx,0AB67    ; All DAA values should add up to this
        jz TEST_2F_1

FAIL_2F_0:
        mov dx,00046    ; Print a F
        mov ax,00202
        int 021

                ; TEST WITH AUX_FLAG=0  and CARRY_FLAG=1
                ; --------------------------------------
TEST_2F_1:
        mov cx,000FF    ; Loop count of 256
        mov bx,00000    ; Initialize BX incrementer
        mov dx,00000    ; Initialize DX summation counter

L11:
        mov ax,0AB00    ; Set AH to 0xAB.. Should not be modified.
        add ax,0        ; Cause AUX_FLAG to be set to 0
        mov al,bl       ; Set AL to incremented value
        stc             ; Set CARRY_FLAG
        das
        add dx,ax       ; Add results to summation counter
        inc bx          ; Increment to the next value
        loop L11
        cmp dx,0D1A7    ; All DAA values should add up to this
        jz TEST_2F_2

FAIL_2F_1:
        mov dx,00046    ; Print a 7
        mov ax,00202
        int 021


                ; TEST WITH AUX_FLAG=1  and CARRY_FLAG=0
                ; --------------------------------------
TEST_2F_2:
        mov cx,000FF    ; Loop count of 256
        mov bx,00000    ; Initialize BX incrementer
        mov dx,00000    ; Initialize DX summation counter

L12:
        mov ax,0AB01    ; Set AH to 0xAB.. Should not be modified.
        add al,0F       ; Cause AUX_FLAG to be set to 1
        mov al,bl       ; Set AL to incremented value
        clc             ; Clear CARRY_FLAG
        das
        add dx,ax       ; Add results to summation counter
        inc bx          ; Increment to the next value
        loop L12
        cmp dx,0AFE7    ; All DAA values should add up to this
        jz TEST_2F_3

FAIL_2F_2:
        mov dx,00046    ; Print a 7
        mov ax,00202
        int 021


                ; TEST WITH AUX_FLAG=1  and CARRY_FLAG=1
                ; --------------------------------------
TEST_2F_3:
        mov cx,000FF    ; Loop count of 256
        mov bx,00000    ; Initialize BX incrementer
        mov dx,00000    ; Initialize DX summation counter

L13:
        mov ax,0AB01    ; Set AH to 0xAB.. Should not be modified.
        add al,0F       ; Cause AUX_FLAG to be set to 1
        mov al,bl       ; Set AL to incremented value
        stc             ; Set CARRY_FLAG
        das
        add dx,ax       ; Add results to summation counter
        inc bx          ; Increment to the next value
        loop L13
        cmp dx,0D3E7    ; All DAA values should add up to this
        jz Z_END

FAIL_2F_3:
        mov dx,00046    ; Print a 7
        mov ax,00202
        int 021



; xxxxxxxxxxxxxxxxxxxxxxx
; End
; xxxxxxxxxxxxxxxxxxxxxxx
Z_END:
        mov ax,00000    ; DOS Command=Exit
        int 021



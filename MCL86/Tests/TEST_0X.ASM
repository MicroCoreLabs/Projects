; Tests for opcode range 0x00-0x0F
; ---------------------------------


; 0x00 - ADD REG8/MEM8,REG8
; ############################################################

TEST_00_0:             ; ADD MEM8,REG8 - Test data values from memory

        mov ax,es       ; Increment ES so it is not the same as DS
        inc ax
        mov es,ax

        mov byte [00050],000
        mov ax,000FF
        lock add [00050],al     ; test lock prefix
        cmp byte [00050],0FF
        jne FAIL_00_0

        mov byte [00050],000
        mov ax,00000
        add [00050],al
        cmp byte [00050],000
        jne FAIL_00_0

        mov byte es:[00052],011 ; test segment override
        mov ax,00022
        add es:[00052],al
        cmp byte es:[00052],033
        jne FAIL_00_0

        mov byte [00053],0FF
        mov ax,000FF
        add [00053],al
        cmp byte [00053],0FE
        jne FAIL_00_0
        jmp TEST_00_1

FAIL_00_0:
        mov dx,00030    ; Print a 0
        mov ax,00202
        int 021

; ##################
TEST_00_1:              ; ADD MEM8,REG8 - Test flags
                        ; Overflow, Sign, Zero, Parity, AUX, Carry

        mov byte [00054],07B
        mov ax,00036
        add [00054],al  ; Overflow should be set
        jno FAIL_00_1   ; If not set, then fail

        mov byte [00055],0B1
        mov ax,00037
        add [00055],al  ; Overflow should NOT be set
        jno PASS_00_1   ; If not set, then we passed
        jmp FAIL_00_1   ; If set then we fail

PASS_00_1:
        mov byte [00056],0FF
        mov ax,000FF
        add [00056],al  ; sign should be set
        jns FAIL_00_1   ; If not set, then fail

        mov byte [00057],011
        mov ax,00022
        add [00057],al  ; sign should NOT be set
        js  FAIL_00_1   ; If set then we fail

        mov byte [00058],000
        mov ax,00000
        add [00058],al  ; zero should be set
        jne FAIL_00_1   ; If not set then we fail
        jmp PASS_00_2

FAIL_00_1:
        mov dx,00030    ; Print a 0
        mov ax,00202
        int 021
        jmp TEST_01_0

PASS_00_2:
        mov byte [00050],000
        mov ax,00001
        add [00050],al  ; zero should NOT be set
        je  FAIL_00_1   ; If set then we fail

        mov byte [00050],012
        mov ax,00035
        add [00050],al  ; parity should be set
        jnp FAIL_00_1   ; If not set then we fail

        mov byte [00050],012
        mov ax,00034
        add [00050],al  ; parity should NOT be set
        jp  FAIL_00_1   ; If set then we fail

        mov byte [00050],0FF
        mov ax,000FF
        add [00050],al  ; carry should be set
        jnc FAIL_00_1   ; If not set then we fail

        mov byte [00050],012
        mov ax,00034
        add [00050],al  ; carry should NOT be set
        jc  FAIL_00_1   ; If set then we fail


; 0x01 - ADD REG16/MEM16,REG16
; ############################################################

TEST_01_0:             ; ADD MEM16,REG16 - Test data values from memory

        mov word [00060],00000
        mov ax,000FF
        lock add [00060],ax
        cmp word [00060],000FF
        jne FAIL_01_0

        mov word [00060],00000
        mov ax,00000
        add [00060],ax
        cmp word [00060],00000
        jne FAIL_01_0

        mov word es:[00060],03333
        mov ax,01111
        add es:[00060],ax
        cmp word es:[00060],04444
        jne FAIL_01_0

        mov word [00060],000FF
        mov ax,000FF
        add [00060],ax
        cmp byte [00060],000FE
        jne FAIL_01_0
        jmp TEST_01_1


FAIL_01_0:
        mov dx,00031    ; Print a 1
        mov ax,00202
        int 021

; ##################
TEST_01_1:              ; ADD MEM16,REG16 - Test flags
                        ; Overflow, Sign, Zero, Parity, AUX, Carry

        mov word [00050],07FFF
        mov ax,01234
        add [00050],ax  ; Overflow should be set
        jno FAIL_01_1   ; If not set, then fail

        mov word [00050],01212
        mov ax,03434
        add [00050],ax  ; Overflow should NOT be set
        jno PASS_01_1   ; If not set, then we passed
        jmp FAIL_01_1   ; If set then we fail

PASS_01_1:
        mov word [00050],00001
        mov ax,07FFF
        add [00050],ax  ; sign should be set
        jns FAIL_01_1   ; If not set, then fail

        mov word [00050],01234
        mov ax,04321
        add [00050],ax  ; sign should NOT be set
        js  FAIL_01_1   ; If set then we fail

        mov word [00050],00000
        mov ax,00000
        add [00050],ax  ; zero should be set
        jne FAIL_01_1   ; If not set then we fail
        jmp PASS_01_2

FAIL_01_1:
        mov dx,00032    ; Print a 2
        mov ax,00202
        int 021
        jmp TEST_02_0

PASS_01_2:
        mov word [00050],01111
        mov ax,02222
        add [00050],ax  ; zero should NOT be set
        je  FAIL_01_1   ; If set then we fail

        mov word [00050],04444
        mov ax,01111
        add [00050],ax  ; parity should be set
        jnp FAIL_01_1   ; If not set then we fail

        mov word [00050],01111
        mov ax,01234
        add [00050],ax  ; parity should NOT be set
        jp  FAIL_01_1   ; If set then we fail

        mov word [00050],0FFFF
        mov ax,00001
        add [00050],ax  ; carry should be set
        jnc FAIL_01_1   ; If not set then we fail

        mov word [00050],01234
        mov ax,05678
        add [00050],ax  ; carry should NOT be set
        jc  FAIL_01_1   ; If set then we fail


; 0x02 - ADD REG8,MEM8/REG8
; ############################################################

TEST_02_0:             ; ADD REG8,REG8 - Test data values from registers
        mov ax,000FF
        lock add ah,al
        cmp ax,0FFFF
        jne FAIL_02_0

        mov ax,00000
        add ah,al
        cmp ax,00000
        jne FAIL_02_0

        mov ax,0FFFF
        add ah,al
        cmp ax , 0FEFF
        jne FAIL_02_0
        jmp TEST_02_1

FAIL_02_0:
        mov dx,00032    ; Print a 2
        mov ax,00202
        int 021

; ##################

TEST_02_1:             ; ADD MEM8,REG8 - Test data values from memory

        mov byte [00050],000
        mov ax,000FF
        add al,[00050]
        cmp al,0FF
        jne FAIL_02_1

        mov byte [00050],000
        mov ax,00000
        add al,[00050]
        cmp al,000
        jne FAIL_02_1

        mov byte es:[00050],066
        mov ax,00011
        add al,es:[00050]
        cmp al,077
        jne FAIL_02_1

        mov byte [00050],0FF
        mov ax,000FF
        add al,[00050]
        cmp al,0FE
        jne FAIL_02_1
        jmp TEST_02_2



FAIL_02_1:
        mov dx,00032    ; Print a 2
        mov ax,00202
        int 021

; ##################

TEST_02_2:              ; ADD REG8,REG8 - Test flags
                        ; Overflow, Sign, Zero, Parity, AUX, Carry

        mov ax,07B36    ; Test overflow flag
        add ah,al       ; Overflow should be set
        jno FAIL_02_2   ; If not set, then fail

        mov ax,0B137    ; Test overflow flag
        add ah,al       ; Overflow should NOT be set
        jno PASS_02_2   ; If not set, then we passed
        jmp FAIL_02_2   ; If set then we fail

PASS_02_2:
        mov dx,0FFFF    ; Test sign flag
        add dl,dh       ; sign should be set
        jns FAIL_02_2   ; If not set, then fail

        mov cx,01122    ; Test sign flag
        add ch,cl       ; sign should NOT be set
        js  FAIL_02_2   ; If set then we fail

        mov cx,00000    ; Test zero flag
        add ch,cl       ; zero should be set
        jne FAIL_02_2   ; If not set then we fail

        mov cx,00001    ; Test zero flag
        add ch,cl       ; zero should NOT be set
        je  FAIL_02_2   ; If set then we fail

        mov ax,01235    ; Test parity flag
        add ah,al       ; parity should be set
        jnp FAIL_02_2   ; If not set then we fail

        mov cx,01234    ; Test parity flag
        add ch,cl       ; parity should NOT be set
        jp  FAIL_02_2   ; If set then we fail

        mov ax,0FFFF    ; Test carry flag
        add ah,al       ; carry should be set
        jnc FAIL_02_2   ; If not set then we fail

        mov cx,01234    ; Test carry flag
        add ch,cl       ; carry should NOT be set
        jc  FAIL_02_2   ; If set then we fail
        jmp TEST_03_0

FAIL_02_2:
        mov dx,00032    ; Print a 2
        mov ax,00202
        int 021


; 0x03 - ADD REG16,MEM16/REG16
; ############################################################

TEST_03_0:             ; ADD MEM16,REG16 - Test data values from memory

        mov word [00055],00000
        mov ax,0FFFF
        add ax,[00055]
        cmp ax,0FFFF
        jne FAIL_03_0

        mov word [00057],00000
        mov ax,00000
        add ax,[00057]
        cmp ax,00000
        jne FAIL_03_0

        mov word es:[00059],06666
        mov ax,01111
        add ax,es:[00059]
        cmp ax,07777
        jne FAIL_03_0

        mov word [00060],0FFFF
        mov ax,0FFFF
        add ax,[00060]
        cmp ax,0FFFE
        jne FAIL_03_0
        jmp TEST_03_1

FAIL_03_0:
        mov dx,00033    ; Print a 3
        mov ax,00202
        int 021

; ##################

TEST_03_1:              ; ADD REG16,MEM16 - Test flags
                        ; Overflow, Sign, Zero, Parity, AUX, Carry

        mov word [00070],07FFF  ; Test overflow flag
        mov ax,01234
        add ax,word [00070]     ; Overflow should be set
        jno FAIL_03_1           ; If not set, then fail

        mov word [00070],01212  ; Test overflow flag
        mov ax,03434
        add ax,word [00070]     ; Overflow should NOT be set
        jno PASS_03_1           ; If not set, then we passed
        jmp FAIL_03_1           ; If set then we fail

PASS_03_1:
        mov word [00070],00001  ; Test sign flag
        mov ax,07FFF
        add ax,word [00070]     ; Sign should be set
        jns FAIL_03_1           ; If not set, then fail

        mov word [00070],01234  ; Test sign flag
        mov ax,04321
        add ax,word [00070]     ; Sign should NOT be set
        js  FAIL_03_1           ; If set, then fail

        mov word [00070],00000  ; Test zero flag
        mov ax,00000
        add ax,word [00070]     ; Zero should be set
        jne FAIL_03_1           ; If not set, then fail

        mov word [00070],00001  ; Test zero flag
        mov ax,00000
        add ax,word [00070]     ; Zero should NOT be set
        je  FAIL_03_1           ; If set, then fail
        jmp TEST_03_2


FAIL_03_1:
        mov dx,00033    ; Print a 3
        mov ax,00202
        int 021


TEST_03_2:
        mov word [00070],01111  ; Test parity flag
        mov ax,01111
        add ax,word [00070]     ; Parity should be set
        jnp FAIL_03_1           ; If not set, then fail

        mov word [00070],01111  ; Test parity flag
        mov ax,01234
        add ax,word [00070]     ; Parity should NOT be set
        jp  FAIL_03_1           ; If set, then fail

        mov word [00070],0FFFF  ; Test carry flag
        mov ax,00001
        add ax,word [00070]     ; Carry should be set
        jnc FAIL_03_1           ; If not set, then fail

        mov word [00070],01234  ; Test carry flag
        mov ax,05678
        add ax,word [00070]     ; Carry should NOT be set
        jc  FAIL_03_1           ; If set, then fail



; 0x04 - ADD AL,IMMED8
; ############################################################

TEST_04_0:             ; ADD AL,IMMED8 - Test data values from registers
        mov ax,000FF
        lock add al,000
        cmp ax,000FF
        jne FAIL_04_0

        mov ax,00000
        add al,000
        cmp ax,00000
        jne FAIL_04_0

        mov ax,012FF
        add al,0FF
        cmp ax , 012FE
        jne FAIL_04_0
        jmp TEST_04_1

FAIL_04_0:
        mov dx,00034    ; Print a 4
        mov ax,00202
        int 021

; ##################

TEST_04_1:              ; ADD AL,IMMED8 - Test flags
                        ; Overflow, Sign, Zero, Parity, AUX, Carry

        mov ax,0007B    ; Test overflow flag
        add al,036      ; Overflow should be set
        jno FAIL_04_1   ; If not set, then fail

        mov ax,037B1    ; Test overflow flag
        add al,037      ; Overflow should NOT be set
        jno PASS_04_1   ; If not set, then we passed
        jmp FAIL_04_1

PASS_04_1:
        mov ax,0FFFF    ; Test sign flag
        add al,0FF      ; sign should be set
        jns FAIL_04_1   ; If not set, then fail

        mov ax,09911    ; Test sign flag
        add al,022      ; sign should NOT be set
        js  FAIL_04_1   ; If set then we fail

        mov ax,00000    ; Test zero flag
        add al,000      ; zero should be set
        jne FAIL_04_1   ; If not set then we fail

        mov ax,00001    ; Test zero flag
        add al,012      ; zero should NOT be set
        je  FAIL_04_1   ; If set then we fail

        mov ax,01235    ; Test parity flag
        add al,012      ; parity should be set
        jnp FAIL_04_1   ; If not set then we fail

        mov ax,01234    ; Test parity flag
        add al,012      ; parity should NOT be set
        jp  FAIL_04_1   ; If set then we fail

        mov ax,0FFFF    ; Test carry flag
        add al,001      ; carry should be set
        jnc FAIL_04_1   ; If not set then we fail

        mov ax,01234    ; Test carry flag
        add al,012      ; carry should NOT be set
        jc  FAIL_04_1   ; If set then we fail

        jmp TEST_05_0

FAIL_04_1:
        mov dx,00034    ; Print a 4
        mov ax,00202
        int 021


; 0x05 - ADD AX,IMMED16
;

TEST_05_0:             ; ADD AX,IMMED16 - Test data values from registers
        mov ax,0FFFF
        lock add ax,00000
        cmp ax,0FFFF
        jne FAIL_05_0

        mov ax,00000
        add ax,00000
        cmp ax,00000
        jne FAIL_05_0

        mov ax,01200
        add ax,00034
        cmp ax,01234
        jne FAIL_05_0
        jmp TEST_05_1

FAIL_05_0:
        mov dx,00035    ; Print a 5
        mov ax,00202
        int 021

; ##################

TEST_05_1:              ; ADD AX,IMMED16 - Test flags
                        ; Overflow, Sign, Zero, Parity, AUX, Carry

        mov ax,07FFF    ; Test overflow flag
        add ax,01234    ; Overflow should be set
        jno FAIL_05_1   ; If not set, then fail

        mov ax,01212    ; Test overflow flag
        add ax,03434    ; Overflow should NOT be set
        jno PASS_05_1   ; If not set, then we passed
        jmp FAIL_05_1

PASS_05_1:
        mov ax,00001    ; Test sign flag
        add ax,07FFF    ; sign should be set
        jns FAIL_05_1   ; If not set, then fail

        mov ax,01234    ; Test sign flag
        add ax,04321    ; sign should NOT be set
        js  FAIL_05_1   ; If set then we fail

        mov ax,00000    ; Test zero flag
        add ax,00000    ; zero should be set
        jne FAIL_05_1   ; If not set then we fail

        mov ax,00001    ; Test zero flag
        add ax,01234    ; zero should NOT be set
        je  FAIL_05_1   ; If set then we fail

        mov ax,04444    ; Test parity flag
        add ax,01111    ; parity should be set
        jnp FAIL_05_1   ; If not set then we fail

        mov ax,01111    ; Test parity flag
        add ax,01234    ; parity should NOT be set
        jp  FAIL_05_1   ; If set then we fail

        mov ax,0FFFF    ; Test carry flag
        add ax,00001    ; carry should be set
        jnc FAIL_05_1   ; If not set then we fail

        mov ax,01234    ; Test carry flag
        add ax,05678    ; carry should NOT be set
        jc  FAIL_05_1   ; If set then we fail

        jmp TEST_06_0

FAIL_05_1:
        mov dx,00035    ; Print a 5
        mov ax,00202
        int 021


; 0x06 - PUSH ES
; ############################################################

TEST_06_0:
        mov ax,01234
        mov es,ax
        lock push es
        pop bx
        cmp ax,bx
        jne FAIL_06_0

        jmp TEST_07_0

FAIL_06_0:
        mov dx,00036    ; Print a 6
        mov ax,00202
        int 021


; 0x07 - POP ES
; ############################################################

TEST_07_0:
        mov ax,01234
        push ax
        lock pop es
        mov bx,es
        cmp ax,bx
        jne FAIL_07_0

        jmp TEST_08_0

FAIL_07_0:
        mov dx,00037    ; Print a 7
        mov ax,00202
        int 021
                   
; 0x08 - OR REG8/MEM8,REG8
; ############################################################

TEST_08_0:             ; OR MEM8,REG8 - Test data values from memory

        mov ax,es       ; Increment ES so it is not the same as DS
        inc ax
        mov es,ax

        mov byte [00050],05A
        mov ax,000A5
        lock or [00050],al
        cmp byte [00050],0FF
        jne FAIL_08_0

        mov byte [00050],000
        mov ax,00000
        or [00050],al
        cmp byte [00050],000
        jne FAIL_08_0

        mov byte es:[00050],080
        mov ax,00001
        or es:[00050],al
        cmp byte es:[00050],081
        jne FAIL_08_0
        jmp TEST_08_1


FAIL_08_0:
        mov dx,00038    ; Print a 8
        mov ax,00202
        int 021

; ##################
TEST_08_1:              ; OR MEM8,REG8 - Test flags
                        ; Overflow, Sign, Zero, Parity, AUX, Carry

        mov byte [00050],011
        mov ax,00022
        or [00050],al  ; Overflow should NEVER be set
        jno PASS_08_1   ; If not set, then we passed
        jmp FAIL_08_1   ; If set then we fail

PASS_08_1:
        mov byte [00050],080
        mov ax,00000
        or [00050],al  ; sign should be set
        jns FAIL_08_1   ; If not set, then fail

        mov byte [00050],011
        mov ax,00022
        or [00050],al  ; sign should NOT be set
        js  FAIL_08_1   ; If set then we fail

        mov byte [00050],000
        mov ax,00000
        or [00050],al  ; zero should be set
        jne FAIL_08_1   ; If not set then we fail
        jmp PASS_08_2

FAIL_08_1:
        mov dx,00038    ; Print a 8
        mov ax,00202
        int 021
        jmp TEST_09_0

PASS_08_2:
        mov byte [00050],000
        mov ax,00001
        or [00050],al  ; zero should NOT be set
        je  FAIL_08_1   ; If set then we fail

        mov byte [00050],001
        mov ax,00002
        or [00050],al  ; parity should be set
        jnp FAIL_08_1   ; If not set then we fail

        mov byte [00050],001
        mov ax,00006
        or [00050],al  ; parity should NOT be set
        jp  FAIL_08_1   ; If set then we fail

        mov byte [00050],012
        mov ax,00034
        or [00050],al  ; carry should NEVER be set
        jc  FAIL_08_1   ; If set then we fail


; 0x09 - OR REG16/MEM16,REG16
; ############################################################

TEST_09_0:             ; OR MEM16,REG16 - Test data values from memory

        mov word [00050],05A5A
        mov ax,0A5A5
        lock or [00050],ax
        cmp word [00050],0FFFF
        jne FAIL_09_0

        mov word [00050],00000
        mov ax,00000
        or [00050],ax
        cmp word [00050],00000
        jne FAIL_09_0

        mov word es:[00050],01111
        mov ax,02222
        or es:[00050],ax
        cmp word es:[00050],03333
        jne FAIL_09_0
        jmp TEST_09_1


FAIL_09_0:
        mov dx,00039    ; Print a 9
        mov ax,00202
        int 021

; ##################
TEST_09_1:              ; OR MEM16,REG16 - Test flags
                        ; Overflow, Sign, Zero, Parity, AUX, Carry

        mov word [00050],01111
        mov ax,02222
        or [00050],ax  ; Overflow should NEVER be set
        jno PASS_09_1   ; If not set, then we passed
        jmp FAIL_09_1   ; If set then we fail

PASS_09_1:
        mov word [00050],08000
        mov ax,00001
        or [00050],ax  ; sign should be set
        jns FAIL_09_1   ; If not set, then fail

        mov word [00050],07FF0
        mov ax,0000F
        or [00050],ax  ; sign should NOT be set
        js  FAIL_09_1   ; If set then we fail

        mov word [00050],00000
        mov ax,00000
        or [00050],ax  ; zero should be set
        jne FAIL_09_1   ; If not set then we fail
        jmp PASS_09_2

FAIL_09_1:
        mov dx,00039    ; Print a 9
        mov ax,00202
        int 021
        jmp TEST_0A_0

PASS_09_2:
        mov word [00050],00000
        mov ax,00001
        or [00050],ax  ; zero should NOT be set
        je  FAIL_09_1   ; If set then we fail

        mov word [00050],00011
        mov ax,00022
        or [00050],ax  ; parity should be set
        jnp FAIL_09_1   ; If not set then we fail

        mov word [00050],00011
        mov ax,00002
        or [00050],ax  ; parity should NOT be set
        jp  FAIL_09_1   ; If set then we fail

        mov word [00050],00012
        mov ax,00034
        or [00050],ax  ; carry should NEVER be set
        jc  FAIL_09_1   ; If set then we fail


; 0x0A - OR REG8,MEM8/REG8
; ############################################################

TEST_0A_0:             ; OR REG8,REG8 - Test data values from registers
        mov ax,05AA5
        lock or ah,al
        cmp ax,0FFA5
        jne FAIL_0A_0

        mov ax,00000
        or ah,al
        cmp ax,00000
        jne FAIL_0A_0

        mov ax,08001
        or ah,al
        cmp ax,08101
        jne FAIL_0A_0
        jmp TEST_0A_1

FAIL_0A_0:
        mov dx,00041    ; Print a A
        mov ax,00202
        int 021

; ##################

TEST_0A_1:             ; OR MEM8,REG8 - Test data values from memory

        mov byte [00050],05A
        mov ax,000A5
        or al,[00050]
        cmp al,0FF
        jne FAIL_0A_1

        mov byte [00050],000
        mov ax,00000
        or al,[00050]
        cmp al,000
        jne FAIL_0A_1

        mov byte es:[00050],080
        mov ax,00001
        or al,es:[00050]
        cmp al,081
        jne FAIL_0A_1
        jmp TEST_0A_2



FAIL_0A_1:
        mov dx,00041    ; Print a A
        mov ax,00202
        int 021

; ##################

TEST_0A_2:              ; OR REG8,REG8 - Test flags
                        ; Overflow, Sign, Zero, Parity, AUX, Carry

        mov ax,0B137    ; Test overflow flag
        or ah,al        ; Overflow should NEVER be set
        jno PASS_0A_2   ; If not set, then we passed
        jmp FAIL_0A_2   ; If set then we fail

PASS_0A_2:
        mov dx,0FFFF    ; Test sign flag
        or dl,dh        ; sign should be set
        jns FAIL_0A_2   ; If not set, then fail

        mov cx,01122    ; Test sign flag
        or ch,cl        ; sign should NOT be set
        js FAIL_0A_2    ; If set then we fail

        mov cx,00000    ; Test zero flag
        or ch,cl        ; zero should be set
        jne FAIL_0A_2   ; If not set then we fail

        mov cx,00001    ; Test zero flag
        or ch,cl        ; zero should NOT be set
        je  FAIL_0A_2   ; If set then we fail

        mov ax,00102    ; Test parity flag
        or ah,al        ; parity should be set
        jnp FAIL_0A_2   ; If not set then we fail

        mov cx,00100    ; Test parity flag
        or ch,cl        ; parity should NOT be set
        jp  FAIL_0A_2   ; If set then we fail

        mov cx,01234    ; Test carry flag
        or ch,cl        ; carry should NEVER be set
        jc  FAIL_0A_2   ; If set then we fail
        jmp TEST_0B_1

FAIL_0A_2:
        mov dx,00041    ; Print a A
        mov ax,00202
        int 021


; 0x0B - OR REG16,MEM16/REG16
; ############################################################

TEST_0B_1:             ; OR MEM16,REG16 - Test data values from memory
        mov word [00050],05A5A
        mov ax,0A5A5
        lock or ax,[00050]
        cmp ax,0FFFF
        jne FAIL_0B_1

        mov word [00050],00000
        mov ax,00000
        or ax,[00050]
        cmp ax,00000
        jne FAIL_0B_1

        mov word es:[00050],01111
        mov ax,02222
        or ax,es:[00050]
        cmp ax,03333
        jne FAIL_0B_1
        jmp TEST_0B_2

FAIL_0B_1:
        mov dx,00042    ; Print a B
        mov ax,00202
        int 021

; ##################

TEST_0B_2:              ; OR REG16,REG16 - Test flags
                        ; Overflow, Sign, Zero, Parity, AUX, Carry

        mov ax,01234    ; Test overflow flag
        mov word[00060],05678
        or ax,[00060]   ; Overflow should NEVER be set
        jno PASS_0B_2   ; If not set, then we passed
        jmp FAIL_0B_2   ; If set then we fail

PASS_0B_2:
        mov ax,08000    ; Test sign flag
        mov word[00060],00001
        or ax,[00060]   ; sign should be set
        jns FAIL_0B_2   ; If not set, then fail

        mov ax,01122    ; Test sign flag
        mov word[00060],01234
        or ax,[00060]   ; sign should NOT be set
        js  FAIL_0B_2   ; If set then we fail

        mov ax,00000    ; Test zero flag
        mov word[00060],00000
        or ax,[00060]   ; zero should be set
        jne FAIL_0B_2   ; If not set then we fail

        mov ax,00001    ; Test zero flag
        mov word[00060],00000
        or ax,[00060]        ; zero should NOT be set
        je  FAIL_0B_2   ; If set then we fail

        mov ax,00011    ; Test parity flag
        mov word[00060],00011
        or ax,[00060]   ; parity should be set
        jnp FAIL_0B_2   ; If not set then we fail

        mov ax,00013   ; Test parity flag
        mov word[00060],00013
        or ax,[00060]  ; parity should NOT be set
        jp FAIL_0B_2   ; If set then we fail

        mov ax,0FFFF    ; Test carry flag
        mov word[00060],0FFFF
        or ax,[00060]   ; carry should NEVER be set
        jc  FAIL_0B_2   ; If set then we fail

        jmp TEST_0C_0

FAIL_0B_2:
        mov dx,00042    ; Print a B
        mov ax,00202
        int 021


; 0x0C - OR AL,IMMED8
; ############################################################

TEST_0C_0:             ; OR AL,IMMED8 - Test data values from registers
        mov ax,0005A
        lock or al,0A5
        cmp ax,000FF
        jne FAIL_0C_0

        mov ax,00000
        or al,000
        cmp ax,00000
        jne FAIL_0C_0
        jmp TEST_0C_1

FAIL_0C_0:
        mov dx,00043    ; Print a C
        mov ax,00202
        int 021

; ##################

TEST_0C_1:              ; OR AL,IMMED8 - Test flags
                        ; Overflow, Sign, Zero, Parity, AUX, Carry

        mov ax,01234    ; Test overflow flag
        or al,011       ; Overflow should NEVER be set
        jno PASS_0C_1   ; If not set, then we passed
        jmp FAIL_0C_1

PASS_0C_1:
        mov ax,00080    ; Test sign flag
        or al,001       ; sign should be set
        jns FAIL_0C_1   ; If not set, then fail

        mov ax,0007E    ; Test sign flag
        or al,001       ; sign should NOT be set
        js  FAIL_0C_1   ; If set then we fail

        mov ax,00000    ; Test zero flag
        or al,000       ; zero should be set
        jne FAIL_0C_1   ; If not set then we fail

        mov ax,00001    ; Test zero flag
        or al,012       ; zero should NOT be set
        je  FAIL_0C_1   ; If set then we fail

        mov ax,01201    ; Test parity flag
        or al,002       ; parity should be set
        jnp FAIL_0C_1   ; If not set then we fail

        mov ax,01201    ; Test parity flag
        or al,006       ; parity should NOT be set
        jp  FAIL_0C_1   ; If set then we fail

        mov ax,01234    ; Test carry flag
        or al,012       ; carry should NEVER be set
        jc  FAIL_0C_1   ; If set then we fail

        jmp TEST_0D_0

FAIL_0C_1:
        mov dx,00043    ; Print a C
        mov ax,00202
        int 021


; 0x0D - OR AX,IMMED16
; ############################################################

TEST_0D_0:             ; OR AX,IMMED16 - Test data values from registers
        mov ax,05A5A
        lock or ax,0A5A5
        cmp ax,0FFFF
        jne FAIL_0D_0

        mov ax,00000
        or ax,00000
        cmp ax,00000
        jne FAIL_0D_0
        jmp TEST_0D_1

FAIL_0D_0:
        mov dx,00044    ; Print a D
        mov ax,00202
        int 021

; ##################

TEST_0D_1:              ; OR AX,IMMED16 - Test flags
                        ; Overflow, Sign, Zero, Parity, AUX, Carry

        mov ax,0B137    ; Test overflow flag
        or ax,01234     ; Overflow should NEVER be set
        jno PASS_0D_1   ; If not set, then we passed
        jmp FAIL_0D_1

PASS_0D_1:
        mov ax,08000    ; Test sign flag
        or ax,00001     ; sign should be set
        jns FAIL_0D_1   ; If not set, then fail

        mov ax,07FFE    ; Test sign flag
        or ax,00001     ; sign should NOT be set
        js  FAIL_0D_1   ; If set then we fail

        mov ax,00000    ; Test zero flag
        or ax,00000     ; zero should be set
        jne FAIL_0D_1   ; If not set then we fail

        mov ax,00001    ; Test zero flag
        or ax,00000     ; zero should NOT be set
        je  FAIL_0D_1   ; If set then we fail

        mov ax,00001    ; Test parity flag
        or ax,00002     ; parity should be set
        jnp FAIL_0D_1   ; If not set then we fail

        mov ax,00001    ; Test parity flag
        or ax,00006     ; parity should NOT be set
        jp  FAIL_0D_1   ; If set then we fail

        mov ax,01234    ; Test carry flag
        or ax,01234     ; carry should NEVER be set
        jc  FAIL_0D_1   ; If set then we fail

        jmp TEST_0E_0

FAIL_0D_1:
        mov dx,00044    ; Print a D
        mov ax,00202
        int 021


; 0x0E - PUSH CS
; ############################################################

TEST_0E_0:
        mov ax,cs
        lock push cs
        pop bx
        cmp ax,bx
        jne FAIL_0E_0

        jmp Z_END

FAIL_0E_0:
        mov dx,00045    ; Print a E
        mov ax,00202
        int 021



; xxxxxxxxxxxxxxxxxxxxxxx
; End
; xxxxxxxxxxxxxxxxxxxxxxx
Z_END:
        mov ax,00000    ; DOS Command=Exit
        int 021



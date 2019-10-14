; Tests for opcode range 0xA0-0xAF
; ---------------------------------

                   
; 0xA0 - MOV AL,MEM8
; ############################################################

TEST_A0_0:
        mov byte [00050],05A
        mov al, byte[00050]
        cmp al,005A
        jne FAIL_A0_0
        jmp TEST_A1_0

FAIL_A0_0:
        mov dx,00030    ; Print a 0
        mov ax,00202
        int 021
        jmp Z_END

; 0xA1 - MOV AX,MEM16
; ############################################################

TEST_A1_0:
        mov word [00050],0ABCD
        mov ax, word [00050]
        cmp ax,0ABCD
        jne FAIL_A1_0
        jmp TEST_A2_0

FAIL_A1_0:
        mov dx,00031    ; Print a 1
        mov ax,00202
        int 021
        jmp Z_END


                   
; 0xA2 - MOV MEM8,AL
; ############################################################

TEST_A2_0:
        mov al,022
        mov byte [00050],al
        cmp byte [00050],022
        jne FAIL_A2_0
        jmp TEST_A3_0

FAIL_A2_0:
        mov dx,00032    ; Print a 2
        mov ax,00202
        int 021
        jmp Z_END


; 0xA3 - MOV AX,MEM16
; ############################################################

TEST_A3_0:
        mov ax,0ABCD
        mov word [00050],ax
        cmp word [00050],0ABCD
        jne FAIL_A3_0
        jmp TEST_A4_0

FAIL_A3_0:
        mov dx,00033    ; Print a 3
        mov ax,00202
        int 021



; 0xA4 - MOVSB
; ############################################################

TEST_A4_0:      ; Direction set to 0

        mov bx,0B000
        mov ax,0B001    ; Set the pointers
        mov si,ax
        add ax,00005
        mov di,ax
        cld             ; Clear direction to incrementing
        mov byte ds:[bx+000],05A
        mov byte ds:[bx+001],011
        mov byte ds:[bx+002],022
        mov byte ds:[bx+003],033
        mov byte ds:[bx+004],044
        mov byte ds:[bx+005],05A
        movsb
        lock movsb
        movsb
        movsb
        cmp byte es:[di-04],011    ; Confifm the data was moved
        jne FAIL_A4_0
        cmp byte es:[di-03],022
        jne FAIL_A4_0
        cmp byte es:[di-02],033
        jne FAIL_A4_0
        cmp byte es:[di-01],044
        jne FAIL_A4_0
        cmp byte ds:[bx+000],05A         ; Confifm surrounding data untouched
        jne FAIL_A4_0
        cmp byte ds:[bx+005],05A
        jne FAIL_A4_0
        cmp di,0B00A            ; Check DI was incremented
        jne FAIL_A4_0
        cmp si,0B005            ; Check SI was incremented
        jne FAIL_A4_0
        jmp TEST_A4_1


FAIL_A4_0:
        mov dx,00034    ; Print a 4
        mov ax,00202
        int 021



TEST_A4_1:      ; Direction set to 1

        mov ax,ds       ; Increment the DS
        inc ax
        mov ds,ax


        mov bx,0B000
        mov ax,0B004    ; Set the pointers
        mov si,ax
        mov ax,0B009
        mov di,ax
        std             ; Set direction to decrementing
        mov byte es:[bx+000],05A
        mov byte es:[bx+001],055
        mov byte es:[bx+002],066
        mov byte es:[bx+003],077
        mov byte es:[bx+004],088
        mov byte es:[bx+005],05A
        es: movsb
        es: movsb
        es: movsb
        es: movsb
        cmp byte es:[di+01],055    ; Confifm the data was moved
        jne FAIL_A4_1
        cmp byte es:[di+02],066
        jne FAIL_A4_1
        cmp byte es:[di+03],077
        jne FAIL_A4_1
        cmp byte es:[di+04],088
        jne FAIL_A4_1
        cmp byte es:[bx+000],05A         ; Confifm surrounding data untouched
        jne FAIL_A4_1
        cmp byte es:[bx+005],05A
        jne FAIL_A4_1
        cmp di,0B005            ; Check DI was decremented
        jne FAIL_A4_1
        cmp si,0B000            ; Check SI was decremented
        jne FAIL_A4_1
        jmp TEST_A4_2


FAIL_A4_1:
        mov dx,00034    ; Print a 4
        mov ax,00202
        int 021

TEST_A4_2:      ; Use REP prefix instead of single movsb's

        mov bx,0B000
        mov ax,0B001    ; Set the pointers
        mov si,ax
        add ax,00005
        mov di,ax
        cld             ; Clear direction to incrementing
        mov byte ds:[bx+000],05A
        mov byte ds:[bx+001],011
        mov byte ds:[bx+002],022
        mov byte ds:[bx+003],033
        mov byte ds:[bx+004],044
        mov byte ds:[bx+005],05A
        mov cx,04
        rep movsb
        cmp byte es:[di-04],011    ; Confifm the data was moved
        jne FAIL_A4_2
        cmp byte es:[di-03],022
        jne FAIL_A4_2
        cmp byte es:[di-02],033
        jne FAIL_A4_2
        cmp byte es:[di-01],044
        jne FAIL_A4_2
        cmp byte ds:[bx+000],05A         ; Confifm surrounding data untouched
        jne FAIL_A4_2
        cmp byte ds:[bx+005],05A
        jne FAIL_A4_2
        cmp di,0B00A            ; Check DI was incremented
        jne FAIL_A4_2
        cmp si,0B005            ; Check SI was incremented
        jne FAIL_A4_2
        jmp TEST_A5_0


FAIL_A4_2:
        mov dx,00034    ; Print a 4
        mov ax,00202
        int 021



; 0xA5 - MOVSW
; ############################################################

TEST_A5_0:      ; Direction set to 0

        mov bx,0C000
        mov ax,0C002    ; Set the pointers
        mov si,ax
        mov ax,0C012
        mov di,ax
        cld             ; Clear direction to incrementing
        mov word ds:[bx+000],05AA5
        mov word ds:[bx+002],01122
        mov word ds:[bx+004],03344
        mov word ds:[bx+006],05566
        mov word ds:[bx+008],07788
        mov word ds:[bx+00A],0A55A
        movsw
        movsw
        movsw
        movsw
        cmp word es:[di-08],01122    ; Confifm the data was moved
        jne FAIL_A5_0
        cmp word es:[di-06],03344
        jne FAIL_A5_0
        cmp word es:[di-04],05566
        jne FAIL_A5_0
        cmp word es:[di-02],07788
        jne FAIL_A5_0
        cmp di,0C01A            ; Check DI was incremented
        jne FAIL_A5_0
        cmp si,0C00A            ; Check SI was incremented
        jne FAIL_A5_0
        jmp TEST_A5_1


FAIL_A5_0:
        mov dx,00035    ; Print a 5
        mov ax,00202
        int 021


TEST_A5_1:      ; Direction set to 1

        mov ax,ds       ; Increment the DS
        inc ax
        mov ds,ax

        mov bx,0C000
        mov ax,0C008    ; Set the pointers
        mov si,ax
        mov ax,0C018
        mov di,ax
        std             ; Set direction to decrementing
        mov word es:[bx+000],00000
        mov word es:[bx+002],01A1A
        mov word es:[bx+004],02B2B
        mov word es:[bx+006],03C3C
        mov word es:[bx+008],04D4D
        mov word es:[bx+00A],0EEEE
        es:movsw
        es:movsw
        es:movsw
        es:movsw
        cmp word es:[di+02],01A1A    ; Confifm the data was moved
        jne FAIL_A5_1
        cmp word es:[di+04],02B2B
        jne FAIL_A5_1
        cmp word es:[di+06],03C3C
        jne FAIL_A5_1
        cmp word es:[di+08],04D4D
        jne FAIL_A5_1
        cmp di,0C010            ; Check DI was decremented
        jne FAIL_A5_1
        cmp si,0C000            ; Check SI was decremented
        jne FAIL_A5_1
        jmp TEST_A5_2


FAIL_A5_1:
        mov dx,00035    ; Print a 5
        mov ax,00202
        int 021



TEST_A5_2:      ; Test REP instead of single MOVSW's
        mov bx,0C000
        mov ax,0C002    ; Set the pointers
        mov si,ax
        mov ax,0C012
        mov di,ax
        cld             ; Clear direction to incrementing
        mov word ds:[bx+000],05AA5
        mov word ds:[bx+002],01122
        mov word ds:[bx+004],03344
        mov word ds:[bx+006],05566
        mov word ds:[bx+008],07788
        mov word ds:[bx+00A],0A55A
        mov cx,0004
        rep  movsw
        cmp word es:[di-08],01122    ; Confifm the data was moved
        jne FAIL_A5_2
        cmp word es:[di-06],03344
        jne FAIL_A5_2
        cmp word es:[di-04],05566
        jne FAIL_A5_2
        cmp word es:[di-02],07788
        jne FAIL_A5_2
        cmp di,0C01A            ; Check DI was incremented
        jne FAIL_A5_2
        cmp si,0C00A            ; Check SI was incremented
        jne FAIL_A5_2
        jmp TEST_A6_0


FAIL_A5_2:
        mov dx,00035    ; Print a 5
        mov ax,00202
        int 021



; 0xA6 - CMPSB
; ############################################################

TEST_A6_0:      ; Direction set to 0

        mov ax,es       ; Set ES apart from DS
        add ax,020
        mov es,ax

        cld             ; Clear direction to incrementing
        mov si,0C000    ; Set the pointers
        mov di,0C000

        mov word ds:[si+000],03412      ; Fill DS Memory
        mov word ds:[si+002],06666
        mov word ds:[si+004],0AB89
        mov word ds:[si+006],0EFCD
        mov word ds:[si+008],0EADE
        mov word ds:[si+00A],0EFBE

        mov word es:[di+000],03412      ; Fill ES Memory
        mov word es:[di+002],07856
        mov word es:[di+004],0AB89
        mov word es:[di+006],0EFCD
        mov word es:[di+008],0EADE
        mov word es:[di+00A],0EFBE

        cmpsb           ; Data should match
        jne FAIL_A6_0
        js  FAIL_A6_0   ; Should not have Sign flag asserted
        cmpsb           ; Data should match
        jne FAIL_A6_0
        cmpsb           ; Data should NOT match
        je FAIL_A6_0
        cmpsb           ; Data should NOT match
        je FAIL_A6_0
        cmpsb           ; Data should match
        jne FAIL_A6_0
        cmpsb           ; Data should match
        jne FAIL_A6_0

        cmp di,0C006            ; Check DI was incremented
        jne FAIL_A6_0
        cmp si,0C006            ; Check SI was incremented
        jne FAIL_A6_0

        jmp TEST_A6_1


FAIL_A6_0:
        mov dx,00036    ; Print a 6
        mov ax,00202
        int 021


TEST_A6_1:      ; Direction set to 1

        std             ; Set direction for decrementing
        mov si,0C005    ; Reset the pointers
        mov di,0C005

        mov ax,ds       ; Increment the DS so it no longer points to data
        mov ss,ax
        inc ax
        mov ds,ax

        ss:cmpsb           ; Data should match
        jne FAIL_A6_1
        ss:cmpsb           ; Data should match
        jne FAIL_A6_1
        ss:cmpsb           ; Data should NOT match
        je FAIL_A6_1
        ss:cmpsb           ; Data should NOT match
        je FAIL_A6_1
        ss:cmpsb           ; Data should match
        jne FAIL_A6_1
        ss:cmpsb           ; Data should match
        jne FAIL_A6_1

        cmp di,0BFFF            ; Check DI was decremented
        jne FAIL_A6_1
        cmp si,0BFFF            ; Check SI was decremented
        jne FAIL_A6_1

        jmp TEST_A6_2

FAIL_A6_1:
        mov dx,00036    ; Print a 6
        mov ax,00202
        int 021


TEST_A6_2:      ; Direction set to 0

        mov ax,es       ; Set ES apart from DS
        add ax,020
        mov es,ax

        cld             ; Clear direction to incrementing
        mov si,0C000    ; Set the pointers
        mov di,0C000

        mov word ds:[si+000],03412      ; Fill DS Memory
        mov word ds:[si+002],07856
        mov word ds:[si+004],0AB89
        mov word ds:[si+006],0EFCD
        mov word ds:[si+008],01111
        mov word ds:[si+00A],0EFBE

        mov word es:[di+000],03412      ; Fill ES Memory
        mov word es:[di+002],07856
        mov word es:[di+004],0AB89
        mov word es:[di+006],0EFCD
        mov word es:[di+008],0EADE
        mov word es:[di+00A],0EFBE

        mov cl,0C       ; Scan up to 12 times
        repz cmpsb

        cmp di,0C009            ; Check where pointer left off
        jne FAIL_A6_2
        cmp si,0C009
        jne FAIL_A6_2

        jmp TEST_A6_3


FAIL_A6_2:
        mov dx,00036    ; Print a 6
        mov ax,00202
        int 021

TEST_A6_3:      ; Direction set to 1

        mov ax,ds       ; Set ES apart from DS
        add ax,020
        mov es,ax

        std             ; Set direction for decrementing
        mov si,0C000    ; Set the pointers
        mov di,0C000

        mov word ds:[si+000],00000      ; Fill DS Memory
        mov word ds:[si+002],00000
        mov word ds:[si+004],00000
        mov word ds:[si+006],00000
        mov word ds:[si+008],00000
        mov word ds:[si+00A],00000

        mov word es:[di+000],01111      ; Fill ES Memory
        mov word es:[di+002],01100
        mov word es:[di+004],01111
        mov word es:[di+006],01111
        mov word es:[di+008],01111
        mov word es:[di+00A],01111

        mov si,0C008    ; Set the pointers
        mov di,0C008
        mov cl,0C       ; Scan up to 12 times
        repnz cmpsb

        cmp di,0C001            ; Check where pointer left off
        jne FAIL_A6_3
        cmp si,0C001
        jne FAIL_A6_3

        jmp TEST_A7_0


FAIL_A6_3:
        mov dx,00036    ; Print a 6
        mov ax,00202
        int 021



; 0xA7 - CMPSW
; ############################################################

TEST_A7_0:      ; Direction set to 0

        mov ax,es       ; Set ES apart from DS
        add ax,020
        mov es,ax

        cld             ; Clear direction to incrementing
        mov si,0C000    ; Set the pointers
        mov di,0C000

        mov word ds:[si+000],03412      ; Fill DS Memory
        mov word ds:[si+002],06666
        mov word ds:[si+004],0AB89
        mov word ds:[si+006],0EFCD
        mov word ds:[si+008],0EADE
        mov word ds:[si+00A],0EFBE

        mov word es:[di+000],03412      ; Fill ES Memory
        mov word es:[di+002],07856
        mov word es:[di+004],0AB89
        mov word es:[di+006],0EFCD
        mov word es:[di+008],0EADE
        mov word es:[di+00A],0EFBE

        cmpsw           ; Data should match
        jne FAIL_A7_0
        js  FAIL_A7_0   ; Should not have Sign flag asserted
        cmpsw           ; Data should NOT match
        je FAIL_A7_0
        cmpsw           ; Data should match
        jne FAIL_A7_0
        lock cmpsw           ; Data should match
        jne FAIL_A7_0
        cmpsw           ; Data should match
        jne FAIL_A7_0
        cmpsw           ; Data should match
        jne FAIL_A7_0

        cmp di,0C00C            ; Check DI was incremented
        jne FAIL_A7_0
        cmp si,0C00C            ; Check SI was incremented
        jne FAIL_A7_0

        jmp TEST_A7_1


FAIL_A7_0:
        mov dx,00037    ; Print a 7
        mov ax,00202
        int 021


TEST_A7_1:      ; Direction set to 1

        std             ; Set direction for decrementing
        mov si,0C00A    ; Reset the pointers
        mov di,0C00A

        mov ax,ds       ; Increment the DS so it no longer points to data
        mov ss,ax
        inc ax
        mov ds,ax

        ss:cmpsw           ; Data should match
        jne FAIL_A7_1
        ss:cmpsw           ; Data should match
        jne FAIL_A7_1
        ss:cmpsw           ; Data should match
        jne FAIL_A7_1
        ss:cmpsw           ; Data should match
        jne FAIL_A7_1
        ss:cmpsw           ; Data should NOT match
        je FAIL_A7_1
        ss:cmpsw           ; Data should match
        jne FAIL_A7_1

        cmp di,0BFFE            ; Check DI was decremented
        jne FAIL_A7_1
        cmp si,0BFFE            ; Check SI was decremented
        jne FAIL_A7_1

        jmp TEST_A7_2

FAIL_A7_1:
        mov dx,00037    ; Print a 7
        mov ax,00202
        int 021


TEST_A7_2:      ; Direction set to 0

        mov ax,es       ; Set ES apart from DS
        add ax,020
        mov es,ax

        cld             ; Clear direction to incrementing
        mov si,0C000    ; Set the pointers
        mov di,0C000

        mov word ds:[si+000],03412      ; Fill DS Memory
        mov word ds:[si+002],07856
        mov word ds:[si+004],0AB89
        mov word ds:[si+006],0EFCD
        mov word ds:[si+008],01111
        mov word ds:[si+00A],0EFBE

        mov word es:[di+000],03412      ; Fill ES Memory
        mov word es:[di+002],07856
        mov word es:[di+004],0AB89
        mov word es:[di+006],0EFCD
        mov word es:[di+008],0EADE
        mov word es:[di+00A],0EFBE

        mov cl,06       ; Scan up to 6 times
        repz cmpsw

        cmp di,0C00A            ; Check where pointer left off
        jne FAIL_A7_2
        cmp si,0C00A
        jne FAIL_A7_2

        jmp TEST_A7_3


FAIL_A7_2:
        mov dx,00037    ; Print a 7
        mov ax,00202
        int 021

TEST_A7_3:      ; Direction set to 1

        mov ax,ds       ; Set ES apart from DS
        add ax,020
        mov es,ax

        std             ; Set direction for decrementing
        mov si,0C000    ; Set the pointers
        mov di,0C000

        mov word ds:[si+000],00000      ; Fill DS Memory
        mov word ds:[si+002],00000
        mov word ds:[si+004],00000
        mov word ds:[si+006],00000
        mov word ds:[si+008],00000
        mov word ds:[si+00A],00000

        mov word es:[di+000],01111      ; Fill ES Memory
        mov word es:[di+002],00000
        mov word es:[di+004],01111
        mov word es:[di+006],01111
        mov word es:[di+008],01111
        mov word es:[di+00A],01111

        mov si,0C00A    ; Set the pointers
        mov di,0C00A
        mov cl,06       ; Scan up to 6 times
        repnz cmpsw

        cmp di,0C000            ; Check where pointer left off
        jne FAIL_A7_3
        cmp si,0C000
        jne FAIL_A7_3

        jmp TEST_A8_0


FAIL_A7_3:
        mov dx,00037    ; Print a 7
        mov ax,00202
        int 021

                   
                   
; 0xA8 - TEST AL,IMM8
; ############################################################

TEST_A8_0:              ; TEST MEM8,REG8 - Test flags

        mov ax,01234
        test al,022     ; Overflow should NEVER be set
        jno PASS_A8_0   ; If not set, then we passed
        jmp FAIL_A8_0   ; If set then we fail

PASS_A8_0:
        mov ax,00080
        test al,0FF     ; sign should be set
        jns FAIL_A8_0   ; If not set, then fail

        mov ax,0007F
        test al,0FF     ; sign should NOT be set
        js  FAIL_A8_0   ; If set then we fail

        mov ax,0005A
        test al,0A5    ; zero should be set
        jne FAIL_A8_0   ; If not set then we fail
        jmp PASS_A8_2

FAIL_A8_0:
        mov dx,00038    ; Print a 8
        mov ax,00202
        int 021
        jmp TEST_A9_0

PASS_A8_2:
        mov ax,00001
        test al,001     ; zero should NOT be set
        je  FAIL_A8_0   ; If set then we fail

        mov ax,00003
        test al,003     ; parity should be set
        jnp FAIL_A8_0   ; If not set then we fail

        mov ax,00001
        test al,001     ; parity should NOT be set
        jp  FAIL_A8_0   ; If set then we fail

        mov ax,01234
        test al,066     ; carry should NEVER be set
        jc  FAIL_A8_0   ; If set then we fail


                   
; 0xA9 - TEST AX,IMM16
; ############################################################

TEST_A9_0:              ; TEST MEM8,REG8 - Test flags

        mov ax,01234
        test ax,00022     ; Overflow should NEVER be set
        jno PASS_A9_0   ; If not set, then we passed
        jmp FAIL_A9_0   ; If set then we fail

PASS_A9_0:
        mov ax,08000
        test ax,0FFFF     ; sign should be set
        jns FAIL_A9_0   ; If not set, then fail

        mov ax,0FF7F
        test ax,000FF     ; sign should NOT be set
        js  FAIL_A9_0   ; If set then we fail

        mov ax,0225A
        test ax,044A5    ; zero should be set
        jne FAIL_A9_0   ; If not set then we fail
        jmp PASS_A9_2

FAIL_A9_0:
        mov dx,00039    ; Print a 9
        mov ax,00202
        int 021
        jmp TEST_AA_0

PASS_A9_2:
        mov ax,01001
        test ax,01001     ; zero should NOT be set
        je  FAIL_A9_0   ; If set then we fail

        mov ax,00003
        test ax,00003     ; parity should be set
        jnp FAIL_A9_0   ; If not set then we fail

        mov ax,00001
        test ax,00001     ; parity should NOT be set
        jp  FAIL_A9_0   ; If set then we fail

        mov ax,01234
        test ax,00066     ; carry should NEVER be set
        jc  FAIL_A9_0   ; If set then we fail

                   
; 0xAA - STOSB
; ############################################################

TEST_AA_0:

        mov ax,es       ; Set ES apart from DS
        add ax,020
        mov es,ax
        add ax,020
        mov ss,ax

        cld             ; Clear direction to incrementing
        mov si,0C000    ; Set the pointers
        mov di,0C000

        mov word es:[di+000],00000      ; Fill ES Memory
        mov word es:[di+002],00000
        mov word es:[di+004],00000
        mov word es:[di+006],00000
        mov word es:[di+008],00000
        mov word es:[di+00A],00000
        mov word es:[di+00C],00000
        mov word es:[di+00E],00000

        mov al,011
        lock stosb      ; Test LOCK
        mov al,022
        stosb
        mov al,033
        stosb
        mov al,044
        ss: stosb       ; Segment override should be ignored

        cmp di,0C004            ; Check where pointer left off
        jne FAIL_AA_0
        cmp si,0C000
        jne FAIL_AA_0

        mov di,0C000            ; Reset DI

        cmp byte es:[di+000],011        ; Data should match
        jne FAIL_AA_0
        cmp byte es:[di+001],022        ; Data should match
        jne FAIL_AA_0
        cmp byte es:[di+002],033        ; Data should match
        jne FAIL_AA_0
        cmp byte es:[di+003],044        ; Data should match
        jne FAIL_AA_0
        cmp byte es:[di+004],000        ; Data should match
        jne FAIL_AA_0

        jmp TEST_AA_1


FAIL_AA_0:
        mov dx,00041    ; Print a A
        mov ax,00202
        int 021

TEST_AA_1:

        std             ; Set direction to Decrementing
        mov si,0C000    ; Set the pointers
        mov di,0C000

        mov word es:[di+000],00000      ; Fill ES Memory
        mov word es:[di+002],00000
        mov word es:[di+004],00000
        mov word es:[di+006],00000
        mov word es:[di+008],00000
        mov word es:[di+00A],00000
        mov word es:[di+00C],00000
        mov word es:[di+00E],00000

        mov si,0C003    ; Set the pointers
        mov di,0C003
        mov al,044
        lock stosb      ; Test LOCK
        mov al,033
        stosb
        mov al,022
        stosb
        mov al,011
        ss: stosb       ; Segment override should be ignored

        cmp di,0BFFF            ; Check where pointer left off
        jne FAIL_AA_1
        cmp si,0C003
        jne FAIL_AA_1

        mov di,0C000            ; Reset DI

        cmp byte es:[di+000],011        ; Data should match
        jne FAIL_AA_1
        cmp byte es:[di+001],022        ; Data should match
        jne FAIL_AA_1
        cmp byte es:[di+002],033        ; Data should match
        jne FAIL_AA_1
        cmp byte es:[di+003],044        ; Data should match
        jne FAIL_AA_1
        cmp byte es:[di+004],000        ; Data should match
        jne FAIL_AA_1

        jmp TEST_AA_2


FAIL_AA_1:
        mov dx,00041   ; Print a A
        mov ax,00202
        int 021

TEST_AA_2:

        cld             ; Clear direction to incrementing
        mov si,0C000    ; Set the pointers
        mov di,0C000

        mov word es:[di+000],00000      ; Fill ES Memory
        mov word es:[di+002],00000
        mov word es:[di+004],00000
        mov word es:[di+006],00000
        mov word es:[di+008],00000
        mov word es:[di+00A],00000
        mov word es:[di+00C],00000
        mov word es:[di+00E],00000

        mov al,011
        mov cx,004
        rep stosb

        cmp di,0C004            ; Check where pointer left off
        jne FAIL_AA_2
        cmp si,0C000
        jne FAIL_AA_2

        mov di,0C000            ; Reset DI

        cmp byte es:[di+000],011        ; Data should match
        jne FAIL_AA_2
        cmp byte es:[di+001],011        ; Data should match
        jne FAIL_AA_2
        cmp byte es:[di+002],011        ; Data should match
        jne FAIL_AA_2
        cmp byte es:[di+003],011        ; Data should match
        jne FAIL_AA_2
        cmp byte es:[di+004],000        ; Data should match
        jne FAIL_AA_2

        jmp TEST_AA_3


FAIL_AA_2:
        mov dx,00041    ; Print a A
        mov ax,00202
        int 021

TEST_AA_3:

        std             ; Set direction to Decrementing
        mov si,0C000    ; Set the pointers
        mov di,0C000

        mov word es:[di+000],00000      ; Fill ES Memory
        mov word es:[di+002],00000
        mov word es:[di+004],00000
        mov word es:[di+006],00000
        mov word es:[di+008],00000
        mov word es:[di+00A],00000
        mov word es:[di+00C],00000
        mov word es:[di+00E],00000

        mov si,0C003    ; Set the pointers
        mov di,0C003
        mov al,011
        mov cx,004
        rep stosb

        cmp di,0BFFF            ; Check where pointer left off
        jne FAIL_AA_3
        cmp si,0C003
        jne FAIL_AA_3

        mov di,0C000            ; Reset DI

        cmp byte es:[di+000],011        ; Data should match
        jne FAIL_AA_3
        cmp byte es:[di+001],011        ; Data should match
        jne FAIL_AA_3
        cmp byte es:[di+002],011        ; Data should match
        jne FAIL_AA_3
        cmp byte es:[di+003],011        ; Data should match
        jne FAIL_AA_3
        cmp byte es:[di+004],000        ; Data should match
        jne FAIL_AA_3

        jmp TEST_AB_0


FAIL_AA_3:
        mov dx,00041    ; Print a A
        mov ax,00202
        int 021

                   
; 0xAB - STOSW
; ############################################################

TEST_AB_0:

        mov ax,es       ; Set ES apart from DS
        add ax,020
        mov es,ax
        add ax,020
        mov ss,ax

        cld             ; Clear direction to incrementing
        mov si,0C000    ; Set the pointers
        mov di,0C000

        mov word es:[di+000],00000      ; Fill ES Memory
        mov word es:[di+002],00000
        mov word es:[di+004],00000
        mov word es:[di+006],00000
        mov word es:[di+008],00000
        mov word es:[di+00A],00000
        mov word es:[di+00C],00000
        mov word es:[di+00E],00000

        mov ax,01111
        lock stosw      ; Test LOCK
        mov ax,02222
        stosw
        mov ax,03333
        stosw
        mov ax,04444
        ss: stosw       ; Segment override should be ignored

        cmp di,0C008            ; Check where pointer left off
        jne FAIL_AB_0
        cmp si,0C000
        jne FAIL_AB_0

        mov di,0C000            ; Reset DI

        cmp word es:[di+000],01111        ; Data should match
        jne FAIL_AB_0
        cmp word es:[di+002],02222        ; Data should match
        jne FAIL_AB_0
        cmp word es:[di+004],03333        ; Data should match
        jne FAIL_AB_0
        cmp word es:[di+006],04444        ; Data should match
        jne FAIL_AB_0
        cmp word es:[di+008],00000        ; Data should match
        jne FAIL_AB_0

        jmp TEST_AB_1


FAIL_AB_0:
        mov dx,00042    ; Print a B
        mov ax,00202
        int 021

TEST_AB_1:

        std             ; Set direction to Decrementing
        mov si,0C000    ; Set the pointers
        mov di,0C000

        mov word es:[di+000],00000      ; Fill ES Memory
        mov word es:[di+002],00000
        mov word es:[di+004],00000
        mov word es:[di+006],00000
        mov word es:[di+008],00000
        mov word es:[di+00A],00000
        mov word es:[di+00C],00000
        mov word es:[di+00E],00000

        mov si,0C006    ; Set the pointers
        mov di,0C006
        mov ax,04444
        lock stosw      ; Test LOCK
        mov ax,03333
        stosw
        mov ax,02222
        stosw
        mov ax,01111
        ss: stosw       ; Segment override should be ignored

        cmp di,0BFFE            ; Check where pointer left off
        jne FAIL_AB_1
        cmp si,0C006
        jne FAIL_AB_1

        mov di,0C000            ; Reset DI

        cmp word es:[di+000],01111        ; Data should match
        jne FAIL_AB_1
        cmp word es:[di+002],02222        ; Data should match
        jne FAIL_AB_1
        cmp word es:[di+004],03333        ; Data should match
        jne FAIL_AB_1
        cmp word es:[di+006],04444        ; Data should match
        jne FAIL_AB_1
        cmp word es:[di+008],00000        ; Data should match
        jne FAIL_AB_1

        jmp TEST_AB_2


FAIL_AB_1:
        mov dx,00042    ; Print a B
        mov ax,00202
        int 021

TEST_AB_2:

        cld             ; Clear direction to incrementing
        mov si,0C000    ; Set the pointers
        mov di,0C000

        mov word es:[di+000],00000      ; Fill ES Memory
        mov word es:[di+002],00000
        mov word es:[di+004],00000
        mov word es:[di+006],00000
        mov word es:[di+008],00000
        mov word es:[di+00A],00000
        mov word es:[di+00C],00000
        mov word es:[di+00E],00000

        mov ax,01111
        mov cx,004
        rep stosw

        cmp di,0C008            ; Check where pointer left off
        jne FAIL_AB_2
        cmp si,0C000
        jne FAIL_AB_2

        mov di,0C000            ; Reset DI

        cmp word es:[di+000],01111        ; Data should match
        jne FAIL_AB_2
        cmp word es:[di+002],01111        ; Data should match
        jne FAIL_AB_2
        cmp word es:[di+004],01111        ; Data should match
        jne FAIL_AB_2
        cmp word es:[di+006],01111        ; Data should match
        jne FAIL_AB_2
        cmp word es:[di+008],00000        ; Data should match
        jne FAIL_AB_2

        jmp TEST_AB_3


FAIL_AB_2:
        mov dx,00042    ; Print a B
        mov ax,00202
        int 021

TEST_AB_3:

        std             ; Set direction to Decrementing
        mov si,0C000    ; Set the pointers
        mov di,0C000

        mov word es:[di+000],00000      ; Fill ES Memory
        mov word es:[di+002],00000
        mov word es:[di+004],00000
        mov word es:[di+006],00000
        mov word es:[di+008],00000
        mov word es:[di+00A],00000
        mov word es:[di+00C],00000
        mov word es:[di+00E],00000

        mov si,0C006    ; Set the pointers
        mov di,0C006
        mov ax,01111
        mov cx,004
        rep stosw

        cmp di,0BFFE            ; Check where pointer left off
        jne FAIL_AB_3
        cmp si,0C006
        jne FAIL_AB_3

        mov di,0C000            ; Reset DI

        cmp word es:[di+000],01111        ; Data should match
        jne FAIL_AB_3
        cmp word es:[di+002],01111        ; Data should match
        jne FAIL_AB_3
        cmp word es:[di+004],01111        ; Data should match
        jne FAIL_AB_3
        cmp word es:[di+006],01111        ; Data should match
        jne FAIL_AB_3
        cmp word es:[di+008],0000        ; Data should match
        jne FAIL_AB_3

        jmp TEST_AC_0


FAIL_AB_3:
        mov dx,00042    ; Print a B
        mov ax,00202
        int 021

                   
; 0xAC - LODSB
; ############################################################

TEST_AC_0:

        mov ax,es       ; Set ES apart from DS
        add ax,020
        mov es,ax
        add ax,020
        mov ds,ax

        cld             ; Clear direction to incrementing
        mov si,0C000    ; Set the pointers
        mov di,0C000

        mov word ds:[si+000],01111      ; Fill Memory
        mov word ds:[si+002],02222
        mov word ds:[si+004],03333
        mov word ds:[si+006],04444
        mov word ds:[si+008],05555
        mov word ds:[si+00A],06666
        mov word ds:[si+00C],07777
        mov word ds:[si+00E],08888

        lock lodsb      ; Test LOCK
        lodsb
        lodsb
        lodsb

        cmp al,022              ; Check for data match
        jne FAIL_AC_0

        cmp di,0C000            ; Check where pointer left off
        jne FAIL_AC_0
        cmp si,0C004
        jne FAIL_AC_0

        jmp TEST_AC_1


FAIL_AC_0:
        mov dx,00043    ; Print a C
        mov ax,00202
        int 021

TEST_AC_1:

        std             ; Set direction to Decrementing

        mov si,0C003    ; Set the pointers
        mov di,0C003

        lock lodsb      ; Test LOCK
        lodsb
        lodsb
        lodsb

        cmp al,011              ; Check for data match
        jne FAIL_AC_1

        cmp di,0C003            ; Check where pointer left off
        jne FAIL_AC_1
        cmp si,0BFFF
        jne FAIL_AC_1

        mov si,0C007            ; Set the pointers
        es: lodsb               ; Segment override where data wont match
        cmp al,044              ; Check for data match
        je FAIL_AC_1

        jmp TEST_AC_2


FAIL_AC_1:
        mov dx,00043   ; Print a C
        mov ax,00202
        int 021

TEST_AC_2:

        cld             ; Clear direction to incrementing
        mov si,0C000    ; Set the pointers
        mov di,0C000

        mov cl,9
        rep lodsb      ; Test Repeat

        cmp al,055              ; Check for data match
        jne FAIL_AC_2

        cmp di,0C000            ; Check where pointer left off
        jne FAIL_AC_2
        cmp si,0C009
        jne FAIL_AC_2

        jmp TEST_AD_0


FAIL_AC_2:
        mov dx,00043    ; Print a C
        mov ax,00202
        int 021
                   
                   
; 0xAD - LODSW
; ############################################################

TEST_AD_0:

        mov ax,es       ; Set ES apart from DS
        add ax,020
        mov es,ax
        add ax,020
        mov ds,ax

        cld             ; Clear direction to incrementing
        mov si,0C000    ; Set the pointers
        mov di,0C000

        mov word ds:[si+000],01111      ; Fill Memory
        mov word ds:[si+002],02222
        mov word ds:[si+004],03333
        mov word ds:[si+006],04444
        mov word ds:[si+008],05555
        mov word ds:[si+00A],06666
        mov word ds:[si+00C],07777
        mov word ds:[si+00E],08888

        lock lodsw      ; Test LOCK
        lodsw
        lodsw
        lodsw

        cmp ax,04444              ; Check for data match
        jne FAIL_AD_0

        cmp di,0C000            ; Check where pointer left off
        jne FAIL_AD_0
        cmp si,0C008
        jne FAIL_AD_0

        jmp TEST_AD_1


FAIL_AD_0:
        mov dx,00044    ; Print a D
        mov ax,00202
        int 021

TEST_AD_1:

        std             ; Set direction to Decrementing

        mov si,0C008    ; Set the pointers
        mov di,0C008

        lock lodsw      ; Test LOCK
        lodsw
        lodsw
        lodsw

        cmp ax,02222              ; Check for data match
        jne FAIL_AD_1

        cmp di,0C008            ; Check where pointer left off
        jne FAIL_AD_1
        cmp si,0C000
        jne FAIL_AD_1

        mov si,0C008            ; Set the pointers
        es: lodsw               ; Segment override where data wont match
        cmp al,044              ; Check for data match
        je FAIL_AD_1

        jmp TEST_AD_2


FAIL_AD_1:
        mov dx,00044   ; Print a D
        mov ax,00202
        int 021

TEST_AD_2:

        cld             ; Clear direction to incrementing
        mov si,0C000    ; Set the pointers
        mov di,0C000

        mov cl,04
        rep lodsw      ; Test Repeat

        cmp ax,04444              ; Check for data match
        jne FAIL_AD_2

        cmp di,0C000            ; Check where pointer left off
        jne FAIL_AD_2
        cmp si,0C008
        jne FAIL_AD_2


        jmp TEST_AE_0


FAIL_AD_2:
        mov dx,00044    ; Print a D
        mov ax,00202
        int 021
                   


                   
; 0xAE - SCASB
; ############################################################

TEST_AE_0:

        mov ax,es       ; Set ES apart from DS
        add ax,020
        mov es,ax
        add ax,020
        mov ds,ax

        cld             ; Clear direction to incrementing
        mov si,0C000    ; Set the pointers
        mov di,0C000

        mov word es:[di+000],01122      ; Fill Memory
        mov word es:[di+002],03344
        mov word es:[di+004],05566
        mov word es:[di+006],07788
        mov word es:[di+008],099AA
        mov word es:[di+00A],0BBCC
        mov word es:[di+00C],0DDEE
        mov word es:[di+00E],0FF5A

        mov al,066
        lock scasb      ; Test LOCK
        je FAIL_AE_0    ; Should not have data match yet
        lock scasb
        je FAIL_AE_0    ; Should not have data match yet
        lock scasb
        je FAIL_AE_0    ; Should not have data match yet
        lock scasb
        je FAIL_AE_0    ; Should not have data match yet
        lock scasb
        jne FAIL_AE_0   ; Data should match here


        cmp di,0C005            ; Check where pointer left off
        jne FAIL_AE_0
        cmp si,0C000
        jne FAIL_AE_0

        jmp TEST_AE_1


FAIL_AE_0:
        mov dx,00045    ; Print a E
        mov ax,00202
        int 021

TEST_AE_1:

        std             ; Set direction to Decrementing

        mov si,0C00A    ; Set the pointers
        mov di,0C00A


        mov al,088
        lock scasb      ; Test LOCK
        je FAIL_AE_1    ; Should not have data match yet
        ss: scasb       ; Segment Override should be ignored
        je FAIL_AE_1    ; Should not have data match yet
        lock scasb
        je FAIL_AE_1    ; Should not have data match yet
        lock scasb
        je FAIL_AE_1    ; Should not have data match yet
        lock scasb
        jne FAIL_AE_1   ; Data should match here


        cmp di,0C005            ; Check where pointer left off
        jne FAIL_AE_1
        cmp si,0C00A
        jne FAIL_AE_1


        mov si,0C007            ; Set the pointers
        es: lodsb               ; Segment override where data wont match
        cmp al,044              ; Check for data match
        je FAIL_AE_1

        jmp TEST_AE_2


FAIL_AE_1:
        mov dx,00045   ; Print a E
        mov ax,00202
        int 021

TEST_AE_2:

        cld             ; Clear direction to incrementing
        mov si,0C000    ; Set the pointers
        mov di,0C000

        mov cl,00F
        mov al,077
        repne scasb      ; Test REPZ - Scan for a data match

        cmp di,0C008            ; Check where pointer left off
        jne FAIL_AE_2
        cmp si,0C000
        jne FAIL_AE_2

        mov si,0C000    ; Reset the pointers
        mov di,0C000

        mov word es:[di+000],04444      ; Fill Memory
        mov word es:[di+002],04444
        mov word es:[di+004],04444
        mov word es:[di+006],04444
        mov word es:[di+008],04544
        mov word es:[di+00A],04444
        mov word es:[di+00C],04444
        mov word es:[di+00E],04444

        mov cl,00F
        mov al,044
        repe scasb      ; Test REPNZ - Scan for a data NOT match

        cmp di,0C00A            ; Check where pointer left off
        jne FAIL_AE_2
        cmp si,0C000
        jne FAIL_AE_2

        jmp TEST_AF_0


FAIL_AE_2:
        mov dx,00045    ; Print a E
        mov ax,00202
        int 021
                   

                   
; 0xAF - SCASW
; ############################################################

TEST_AF_0:

        mov ax,es       ; Set ES apart from DS
        add ax,020
        mov es,ax
        add ax,020
        mov ds,ax

        cld             ; Clear direction to incrementing
        mov si,0C000    ; Set the pointers
        mov di,0C000

        mov word es:[di+000],01111      ; Fill Memory
        mov word es:[di+002],02222
        mov word es:[di+004],03333
        mov word es:[di+006],04444
        mov word es:[di+008],05555
        mov word es:[di+00A],06666
        mov word es:[di+00C],07777
        mov word es:[di+00E],08888

        mov ax,05555
        lock scasw      ; Test LOCK
        je FAIL_AF_0    ; Should not have data match yet
        lock scasw
        je FAIL_AF_0    ; Should not have data match yet
        lock scasw
        je FAIL_AF_0    ; Should not have data match yet
        lock scasw
        je FAIL_AF_0    ; Should not have data match yet
        lock scasw
        jne FAIL_AF_0   ; Data should match here


        cmp di,0C00A            ; Check where pointer left off
        jne FAIL_AF_0
        cmp si,0C000
        jne FAIL_AF_0

        jmp TEST_AF_1


FAIL_AF_0:
        mov dx,00046    ; Print a F
        mov ax,00202
        int 021

TEST_AF_1:

        std             ; Set direction to Decrementing

        mov si,0C00A    ; Set the pointers
        mov di,0C00A


        mov ax,03333
        lock scasw      ; Test LOCK
        je FAIL_AF_1    ; Should not have data match yet
        ss: scasw       ; Segment Override should be ignored
        je FAIL_AF_1    ; Should not have data match yet
        lock scasw
        je FAIL_AF_1    ; Should not have data match yet
        lock scasw
        jne FAIL_AF_1   ; Data should match here


        cmp di,0C002            ; Check where pointer left off
        jne FAIL_AF_1
        cmp si,0C00A
        jne FAIL_AF_1

        jmp TEST_AF_2


FAIL_AF_1:
        mov dx,00046   ; Print a F
        mov ax,00202
        int 021

TEST_AF_2:

        cld             ; Clear direction to incrementing
        mov si,0C000    ; Set the pointers
        mov di,0C000

        mov cl,00F
        mov ax,07777
        repne scasw      ; Test REPZ - Scan for a data match

        cmp di,0C00E            ; Check where pointer left off
        jne FAIL_AF_2
        cmp si,0C000
        jne FAIL_AF_2

        mov si,0C000    ; Reset the pointers
        mov di,0C000

        mov word es:[di+000],04444      ; Fill Memory
        mov word es:[di+002],04444
        mov word es:[di+004],04444
        mov word es:[di+006],04444
        mov word es:[di+008],07777
        mov word es:[di+00A],04444
        mov word es:[di+00C],04444
        mov word es:[di+00E],04444

        mov cl,00F
        mov ax,04444
        repe scasw      ; Test REPNZ - Scan for a data NOT match

        cmp di,0C00A            ; Check where pointer left off
        jne FAIL_AF_2
        cmp si,0C000
        jne FAIL_AF_2

        jmp Z_END


FAIL_AF_2:
        mov dx,00046    ; Print a F
        mov ax,00202
        int 021
                   
                   
; xxxxxxxxxxxxxxxxxxxxxxx
; End
; xxxxxxxxxxxxxxxxxxxxxxx
Z_END:
        mov ax,00000    ; DOS Commtest=Exit
        int 021



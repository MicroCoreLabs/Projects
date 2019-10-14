; Tests for opcode range 0x84-0x8F
; ---------------------------------

; Opcodes 0x88 and 0x89 will be tested by hand
; because assembler always uses 0x8A and 0x8B.

                   
; 0x84 - TEST REG8/MEM8,REG8
; ############################################################

        mov dx,es       ; Increment ES so it is not the same as DS
        inc dx
        mov es,dx

TEST_84_0:              ; TEST MEM8,REG8 - Test flags

        mov byte [00050],0FF
        mov dx,00000
        test byte [00050],dl  ; Overflow should NEVER be set
        jno PASS_84_0   ; If not set, then we passed
        jmp FAIL_84_0   ; If set then we fail

PASS_84_0:
        mov byte [00050],080
        mov dx,00080
        test byte [00050],dl  ; sign should be set
        jns FAIL_84_0   ; If not set, then fail

        mov byte [00050],0FF
        mov dx,0007F
        test byte [00050],dl  ; sign should NOT be set
        js  FAIL_84_0   ; If set then we fail

        mov byte [00050],000
        mov dx,000FF
        test byte [00050],dl  ; zero should be set
        jne FAIL_84_0   ; If not set then we fail
        jmp PASS_84_2

FAIL_84_0:
        mov dx,00034    ; Print a 4
        mov ax,00202
        int 021
        jmp TEST_84_1

PASS_84_2:
        mov byte [00050],0FF
        mov dx,00001
        test byte [00050],dl  ; zero should NOT be set
        je  FAIL_84_0   ; If set then we fail

        mov byte [00050],003
        mov dx,00003
        test byte [00050],dl  ; parity should be set
        jnp FAIL_84_0   ; If not set then we fail

        mov byte [00050],003
        mov dx,00001
        test byte [00050],dl  ; parity should NOT be set
        jp  FAIL_84_0   ; If set then we fail

        mov byte [00050],012
        mov dx,00034
        test byte [00050],dl  ; carry should NEVER be set
        jc  FAIL_84_0   ; If set then we fail


TEST_84_1:              ; TEST REG8,REG8 - Test flags

        mov cl,0FF
        mov dx,00000
        test cl,dl  ; Overflow should NEVER be set
        jno PASS_84_3   ; If not set, then we passed
        jmp FAIL_84_1   ; If set then we fail

PASS_84_3:
        mov cl,080
        mov dx,00080
        test cl,dl  ; sign should be set
        jns FAIL_84_1   ; If not set, then fail

        mov cl,0FF
        mov dx,0007F
        test cl,dl  ; sign should NOT be set
        js  FAIL_84_1   ; If set then we fail

        mov cl,000
        mov dx,000FF
        test cl,dl  ; zero should be set
        jne FAIL_84_1   ; If not set then we fail
        jmp PASS_84_4

FAIL_84_1:
        mov dx,00034    ; Print a 4
        mov ax,00202
        int 021
        jmp TEST_85_0

PASS_84_4:
        mov cl,0FF
        mov dx,00001
        test cl,dl  ; zero should NOT be set
        je  FAIL_84_1   ; If set then we fail

        mov cl,003
        mov dx,00003
        test cl,dl  ; parity should be set
        jnp FAIL_84_1   ; If not set then we fail

        mov cl,003
        mov dx,00001
        test cl,dl  ; parity should NOT be set
        jp  FAIL_84_1   ; If set then we fail

        mov cl,012
        mov dx,00034
        test cl,dl  ; carry should NEVER be set
        jc  FAIL_84_1   ; If set then we fail



; 0x85 - TEST REG16/MEM16,REG16
; ############################################################

        mov dx,es       ; Increment ES so it is not the same as DS
        inc dx
        mov es,dx

TEST_85_0:              ; TEST MEM16,REG16 - Test flags

        mov word [00050],022FF
        mov dx,00000
        test word [00050],dx  ; Overflow should NEVER be set
        jno PASS_85_0   ; If not set, then we passed
        jmp FAIL_85_0   ; If set then we fail

PASS_85_0:
        mov word [00050],08000
        mov dx,08000
        test word [00050],dx  ; sign should be set
        jns FAIL_85_0   ; If not set, then fail

        mov word [00050],012FF
        mov dx,0007F
        test word [00050],dx  ; sign should NOT be set
        js  FAIL_85_0   ; If set then we fail

        mov word [00050],01111
        mov dx,04444
        test word [00050],dx  ; zero should be set
        jne FAIL_85_0   ; If not set then we fail
        jmp PASS_85_2

FAIL_85_0:
        mov dx,00035    ; Print a 5
        mov ax,00202
        int 021
        jmp TEST_85_1

PASS_85_2:
        mov word [00050],012FF
        mov dx,02001
        test word [00050],dx  ; zero should NOT be set
        je  FAIL_85_0   ; If set then we fail

        mov word [00050],01203
        mov dx,00003
        test word [00050],dx  ; parity should be set
        jnp FAIL_85_0   ; If not set then we fail

        mov word [00050],01203
        mov dx,00001
        test word [00050],dx  ; parity should NOT be set
        jp  FAIL_85_0   ; If set then we fail

        mov word [00050],01234
        mov dx,02034
        test word [00050],dx  ; carry should NEVER be set
        jc  FAIL_85_0   ; If set then we fail


TEST_85_1:              ; TEST REG16,REG16 - Test flags

        mov cx,0F12F
        mov dx,00000
        test cx,dx  ; Overflow should NEVER be set
        jno PASS_85_3   ; If not set, then we passed
        jmp FAIL_85_1   ; If set then we fail

PASS_85_3:
        mov cx,08012
        mov dx,08012
        test cx,dx  ; sign should be set
        jns FAIL_85_1   ; If not set, then fail

        mov cx,012FF
        mov dx,0027F
        test cx,dx  ; sign should NOT be set
        js  FAIL_85_1   ; If set then we fail

        mov cx,08888
        mov dx,01111
        test cx,dx  ; zero should be set
        jne FAIL_85_1   ; If not set then we fail
        jmp PASS_85_4

FAIL_85_1:
        mov dx,00035    ; Print a 5
        mov ax,00202
        int 021
        jmp TEST_86_0

PASS_85_4:
        mov cx,01234
        mov dx,01234
        test cx,dx  ; zero should NOT be set
        je  FAIL_85_1   ; If set then we fail

        mov cx,01233
        mov dx,01003
        test cx,dx  ; parity should be set
        jnp FAIL_85_1   ; If not set then we fail

        mov cx,01233
        mov dx,02001
        test cx,dx  ; parity should NOT be set
        jp  FAIL_85_1   ; If set then we fail

        mov cx,01234
        mov dx,00034
        test cx,dx  ; carry should NEVER be set
        jc  FAIL_85_1   ; If set then we fail


                   
; 0x86 - XCHG REG8, MEM8/REG8
; ############################################################

TEST_86_0:      ; XCHG REG8,REG8

        mov cl,0CC
        mov dl,0DD
        xchg cl,dl
        cmp cl,0DD
        jne FAIL_86_0
        cmp dl,0CC
        jne FAIL_86_0

TEST_86_1:      ; XCHG REG8,MEM8

        mov byte [00050],011
        mov dl,0DD
        xchg dl, byte [00050]
        cmp dl,011
        jne FAIL_86_0
        cmp byte [00050],0DD
        jne FAIL_86_0
        jmp TEST_87_0

FAIL_86_0:
        mov dx,00036    ; Print a 6
        mov ax,00202
        int 021

                   
; 0x87 - XCHG REG16, MEM16/REG16
; ############################################################

TEST_87_0:      ; XCHG REG16,REG16

        mov cx,0CCCC
        mov dx,0DDDD
        xchg cx,dx
        cmp cx,0DDDD
        jne FAIL_87_0
        cmp dx,0CCCC
        jne FAIL_87_0

TEST_87_1:      ; XCHG REG16,MEM16

        mov word es:[00050],01111
        mov dx,0DDDD
        xchg dx, word es:[00050]
        cmp dx,01111
        jne FAIL_87_0
        cmp word es:[00050],0DDDD
        jne FAIL_87_0
        jmp TEST_8A_0

FAIL_87_0:
        mov dx,00037    ; Print a 7
        mov ax,00202
        int 021

                   
; 0x8A - MOV REG8/MEM8, REG8
; ############################################################

TEST_8A_0:      ; MOV REG8,REG8

        mov cx,01234
        mov dx,0ABCD
        mov dl,cl
        cmp dl,034
        jne FAIL_8A_0

TEST_8A_1:      ; MOV MEM8,REG8

        mov byte es:[00050],078
        mov dx,0ABCD
        mov dl, byte es:[00050]
        cmp dl,078
        jne FAIL_8A_0
        jmp TEST_8B_0


FAIL_8A_0:
        mov dx,00041    ; Print a A
        mov ax,00202
        int 021

                   
; 0x8B - MOV REG8/MEM8, REG8
; ############################################################

TEST_8B_0:      ; MOV REG16,REG16

        mov cx,01234
        mov dx,0ABCD
        mov dx,cx
        cmp dx,01234
        jne FAIL_8B_0

TEST_8B_1:      ; MOV MEM16,REG16

        mov word es:[00050],05678
        mov dx,0ABCD
        mov dx, word es:[00050]
        cmp dx,05678
        jne FAIL_8B_0
        jmp TEST_8C_0


FAIL_8B_0:
        mov dx,00042    ; Print a B
        mov ax,00202
        int 021


; 0x8C - MOV REG16/MEM16, SEGREG
; ############################################################

TEST_8C_0:      ; MOV REG16,SEGREG

        mov ax,es
        mov bx,cs
        mov cx,ss
        mov dx,ds

        mov word [00050],es
        mov word [00060],cs
        mov word [00070],ss
        mov word [00080],ds

        cmp ax, word [00050]
        jne FAIL_8C_0
        cmp bx, word [00060]
        jne FAIL_8C_0
        cmp cx, word [00070]
        jne FAIL_8C_0
        cmp dx, word [00080]
        jne FAIL_8C_0
        jmp TEST_8D_0


FAIL_8C_0:
        mov dx,00043    ; Print a C
        mov ax,00202
        int 021


; 0x8D - LEA
; ############################################################

TEST_8D_0:

        mov bx,02222
        lea di,[bx+01111]
        cmp di,03333
        jne FAIL_8D_0

        mov bx,03333
        mov si,02222
        lea di,[bx+si+01111]
        cmp di,06666
        jne FAIL_8D_0
        jmp TEST_8E_0


FAIL_8D_0:
        mov dx,00044    ; Print a D
        mov ax,00202
        int 021


; 0x8E - MOV SEGREG, REG16/MEM16
; ############################################################

TEST_8E_0:


        mov ax,ds
        mov word [00050],ds
        mov ds, word [00050]
        mov cx,ds
        cmp cx,ax
        jne FAIL_8E_0

        mov bx,ds
        mov ds,bx
        mov cx,ds
        cmp cx,bx
        jne FAIL_8E_0
        jmp TEST_8F_0


FAIL_8E_0:
        mov dx,00045   ; Print a E
        mov ax,00202
        int 021


; 0x8F - MOV SEGREG, REG16/MEM16
; ############################################################

TEST_8F_0:


        mov ax,01111
        push ax
        pop word [00050]
        cmp word [00050],ax
        jne FAIL_8F_0

        jmp Z_END


FAIL_8F_0:
        mov dx,00046   ; Print a F
        mov ax,00202
        int 021

; xxxxxxxxxxxxxxxxxxxxxxx
; End
; xxxxxxxxxxxxxxxxxxxxxxx
Z_END:
        mov ax,00000    ; DOS Commtest=Exit
        int 021


; Addressing modes tests
; ----------------------
; Test all combinations of addressing modes to and from memory.
; CGA video memory space at BB000-BB1FF is used.

        ; Set all segments and pointers
        ; -----------------------------
        mov ax,0BB00    ; Set the ES
        mov es,ax
        mov di,00000    ; Zero the DI pointer

        mov ax,0B900    ; Set the DS
        mov ds,ax
        mov si,02000    ; Zero the SI pointer

        mov ax,0BA00    ; Set the SS
        mov ss,ax
        mov sp,011FE    ; Set the Stack to BB1FE
        mov bp,01000    ; Set the BP

        ; Fill BB000-BB1FF with incremening data
        ; ---------------------------------------
        mov ax,00000    ; Zero out value to write
        mov cx,00200    ; Set cx to count 512 times
        cld             ; Make sure DI increments

L1:     stosb           ; ES:DI <= AL
        inc ax          ; AX and DI will increment
        loop L1         ; Repeat FF times


        ; Read memory using each addressing mode
        ; and compare to immediate value.
        ; Then write and read back a byte to verify EA writing.

        ; MOD=00 R/M=000 -- DS:BX+SI= B900+2030+14 = BB044
ADDR_TEST1:
        mov bx , 02030
        mov si , 014
        lea ax , [bx+si]
        cmp byte [bx+si] , 044
        jne FAIL1
        cmp word [bx+si] , 04544
        jne FAIL1

        ; MOD=01 R/M=000 -- DS:BX+SI+D8= B900+2030+14+4 = BB048
        mov bx , 02030
        mov si , 014
        lea ax , [bx+si+04]
        cmp byte [bx+si+04] , 048
        jne FAIL1
        cmp word [bx+si+04] , 04948
        jne FAIL1

        ; MOD=01 R/M=000 -- DS:BX+SI-D8= B900+2030+14-3 = BB040
        mov bx , 02030
        mov si , 014
        lea ax , [bx+si-04]
        cmp byte [bx+si-04] , 040
        jne FAIL1
        cmp word [bx+si-04] , 04140
        jne FAIL1

        ; MOD=10 R/M=000 -- DS:BX+SI+D16= B900+2020+25+104 = BB149
        mov bx , 02020
        mov si , 00025
        lea ax , [bx+si+0104]
        cmp byte [bx+si+0104] , 049
        jne FAIL1
        cmp word [bx+si+0104] , 04A49
        jne FAIL1

        ; MOD=10 R/M=000 -- DS:BX+SI-D16= B900+2120+25-102 = BB043
        mov bx , 02120
        mov si , 00025
        lea ax , [bx+si-0102]
        cmp byte [bx+si-0102], 043
        jne FAIL1
        cmp word [bx+si-0102], 04443
        jne FAIL1
        jmp TEST2


FAIL1:
        mov dx,00031    ; Print a 1
        mov ax,00202
        int 021



        ; XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

        ; MOD=00 R/M=001 -- DS:BX+DI= B900+2040+04 = BB044
TEST2:  mov bx , 02040
        mov di , 004
        lea ax , [bx+di]
        cmp byte [bx+di] , 044
        jne FAIL2
        cmp word [bx+di] , 04544
        jne FAIL2

        ; MOD=01 R/M=001 -- DS:BX+DI+D8= B900+2040+04+4 = BB048
        mov bx , 02040
        mov di , 004
        lea ax , [bx+di+04]
        cmp byte [bx+di+04] , 048
        jne FAIL2
        cmp word [bx+di+04] , 04948
        jne FAIL2

        ; MOD=01 R/M=001 -- DS:BX+DI-D8= B900+2040+04-3 = BB040
        mov bx , 02040
        mov di , 004
        lea ax , [bx+di-04]
        cmp byte [bx+di-04] , 040
        jne FAIL2
        cmp word [bx+di-04] , 04140
        jne FAIL2

        ; MOD=10 R/M=001 -- DS:BX+DI+D16= B900+2010+35+104 = BB149
        mov bx , 02010
        mov di , 00035
        lea ax , [bx+di+0104]
        cmp byte [bx+di+0104] , 049
        jne FAIL2
        cmp word [bx+di+0104] , 04A49
        jne FAIL2

        ; MOD=10 R/M=001 -- DS:BX+DI-D16= B900+2110+35-102 = BB043
        mov bx , 02110
        mov di , 00035
        lea ax , [bx+di-0102]
        cmp byte [bx+di-0102], 043
        jne FAIL2
        cmp word [bx+di-0102] , 04443
        jne FAIL2
        jmp TEST3

        ; XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX


FAIL2:
        mov dx,00032    ; Print a 2
        mov ax,00202
        int 021



        ; XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

        ; MOD=00 R/M=010 -- SS:BP+SI= BA00+1070+05 = BB075
TEST3:  mov bp , 01070
        mov si, 005
        lea ax , [bp+si]
        cmp byte [bp+si] , 075
        jne FAIL3
        cmp word [bp+si] , 07675
        jne FAIL3

        ; MOD=01 R/M=010 -- SS:BP+SI+D8= BA00+1070+05+2 = BB077
        mov bp , 01070
        mov si , 005
        lea ax , [bp+si+02]
        cmp byte [bp+si+02] , 077
        jne FAIL3
        cmp word [bp+si+02] , 07877
        jne FAIL3

        ; MOD=01 R/M=010 -- SS:BP+SI-D8= BA00+1070+05-3 = BB072
        mov bp , 01070
        mov si , 005
        lea ax , [bp+si-03]
        cmp byte [bp+si-03] , 072
        jne FAIL3
        cmp word [bp+si-03] , 07372
        jne FAIL3

        ; MOD=10 R/M=010 -- SS:BP+SI+D16= BA00+1070+05+103 = BB178
        mov bp , 01070
        mov si , 005
        lea ax , [bp+si+0103]
        cmp byte [bp+si+0103] , 078
        jne FAIL3
        cmp word [bp+si+0103] , 07978
        jne FAIL3

        ; MOD=10 R/M=010 -- SS:BP+SI-D16= BA00+1170+35-102 = BB0A3
        mov bp , 01170
        mov si , 00035
        lea ax , [bp+si-0102]
        cmp byte [bp+si-0102], 0A3
        jne FAIL3
        cmp word [bp+si-0102] , 0A4A3
        jne FAIL3
        jmp TEST4


FAIL3:
        mov dx,00033    ; Print a 3
        mov ax,00202
        int 021



        ; XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

        ; MOD=00 R/M=011 -- SS:BP+DI= BA00+1070+06 = BB076
TEST4:  mov bp , 01070
        mov di, 006
        lea ax , [bp+di]
        cmp byte [bp+di] , 076
        jne FAIL4
        cmp word [bp+di] , 07776
        jne FAIL4

        ; MOD=01 R/M=011 -- SS:BP+DI+D8= BA00+1070+06+2 = BB078
        mov bp , 01070
        mov di , 006
        lea ax , [bp+di+02]
        cmp byte [bp+di+02] , 078
        jne FAIL4
        cmp word [bp+di+02] , 07978
        jne FAIL4

        ; MOD=01 R/M=011 -- SS:BP+DI-D8= BA00+1070+06-3 = BB073
        mov bp , 01070
        mov di , 006
        lea ax , [bp+di-03]
        cmp byte [bp+di-03] , 073
        jne FAIL4
        cmp word [bp+di-03] , 07473
        jne FAIL4

        ; MOD=10 R/M=011 -- SS:BP+DI+D16= BA00+1070+06+103 = BB179
        mov bp , 01070
        mov di , 006
        lea ax , [bp+di+0103]
        cmp byte [bp+di+0103] , 079
        jne FAIL4
        cmp word [bp+di+0103] , 07A79
        jne FAIL4

        ; MOD=10 R/M=011 -- SS:BP+DI-D16= BA00+1170+36-102 = BB0A4
        mov bp , 01170
        mov di , 00036
        lea ax , [bp+di-0102]
        cmp byte [bp+di-0102], 0A4
        jne FAIL4
        cmp word [bp+di-0102] , 0A5A4
        jne FAIL4
        jmp TEST5



FAIL4:
        mov dx,00034    ; Print a 4
        mov ax,00202
        int 021



        ; XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX


        ; MOD=00 R/M=100 -- DS:SI= B900+2024 = BB024
TEST5:  mov bx , 00000
        mov si , 02024
        lea ax , [si]
        cmp byte [si] , 024
        jne FAIL5
        cmp word [si] , 02524
        jne FAIL5

        ; MOD=01 R/M=100 -- DS:SI+D8= B900+2024+3 = BB027
        mov bx , 00000
        mov si , 02024
        lea ax , [si+03]
        cmp byte [si+03] , 027
        jne FAIL5
        cmp word [si+03] , 02827
        jne FAIL5

        ; MOD=01 R/M=100 -- DS:SI-D8= B900+2024-3 = BB021
        mov bx , 00000
        mov si , 02024
        lea ax , [si-03]
        cmp byte [si-03] , 021
        jne FAIL5
        cmp word [si-03] , 02221
        jne FAIL5

        ; MOD=10 R/M=100 -- DS:SI+D16= B900+2024+104 = BB128
        mov bx , 00000
        mov si , 02024
        lea ax , [si+0104]
        cmp byte [si+0104] , 028
        jne FAIL5
        cmp word [si+0104] , 02928
        jne FAIL5

        ; MOD=10 R/M=100 -- DS:SI-D16= B900+2124-102 = BB022
        mov bx , 00000
        mov si , 02124
        lea ax , [si-0102]
        cmp byte [si-0102], 022
        jne FAIL5
        cmp word [si-0102] , 02322
        jne FAIL5
        jmp TEST6


FAIL5:
        mov dx,00035    ; Print a 5
        mov ax,00202
        int 021



        ; XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX


        ; MOD=00 R/M=101 -- DS:DI= B900+2024 = BB024
TEST6:  mov si , 00000
        mov di , 02024
        lea ax , [di]
        cmp byte [di] , 024
        jne FAIL6
        cmp word [di] , 02524
        jne FAIL6

        ; MOD=01 R/M=101 -- DS:DI+D8= B900+2024+3 = BB027
        mov si , 00000
        mov di , 02024
        lea ax , [di+03]
        cmp byte [di+03] , 027
        jne FAIL6
        cmp word [di+03] , 02827
        jne FAIL6

        ; MOD=01 R/M=101 -- DS:DI-D8= B900+2024-3 = BB021
        mov si , 00000
        mov di , 02024
        lea ax , [di-03]
        cmp byte [di-03] , 021
        jne FAIL6
        cmp word [di-03] , 02221
        jne FAIL6

        ; MOD=10 R/M=101 -- DS:DI+D16= B900+2025+104 = BB129
        mov si , 00000
        mov di , 02025
        lea ax , [di+0104]
        cmp byte [di+0104] , 029
        jne FAIL6
        cmp word [di+0104] , 02A29
        jne FAIL6

        ; MOD=10 R/M=101 -- DS:DI-D16= B900+2124-102 = BB022
        mov si , 00000
        mov di , 02124
        lea ax , [di-0102]
        cmp byte [di-0102], 022
        jne FAIL6
        cmp word [di-0102] , 02322
        jne FAIL6
        jmp TEST7


FAIL6:
        mov dx,00036    ; Print an 6
        mov ax,00202
        int 021
        jmp Z_END


        ; XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

        ; MOD=00 R/M=110 -- DS=B900:[DIRECT ACCESS] = BB044
TEST7:  mov bp , 00000
        lea ax , [02044]
        cmp byte [02044] , 044
        jne FAIL7
        cmp word [02044] , 04544
        jne FAIL7

        ; MOD=01 R/M=110 -- SS:BP+D8= BA00+1050+5 = BB055
        mov bp , 01050
        lea ax , [bp+05]
        cmp byte [bp+05] , 055
        jne FAIL7
        cmp word [bp+05] , 05655
        jne FAIL7

        ; MOD=01 R/M=110 -- SS:BP+D8= BA00+1050-3 = BB04D
        mov bp , 01050
        lea ax , [bp-03]
        cmp byte [bp-03] , 04D
        jne FAIL7
        cmp word [bp-03] , 04E4D
        jne FAIL7

        ; MOD=10 R/M=110 -- SS:BP+D16= BA00+1060+106 = BB166
        mov bp , 01060
        lea ax , [bp+0106]
        cmp byte [bp+0106] , 066
        jne FAIL7
        cmp word [bp+0106] , 06766
        jne FAIL7

        ; MOD=10 R/M=110 -- SS:BP-D16= BA00+1170-102 = BB06E
        mov bp , 01170
        lea ax , [bp-0102]
        cmp byte [bp-0102], 06E
        jne FAIL7
        cmp word [bp-0102] , 06F6E
        jne FAIL7
        jmp TEST8


FAIL7:
        mov dx,00037    ; Print an 7
        mov ax,00202
        int 021
        jmp Z_END



        ; XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

        ; MOD=00 R/M=111 -- DS:BX= B900+2066 = BB066
TEST8:  mov bx , 02066
        mov si , 00000
        lea ax , [bx]
        cmp byte [bx] , 066
        jne FAIL8
        cmp word [bx] , 06766
        jne FAIL8

        ; MOD=01 R/M=111 -- DS:BX+D8= B900+2066+3 = BB069
        mov bx , 02066
        mov si , 00000
        lea ax , [bx+03]
        cmp byte [bx+03] , 069
        jne FAIL8
        cmp word [bx+03] , 06A69
        jne FAIL8

        ; MOD=01 R/M=111 -- DS:BX-D8= B900+2066-3 = BB063
        mov bx , 02066
        mov si , 00000
        lea ax , [bx-03]
        cmp byte [bx-03] , 063
        jne FAIL8
        cmp word [bx-03] , 06463
        jne FAIL8

        ; MOD=10 R/M=111 -- DS:BX+D16= B900+2066+103 = BB169
        mov bx , 02066
        mov si , 00000
        lea ax , [bx+0103]
        cmp byte [bx+0103] , 069
        jne FAIL8
        cmp word [bx+0103] , 06A69
        jne FAIL8

        ; MOD=10 R/M=111 -- DS:BX-D16= B900+2166-102 = BB064
        mov bx , 02166
        mov si , 00000
        lea ax , [bx-0102]
        cmp byte [bx-0102], 064
        jne FAIL8
        cmp word [bx-0102] , 06564
        jne FAIL8
        jmp ADR_MODE_TEST_2

        ; XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX




FAIL8:
        mov dx,00038    ; Print an 8
        mov ax,00202
        int 021
        jmp Z_END



; Addressing modes Test-2
; ------------------------
ADR_MODE_TEST_2:
        nop

        ; Set all segments and pointers
        ; -----------------------------

        mov ax,0BB00    ; Set the ES
        mov es,ax
        mov di,00000    ; Zero the DI pointer

        mov ax,0B900    ; Set the DS
        mov ds,ax
        mov si,02000    ; Zero the SI pointer

        mov ax,0BA00    ; Set the SS
        mov ss,ax
        mov sp,011FE    ; Set the Stack to BB1FE
        mov bp,01000    ; Set the BP


        ; Fill BB000-BB1FF with incremening data
        ; ---------------------------------------

        mov ax,00000    ; Zero out value to write
        mov cx,00200    ; Set cx to count 512 times
        cld             ; Make sure DI increments

L11:    stosb           ; ES:DI <= AL
        inc ax          ; AX and DI will increment
        loop L11        ; Repeat FF times


        ; Write memory using each addressing mode
        ; and compare to immediate value.

        ; MOD=00 R/M=000 -- DS:BX+SI= B900+2030+14 = BB044
TEST11: mov bx , 02030
        mov si , 014
        mov byte [bx+si] , 05A
        cmp byte [bx+si] , 05A
        jne FAIL11

        ; MOD=01 R/M=000 -- DS:BX+SI+D8= B900+2030+14+4 = BB048
        mov bx , 02030
        mov si , 014
        mov byte [bx+si+04] , 012
        cmp byte [bx+si+04] , 012
        jne FAIL11

        ; MOD=01 R/M=000 -- DS:BX+SI-D8= B900+2030+14-3 = BB040
        mov bx , 02030
        mov si , 014
        mov byte [bx+si-04] , 034
        cmp byte [bx+si-04] , 034
        jne FAIL11

        ; MOD=10 R/M=000 -- DS:BX+SI+D16= B900+2020+25+104 = BB149
        mov bx , 02020
        mov si , 00025
        mov byte [bx+si+0104] , 087
        cmp byte [bx+si+0104] , 087
        jne FAIL11

        ; MOD=10 R/M=000 -- DS:BX+SI-D16= B900+2120+25-102 = BB043
        mov bx , 02120
        mov si , 00025
        mov byte [bx+si-0102] , 041
        cmp byte [bx+si-0102] , 041
        jne FAIL11
        jmp TEST12


FAIL11:
        mov dx,00031    ; Print a 1
        mov ax,00202
        int 021



        ; XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

        ; MOD=00 R/M=001 -- DS:BX+DI= B900+2040+04 = BB044
TEST12: mov bx , 02040
        mov di , 004
        mov byte [bx+di] , 012
        cmp byte [bx+di] , 012
        jne FAIL12

        ; MOD=01 R/M=001 -- DS:BX+DI+D8= B900+2040+04+4 = BB048
        mov bx , 02040
        mov di , 004
        mov byte [bx+di+04] , 085
        cmp byte [bx+di+04] , 085
        jne FAIL12

        ; MOD=01 R/M=001 -- DS:BX+DI-D8= B900+2040+04-3 = BB040
        mov bx , 02040
        mov di , 004
        mov byte [bx+di-04] , 056
        cmp byte [bx+di-04] , 056
        jne FAIL12

        ; MOD=10 R/M=001 -- DS:BX+DI+D16= B900+2010+35+104 = BB149
        mov bx , 02010
        mov di , 00035
        mov byte [bx+di+0104] , 053
        cmp byte [bx+di+0104] , 053
        jne FAIL12

        ; MOD=10 R/M=001 -- DS:BX+DI-D16= B900+2110+35-102 = BB043
        mov bx , 02110
        mov di , 00035
        mov byte [bx+di-0102] , 075
        cmp byte [bx+di-0102] , 075
        jne FAIL12
        jmp TEST13

        ; XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX


FAIL12:
        mov dx,00032    ; Print a 2
        mov ax,00202
        int 021



        ; XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

        ; MOD=00 R/M=010 -- SS:BP+SI= BA00+1070+05 = BB075
TEST13: mov bp , 01070
        mov si, 005
        mov byte [bp+si] , 072
        cmp byte [bp+si] , 072
        jne FAIL13

        ; MOD=01 R/M=010 -- SS:BP+SI+D8= BA00+1070+05+2 = BB077
        mov bp , 01070
        mov si , 005
        mov byte [bp+si+02] , 011
        cmp byte [bp+si+02] , 011
        jne FAIL13

        ; MOD=01 R/M=010 -- SS:BP+SI-D8= BA00+1070+05-3 = BB072
        mov bp , 01070
        mov si , 005
        mov byte [bp+si-03] , 024
        cmp byte [bp+si-03] , 024
        jne FAIL13

        ; MOD=10 R/M=010 -- SS:BP+SI+D16= BA00+1070+05+103 = BB178
        mov bp , 01070
        mov si , 005
        mov byte [bp+si+0103] , 033
        cmp byte [bp+si+0103] , 033
        jne FAIL13

        ; MOD=10 R/M=010 -- SS:BP+SI-D16= BA00+1170+35-102 = BB0A3
        mov bp , 01170
        mov si , 00035
        mov byte [bp+si-0102] , 0BC
        cmp byte [bp+si-0102] , 0BC
        jne FAIL13
        jmp TEST14


FAIL13:
        mov dx,00033    ; Print a 3
        mov ax,00202
        int 021



        ; XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

        ; MOD=00 R/M=011 -- SS:BP+DI= BA00+1070+06 = BB076
TEST14: mov bp , 01070
        mov di, 006
        mov byte [bp+di] , 0A2
        cmp byte [bp+di] , 0A2
        jne FAIL14

        ; MOD=01 R/M=011 -- SS:BP+DI+D8= BA00+1070+06+2 = BB078
        mov bp , 01070
        mov di , 006
        mov byte [bp+di+02] , 0CE
        cmp byte [bp+di+02] , 0CE
        jne FAIL14

        ; MOD=01 R/M=011 -- SS:BP+DI-D8= BA00+1070+06-3 = BB073
        mov bp , 01070
        mov di , 006
        mov byte [bp+di-03] , 022
        cmp byte [bp+di-03] , 022
        jne FAIL14

        ; MOD=10 R/M=011 -- SS:BP+DI+D16= BA00+1070+06+103 = BB179
        mov bp , 01070
        mov di , 006
        mov byte [bp+di+0103] , 0AB
        cmp byte [bp+di+0103] , 0AB
        jne FAIL14

        ; MOD=10 R/M=011 -- SS:BP+DI-D16= BA00+1170+36-102 = BB0A4
        mov bp , 01170
        mov di , 00036
        mov byte [bp+di-0102] , 0EE
        cmp byte [bp+di-0102] , 0EE
        jne FAIL14
        jmp TEST15



FAIL14:
        mov dx,00034    ; Print a 4
        mov ax,00202
        int 021



        ; XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX


        ; MOD=00 R/M=100 -- DS:SI= B900+2024 = BB024
TEST15: mov bx , 00000
        mov si , 02024
        mov byte [si] , 0DD
        cmp byte [si] , 0DD
        jne FAIL15

        ; MOD=01 R/M=100 -- DS:SI+D8= B900+2024+3 = BB027
        mov bx , 00000
        mov si , 02024
        mov byte [si+03] , 012
        cmp byte [si+03] , 012
        jne FAIL15

        ; MOD=01 R/M=100 -- DS:SI-D8= B900+2024-3 = BB021
        mov bx , 00000
        mov si , 02024
        mov byte [si-03] , 0F3
        cmp byte [si-03] , 0F3
        jne FAIL15

        ; MOD=10 R/M=100 -- DS:SI+D16= B900+2024+104 = BB128
        mov bx , 00000
        mov si , 02024
        mov byte [si+0104] , 0A2
        cmp byte [si+0104] , 0A2
        jne FAIL15

        ; MOD=10 R/M=100 -- DS:SI-D16= B900+2124-102 = BB022
        mov bx , 00000
        mov si , 02124
        mov byte [si-0102] , 04E
        cmp byte [si-0102] , 04E
        jne FAIL15
        jmp TEST16


FAIL15:
        mov dx,00035    ; Print a 5
        mov ax,00202
        int 021



        ; XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX


        ; MOD=00 R/M=101 -- DS:DI= B900+2024 = BB024
TEST16: mov si , 00000
        mov di , 02024
        mov byte [di] , 0AA
        cmp byte [di] , 0AA
        jne FAIL16

        ; MOD=01 R/M=101 -- DS:DI+D8= B900+2024+3 = BB027
        mov si , 00000
        mov di , 02024
        mov byte [di+03] , 0AB
        cmp byte [di+03] , 0AB
        jne FAIL16

        ; MOD=01 R/M=101 -- DS:DI-D8= B900+2024-3 = BB021
        mov si , 00000
        mov di , 02024
        mov byte [di-03] , 033
        cmp byte [di-03] , 033
        jne FAIL16

        ; MOD=10 R/M=101 -- DS:DI+D16= B900+2025+104 = BB129
        mov si , 00000
        mov di , 02025
        mov byte [di+0104] , 046
        cmp byte [di+0104] , 046
        jne FAIL16

        ; MOD=10 R/M=101 -- DS:DI-D16= B900+2124-102 = BB022
        mov si , 00000
        mov di , 02124
        mov byte [di-0102] , 0CE
        cmp byte [di-0102] , 0CE
        jne FAIL16
        jmp TEST17


FAIL16:
        mov dx,00036    ; Print an 6
        mov ax,00202
        int 021
        jmp Z_END


        ; XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

        ; MOD=00 R/M=110 -- DS=B900:[DIRECT ACCESS] = BB044
TEST17:  mov bp , 00000
        mov byte [02044] , 0A2
        cmp byte [02044] , 0A2
        jne FAIL17

        ; MOD=01 R/M=110 -- SS:BP+D8= BA00+1050+5 = BB055
        mov bp , 01050
        mov byte [bp+05] , 0E8
        cmp byte [bp+05] , 0E8
        jne FAIL17

        ; MOD=01 R/M=110 -- SS:BP+D8= BA00+1050-3 = BB04D
        mov bp , 01050
        mov byte [bp-03] , 03C
        cmp byte [bp-03] , 03C
        jne FAIL17

        ; MOD=10 R/M=110 -- SS:BP+D16= BA00+1060+106 = BB166
        mov bp , 01060
        mov byte [bp+0106] , 012
        cmp byte [bp+0106] , 012
        jne FAIL17

        ; MOD=10 R/M=110 -- SS:BP-D16= BA00+1170-102 = BB06E
        mov bp , 01170
        mov byte [bp-0102] , 09C
        cmp byte [bp-0102] , 09C
        jne FAIL17
        jmp TEST18


FAIL17:
        mov dx,00037    ; Print an 7
        mov ax,00202
        int 021
        jmp Z_END



        ; XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

        ; MOD=00 R/M=111 -- DS:BX= B900+2066 = BB066
TEST18: mov bx , 02066
        mov si , 00000
        mov byte [bx] , 045
        cmp byte [bx] , 045
        jne FAIL18

        ; MOD=01 R/M=111 -- DS:BX+D8= B900+2066+3 = BB069
        mov bx , 02066
        mov si , 00000
        mov byte [bx+03] , 099
        cmp byte [bx+03] , 099
        jne FAIL18

        ; MOD=01 R/M=111 -- DS:BX-D8= B900+2066-3 = BB063
        mov bx , 02066
        mov si , 00000
        mov byte [bx-03] , 0C6
        cmp byte [bx-03] , 0C6
        jne FAIL18

        ; MOD=10 R/M=111 -- DS:BX+D16= B900+2066+103 = BB169
        mov bx , 02066
        mov si , 00000
        mov byte [bx+0103] , 034
        cmp byte [bx+0103] , 034
        jne FAIL18

        ; MOD=10 R/M=111 -- DS:BX-D16= B900+2166-102 = BB064
        mov bx , 02166
        mov si , 00000
        mov byte [bx-0102] , 0EA
        cmp byte [bx-0102] , 0EA
        jne FAIL18
        jmp ADR_MODE_TEST_3


        ; XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX


FAIL18:
        mov dx,00038    ; Print an 8
        mov ax,00202
        int 021
        jmp Z_END


; Addressing modes Test-3
; -----------------------
ADR_MODE_TEST_3:
        nop

        ; Set all segments and pointers
        ; -----------------------------

        mov ax,0BB00    ; Set the ES
        mov es,ax
        mov di,00000    ; Zero the DI pointer

        mov ax,0B900    ; Set the DS
        mov ds,ax
        mov si,02000    ; Zero the SI pointer

        mov ax,0BA00    ; Set the SS
        mov ss,ax
        mov sp,011FE    ; Set the Stack to BB1FE
        mov bp,01000    ; Set the BP


        ; Fill BB000-BB1FF with incremening data
        ; ---------------------------------------

        mov ax,00000    ; Zero out value to write
        mov cx,00200    ; Set cx to count 512 times
        cld             ; Make sure DI increments

L21:    stosb           ; ES:DI <= AL
        inc ax          ; AX and DI will increment
        loop L21        ; Repeat FF times


        ; Write memory using each addressing mode
        ; and compare to immediate value.

        ; MOD=00 R/M=000 -- DS:BX+SI= B900+2030+14 = BB044
TEST21: mov bx , 02030
        mov si , 014
        mov word [bx+si] , 0325A
        cmp word [bx+si] , 0325A
        jne FAIL21

        ; MOD=01 R/M=000 -- DS:BX+SI+D8= B900+2030+14+4 = BB048
        mov bx , 02030
        mov si , 014
        mov word [bx+si+04] , 0EC12
        cmp word [bx+si+04] , 0EC12
        jne FAIL21

        ; MOD=01 R/M=000 -- DS:BX+SI-D8= B900+2030+14-3 = BB040
        mov bx , 02030
        mov si , 014
        mov word [bx+si-04] , 0AB34
        cmp word [bx+si-04] , 0AB34
        jne FAIL21

        ; MOD=10 R/M=000 -- DS:BX+SI+D16= B900+2020+25+104 = BB149
        mov bx , 02020
        mov si , 00025
        mov word [bx+si+0104] , 0DD87
        cmp word [bx+si+0104] , 0DD87
        jne FAIL21

        ; MOD=10 R/M=000 -- DS:BX+SI-D16= B900+2120+25-102 = BB043
        mov bx , 02120
        mov si , 00025
        mov word [bx+si-0102] , 0D341
        cmp word [bx+si-0102] , 0D341
        jne FAIL21
        jmp TEST22


FAIL21:
        mov dx,00031    ; Print a 1
        mov ax,00202
        int 021



        ; XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

        ; MOD=00 R/M=001 -- DS:BX+DI= B900+2040+04 = BB044
TEST22: mov bx , 02040
        mov di , 004
        mov word [bx+di] , 02E12
        cmp word [bx+di] , 02E12
        jne FAIL22

        ; MOD=01 R/M=001 -- DS:BX+DI+D8= B900+2040+04+4 = BB048
        mov bx , 02040
        mov di , 004
        mov word [bx+di+04] , 02285
        cmp word [bx+di+04] , 02285
        jne FAIL22

        ; MOD=01 R/M=001 -- DS:BX+DI-D8= B900+2040+04-3 = BB040
        mov bx , 02040
        mov di , 004
        mov word [bx+di-04] , 0EA56
        cmp word [bx+di-04] , 0EA56
        jne FAIL22

        ; MOD=10 R/M=001 -- DS:BX+DI+D16= B900+2010+35+104 = BB149
        mov bx , 02010
        mov di , 00035
        mov word [bx+di+0104] , 0CC53
        cmp word [bx+di+0104] , 0CC53
        jne FAIL22

        ; MOD=10 R/M=001 -- DS:BX+DI-D16= B900+2110+35-102 = BB043
        mov bx , 02110
        mov di , 00035
        mov word [bx+di-0102] , 04475
        cmp word [bx+di-0102] , 04475
        jne FAIL22
        jmp TEST23

        ; XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX


FAIL22:
        mov dx,00032    ; Print a 2
        mov ax,00202
        int 021



        ; XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

        ; MOD=00 R/M=010 -- SS:BP+SI= BA00+1070+05 = BB075
TEST23: mov bp , 01070
        mov si, 005
        mov word [bp+si] , 08472
        cmp word [bp+si] , 08472
        jne FAIL23

        ; MOD=01 R/M=010 -- SS:BP+SI+D8= BA00+1070+05+2 = BB077
        mov bp , 01070
        mov si , 005
        mov word [bp+si+02] , 03C11
        cmp word [bp+si+02] , 03C11
        jne FAIL23

        ; MOD=01 R/M=010 -- SS:BP+SI-D8= BA00+1070+05-3 = BB072
        mov bp , 01070
        mov si , 005
        mov word [bp+si-03] , 02A24
        cmp word [bp+si-03] , 02A24
        jne FAIL23

        ; MOD=10 R/M=010 -- SS:BP+SI+D16= BA00+1070+05+103 = BB178
        mov bp , 01070
        mov si , 005
        mov word [bp+si+0103] , 04C33
        cmp word [bp+si+0103] , 04C33
        jne FAIL23

        ; MOD=10 R/M=010 -- SS:BP+SI-D16= BA00+1170+35-102 = BB0A3
        mov bp , 01170
        mov si , 00035
        mov word [bp+si-0102] , 055BC
        cmp word [bp+si-0102] , 055BC
        jne FAIL23
        jmp TEST24


FAIL23:
        mov dx,00033    ; Print a 3
        mov ax,00202
        int 021



        ; XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

        ; MOD=00 R/M=011 -- SS:BP+DI= BA00+1070+06 = BB076
TEST24: mov bp , 01070
        mov di, 006
        mov word [bp+di] , 0EDA2
        cmp word [bp+di] , 0EDA2
        jne FAIL24

        ; MOD=01 R/M=011 -- SS:BP+DI+D8= BA00+1070+06+2 = BB078
        mov bp , 01070
        mov di , 006
        mov word [bp+di+02] , 0DFCE
        cmp word [bp+di+02] , 0DFCE
        jne FAIL24

        ; MOD=01 R/M=011 -- SS:BP+DI-D8= BA00+1070+06-3 = BB073
        mov bp , 01070
        mov di , 006
        mov word [bp+di-03] , 0C422
        cmp word [bp+di-03] , 0C422
        jne FAIL24

        ; MOD=10 R/M=011 -- SS:BP+DI+D16= BA00+1070+06+103 = BB179
        mov bp , 01070
        mov di , 006
        mov word [bp+di+0103] , 02CAB
        cmp word [bp+di+0103] , 02CAB
        jne FAIL24

        ; MOD=10 R/M=011 -- SS:BP+DI-D16= BA00+1170+36-102 = BB0A4
        mov bp , 01170
        mov di , 00036
        mov word [bp+di-0102] , 057EE
        cmp word [bp+di-0102] , 057EE
        jne FAIL24
        jmp TEST25



FAIL24:
        mov dx,00034    ; Print a 4
        mov ax,00202
        int 021



        ; XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX


        ; MOD=00 R/M=100 -- DS:SI= B900+2024 = BB024
TEST25: mov bx , 00000
        mov si , 02024
        mov word [si] , 010DD
        cmp word [si] , 010DD
        jne FAIL25

        ; MOD=01 R/M=100 -- DS:SI+D8= B900+2024+3 = BB027
        mov bx , 00000
        mov si , 02024
        mov word [si+03] , 02A12
        cmp word [si+03] , 02A12
        jne FAIL25

        ; MOD=01 R/M=100 -- DS:SI-D8= B900+2024-3 = BB021
        mov bx , 00000
        mov si , 02024
        mov word [si-03] , 0CDF3
        cmp word [si-03] , 0CDF3
        jne FAIL25

        ; MOD=10 R/M=100 -- DS:SI+D16= B900+2024+104 = BB128
        mov bx , 00000
        mov si , 02024
        mov word [si+0104] , 0DFA2
        cmp word [si+0104] , 0DFA2
        jne FAIL25

        ; MOD=10 R/M=100 -- DS:SI-D16= B900+2124-102 = BB022
        mov bx , 00000
        mov si , 02124
        mov word [si-0102] , 0AD4E
        cmp word [si-0102] , 0AD4E
        jne FAIL25
        jmp TEST26


FAIL25:
        mov dx,00035    ; Print a 5
        mov ax,00202
        int 021



        ; XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX


        ; MOD=00 R/M=101 -- DS:DI= B900+2024 = BB024
TEST26: mov si , 00000
        mov di , 02024
        mov word [di] , 03CAA
        cmp word [di] , 03CAA
        jne FAIL26

        ; MOD=01 R/M=101 -- DS:DI+D8= B900+2024+3 = BB027
        mov si , 00000
        mov di , 02024
        mov word [di+03] , 021AB
        cmp word [di+03] , 021AB
        jne FAIL26

        ; MOD=01 R/M=101 -- DS:DI-D8= B900+2024-3 = BB021
        mov si , 00000
        mov di , 02024
        mov word [di-03] , 07933
        cmp word [di-03] , 07933
        jne FAIL26

        ; MOD=10 R/M=101 -- DS:DI+D16= B900+2025+104 = BB129
        mov si , 00000
        mov di , 02025
        mov word [di+0104] , 0B646
        cmp word [di+0104] , 0B646
        jne FAIL26

        ; MOD=10 R/M=101 -- DS:DI-D16= B900+2124-102 = BB022
        mov si , 00000
        mov di , 02124
        mov word [di-0102] , 0EBCE
        cmp word [di-0102] , 0EBCE
        jne FAIL26
        jmp TEST27


FAIL26:
        mov dx,00036    ; Print an 6
        mov ax,00202
        int 021
        jmp Z_END


        ; XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

        ; MOD=00 R/M=110 -- DS=B900:[DIRECT ACCESS] = BB044
TEST27: mov bp , 00000
        mov word [02044] , 0ABA2
        cmp word [02044] , 0ABA2
        jne FAIL27

        ; MOD=01 R/M=110 -- SS:BP+D8= BA00+1050+5 = BB055
        mov bp , 01050
        mov word [bp+05] , 0BEE8
        cmp word [bp+05] , 0BEE8
        jne FAIL27

        ; MOD=01 R/M=110 -- SS:BP+D8= BA00+1050-3 = BB04D
        mov bp , 01050
        mov word [bp-03] , 09B3C
        cmp word [bp-03] , 09B3C
        jne FAIL27

        ; MOD=10 R/M=110 -- SS:BP+D16= BA00+1060+106 = BB166
        mov bp , 01060
        mov word [bp+0106] , 06E12
        cmp word [bp+0106] , 06E12
        jne FAIL27

        ; MOD=10 R/M=110 -- SS:BP-D16= BA00+1170-102 = BB06E
        mov bp , 01170
        mov word [bp-0102] , 03C9C
        cmp word [bp-0102] , 03C9C
        jne FAIL27
        jmp TEST28


FAIL27:
        mov dx,00037    ; Print an 7
        mov ax,00202
        int 021
        jmp Z_END



        ; XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

        ; MOD=00 R/M=111 -- DS:BX= B900+2066 = BB066
TEST28: mov bx , 02066
        mov si , 00000
        mov word [bx] , 0B245
        cmp word [bx] , 0B245
        jne FAIL28

        ; MOD=01 R/M=111 -- DS:BX+D8= B900+2066+3 = BB069
        mov bx , 02066
        mov si , 00000
        mov word [bx+03] , 01A99
        cmp word [bx+03] , 01A99
        jne FAIL28

        ; MOD=01 R/M=111 -- DS:BX-D8= B900+2066-3 = BB063
        mov bx , 02066
        mov si , 00000
        mov word [bx-03] , 04DC6
        cmp word [bx-03] , 04DC6
        jne FAIL28

        ; MOD=10 R/M=111 -- DS:BX+D16= B900+2066+103 = BB169
        mov bx , 02066
        mov si , 00000
        mov word [bx+0103] , 0EC34
        cmp word [bx+0103] , 0EC34
        jne FAIL28

        ; MOD=10 R/M=111 -- DS:BX-D16= B900+2166-102 = BB064
        mov bx , 02166
        mov si , 00000
        mov word [bx-0102] , 05DEA
        cmp word [bx-0102] , 05DEA
        jne FAIL28


        ; XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX


Z_END:
        mov ax,00000    ; DOS Command=Exit
        int 021


FAIL28:
        mov dx,00038    ; Print an 8
        mov ax,00202
        int 021
        jmp Z_END


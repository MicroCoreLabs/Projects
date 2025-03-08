TITLE  Test_umb  will test for Upper Memory Blocks

CR      EQU     0Dh
LF      EQU     0Ah
fwd     EQU     00h
bwd     EQU    0FFh
yes     EQU     00h
no      EQU    0FFh

cseg    segment public
        assume cs:cseg, ds:cseg, es:nothing

;-------------------------------------------------------------------
; Code

init:   push    cs
        pop     ds

        mov     ah, 09h
        mov     dx, offset hello$
        int     21h

        cld                             ;lets be sure
        mov     es, [initadr]           ;start there (A000)

nxtBlk: call    ChkRAM
        mov     [jmpsze], 0400h         ;take 400h size steps
        mov     [direct], fwd           ;move to the right again
        cmp     [flip], yes
        jnz     short sayNo

sayYes: mov     dx, offset yesRAM$      ;found RAM
        mov     [flip], yes             ;  indicate with flip1
        jmp     short showMs

sayNo:  mov     dx, offset noRAM$       ;found no RAM
        mov     [flip], no              ;  indicate with flip0

showMs: call    messge                  ;and tell it

move:   cmp     [direct], bwd           ;backward?
        jz      short backw
        mov     di, es
        add     di, [jmpsze]            ;jump forward
        mov     es, di
        jc      endIt
        jmp     short cont

backw:  mov     di, es
        sub     di, [jmpsze]            ;jump backward
        mov     es, di

cont:   call    ChkRAM                  ;check location for RAM
        jz      move                    ;if no flip - keep jump'n

        xor     [direct], 0FFh          ;invert direction
        mov     ax, [jmpsze]            ;get jmpsze
        shr     ax, 1                   ;divide by 2
        mov     [jmpsze], ax            ;and store new
        jnz     move                    ;jump other way half dist'ce

        cmp     [direct], bwd           ;if direction bwd, then we are
        jnz     goOn                    ;already on begin new blk, so we
        mov     di, es                  ;we must recede one position
        dec     di                      ;for end of last blk
        mov     es, di                  ;so move left one paragraph
        xor     [flip], 0FFh            ;don't worry, we'll flip back
goOn:   call    endMes                  ;print this (end)location
        xor     [flip], 0FFh            ;but if stand before RAMflip wrong
        mov     di, es                  ;and proceed to begin next block
        inc     di
        mov     es, di
        jmp     nxtBlk

endIt:  mov     dx, offset last$
        mov     ah, 09h
        int     21h
        mov     dx, offset bye$
        int     21h
        mov     dx, offset warn$
        int     21h
        mov     ax, 4C00h
        int     21h

;-------------------------------------------------------------------
; Variables

jmpsze  dw     ?                        ;jumpsize
initadr dw    0A000h                    ;starting address
direct  db       fwd                    ;direction
flip    db       yes                    ;ram at last loc

hello$  db CR,LF,'ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»',CR,LF, \
                 'º  Test_UMB   checks for RAM in  Upper Memory  º',CR,LF, \
                 'º ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿ º$'

yesRAM$ db CR,LF,'º ³  Found RAM at paragraph $'
noRAM$  db CR,LF,'º ³  None      at paragraph $'
contd$  db                                   '#### until $'
endMes$ db                                              '####  ³ º$'
last$   db                                              'FFFF  ³ º',CR,LF,'$'

bye$    db       'º ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ º',CR,LF, \
                 'º   Author: Marco van Zwetselaar  8 Nov 1991   º',CR,LF, \
                 'ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼',CR,LF,'$'

warn$   db CR,LF,'PLEASE NOTE: Not all RAM displayed can be used!',CR,LF, \
                 '  In *general*, segment A, D and E are safe.',CR,LF,CR,LF,'$'

;-------------------------------------------------------------------
; Procedures

chkram  proc    near

        ;takes :    es : is paragraph to test
        ;destr : di, bx, dx, cx
        ;retur : zeroflag if flips equal, dl=old flip (FF=none, 00=RAM)

        xor     di, di
        mov     bx, es:[di]             ;get memory contents at es:0
        mov     dx, bx                  ;store in dx
        xor     dx, 0FFFFh              ;invert all bits
        mov     es:[di], dx             ;and store in memory again
        mov     cx, 080h                ;Pause a moment, so that
        loop    $                       ;we don't read what we wrote
        cmp     es:[di], dx             ;compare to what we put there
        mov     es:[di], bx             ;and restore original value
        mov     dl, [flip]              ;save old flip
        jz      flip0                   ;found ram?
        mov     [flip], no              ;    NOT - flip to no
        jmp     short pfff
flip0:  mov     [flip], yes             ;    YES - flip to yes
pfff:   cmp     dl, [flip]              ;set ZFlag if flipped
        ret

chkram  endp

messge  proc    near

        ;takes : ds:dx points to mess (no/yesRAM)
        ;      : es is segment-addr = paragr
        ;destr : di, bx, ax
        ;retur : unimportant - will print mess & addresses

        mov     ah, 09h                         ;print yes/noRAM
        int     21h

        mov     dx, es                          ;paragraph into dx
        mov     di, offset contd$               ;point di to location where
        push    es
        push    cs                              ;  it should be patched in
        pop     es
        mov     bx, offset digs                 ;ds:bx point to begin xtable
        mov     ax, dx                          ;dx is paragraph address
        xchg    al, ah                          ;ah patched 1st: must be in al
        call    makehex
        mov     ax, dx                          ;then patch al in
        call    makehex
        mov     dx, offset contd$               ;then print rest of messge
        mov     ah, 09h
        int     21h
        pop     es

        ret

messge  endp

endMes  proc    near

        mov     dx, es                          ;paragraph number in dx=es
        mov     di, offset endMes$              ;point es:di to patch
        push    es                              ;but save es for later!
        push    cs
        pop     es
        mov     bx, offset digs                 ;point ds:bx to xlat tbl
        mov     ax, dx
        xchg    al, ah
        call    makehex
        mov     ax, dx
        call    makehex
        mov     dx, offset endMes$              ;and show endlocation
        mov     ah, 09h
        int     21h
        pop     es                              ;reset es

        ret

endMes  endp

makehex proc    near

        ;takes :    al : byte to be conv'ted to ascii (like FCh - 'FC')
        ;        ds:bx : points to beginning of xlat table
        ;        es:di : points to location where "XX" should come
        ;destr : ax, di will point two bytes further
        ;retur : ascii digits in locations es:di and es:di+1

        db      0D4h, 010h              ;adjust for ascii multip: ah->ax/16
                                        ;                         al->rest

        xchg    al, ah                  ;high nibble first
        xlat                            ;ds:bx must point to right dig
        stosb                           ;store the string-byte

        xchg    al, ah
        xlat                            ;low level
        stosb

        ret

        digs    db      '0123456789ABCDEF'

makehex endp

cseg    ends
        end


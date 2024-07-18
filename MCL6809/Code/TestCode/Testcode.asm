;
;
;  File Name   :  MC6809 Opcode Tests
;  Used on     :  
;  Author      :  Ted Fried, MicroCore Labs
;  Creation    :  7/1/2024
;
;   Description:
;   ============
;   
;  MC6809 assembly program to test each opcode, flag, and addressing mode.
;
;  If failures are detected, the code will immediately loop on itself.
;
;  I used ASM6809.EXE to assemble the code and generate the binary.
;  Please set the reset vector to 0x0000.
;
;------------------------------------------------------------------------
;
; Modification History:
; =====================
;
; Revision 1 7/1/2024 
; Initial revision
;
;
;------------------------------------------------------------------------
;
; Copyright (c) 2024 Ted Fried
; 
; Permission is hereby granted, free of charge, to any person obtaining a copy
; of this software and associated documentation files (the "Software"), to deal
; in the Software without restriction, including without limitation the rights
; to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
; copies of the Software, and to permit persons to whom the Software is
; furnished to do so, subject to the following conditions:
; 
; The above copyright notice and this permission notice shall be included in all
; copies or substantial portions of the Software.
; 
; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
; IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
; FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
; AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
; LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
; OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
; SOFTWARE.
;

; Scratch workspace from  0x0000 
; Test code starts at     0x2000
; System Stack starts at  0xF100
; User Stack starts at    0xF200


  jmp op_LOAD_STORES

  
  ORG 0x01B00 
  lda #$000         ; SWI
  ldb #$000  
  ldx #$000  
  ldy #$000 
  rti
    
  ORG 0x01BA0 
  lda #$000         ; SWI2
  ldb #$000  
  ldx #$000  
  ldy #$000 
  rti
    
  ORG 0x01BB0 
  lda #$000         ; SWI3
  ldb #$000  
  ldx #$000  
  ldy #$000 
  rti
  
   
  
  ORG 0x02000 

; Test - Loads, stores using all addressing modes
; ----------------------------------------------------------------------
op_LOAD_STORES   
  nop
  nop
  nop

  ; Immediate Loads
  ; ----------------
  lda #$0AA  
  ldb #$0BB
  ldd #$FACE
  ldu #$01234
  lds #$05678
  ldx #$0DEAD
  ldy #$0BEEF
  nop
  nop
  nop
  
  ; Populate memory with test values
  ; 0x1200: 12 34
  ; 0x1204: 12 38
  ; 0x1212: 88 99
  ; 0x1234: 12 34 56 78 DE AD BE EF 
  ; 0x1258: 33 44 55 66 
  ; 0x1260: 33 44
  ; 0x8E12: 66 77
  ; 0x8F38: 5A 5B 
  ; 0x8F40: 12 34 
  
  ldy #$01200
  ldx #$01234
  stx ,Y    
  ldy #$01204
  ldx #$01238
  stx ,Y  
  ldy #$01234
  ldx #$01234
  stx ,Y
  ldx #$01236
  ldy #$05678
  sty ,X
  ldu #$01238
  lds #$0DEAD
  sts ,U
  lds #$0123A
  ldu #$0BEEF
  stu ,S
  ldu #$01258
  lds #$03344
  sts ,U
  lds #$0125A
  ldu #$05566
  stu ,S
  lds #$08F38
  ldu #$05A5B
  stu ,S
  lds #$08F40
  ldu #$01234
  stu ,S
  lds #$08E12
  ldu #$06677
  stu ,S
  lds #$01212
  ldu #$08899
  stu ,S
  ldu #$01260
  lds #$03344
  sts ,U
  nop
  nop
  nop
  
  
  ; ----------------------------------------
  ; Test - Loads
  ; ----------------------------------------
  
  ; Direct  
  ; ----------
  lda #$012  
  exg a,dp          ; Set the Direct Page
  SETDP 0x012       ; Tell the assembler about it
  
  lda <$034  
  cmpa #0x012
  lbne FAIL
  
  ldb <$035  
  cmpb #0x034
  lbne FAIL
  
  ldd <$036
  cmpd #0x05678
  lbne FAIL
 
  ldu <$038
  cmpu #0x0DEAD
  lbne FAIL

  lds <$03a
  cmps #0x0BEEF
  lbne FAIL

  ldx <$035
  cmpx #0x03456
  lbne FAIL

  ldy <$037 
  cmpy #0x078DE
  lbne FAIL

  nop
  nop
  nop
 

  ; Extended Direct                 
  ; -----------------
  lda >$0123B   
  cmpa #0x0EF
  lbne FAIL
  
  ldb >$0123a   
  cmpb #0x0BE
  lbne FAIL
  
  ldd >$01238   
  cmpd #0x0DEAD
  lbne FAIL
 
  ldu >$01234
  cmpu #0x01234
  lbne FAIL

  lds >$01234
  cmps #0x01234
  lbne FAIL

  ldx >$01235
  cmpx #0x03456
  lbne FAIL

  ldy >$01236 
  cmpy #0x05678
  lbne FAIL

  nop
  nop
  nop  



  ; Indexed - Extended Indirect                 
  ; ---------------------------
  
  ; Load memory with the indirect pointers - addresses + 0x0030
  ; 0x1400: 0x1234
  ; 0x1410: 0x1238

  ldy #$01400
  ldx #$01234
  stx ,Y
  ldx #$01410
  ldy #$01238
  sty ,X

   
  lda [$01400]  
  cmpa #0x012
  lbne FAIL
  
  ldb [$01400]  
  cmpb #0x012
  lbne FAIL
  
  ldd [$01400]  
  cmpd #0x01234
  lbne FAIL
 
  ldu [$01410]
  cmpu #0x0DEAD
  lbne FAIL

  lds [$01410]
  cmps #0x0DEAD
  lbne FAIL

  ldx [$01400]
  cmpx #0x01234
  lbne FAIL

  ldy [$01400] 
  cmpy #0x01234
  lbne FAIL

  nop
  nop
  nop  

  

  ; Indexed - Non-Indirect Register with opcode offsets from register 
  ; ------------------------------------------------------------------
  
  ldu #$01234       ; Set R index registers
  lds #$01238
  ldx #$01234
  ldy #$01238
  
  lda ,U            ; Indexed - Non-Indirect Register (no offset) 
  cmpa #0x012
  lbne FAIL
  
  lda -1,S          ; Indexed - Non-Indirect Register (5-bit offset) 
  cmpa #0x078
  lbne FAIL
  
  lda 32,S          ; Indexed - Non-Indirect Register (8-bit offset) 
  cmpa #0x033
  lbne FAIL
  
  lda 32000,S       ; Indexed - Non-Indirect Register (16-bit offset) 
  cmpa #0x05A
  lbne FAIL

  
  ldb ,Y            ; Indexed - Non-Indirect Register (no offset)
  cmpb #0x0DE
  lbne FAIL
  
  lda #2            ; Indexed - Non-Indirect Register (Accumulator-A offset)
  ldb A,Y            
  cmpb #0x0BE
  lbne FAIL
  
  ldb #3            ; Indexed - Non-Indirect Register (Accumulator-B offset)
  lda B,Y            
  cmpa #0x0EF
  lbne FAIL
    
  ldd #1            ; Indexed - Non-Indirect Register (Accumulator-B offset)
  lda D,Y            
  cmpa #0x0AD
  lbne FAIL
  
  

  ldd ,S            ; Indexed - Non-Indirect Register (no offset)
  cmpd #0x0DEAD
  lbne FAIL
 
  ldd ,S+           ; Indexed - Non-Indirect Register (Post-increment)
  cmpd #0x0DEAD
  lbne FAIL
  
  ldd ,S+           ; Indexed - Non-Indirect Register (Post-increment +1)
  cmpd #0x0ADBE
  lbne FAIL
   
  ldd ,S++          ; Indexed - Non-Indirect Register (Post-increment +2)
  cmpd #0x0BEEF
  lbne FAIL
 
  ldx #$01238
  ldu ,-X           ; Indexed - Non-Indirect Register (Pre-decrement -1)
  cmpu #0x078DE
  lbne FAIL

PCR_LABEL 
  ldx #$01238
  ldu ,--X                      ; Indexed - Non-Indirect Register (Pre-decrement -2)
  cmpu #0x05678
  lbne FAIL
    
  lda PCR_LABEL,PCR             ; Indexed - Non-Indirect PCR - PC Relative - 8-bit offset  
  cmpa #0x08E
  lbne FAIL
     
  lda op_LOAD_STORES,PCR        ; Indexed - Non-Indirect PCR - PC Relative - 16-bit offset  
  cmpa #0x012
  lbne FAIL
  

  lda [PCR_LABEL,PCR]           ; Indexed - Indirect PCR - PC Relative - 8-bit offset  
  cmpa #0x066
  lbne FAIL
  
  lda [op_LOAD_STORES,PCR]      ; Indexed - Indirect PCR - PC Relative - 16-bit offset  
  cmpa #0x088
  lbne FAIL
       
  
  
  
  ldu #$01234       ; Restore R index registers
  lds #$01238
  ldx #$01234
  ldy #$01238

  ldu ,X
 

  lds #$01200           ; Indexed - Indirect Register (8-bit offset)
  lda [4,S]          
  cmpu #0x01234
  lbne FAIL

  lds ,Y
  cmps #0x0DEAD
  lbne FAIL

  ldx ,Y
  cmpx #0x0DEAD
  lbne FAIL

  ldy ,Y
  cmpy #0x0DEAD
  lbne FAIL
  cmpa #0x0DE
  lbne FAIL

  lds #$01300           ; Indexed - Indirect Register (16-bit offset)
  lda [(-0x00100),S]            
  cmpa #0x012
  lbne FAIL
 
  ldu #$011FF           ; Indexed - Indirect Register (Accumulator-A offset)
  lda #$00001
  lda [A,U]         
  cmpa #0x012
  lbne FAIL
   
  ldu #$011FF           ; Indexed - Indirect Register (Accumulator-B offset)
  ldb #$00001
  lda [B,U]         
  cmpa #0x012
  lbne FAIL
    
  ldu #$010FF           ; Indexed - Indirect Register (Accumulator-D offset)
  ldd #$00101
  lda [D,U]         
  cmpa #0x012
  lbne FAIL
  
   
  lds #$01200
  ldy [,S++]            ; Indexed - ndirect Register (Post-increment +2)
  cmpy #0x01234
  lbne FAIL
  cmps #0x01202
  lbne FAIL
   
   
  lds #$01202
  ldy [,--S]            ; Indexed - ndirect Register (Pre_decement -2)
  cmpy #0x01234
  lbne FAIL
  cmps #0x01200
  lbne FAIL
  nop
  nop
  nop


  ; ----------------------------------------
  ; Test - Stores
  ; ----------------------------------------
  
  lda #$018  
  exg a,dp          ; Set the Direct Page
  SETDP 0x018       ; Tell the assembler about it
  
  ldy #$01A00       ; Store same pattern at 0x1800, 0x1900, 0x1A00 using each of the addressing modes
  lda #0x0AA
  sta <0x00
  sta >0x1900
  sta ,Y+
  ldb #0x0BB
  stb <0x01
  stb >0x1901
  stb ,Y+
  ldd #0x0D00D
  std <0x02
  std >0x1902
  std ,Y++
  lds #0x05005
  sts <0x04
  sts >0x1904
  sts ,Y++
  ldu #0x06006
  stu <0x06
  stu >0x1906
  stu ,Y++
  ldx #0x01001
  stx <0x08
  stx >0x1908
  stx ,Y++
  
  ldb #0x00
  ldd #0x00
  lds #0x00
  ldu #0x00
  ldx #0x00
  ldy #0x00
   
  lda <0x00
  cmpa #$0AA
  lbne FAIL 
  lda #0x00
  lda >0x1900
  cmpa #$0AA
  lbne FAIL 
   
  ldb <0x01
  cmpb #$0BB
  lbne FAIL 
  ldb #0x00
  ldb >0x1901
  cmpb #$0BB
  lbne FAIL 

   
  ldd <0x02
  cmpd #$0D00D
  lbne FAIL 
  ldd #0x00
  ldd >0x1902
  cmpd #$0D00D
  lbne FAIL 
   
  lds <0x04
  cmps #$05005
  lbne FAIL 
  lds #0x00
  lds >0x1904
  cmps #$05005
  lbne FAIL 
   
  ldu <0x06
  cmpu #0x06006
  lbne FAIL 
  ldu #0x00
  ldu >0x1906
  cmpu #0x06006
  lbne FAIL 
   
  ldx <0x08
  cmpx #$01001
  lbne FAIL 
  ldx #0x00
  ldx >0x1908
  cmpx #$01001
  lbne FAIL 
  
  ; LEA tests
  ldy #0x01234
  leas ,Y
  cmps #0x01234
  lbne FAIL 
  leau ,Y
  cmpu #0x01234
  lbne FAIL 
  leax ,Y
  cmpx #0x01234
  lbne FAIL 
  ldx #0x01234
  leay ,X
  cmpy #0x01234
  lbne FAIL 
  

;-----------------------------------------------------------
;-----------------------------------------------------------  


; Test brsnche and jump opcodes
; ----------------------------------------------------------------------
op_BRANCHES_JUMPS   
  nop
  nop
  nop
  
  bra BRANCHES_JUMPS_START

LOCAL_FAIL  
  jmp LOCAL_FAIL
  
SUBROUTINE_TEST
  nop
  nop
  rts
  
  
BRANCHES_JUMPS_START
  
  ; Branches - set CC manually then test branch
  
  andcc #0x0F0      ; Clear arithmetic flags
  lbmi FAIL         ; branch if N=1    
  lbeq FAIL         ; branch if Z=1    
  lbvs FAIL         ; branch if V=1    
  lbcs FAIL         ; branch if C=1    
  
  bmi LOCAL_FAIL    ; branch if N=1    
  beq LOCAL_FAIL    ; branch if Z=1    
  bvs LOCAL_FAIL    ; branch if V=1    
  bcs LOCAL_FAIL    ; branch if C=1    
    
  orcc #0x00F       ; Set arithmetic flags
  lbpl FAIL         ; branch if N=0    
  lbne FAIL         ; branch if Z=0    
  lbvc FAIL         ; branch if V=0    
  lbcc FAIL         ; branch if C=0    
  
  bpl LOCAL_FAIL    ; branch if N=0    
  bne LOCAL_FAIL    ; branch if Z=0    
  bvc LOCAL_FAIL    ; branch if V=0    
  bcc LOCAL_FAIL    ; branch if C=0    
  
  blt LOCAL_FAIL    ; branch if flag_n!=flag_v    
  lblt LOCAL_FAIL      
    
  bgt LOCAL_FAIL    ; branch if (flag_n==flag_v) && (flag_z==0)    
  lbgt LOCAL_FAIL       
   
  andcc #0x0F7      ; Clear n flag
  bge LOCAL_FAIL    ; branch if flag_n==flag_v    
  lbge LOCAL_FAIL      
     
  orcc #0x001       ; Set c flag
  bhi LOCAL_FAIL    ; branch if (flag_z==0) && (flag_c==0)    
  lbhi LOCAL_FAIL      
  
  andcc #0x0F8      ; Clear z,v,c flags
  ble LOCAL_FAIL    ; branch if (flag_n!=flag_v) || (flag_z==1)   
  lble LOCAL_FAIL      
    
  bls LOCAL_FAIL    ; branch if (flag_z!=0) || (flag_c!=0)    
  lbls LOCAL_FAIL      
       
  lbra BRANCHES_CONTINUE

LOCAL_FAIL2  
  jmp LOCAL_FAIL2
  
BRANCHES_CONTINUE
  brn  LOCAL_FAIL2
  lbrn LOCAL_FAIL2
  
  bsr  SUBROUTINE_TEST  ; Branch Subroutine
  jsr  SUBROUTINE_TEST  ; Jump Subroutine
  lbsr SUBROUTINE_TEST  ; Long Branch Subroutine
  
  
  


;-----------------------------------------------------------
;-----------------------------------------------------------  

  
; Test - Addition and subtraction 
; ----------------------------------------------------------------------
op_ADD_SUB   
  nop
  nop
  nop
  
  lda #$012  
  exg a,dp          ; Set the Direct Page
  SETDP 0x012       ; Tell the assembler about it

; Addition
; ------------

  ldx #0x01234
  ldb #0x02
  abx
  cmpx #0x01236
  lbne FAIL 
    
  lda #0x02         ; ADDA Immediate
  adda #0x02
  cmpa #0x004
  lbne FAIL 
      
  lda #0x02         ; ADDA Direct
  adda <$034
  cmpa #0x014
  lbne FAIL 
     
  ldx #0x01200      ; ADDA Indexed
  lda #0x02
  adda ,X
  cmpa #0x014
  lbne FAIL 
      
  lda #0x02         ; ADDA Extended
  adda >$01234
  cmpa #0x014
  lbne FAIL 
  
  
  ldb #0x02         ; ADDB Immediate
  addb #0x02
  cmpb #0x004
  lbne FAIL 
      
  ldb #0x02         ; ADDB Direct
  addb <$034
  cmpb #0x014
  lbne FAIL 
     
  ldx #0x01200      ; ADDB Indexed
  ldb #0x02
  addb ,X
  cmpb #0x014
  lbne FAIL 
      
  ldb #0x02         ; ADDB Extended
  addb >$01234
  cmpb #0x014
  lbne FAIL 
  

  ldd #0x01002      ; ADDD Immediate
  addd #0x02
  cmpd #0x01004
  lbne FAIL 
      
  ldd #0x01002      ; ADDD Direct
  addd <$034
  cmpd #0x02236
  lbne FAIL 
     
  ldx #0x01200      ; ADDD Indexed
  ldd #0x02
  addd ,X
  cmpd #0x01236
  lbne FAIL 
      
  ldd #0x02         ; ADDD Extended
  addd >$01234
  cmpd #0x01236
  lbne FAIL 
  
  

  lda #0x02         ; ADCA Immediate
  orcc #0x001       ; Set Carry flag
  adca #0x02
  cmpa #0x005
  lbne FAIL 
      
  lda #0x02         ; ADCA Direct
  orcc #0x001       ; Set Carry flag
  adca <$034
  cmpa #0x015
  lbne FAIL 
     
  ldx #0x01200      ; ADCA Indexed
  lda #0x02
  orcc #0x001       ; Set Carry flag
  adca ,X
  cmpa #0x015
  lbne FAIL 
      
  lda #0x02         ; ADCA Extended
  orcc #0x001       ; Set Carry flag
  adca >$01234
  cmpa #0x015
  lbne FAIL 
  
    

  ldb #0x02         ; ADCB Immediate
  orcc #0x001       ; Set Carry flag
  adcb #0x02
  cmpb #0x005
  lbne FAIL 
      
  ldb #0x02         ; ADCB Direct
  orcc #0x001       ; Set Carry flag
  adcb <$034
  cmpb #0x015
  lbne FAIL 
     
  ldx #0x01200      ; ADCB Indexed
  ldb #0x02
  orcc #0x001       ; Set Carry flag
  adcb ,X
  cmpb #0x015
  lbne FAIL 
      
  ldb #0x02         ; ADCB Extended
  orcc #0x001       ; Set Carry flag
  adcb >$01234
  cmpb #0x015
  lbne FAIL 
  
  
; Subtraction
; ------------

  lda #0x02         ; SUBA Immediate
  suba #0x02
  cmpa #0x00
  lbne FAIL 
      
  lda #0x12         ; SUBA Direct
  suba <$034
  cmpa #0x000
  lbne FAIL 
     
  ldx #0x01200      ; SUBA Indexed
  lda #0x012
  suba ,X
  cmpa #0x000
  lbne FAIL 
      
  lda #0x012        ; SUBA Extended
  suba >$01234
  cmpa #0x000
  lbne FAIL 
  
  
  ldb #0x02         ; SUBB Immediate
  subb #0x02
  cmpb #0x000
  lbne FAIL 
      
  ldb #0x012        ; SUBB Direct
  subb <$034
  cmpb #0x00
  lbne FAIL 
     
  ldx #0x01200      ; SUBB Indexed
  ldb #0x012
  subb ,X
  cmpb #0x00
  lbne FAIL 
      
  ldb #0x012        ; SUBB Extended
  subb >$01234
  cmpb #0x00
  lbne FAIL 
  

  ldd #0x01234      ; SUBD Immediate
  subd #0x01234
  cmpd #0x00
  lbne FAIL 
      
  ldd #0x01234      ; SUBD Direct
  subd <$034
  cmpd #0x00
  lbne FAIL 
     
  ldx #0x01234      ; SUBD Indexed
  ldd #0x01234
  subd ,X
  cmpd #0x00
  lbne FAIL 
      
  ldd #0x01234      ; SUBD Extended
  subd >$01234
  cmpd #0x00
  lbne FAIL 
  
  

  lda #0x03         ; SBCA Immediate
  orcc #0x001       ; Set Carry flag
  sbca #0x02
  cmpa #0x000
  lbne FAIL 
      
  lda #0x013        ; SBCA Direct
  orcc #0x001       ; Set Carry flag
  sbca <$034
  cmpa #0x00
  lbne FAIL 
     
  ldx #0x01200      ; SBCA Indexed
  lda #0x013
  orcc #0x001       ; Set Carry flag
  sbca ,X
  cmpa #0x000
  lbne FAIL 
      
  lda #0x013        ; SBCA Extended
  orcc #0x001       ; Set Carry flag
  sbca >$01234
  cmpa #0x00
  lbne FAIL 
  
    

  ldb #0x03         ; SBCB Immediate
  orcc #0x001       ; Set Carry flag
  sbcb #0x02
  cmpb #0x000
  lbne FAIL 
      
  ldb #0x013        ; SBCB Direct
  orcc #0x001       ; Set Carry flag
  sbcb <$034
  cmpb #0x00
  lbne FAIL 
     
  ldx #0x01200      ; SBCB Indexed
  ldb #0x013
  orcc #0x001       ; Set Carry flag
  sbcb ,X
  cmpb #0x000
  lbne FAIL 
      
  ldb #0x013        ; SBCB Extended
  orcc #0x001       ; Set Carry flag
  sbcb >$01234
  cmpb #0x00
  lbne FAIL 
  
  
                    ; ADDA Flags check
  lda #0x00         
  adda #0x00        ; Expected: n=0  z=1  v=0  c=0
  lbmi FAIL         ; branch if N=1    
  lbne FAIL         ; branch if Z=0    
  lbvs FAIL         ; branch if V=1    
  lbcs FAIL         ; branch if C=1  
  
  lda #0xFE         
  adda #0x01        ; Expected: n=1  z=0  v=0  c=0
  lbpl FAIL         ; branch if N=0    
  lbeq FAIL         ; branch if Z=1    
  lbvs FAIL         ; branch if V=1    
  lbcs FAIL         ; branch if C=1      
  
  lda #0x7E         
  adda #0x03        ; Expected: v=1
  lbvc FAIL         ; branch if V=0    
    
  lda #0xFE         
  adda #0x03        ; Expected: c=1
  lbcc FAIL         ; branch if C=0    
   
  
  
                    ; SUBA Flags check
  lda #0x00         
  suba #0x00        ; Expected: n=0  z=1  v=0  c=0
  lbmi FAIL         ; branch if N=1    
  lbne FAIL         ; branch if Z=0    
  lbvs FAIL         ; branch if V=1    
  lbcs FAIL         ; branch if C=1  
  
  lda #0xFE         
  suba #0x01        ; Expected: n=1  z=0  v=0  c=0
  lbpl FAIL         ; branch if N=0    
  lbeq FAIL         ; branch if Z=1    
  lbvs FAIL         ; branch if V=1    
  lbcs FAIL         ; branch if C=1      
  
  lda #0x7E         
  suba #0x03        ; Expected: v=0
  lbvs FAIL         ; branch if V=1    
    
  lda #0xFE         
  suba #0x03        ; Expected: c=0
  lbcs FAIL         ; branch if C=1      
   

  ; Comparisons
  ; --------------
  
  ; Immediate
  ; ---------
  lda #0x080        ; Checking opcode support - flags already checked with SUB tests
  cmpa #0x080
  lbne FAIL 
  
  ldb #0x080
  cmpb #0x080
  lbne FAIL 
   
  ldd #0x01111
  cmpd #0x01111
  lbne FAIL 
   
  lds #0x02222
  cmps #0x02222
  lbne FAIL 
   
  ldu #0x03333
  cmpu #0x03333
  lbne FAIL 
   
  ldx #0x04444
  cmpx #0x04444
  lbne FAIL 
   
  ldy #0x05555
  cmpy #0x05555
  lbne FAIL 

  
  ; Direct  
  ; ----------
  lda #$012  
  exg a,dp          ; Set the Direct Page
  SETDP 0x012       ; Tell the assembler about it
  
  lda #$012  
  cmpa <0x034
  lbne FAIL
    
  ldb #$012  
  cmpb <0x034
  lbne FAIL
    
  ldd #$01234    
  cmpd <0x034
  lbne FAIL
    
  ldu #$01234    
  cmpu <0x034
  lbne FAIL
  
  lds #$01234    
  cmps <0x034
  lbne FAIL
    
  ldx #$01234    
  cmpx <0x034
  lbne FAIL
  
  ldy #$01234    
  cmpy <0x034
  lbne FAIL
       
    
  ; Indexed
  ; --------
    

  ldx #0x01234  
  
  lda #0x012
  cmpa ,X
  lbne FAIL 
    
  ldb #0x012
  cmpb ,X
  lbne FAIL 
    
  ldd #0x01234
  cmpd ,X
  lbne FAIL 
      
  lds #0x01234
  cmps ,X
  lbne FAIL 
      
  ldu #0x01234
  cmpu ,X
  lbne FAIL 
      
  ldy #0x01234
  cmpy ,X
  lbne FAIL 
      
  ldy #0x01234  
  ldx #0x01234
  cmpx ,Y
  lbne FAIL 
      
      
  ; Extended Direct                 
  ; -----------------
  lda #$012 
  cmpa >0x01234
  lbne FAIL
  
  ldb #$012 
  cmpb >0x01234
  lbne FAIL
    
  ldd #$01234   
  cmpd >0x01234
  lbne FAIL
    
  ldu #$01234   
  cmpu >0x01234
  lbne FAIL
    
  lds #$01234   
  cmps >0x01234
  lbne FAIL
    
  ldx #$01234   
  cmpx >0x01234
  lbne FAIL
    
  ldy #$01234   
  cmpy >0x01234
  lbne FAIL
  

   

  ; Increment
  ; ---------
  lda #$012 
  inca
  cmpa #0x013
  lbne FAIL
  
  ldb #$022 
  incb
  cmpb #0x023
  lbne FAIL
   
  lda #$012  
  exg a,dp          ; Set the Direct Page
  SETDP 0x012       ; Tell the assembler about it
  
  inc <0x060
  ldb <0x060
  cmpb #0x034
  lbne FAIL
  
  ldx #0x01260   
  lda #0x012
  inc ,X
  ldb <0x060
  cmpb #0x035
  lbne FAIL    

  inc >0x01260
  ldb <0x060
  cmpb #0x036
  lbne FAIL     
  
  ; Flags check
  ; -----------
  lda #$07F 
  inca
  lbvc FAIL         ; branch if V=0    
  lbpl FAIL         ; branch if N=0    
  lbeq FAIL         ; branch if Z=1    
  
  ; Decrement
  ; ---------
  lda #$012 
  deca
  cmpa #0x011
  lbne FAIL
  
  ldb #$022 
  decb
  cmpb #0x021
  lbne FAIL
   
  lda #$012  
  exg a,dp          ; Set the Direct Page
  SETDP 0x012       ; Tell the assembler about it
  
  dec <0x060
  ldb <0x060
  cmpb #0x035
  lbne FAIL
  
  ldx #0x01260   
  lda #0x012
  dec ,X
  ldb <0x060
  cmpb #0x034
  lbne FAIL    

  dec >0x01260
  ldb <0x060
  cmpb #0x033
  lbne FAIL     
  
  
  ; Flags check
  ; -----------
  lda #$080 
  deca
  lbvc FAIL         ; branch if V=0    
  lbmi FAIL         ; branch if N=1    
  lbeq FAIL         ; branch if Z=1    
    


;-----------------------------------------------------------
;-----------------------------------------------------------  

  
; Test - Boolean Bit and Test
;-----------------------------------------------------------  
  
  ; ---
  ; AND
  ; ---

  lda #0x0088                           ; Immediate
  anda #0x0F0
  lbvs FAIL         ; branch if V=1    
  lbpl FAIL         ; branch if N=0   
  lbeq FAIL         ; branch if Z=1    
  cmpa #0x080
  lbne FAIL  
  
  ldb #0x005A   
  andb #0x00F
  lbvs FAIL         ; branch if V=1    
  lbmi FAIL         ; branch if N=1    
  lbeq FAIL         ; branch if Z=1    
  cmpb #0x00A
  lbne FAIL
    
    
  andcc #0x000
  lbvs FAIL         ; branch if V=1    
  lbmi FAIL         ; branch if N=1    
  lbeq FAIL         ; branch if Z=1    
  orcc #0x00F
  lbvc FAIL         ; branch if V=0    
  lbpl FAIL         ; branch if N=0    
  lbne FAIL         ; branch if Z=0       

  
  lda #0x00F                            ; Direct
  anda <$034
  lbvs FAIL         ; branch if V=1    
  lbmi FAIL         ; branch if N=1    
  lbeq FAIL         ; branch if Z=1    
  cmpa #0x002
  lbne FAIL  
  
  lda #0x00F                            ; Indexed
  ldx #0x01200       
  anda ,X
  lbvs FAIL         ; branch if V=1    
  lbmi FAIL         ; branch if N=1    
  lbeq FAIL         ; branch if Z=1    
  cmpa #0x002
  lbne FAIL  
  
  lda #0x00F                            ; Extended
  ldx #0x01200       
  anda >$01234
  lbvs FAIL         ; branch if V=1    
  lbmi FAIL         ; branch if N=1    
  lbeq FAIL         ; branch if Z=1    
  cmpa #0x002
  lbne FAIL  
  
        
  
  ldb #0x00F                            ; Direct
  andb <$034
  lbvs FAIL         ; branch if V=1    
  lbmi FAIL         ; branch if N=1    
  lbeq FAIL         ; branch if Z=1    
  cmpb #0x002
  lbne FAIL  
  
  ldb #0x00F                            ; Indexed
  ldx #0x01200       
  andb ,X
  lbvs FAIL         ; branch if V=1    
  lbmi FAIL         ; branch if N=1    
  lbeq FAIL         ; branch if Z=1    
  cmpb #0x002
  lbne FAIL  
  
  ldb #0x00F                            ; Extended
  ldx #0x01200       
  andb >$01234
  lbvs FAIL         ; branch if V=1    
  lbmi FAIL         ; branch if N=1    
  lbeq FAIL         ; branch if Z=1    
  cmpb #0x002
  lbne FAIL  
  
        

  ; ---
  ; OR
  ; ---

  lda #0x000A                           ; Immediate
  ora #0x050
  lbvs FAIL         ; branch if V=1    
  lbmi FAIL         ; branch if N=1    
  lbeq FAIL         ; branch if Z=1    
  cmpa #0x5A
  lbne FAIL  
  
  ldb #0x00A0   
  orb #0x005
  lbvs FAIL         ; branch if V=1    
  lbpl FAIL         ; branch if N=0    
  lbeq FAIL         ; branch if Z=1    
  cmpb #0x0A5
  lbne FAIL
    
      
  orcc #0x00F
  lbvc FAIL         ; branch if V=0    
  lbpl FAIL         ; branch if N=0    
  lbne FAIL         ; branch if Z=0       

  
  lda #0x00F                            ; Direct
  ora <$034
  lbvs FAIL         ; branch if V=1    
  lbmi FAIL         ; branch if N=1    
  lbeq FAIL         ; branch if Z=1    
  cmpa #0x01F
  lbne FAIL  
  
  lda #0x00F                            ; Indexed
  ldx #0x01200       
  ora ,X
  lbvs FAIL         ; branch if V=1    
  lbmi FAIL         ; branch if N=1    
  lbeq FAIL         ; branch if Z=1    
  cmpa #0x01F
  lbne FAIL  
  
  lda #0x00F                            ; Extended
  ldx #0x01200       
  ora >$01234
  lbvs FAIL         ; branch if V=1    
  lbmi FAIL         ; branch if N=1    
  lbeq FAIL         ; branch if Z=1    
  cmpa #0x01F
  lbne FAIL  
    
  ldb #0x00F                            ; Direct
  orb <$034
  lbvs FAIL         ; branch if V=1    
  lbmi FAIL         ; branch if N=1    
  lbeq FAIL         ; branch if Z=1    
  cmpb #0x01F
  lbne FAIL  
  
  ldb #0x00F                            ; Indexed
  ldx #0x01200       
  orb ,X
  lbvs FAIL         ; branch if V=1    
  lbmi FAIL         ; branch if N=1    
  lbeq FAIL         ; branch if Z=1    
  cmpb #0x01F
  lbne FAIL  
  
  ldb #0x00F                            ; Extended
  ldx #0x01200       
  orb >$01234
  lbvs FAIL         ; branch if V=1    
  lbmi FAIL         ; branch if N=1    
  lbeq FAIL         ; branch if Z=1    
  cmpb #0x01F
  lbne FAIL  
  
        

        

  ; ----
  ; EOR
  ; ----

  lda #0x000A                           ; Immediate
  eora #0x050
  lbvs FAIL         ; branch if V=1    
  lbmi FAIL         ; branch if N=1    
  lbeq FAIL         ; branch if Z=1    
  cmpa #0x5A
  lbne FAIL  
  
  ldb #0x00A0   
  eorb #0x005
  lbvs FAIL         ; branch if V=1    
  lbpl FAIL         ; branch if N=0    
  lbeq FAIL         ; branch if Z=1    
  cmpb #0x0A5
  lbne FAIL
      
      
  lda #0x00F                            ; Direct
  eora <$034
  lbvs FAIL         ; branch if V=1    
  lbmi FAIL         ; branch if N=1    
  lbeq FAIL         ; branch if Z=1    
  cmpa #0x01D
  lbne FAIL  
  
  lda #0x00F                            ; Indexed
  ldx #0x01200       
  eora ,X
  lbvs FAIL         ; branch if V=1    
  lbmi FAIL         ; branch if N=1    
  lbeq FAIL         ; branch if Z=1    
  cmpa #0x01D
  lbne FAIL  
  
  lda #0x00F                            ; Extended
  ldx #0x01200       
  eora >$01234
  lbvs FAIL         ; branch if V=1    
  lbmi FAIL         ; branch if N=1    
  lbeq FAIL         ; branch if Z=1    
  cmpa #0x01D
  lbne FAIL  
    
  ldb #0x00F                            ; Direct
  eorb <$034
  lbvs FAIL         ; branch if V=1    
  lbmi FAIL         ; branch if N=1    
  lbeq FAIL         ; branch if Z=1    
  cmpb #0x01D
  lbne FAIL  
  
  ldb #0x00F                            ; Indexed
  ldx #0x01200       
  eorb ,X
  lbvs FAIL         ; branch if V=1    
  lbmi FAIL         ; branch if N=1    
  lbeq FAIL         ; branch if Z=1    
  cmpb #0x01D
  lbne FAIL  
  
  ldb #0x00F                            ; Extended
  ldx #0x01200       
  eorb >$01234
  lbvs FAIL         ; branch if V=1    
  lbmi FAIL         ; branch if N=1    
  lbeq FAIL         ; branch if Z=1    
  cmpb #0x01D
  lbne FAIL  
  
              

  ; ----
  ; BIT
  ; ----

  lda #0x0088                           ; Immediate
  bita #0x0F0
  lbvs FAIL         ; branch if V=1    
  lbpl FAIL         ; branch if N=0   
  lbeq FAIL         ; branch if Z=1    

  
  ldb #0x005A   
  bitb #0x00F
  lbvs FAIL         ; branch if V=1    
  lbmi FAIL         ; branch if N=1    
  lbeq FAIL         ; branch if Z=1    

    

  
  lda #0x00F                            ; Direct
  bita <$034
  lbvs FAIL         ; branch if V=1    
  lbmi FAIL         ; branch if N=1    
  lbeq FAIL         ; branch if Z=1    

  
  lda #0x00F                            ; Indexed
  ldx #0x01200       
  bita ,X
  lbvs FAIL         ; branch if V=1    
  lbmi FAIL         ; branch if N=1    
  lbeq FAIL         ; branch if Z=1    

  
  lda #0x00F                            ; Extended
  ldx #0x01200       
  bita >$01234
  lbvs FAIL         ; branch if V=1    
  lbmi FAIL         ; branch if N=1    
  lbeq FAIL         ; branch if Z=1    
 
         
  
  ldb #0x00F                            ; Direct
  bitb <$034
  lbvs FAIL         ; branch if V=1    
  lbmi FAIL         ; branch if N=1    
  lbeq FAIL         ; branch if Z=1    

  
  ldb #0x00F                            ; Indexed
  ldx #0x01200       
  bitb ,X
  lbvs FAIL         ; branch if V=1    
  lbmi FAIL         ; branch if N=1    
  lbeq FAIL         ; branch if Z=1    
 
  
  ldb #0x00F                            ; Extended
  ldx #0x01200       
  bitb >$01234
  lbvs FAIL         ; branch if V=1    
  lbmi FAIL         ; branch if N=1    
  lbeq FAIL         ; branch if Z=1    
 
  
  

  ; ----
  ; Test
  ; ----

  lda #0x0088                           ; Inherent
  tsta
  lbvs FAIL         ; branch if V=1    
  lbpl FAIL         ; branch if N=0   
  lbeq FAIL         ; branch if Z=1    
  
  ldb #0x0088                           ; Inherent
  tstb
  lbvs FAIL         ; branch if V=1    
  lbpl FAIL         ; branch if N=0   
  lbeq FAIL         ; branch if Z=1            
  
  tst <$034                             ; Direct
  lbvs FAIL         ; branch if V=1    
  lbmi FAIL         ; branch if N=1    
  lbeq FAIL         ; branch if Z=1    

  
  ldx #0x01200                          ; Indexed
  tst ,X
  lbvs FAIL         ; branch if V=1    
  lbmi FAIL         ; branch if N=1    
  lbeq FAIL         ; branch if Z=1    
 
  
  ldx #0x01200                          ; Extended
  tst >$01234
  lbvs FAIL         ; branch if V=1    
  lbmi FAIL         ; branch if N=1    
  lbeq FAIL         ; branch if Z=1    
 
  

  ; ----
  ; COM
  ; ----

  lda #0x0088                           ; Inherent
  coma
  lbvs FAIL         ; branch if V=1    
  lbcc FAIL         ; branch if C=0    
  lbmi FAIL         ; branch if N=1    
  lbeq FAIL         ; branch if Z=1  
  cmpa #0x077
  lbne FAIL    
  
  ldb #0x0088                           ; Inherent
  comb
  lbvs FAIL         ; branch if V=1    
  lbcc FAIL         ; branch if C=0    
  lbmi FAIL         ; branch if N=1    
  lbeq FAIL         ; branch if Z=1            
  cmpb #0x077
  lbne FAIL  
  
  com <$034                             ; Direct
  lbvs FAIL         ; branch if V=1    
  lbcc FAIL         ; branch if C=0    
  lbpl FAIL         ; branch if N=0   
  lbeq FAIL         ; branch if Z=1   
  lda <$034  
  cmpa #0x0ED
  lbne FAIL    
  com <$034                             ; Put back origial value

  
  ldx #0x01234                          ; Indexed
  com ,X                                 
  lbvs FAIL         ; branch if V=1    
  lbcc FAIL         ; branch if C=0    
  lbpl FAIL         ; branch if N=0   
  lbeq FAIL         ; branch if Z=1    
  lda ,X  
  cmpa ,X
  lbne FAIL    
  com ,X                                ; Put back origial value
 
  
  com >$01234                           ; Extended                   
  lbvs FAIL         ; branch if V=1    
  lbcc FAIL         ; branch if C=0    
  lbpl FAIL         ; branch if N=0   
  lbeq FAIL         ; branch if Z=1  
  lda >$01234  
  cmpa #0x0ED
  lbne FAIL  
  com >$01234                           ; Put back origial value
 

;-----------------------------------------------------------
;-----------------------------------------------------------  



; Test - Shifts
;-----------------------------------------------------------  

  ; ----
  ; ASL
  ; ----

  lda #0x0088                           ; Inherent
  asla
  lbvc FAIL         ; branch if V=0    
  lbcc FAIL         ; branch if C=0    
  lbmi FAIL         ; branch if N=1    
  lbeq FAIL         ; branch if Z=1  
  cmpa #0x010
  lbne FAIL    
  
  ldb #0x0088                           ; Inherent
  aslb
  lbvc FAIL         ; branch if V=0    
  lbcc FAIL         ; branch if C=0    
  lbmi FAIL         ; branch if N=1    
  lbeq FAIL         ; branch if Z=1  
  cmpb #0x010
  lbne FAIL   
  
  asl <$000                             ; Direct
  lbvs FAIL         ; branch if V=1    
  lbcs FAIL         ; branch if C=1      
  lbmi FAIL         ; branch if N=1    
  lbeq FAIL         ; branch if Z=1   
  lda <$000  
  cmpa #0x024
  lbne FAIL    
  com <$034                             ; Put back origial value

  
  ldx #0x01200                          ; Indexed
  asl ,X                                 
  lbvs FAIL         ; branch if V=1    
  lbcs FAIL         ; branch if C=1      
  lbmi FAIL         ; branch if N=1    
  lbeq FAIL         ; branch if Z=1    
  lda ,X  
  cmpa ,X
  lbne FAIL    
  com ,X                                ; Put back origial value
 
  
  asl >$01200                           ; Extended                   
  lbvc FAIL         ; branch if V=0    
  lbcc FAIL         ; branch if C=0    
  lbmi FAIL         ; branch if N=1    
  lbeq FAIL         ; branch if Z=1  
  lda >$01234  
  cmpa #0x0ED
  lbne FAIL  
  com >$01234                           ; Put back origial value
 


  ; ----
  ; ASR
  ; ----

  lda #0x0088                           ; Inherent
  asra
  lbcs FAIL         ; branch if C=1      
  lbpl FAIL         ; branch if N=0   
  lbeq FAIL         ; branch if Z=1  
  cmpa #0x0C4
  lbne FAIL    
  
  ldb #0x0088                           ; Inherent
  asrb
  lbcs FAIL         ; branch if C=1      
  lbpl FAIL         ; branch if N=0   
  lbeq FAIL         ; branch if Z=1  
  cmpb #0x0C4
  lbne FAIL   
  
  asr <$000                             ; Direct
  lbcs FAIL         ; branch if C=1      
  lbmi FAIL         ; branch if N=1    
  lbeq FAIL         ; branch if Z=1   
  lda <$000  
  cmpa #0x037
  lbne FAIL    
  com <$034                             ; Put back origial value

  
  ldx #0x01200                          ; Indexed
  asr ,X                                 
  lbcc FAIL         ; branch if C=0    
  lbmi FAIL         ; branch if N=1    
  lbeq FAIL         ; branch if Z=1    
  lda ,X  
  cmpa ,X
  lbne FAIL    
  com ,X                                ; Put back origial value
 
  
  asr >$01200                           ; Extended                   
  lbcs FAIL         ; branch if C=1      
  lbpl FAIL         ; branch if N=0   
  lbeq FAIL         ; branch if Z=1  
  lda >$01200  
  cmpa #0x0F2
  lbne FAIL  
  com >$01200                           ; Put back origial value
 

  ; ----
  ; LSR
  ; ----

  lda #0x0088                           ; Inherent
  lsra
  lbcs FAIL         ; branch if C=1      
  lbmi FAIL         ; branch if N=1    
  lbeq FAIL         ; branch if Z=1  
  cmpa #0x044
  lbne FAIL    
  
  ldb #0x0088                           ; Inherent
  lsrb
  lbcs FAIL         ; branch if C=1      
  lbmi FAIL         ; branch if N=1    
  lbeq FAIL         ; branch if Z=1  
  cmpb #0x044
  lbne FAIL   
  
  lsr <$000                             ; Direct
  lbcc FAIL         ; branch if C=0    
  lbmi FAIL         ; branch if N=1    
  lbeq FAIL         ; branch if Z=1   
  lda <$000  
  cmpa #0x006
  lbne FAIL    
  com <$034                             ; Put back origial value

  
  ldx #0x01200                          ; Indexed
  lsr ,X                                 
  lbcs FAIL         ; branch if C=1      
  lbmi FAIL         ; branch if N=1    
  lbeq FAIL         ; branch if Z=1    
  lda ,X  
  cmpa #0x003
  lbne FAIL    
  com ,X                                ; Put back origial value
 
  
  lsr >$01200                           ; Extended                   
  lbcs FAIL         ; branch if C=1      
  lbmi FAIL         ; branch if N=1    
  lbeq FAIL         ; branch if Z=1  
  lda >$01200  
  cmpa #0x07E
  lbne FAIL  
  com >$01200                           ; Put back origial value
 


  ; ----
  ; ROL
  ; ----

  lda #0x0088                           ; Inherent
  rola
  lbvc FAIL         ; branch if V=0    
  lbcc FAIL         ; branch if C=0    
  lbmi FAIL         ; branch if N=1    
  lbeq FAIL         ; branch if Z=1  
  cmpa #0x011
  lbne FAIL    
  
  ldb #0x0088                           ; Inherent
  rolb
  lbvc FAIL         ; branch if V=0    
  lbcc FAIL         ; branch if C=0    
  lbmi FAIL         ; branch if N=1    
  lbeq FAIL         ; branch if Z=1  
  cmpb #0x010
  lbne FAIL   
  
  rol <$000                             ; Direct
  lbvc FAIL         ; branch if V=0    
  lbcc FAIL         ; branch if C=0    
  lbmi FAIL         ; branch if N=1    
  lbeq FAIL         ; branch if Z=1   
  lda <$000  
  cmpa #0x002
  lbne FAIL    

  
  ldx #0x01200                          ; Indexed
  rol ,X                                 
  lbvs FAIL         ; branch if V=1    
  lbcs FAIL         ; branch if C=1      
  lbmi FAIL         ; branch if N=1    
  lbeq FAIL         ; branch if Z=1    
  lda ,X  
  cmpa #0x004
  lbne FAIL    
 
  
  rol >$01200                           ; Extended                   
  lbvs FAIL         ; branch if V=1    
  lbcs FAIL         ; branch if C=1      
  lbmi FAIL         ; branch if N=1    
  lbeq FAIL         ; branch if Z=1  
  lda >$01200  
  cmpa #0x008
  lbne FAIL  
 


  ; ----
  ; ROR
  ; ----

  lda #0x0088                           ; Inherent
  rora
  lbcs FAIL         ; branch if C=1      
  lbmi FAIL         ; branch if N=1    
  lbeq FAIL         ; branch if Z=1  
  cmpa #0x044
  lbne FAIL    
  
  ldb #0x0088                           ; Inherent
  rorb
  lbcs FAIL         ; branch if C=1      
  lbmi FAIL         ; branch if N=1    
  lbeq FAIL         ; branch if Z=1  
  cmpb #0x044
  lbne FAIL   
  
  ror <$000                             ; Direct
  lbcs FAIL         ; branch if C=1      
  lbmi FAIL         ; branch if N=1    
  lbeq FAIL         ; branch if Z=1   
  lda <$000  
  cmpa #0x004
  lbne FAIL    

  
  ldx #0x01200                          ; Indexed
  ror ,X                                 
  lbcs FAIL         ; branch if C=1      
  lbmi FAIL         ; branch if N=1    
  lbeq FAIL         ; branch if Z=1    
  lda ,X  
  cmpa #0x002
  lbne FAIL    
 
  
  ror >$01200                           ; Extended                   
  lbcs FAIL         ; branch if C=1      
  lbmi FAIL         ; branch if N=1    
  lbeq FAIL         ; branch if Z=1  
  lda >$01200  
  cmpa #0x001
  lbne FAIL  
 


  
  ; ----
  ; LSR
  ; ----
  
  ldy #0x01234
  sty >$01200   

  lda #0x0088                           ; Inherent
  lsra
  lbcs FAIL         ; branch if C=1      
  lbmi FAIL         ; branch if N=1    
  lbeq FAIL         ; branch if Z=1  
  cmpa #0x044
  lbne FAIL    
  
  ldb #0x0088                           ; Inherent
  lsrb
  lbcs FAIL         ; branch if C=1      
  lbmi FAIL         ; branch if N=1    
  lbeq FAIL         ; branch if Z=1  
  cmpb #0x044
  lbne FAIL   
  
  lsr <$000                             ; Direct
  lbcs FAIL         ; branch if C=1      
  lbmi FAIL         ; branch if N=1    
  lbeq FAIL         ; branch if Z=1  
  lda <$000  
  cmpa #0x009
  lbne FAIL    
  com <$044                             ; Put back origial value

  
  ldx #0x01200                          ; Indexed
  lsr ,X                                 
  lbcc FAIL         ; branch if C=0    
  lbmi FAIL         ; branch if N=1    
  lbeq FAIL         ; branch if Z=1    
  lda ,X  
  cmpa #0x004
  lbne FAIL    
  com ,X                                ; Put back origial value
 
  
  lsr >$01200                           ; Extended                   
  lbcc FAIL         ; branch if C=0    
  lbmi FAIL         ; branch if N=1    
  lbeq FAIL         ; branch if Z=1  
  lda >$01200  
  cmpa #0x07D
  lbne FAIL  
  com >$01200                           ; Put back origial value
 


;-----------------------------------------------------------
;-----------------------------------------------------------  



; Test - Math
;-----------------------------------------------------------  

  ; ----
  ; CLR
  ; ----
  lda #0x088
  clra
  lbmi FAIL         ; branch if N=1    
  lbne FAIL         ; branch if Z=0  
  lbvs FAIL         ; branch if V=1    
  lbcs FAIL         ; branch if C=1      
  cmpa #0x000
  lbne FAIL  
  
  ldb #0x05A
  clrb
  cmpb #0x000
  lbne FAIL  
  
  com <$000                  ; Direct
  clr <$000                
  lda >$01200
  cmpa #0x000
  lbne FAIL  

    
  ldy #0x01200              ; Indexed
  com >$01200       
  clr ,Y        
  lda >$01200
  cmpa #0x000
  lbne FAIL  

    
  com >$01200               ; Extended
  clr >$01200               
  lda >$01200
  cmpa #0x000
  lbne FAIL  


  ; ----
  ; DAA
  ; ----
  
  ldd #0x0
  ldy #0x0FF00
  sty >$01200               
DAA_LOOP
  lda >$01200
  daa
  adda >$01201
  sta >$01201
  dec >$01200               
  bne DAA_LOOP
  
  lda >$01201
  cmpa #0x08A
  lbne FAIL  




  ; ----
  ; EXG
  ; ----
  
  lda #0x0AA
  ldb #0x0BB
  exg a,b
  cmpa #0x0BB
  lbne FAIL  
  cmpb #0x0AA
  lbne FAIL  
  
  ldx #0x0AAAA
  ldy #0x0BBBB
  exg x,y
  cmpx #0x0BBBB
  lbne FAIL  
  cmpy #0x0AAAA
  lbne FAIL  
  
  ldu #0x01111
  lds #0x02222
  exg u,s
  cmpu #0x02222
  lbne FAIL  
  cmps #0x01111
  lbne FAIL  

  exg u,x
  cmpu #0x0BBBB
  lbne FAIL  
  cmpx #0x02222
  lbne FAIL  
  
  exg s,y
  cmps #0x0AAAA
  lbne FAIL  
  cmpy #0x01111
  lbne FAIL  
  
  exg x,u
  cmpx #0x0BBBB
  lbne FAIL  
  cmpu #0x02222
  lbne FAIL  
  
  exg y,s
  cmpy #0x0AAAA
  lbne FAIL  
  cmps #0x01111
  lbne FAIL  
  
  
  ; ----
  ; TFR
  ; ----
  
  tfr a,b
  cmpb #0x0BB
  lbne FAIL 
  
  tfr x,y
  cmpy #0x0BBBB
  lbne FAIL 
  
  tfr u,s
  cmps #0x02222
  lbne FAIL 
    

  ; ----
  ; NEG
  ; ----

  lda #0x0088                           ; Inherent
  nega
  lbvs FAIL         ; branch if V=1    
  lbcc FAIL         ; branch if C=0    
  lbmi FAIL         ; branch if N=1    
  lbeq FAIL         ; branch if Z=1  
  cmpa #0x078
  lbne FAIL    
  
  ldb #0x0088                           ; Inherent
  negb
  lbvs FAIL         ; branch if V=1    
  lbcc FAIL         ; branch if C=0    
  lbmi FAIL         ; branch if N=1    
  lbeq FAIL         ; branch if Z=1            
  cmpb #0x078
  lbne FAIL  
  
  neg <$034                             ; Direct
  lbvs FAIL         ; branch if V=1    
  lbcc FAIL         ; branch if C=0    
  lbpl FAIL         ; branch if N=0   
  lbeq FAIL         ; branch if Z=1   
  lda <$034  
  cmpa #0x0EE
  lbne FAIL    
  com <$034                             ; Put back origial value

  
  ldx #0x01234                          ; Indexed
  neg ,X                                 
  lbvs FAIL         ; branch if V=1    
  lbcc FAIL         ; branch if C=0    
  lbpl FAIL         ; branch if N=0   
  lbeq FAIL         ; branch if Z=1    
  lda ,X  
  cmpa #0x0EF
  lbne FAIL    
  neg ,X                                ; Put back origial value
 
  
  neg >$01234                           ; Extended                   
  lbvs FAIL         ; branch if V=1    
  lbcc FAIL         ; branch if C=0    
  lbpl FAIL         ; branch if N=0   
  lbeq FAIL         ; branch if Z=1  
  lda >$01234  
  cmpa #0x0EF
  lbne FAIL  
  neg >$01234                           ; Put back origial value
 


  ; ----
  ; MUL
  ; ----
  
  ldd #0x0
  ldy #0x0FF00
  sty >$01200               
MUL_LOOP
  ldd >$01200
  mul
  addd >$01202
  std >$01202
  inc >$01201               
  dec >$01200               
  bne MUL_LOOP
  
  ldd >$01202
  cmpd #0x02B00
  lbne FAIL  
  
  
  
  ; ----
  ; SEX
  ; ----
  
  ldb #0x07F
  sex
  cmpa #0x00
  lbne FAIL    
    
  ldb #0x080
  sex
  cmpa #0x0FF
  lbne FAIL    
  
;-----------------------------------------------------------
;-----------------------------------------------------------  



; Test - Stack
;-----------------------------------------------------------  
  
  ; System Stack starts at  0xF100
  ; User Stack starts at    0xF200

  lda #0x0AA
  ldb #0x0BB
  ldx #0x01234
  ldy #0x05678
  lds #0x0F100
  ldu #0x0F200
  pshs #0x03E
  pshu #0x03E

  lda >$0F1F9       ; register_A
  cmpa #0x0AA
  lbne FAIL  
  lda >$0F1FA       ; register_B
  cmpa #0x0BB
  lbne FAIL  
  lda >$0F1FB       ; register_DP
  cmpa #0x012
  lbne FAIL  
  ldx >$0F1FC       ; register_X
  cmpx #0x01234
  lbne FAIL  
  ldx >$0F1FE       ; register_Y
  cmpx #0x05678
  lbne FAIL  
  

  lda #0x00
  ldb #0x00
  ldx #0x00
  ldy #0x00
  
  puls #0x03E
  pulu #0x03E
        
  cmpa #0x0AA       ; register_A
  lbne FAIL     
                
  cmpb #0x0BB       ; register_B
  lbne FAIL     
                
  cmpx #0x01234     ; register_X
  lbne FAIL     
                
  cmpy #0x05678     ; register_Y
  lbne FAIL  
  
  nop
  nop
  
  
;-----------------------------------------------------------
;-----------------------------------------------------------  



; Test - Traps, Interrupts
;-----------------------------------------------------------  
  
  
  lda #0x0AA
  ldb #0x0BB
  ldx #0x01234
  ldy #0x05678
  
  swi
  cmpa #0x0AA
  lbne FAIL  
  cmpb #0x0BB
  lbne FAIL  
  cmpx #0x01234
  lbne FAIL  
  cmpy #0x05678  
  lbne FAIL  
  nop
  nop
  nop
    
  swi2
  cmpa #0x0AA
  lbne FAIL  
  cmpb #0x0BB
  lbne FAIL  
  cmpx #0x01234
  lbne FAIL  
  cmpy #0x05678  
  lbne FAIL  
  nop
  nop
  nop
    
  swi3
  cmpa #0x0AA
  lbne FAIL  
  cmpb #0x0BB
  lbne FAIL  
  cmpx #0x01234
  lbne FAIL  
  cmpy #0x05678  
  lbne FAIL  
  nop
  nop
  nop
  
  ;sync

  ;cwai #0x66
  
  
  jmp ALL_DONE
   
;-----------------------------------------------------------
;-----------------------------------------------------------  
; Loop here when all tests pass
;
ALL_DONE  
  mul
  jmp ALL_DONE  
  
; Loop here when any test fails
;
FAIL  
  jmp FAIL






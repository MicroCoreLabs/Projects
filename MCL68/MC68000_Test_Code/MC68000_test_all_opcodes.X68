*
*
*  File Name   :  MCL68 Opcode Tests
*  Used on     :  
*  Author      :  Ted Fried, MicroCore Labs
*  Creation    :  7/14/2020
*
*   Description:
*   ============
*   
*  Program to test all of the Motorola 68000's opcodes.
*
*  If failures are detected, the code will immediately loop on itself.
*  All addressing modes, data sizes, and opcode combinations are tested.
*
*  This code was developed using the Easy68K simulator where all tests passed!
*
*------------------------------------------------------------------------
*
* Modification History:
* =====================
*
* Revision 1 7/14/2020 
* Initial revision
*
*
*------------------------------------------------------------------------
*
* Copyright (c) 2020 Ted Fried
* 
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
* 
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
* 
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
* SOFTWARE.
*


* Populate Exception Vectors
*
  ORG $00000   
  dc.l    $000003F0  * Vector = 0   Reset Supervisor Stack Pointer
  dc.l    $00000400  * Vector = 1   Reset Initial PC
  dc.l    $22222222  * Vector = 2   Bus Error
  dc.l    $30303033  * Vector = 3   Address Error
  dc.l    $44444444  * Vector = 4   Illegal Instruction
  dc.l    $55555555  * Vector = 5   Zero Divide
  dc.l    $0000F010  * Vector = 6   CHK Instruction
  dc.l    $0000F020  * Vector = 7   TRAPV Instruction
  dc.l    $88888888  * Vector = 8   Privilege Violation 
  dc.l    $99999999  * Vector = 9   Trace
  dc.l    $aaaaaaaa  * Vector = 10  Line A Emulator
  dc.l    $bbbbbbbb  * Vector = 11  Line F Emulator
  
  ORG $00060   
  dc.l    $12121212  * Vector = 24  Spurrious Interrupt
  dc.l    $11111111  * Vector = 25  Level 1 Interrupt Autovector
  dc.l    $22222222  * Vector = 26  Level 2 Interrupt Autovector
  dc.l    $33333333  * Vector = 27  Level 3 Interrupt Autovector
  dc.l    $44444444  * Vector = 28  Level 4 Interrupt Autovector
  dc.l    $55555555  * Vector = 29  Level 5 Interrupt Autovector
  dc.l    $66666666  * Vector = 30  Level 6 Interrupt Autovector
  dc.l    $77777777  * Vector = 31  Level 7 Interrupt Autovector
  

* Loop here when all tests pass
*
  ORG $00F000 
ALL_DONE: bra ALL_DONE

 
* Exception Vector = 6   CHK Instruction
*
  ORG $00F010 
  
EXCEPTION_6:
            move.l #$EEEE0006 , d6      * Set d6 to the exception vector 
            rte
          

 
* Exception Vector = 7   TRAPV Instruction
*
  ORG $00F020 
  
EXCEPTION_7:
            move.l #$12345678 , d0      * Set d6 to the exception vector 
            rte
          


* Beginning of opcode tests
*
START   ORG $000400 

   move.l #$000003F0  , a7      * populate stack pointer


   jsr op_ORI_TO_CCR
   jsr op_ORI_TO_SR
   jsr op_EORI_TO_CCR
   jsr op_EORI_TO_SR
   jsr op_ANDI_TO_CCR
   jsr op_ANDI_TO_SR
   jsr op_BTST
   jsr op_BCHG
   jsr op_BCLR
   jsr op_BSET
   jsr op_MOVEP
   jsr op_BOOL_I
   jsr op_CMP_I
   jsr op_ADD_I
   jsr op_SUB_I
   jsr op_MOVE
   jsr op_MOVE_xxx_FLAGS
   jsr op_EXT
   jsr op_SWAP
   jsr op_LEAPEA 
   jsr op_TAS 
   jsr op_TST 
   jsr op_LINKS 
   jsr op_MOVE_USP
   jsr op_CHK
   jsr op_NEGS
   jsr op_MOVEM
   jsr op_ABCD
   jsr op_SBCD
   jsr op_NBCD
   jsr op_TRAPV
   jsr op_RTR
   jsr op_BSR
   jsr op_BCC
   jsr op_DBCC
   jsr op_SCC
   jsr op_ADDQ
   jsr op_SUBQ
   jsr op_MOVEQ
   jsr op_DIVU
   jsr op_DIVS
   jsr op_OR
   jsr op_AND
   jsr op_EOR
   jsr op_CMP
   jsr op_CMPA
   jsr op_CMPM
   jsr op_ADD
   jsr op_SUB
   jsr op_ADDA
   jsr op_SUBA
   jsr op_ADDX
   jsr op_SUBX
   jsr op_MULU
   jsr op_MULS
   jsr op_EXG
   jsr op_ROx
   jsr op_ROXx
   jsr op_SHIFTS
   jsr op_SHIFTS2
   
   jmp ALL_DONE

   

BSR_FAR1:       move.l #$33333333 , d3
                rts

*-----------------------------------------------------------
*-----------------------------------------------------------
* OPCODE : ORI_TO_CCR
*-----------------------------------------------------------
*-----------------------------------------------------------
op_ORI_TO_CCR: 

    ori.b #$FF, CCR
    bpl ORI_TO_CCR_FAIL     * branch if Z clear  
    bne ORI_TO_CCR_FAIL     * branch if N clear
    bvc ORI_TO_CCR_FAIL     * branch if V clear 
    bcc ORI_TO_CCR_FAIL     * branch if C clear 
    
    move #$00, CCR
    ori.b #$00, CCR
    beq ORI_TO_CCR_FAIL     * branch if Z set  
    bmi ORI_TO_CCR_FAIL     * branch if N set  
    bvs ORI_TO_CCR_FAIL     * branch if V set  
    bcs ORI_TO_CCR_FAIL     * branch if C set  
   
    move #$2700, SR         * Put flags back to initial value

    rts
    
ORI_TO_CCR_FAIL: bra ORI_TO_CCR_FAIL
   

*-----------------------------------------------------------
*-----------------------------------------------------------
* OPCODE : ORI_TO_SR
*-----------------------------------------------------------
*-----------------------------------------------------------
op_ORI_TO_SR: 

    ori.w #$2FFF, SR
    bpl ORI_TO_SR_FAIL     * branch if Z clear  
    bne ORI_TO_SR_FAIL     * branch if N clear
    bvc ORI_TO_SR_FAIL     * branch if V clear 
    bcc ORI_TO_SR_FAIL     * branch if C clear 
    
    move #$2000, SR
    ori.w #$0000, SR
    beq ORI_TO_SR_FAIL     * branch if Z set  
    bmi ORI_TO_SR_FAIL     * branch if N set  
    bvs ORI_TO_SR_FAIL     * branch if V set  
    bcs ORI_TO_SR_FAIL     * branch if C set  
   
    move #$2700, SR        * Put flags back to initial value

    rts
    
ORI_TO_SR_FAIL: bra ORI_TO_SR_FAIL
   

*-----------------------------------------------------------
*-----------------------------------------------------------
* OPCODE : EORI_TO_CCR
*-----------------------------------------------------------
*-----------------------------------------------------------
op_EORI_TO_CCR: 

    move #$00, CCR
    eori.b #$FF, CCR
    bpl EORI_TO_CCR_FAIL     * branch if Z clear  
    bne EORI_TO_CCR_FAIL     * branch if N clear
    bvc EORI_TO_CCR_FAIL     * branch if V clear 
    bcc EORI_TO_CCR_FAIL     * branch if C clear 
    
    move #$00, CCR
    eori.b #$00, CCR
    beq EORI_TO_CCR_FAIL     * branch if Z set  
    bmi EORI_TO_CCR_FAIL     * branch if N set  
    bvs EORI_TO_CCR_FAIL     * branch if V set  
    bcs EORI_TO_CCR_FAIL     * branch if C set  
   
    move #$2700, SR         * Put flags back to initial value

    rts
    
EORI_TO_CCR_FAIL: bra EORI_TO_CCR_FAIL
   

*-----------------------------------------------------------
*-----------------------------------------------------------
* OPCODE : EORI_TO_SR
*-----------------------------------------------------------
*-----------------------------------------------------------
op_EORI_TO_SR: 

    move #$2000, SR
    eori.w #$0FFF, SR
    bpl EORI_TO_SR_FAIL     * branch if Z clear  
    bne EORI_TO_SR_FAIL     * branch if N clear
    bvc EORI_TO_SR_FAIL     * branch if V clear 
    bcc EORI_TO_SR_FAIL     * branch if C clear 
    
    move #$2000, SR
    eori.w #$0000, SR
    beq EORI_TO_SR_FAIL     * branch if Z set  
    bmi EORI_TO_SR_FAIL     * branch if N set  
    bvs EORI_TO_SR_FAIL     * branch if V set  
    bcs EORI_TO_SR_FAIL     * branch if C set  
   
    move #$2700, SR        * Put flags back to initial value

    rts
    
EORI_TO_SR_FAIL: bra EORI_TO_SR_FAIL
   


*-----------------------------------------------------------
*-----------------------------------------------------------
* OPCODE : ANDI_TO_CCR
*-----------------------------------------------------------
*-----------------------------------------------------------
op_ANDI_TO_CCR: 

    move #$FF, CCR
    andi.b #$FF, CCR
    bpl ANDI_TO_CCR_FAIL     * branch if Z clear  
    bne ANDI_TO_CCR_FAIL     * branch if N clear
    bvc ANDI_TO_CCR_FAIL     * branch if V clear 
    bcc ANDI_TO_CCR_FAIL     * branch if C clear 
    
    move #$FF, CCR
    andi.b #$00, CCR
    beq ANDI_TO_CCR_FAIL     * branch if Z set  
    bmi ANDI_TO_CCR_FAIL     * branch if N set  
    bvs ANDI_TO_CCR_FAIL     * branch if V set  
    bcs ANDI_TO_CCR_FAIL     * branch if C set  
   
    move #$2700, SR         * Put flags back to initial value

    rts
    
ANDI_TO_CCR_FAIL: bra ANDI_TO_CCR_FAIL
   

*-----------------------------------------------------------
*-----------------------------------------------------------
* OPCODE : ANDI_TO_SR
*-----------------------------------------------------------
*-----------------------------------------------------------
op_ANDI_TO_SR: 
    move #$20FF, SR
    andi.w #$FFFF, SR
    bpl ANDI_TO_SR_FAIL     * branch if Z clear  
    bne ANDI_TO_SR_FAIL     * branch if N clear
    bvc ANDI_TO_SR_FAIL     * branch if V clear 
    bcc ANDI_TO_SR_FAIL     * branch if C clear 
    
    move #$20FF, SR
    andi.w #$FF00, SR
    beq ANDI_TO_SR_FAIL     * branch if Z set  
    bmi ANDI_TO_SR_FAIL     * branch if N set  
    bvs ANDI_TO_SR_FAIL     * branch if V set  
    bcs ANDI_TO_SR_FAIL     * branch if C set  
   
    move #$2700, SR         * Put flags back to initial value

    rts
    
ANDI_TO_SR_FAIL: bra ANDI_TO_SR_FAIL
  
  
*-----------------------------------------------------------
*-----------------------------------------------------------
* OPCODE : BTST
*-----------------------------------------------------------
*-----------------------------------------------------------
op_BTST: 

*  Bit Number Static 
    
            * EA = Dn  - LONG only
            move.l #$80000001 , d0      * populate test data
            btst.l #0 , d0              
            beq BTST_FAIL               * branch if Z set
            btst.l #1 , d0              * 
            bne BTST_FAIL               * branch if Z clear  
            btst.l #31 , d0             * 
            beq BTST_FAIL               * branch if Z set
            
            
            * EA = (An)  - BYTE only
            move.l #$00000100 , a0      * point to memory to address 0x100
            move.b #$81 , (a0)          * populate test data
            move.b (a0) , d1            * Check to see if data in memory is 0x81
            btst.b #0 , (a0)            
            beq BTST_FAIL               * branch if Z set
            btst.b #1 , (a0)            * 
            bne BTST_FAIL               * branch if Z clear  
            btst.b #7 , (a0)            * 
            beq BTST_FAIL               * branch if Z set
            
            
            * EA = (An)+  - BYTE only
            move.l #$00000100 , a0      * point to memory to address 0x100 
            move.b #$01 , (a0)+         * populate test data
            move.b #$FC , (a0)+         * populate test data
            move.b #$80 , (a0)+         * populate test data
            move.l #$00000100 , a0      * point to memory to address 0x100 
            btst.b #0 , (a0)+            
            beq BTST_FAIL               * branch if Z set
            btst.b #1 , (a0)+           * 
            bne BTST_FAIL               * branch if Z clear  
            btst.b #7 , (a0)+           * 
            beq BTST_FAIL               * branch if Z set
        
        
            * EA = -(An)  - BYTE only
            move.l #$00000100 , a0      * point to memory to address
            move.b #$80 , (a0)+         * populate test data
            move.b #$FC , (a0)+         * populate test data
            move.b #$01 , (a0)+         * populate test data
            move.l #$00000103 , a0      * point to memory to address 
            btst.b #0 , -(a0)            
            beq BTST_FAIL               * branch if Z set
            btst.b #1 , -(a0)           * 
            bne BTST_FAIL               * branch if Z clear  
            btst.b #7 , -(a0)           * 
            beq BTST_FAIL               * branch if Z set
        
        
            * EA = n(An)  - BYTE only
            move.l #$00000100 , a0      * point to memory to address
            move.b #$01 , (a0)+         * populate test data
            move.b #$FC , (a0)+         * populate test data
            move.b #$80 , (a0)+         * populate test data
            move.l #$00000100 , a0      * point to memory to address
            btst.b #0 , 0(a0)            
            beq BTST_FAIL               * branch if Z set
            btst.b #1 , 1(a0)           * 
            bne BTST_FAIL               * branch if Z clear  
            btst.b #7 , 2(a0)           * 
            beq BTST_FAIL               * branch if Z set
        
        
            * EA = n(An,R.W)  - BYTE only
            move.l #$00000100 , a0      * point to memory to address
            move.l #$00000000 , a1      * point to memory to address
            move.l #$00000001 , a2      * point to memory to address
            move.l #$00000000 , d0      * point to memory to address
            move.l #$00000001 , d1      * point to memory to address
            btst.b #0 , 0(a0,d0.w)            
            beq BTST_FAIL               * branch if Z set
            btst.b #1 , 0(a0,d1.w)      * 
            bne BTST_FAIL               * branch if Z clear  
            btst.b #7 , 1(a0,d1.w)      * 
            beq BTST_FAIL               * branch if Z set
            * EA = n(An,R.L)  - BYTE only
            btst.b #0 , 0(a0,d0.l)  
            beq BTST_FAIL               * branch if Z set
            btst.b #1 , 0(a0,d1.l)      * 
            bne BTST_FAIL               * branch if Z clear  
            btst.b #7 , 1(a0,d1.l)      * 
            beq BTST_FAIL               * branch if Z set
            * EA = n(An,A.W)  - BYTE only
            btst.b #0 , 0(a0,a1.w)            
            beq BTST_FAIL               * branch if Z set
            btst.b #1 , 0(a0,a2.w)      * 
            bne BTST_FAIL               * branch if Z clear  
            btst.b #7 , 1(a0,a2.w)      * 
            beq BTST_FAIL               * branch if Z set
            * EA = n(An,A.L)  - BYTE only
            btst.b #0 , 0(a0,a1.l)  
            beq BTST_FAIL               * branch if Z set
            btst.b #1 , 0(a0,a2.l)      * 
            bne BTST_FAIL               * branch if Z clear  
            btst.b #7 , 1(a0,a2.l)      * 
            beq BTST_FAIL               * branch if Z set
        
        
            * EA = x.W  - BYTE only
            btst.b #0 , $0100            
            beq BTST_FAIL               * branch if Z set
            btst.b #1 , $0101           * 
            bne BTST_FAIL               * branch if Z clear  
            btst.b #7 , $0102           * 
            beq BTST_FAIL               * branch if Z set
        
        
            * EA = x.L  - BYTE only
            move.l #$000F0100 , a0      * point to memory to address 0x100 
            move.b #$01 , (a0)+         * populate test data
            move.b #$FC , (a0)+         * populate test data
            move.b #$80 , (a0)+         * populate test data
            btst.b #0 , $000F0100 
            beq BTST_FAIL               * branch if Z set
            btst.b #1 , $000F0101       * 
            bne BTST_FAIL               * branch if Z clear  
            btst.b #7 , $000F0102       * 
            beq BTST_FAIL               * branch if Z set
        
        
            * EA = x(PC)  - BYTE only
            lea op_BTST(pc) , a5
            btst.b #0 , op_BTST(pc) 
            bne BTST_FAIL               * branch if Z clear  
            btst.b #3 ,op_BTST0(pc)     * 
            beq BTST_FAIL               * branch if Z set
            btst.b #6 , op_BTST12(pc)    * 
            beq BTST_FAIL               * branch if Z set
  
  
            * EA = n(PC,R.W)  - BYTE only
            move.l #$00000100 , a0      * point to memory to address
            move.l #$00000000 , a1      * point to memory to address
            move.l #$00000001 , a2      * point to memory to address
            move.l #$00000000 , d0      * point to memory to address
            move.l #$00000001 , d1      * point to memory to address
    
op_BTST0:   btst.b #0 , op_BTST0(pc,d0.w)            
            bne BTST_FAIL               * branch if Z clear  
            
            lea op_BTST1(pc,d1.w) , a5
op_BTST1:   btst.b #1 , op_BTST1(pc,d1.w)      * 
            beq BTST_FAIL               * branch if Z set
op_BTST2:   btst.b #7 , op_BTST2(pc,d1.w)      * 
            bne BTST_FAIL               * branch if Z clear  
            * EA = n(PC,R.L)  - BYTE only
op_BTST3:   btst.b #0 , op_BTST3(pc,d0.l)  
            bne BTST_FAIL               * branch if Z clear  
op_BTST4:   btst.b #1 , op_BTST4(pc,d1.l)      * 
            beq BTST_FAIL               * branch if Z set
op_BTST5:   btst.b #7 , op_BTST5(pc,d1.l)      * 
            bne BTST_FAIL               * branch if Z clear  
            * EA = n(PC,A.W)  - BYTE only
op_BTST6    btst.b #0 , op_BTST6(pc,a1.w)            
            bne BTST_FAIL               * branch if Z clear  
op_BTST7:   btst.b #1 , op_BTST7(pc,a2.w)      * 
            beq BTST_FAIL               * branch if Z set
op_BTST8:   btst.b #7 , op_BTST8(pc,a2.w)      * 
            bne BTST_FAIL               * branch if Z clear  
            * EA = n(PC,A.L)  - BYTE only
op_BTST9:   btst.b #0 , op_BTST9(pc,a1.l)  
            bne BTST_FAIL               * branch if Z clear  
op_BTST10:  btst.b #1 , op_BTST10(pc,a2.l)      * 
            beq BTST_FAIL               * branch if Z set
op_BTST11:  btst.b #7 , op_BTST11(pc,a2.l)      * 
op_BTST12:  bne BTST_FAIL               * branch if Z clear  
 


* Bit Number Dynamic
    
            * EA = Dn  - LONG only
            move.l #$80000001 , d0      * populate test data
            move.l #0,  d5              * populate bit number to test
            move.l #1,  d6              * populate bit number to test
            move.l #31, d7              * populate bit number to test
            
            btst.l d5 , d0              
            beq BTST_FAIL               * branch if Z set
            btst.l d6 , d0              * 
            bne BTST_FAIL               * branch if Z clear  
            btst.l d7 , d0             * 
            beq BTST_FAIL               * branch if Z set
            
            
            * EA = (An)  - BYTE only
            move.l #0,  d5              * populate bit number to test
            move.l #1,  d6              * populate bit number to test
            move.l #7,  d7              * populate bit number to test           
            move.l #$00000100 , a0      * point to memory to address 0x100
            move.b #$81 , (a0)          * populate test data
            move.b (a0) , d1            * Check to see if data in memory is 0x81
            btst.b d5 , (a0)            
            beq BTST_FAIL               * branch if Z set
            btst.b d6 , (a0)            * 
            bne BTST_FAIL               * branch if Z clear  
            btst.b d7 , (a0)            * 
            beq BTST_FAIL               * branch if Z set
            
* ---

    
            * EA = (An)+  - BYTE only
            move.l #$00000100 , a0      * point to memory to address 0x100 
            move.b #$01 , (a0)+         * populate test data
            move.b #$FC , (a0)+         * populate test data
            move.b #$80 , (a0)+         * populate test data
            move.l #$00000100 , a0      * point to memory to address 0x100 
            btst.b d5 , (a0)+            
            beq BTST_FAIL               * branch if Z set
            btst.b d6 , (a0)+           * 
            bne BTST_FAIL               * branch if Z clear  
            btst.b d7 , (a0)+           * 
            beq BTST_FAIL               * branch if Z set
        
        
            * EA = -(An)  - BYTE only
            move.l #$00000100 , a0      * point to memory to address
            move.b #$80 , (a0)+         * populate test data
            move.b #$FC , (a0)+         * populate test data
            move.b #$01 , (a0)+         * populate test data
            move.l #$00000103 , a0      * point to memory to address 
            btst.b d5 , -(a0)            
            beq BTST_FAIL               * branch if Z set
            btst.b d6 , -(a0)           * 
            bne BTST_FAIL               * branch if Z clear  
            btst.b d7 , -(a0)           * 
            beq BTST_FAIL               * branch if Z set
        
        
            * EA = n(An)  - BYTE only
            move.l #$00000100 , a0      * point to memory to address
            move.b #$01 , (a0)+         * populate test data
            move.b #$FC , (a0)+         * populate test data
            move.b #$80 , (a0)+         * populate test data
            move.l #$00000100 , a0      * point to memory to address
            btst.b d5 , 0(a0)            
            beq BTST_FAIL               * branch if Z set
            btst.b d6 , 1(a0)           * 
            bne BTST_FAIL               * branch if Z clear  
            btst.b d7 , 2(a0)           * 
            beq BTST_FAIL               * branch if Z set
        
        
            * EA = n(An,R.W)  - BYTE only
            move.l #$00000100 , a0      * point to memory to address
            move.l #$00000000 , a1      * point to memory to address
            move.l #$00000001 , a2      * point to memory to address
            move.l #$00000000 , d0      * point to memory to address
            move.l #$00000001 , d1      * point to memory to address
            btst.b d5 , 0(a0,d0.w)            
            beq BTST_FAIL               * branch if Z set
            btst.b d6 , 0(a0,d1.w)      * 
            bne BTST_FAIL               * branch if Z clear  
            btst.b d7 , 1(a0,d1.w)      * 
            beq BTST_FAIL               * branch if Z set
            * EA = n(An,R.L)  - BYTE only
            btst.b d5 , 0(a0,d0.l)  
            beq BTST_FAIL               * branch if Z set
            btst.b d6 , 0(a0,d1.l)      * 
            bne BTST_FAIL               * branch if Z clear  
            btst.b d7 , 1(a0,d1.l)      * 
            beq BTST_FAIL               * branch if Z set
            * EA = n(An,A.W)  - BYTE only
            btst.b d5 , 0(a0,a1.w)            
            beq BTST_FAIL               * branch if Z set
            btst.b d6 , 0(a0,a2.w)      * 
            bne BTST_FAIL               * branch if Z clear  
            btst.b d7 , 1(a0,a2.w)      * 
            beq BTST_FAIL               * branch if Z set
            * EA = n(An,A.L)  - BYTE only
            btst.b d5 , 0(a0,a1.l)  
            beq BTST_FAIL               * branch if Z set
            btst.b d6 , 0(a0,a2.l)      * 
            bne BTST_FAIL               * branch if Z clear  
            btst.b d7 , 1(a0,a2.l)      * 
            beq BTST_FAIL               * branch if Z set
        
        
            * EA = x.W  - BYTE only
            btst.b d5 , $0100            
            beq BTST_FAIL               * branch if Z set
            btst.b d6 , $0101           * 
            bne BTST_FAIL               * branch if Z clear  
            btst.b d7 , $0102           * 
            beq BTST_FAIL               * branch if Z set
        
        
            * EA = x.L  - BYTE only
            move.l #$000F0100 , a0      * point to memory to address 0x100 
            move.b #$01 , (a0)+         * populate test data
            move.b #$FC , (a0)+         * populate test data
            move.b #$80 , (a0)+         * populate test data
            btst.b d5 , $000F0100 
            beq BTST_FAIL               * branch if Z set
            btst.b d6 , $000F0101       * 
            bne BTST_FAIL               * branch if Z clear  
            btst.b d7 , $000F0102       * 
            beq BTST_FAIL               * branch if Z set
        
        
            * EA = x(PC)  - BYTE only
            move.l #3,  d6              * populate bit number to test
            move.l #6,  d7              * populate bit number to test
            lea op_BTST(pc) , a5
            btst.b d5 , op_BTST(pc) 
            bne BTST_FAIL               * branch if Z clear  
            btst.b d6 ,op_BTST0(pc)     * 
            beq BTST_FAIL               * branch if Z set
            btst.b d7 , op_BTST12(pc)    * 
            beq BTST_FAIL               * branch if Z set
  
  
            * EA = n(PC,R.W)  - BYTE only
            move.l #$00000100 , a0      * point to memory to address
            move.l #$00000000 , a1      * point to memory to address
            move.l #$00000001 , a2      * point to memory to address
            move.l #$00000000 , d0      * point to memory to address
            move.l #$00000001 , d1      * point to memory to address
            move.l #1,  d6              * populate bit number to test
            move.l #7,  d7              * populate bit number to test
    
op_BTST20:  btst.b d5 , op_BTST20(pc,d0.w)            
            beq BTST_FAIL               * branch if Z set            
            lea op_BTST21(pc,d1.w) , a5
op_BTST21:  btst.b d6 , op_BTST21(pc,d1.w)      * 
            beq BTST_FAIL               * branch if Z set
op_BTST22:  btst.b d7 , op_BTST22(pc,d1.w)      * 
            bne BTST_FAIL               * branch if Z clear  
            * EA = n(PC,R.L)  - BYTE only
op_BTST23:  btst.b d5 , op_BTST23(pc,d0.l)  
            beq BTST_FAIL               * branch if Z set
op_BTST24: btst.b d6 , op_BTST24(pc,d1.l)      * 
            beq BTST_FAIL               * branch if Z set
op_BTST25  btst.b d7 , op_BTST25(pc,d1.l)      * 
            bne BTST_FAIL               * branch if Z clear  
            * EA = n(PC,A.W)  - BYTE only
op_BTST26   btst.b d5 , op_BTST26(pc,a1.w)            
            beq BTST_FAIL               * branch if Z set
op_BTST27:  btst.b d6 , op_BTST27(pc,a2.w)      * 
            beq BTST_FAIL               * branch if Z set
op_BTST28:  btst.b d7 , op_BTST28(pc,a2.w)      * 
            bne BTST_FAIL               * branch if Z clear  
            * EA = n(PC,A.L)  - BYTE only
op_BTST29:  btst.b d5 , op_BTST29(pc,a1.l)  
            beq BTST_FAIL               * branch if Z set
op_BTST30:  btst.b d6 , op_BTST30(pc,a2.l)      * 
            beq BTST_FAIL               * branch if Z set
op_BTST31:  btst.b d7 , op_BTST31(pc,a2.l)      * 
op_BTST32:  bne BTST_FAIL               * branch if Z clear  
 
            * EA = #x  - BYTE only

            move.l #0,  d5              * populate bit number to test
            move.l #3,  d6              * populate bit number to test
            move.l #7,  d7              * populate bit number to test
            
            btst.b d5 , #$88
            bne BTST_FAIL               * branch if Z clear  
            btst.b d6 , #$88
            beq BTST_FAIL               * branch if Z set
            btst.b d7 , #$88
            beq BTST_FAIL               * branch if Z set
            

    rts
    
BTST_FAIL: bra BTST_FAIL
   
 
 
  
*-----------------------------------------------------------
*-----------------------------------------------------------
* OPCODE : BCHG
*-----------------------------------------------------------
*-----------------------------------------------------------
op_BCHG: 


*  Bit Number Static 
    
            * EA = Dn  - LONG only
            move.l #$80000001 , d0      * populate test data
            bchg.l #0 , d0              
            beq BCHG_FAIL               * branch if Z set
            bchg.l #1 , d0              * 
            bne BCHG_FAIL               * branch if Z clear  
            bchg.l #31 , d0             * 
            beq BCHG_FAIL               * branch if Z set
            cmpi.l #$00000002 , d0
            bne BCHG_FAIL               * branch if Z clear  

            
            * EA = (An)  - BYTE only
            move.l #$00000100 , a0      * point to memory to address 0x100
            move.b #$81 , (a0)          * populate test data
            move.b (a0) , d1            * Check to see if data in memory is 0x81
            bchg.b #0 , (a0)            
            beq BCHG_FAIL               * branch if Z set
            bchg.b #1 , (a0)            * 
            bne BCHG_FAIL               * branch if Z clear  
            bchg.b #7 , (a0)            * 
            beq BCHG_FAIL               * branch if Z set
            cmpi.b #$02 , (a0)
            bne BCHG_FAIL               * branch if Z clear  
            
            * EA = (An)+  - BYTE only
            move.l #$00000100 , a0      * point to memory to address 0x100 
            move.b #$01 , (a0)+         * populate test data
            move.b #$FC , (a0)+         * populate test data
            move.b #$80 , (a0)+         * populate test data
            move.l #$00000100 , a0      * point to memory to address 0x100 
            bchg.b #0 , (a0)+            
            beq BCHG_FAIL               * branch if Z set
            bchg.b #1 , (a0)+           * 
            bne BCHG_FAIL               * branch if Z clear  
            bchg.b #7 , (a0)+           * 
            beq BCHG_FAIL               * branch if Z set
            move.l #$00000100 , a0      * point to memory to address 0x100 
            cmpi.b #$00 , (a0)+
            bne BCHG_FAIL               * branch if Z clear  
            cmpi.b #$FE , (a0)+
            bne BCHG_FAIL               * branch if Z clear  
            cmpi.b #$00 , (a0)+
            bne BCHG_FAIL               * branch if Z clear  
        
            * EA = -(An)  - BYTE only
            move.l #$00000100 , a0      * point to memory to address
            move.b #$80 , (a0)+         * populate test data
            move.b #$FC , (a0)+         * populate test data
            move.b #$01 , (a0)+         * populate test data
            move.l #$00000103 , a0      * point to memory to address 
            bchg.b #0 , -(a0)            
            beq BCHG_FAIL               * branch if Z set
            bchg.b #1 , -(a0)           * 
            bne BCHG_FAIL               * branch if Z clear  
            bchg.b #7 , -(a0)           * 
            beq BCHG_FAIL               * branch if Z set
            move.l #$00000103 , a0      * point to memory to address 0x100 
            cmpi.b #$00 , -(a0)
            bne BCHG_FAIL               * branch if Z clear  
            cmpi.b #$FE , -(a0)
            bne BCHG_FAIL               * branch if Z clear  
            cmpi.b #$00 , -(a0)
            bne BCHG_FAIL               * branch if Z clear  
        
        
            * EA = n(An)  - BYTE only
            move.l #$00000100 , a0      * point to memory to address
            move.b #$01 , (a0)+         * populate test data
            move.b #$FC , (a0)+         * populate test data
            move.b #$80 , (a0)+         * populate test data
            move.l #$00000100 , a0      * point to memory to address
            bchg.b #0 , 0(a0)            
            beq BCHG_FAIL               * branch if Z set
            bchg.b #1 , 1(a0)           * 
            bne BCHG_FAIL               * branch if Z clear  
            bchg.b #7 , 2(a0)           * 
            beq BCHG_FAIL               * branch if Z set
            move.l #$00000100 , a0      * point to memory to address 0x100 
            cmpi.b #$00 , (a0)+
            bne BCHG_FAIL               * branch if Z clear  
            cmpi.b #$FE , (a0)+
            bne BCHG_FAIL               * branch if Z clear  
            cmpi.b #$00 , (a0)+
            bne BCHG_FAIL               * branch if Z clear  
                
                
            * EA = n(An,D.W)  - BYTE only
            move.l #$00000100 , a0      * point to memory to address
            move.l #$00000000 , a1      * point to memory to address
            move.l #$00000001 , a2      * point to memory to address
            move.l #$00000000 , d0      * point to memory to address
            move.l #$00000001 , d1      * point to memory to address
            bchg.b #0 , 0(a0,d0.w)            
            bne BCHG_FAIL               * branch if Z clear  
            bchg.b #1 , 0(a0,d1.w)      * 
            beq BCHG_FAIL               * branch if Z set
            bchg.b #7 , 1(a0,d1.w)      * 
            bne BCHG_FAIL               * branch if Z clear  
            * EA = n(An,D.L)  - BYTE only
            bchg.b #0 , 0(a0,d0.l)  
            beq BCHG_FAIL               * branch if Z set
            bchg.b #1 , 0(a0,d1.l)      * 
            bne BCHG_FAIL               * branch if Z clear  
            bchg.b #7 , 1(a0,d1.l)      * 
            beq BCHG_FAIL               * branch if Z set
            * EA = n(An,A.W)  - BYTE only
            bchg.b #0 , 0(a0,a1.w)            
            bne BCHG_FAIL               * branch if Z clear  
            bchg.b #1 , 0(a0,a2.w)      * 
            beq BCHG_FAIL               * branch if Z set
            bchg.b #7 , 1(a0,a2.w)      * 
            bne BCHG_FAIL               * branch if Z clear  
            * EA = n(An,A.L)  - BYTE only
            bchg.b #0 , 0(a0,a1.l)  
            beq BCHG_FAIL               * branch if Z set
            bchg.b #1 , 0(a0,a2.l)      * 
            bne BCHG_FAIL               * branch if Z clear  
            bchg.b #7 , 1(a0,a2.l)      * 
            beq BCHG_FAIL               * branch if Z set
            move.l #$00000100 , a0      * point to memory to address 0x100 
            cmpi.b #$00 , (a0)+
            bne BCHG_FAIL               * branch if Z clear  
            cmpi.b #$FE , (a0)+
            bne BCHG_FAIL               * branch if Z clear  
            cmpi.b #$00 , (a0)+
            bne BCHG_FAIL               * branch if Z clear  
    
        
            * EA = x.W  - BYTE only
            bchg.b #0 , $0100            
            bne BCHG_FAIL               * branch if Z clear  
            bchg.b #1 , $0101           * 
            beq BCHG_FAIL               * branch if Z set
            bchg.b #7 , $0102           * 
            bne BCHG_FAIL               * branch if Z clear  
            move.l #$00000100 , a0      * point to memory to address 0x100 
            cmpi.b #$01 , (a0)+
            bne BCHG_FAIL               * branch if Z clear  
            cmpi.b #$FC , (a0)+
            bne BCHG_FAIL               * branch if Z clear  
            cmpi.b #$80 , (a0)+
            bne BCHG_FAIL               * branch if Z clear  
            
            * EA = x.L  - BYTE only
            move.l #$000F0100 , a0      * point to memory to address 0x100 
            move.b #$01 , (a0)+         * populate test data
            move.b #$FC , (a0)+         * populate test data
            move.b #$80 , (a0)+         * populate test data
            bchg.b #0 , $000F0100 
            beq BCHG_FAIL               * branch if Z set
            bchg.b #1 , $000F0101       * 
            bne BCHG_FAIL               * branch if Z clear  
            bchg.b #7 , $000F0102       * 
            beq BCHG_FAIL               * branch if Z set
            move.l #$00000100 , a0      * point to memory to address 0x100 
            cmpi.b #$01 , (a0)+
            bne BCHG_FAIL               * branch if Z clear  
            cmpi.b #$FC , (a0)+
            bne BCHG_FAIL               * branch if Z clear  
            cmpi.b #$80 , (a0)+
            bne BCHG_FAIL               * branch if Z clear  
            

* Bit Number Dynamic
    
            * EA = Dn  - LONG only
            move.l #$80000001 , d0      * populate test data
            move.l #0,  d5              * populate bit number to test
            move.l #1,  d6              * populate bit number to test
            move.l #31, d7              * populate bit number to test
            
            bchg.l d5 , d0              
            beq BCHG_FAIL               * branch if Z set
            bchg.l d6 , d0              * 
            bne BCHG_FAIL               * branch if Z clear  
            bchg.l d7 , d0             * 
            beq BCHG_FAIL               * branch if Z set
            cmpi.l #$00000002 , d0
            bne BCHG_FAIL               * branch if Z clear  

            
            * EA = (An)  - BYTE only
            move.l #0,  d5              * populate bit number to test
            move.l #1,  d6              * populate bit number to test
            move.l #7,  d7              * populate bit number to test           
            move.l #$00000100 , a0      * point to memory to address 0x100
            move.b #$81 , (a0)          * populate test data
            move.b (a0) , d1            * Check to see if data in memory is 0x81
            bchg.b d5 , (a0)            
            beq BCHG_FAIL               * branch if Z set
            bchg.b d6 , (a0)            * 
            bne BCHG_FAIL               * branch if Z clear  
            bchg.b d7 , (a0)            * 
            beq BCHG_FAIL               * branch if Z set
            cmpi.b #$02 , (a0)
            bne BCHG_FAIL               * branch if Z clear  
            
    
            * EA = (An)+  - BYTE only
            move.l #$00000100 , a0      * point to memory to address 0x100 
            move.b #$01 , (a0)+         * populate test data
            move.b #$FC , (a0)+         * populate test data
            move.b #$80 , (a0)+         * populate test data
            move.l #$00000100 , a0      * point to memory to address 0x100 
            bchg.b d5 , (a0)+            
            beq BCHG_FAIL               * branch if Z set
            bchg.b d6 , (a0)+           * 
            bne BCHG_FAIL               * branch if Z clear  
            bchg.b d7 , (a0)+           * 
            beq BCHG_FAIL               * branch if Z set
            move.l #$00000100 , a0      * point to memory to address 0x100 
            cmpi.b #$00 , (a0)+
            bne BCHG_FAIL               * branch if Z clear  
            cmpi.b #$FE , (a0)+
            bne BCHG_FAIL               * branch if Z clear  
            cmpi.b #$00 , (a0)+
            bne BCHG_FAIL               * branch if Z clear  
                
            * EA = -(An)  - BYTE only
            move.l #$00000100 , a0      * point to memory to address
            move.b #$80 , (a0)+         * populate test data
            move.b #$FC , (a0)+         * populate test data
            move.b #$01 , (a0)+         * populate test data
            move.l #$00000103 , a0      * point to memory to address 
            bchg.b d5 , -(a0)            
            beq BCHG_FAIL               * branch if Z set
            bchg.b d6 , -(a0)           * 
            bne BCHG_FAIL               * branch if Z clear  
            bchg.b d7 , -(a0)           * 
            beq BCHG_FAIL               * branch if Z set
            move.l #$00000103 , a0      * point to memory to address 0x100 
            cmpi.b #$00 , -(a0)
            bne BCHG_FAIL               * branch if Z clear  
            cmpi.b #$FE , -(a0)
            bne BCHG_FAIL               * branch if Z clear  
            cmpi.b #$00 , -(a0)
            bne BCHG_FAIL               * branch if Z clear  
                
            * EA = n(An)  - BYTE only
            move.l #$00000100 , a0      * point to memory to address
            move.b #$01 , (a0)+         * populate test data
            move.b #$FC , (a0)+         * populate test data
            move.b #$80 , (a0)+         * populate test data
            move.l #$00000100 , a0      * point to memory to address
            bchg.b d5 , 0(a0)            
            beq BCHG_FAIL               * branch if Z set
            bchg.b d6 , 1(a0)           * 
            bne BCHG_FAIL               * branch if Z clear  
            bchg.b d7 , 2(a0)           * 
            beq BCHG_FAIL               * branch if Z set
            move.l #$00000100 , a0      * point to memory to address 0x100 
            cmpi.b #$00 , (a0)+
            bne BCHG_FAIL               * branch if Z clear  
            cmpi.b #$FE , (a0)+
            bne BCHG_FAIL               * branch if Z clear  
            cmpi.b #$00 , (a0)+
            bne BCHG_FAIL               * branch if Z clear  
                
            * EA = n(An,R.W)  - BYTE only
            move.l #$00000100 , a0      * point to memory to address
            move.l #$00000000 , a1      * point to memory to address
            move.l #$00000001 , a2      * point to memory to address
            move.l #$00000000 , d0      * point to memory to address
            move.l #$00000001 , d1      * point to memory to address
            bchg.b d5 , 0(a0,d0.w)            
            bne BCHG_FAIL               * branch if Z clear  
            bchg.b d6 , 0(a0,d1.w)      * 
            beq BCHG_FAIL               * branch if Z set
            bchg.b d7 , 1(a0,d1.w)      * 
            bne BCHG_FAIL               * branch if Z clear  
            * EA = n(An,R.L)  - BYTE only
            bchg.b d5 , 0(a0,d0.l)  
            beq BCHG_FAIL               * branch if Z set
            bchg.b d6 , 0(a0,d1.l)      * 
            bne BCHG_FAIL               * branch if Z clear  
            bchg.b d7 , 1(a0,d1.l)      * 
            beq BCHG_FAIL               * branch if Z set
            * EA = n(An,A.W)  - BYTE only
            bchg.b d5 , 0(a0,a1.w)            
            bne BCHG_FAIL               * branch if Z clear  
            bchg.b d6 , 0(a0,a2.w)      * 
            beq BCHG_FAIL               * branch if Z set
            bchg.b d7 , 1(a0,a2.w)      * 
            bne BCHG_FAIL               * branch if Z clear  
            * EA = n(An,A.L)  - BYTE only
            bchg.b d5 , 0(a0,a1.l)  
            beq BCHG_FAIL               * branch if Z set
            bchg.b d6 , 0(a0,a2.l)      * 
            bne BCHG_FAIL               * branch if Z clear  
            bchg.b d7 , 1(a0,a2.l)      * 
            beq BCHG_FAIL               * branch if Z set
            cmpi.b #$00 , (a0)+
            bne BCHG_FAIL               * branch if Z clear  
            
            * EA = x.W  - BYTE only
            bchg.b d5 , $0100            
            bne BCHG_FAIL               * branch if Z clear  
            bchg.b d6 , $0101           * 
            beq BCHG_FAIL               * branch if Z set
            bchg.b d7 , $0102           * 
            bne BCHG_FAIL               * branch if Z clear  
            cmpi.b #$FC , (a0)+
            bne BCHG_FAIL               * branch if Z clear  
                    
            * EA = x.L  - BYTE only
            move.l #$000F0100 , a0      * point to memory to address 0x100 
            move.b #$01 , (a0)+         * populate test data
            move.b #$FC , (a0)+         * populate test data
            move.b #$80 , (a0)+         * populate test data
            bchg.b d5 , $000F0100 
            beq BCHG_FAIL               * branch if Z set
            bchg.b d6 , $000F0101       * 
            bne BCHG_FAIL               * branch if Z clear  
            bchg.b d7 , $000F0102       * 
            beq BCHG_FAIL               * branch if Z set
            move.l #$000F0101 , a0      * point to memory to address 0x100 
            cmpi.b #$FE , (a0)
            bne BCHG_FAIL               * branch if Z clear  
                    

    rts
    
BCHG_FAIL: bra BCHG_FAIL



  
*-----------------------------------------------------------
*-----------------------------------------------------------
* OPCODE : BCLR
*-----------------------------------------------------------
*-----------------------------------------------------------
op_BCLR: 


*  Bit Number Static 
    
            * EA = Dn  - LONG only
            move.l #$FF0000FF , d0      * populate test data
            bclr.l #0 , d0              
            beq *               * branch if Z set
            bclr.l #1 , d0              * 
            beq *               * branch if Z set
            bclr.l #15 , d0             * 
            bne *               * branch if Z clear  
            bclr.l #31 , d0             * 
            beq *               * branch if Z set
            cmpi.l #$7F0000FC , d0
            bne *               * branch if Z clear  

            
            * EA = (An)  - BYTE only
            move.l #$00000100 , a0      * point to memory to address 0x100
            move.b #$0F , (a0)          * populate test data
            bclr.b #0 , (a0)            
            beq *               * branch if Z set
            bclr.b #7 , (a0)            * 
            bne *               * branch if Z clear  
            cmpi.b #$0E , (a0)
            bne *               * branch if Z clear  
            
            * EA = (An)+  - BYTE only
            move.l #$00000100 , a0      * point to memory to address 0x100 
            move.b #$01 , (a0)+         * populate test data
            move.b #$00 , (a0)+         * populate test data
            move.l #$00000100 , a0      * point to memory to address 0x100 
            bclr.b #0 , (a0)+            
            beq *               * branch if Z set
            bclr.b #1 , (a0)+           * 
            bne *               * branch if Z clear  
            move.l #$00000100 , a0      * point to memory to address 0x100 
            cmpi.b #$00 , (a0)+
            bne *               * branch if Z clear  
            cmpi.b #$00 , (a0)+
            bne *               * branch if Z clear  
 
        
            * EA = -(An)  - BYTE only
            move.l #$00000100 , a0      * point to memory to address
            move.b #$01 , (a0)+         * populate test data
            move.b #$80 , (a0)+         * populate test data
            bclr.b #7 , -(a0)            
            beq *               * branch if Z set
            bclr.b #0 , -(a0)           * 
            beq *               * branch if Z set
            move.l #$00000102 , a0      * point to memory to address 0x100 
            cmpi.b #$00 , -(a0)
            bne *               * branch if Z clear  
            cmpi.b #$00 , -(a0)
            bne *               * branch if Z clear  

        
            * EA = n(An)  - BYTE only
            move.l #$00000100 , a0      * point to memory to address
            move.b #$FF , (a0)+         * populate test data
            move.b #$FF , (a0)+         * populate test data
            move.l #$00000100 , a0      * point to memory to address
            bclr.b #0 , 0(a0)            
            beq *               * branch if Z set
            bclr.b #4 , 1(a0)           * 
            beq *               * branch if Z set
            move.l #$00000100 , a0      * point to memory to address 0x100 
            cmpi.b #$FE , (a0)+
            bne *               * branch if Z clear  
            cmpi.b #$EF , (a0)+
            bne *               * branch if Z clear  

                
            * EA = n(An,D.W)  - BYTE only
            move.l #$00000100 , a0      * point to memory to address
            move.l #$00000000 , a1      * point to memory to address
            move.l #$00000001 , a2      * point to memory to address
            move.l #$00000000 , d0      * point to memory to address
            move.l #$00000001 , d1      * point to memory to address
            move.b #$FF , (a0)+         * populate test data
            move.b #$FF , (a0)+         * populate test data
            move.l #$00000100 , a0      * point to memory to address
            bclr.b #0 , 0(a0,d0.w)            
            beq *               * branch if Z set
            bclr.b #1 , 0(a0,d1.w)      * 
            beq *               * branch if Z set
            bclr.b #2 , 1(a0,d1.w)      * 
            bne *               * branch if Z clear  
            * EA = n(An,D.L)  - BYTE only
            bclr.b #3 , 0(a0,d0.l)  
            beq *               * branch if Z set
            bclr.b #4 , 0(a0,d1.l)      * 
            beq *               * branch if Z set
            bclr.b #5 , 1(a0,d1.l)      * 
            bne *               * branch if Z clear  
            * EA = n(An,A.W)  - BYTE only
            bclr.b #6 , 0(a0,a1.w)            
            beq *               * branch if Z set
            bclr.b #1 , 0(a0,a2.w)      * 
            bne *               * branch if Z clear  
            bclr.b #7 , 1(a0,a2.w)      * 
            beq *               * branch if Z set
            * EA = n(An,A.L)  - BYTE only
            bclr.b #0 , 0(a0,a1.l)  
            bne *               * branch if Z clear  
            bclr.b #0 , 0(a0,a2.l)      * 
            beq *               * branch if Z set
            bclr.b #1 , 1(a0,a2.l)      * 
            bne *               * branch if Z clear  
            move.l #$00000100 , a0      * point to memory to address 0x100 
            cmpi.b #$B6 , (a0)+
            bne *               * branch if Z clear  
            cmpi.b #$EC , (a0)+
            bne *               * branch if Z clear  
            cmpi.b #$59 , (a0)+
            beq *               * branch if Z set
    
        
            * EA = x.W  - BYTE only
            move.l #$00000100 , a0      * point to memory to address
            move.b #$FF , (a0)+         * populate test data
            bclr.b #0 , $0100            
            beq *               * branch if Z set
            bclr.b #1 , $0100           * 
            beq *               * branch if Z set
            move.l #$00000100 , a0      * point to memory to address 0x100 
            cmpi.b #$FC , (a0)+
            bne *               * branch if Z clear  

            
            * EA = x.L  - BYTE only
            move.l #$000F0100 , a0      * point to memory to address 0x100 
            move.b #$FF , (a0)          * populate test data
            bclr.b #0 , $000F0100 
            beq *               * branch if Z set
            bclr.b #1 , $000F0100       * 
            beq *               * branch if Z set
            bclr.b #2 , $000F0100       * 
            beq *               * branch if Z set
            move.l #$000F0100 , a0      * point to memory to address 0x100 
            cmpi.b #$F8 , (a0)+
            bne *               * branch if Z clear  


* Bit Number Dynamic
    
            * EA = Dn  - LONG only
            move.l #$FF00FF00 , d0      * populate test data
            move.l #0,  d5              * populate bit number to test
            move.l #1,  d6              * populate bit number to test
            move.l #31, d7              * populate bit number to test
            
            bclr.l d5 , d0              
            bne *               * branch if Z clear  
            bclr.l d6 , d0              * 
            bne *               * branch if Z clear  
            bclr.l d7 , d0             * 
            beq *               * branch if Z set
            cmpi.l #$7F00FF00 , d0
            bne *               * branch if Z clear  

            
            * EA = (An)  - BYTE only
            move.l #0,  d5              * populate bit number to test
            move.l #1,  d6              * populate bit number to test
            move.l #7,  d7              * populate bit number to test           
            move.l #$00000100 , a0      * point to memory to address 0x100
            move.b #$81 , (a0)          * populate test data
            bclr.b d5 , (a0)            
            beq *               * branch if Z set
            bclr.b d6 , (a0)            * 
            bne *               * branch if Z clear  
            bclr.b d7 , (a0)            * 
            beq *               * branch if Z set
            cmpi.b #$00 , (a0)
            bne *               * branch if Z clear  
            
    
            * EA = (An)+  - BYTE only
            move.l #$00000100 , a0      * point to memory to address 0x100 
            move.b #$01 , (a0)+         * populate test data
            move.b #$FC , (a0)+         * populate test data
            move.b #$80 , (a0)+         * populate test data
            move.l #$00000100 , a0      * point to memory to address 0x100 
            bclr.b d5 , (a0)+            
            beq *               * branch if Z set
            bclr.b d6 , (a0)+           * 
            bne *               * branch if Z clear  
            bclr.b d7 , (a0)+           * 
            beq *               * branch if Z set
            move.l #$00000100 , a0      * point to memory to address 0x100 
            cmpi.b #$00 , (a0)+
            bne *               * branch if Z clear  
            cmpi.b #$FC , (a0)+
            bne *               * branch if Z clear  
            cmpi.b #$00 , (a0)+
            bne *               * branch if Z clear  
                
            * EA = -(An)  - BYTE only
            move.l #$00000100 , a0      * point to memory to address
            move.b #$80 , (a0)+         * populate test data
            move.b #$FC , (a0)+         * populate test data
            move.b #$01 , (a0)+         * populate test data
            move.l #$00000103 , a0      * point to memory to address 
            bclr.b d5 , -(a0)            
            beq *               * branch if Z set
            bclr.b d6 , -(a0)           * 
            bne *               * branch if Z clear  
            bclr.b d7 , -(a0)           * 
            beq *               * branch if Z set
            move.l #$00000103 , a0      * point to memory to address 0x100 
            cmpi.b #$00 , -(a0)
            bne *               * branch if Z clear  
            cmpi.b #$FC , -(a0)
            bne *               * branch if Z clear  
            cmpi.b #$00 , -(a0)
            bne *               * branch if Z clear  
                
            * EA = n(An)  - BYTE only
            move.l #$00000100 , a0      * point to memory to address
            move.b #$01 , (a0)+         * populate test data
            move.b #$FC , (a0)+         * populate test data
            move.b #$80 , (a0)+         * populate test data
            move.l #$00000100 , a0      * point to memory to address
            bclr.b d5 , 0(a0)            
            beq *               * branch if Z set
            bclr.b d6 , 1(a0)           * 
            bne *               * branch if Z clear  
            bclr.b d7 , 2(a0)           * 
            beq *               * branch if Z set
            move.l #$00000100 , a0      * point to memory to address 0x100 
            cmpi.b #$00 , (a0)+
            bne *               * branch if Z clear  
            cmpi.b #$FC , (a0)+
            bne *               * branch if Z clear  
            cmpi.b #$00 , (a0)+
            bne *               * branch if Z clear  
                
            * EA = n(An,R.W)  - BYTE only
            move.l #$00000100 , a0      * point to memory to address
            move.b #$FF , (a0)+         * populate test data
            move.b #$FF , (a0)+         * populate test data
            move.b #$FF , (a0)+         * populate test data
            move.l #$00000103 , a0      * point to memory to address 
            move.l #$00000100 , a0      * point to memory to address
            move.l #$00000000 , a1      * point to memory to address
            move.l #$00000001 , a2      * point to memory to address
            move.l #$00000000 , d0      * point to memory to address
            move.l #$00000001 , d1      * point to memory to address
            bclr.b d5 , 0(a0,d0.w)            
            beq *               * branch if Z set
            bclr.b d6 , 0(a0,d1.w)      * 
            beq *               * branch if Z set
            bclr.b d7 , 1(a0,d1.w)      * 
            beq *               * branch if Z set
            * EA = n(An,R.L)  - BYTE only
            bclr.b d5 , 0(a0,d0.l)  
            bne *               * branch if Z clear  
            bclr.b d6 , 0(a0,d1.l)      * 
            bne *               * branch if Z clear  
            bclr.b d7 , 1(a0,d1.l)      * 
            bne *               * branch if Z clear  
            * EA = n(An,A.W)  - BYTE only
            bclr.b d5 , 0(a0,a1.w)            
            bne *               * branch if Z clear  
            bclr.b d6 , 0(a0,a2.w)      * 
            bne *               * branch if Z clear  
            bclr.b d7 , 1(a0,a2.w)      * 
            bne *               * branch if Z clear  
            * EA = n(An,A.L)  - BYTE only
            bclr.b d5 , 0(a0,a1.l)  
            bne *               * branch if Z clear  
            bclr.b d6 , 0(a0,a2.l)      * 
            bne *               * branch if Z clear  
            bclr.b d7 , 1(a0,a2.l)      * 
            bne *               * branch if Z clear  
            move.l #$00000100 , a0      * point to memory to address 
            cmpi.b #$FE , (a0)
            bne *               * branch if Z clear  
            
            * EA = x.W  - BYTE only
            move.l #$00000100 , a0      * point to memory to address
            move.b #$FF , (a0)+         * populate test data
            move.b #$FF , (a0)+         * populate test data
            move.b #$FF , (a0)+         * populate test data
            bclr.b d5 , $0100            
            beq *               * branch if Z set
            bclr.b d6 , $0101           * 
            beq *               * branch if Z set
            bclr.b d7 , $0102           * 
            beq *               * branch if Z set
            move.l #$00000100 , a0      * point to memory to address
            cmpi.b #$FE , (a0)+
            bne *               * branch if Z clear  
                    
            * EA = x.L  - BYTE only
            move.l #$000F0100 , a0      * point to memory to address 0x100 
            move.b #$01 , (a0)+         * populate test data
            move.b #$FC , (a0)+         * populate test data
            move.b #$80 , (a0)+         * populate test data
            bclr.b d5 , $000F0100 
            beq *               * branch if Z set
            bclr.b d6 , $000F0101       * 
            bne *               * branch if Z clear  
            bclr.b d7 , $000F0102       * 
            beq *               * branch if Z set
            move.l #$000F0101 , a0      * point to memory to address 0x100 
            cmpi.b #$FC , (a0)
            bne *               * branch if Z clear  
                    


    rts
    




  
*-----------------------------------------------------------
*-----------------------------------------------------------
* OPCODE : BSET
*-----------------------------------------------------------
*-----------------------------------------------------------
op_BSET: 


*  Bit Number Static 
    
            * EA = Dn  - LONG only
            move.l #$00000000 , d0      * populate test data
            bset.l #0 , d0              
            bne BSET_FAIL               * branch if Z clear  
            bset.l #1 , d0              * 
            bne BSET_FAIL               * branch if Z clear  
            bset.l #15 , d0             * 
            bne BSET_FAIL               * branch if Z clear  
            bset.l #31 , d0             * 
            bne BSET_FAIL               * branch if Z clear  
            cmpi.l #$80008003 , d0
            bne BSET_FAIL               * branch if Z clear  

            
            * EA = (An)  - BYTE only
            move.l #$00000100 , a0      * point to memory to address 0x100
            move.b #$00 , (a0)          * populate test data
            bset.b #0 , (a0)            
            bne BSET_FAIL               * branch if Z clear  
            bset.b #7 , (a0)            * 
            bne BSET_FAIL               * branch if Z clear  
            cmpi.b #$81 , (a0)
            bne BSET_FAIL               * branch if Z clear  
            
            * EA = (An)+  - BYTE only
            move.l #$00000100 , a0      * point to memory to address 0x100 
            move.b #$00 , (a0)+         * populate test data
            move.b #$00 , (a0)+         * populate test data
            move.l #$00000100 , a0      * point to memory to address 0x100 
            bset.b #0 , (a0)+            
            bne BSET_FAIL               * branch if Z clear  
            bset.b #1 , (a0)+           * 
            bne BSET_FAIL               * branch if Z clear  
            move.l #$00000100 , a0      * point to memory to address 0x100 
            cmpi.b #$01 , (a0)+
            bne BSET_FAIL               * branch if Z clear  
            cmpi.b #$02 , (a0)+
            bne BSET_FAIL               * branch if Z clear  
 
        
            * EA = -(An)  - BYTE only
            move.l #$00000100 , a0      * point to memory to address
            move.b #$00 , (a0)+         * populate test data
            move.b #$00 , (a0)+         * populate test data
            bset.b #7 , -(a0)            
            bne BSET_FAIL               * branch if Z clear  
            bset.b #0 , -(a0)           * 
            bne BSET_FAIL               * branch if Z clear  
            move.l #$00000102 , a0      * point to memory to address 0x100 
            cmpi.b #$80 , -(a0)
            bne BSET_FAIL               * branch if Z clear  
            cmpi.b #$01 , -(a0)
            bne BSET_FAIL               * branch if Z clear  

        
            * EA = n(An)  - BYTE only
            move.l #$00000100 , a0      * point to memory to address
            move.b #$00 , (a0)+         * populate test data
            move.b #$00 , (a0)+         * populate test data
            move.l #$00000100 , a0      * point to memory to address
            bset.b #0 , 0(a0)            
            bne BSET_FAIL               * branch if Z clear  
            bset.b #4 , 1(a0)           * 
            bne BSET_FAIL               * branch if Z clear  
            move.l #$00000100 , a0      * point to memory to address 0x100 
            cmpi.b #$01 , (a0)+
            bne BSET_FAIL               * branch if Z clear  
            cmpi.b #$10 , (a0)+
            bne BSET_FAIL               * branch if Z clear  

                
            * EA = n(An,D.W)  - BYTE only
            move.l #$00000100 , a0      * point to memory to address
            move.l #$00000000 , a1      * point to memory to address
            move.l #$00000004 , a2      * point to memory to address
            move.l #$00000000 , d0      * point to memory to address
            move.l #$00000001 , d1      * point to memory to address
            move.b #$00 , (a0)+         * populate test data
            move.b #$00 , (a0)+         * populate test data
            move.b #$00 , (a0)+         * populate test data
            move.b #$00 , (a0)+         * populate test data
            move.b #$00 , (a0)+         * populate test data
            move.b #$00 , (a0)+         * populate test data
            move.b #$00 , (a0)+         * populate test data
            move.b #$00 , (a0)+         * populate test data
            move.b #$00 , (a0)+         * populate test data
            move.b #$00 , (a0)+         * populate test data
            move.l #$00000100 , a0      * point to memory to address
            bset.b #0 , 0(a0,d0.w)            
            bne BSET_FAIL               * branch if Z clear  
            bset.b #1 , 0(a0,d1.w)      * 
            bne BSET_FAIL               * branch if Z clear  
            bset.b #2 , 1(a0,d1.w)      * 
            bne BSET_FAIL               * branch if Z clear  
            * EA = n(An,D.L)  - BYTE only
            bset.b #3 , 2(a0,d0.l)  
            bne BSET_FAIL               * branch if Z clear  
            bset.b #4 , 0(a0,d1.l)      * 
            bne BSET_FAIL               * branch if Z clear  
            bset.b #5 , 1(a0,d1.l)      * 
            bne BSET_FAIL               * branch if Z clear  
            * EA = n(An,A.W)  - BYTE only
            bset.b #6 , 0(a0,a1.w)            
            bne BSET_FAIL               * branch if Z clear  
            bset.b #1 , 0(a0,a2.w)      * 
            bne BSET_FAIL               * branch if Z clear  
            bset.b #7 , 1(a0,a2.w)      * 
            bne BSET_FAIL               * branch if Z clear  
            * EA = n(An,A.L)  - BYTE only
            bset.b #0 , 2(a0,a2.l)  
            bne BSET_FAIL               * branch if Z clear  
            bset.b #0 , 3(a0,a2.l)      * 
            bne BSET_FAIL               * branch if Z clear  
            bset.b #1 , 4(a0,a2.l)      * 
            bne BSET_FAIL               * branch if Z clear  
            move.l #$00000100 , a0      * point to memory to address 0x100 
            cmpi.l #$41122C00 , (a0)+
            bne BSET_FAIL               * branch if Z clear  
            cmpi.l #$02800101 , (a0)+
            bne *
 

        
            * EA = x.W  - BYTE only
            move.l #$00000100 , a0      * point to memory to address
            move.b #$00 , (a0)+         * populate test data
            bset.b #0 , $0100            
            bne BSET_FAIL               * branch if Z clear  
            bset.b #1 , $0100           * 
            bne BSET_FAIL               * branch if Z clear  
            move.l #$00000100 , a0      * point to memory to address 0x100 
            cmpi.b #$03 , (a0)+
            bne *

            
            * EA = x.L  - BYTE only
            move.l #$000F0100 , a0      * point to memory to address 0x100 
            move.b #$00 , (a0)          * populate test data
            bset.b #0 , $000F0100 
            bne BSET_FAIL               * branch if Z clear  
            bset.b #1 , $000F0100       * 
            bne BSET_FAIL               * branch if Z clear  
            bset.b #2 , $000F0100       * 
            bne BSET_FAIL               * branch if Z clear  
            move.l #$000F0100 , a0      * point to memory to address 0x100 
            cmpi.b #$07 , (a0)+
            bne *


* Bit Number Dynamic
    
            * EA = Dn  - LONG only
            move.l #$00000000 , d0      * populate test data
            move.l #0,  d5              * populate bit number to test
            move.l #1,  d6              * populate bit number to test
            move.l #31, d7              * populate bit number to test
            
            bset.l d5 , d0              
            bne BSET_FAIL               * branch if Z clear  
            bset.l d6 , d0              * 
            bne BSET_FAIL               * branch if Z clear  
            bset.l d7 , d0             * 
            bne BSET_FAIL               * branch if Z clear  
            cmpi.l #$80000003 , d0
            bne BSET_FAIL               * branch if Z clear  

            
            * EA = (An)  - BYTE only
            move.l #0,  d5              * populate bit number to test
            move.l #1,  d6              * populate bit number to test
            move.l #7,  d7              * populate bit number to test           
            move.l #$00000100 , a0      * point to memory to address 0x100
            move.b #$00 , (a0)          * populate test data
            bset.b d5 , (a0)            
            bne BSET_FAIL               * branch if Z clear  
            bset.b d6 , (a0)            * 
            bne BSET_FAIL               * branch if Z clear  
            bset.b d7 , (a0)            * 
            bne BSET_FAIL               * branch if Z clear  
            cmpi.b #$83 , (a0)
            bne BSET_FAIL               * branch if Z clear  
            
    
            * EA = (An)+  - BYTE only
            move.l #$00000100 , a0      * point to memory to address 0x100 
            move.b #$00 , (a0)+         * populate test data
            move.b #$00 , (a0)+         * populate test data
            move.b #$00 , (a0)+         * populate test data
            move.l #$00000100 , a0      * point to memory to address 0x100 
            bset.b d5 , (a0)+            
            bne BSET_FAIL               * branch if Z clear  
            bset.b d6 , (a0)+           * 
            bne BSET_FAIL               * branch if Z clear  
            bset.b d7 , (a0)+           * 
            bne BSET_FAIL               * branch if Z clear  
            move.l #$00000100 , a0      * point to memory to address 0x100 
            cmpi.b #$01 , (a0)+
            bne BSET_FAIL               * branch if Z clear  
            cmpi.b #$02 , (a0)+
            bne BSET_FAIL               * branch if Z clear  
            cmpi.b #$80 , (a0)+
            bne BSET_FAIL               * branch if Z clear  
                
            * EA = -(An)  - BYTE only
            move.l #$00000100 , a0      * point to memory to address
            move.b #$00 , (a0)+         * populate test data
            move.b #$00 , (a0)+         * populate test data
            move.b #$00 , (a0)+         * populate test data
            move.l #$00000103 , a0      * point to memory to address 
            bset.b d5 , -(a0)            
            bne BSET_FAIL               * branch if Z clear  
            bset.b d6 , -(a0)           * 
            bne BSET_FAIL               * branch if Z clear  
            bset.b d7 , -(a0)           * 
            bne BSET_FAIL               * branch if Z clear  
            move.l #$00000103 , a0      * point to memory to address 0x100 
            cmpi.b #$01 , -(a0)
            bne BSET_FAIL               * branch if Z clear  
            cmpi.b #$02 , -(a0)
            bne BSET_FAIL               * branch if Z clear  
            cmpi.b #$80 , -(a0)
            bne BSET_FAIL               * branch if Z clear  
                
            * EA = n(An)  - BYTE only
            move.l #$00000100 , a0      * point to memory to address
            move.b #$00 , (a0)+         * populate test data
            move.b #$00 , (a0)+         * populate test data
            move.b #$00 , (a0)+         * populate test data
            move.l #$00000100 , a0      * point to memory to address
            bset.b d5 , 0(a0)            
            bne BSET_FAIL               * branch if Z clear  
            bset.b d6 , 1(a0)           * 
            bne BSET_FAIL               * branch if Z clear  
            bset.b d7 , 2(a0)           * 
            bne BSET_FAIL               * branch if Z clear  
            move.l #$00000100 , a0      * point to memory to address 0x100 
            cmpi.b #$01 , (a0)+
            bne BSET_FAIL               * branch if Z clear  
            cmpi.b #$02 , (a0)+
            bne BSET_FAIL               * branch if Z clear  
            cmpi.b #$80 , (a0)+
            bne BSET_FAIL               * branch if Z clear  
                
            * EA = n(An,R.W)  - BYTE only
            move.l #$00000100 , a0      * point to memory to address
            move.b #$00 , (a0)+         * populate test data
            move.b #$00 , (a0)+         * populate test data
            move.b #$00 , (a0)+         * populate test data
            move.b #$00 , (a0)+         * populate test data
            move.b #$00 , (a0)+         * populate test data
            move.b #$00 , (a0)+         * populate test data
            move.b #$00 , (a0)+         * populate test data
            move.b #$00 , (a0)+         * populate test data
            move.b #$00 , (a0)+         * populate test data
            move.b #$00 , (a0)+         * populate test data
            move.b #$00 , (a0)+         * populate test data
            move.b #$00 , (a0)+         * populate test data
            move.l #$00000100 , a0      * point to memory to address
            move.l #$00000000 , a1      * point to memory to address
            move.l #$00000001 , a2      * point to memory to address
            move.l #$00000000 , d0      * point to memory to address
            move.l #$00000001 , d1      * point to memory to address
            bset.b d5 , 0(a0,d0.w)            
            bne BSET_FAIL               * branch if Z clear  
            bset.b d6 , 0(a0,d1.w)      * 
            bne BSET_FAIL               * branch if Z clear  
            bset.b d7 , 1(a0,d1.w)      * 
            bne BSET_FAIL               * branch if Z clear  
            * EA = n(An,R.L)  - BYTE only
            bset.b d5 , 2(a0,d0.l)  
            bne BSET_FAIL               * branch if Z clear  
            bset.b d6 , 3(a0,d1.l)      * 
            bne BSET_FAIL               * branch if Z clear  
            bset.b d7 , 4(a0,d1.l)      * 
            bne BSET_FAIL               * branch if Z clear  
            * EA = n(An,A.W)  - BYTE only
            bset.b d5 , 5(a0,a1.w)            
            bne BSET_FAIL               * branch if Z clear  
            bset.b d6 , 6(a0,a2.w)      * 
            bne BSET_FAIL               * branch if Z clear  
            bset.b d7 , 7(a0,a2.w)      * 
            bne BSET_FAIL               * branch if Z clear  
            * EA = n(An,A.L)  - BYTE only
            bset.b d5 , 8(a0,a1.l)  
            bne BSET_FAIL               * branch if Z clear  
            bset.b d6 , 9(a0,a2.l)      * 
            bne BSET_FAIL               * branch if Z clear  
            bset.b d7 , 10(a0,a2.l)      * 
            bne BSET_FAIL               * branch if Z clear  
            move.l #$00000100 , a0      * point to memory to address 0x100 
            cmpi.l #$01028100 , (a0)+
            bne BSET_FAIL               * branch if Z clear  
            cmpi.l #$02810002 , (a0)+
            bne *
 
            
            * EA = x.W  - BYTE only
            move.l #$00000100 , a0      * point to memory to address
            move.b #$00 , (a0)+         * populate test data
            move.b #$00 , (a0)+         * populate test data
            move.b #$00 , (a0)+         * populate test data
            bset.b d5 , $0100            
            bne BSET_FAIL               * branch if Z clear  
            bset.b d6 , $0100           * 
            bne BSET_FAIL               * branch if Z clear  
            bset.b d7 , $0100           * 
            bne BSET_FAIL               * branch if Z clear  
            move.l #$00000100 , a0      * point to memory to address
            cmpi.b #$83 , (a0)+
            bne BSET_FAIL               * branch if Z clear  
                    
            * EA = x.L  - BYTE only
            move.l #$000F0100 , a0      * point to memory to address 0x100 
            move.b #$00 , (a0)+         * populate test data
            move.b #$00 , (a0)+         * populate test data
            move.b #$00 , (a0)+         * populate test data
            bset.b d5 , $000F0100 
            bne BSET_FAIL               * branch if Z clear  
            bset.b d6 , $000F0100       * 
            bne BSET_FAIL               * branch if Z clear  
            bset.b d7 , $000F0100       * 
            bne BSET_FAIL               * branch if Z clear  
            move.l #$000F0100 , a0      * point to memory to address 0x100 
            cmpi.b #$83 , (a0)
            bne BSET_FAIL               * branch if Z clear  
                    

    rts
    
BSET_FAIL: bra BSET_FAIL


*-----------------------------------------------------------
*-----------------------------------------------------------
* OPCODE : MOVEP
*-----------------------------------------------------------
*-----------------------------------------------------------
op_MOVEP: 

* Dn --> x(An)
            move.l #$00000100 , a0  
            move.l #$12345678 , d0  
            move.l #$AABBCCDD , d1  
            move.l #0 , (a0)
            move.l #0 , 4(a0)
            
            movep.w d0 , 0(a0)      * even offset   
            movep.w d1 , 1(a0)      * odd offset
            
            movep.l d0 , 4(a0)      * even offset   
            movep.l d1 , 5(a0)      * odd offset
            
            cmpi.l #$56CC78DD , (a0)
            bne *
            cmpi.l #$12AA34BB , 4(a0)
            bne *
            cmpi.l #$56CC78DD , 8(a0)
            bne *
            
            
* x(An)--> Dn
            move.l #$5a5a5a5a , d0  
            move.l #$5a5a5a5a , d1  
            move.l #$5a5a5a5a , d2  
            move.l #$5a5a5a5a , d3  
            
            movep.w 0(a0) , d0      * even offset   
            movep.w 1(a0) , d1      * odd offset
            
            movep.l 4(a0) , d2      * even offset   
            movep.l 5(a0) , d3      * odd offset
            
            cmpi.l #$5a5a5678 , d0
            bne *
            cmpi.l #$5a5aCCDD , d1
            bne *
            cmpi.l #$12345678 , d2
            bne *
            cmpi.l #$AABBCCDD , d3
            bne *
    
            rts
     
    

*-----------------------------------------------------------
*-----------------------------------------------------------
* OPCODE : BOOL_I
*-----------------------------------------------------------
*-----------------------------------------------------------
op_BOOL_I: 
        
    * Dn -- BYTE
            move.l #$12345678 , d0  
            move.w #$000F, CCR          * pre-set Flags
            ori.b  #$FF , d0
            eori.b #$5A , d0
            and.b  #$F0 , d0
            bvs *                       * Check V,C are cleared
            bcs *
            bpl *                       * Verify if N flag is set
            and.b  #$00 , d0
            bmi *                       * Verify if N flag is cleared
            bne *                       * Verify if Z flag is set

    * Dn -- WORD
            move.l #$12345678 , d1  
            move.w #$000F, CCR          * pre-set Flags
            ori.w  #$FFFF , d1
            eori.w #$5A5A , d1
            and.w  #$F0F0 , d1
            bvs *                       * Check V,C are cleared
            bcs *
            bpl *                       * Verify if N flag is set
            and.w  #$0000 , d1
            bmi *                       * Verify if N flag is cleared
            bne *                       * Verify if Z flag is set

    * Dn -- LONG
            move.l #$12345678 , d2  
            move.w #$000F, CCR          * pre-set Flags
            ori.l  #$FFFFFFFF , d2
            eori.l #$5A5A5A5A , d2
            and.l  #$F0F0F0F0 , d2
            bvs *                       * Check V,C are cleared
            bcs *
            bpl *                       * Verify if N flag is set
            and.l  #$00000000 , d2
            bmi *                       * Verify if N flag is cleared
            bne *                       * Verify if Z flag is set

    
    * (An) -- BYTE
            move.l #$00000100 , a0  
            move.l #$12345678 , (a0)  
            move.w #$000F, CCR          * pre-set Flags
            ori.b  #$FF , (a0)
            eori.b #$5A , (a0)
            and.b  #$F0 , (a0)
            bvs *                       * Check V,C are cleared
            bcs *
            bpl *                       * Verify if N flag is set
            and.b  #$00 , (a0)
            bmi *                       * Verify if N flag is cleared
            bne *                       * Verify if Z flag is set
            cmpi.b #$00 , (a0)
            bne *                       * Verify if Z flag is set
            
    * (An) -- WORD
            move.l #$12345678 , (a0)  
            move.w #$000F, CCR          * pre-set Flags
            ori.w  #$FFFF , (a0)
            eori.w #$5A5A , (a0)
            and.w  #$F0F0 , (a0)
            bvs *                       * Check V,C are cleared
            bcs *
            bpl *                       * Verify if N flag is set
            and.w  #$0000 , (a0)
            bmi *                       * Verify if N flag is cleared
            bne *                       * Verify if Z flag is set
            cmpi.w #$00 , (a0)
            bne *                       * Verify if Z flag is set
            
    * (An) -- LONG
            move.l #$12345678 , (a0)  
            move.w #$000F, CCR          * pre-set Flags
            ori.l  #$FFFFFFFF , (a0)
            eori.l #$5A5A5A5A , (a0)
            and.l  #$F0F0F0F0 , (a0)
            bvs *                       * Check V,C are cleared
            bcs *
            bpl *                       * Verify if N flag is set
            and.l  #$00000000 , (a0)
            bmi *                       * Verify if N flag is cleared
            bne *                       * Verify if Z flag is set
            cmpi.l #$00 , (a0)
            bne *                       * Verify if Z flag is set
            


    * (An)+ -- BYTE
            move.l #$00000100 , a0  
            move.l #$00A5FF88 , (a0)  
            move.w #$000F, CCR          * pre-set Flags
            
            ori.b  #$F5 , (a0)+
            bpl *                       * Verify if N flag is set
            beq *                       * Verify if Z flag is cleared
            
            eori.b #$FF , (a0)+
            bmi *                       * Verify if N flag is cleared
            beq *                       * Verify if Z flag is cleared
            
            and.b  #$AA , (a0)+
            bpl *                       * Verify if N flag is set
            beq *                       * Verify if Z flag is cleared
            
            move.l #$00000100 , a0  
            cmpi.l #$F55AAA88 , (a0)
            bne *                       * Verify if Z flag is set
            
            
    * (An)+ -- WORD
            move.l #$00000100 , a0  
            move.l #$00000104 , a1  
            move.l #$00005a5a , (a0)  
            move.l #$12345678 , (a1)  
            move.w #$000F, CCR          * pre-set Flags
            
            ori.w  #$5678 , (a0)+
            bmi *                       * Verify if N flag is cleared
            beq *                       * Verify if Z flag is cleared
            
            eori.w #$FFFF , (a0)+
            bpl *                       * Verify if N flag is set
            beq *                       * Verify if Z flag is cleared
            
            and.w  #$A55A , (a0)+
            bmi *                       * Verify if N flag is cleared
            beq *                       * Verify if Z flag is cleared
            
            move.l #$00000100 , a0  
            cmpi.l #$5678a5a5 , (a0)
            move.l #$00000104 , a0  
            cmpi.l #$00105678 , (a0)
            bne *                       * Verify if Z flag is set
            
    * (An)+ -- LONG
            move.l #$00000100 , a0  
            move.l #$00000000 , (a0)+  
            move.l #$5a5a5a5a , (a0)+  
            move.l #$FFFFFFFF , (a0)+  
            move.l #$00000100 , a0  
            move.w #$000F, CCR          * pre-set Flags
            
            ori.l  #$12345678 , (a0)+
            bmi *                       * Verify if N flag is cleared
            beq *                       * Verify if Z flag is cleared
            
            eori.l #$FFFFFFFF , (a0)+
            bpl *                       * Verify if N flag is set
            beq *                       * Verify if Z flag is cleared
            
            and.l  #$A5A5A55A , (a0)+
            bpl *                       * Verify if N flag is set
            beq *                       * Verify if Z flag is cleared
            
            move.l #$00000100 , a0  
            cmpi.l #$12345678 , (a0)+
            cmpi.l #$a5a5a5a5 , (a0)+
            cmpi.l #$a5a5a55a , (a0)+
            bne *                       * Verify if Z flag is set
            
            rts


*-----------------------------------------------------------
*-----------------------------------------------------------
* OPCODE : BSR
*-----------------------------------------------------------
*-----------------------------------------------------------

     
BSR_CLOSE1:     move.l #$11111111 , d1
                rts
 


op_BSR:         bsr.s BSR_CLOSE1        * Negative 8-bit displacement
                bsr.s BSR_CLOSE2        * Positive 8-bit displacement
                bsr.w BSR_FAR1          * Negative 16-bit displacement
                bsr.w BSR_FAR2          * Positive 16-bit displacement
                
                cmpi.l #$11111111 , d1
                bne *
                cmpi.l #$22222222 , d2
                bne *
                cmpi.l #$33333333 , d3
                bne *
                cmpi.l #$44444444 , d4
                bne *
                   
                rts   
                
                
BSR_CLOSE2:     move.l #$22222222 , d2
                rts

*-----------------------------------------------------------
*-----------------------------------------------------------
* OPCODE : op_CMP_I
*-----------------------------------------------------------
*-----------------------------------------------------------
op_CMP_I: 

            move.l #$00000100 , a0 
            move.l #$00000100 , (a0) 
 
    * REGISTER - BYTE
            move.l #$FFFFFF80 , d0  
            cmpi.b #$80 , d0
            bne *                       * Check Z Flag  beq/bne
            bmi *                       * Check N Flag  bmi/bpl
            bcs *                       * Check C Flag  bcc/bcs
            bvs *                       * Check V Flag  bvc/bvs
            
            move.l #$FFFFF000 , d1  
            cmpi.b #$00 , d1
            bne *                       * Check Z Flag  beq/bne
            bmi *                       * Check N Flag  bmi/bpl
            bcs *                       * Check C Flag  bcc/bcs
            bvs *                       * Check V Flag  bvc/bvs
            
            move.l #$FFFFFF02 , d2  
            cmpi.b #$FF , d2
            beq *                       * Check Z Flag  beq/bne
            bmi *                       * Check N Flag  bmi/bpl
            bcc *                       * Check C Flag  bcc/bcs
            bvs *                       * Check V Flag  bvc/bvs
                
            move.l #$FFFFFF7F , d3  
            cmpi.b #$FF , d3
            beq *                       * Check Z Flag  beq/bne
            bpl *                       * Check N Flag  bmi/bpl
            bcc *                       * Check C Flag  bcc/bcs
            bvc *                       * Check V Flag  bvc/bvs
         
         
    * REGISTER - WORD
            move.l #$FFFF8000 , d0  
            cmpi.w #$8000 , d0
            bne *                       * Check Z Flag  beq/bne
            bmi *                       * Check N Flag  bmi/bpl
            bcs *                       * Check C Flag  bcc/bcs
            bvs *                       * Check V Flag  bvc/bvs
            
            move.l #$FFF00000 , d1  
            cmpi.w #$0000 , d1
            bne *                       * Check Z Flag  beq/bne
            bmi *                       * Check N Flag  bmi/bpl
            bcs *                       * Check C Flag  bcc/bcs
            bvs *                       * Check V Flag  bvc/bvs
            
            move.l #$FFFF0002 , d2  
            cmpi.w #$FFFF , d2
            beq *                       * Check Z Flag  beq/bne
            bmi *                       * Check N Flag  bmi/bpl
            bcc *                       * Check C Flag  bcc/bcs
            bvs *                       * Check V Flag  bvc/bvs
                
            move.l #$FFFF7FFF , d3  
            cmpi.w #$FFFF , d3
            beq *                       * Check Z Flag  beq/bne
            bpl *                       * Check N Flag  bmi/bpl
            bcc *                       * Check C Flag  bcc/bcs
            bvc *                       * Check V Flag  bvc/bvs
            
    * REGISTER - LONG
            move.l #$80000000 , d0  
            cmpi.l #$80000000 , d0
            bne *                       * Check Z Flag  beq/bne
            bmi *                       * Check N Flag  bmi/bpl
            bcs *                       * Check C Flag  bcc/bcs
            bvs *                       * Check V Flag  bvc/bvs
            
            move.l #$00000000 , d1  
            cmpi.l #$00000000 , d1
            bne *                       * Check Z Flag  beq/bne
            bmi *                       * Check N Flag  bmi/bpl
            bcs *                       * Check C Flag  bcc/bcs
            bvs *                       * Check V Flag  bvc/bvs
            
            move.l #$00000002 , d2  
            cmpi.l #$FFFFFFFF , d2
            beq *                       * Check Z Flag  beq/bne
            bmi *                       * Check N Flag  bmi/bpl
            bcc *                       * Check C Flag  bcc/bcs
            bvs *                       * Check V Flag  bvc/bvs
                
            move.l #$7FFFFFFF , d3  
            cmpi.l #$FFFFFFFF , d3
            beq *                       * Check Z Flag  beq/bne
            bpl *                       * Check N Flag  bmi/bpl
            bcc *                       * Check C Flag  bcc/bcs
            bvc *                       * Check V Flag  bvc/bvs
            
            
            

    * EA=x(An,Dn) - BYTE
            move.l #$00000100 , a0  
            move.l #$00000004 , d7  
            
            move.l #$FFFFFF80 , 12(a0,d7)
            move.l #$FFFFFF80 , 12(a0,d7)
            cmpi.b #$80 , 15(a0,d7)
            bne *                       * Check Z Flag  beq/bne
            bmi *                       * Check N Flag  bmi/bpl
            bcs *                       * Check C Flag  bcc/bcs
            bvs *                       * Check V Flag  bvc/bvs
            
            move.l #$FFFFF000 , 12(a0,d7)
            cmpi.b #$00 , 15(a0,d7)
            bne *                       * Check Z Flag  beq/bne
            bmi *                       * Check N Flag  bmi/bpl
            bcs *                       * Check C Flag  bcc/bcs
            bvs *                       * Check V Flag  bvc/bvs
            
            move.l #$FFFFFF02 , 12(a0,d7)
            cmpi.b #$FF , 15(a0,d7)
            beq *                       * Check Z Flag  beq/bne
            bmi *                       * Check N Flag  bmi/bpl
            bcc *                       * Check C Flag  bcc/bcs
            bvs *                       * Check V Flag  bvc/bvs
                
            move.l #$FFFFFF7F , 12(a0,d7)
            cmpi.b #$FF , 15(a0,d7)
            beq *                       * Check Z Flag  beq/bne
            bpl *                       * Check N Flag  bmi/bpl
            bcc *                       * Check C Flag  bcc/bcs
            bvc *                       * Check V Flag  bvc/bvs
         
         
    * EA=x(An,Dn) - WORD
            move.l #$FFFF8000 , 12(a0,d7)
            cmpi.w #$8000 , 14(a0,d7)
            bne *                       * Check Z Flag  beq/bne
            bmi *                       * Check N Flag  bmi/bpl
            bcs *                       * Check C Flag  bcc/bcs
            bvs *                       * Check V Flag  bvc/bvs
            
            move.l #$FFF00000 , 12(a0,d7)
            cmpi.w #$0000 , 14(a0,d7)
            bne *                       * Check Z Flag  beq/bne
            bmi *                       * Check N Flag  bmi/bpl
            bcs *                       * Check C Flag  bcc/bcs
            bvs *                       * Check V Flag  bvc/bvs
            
            move.l #$FFFF0002 , 12(a0,d7)
            cmpi.w #$FFFF , 14(a0,d7)
            beq *                       * Check Z Flag  beq/bne
            bmi *                       * Check N Flag  bmi/bpl
            bcc *                       * Check C Flag  bcc/bcs
            bvs *                       * Check V Flag  bvc/bvs
                
            move.l #$FFFF7FFF , 12(a0,d7)
            cmpi.w #$FFFF , 14(a0,d7)
            beq *                       * Check Z Flag  beq/bne
            bpl *                       * Check N Flag  bmi/bpl
            bcc *                       * Check C Flag  bcc/bcs
            bvc *                       * Check V Flag  bvc/bvs
            
    * EA=x(An,Dn) - LONG
            move.l #$80000000 , 12(a0,d7)
            cmpi.l #$80000000 , 12(a0,d7)
            bne *                       * Check Z Flag  beq/bne
            bmi *                       * Check N Flag  bmi/bpl
            bcs *                       * Check C Flag  bcc/bcs
            bvs *                       * Check V Flag  bvc/bvs
            
            move.l #$00000000 , 12(a0,d7)
            cmpi.l #$00000000 , 12(a0,d7)
            bne *                       * Check Z Flag  beq/bne
            bmi *                       * Check N Flag  bmi/bpl
            bcs *                       * Check C Flag  bcc/bcs
            bvs *                       * Check V Flag  bvc/bvs
            
            move.l #$00000002 , 12(a0,d7)
            cmpi.l #$FFFFFFFF , 12(a0,d7)
            beq *                       * Check Z Flag  beq/bne
            bmi *                       * Check N Flag  bmi/bpl
            bcc *                       * Check C Flag  bcc/bcs
            bvs *                       * Check V Flag  bvc/bvs
                
            move.l #$7FFFFFFF , 12(a0,d7)
            cmpi.l #$FFFFFFFF , 12(a0,d7)
            beq *                       * Check Z Flag  beq/bne
            bpl *                       * Check N Flag  bmi/bpl
            bcc *                       * Check C Flag  bcc/bcs
            bvc *                       * Check V Flag  bvc/bvs
            
            
            
            
            rts
            
            
  
*-----------------------------------------------------------
*-----------------------------------------------------------
* OPCODE : ADD_I
*-----------------------------------------------------------
*-----------------------------------------------------------
op_ADD_I: 
    
    * EA = Dn  - Byte
            move.l #$12345678 , d0      * populate test data
            addi.b #0 , d0                          
            beq *                       * Check Z Flag  beq/bne
            bmi *                       * Check N Flag  bmi/bpl
            bcs *                       * Check C Flag  bcc/bcs
            bvs *                       * Check V Flag  bvc/bvs
            addi.b #$10 , d0                            
            beq *                       * Check Z Flag  beq/bne
            bpl *                       * Check N Flag  bmi/bpl
            bcs *                       * Check C Flag  bcc/bcs
            bvc *                       * Check V Flag  bvc/bvs
            addi.b #$A5 , d0                            
            beq *                       * Check Z Flag  beq/bne
            bmi *                       * Check N Flag  bmi/bpl
            bcc *                       * Check C Flag  bcc/bcs
            bvc *                       * Check V Flag  bvc/bvs
            cmpi.b #$2D , d0                            
            bne *                       * Check Z Flag  beq/bne
            
    * EA = Dn  - WORD
            move.l #$12345678 , d0      * populate test data
            addi.w #0 , d0                          
            beq *                       * Check Z Flag  beq/bne
            bmi *                       * Check N Flag  bmi/bpl
            bcs *                       * Check C Flag  bcc/bcs
            bvs *                       * Check V Flag  bvc/bvs
            addi.w #$7000 , d0                          
            beq *                       * Check Z Flag  beq/bne
            bpl *                       * Check N Flag  bmi/bpl
            bcs *                       * Check C Flag  bcc/bcs
            bvc *                       * Check V Flag  bvc/bvs
            addi.w #$A55A , d0                          
            beq *                       * Check Z Flag  beq/bne
            bmi *                       * Check N Flag  bmi/bpl
            bcc *                       * Check C Flag  bcc/bcs
            bvc *                       * Check V Flag  bvc/bvs
            cmpi.w #$6BD2 , d0                          
            bne *                       * Check Z Flag  beq/bne
    
    * EA = Dn  - LONG
            move.l #$12345678  , d0      * populate test data
            addi.l #0 , d0                          
            beq *                       * Check Z Flag  beq/bne
            bmi *                       * Check N Flag  bmi/bpl
            bcs *                       * Check C Flag  bcc/bcs
            bvs *                       * Check V Flag  bvc/bvs
            addi.l #$F0000000 , d0                          
            beq *                       * Check Z Flag  beq/bne
            bmi *                       * Check N Flag  bmi/bpl
            bcc *                       * Check C Flag  bcc/bcs
            bvs *                       * Check V Flag  bvc/bvs
            addi.l #$855AA55A , d0                          
            beq *                       * Check Z Flag  beq/bne
            bpl *                       * Check N Flag  bmi/bpl
            bcs *                       * Check C Flag  bcc/bcs
            bvs *                       * Check V Flag  bvc/bvs
            addi.l #$A0000000 , d0                          
            bvc *                       * Check V Flag  bvc/bvs
            cmpi.l #$278EFBD2 , d0                          
            bne *                       * Check Z Flag  beq/bne
    
    

    * EA = x.L  - Byte
            move.l #$000F0100 , a0      * populate test data
            move.l #$12345678 ,(a0)     * populate test data
            addi.b #0 , $000F0103                           
            beq *                       * Check Z Flag  beq/bne
            bmi *                       * Check N Flag  bmi/bpl
            bcs *                       * Check C Flag  bcc/bcs
            bvs *                       * Check V Flag  bvc/bvs
            addi.b #$10 , $000F0103                         
            beq *                       * Check Z Flag  beq/bne
            bpl *                       * Check N Flag  bmi/bpl
            bcs *                       * Check C Flag  bcc/bcs
            bvc *                       * Check V Flag  bvc/bvs
            addi.b #$A5 , $000F0103                         
            beq *                       * Check Z Flag  beq/bne
            bmi *                       * Check N Flag  bmi/bpl
            bcc *                       * Check C Flag  bcc/bcs
            bvc *                       * Check V Flag  bvc/bvs
            cmpi.b #$2D , $000F0103                         
            bne *                       * Check Z Flag  beq/bne
            
    * EA = x.L- WORD
            move.l #$000F0100 , a0      * populate test data
            move.l #$12345678 ,(a0)     * populate test data
            addi.w #0 , $000F0100                           
            beq *                       * Check Z Flag  beq/bne
            bmi *                       * Check N Flag  bmi/bpl
            bcs *                       * Check C Flag  bcc/bcs
            bvs *                       * Check V Flag  bvc/bvs
            addi.w #$7000 , $000F0100                           
            beq *                       * Check Z Flag  beq/bne
            bpl *                       * Check N Flag  bmi/bpl
            bcs *                       * Check C Flag  bcc/bcs
            bvc *                       * Check V Flag  bvc/bvs
            addi.w #$A55A , $000F0100                           
            beq *                       * Check Z Flag  beq/bne
            bmi *                       * Check N Flag  bmi/bpl
            bcc *                       * Check C Flag  bcc/bcs
            bvc *                       * Check V Flag  bvc/bvs
            cmpi.w #$278E , $000F0100                           
            bne *                       * Check Z Flag  beq/bne
    
    * EA = x.L- LONG
            move.l #$12345678  , $000F0100  * populate test data
            addi.l #0 , $000F0100                           
            beq *                       * Check Z Flag  beq/bne
            bmi *                       * Check N Flag  bmi/bpl
            bcs *                       * Check C Flag  bcc/bcs
            bvs *                       * Check V Flag  bvc/bvs
            addi.l #$F0000000 , $000F0100                           
            beq *                       * Check Z Flag  beq/bne
            bmi *                       * Check N Flag  bmi/bpl
            bcc *                       * Check C Flag  bcc/bcs
            bvs *                       * Check V Flag  bvc/bvs
            addi.l #$855AA55A , $000F0100                           
            beq *                       * Check Z Flag  beq/bne
            bpl *                       * Check N Flag  bmi/bpl
            bcs *                       * Check C Flag  bcc/bcs
            bvs *                       * Check V Flag  bvc/bvs
            addi.l #$A0000000 , $000F0100                           
            bvc *                       * Check V Flag  bvc/bvs
            cmpi.l #$278EFBD2 , $000F0100                           
            bne *                       * Check Z Flag  beq/bne
    
            rts


*-----------------------------------------------------------
*-----------------------------------------------------------
* OPCODE : SUB_I
*-----------------------------------------------------------
*-----------------------------------------------------------
op_SUB_I: 
    
    * EA = Dn  - Byte
            move.l #$12345678 , d0      * populate test data
            subi.b #0 , d0                          
            beq *                       * Check Z Flag  beq/bne
            bmi *                       * Check N Flag  bmi/bpl
            bcs *                       * Check C Flag  bcc/bcs
            bvs *                       * Check V Flag  bvc/bvs
            subi.b #$10 , d0                            
            beq *                       * Check Z Flag  beq/bne
            bmi *                       * Check N Flag  bmi/bpl
            bcs *                       * Check C Flag  bcc/bcs
            bvs *                       * Check V Flag  bvc/bvs
            subi.b #$A5 , d0                            
            beq *                       * Check Z Flag  beq/bne
            bpl *                       * Check N Flag  bmi/bpl
            bcc *                       * Check C Flag  bcc/bcs
            bvc *                       * Check V Flag  bvc/bvs
            cmpi.b #$C3 , d0                            
            bne *                       * Check Z Flag  beq/bne
            
    * EA = Dn  - WORD
            move.l #$12345678 , d0      * populate test data
            subi.w #0 , d0                          
            beq *                       * Check Z Flag  beq/bne
            bmi *                       * Check N Flag  bmi/bpl
            bcs *                       * Check C Flag  bcc/bcs
            bvs *                       * Check V Flag  bvc/bvs
            subi.w #$7000 , d0                          
            beq *                       * Check Z Flag  beq/bne
            bpl *                       * Check N Flag  bmi/bpl
            bcc *                       * Check C Flag  bcc/bcs
            bvs *                       * Check V Flag  bvc/bvs
            subi.w #$A55A , d0                          
            beq *                       * Check Z Flag  beq/bne
            bmi *                       * Check N Flag  bmi/bpl
            bcs *                       * Check C Flag  bcc/bcs
            bvs *                       * Check V Flag  bvc/bvs
            cmpi.w #$411E , d0                          
            bne *                       * Check Z Flag  beq/bne
    
    * EA = Dn  - LONG
            move.l #$12345678  , d0      * populate test data
            subi.l #0 , d0                          
            beq *                       * Check Z Flag  beq/bne
            bmi *                       * Check N Flag  bmi/bpl
            bcs *                       * Check C Flag  bcc/bcs
            bvs *                       * Check V Flag  bvc/bvs
            subi.l #$F0000000 , d0                          
            beq *                       * Check Z Flag  beq/bne
            bmi *                       * Check N Flag  bmi/bpl
            bcc *                       * Check C Flag  bcc/bcs
            bvs *                       * Check V Flag  bvc/bvs
            subi.l #$855AA55A , d0                          
            beq *                       * Check Z Flag  beq/bne
            bpl *                       * Check N Flag  bmi/bpl
            bcc *                       * Check C Flag  bcc/bcs
            bvc *                       * Check V Flag  bvc/bvs
            subi.l #$A0000000 , d0                          
            bvs *                       * Check V Flag  bvc/bvs
            cmpi.l #$FCD9B11E , d0                          
            bne *                       * Check Z Flag  beq/bne
    
    

    * EA = x.L  - Byte
            move.l #$000F0100 , a0      * populate test data
            move.l #$12345678 ,(a0)     * populate test data
            subi.b #0 , $000F0103                           
            beq *                       * Check Z Flag  beq/bne
            bmi *                       * Check N Flag  bmi/bpl
            bcs *                       * Check C Flag  bcc/bcs
            bvs *                       * Check V Flag  bvc/bvs
            subi.b #$10 , $000F0103                         
            beq *                       * Check Z Flag  beq/bne
            bmi *                       * Check N Flag  bmi/bpl
            bcs *                       * Check C Flag  bcc/bcs
            bvs *                       * Check V Flag  bvc/bvs
            subi.b #$A5 , $000F0103                         
            beq *                       * Check Z Flag  beq/bne
            bpl *                       * Check N Flag  bmi/bpl
            bcc *                       * Check C Flag  bcc/bcs
            bvc *                       * Check V Flag  bvc/bvs
            cmpi.b #$C3 , $000F0103                         
            bne *                       * Check Z Flag  beq/bne
            
    * EA = x.L- WORD
            move.l #$000F0100 , a0      * populate test data
            move.l #$12345678 ,(a0)     * populate test data
            subi.w #0 , $000F0100                           
            beq *                       * Check Z Flag  beq/bne
            bmi *                       * Check N Flag  bmi/bpl
            bcs *                       * Check C Flag  bcc/bcs
            bvs *                       * Check V Flag  bvc/bvs
            subi.w #$7000 , $000F0100                           
            beq *                       * Check Z Flag  beq/bne
            bpl *                       * Check N Flag  bmi/bpl
            bcc *                       * Check C Flag  bcc/bcs
            bvs *                       * Check V Flag  bvc/bvs
            subi.w #$A55A , $000F0100                           
            beq *                       * Check Z Flag  beq/bne
            bpl *                       * Check N Flag  bmi/bpl
            bcc *                       * Check C Flag  bcc/bcs
            bvs *                       * Check V Flag  bvc/bvs
            cmpi.w #$FCDA , $000F0100                           
            bne *                       * Check Z Flag  beq/bne
    
    * EA = x.L- LONG
            move.l #$12345678  , $000F0100  * populate test data
            subi.l #0 , $000F0100                           
            beq *                       * Check Z Flag  beq/bne
            bmi *                       * Check N Flag  bmi/bpl
            bcs *                       * Check C Flag  bcc/bcs
            bvs *                       * Check V Flag  bvc/bvs
            subi.l #$F0000000 , $000F0100                           
            beq *                       * Check Z Flag  beq/bne
            bmi *                       * Check N Flag  bmi/bpl
            bcc *                       * Check C Flag  bcc/bcs
            bvs *                       * Check V Flag  bvc/bvs
            subi.l #$855AA55A , $000F0100                           
            beq *                       * Check Z Flag  beq/bne
            bpl *                       * Check N Flag  bmi/bpl
            bcc *                       * Check C Flag  bcc/bcs
            bvc *                       * Check V Flag  bvc/bvs
            subi.l #$A0000000 , $000F0100                           
            bvs *                       * Check V Flag  bvc/bvs
            cmpi.l #$FCD9B11E , $000F0100                           
            bne *                       * Check Z Flag  beq/bne
            
            rts
    
    

*-----------------------------------------------------------
*-----------------------------------------------------------
* OPCODE : MOVE
*-----------------------------------------------------------
*-----------------------------------------------------------
op_MOVE: 
            move.l #$11223344  , d0
            move.l #$55667788  , d1
            move.l #$8899aabb  , d2
            move.l #$ccddeeff  , d3
            move.l #$00000000  , d4
            move.l #$00000000  , d5
            move.l #$00000000  , d6
            move.l #$00000000  , d7         
            move.l #$44332211  , a0
            move.l #$88776655  , a1
            move.l #$bbaa9988  , a2
            move.l #$ffeeddcc  , a3
            
            move.b d0 , d4              * BYTE - DATA REGISTER
            beq *                       * Check Z Flag  beq/bne
            bmi *                       * Check N Flag  bmi/bpl
            cmpi.l #$00000044 , d4                          
            bne *                       * Check Z Flag  beq/bne
        
            move.w d1 , d5              * WORD - DATA REGISTER
            beq *                       * Check Z Flag  beq/bne
            bmi *                       * Check N Flag  bmi/bpl
            cmpi.l #$00007788 , d5                          
            bne *                       * Check Z Flag  beq/bne
        
            move.l d2 , d6              * LONG - DATA REGISTER
            beq *                       * Check Z Flag  beq/bne
            bpl *                       * Check N Flag  bmi/bpl
            cmpi.l #$8899aabb , d6                          
            bne *                       * Check Z Flag  beq/bne

            move.w a1 , d5              * WORD - ADDRESS REGISTER
            beq *                       * Check Z Flag  beq/bne
            bmi *                       * Check N Flag  bmi/bpl
            cmpi.l #$00006655 , d5                          
            bne *                       * Check Z Flag  beq/bne
        
            move.l a2 , d6              * LONG - ADDRESS REGISTER
            beq *                       * Check Z Flag  beq/bne
            bpl *                       * Check N Flag  bmi/bpl
            cmpi.l #$bbaa9988  , d6                         
            bne *                       * Check Z Flag  beq/bne
            
    
            movea.w d2 , a4             * WORD - ADDRESS REGISTER as SOURCE ## MOVEA
            cmpa.l d2 , a4                          
            beq *                       * Check Z Flag  beq/bne ## comopare fails because A4 was sign extended
        
            movea.l d1 , a5             * LONG - ADDRESS REGISTER as SOURCE ## MOVEA
            cmpa.l d1  , a5                         
            bne *                       * Check Z Flag  beq/bne
        


  * Too mamy EA combinations to test, so we focus on a few of the more complicted EA's 
  
            move.l #$11223344  , d0
            move.l #$00010100  , d1
            move.l #$8899aabb  , d2
            move.l #$00000001  , d3
            move.l #$00000000  , d4
            move.l #$00000000  , d5
            move.l #$00000000  , d6
            move.l #$00000000  , d7         
            move.l #$00000000  , a0
            move.l #$00010100  , a1

    * x(An,AL) --> x.L
            move.b #$5A , 4(a0,a1.l)    * BYTE 
            lea 4(a0,a1.l) , a3    
            move.b 4(a0,a1.l) , $00010105    
            beq *                       * Check Z Flag  beq/bne
            bmi *                       * Check N Flag  bmi/bpl
            cmpi.b #$5A , 5(a0,a1.l)                            
            bne *                       * Check Z Flag  beq/bne
                
    * x.L --> n(An,Dw)
MOVE2:      move.b  $00010105 , 7(a0,d1.w)    * BYTE  
            beq *                       * Check Z Flag  beq/bne
            bmi *                       * Check N Flag  bmi/bpl
            cmpi.b #$5A , 7(a0,d1.w)                            
            bne *                       * Check Z Flag  beq/bne
                
    * x(PC,Ds) --> x.w
            move.b  MOVE1(pc,d3), $0100 * BYTE  
            beq *                       * Check Z Flag  beq/bne
            bpl *                       * Check N Flag  bmi/bpl
            cmpi.b #$B9 ,1+MOVE2                            
            bne *                       * Check Z Flag  beq/bne
                    
    * #x -->    n(An,AL)
            move.b  #$78, 7(a0,d1.w)    * BYTE  
            beq *                       * Check Z Flag  beq/bne
            bmi *                       * Check N Flag  bmi/bpl
            cmpi.b #$78 ,7(a0,d1.w)                         
            bne *                       * Check Z Flag  beq/bne
        
            move.l #$11223344  , d0
            move.l #$00010100  , d1
            move.l #$8899aabb  , d2
            move.l #$00000002  , d3
            move.l #$00000000  , d4
            move.l #$00000000  , d5
            move.l #$00000000  , d6
            move.l #$00000000  , d7         
            move.l #$00000000  , a0
            move.l #$00010100  , a1
            
    * x(An,AL) --> x.L
            move.w #$5A5A , 4(a0,a1.l)    * WORD  
            lea 4(a0,a1.l) , a4    
            move.w 4(a0,a1.l) , $00010104    
            beq *                       * Check Z Flag  beq/bne
            bmi *                       * Check N Flag  bmi/bpl
            cmpi.w #$5A5A , 4(a0,a1.l)                          
            bne *                       * Check Z Flag  beq/bne
                
    * x.L --> n(An,Dw)
MOVE1:      move.w  $00010104 , 6(a0,d1.w)    * WORD  
            beq *                       * Check Z Flag  beq/bne
            bmi *                       * Check N Flag  bmi/bpl
            cmpi.w #$5A5A , 6(a0,d1.w)                          
            bne *                       * Check Z Flag  beq/bne
                
    * x(PC,Ds) --> x.w
            move.w  MOVE1(pc,d3), $0100 * WORD  
            beq *                       * Check Z Flag  beq/bne
            bmi *                       * Check N Flag  bmi/bpl
            cmpi.w #$67FE ,8+MOVE1                          
            bne *                       * Check Z Flag  beq/bne
                    
    * #x -->    n(An,AL)
            move.w  #$7878, 6(a0,d1.w)    * WORD  
            beq *                       * Check Z Flag  beq/bne
            bmi *                       * Check N Flag  bmi/bpl
            cmpi.w #$7878 ,6(a0,d1.w)                           
            bne *                       * Check Z Flag  beq/bne
        
* ---
        
            move.l #$11223344  , d0
            move.l #$00010100  , d1
            move.l #$8899aabb  , d2
            move.l #$00000002  , d3
            move.l #$00000000  , d4
            move.l #$00000000  , d5
            move.l #$00000000  , d6
            move.l #$00000000  , d7         
            move.l #$00000000  , a0
            move.l #$00010100  , a1
            
    * x(An,AL) --> x.L
            move.l #$5A5A1234 , 4(a0,a1.l)    * LONG  
            lea 4(a0,a1.l) , a4    
            move.l 4(a0,a1.l) , $00010104    
            beq *                       * Check Z Flag  beq/bne
            bmi *                       * Check N Flag  bmi/bpl
            cmpi.l #$5A5A1234 , 4(a0,a1.l)                          
            bne *                       * Check Z Flag  beq/bne
                
    * x.L --> n(An,Dw)
MOVE3:      move.l  $00010104 , 6(a0,d1.w)    * LONG  
            beq *                       * Check Z Flag  beq/bne
            bmi *                       * Check N Flag  bmi/bpl
            cmpi.l #$5A5A1234 , 6(a0,d1.w)                          
            bne *                       * Check Z Flag  beq/bne
                
    * x(PC,Ds) --> x.w
            move.l  MOVE3(pc,d3), $0100 * LONG  
            beq *                       * Check Z Flag  beq/bne
            bmi *                       * Check N Flag  bmi/bpl
            cmpi.l #$67FE6BFE ,8+MOVE3                          
            bne *                       * Check Z Flag  beq/bne
                    
    * #x -->    n(An,AL)
            move.l  #$78782323, 6(a0,d1.w)    * LONG  
            beq *                       * Check Z Flag  beq/bne
            bmi *                       * Check N Flag  bmi/bpl
            cmpi.l #$78782323 ,6(a0,d1.w)                           
            bne *                       * Check Z Flag  beq/bne
        
        
         rts

    
*-----------------------------------------------------------
*-----------------------------------------------------------
* OPCODE : MOVE_xxx_FLAGS
*-----------------------------------------------------------
*-----------------------------------------------------------
op_MOVE_xxx_FLAGS: 

    * Move_To_SR
    
    * Dn
    
            move.w #$2FFF, d0
            move d0 , SR 
            bpl *           * branch if Z clear  
            bne *           * branch if N clear
            bvc *           * branch if V clear 
            bcc *           * branch if C clear 
            move.w #$2F00, d0
            move d0 , CCR 
            beq *           * branch if Z set  
            bmi *           * branch if N set  
            bvs *           * branch if V set  
            bcs *           * branch if C set  
    
            move.w #$2000, d0
            move d0 , SR 
            beq *           * branch if Z set  
            bmi *           * branch if N set  
            bvs *           * branch if V set  
            bcs *           * branch if C set  
       
    * (An)
            move.l #$00000100, a0
            move.w #$2FFF, (a0)
            move (a0) , SR 
            bpl *           * branch if Z clear  
            bne *           * branch if N clear
            bvc *           * branch if V clear 
            bcc *           * branch if C clear 
    
            move.w #$2000,(a0)
            move (a0) , SR 
            beq *           * branch if Z set  
            bmi *           * branch if N set  
            bvs *           * branch if V set  
            bcs *           * branch if C set  
            
    * (An)+
            move.l #$00000100, a0
            move.w #$2FFF, (a0)
            move (a0)+ , SR 
            bpl *           * branch if Z clear  
            bne *           * branch if N clear
            bvc *           * branch if V clear 
            bcc *           * branch if C clear 
    
            move.w #$2000,(a0)
            move (a0)+ , SR 
            beq *           * branch if Z set  
            bmi *           * branch if N set  
            bvs *           * branch if V set  
            bcs *           * branch if C set  
                 
    * -(An)
            move.l #$00000102, a0
            move.w #$2FFF, (a0)
            move (a0)+ , SR 
            bpl *           * branch if Z clear  
            bne *           * branch if N clear
            bvc *           * branch if V clear 
            bcc *           * branch if C clear 
    
            move.w #$2000,(a0)
            move (a0)+ , SR 
            beq *           * branch if Z set  
            bmi *           * branch if N set  
            bvs *           * branch if V set  
            bcs *           * branch if C set  
                            
    * n(An)
            move.l #$00000102, a0
            move.w #$2FFF, 2(a0)
            move 2(a0) , SR 
            bpl *           * branch if Z clear  
            bne *           * branch if N clear
            bvc *           * branch if V clear 
            bcc *           * branch if C clear 
    
            move.w #$2000,2(a0)
            move 2(a0) , SR 
            beq *           * branch if Z set  
            bmi *           * branch if N set  
            bvs *           * branch if V set  
            bcs *           * branch if C set  
                                    
    * n(An,Rn.l)
            move.l #$00000100, a0
            move.l #$00000002, d0
            move.w #$2FFF, 2(a0,d0.l)
            move 2(a0,d0.l) , SR 
            bpl *           * branch if Z clear  
            bne *           * branch if N clear
            bvc *           * branch if V clear 
            bcc *           * branch if C clear 
    
            move.w #$2000, 2(a0,d0.l)
            move 2(a0,d0.l) , SR 
            beq *           * branch if Z set  
            bmi *           * branch if N set  
            bvs *           * branch if V set  
            bcs *           * branch if C set  
                                               
    * x.W
            move.w #$2FFF, $0100
            move $0100 , SR 
            bpl *           * branch if Z clear  
            bne *           * branch if N clear
            bvc *           * branch if V clear 
            bcc *           * branch if C clear 
    
            move.w #$2000, $0100
            move $0100 , SR 
            beq *           * branch if Z set  
            bmi *           * branch if N set  
            bvs *           * branch if V set  
            bcs *           * branch if C set  
                                                         
    * x.L
            move.w #$2FFF, $00010100
            move $00010100 , SR 
            bpl *           * branch if Z clear  
            bne *           * branch if N clear
            bvc *           * branch if V clear 
            bcc *           * branch if C clear 
    
MOVE4:      move.w #$2000, $00010100
            move $00010100 , SR 
            beq *           * branch if Z set  
            bmi *           * branch if N set  
            bvs *           * branch if V set  
            bcs *           * branch if C set  
                                                                   
    * x(PC)
            move MOVE4+2(pc) , SR 
            beq *           * branch if Z set  
            bmi *           * branch if N set  
            bvs *           * branch if V set  
            bcs *           * branch if C set 
                                                                   
    * x(PC,d0.l)
            move.l #$00000000, d0
            move MOVE4+2(pc,d0.l) , SR 
            beq *           * branch if Z set  
            bmi *           * branch if N set  
            bvs *           * branch if V set  
            bcs *           * branch if C set 
            move MOVE4+2(pc,d0.l) , CCR 
            beq *           * branch if Z set  
            bmi *           * branch if N set  
            bvs *           * branch if V set  
            bcs *           * branch if C set 
                                                                   
    * #x
            move #$2FFF, SR 
            bne *           * branch if Z clear  
            bpl *           * branch if N clear
            bvc *           * branch if V clear 
            bcc *           * branch if C clear 
            
            
            
 * MOVE_From_SR

            
            
    * Dn
            move #$275A, SR        * Initial value
            move SR , d0
            cmpi.w #$275A , d0
            bne *                   * branch if Z set  
                 
    * (An)
            move.l #$00000100, a0
            move #$275A, SR        * Initial value
            move SR , (a0)
            cmpi.w #$275A , (a0)
            bne *                   * branch if Z set  
                       
    * (An)+
            move.l #$00000100, a0
            move #$257A, SR        * Initial value
            move SR , (a0)+
            move.l #$00000100, a0
            cmpi.w #$257A , (a0)+
            bne *                   * branch if Z set  
                                   
    * -(An)
            move.l #$00000102, a0
            move #$2766, SR        * Initial value
            move SR , -(a0)
            move.l #$00000100, a0
            cmpi.w #$2766 , (a0)
            bne *                   * branch if Z set  
                                         
    * x(An)
            move.l #$00000102, a0
            move #$2733, SR        * Initial value
            move SR , 4(a0)
            cmpi.w #$2733 , 4(a0)
            bne *                   * branch if Z set  
                                             
    * x(An,rn)
            move.l #$00000102, a0
            move.l #$00000004, d0
            move #$275a, SR        * Initial value
            move SR , 4(a0,d0.l)
            cmpi.w #$275a , 4(a0,d0.l)
            bne *                   * branch if Z set  
                                                        
    * x.W
            move #$2777, SR        * Initial value
            move SR , $0102
            cmpi.w #$2777 , $0102
            bne *                   * branch if Z set  
                                                             
    * x.L
            move #$2777, SR        * Initial value
            move SR , $10102
            cmpi.w #$2777 , $10102
            bne *                   * branch if Z set  
            
            
            
            move #$2700, SR        * Put flags back to initial value

            rts

             
*-----------------------------------------------------------
*-----------------------------------------------------------
* OPCODE : EXT
*-----------------------------------------------------------
*-----------------------------------------------------------
op_EXT: 

            move.l #$0000007F, d0
            move.l #$00008FFF, d1
            move.l #$00000000, d2
            
            ext.w d0
            bmi *                   * Check N Flag  bmi/bpl
            beq *                   * Check Z Flag  beq/bne
            cmpi.l #$0000007F , d0
            bne *                   * branch if Z set  
            
            ext.l d1
            bpl *                   * Check N Flag  bmi/bpl
            beq *                   * Check Z Flag  beq/bne
            cmpi.l #$FFFF8FFF , d1
            bne *                   * branch if Z set  
            
            ext.l d2
            bne *                   * Check Z Flag  beq/bne


             
*-----------------------------------------------------------
*-----------------------------------------------------------
* OPCODE : SWAP
*-----------------------------------------------------------
*-----------------------------------------------------------
op_SWAP: 

            move.l #$12345678, d0
            
            swap d0
            bmi *                   * Check N Flag  bmi/bpl
            beq *                   * Check Z Flag  beq/bne
            cmpi.l #$56781234 , d0
            bne *                   * branch if Z set  



            rts
            
             
*-----------------------------------------------------------
*-----------------------------------------------------------
* OPCODE : LEA_PEA
*-----------------------------------------------------------
*-----------------------------------------------------------
op_LEAPEA: 

            move.l #$00345678, a0
            move.l #$00000000, d4
            
    * (An)      
            lea (a0) , a6
            move.l a6 , d0
            cmpi.l #$00345678, d0
            bne *                   * branch if Z set  
            pea (a0)
            cmpi.l #$00345678, (a7)
            bne *                   * branch if Z set  
            addq #4 , a7            * Restore Stack Pointer
            
    * x(An)     
            lea 4(a0) , a6
            move.l a6 , d0
            cmpi.l #$0034567C, d0
            bne *                   * branch if Z set  
            pea 4(a0)
            cmpi.l #$0034567C, (a7)
            bne *                   * branch if Z set  
            addq #4 , a7            * Restore Stack Pointer         

    * x(An,Dn.l)        
            lea 4(a0,d4) , a6
            move.l a6 , d0
            cmpi.l #$0034567C, d0
            bne *                   * branch if Z set  
            pea 4(a0,d4.l)
            cmpi.l #$0034567C, (a7)
            bne *                   * branch if Z set  
            addq #4 , a7            * Restore Stack Pointer
            
    * x.W       
            lea $1234 , a6
            move.l a6 , d0
            cmpi.w #$1234, d0
            bne *                   * branch if Z set  
            pea $1234
            cmpi.l #$00001234, (a7)
            bne *                   * branch if Z set  
            addq #4 , a7            * Restore Stack Pointer
           
    * x.L       
            lea $00345678 , a6
            move.l a6 , d0
            cmp.l a6, d0
            bne *                   * branch if Z set  
            pea $00345678
            cmpi.l #$00345678, (a7)
            bne *                   * branch if Z set  
            addq #4 , a7            * Restore Stack Pointer
           
    * x(PC)     
            lea LEA1(pc), a6
            move.l a6 , d0
            cmp.l a6, d0
            bne *                   * branch if Z set  
LEA1:       pea LEA1(pc)
            cmpi.l #$0000241E, (a7)
            beq *                   * branch if Z clear  
            addq #4 , a7            * Restore Stack Pointer



          
            move #$2700, SR        * Put flags back to initial value

            rts
    

             
*-----------------------------------------------------------
*-----------------------------------------------------------
* OPCODE : LEA_TAS
*-----------------------------------------------------------
*-----------------------------------------------------------
op_TAS: 

    * Test just one addressing mode

            move.l #$00000100, a0
            
    * (An)      
            move.b #$00 , (a0)
            bmi *                   * Check N Flag  bmi/bpl
            bne *                   * Check Z Flag  beq/bne
            tas (a0)
            cmpi.b #$80, (a0)
            bne *                   * branch if Z set  
            move.b #$F5 , (a0)
            tas (a0)
            bpl *                   * Check N Flag  bmi/bpl
            beq *                   * Check Z Flag  beq/bne
            tas (a0)
            cmpi.b #$F5, (a0)
            bne *                   * branch if Z set  

            rts
            
     
*-----------------------------------------------------------
*-----------------------------------------------------------
* OPCODE : LEA_TST
*-----------------------------------------------------------
*-----------------------------------------------------------
op_TST: 

    * Test just one addressing mode

            move.l #$00000100, a0
            
    * (An) - BYTE       
            move.b #$00 , (a0)
            tst.b (a0)
            bmi *                   * Check N Flag  bmi/bpl
            bne *                   * Check Z Flag  beq/bne
            move.b #$F5 , (a0)
            tst.b (a0)
            bpl *                   * Check N Flag  bmi/bpl
            beq *                   * Check Z Flag  beq/bne
            
    * (An) - WORD       
            move.w #$0000 , (a0)
            tst.w (a0)
            bmi *                   * Check N Flag  bmi/bpl
            bne *                   * Check Z Flag  beq/bne
            move.w #$F567 , (a0)
            tst.w (a0)
            bpl *                   * Check N Flag  bmi/bpl
            beq *                   * Check Z Flag  beq/bne
            
    * (An) - LONG       
            move.l #$00000000 , (a0)
            tst.l (a0)
            bmi *                   * Check N Flag  bmi/bpl
            bne *                   * Check Z Flag  beq/bne
            move.l #$F56789ab , (a0)
            tst.l (a0)
            bpl *                   * Check N Flag  bmi/bpl
            beq *                   * Check Z Flag  beq/bne


            rts
    
     
*-----------------------------------------------------------
*-----------------------------------------------------------
* OPCODE : LINKS
*-----------------------------------------------------------
*-----------------------------------------------------------
op_LINKS: 

            move.l #$11223344, a0
            move.l #$11223344, d0
            link a0, #$0
            cmpi.l #$11223344, (a7)
            
            unlk a0
            cmp.l d0 , a0
            bne *                   * branch if Z set  

            rts
                 
*-----------------------------------------------------------
*-----------------------------------------------------------
* OPCODE : MOVE_USP
*-----------------------------------------------------------
*-----------------------------------------------------------
op_MOVE_USP: 

            move.l #$11223344, a0
            move a0 , USP
            move USP , a1
            cmp.l a0 , a1
            bne *                   * branch if Z set  

                          
*-----------------------------------------------------------
*-----------------------------------------------------------
* OPCODE : CHK
*-----------------------------------------------------------
*-----------------------------------------------------------
op_CHK: 
            move.w #$1122, d0
            move.w #$1122, d1
            chk d0 , d1 
            
            nop
            nop
            
            move.w #$1122, d1
            chk #$1122 , d1 
                    
    * Comment out when using Easy68K
            *move.w #$1122, d1
            *chk #00122 , d1 
            *cmp.l #$EEEE0006 , d6
            *bne *                   * branch if Z set  

            *move.w #$1122, d0      
            *move.w #$8000, d1
            *chk d0 , d1 
            *cmp.l #$EEEE0006 , d6
            *bne *                   * branch if Z set  

            rts
      
                          
*-----------------------------------------------------------
*-----------------------------------------------------------
* OPCODE : NEGS
*-----------------------------------------------------------
*-----------------------------------------------------------
op_NEGS: 

    * NOT - BYTE
            move.l #$00000100, a0
            move.l #$00000000, d0
            not.b d0
            bpl *                   * Check N Flag  bmi/bpl
            beq *                   * Check Z Flag  beq/bne
            not.b d0
            bmi *                   * Check N Flag  bmi/bpl
            bne *                   * Check Z Flag  beq/bne
            cmpi.b #$00 , d0
            bne *                   * Check Z Flag  beq/bne
            move.b #$80 , (a0)
            not.b (a0)
            bmi *                   * Check N Flag  bmi/bpl
            beq *                   * Check Z Flag  beq/bne
            not.b (a0)
            bpl *                   * Check N Flag  bmi/bpl
            beq *                   * Check Z Flag  beq/bne
            cmpi.b #$80 , (a0)
            bne *                   * Check Z Flag  beq/bne

    * NOT - WORD
            move.l #$00000100, a0
            move.l #$00000000, d0
            not.w d0
            bpl *                   * Check N Flag  bmi/bpl
            beq *                   * Check Z Flag  beq/bne
            not.w d0
            bmi *                   * Check N Flag  bmi/bpl
            bne *                   * Check Z Flag  beq/bne
            cmpi.w #$0000 , d0
            bne *                   * Check Z Flag  beq/bne
            move.w #$5a5a , (a0)
            not.w (a0)
            bpl *                   * Check N Flag  bmi/bpl
            beq *                   * Check Z Flag  beq/bne
            not.w (a0)
            bmi *                   * Check N Flag  bmi/bpl
            beq *                   * Check Z Flag  beq/bne
            cmpi.w #$5a5a , (a0)
            bne *                   * Check Z Flag  beq/bne

    * NOT - LONG
            move.l #$00000100, a0
            move.l #$00000000, d0
            not.l d0
            bpl *                   * Check N Flag  bmi/bpl
            beq *                   * Check Z Flag  beq/bne
            not.l d0
            bmi *                   * Check N Flag  bmi/bpl
            bne *                   * Check Z Flag  beq/bne
            cmpi.l #$00000000 , d0
            bne *                   * Check Z Flag  beq/bne
            move.l #$5a5a1234 , (a0)
            not.l (a0)
            bpl *                   * Check N Flag  bmi/bpl
            beq *                   * Check Z Flag  beq/bne
            not.l (a0)
            bmi *                   * Check N Flag  bmi/bpl
            beq *                   * Check Z Flag  beq/bne
            cmpi.l #$5a5a1234 , (a0)
            bne *                   * Check Z Flag  beq/bne

* ----- 

    * NEG - BYTE
            move.l #$00000100, a0
            move.l #$00000000, d0
            move.l #$00000080, d1
            neg.b d0
            bmi *                   * Check N Flag  bmi/bpl 0
            bne *                   * Check Z Flag  beq/bne 1
            bcs *                   * Check C Flag  bcc/bcs 1
            bvs *                   * Check V Flag  bvc/bvs 1
            neg.b d1
            bpl *                   * Check N Flag  bmi/bpl 1
            beq *                   * Check Z Flag  beq/bne 0
            bcc *                   * Check C Flag  bcc/bcs 0
            bvc *                   * Check V Flag  bvc/bvs 0       
            cmpi.b #$80 , d1
            bne *                   * Check Z Flag  beq/bne
            move.b #$7F , (a0)
            neg.b (a0)
            bpl *                   * Check N Flag  bmi/bpl 1
            beq *                   * Check Z Flag  beq/bne 0
            bcc *                   * Check C Flag  bcc/bcs 0
            bvs *                   * Check V Flag  bvc/bvs 1          
            move.b #$F5 , (a0)
            neg.b (a0)
            bmi *                   * Check N Flag  bmi/bpl 0
            beq *                   * Check Z Flag  beq/bne 0
            bcc *                   * Check C Flag  bcc/bcs 0
            bvs *                   * Check V Flag  bvc/bvs 1       
            cmpi.b #$0B , (a0)
            bne *                   * Check Z Flag  beq/bne

* -----         

    * NEG - WORD
            move.l #$00000100, a0
            move.l #$00000000, d0
            move.l #$00008000, d1
            neg.w d0
            bmi *                   * Check N Flag  bmi/bpl 0
            bne *                   * Check Z Flag  beq/bne 1
            bcs *                   * Check C Flag  bcc/bcs 1
            bvs *                   * Check V Flag  bvc/bvs 1
            neg.w d1
            bpl *                   * Check N Flag  bmi/bpl 1
            beq *                   * Check Z Flag  beq/bne 0
            bcc *                   * Check C Flag  bcc/bcs 0
            bvc *                   * Check V Flag  bvc/bvs 0       
            cmpi.w #$8000 , d1
            bne *                   * Check Z Flag  beq/bne
            move.w #$7FFF , (a0)
            neg.w (a0)
            bpl *                   * Check N Flag  bmi/bpl 1
            beq *                   * Check Z Flag  beq/bne 0
            bcc *                   * Check C Flag  bcc/bcs 0
            bvs *                   * Check V Flag  bvc/bvs 1          
            move.w #$F578 , (a0)
            neg.w (a0)
            bmi *                   * Check N Flag  bmi/bpl 0
            beq *                   * Check Z Flag  beq/bne 0
            bcc *                   * Check C Flag  bcc/bcs 0
            bvs *                   * Check V Flag  bvc/bvs 1       
            cmpi.w #$0A88 , (a0)
            bne *                   * Check Z Flag  beq/bne

* -----         

    * NEG - LONG
            move.l #$00000100, a0
            move.l #$00000000, d0
            move.l #$80000000, d1
            neg.l d0
            bmi *                   * Check N Flag  bmi/bpl 0
            bne *                   * Check Z Flag  beq/bne 1
            bcs *                   * Check C Flag  bcc/bcs 1
            bvs *                   * Check V Flag  bvc/bvs 1
            neg.l d1
            bpl *                   * Check N Flag  bmi/bpl 1
            beq *                   * Check Z Flag  beq/bne 0
            bcc *                   * Check C Flag  bcc/bcs 0
            bvc *                   * Check V Flag  bvc/bvs 0       
            cmpi.l #$80000000 , d1
            bne *                   * Check Z Flag  beq/bne
            move.l #$7FFFFFFF , (a0)
            neg.l (a0)
            bpl *                   * Check N Flag  bmi/bpl 1
            beq *                   * Check Z Flag  beq/bne 0
            bcc *                   * Check C Flag  bcc/bcs 0
            bvs *                   * Check V Flag  bvc/bvs 1          
            move.l #$F5781234 , (a0)
            neg.l (a0)
            bmi *                   * Check N Flag  bmi/bpl 0
            beq *                   * Check Z Flag  beq/bne 0
            bcc *                   * Check C Flag  bcc/bcs 0
            bvs *                   * Check V Flag  bvc/bvs 1       
            cmpi.l #$0A87EDCC , (a0)
            bne *                   * Check Z Flag  beq/bne


* -----         

    * NEGX - BYTE
            move.l #$00000100, a0
            move.l #$00000000, d0
            move.l #$00000080, d1
            ori.b #$10 , CCR        * Set X Flag
            negx.b d0
            bpl *                   * Check N Flag  bmi/bpl 0
            beq *                   * Check Z Flag  beq/bne 1
            bcc *                   * Check C Flag  bcc/bcs 1
            bvs *                   * Check V Flag  bvc/bvs 1           
            andi.b #$EF , CCR       * Clear X Flag
            negx.b d0
            bmi *                   * Check N Flag  bmi/bpl 0
            beq *                   * Check Z Flag  beq/bne 1
            bcc *                   * Check C Flag  bcc/bcs 1
            bvs *                   * Check V Flag  bvc/bvs 1
            ori.b #$10 , CCR        * Set X Flag
            negx.b d1
            bmi *                   * Check N Flag  bmi/bpl 1
            beq *                   * Check Z Flag  beq/bne 0
            bcc *                   * Check C Flag  bcc/bcs 0
            bvs *                   * Check V Flag  bvc/bvs 0       
            cmpi.b #$7F , d1
            bne *                   * Check Z Flag  beq/bne         
            andi.b #$EF , CCR       * Clear X Flag
            negx.b d1
            bpl *                   * Check N Flag  bmi/bpl 1
            beq *                   * Check Z Flag  beq/bne 0
            bcc *                   * Check C Flag  bcc/bcs 0
            bvs *                   * Check V Flag  bvc/bvs 0       
            cmpi.b #$81 , d1
            bne *                   * Check Z Flag  beq/bne
            move.b #$7F , (a0)
            ori.b #$10 , CCR        * Set X Flag
            negx.b (a0)
            bpl *                   * Check N Flag  bmi/bpl 1
            beq *                   * Check Z Flag  beq/bne 0
            bcc *                   * Check C Flag  bcc/bcs 0
            bvs *                   * Check V Flag  bvc/bvs 1          
            move.b #$7F , (a0)
            andi.b #$EF , CCR       * Clear X Flag
            negx.b (a0)
            bpl *                   * Check N Flag  bmi/bpl 1
            beq *                   * Check Z Flag  beq/bne 0
            bcc *                   * Check C Flag  bcc/bcs 0
            bvs *                   * Check V Flag  bvc/bvs 1          
            move.b #$F5 , (a0)
            ori.b #$10 , CCR        * Set X Flag
            negx.b (a0)
            bmi *                   * Check N Flag  bmi/bpl 0
            beq *                   * Check Z Flag  beq/bne 0
            bcc *                   * Check C Flag  bcc/bcs 0
            bvs *                   * Check V Flag  bvc/bvs 1       
            cmpi.b #$0A , (a0)
            bne *                   * Check Z Flag  beq/bne
            andi.b #$EF , CCR       * Clear X Flag
            negx.b (a0)
            bpl *                   * Check N Flag  bmi/bpl 0
            beq *                   * Check Z Flag  beq/bne 0
            bcc *                   * Check C Flag  bcc/bcs 0
            bvs *                   * Check V Flag  bvc/bvs 1       
            cmpi.b #$F6 , (a0)
            bne *                   * Check Z Flag  beq/bne

    

* -----         

    * NEGX - WORD
            move.l #$00000100, a0
            move.l #$00000000, d0
            move.l #$00008000, d1
            ori.b #$10 , CCR        * Set X Flag
            negx.w d0
            bpl *                   * Check N Flag  bmi/bpl 0
            beq *                   * Check Z Flag  beq/bne 1
            bcc *                   * Check C Flag  bcc/bcs 1
            bvs *                   * Check V Flag  bvc/bvs 1           
            andi.b #$EF , CCR       * Clear X Flag
            negx.w d0
            bmi *                   * Check N Flag  bmi/bpl 0
            beq *                   * Check Z Flag  beq/bne 1
            bcc *                   * Check C Flag  bcc/bcs 1
            bvs *                   * Check V Flag  bvc/bvs 1
            ori.b #$10 , CCR        * Set X Flag
            negx.w d1
            bmi *                   * Check N Flag  bmi/bpl 1
            beq *                   * Check Z Flag  beq/bne 0
            bcc *                   * Check C Flag  bcc/bcs 0
            bvs *                   * Check V Flag  bvc/bvs 0       
            cmpi.w #$7FFF , d1
            bne *                   * Check Z Flag  beq/bne         
            andi.b #$EF , CCR       * Clear X Flag
            negx.w d1
            bpl *                   * Check N Flag  bmi/bpl 1
            beq *                   * Check Z Flag  beq/bne 0
            bcc *                   * Check C Flag  bcc/bcs 0
            bvs *                   * Check V Flag  bvc/bvs 0       
            cmpi.w #$8001 , d1
            bne *                   * Check Z Flag  beq/bne
            move.w #$7FFF , (a0)
            ori.b #$10 , CCR        * Set X Flag
            negx.w (a0)
            bpl *                   * Check N Flag  bmi/bpl 1
            beq *                   * Check Z Flag  beq/bne 0
            bcc *                   * Check C Flag  bcc/bcs 0
            bvs *                   * Check V Flag  bvc/bvs 1          
            move.w #$F567 , (a0)            
            andi.b #$EF , CCR       * Clear X Flag
            negx.w (a0)
            bmi *                   * Check N Flag  bmi/bpl 1
            beq *                   * Check Z Flag  beq/bne 0
            bcc *                   * Check C Flag  bcc/bcs 0
            bvs *                   * Check V Flag  bvc/bvs 1          
            move.w #$F567 , (a0)
            ori.b #$10 , CCR        * Set X Flag
            negx.w (a0)
            bmi *                   * Check N Flag  bmi/bpl 0
            beq *                   * Check Z Flag  beq/bne 0
            bcc *                   * Check C Flag  bcc/bcs 0
            bvs *                   * Check V Flag  bvc/bvs 1       
            cmpi.w #$0A98 , (a0)
            bne *                   * Check Z Flag  beq/bne
            andi.b #$EF , CCR       * Clear X Flag
            negx.w (a0)
            bpl *                   * Check N Flag  bmi/bpl 0
            beq *                   * Check Z Flag  beq/bne 0
            bcc *                   * Check C Flag  bcc/bcs 0
            bvs *                   * Check V Flag  bvc/bvs 1       
            cmpi.w #$F568 , (a0)
            bne *                   * Check Z Flag  beq/bne

            
* -----         

    * NEGX - LONG
            move.l #$00000100, a0
            move.l #$00000000, d0
            move.l #$80000000, d1
            ori.b #$10 , CCR        * Set X Flag
            negx.l d0
            bpl *                   * Check N Flag  bmi/bpl 0
            beq *                   * Check Z Flag  beq/bne 1
            bcc *                   * Check C Flag  bcc/bcs 1
            bvs *                   * Check V Flag  bvc/bvs 1           
            andi.b #$EF , CCR       * Clear X Flag
            negx.l d0
            bmi *                   * Check N Flag  bmi/bpl 0
            beq *                   * Check Z Flag  beq/bne 1
            bcc *                   * Check C Flag  bcc/bcs 1
            bvs *                   * Check V Flag  bvc/bvs 1
            ori.b #$10 , CCR        * Set X Flag
            negx.l d1
            bmi *                   * Check N Flag  bmi/bpl 1
            beq *                   * Check Z Flag  beq/bne 0
            bcc *                   * Check C Flag  bcc/bcs 0
            bvs *                   * Check V Flag  bvc/bvs 0       
            cmpi.l #$7FFFFFFF , d1
            bne *                   * Check Z Flag  beq/bne         
            andi.b #$EF , CCR       * Clear X Flag
            negx.l d1
            bpl *                   * Check N Flag  bmi/bpl 1
            beq *                   * Check Z Flag  beq/bne 0
            bcc *                   * Check C Flag  bcc/bcs 0
            bvs *                   * Check V Flag  bvc/bvs 0       
            cmpi.l #$80000001 , d1
            bne *                   * Check Z Flag  beq/bne
            move.l #$7FFF , (a0)
            ori.b #$10 , CCR        * Set X Flag
            negx.l (a0)
            bpl *                   * Check N Flag  bmi/bpl 1
            beq *                   * Check Z Flag  beq/bne 0
            bcc *                   * Check C Flag  bcc/bcs 0
            bvs *                   * Check V Flag  bvc/bvs 1          
            move.l #$F5671234 , (a0)            
            andi.b #$EF , CCR       * Clear X Flag
            negx.l (a0)
            bmi *                   * Check N Flag  bmi/bpl 1
            beq *                   * Check Z Flag  beq/bne 0
            bcc *                   * Check C Flag  bcc/bcs 0
            bvs *                   * Check V Flag  bvc/bvs 1          
            move.l #$F5675678 , (a0)
            ori.b #$10 , CCR        * Set X Flag
            negx.l (a0)
            bmi *                   * Check N Flag  bmi/bpl 0
            beq *                   * Check Z Flag  beq/bne 0
            bcc *                   * Check C Flag  bcc/bcs 0
            bvs *                   * Check V Flag  bvc/bvs 1       
            cmpi.l #$0A98A987 , (a0)
            bne *                   * Check Z Flag  beq/bne
            andi.b #$EF , CCR       * Clear X Flag
            negx.l (a0)
            bpl *                   * Check N Flag  bmi/bpl 0
            beq *                   * Check Z Flag  beq/bne 0
            bcc *                   * Check C Flag  bcc/bcs 0
            bvs *                   * Check V Flag  bvc/bvs 1       
            cmpi.l #$F5675679 , (a0)
            bne *                   * Check Z Flag  beq/bne

            
* -----         

    * CLR - BYTE
            move.l #$00000100, a0
            move.l #$12345678, d0
            move.l #$12345678, d1                   
            move.l #$12345678, d2                   
            move.l #$12345600, d4                   
            move.l #$12340000, d5                   
            move.l #$00000000, d6                   
            
            clr.b d0
            bne *                   * Check Z Flag  beq/bne 0
            bmi *                   * Check N Flag  bmi/bpl 0
            cmp.l d0 , d4
            bne *                   * Check Z Flag  beq/bne 0
            
            clr.w d1
            bne *                   * Check Z Flag  beq/bne 0
            bmi *                   * Check N Flag  bmi/bpl 0
            cmp.l d1 , d5
            bne *                   * Check Z Flag  beq/bne 0
            
            clr.l d2
            bne *                   * Check Z Flag  beq/bne 0
            bmi *                   * Check N Flag  bmi/bpl 0
            cmp.l d2 , d6
            bne *                   * Check Z Flag  beq/bne 0

            rts      
            
      
                          
*-----------------------------------------------------------
*-----------------------------------------------------------
* OPCODE : MOVEM
*-----------------------------------------------------------
*-----------------------------------------------------------
op_MOVEM: 

    * WORD  Registers --> Memory
            move.l #$0000d0d0, d0
            move.l #$0000d1d1, d1
            move.l #$0000d2d2, d2
            move.l #$0000d3d3, d3
            move.l #$0000d4d4, d4
            move.l #$0000d5d5, d5
            move.l #$0000d6d6, d6
            move.l #$0000d7d7, d7
            move.l #$00000a0a, a0
            move.l #$00001a1a, a1
            move.l #$00002a2a, a2
            move.l #$00003a3a, a3
            move.l #$00004a4a, a4
            move.l #$00005a5a, a5
            move.l #$00006a6a, a6
           *move.l #$00007a7a, a7  * Dont change the Stack Pointer
            
            movem.w D0-D7/A0-A7 , $00000100  
            
            move.l #$00000100, a0
            
            cmp.w (a0)+ , d0            
            bne *                   * Check Z Flag  beq/bne 0
            cmp.w (a0)+ , d1            
            bne *                   * Check Z Flag  beq/bne 0
            cmp.w (a0)+ , d2            
            bne *                   * Check Z Flag  beq/bne 0
            cmp.w (a0)+ , d3            
            bne *                   * Check Z Flag  beq/bne 0
            cmp.w (a0)+ , d4            
            bne *                   * Check Z Flag  beq/bne 0
            cmp.w (a0)+ , d5            
            bne *                   * Check Z Flag  beq/bne 0
            cmp.w (a0)+ , d6            
            bne *                   * Check Z Flag  beq/bne 0
            cmp.w (a0)+ , d7            
            bne *                   * Check Z Flag  beq/bne 0

            cmp.w #$0A0A , (a0)+    * Because we are using a0 as a pointer
            bne *                   * Check Z Flag  beq/bne 0
 
            cmp.w (a0)+ , a1
            bne *                   * Check Z Flag  beq/bne 0
            cmp.w (a0)+ , a2
            bne *                   * Check Z Flag  beq/bne 0
            cmp.w (a0)+ , a3
            bne *                   * Check Z Flag  beq/bne 0
            cmp.w (a0)+ , a4
            bne *                   * Check Z Flag  beq/bne 0
            cmp.w (a0)+ , a5
            bne *                   * Check Z Flag  beq/bne 0
            cmp.w (a0)+ , a6
            bne *                   * Check Z Flag  beq/bne 0
          



    * LONG  Registers --> Memory
            move.l #$d0d0d0d0, d0
            move.l #$d1d1d1d1, d1
            move.l #$d2d2d2d2, d2
            move.l #$d3d3d3d3, d3
            move.l #$d4d4d4d4, d4
            move.l #$d5d5d5d5, d5
            move.l #$d6d6d6d6, d6
            move.l #$d7d7d7d7, d7
            move.l #$0a0a0a0a, a0
            move.l #$1a1a1a1a, a1
            move.l #$2a2a2a2a, a2
            move.l #$3a3a3a3a, a3
            move.l #$4a4a4a4a, a4
            move.l #$5a5a5a5a, a5
            move.l #$6a6a6a6a, a6
           *move.l #$7a7a7a7a, a7  * Dont change the Stack Pointer
            
            
            movem.l D0-D7/A0-A7 , $00000120  
            
            move.l #$00000120, a0
            
            cmp.l (a0)+ , d0            
            bne *                   * Check Z Flag  beq/bne 0
            cmp.l (a0)+ , d1            
            bne *                   * Check Z Flag  beq/bne 0
            cmp.l (a0)+ , d2            
            bne *                   * Check Z Flag  beq/bne 0
            cmp.l (a0)+ , d3            
            bne *                   * Check Z Flag  beq/bne 0
            cmp.l (a0)+ , d4            
            bne *                   * Check Z Flag  beq/bne 0
            cmp.l (a0)+ , d5            
            bne *                   * Check Z Flag  beq/bne 0
            cmp.l (a0)+ , d6            
            bne *                   * Check Z Flag  beq/bne 0
            cmp.l (a0)+ , d7            
            bne *                   * Check Z Flag  beq/bne 0

            cmp.l #$0A0A0A0A , (a0)+    * Because we are using a0 as a pointer
            bne *                   * Check Z Flag  beq/bne 0
 
            cmp.l (a0)+ , a1
            bne *                   * Check Z Flag  beq/bne 0
            cmp.l (a0)+ , a2
            bne *                   * Check Z Flag  beq/bne 0
            cmp.l (a0)+ , a3
            bne *                   * Check Z Flag  beq/bne 0
            cmp.l (a0)+ , a4
            bne *                   * Check Z Flag  beq/bne 0
            cmp.l (a0)+ , a5
            bne *                   * Check Z Flag  beq/bne 0
            cmp.l (a0)+ , a6
            bne *                   * Check Z Flag  beq/bne 0
     * ----


    * WORD  Registers --> Memory  -(An) EA Mode
            move.l #$0000d0d0, d0
            move.l #$0000d1d1, d1
            move.l #$0000d2d2, d2
            move.l #$0000d3d3, d3
            move.l #$0000d4d4, d4
            move.l #$0000d5d5, d5
            move.l #$0000d6d6, d6
            move.l #$0000d7d7, d7
            move.l #$00000a0a, a0
            move.l #$00001a1a, a1
            move.l #$00002a2a, a2
            move.l #$00003a3a, a3
            move.l #$00004a4a, a4
            move.l #$00005a5a, a5
            move.l #$00006a6a, a6
           *move.l #$00007a7a, a7  * Dont change the Stack Pointer
           
            move.l #$000001A0, a0
            movem.w D0-D7/A0-A7 , -(a0)  
            
            move.l #$0000019E, a0
            
            cmp.w -(a0) , a6            
            bne *                   * Check Z Flag  beq/bne 0
            cmp.w -(a0) , a5            
            bne *                   * Check Z Flag  beq/bne 0
            cmp.w -(a0) , a4            
            bne *                   * Check Z Flag  beq/bne 0
            cmp.w -(a0) , a3            
            bne *                   * Check Z Flag  beq/bne 0
            cmp.w -(a0) , a2            
            bne *                   * Check Z Flag  beq/bne 0
            cmp.w -(a0) , a1            
            bne *                   * Check Z Flag  beq/bne 0
            cmp.w -(a0) , a0            
           * bne *                   * Check Z Flag  beq/bne 0
            cmp.w -(a0) , d7            
            bne *                   * Check Z Flag  beq/bne 0
            cmp.w -(a0) , d6
            bne *                   * Check Z Flag  beq/bne 0
            cmp.w -(a0) , d5
            bne *                   * Check Z Flag  beq/bne 0
            cmp.w -(a0) , d4
            bne *                   * Check Z Flag  beq/bne 0
            cmp.w -(a0) , d3
            bne *                   * Check Z Flag  beq/bne 0
            cmp.w -(a0) , d2
            bne *                   * Check Z Flag  beq/bne 0
            cmp.w -(a0) , d1
            bne *                   * Check Z Flag  beq/bne 0
            cmp.w -(a0) , d0
            bne *                   * Check Z Flag  beq/bne 0
          



    * LONG  Registers --> Memory   -(An) EA Mode
            move.l #$d0d0d0d0, d0
            move.l #$d1d1d1d1, d1
            move.l #$d2d2d2d2, d2
            move.l #$d3d3d3d3, d3
            move.l #$d4d4d4d4, d4
            move.l #$d5d5d5d5, d5
            move.l #$d6d6d6d6, d6
            move.l #$d7d7d7d7, d7
            move.l #$0a0a0a0a, a0
            move.l #$1a1a1a1a, a1
            move.l #$2a2a2a2a, a2
            move.l #$3a3a3a3a, a3
            move.l #$4a4a4a4a, a4
            move.l #$5a5a5a5a, a5
            move.l #$6a6a6a6a, a6
           *move.l #$7a7a7a7a, a7  * Dont change the Stack Pointer
            
         
            move.l #$000001A0, a0
            movem.l D0-D7/A0-A7 , -(a0)  
            
            move.l #$0000019C, a0
            
            cmp.l -(a0) , a6            
            bne *                   * Check Z Flag  beq/bne 0
            cmp.l -(a0) , a5            
            bne *                   * Check Z Flag  beq/bne 0
            cmp.l -(a0) , a4            
            bne *                   * Check Z Flag  beq/bne 0
            cmp.l -(a0) , a3            
            bne *                   * Check Z Flag  beq/bne 0
            cmp.l -(a0) , a2            
            bne *                   * Check Z Flag  beq/bne 0
            cmp.l -(a0) , a1            
            bne *                   * Check Z Flag  beq/bne 0
            cmp.l -(a0) , a0            
           * bne *                   * Check Z Flag  beq/bne 0
            cmp.l -(a0) , d7            
            bne *                   * Check Z Flag  beq/bne 0
            cmp.l -(a0) , d6
            bne *                   * Check Z Flag  beq/bne 0
            cmp.l -(a0) , d5
            bne *                   * Check Z Flag  beq/bne 0
            cmp.l -(a0) , d4
            bne *                   * Check Z Flag  beq/bne 0
            cmp.l -(a0) , d3
            bne *                   * Check Z Flag  beq/bne 0
            cmp.l -(a0) , d2
            bne *                   * Check Z Flag  beq/bne 0
            cmp.l -(a0) , d1
            bne *                   * Check Z Flag  beq/bne 0
            cmp.l -(a0) , d0
            bne *                   * Check Z Flag  beq/bne 0
          


     *----     
          
    * WORD - Memory --> Registers
            move.l #$00000000, d0
            move.l #$00000000, d1
            move.l #$00000000, d2
            move.l #$00000000, d3
            move.l #$00000000, d4
            move.l #$00000000, d5
            move.l #$00000000, d6
            move.l #$00000000, d7
            move.l #$00000000, a0
            move.l #$00000000, a1
            move.l #$00000000, a2
            move.l #$00000000, a3
            move.l #$00000000, a4
            move.l #$00000000, a5
            move.l #$00000000, a6
           *move.l #$00000000, a7  * Dont change the Stack Pointer
            
            movem.w $00000100 , D0/D2/D4/D6/A1/A3/A5   
            
            cmp.l #$FFFFD0D0 , d0           
            bne *                   * Check Z Flag  beq/bne 0
            cmp.l #$FFFFD1D1 , d2           
            bne *                  * Check Z Flag  beq/bne 0
            cmp.l #$FFFFD2D2 , d4           
            bne *                   * Check Z Flag  beq/bne 0
            cmp.l #$FFFFD3D3 , d6           
            bne *                   * Check Z Flag  beq/bne 0
            cmp.l #$FFFFD4D4 , a1           
            bne *                   * Check Z Flag  beq/bne 0
            cmp.l #$FFFFD5D5 , a3           
            bne *                   * Check Z Flag  beq/bne 0
            cmp.l #$FFFFD6D6 , a5           
            bne *                   * Check Z Flag  beq/bne 0
            
 
    * LONG - Memory --> Registers
            move.l #$00000000, d0
            move.l #$00000000, d1
            move.l #$00000000, d2
            move.l #$00000000, d3
            move.l #$00000000, d4
            move.l #$00000000, d5
            move.l #$00000000, d6
            move.l #$00000000, d7
            move.l #$00000000, a0
            move.l #$00000000, a1
            move.l #$00000000, a2
            move.l #$00000000, a3
            move.l #$00000000, a4
            move.l #$00000000, a5
            move.l #$00000000, a6
           *move.l #$00000000, a7  * Dont change the Stack Pointer
            
            movem.l $00000120 , D0/D2/D4/D6/A1/A3/A5   
            
            cmp.l #$D0D0D0D0 , d0           
            bne *                   * Check Z Flag  beq/bne 0
            cmp.l #$D1D1D1D1 , d2           
            bne *                  * Check Z Flag  beq/bne 0
            cmp.l #$D2D2D2D2 , d4           
            bne *                   * Check Z Flag  beq/bne 0
            cmp.l #$D3D3D3D3 , d6           
            bne *                   * Check Z Flag  beq/bne 0
            cmp.l #$D4D4D4D4 , a1           
            bne *                   * Check Z Flag  beq/bne 0
            cmp.l #$D5D5D5D5 , a3           
            bne *                   * Check Z Flag  beq/bne 0
            cmp.l #$D6D6D6D6 , a5           
            bne *                   * Check Z Flag  beq/bne 0
            
            rts     

                          
*-----------------------------------------------------------
*-----------------------------------------------------------
* OPCODE : ABCD
*-----------------------------------------------------------
*-----------------------------------------------------------
op_ABCD: 
    
    * Test with X Flag CLEARED
                move.l #$00000110, a0 * Address pointer-X
                move.l #$00000120, a1 * Address pointer-Y
                move.l #$00000000, d0 * BCD byte-X
                move.l #$00000000, d1 * BCD byte-Y
                move.l #$00000000, d2
                move.l #$00000000, d3 * Cumulative -(An) BCD results
                move.l #$00000000, d4 * Cumulative number of times C was set
                move.l #$00000000, d5 * Cumulative Register BCD results
                move.l #$00000099, d6 * Inner loop counter
                move.l #$00000099, d7 * Outer loop counter

ABCD_OUTER1:    move.l d7 , d0
ABCD_INNER1:    move.l d6 , d1
                andi.b #$EF , CCR     * Clear X Flag
                move.l #$00000110, a0 * Address pointer-X
                move.l #$00000120, a1 * Address pointer-Y
                move.b d0 , -1(a0)
                move.b d1 , -1(a1)
                
                abcd d0 , d1
                bcc ABCD_NO_C1          * Check C Flag  bcc/bcs 0
                add.l #1 , d4
ABCD_NO_C1:     add.l d1 , d5
                
                abcd -(a0) , -(a1)
                bcc ABCD_NO_C2          * Check C Flag  bcc/bcs 0
                add.l #1 , d4
ABCD_NO_C2:     add.b (a1) , d3


                dbf d6 , ABCD_INNER1
                move.l #$00000099, d6
                dbf d7 , ABCD_OUTER1
                cmpi.l #$00005AFC , d4  * Check the cumulative results
                bne *                 
                cmpi.l #$001C9A34 , d5
                bne *                
                cmpi.l #$00000034 , d3
                bne *                

    * Test with X Flag SET
                move.l #$00000110, a0 * Address pointer-X
                move.l #$00000120, a1 * Address pointer-Y
                move.l #$00000000, d0 * BCD byte-X
                move.l #$00000000, d1 * BCD byte-Y
                move.l #$00000000, d2
                move.l #$00000000, d3 * Cumulative -(An) BCD results
                move.l #$00000000, d4 * Cumulative number of times C was set
                move.l #$00000000, d5 * Cumulative Register BCD results
                move.l #$00000099, d6 * Inner loop counter
                move.l #$00000099, d7 * Outer loop counter

ABCD_OUTER2:    move.l d7 , d0
ABCD_INNER2:    move.l d6 , d1
                ori.b #$10 , CCR      * Set X Flag
                move.l #$00000110, a0 * Address pointer-X
                move.l #$00000120, a1 * Address pointer-Y
                move.b d0 , -1(a0)
                move.b d1 , -1(a1)
                
                abcd d0 , d1
                bcc ABCD_NO_C3          * Check C Flag  bcc/bcs 0
                add.l #1 , d4
ABCD_NO_C3:     add.l d1 , d5
                
                abcd -(a0) , -(a1)
                bcc ABCD_NO_C4          * Check C Flag  bcc/bcs 0
                add.l #1 , d4
ABCD_NO_C4:     add.b (a1) , d3


                dbf d6 , ABCD_INNER2
                move.l #$00000099, d6
                dbf d7 , ABCD_OUTER2
                cmpi.l #$00005B60 , d4  * Check the cumulative results
                bne *                 
                cmpi.l #$001CCFC8 , d5
                bne *                
                cmpi.l #$00000034 , d3
                bne *                

            * Quick check of Z Flag
                move.b #$00, d0 
                move.b #$00, d1 
                move #$00, CCR              * Set Z flag to 0
                abcd d1,d0                  * Should NOT set Z Flag to 1
                beq *                       * Check Z Flag  beq/bne
                
                move.b #$01, d0 
                move.b #$00, d1 
                move #$04, CCR              * Set Z flag to 0
                abcd d1,d0                  * Should NOT set Z Flag to 1
                beq *                       * Check Z Flag  beq/bne
                
                rts   
                          
*-----------------------------------------------------------
*-----------------------------------------------------------
* OPCODE : SBCD
*-----------------------------------------------------------
*-----------------------------------------------------------
op_SBCD: 

    * Test with X Flag CLEARED
                move.l #$00000110, a0 * Address pointer-X
                move.l #$00000120, a1 * Address pointer-Y
                move.l #$00000000, d0 * BCD byte-X
                move.l #$00000000, d1 * BCD byte-Y
                move.l #$00000000, d2
                move.l #$00000000, d3 * Cumulative -(An) BCD results
                move.l #$00000000, d4 * Cumulative number of times C was set
                move.l #$00000000, d5 * Cumulative Register BCD results
                move.l #$00000099, d6 * Inner loop counter
                move.l #$00000099, d7 * Outer loop counter

SBCD_OUTER1:    move.l d7 , d0
SBCD_INNER1:    move.l d6 , d1
                andi.b #$EF , CCR     * Clear X Flag
                move.l #$00000110, a0 * Address pointer-X
                move.l #$00000120, a1 * Address pointer-Y
                move.b d0 , -1(a0)
                move.b d1 , -1(a1)
                
                sbcd d0 , d1
                bcc SBCD_NO_C1          * Check C Flag  bcc/bcs 0
                add.l #1 , d4
SBCD_NO_C1:     add.l d1 , d5
                
                sbcd -(a0) , -(a1)
                bcc SBCD_NO_C2          * Check C Flag  bcc/bcs 0
                add.l #1 , d4
SBCD_NO_C2:     add.b (a1) , d3


                dbf d6 , SBCD_INNER1
                move.l #$00000099, d6
                dbf d7 , SBCD_OUTER1
                cmpi.l #$00005C0A , d4  * Check the cumulative results
                bne *                 
                cmpi.l #$001C459E , d5
                bne *                
                cmpi.l #$0000009E , d3
                bne *                

    * Test with X Flag SET
                move.l #$00000110, a0 * Address pointer-X
                move.l #$00000120, a1 * Address pointer-Y
                move.l #$00000000, d0 * BCD byte-X
                move.l #$00000000, d1 * BCD byte-Y
                move.l #$00000000, d2
                move.l #$00000000, d3 * Cumulative -(An) BCD results
                move.l #$00000000, d4 * Cumulative number of times C was set
                move.l #$00000000, d5 * Cumulative Register BCD results
                move.l #$00000099, d6 * Inner loop counter
                move.l #$00000099, d7 * Outer loop counter

SBCD_OUTER2:    move.l d7 , d0
SBCD_INNER2:    move.l d6 , d1
                ori.b #$10 , CCR      * Set X Flag
                move.l #$00000110, a0 * Address pointer-X
                move.l #$00000120, a1 * Address pointer-Y
                move.b d0 , -1(a0)
                move.b d1 , -1(a1)
                
                sbcd d0 , d1
                bcc SBCD_NO_C3          * Check C Flag  bcc/bcs 0
                add.l #1 , d4
SBCD_NO_C3:     add.l d1 , d5
                
                sbcd -(a0) , -(a1)
                bcc SBCD_NO_C4          * Check C Flag  bcc/bcs 0
                add.l #1 , d4
SBCD_NO_C4:     add.b (a1) , d3

                dbf d6 , SBCD_INNER2
                move.l #$00000099, d6
                dbf d7 , SBCD_OUTER2
                cmpi.l #$00005CA4 , d4  * Check the cumulative results
                bne *                 
                cmpi.l #$001C5C66 , d5
                bne *                
                cmpi.l #$0000009E , d3
                bne *                


            * Quick check of Z Flag
                move.b #$00, d0 
                move.b #$00, d1 
                move #$00, CCR              * Set Z flag to 0
                sbcd d1,d0                  * Should NOT set Z Flag to 1
                beq *                       * Check Z Flag  beq/bne

                move.b #$01, d0 
                move.b #$00, d1 
                move #$04, CCR              * Set Z flag to 0
                sbcd d1,d0                  * Should NOT set Z Flag to 1
                beq *                       * Check Z Flag  beq/bne

                rts   
               
*-----------------------------------------------------------
*-----------------------------------------------------------
* OPCODE : NBCD
*-----------------------------------------------------------
*-----------------------------------------------------------
op_NBCD: 
    
       * NBCD to a  Register
       
                move.l #$00000000, d0 * BCD byte
                move.l #$00000000, d1 
                move.l #$00000000, d2
                move.l #$00000000, d3 * Cumulative number of times Z was set
                move.l #$00000000, d4 * Cumulative number of times C was set
                move.l #$00000000, d5 * Cumulative BCD results
                move.l #$00000099, d6
                move.l #$00000099, d7 * Loop counter

NBCD_LOOP:      move.l d7 , d0
                move #$04, CCR        * Set Z flag to 0

                nbcd d0
                
                bcc NBCD_NO_C         * Check C Flag 
                add.l #1 , d4
NBCD_NO_C:      bne NBCD_NO_Z         * Check Z Flag 
                add.l #1 , d3
NBCD_NO_Z:      add.l d0 , d5         * Add results into d5

                dbf d7 , NBCD_LOOP
                
                cmpi.l #$00000001 , d3  * Check the cumulative results
                bne *                 
                cmpi.l #$00000099 , d4
                bne *                
                cmpi.l #$00002E3B , d5
                bne *     
           

       * NBCD to a memory location
       
                move.l #$00000000, d0 * BCD byte
                move.l #$00000000, d1 
                move.l #$00000000, d2
                move.l #$00000000, d3 * Cumulative number of times Z was set
                move.l #$00000000, d4 * Cumulative number of times C was set
                move.l #$00000000, d5 * Cumulative BCD results
                move.l #$00000099, d6
                move.l #$00000099, d7 * Loop counter

NBCD_LOOP1:     move.b d7 , $00000100
                move #$04, CCR        * Set Z flag to 0

                nbcd $00000100
                move.b $00000100 , d0
                
                bcc NBCD_NO_C1        * Check C Flag 
                add.l #1 , d4
NBCD_NO_C1:     bne NBCD_NO_Z1        * Check Z Flag 
                add.l #1 , d3
NBCD_NO_Z1:     add.l d0 , d5         * Add results into d5

                dbf d7 , NBCD_LOOP1
                
                cmpi.l #$00000001 , d3  * Check the cumulative results
                bne *                 
                cmpi.l #$00000000 , d4
                bne *                
                cmpi.l #$00002E3B , d5
                bne *     
           

                rts   


               
*-----------------------------------------------------------
*-----------------------------------------------------------
* OPCODE : TRAPV
*-----------------------------------------------------------
*-----------------------------------------------------------
op_TRAPV: 

    * TRAPV will set d0 to 12345678 if V flag is set
    
                move.l #$00000000, d0 * Clear d0
                
                move #$00, CCR        * Clear V flag
                trapv
                cmpi.l #$00000000 , d0  * Check of d0 was updated (should not be_)
                bne *       

               * Easy658K does not use exception vectors
               * move #$02, CCR        * Set V flag
               * trapv
               * cmpi.l #$12345678 , d0  * Check of d0 was updated (should not be_)
               * bne *       


                rts   


               
*-----------------------------------------------------------
*-----------------------------------------------------------
* OPCODE : RTR
*-----------------------------------------------------------
*-----------------------------------------------------------

op_RTR: 

    * Leventhal claims only 5 LSB's are popped from the stack to the CCR
    
                lea RTR_DONE , a0
                move.l a0, -(a7)     * push destination PC to the stack
                move.w #$FF15 , -(a7)       * push flags=0xFFFF to the stack
                rtr

RTR_DONE:       move SR , d0
                andi #$1F , d0
                cmpi #$15 , d0
                bne *
                
                rts   

   
BSR_FAR2:       move.l #$44444444 , d4
                rts

               
*-----------------------------------------------------------
*-----------------------------------------------------------
* OPCODE : BCC
*-----------------------------------------------------------
*-----------------------------------------------------------

op_BCC:         move #$00 , CCR
                bhi.s BCC1            * Higher Than         C=0 AND Z=0
                bra *
                
BCC1:           move #$01 , CCR
                bls.w BCC2            * Lower or Same       C=1 OR Z=1
                bra *
                 
BCC2:           move #$00 , CCR
                bcc.s BCC3            * Carry Clear         C=0
                bra *
                   
BCC3:           move #$01 , CCR
                bcs.w BCC4            * Carry Set           C=1
                bra *
                   
BCC4:           move #$00 , CCR
                bne.s BCC5            * Not Equal           Z=0
                bra *
                     
BCC5:           move #$04 , CCR
                beq.w BCC6            * Equal               Z=1
                bra *
                       
BCC6:           move #$00 , CCR
                bvc.s BCC7            * V Clear             V=0
                bra *
                         
BCC7:           move #$02 , CCR
                bvs.w BCC8            * V Set               V=1
                bra *
                          
BCC8:           move #$00 , CCR
                bpl.s BCC9            * Plus                N=0
                bra *
                           
BCC9:           move #$08 , CCR
                bmi.w BCC10           * Minus               N=1
                bra *
                            
BCC10:          move #$00 , CCR
                bge.s BCC11           * Greater or Equal    N=V
                bra *
                             
BCC11:          move #$02 , CCR
                blt.w BCC12           * Less Than           N!=V
                bra *
                               
BCC12:          move #$0A , CCR
                bgt.s BCC13           * Greater Than        N=V  AND Z=0
                bra *
                                
BCC13:          move #$06 , CCR
                ble.w BCC14           * Less Than or Equal  N!=V AND Z=1
                bra *
               

BCC14:          rts
  
  
*-----------------------------------------------------------
*-----------------------------------------------------------
* OPCODE : DBCC
*-----------------------------------------------------------
*-----------------------------------------------------------

op_DBCC:        move.l #$00000003 , d0    * Loop counter
                move.l #$00000000 , d1    * Accumulator
                move #$00 , CCR
                
DBCC_LOOP1:     addi.b #$1 , d1
                dbf d0 , DBCC_LOOP1
                
                cmpi.l #$00000004 , d1  * Check Accumulator results
                bne *       
                  
DBCC_LOOP2:     addi.b #$1 , d1
                dbcc d0 , DBCC_LOOP2    * Dont loop
                
                cmpi.l #$00000005 , d1  * Check Accumulator results
                bne *       
            
                rts
                

*-----------------------------------------------------------
*-----------------------------------------------------------
* OPCODE : SCC
*-----------------------------------------------------------
*-----------------------------------------------------------

op_SCC:         move #$01 , CCR             
                scc $00010000                   * Clear the EA byte
                cmpi.b #$00 , $00010000
                bne *       

                move #$00 , CCR
                scc $00010000                   * Set the EA byte to 0xFF
                cmpi.b #$FF , $00010000
                bne *       

                rts
                


*-----------------------------------------------------------
*-----------------------------------------------------------
* OPCODE : ADDQ
*-----------------------------------------------------------
*-----------------------------------------------------------

op_ADDQ:       

    * BYTE
                move.l #$000000FF , d0    * Loop counter
                move.l #$00000000 , d1    * Flag results accumulator
                move.l #$00000000 , d2    * Data results accumulator
                move.l #$00000000 , d3   
                move.l #$00000000 , d4    
                move.l #$00000000 , d5    
                move.l #$00000000 , d6    
                move.l #$00000000 , d7    

ADDQ_LOOP1:     addq.b #3 , d5          
                move SR , d6      
                andi.l #$1F , d6        * Isolate flags
                add.l d6 , d1           * Copy flag results into accumulator
                add.l d5 , d2           * Copy data results into data accumulator
                dbf d0 , ADDQ_LOOP1
                
                cmpi.l #$0000043D , d1
                bne *       
                cmpi.l #$00007F80 , d2
                bne *       


    * WORD
                move.l #$000000FF , d0    * Loop counter
                move.l #$00000000 , d1    * Flag results accumulator
                move.l #$00000000 , d2    * Data results accumulator
                move.l #$00000000 , d3   
                move.l #$00000000 , d4    
                move.l #$0000FFF0 , d5    
                move.l #$00000000 , d6    
                move.l #$00000000 , d7   
                move.l #$00000100 , a0   

ADDQ_LOOP2:     addq.w #5 , d5   
                move SR , d6      
                andi.l #$1F , d6        * Isolate flags
                add.l d6 , d1           * Copy flag results into accumulator
                add.l d5 , d2           * Copy data results into data accumulator
                dbf d0 , ADDQ_LOOP2

                cmpi.l #$00000029 , d1
                bne *       
                cmpi.l #$00057280 , d2
                bne *       


    * LONG
                move.l #$000000FF , d0    * Loop counter
                move.l #$00000000 , d1    * Flag results accumulator
                move.l #$00000000 , d2    * Data results accumulator
                move.l #$00000000 , d3   
                move.l #$00000000 , d4    
                move.l #$FFFFFFF0 , d5    
                move.l #$00000000 , d6    
                move.l #$00000000 , d7   

ADDQ_LOOP3:     addq.l #1 , d5          
                move SR , d6      
                andi.l #$1F , d6        * Isolate flags
                add.l d6 , d1           * Copy flag results into accumulator
                add.l d5 , d2           * Copy data results into data accumulator
                dbf d0 , ADDQ_LOOP3

                cmpi.l #$0000008D , d1
                bne *       
                cmpi.l #$00007080 , d2
                bne *      

    * Check that Flags are not updated for Address registers
                move.l #$0000FFFF , a0   
                move #$00 , CCR         * Clear flags
                addq.w #$7 , a0         
                bcs *

                rts
        


*-----------------------------------------------------------
*-----------------------------------------------------------
* OPCODE : SUBQ
*-----------------------------------------------------------
*-----------------------------------------------------------

op_SUBQ:       

    * BYTE
                move.l #$000000FF , d0    * Loop counter
                move.l #$00000000 , d1    * Flag results accumulator
                move.l #$00001234 , d2    * Data results accumulator
                move.l #$00000000 , d3   
                move.l #$00000000 , d4    
                move.l #$00000012 , d5    
                move.l #$00000000 , d6    
                move.l #$00000000 , d7    

SUBQ_LOOP1:     subq.b #1 , d5          
                move SR , d6      
                andi.l #$1F , d6        * Isolate flags
                add.l d6 , d1           * Copy flag results into accumulator
                add.l d5 , d2           * Copy data results into data accumulator
                dbf d0 , SUBQ_LOOP1
                
                cmpi.l #$00000417 , d1
                bne *       
                cmpi.l #$000091B4 , d2
                bne *       


    * WORD
                move.l #$000000FF , d0    * Loop counter
                move.l #$00000000 , d1    * Flag results accumulator
                move.l #$00000000 , d2    * Data results accumulator
                move.l #$00000000 , d3   
                move.l #$00000000 , d4    
                move.l #$00000002 , d5    
                move.l #$00000000 , d6    
                move.l #$00000000 , d7   
                move.l #$00000100 , a0   

SUBQ_LOOP2:     subq.w #5 , d5   
                move SR , d6      
                andi.l #$1F , d6        * Isolate flags
                add.l d6 , d1           * Copy flag results into accumulator
                add.l d5 , d2           * Copy data results into data accumulator
                dbf d0 , SUBQ_LOOP2

                cmpi.l #$00000811 , d1
                bne *       
                cmpi.l #$00FD7F80 , d2
                bne *       


    * LONG
                move.l #$000000FF , d0    * Loop counter
                move.l #$00000000 , d1    * Flag results accumulator
                move.l #$00000000 , d2    * Data results accumulator
                move.l #$00000000 , d3   
                move.l #$00000000 , d4    
                move.l #$00000007 , d5    
                move.l #$00000000 , d6    
                move.l #$00000000 , d7   

SUBQ_LOOP3:     subq.l #1 , d5          
                move SR , d6      
                andi.l #$1F , d6        * Isolate flags
                add.l d6 , d1           * Copy flag results into accumulator
                add.l d5 , d2           * Copy data results into data accumulator
                dbf d0 , SUBQ_LOOP3

                cmpi.l #$000007DD , d1
                bne *       
                cmpi.l #$FFFF8680 , d2
                bne *      

    * Check that Flags are not updated for Address registers
                move.l #$0001FFFF , a0   
                move #$00 , CCR         * Clear flags
                subq.w #$7 , a0         
                bcs *

                rts
        
        


*-----------------------------------------------------------
*-----------------------------------------------------------
* OPCODE : MOVEQ
*-----------------------------------------------------------
*-----------------------------------------------------------

op_MOVEQ:     
                move.l #$00000000 , d0  
                moveq #$0 , d0
                bne *
                cmpi.l #$00000000 , d0
                bne *

                move.l #$00000000 , d0  
                moveq #$80 , d0
                beq *
                bpl *
                cmpi.l #$FFFFFF80 , d0
                bne *


                rts
   
   
*-----------------------------------------------------------
*-----------------------------------------------------------
* OPCODE : DIVU
*-----------------------------------------------------------
*-----------------------------------------------------------

op_DIVU:     

                move.l #$a5a5a5a5, d0        * Initial Numerator
                move.l #$00005a5a, d1        * Initial Divisor
                move.l #$a5a5a5a5, d2
                move.l #$00000000, d3
                move.l #$00000000, d4        * Cumulative data results
                move.l #$00000000, d5       * Cumulative flag results
                move.l #$0000000E, d6       * Inner loop counter
                move.l #$0000001E, d7       * Outer loop counter


DIVU_OUTER1:    divu d1  , d0               * !! Easy68K C not always cleared
                move SR , d3      
                andi.l #$0C , d3            * Isolate flags 
                add.l d3 , d5               * Copy flag results into accumulator
                add.l d0 , d4               * Copy data results into data accumulator   
                lsr.l #$1 , d1

                dbf d6 , DIVU_OUTER1
                lsr.l #$1 , d2
                move.l d2 , d0
                move.l #$00005a5a, d1       * Initial Divisor
                move.l #$0000000E, d6       * Inner loop counter
                dbf d7 , DIVU_OUTER1
                
                cmpi.l #$92FEDB89 , d4      * Check the data results
                bne *                
                     
                cmpi.l #$00000110 , d5      * Check the Flag results
                bne *                 
          

                rts
                
  
   
*-----------------------------------------------------------
*-----------------------------------------------------------
* OPCODE : DIVS
*-----------------------------------------------------------
*-----------------------------------------------------------

op_DIVS:     

                move.l #$a5a5a5a5, d0        * Initial Numerator
                move.l #$00005a5a, d1        * Initial Divisor
                move.l #$a5a5a5a5, d2
                move.l #$00000000, d3
                move.l #$00000000, d4        * Cumulative data results
                move.l #$00000000, d5       * Cumulative flag results
                move.l #$0000000E, d6       * Inner loop counter
                move.l #$0000001E, d7       * Outer loop counter


DIVS_OUTER1:    divs d1  , d0               * !! Easy68K C not always cleared
                move SR , d3      
                andi.l #$0C , d3            * Isolate flags 
                add.l d3 , d5               * Copy flag results into accumulator
                add.l d0 , d4               * Copy data results into data accumulator   
                lsr.l #$1 , d1

                dbf d6 , DIVS_OUTER1
                lsr.l #$1 , d2
                move.l d2 , d0
                move.l #$00005a5a, d1       * Initial Divisor
                move.l #$0000000E, d6       * Inner loop counter
                dbf d7 , DIVS_OUTER1
                
                cmpi.l #$4EC5D057 , d4      * Check the data results
                bne *                
                     
                cmpi.l #$00000038 , d5      * Check the Flag results
                bne *                 
          

                rts
       

   
*-----------------------------------------------------------
*-----------------------------------------------------------
* OPCODE : OR
*-----------------------------------------------------------
*-----------------------------------------------------------

op_OR:   

  ** <EA> to Register

                move.l #$a5a5a5a5, d0       * Initial Data-X  Inner loop
                move.l #$8167E123, d1       * Initial Data-Y  Outer loop
                move.l #$a5a5a5a5, d2
                move.l #$00000000, d3
                move.l #$00000000, d4       * Cumulative data results
                move.l #$00000000, d5       * Cumulative flag results
                move.l #$0000001E, d6       * Inner loop counter
                move.l #$0000001E, d7       * Outer loop counter
                move.l #$00000100, a0       * Address for memory EA operations


OR_OUTER1:    
 
    * BYTE     
                move.l d1 , (a0)
                or.b (a0) , d0             
                move SR , d3      
                andi.l #$0C , d3            * Isolate flags 
                add.l d3 , d5               * Copy flag results into accumulator
                add.l d0 , d4               * Copy data results into data accumulator   
 
    * WORD      
                move.l d1 , (a0)
                or.w (a0) , d0             
                move SR , d3      
                andi.l #$0C , d3            * Isolate flags 
                add.l d3 , d5               * Copy flag results into accumulator
                add.l d0 , d4               * Copy data results into data accumulator   
 
    * LONG      
                move.l d1 , (a0)
                or.l (a0) , d0             
                move SR , d3      
                andi.l #$0F , d3            * Isolate flags 
                add.l d3 , d5               * Copy flag results into accumulator
                add.l d0 , d4               * Copy data results into data accumulator   
                
                
                lsr.l #$1 , d1
                dbf d6 , OR_OUTER1
                lsr.l #$1 , d2
                move.l #$8167E123, d1       * Initial Data-Y
                move.l #$0000001E, d6       * Inner loop counter
                dbf d7 , OR_OUTER1
                
                cmpi.l #$76EAC803 , d4      * Check the data results
                bne *                
                cmpi.l #$00005A18 , d5      * Check the Flag results
                bne *                
                   
                   
  ** Register to <EA>

                move.l #$86738374, d0       * Initial Data-X  Inner loop
                move.l #$FC55F2FE, d1       * Initial Data-Y  Outer loop
                move.l #$86738374, d2
                move.l #$00000000, d3
                move.l #$00000000, d4       * Cumulative data results
                move.l #$00000000, d5       * Cumulative flag results
                move.l #$0000001E, d6       * Inner loop counter
                move.l #$0000001D, d7       * Outer loop counter
                move.l #$00000100, a0       * Address for memory EA operations


OR_OUTER2:    
 
    * BYTE     
                move.l d0 , (a0)
                or.b d1 , (a0)             
                move SR , d3      
                andi.l #$0C , d3            * Isolate flags 
                add.l d3 , d5               * Copy flag results into accumulator
                add.l (a0) , d4             * Copy data results into data accumulator   
 
    * WORD      
                move.l d0 , (a0)
                or.w d1 , (a0)  
                move SR , d3      
                andi.l #$0C , d3            * Isolate flags 
                add.l d3 , d5               * Copy flag results into accumulator
                add.l (a0) , d4             * Copy data results into data accumulator   
 
    * LONG      
                move.l d0 , (a0)
                or.l d1 , (a0)  
                move SR , d3      
                andi.l #$0F , d3            * Isolate flags 
                add.l d3 , d5               * Copy flag results into accumulator
                add.l (a0) , d4             * Copy data results into data accumulator   
                
                
                lsr.l #$1 , d1
                dbf d6 , OR_OUTER2
                lsr.l #$1 , d2
                move.l #$8167E123, d1       * Initial Data-Y
                move.l #$0000001E, d6       * Inner loop counter
                dbf d7 , OR_OUTER2
                
                cmpi.l #$FA82B9E4 , d4      * Check the data results
                bne *                
                cmpi.l #$00005730 , d5      * Check the Flag results
                bne *                 
                   
                   
                rts
                
                

*-----------------------------------------------------------
*-----------------------------------------------------------
* OPCODE : AND
*-----------------------------------------------------------
*-----------------------------------------------------------

op_AND:   

  ** <EA> to Register

                move.l #$a5a5a5a5, d0       * Initial Data-X  Inner loop
                move.l #$8167E123, d1       * Initial Data-Y  Outer loop
                move.l #$a5a5a5a5, d2
                move.l #$00000000, d3
                move.l #$00000000, d4       * Cumulative data results
                move.l #$00000000, d5       * Cumulative flag results
                move.l #$0000001E, d6       * Inner loop counter
                move.l #$0000001E, d7       * Outer loop counter
                move.l #$00000100, a0       * Address for memory EA operations


AND_OUTER1:    
 
    * BYTE     
                move.l d1 , (a0)
                and.b (a0) , d0             
                move SR , d3      
                andi.l #$0C , d3            * Isolate flags 
                add.l d3 , d5               * Copy flag results into accumulator
                add.l d0 , d4               * Copy data results into data accumulator   
 
    * WORD      
                move.l d1 , (a0)
                and.w (a0) , d0             
                move SR , d3      
                andi.l #$0C , d3            * Isolate flags 
                add.l d3 , d5               * Copy flag results into accumulator
                add.l d0 , d4               * Copy data results into data accumulator   
 
    * LONG      
                move.l d1 , (a0)
                and.l (a0) , d0             
                move SR , d3      
                andi.l #$0F , d3            * Isolate flags 
                add.l d3 , d5               * Copy flag results into accumulator
                add.l d0 , d4               * Copy data results into data accumulator   
                
                
                lsr.l #$1 , d1
                dbf d6 , AND_OUTER1
                lsr.l #$1 , d2
                move.l #$8167E123, d1       * Initial Data-Y
                move.l #$0000001E, d6       * Inner loop counter
                dbf d7 , AND_OUTER1
                
                cmpi.l #$CF212883 , d4      * Check the data results
                bne *                
                cmpi.l #$00002D10 , d5      * Check the Flag results
                bne *                
                   
                   
  ** Register to <EA>

                move.l #$86738374, d0       * Initial Data-X  Inner loop
                move.l #$FC55F2FE, d1       * Initial Data-Y  Outer loop
                move.l #$86738374, d2
                move.l #$00000000, d3
                move.l #$00000000, d4       * Cumulative data results
                move.l #$00000000, d5       * Cumulative flag results
                move.l #$0000001E, d6       * Inner loop counter
                move.l #$0000001D, d7       * Outer loop counter
                move.l #$00000100, a0       * Address for memory EA operations


AND_OUTER2:    
 
    * BYTE     
                move.l d0 , (a0)
                and.b d1 , (a0)             
                move SR , d3      
                andi.l #$0C , d3            * Isolate flags 
                add.l d3 , d5               * Copy flag results into accumulator
                add.l (a0) , d4             * Copy data results into data accumulator   
 
    * WORD      
                move.l d0 , (a0)
                and.w d1 , (a0)  
                move SR , d3      
                andi.l #$0C , d3            * Isolate flags 
                add.l d3 , d5               * Copy flag results into accumulator
                add.l (a0) , d4             * Copy data results into data accumulator   
 
    * LONG      
                move.l d0 , (a0)
                and.l d1 , (a0)  
                move SR , d3      
                andi.l #$0F , d3            * Isolate flags 
                add.l d3 , d5               * Copy flag results into accumulator
                add.l (a0) , d4             * Copy data results into data accumulator   
                
                
                lsr.l #$1 , d1
                dbf d6 , AND_OUTER2
                lsr.l #$1 , d2
                move.l #$8167E123, d1       * Initial Data-Y
                move.l #$0000001E, d6       * Inner loop counter
                dbf d7 , AND_OUTER2
                
                cmpi.l #$4A3DE544 , d4      * Check the data results
                bne *                
                cmpi.l #$000018E8 , d5      * Check the Flag results
                bne *                 
                   
                   
                rts
                
               

*-----------------------------------------------------------
*-----------------------------------------------------------
* OPCODE : EOR
*-----------------------------------------------------------
*-----------------------------------------------------------

op_EOR:   
 
  ** Register to <EA>

                move.l #$86738374, d0       * Initial Data-X  Inner loop
                move.l #$FC55F2FE, d1       * Initial Data-Y  Outer loop
                move.l #$86738374, d2
                move.l #$00000000, d3
                move.l #$00000000, d4       * Cumulative data results
                move.l #$00000000, d5       * Cumulative flag results
                move.l #$0000001E, d6       * Inner loop counter
                move.l #$0000001D, d7       * Outer loop counter
                move.l #$00000100, a0       * Address for memory EA operations


EOR_OUTER2:    
 
    * BYTE     
                move.l d0 , (a0)
                eor.b d1 , (a0)             
                move SR , d3      
                andi.l #$0C , d3            * Isolate flags 
                add.l d3 , d5               * Copy flag results into accumulator
                add.l (a0) , d4             * Copy data results into data accumulator   
 
    * WORD      
                move.l d0 , (a0)
                eor.w d1 , (a0)  
                move SR , d3      
                andi.l #$0C , d3            * Isolate flags 
                add.l d3 , d5               * Copy flag results into accumulator
                add.l (a0) , d4             * Copy data results into data accumulator   
 
    * LONG      
                move.l d0 , (a0)
                eor.l d1 , (a0)  
                move SR , d3      
                andi.l #$0F , d3            * Isolate flags 
                add.l d3 , d5               * Copy flag results into accumulator
                add.l (a0) , d4             * Copy data results into data accumulator   
                
                
                lsr.l #$1 , d1
                dbf d6 , EOR_OUTER2
                lsr.l #$1 , d2
                move.l #$8167E123, d1       * Initial Data-Y
                move.l #$0000001E, d6       * Inner loop counter
                dbf d7 , EOR_OUTER2
                
                cmpi.l #$55C5EB70 , d4      * Check the data results
                bne *                
                cmpi.l #$00004430 , d5      * Check the Flag results
                bne *                 
                   
                   
                rts
                

*-----------------------------------------------------------
*-----------------------------------------------------------
* OPCODE : CMP
*-----------------------------------------------------------
*-----------------------------------------------------------

op_CMP:   


  ** <EA> to Register

                move.l #$a5a5a5a5, d0       * Initial Data-X  Inner loop
                move.l #$8167E123, d1       * Initial Data-Y  Outer loop
                move.l #$a5a5a5a5, d2
                move.l #$00000000, d3
                move.l #$00000000, d4       * Cumulative data results
                move.l #$00000000, d5       * Cumulative flag results
                move.l #$0000001E, d6       * Inner loop counter
                move.l #$0000001E, d7       * Outer loop counter
                move.l #$00000100, a0       * Address for memory EA operations


CMP_OUTER1:    
 
    * BYTE     
                move.l d1 , (a0)
                cmp.b (a0) , d0             
                move SR , d3      
                andi.l #$0F , d3            * Isolate flags 
                add.l d3 , d5               * Copy flag results into accumulator
                add.l d0 , d4               * Copy data results into data accumulator   
 
    * WORD      
                move.l d1 , (a0)
                cmp.w (a0) , d0             
                move SR , d3      
                andi.l #$0F , d3            * Isolate flags 
                add.l d3 , d5               * Copy flag results into accumulator
                add.l d0 , d4               * Copy data results into data accumulator   
 
    * LONG      
                move.l d1 , (a0)
                cmp.l (a0) , d0             
                move SR , d3      
                andi.l #$0F , d3            * Isolate flags 
                add.l d3 , d5               * Copy flag results into accumulator
                add.l d0 , d4               * Copy data results into data accumulator   
                
                
                lsr.l #$1 , d1
                dbf d6 , CMP_OUTER1
                lsr.l #$1 , d2
                move.l #$8167E123, d1       * Initial Data-Y
                move.l #$0000001E, d6       * Inner loop counter
                dbf d7 , CMP_OUTER1
                
                cmpi.l #$7878712F , d4      * Check the data results
                bne *                
                cmpi.l #$00005502 , d5      * Check the Flag results
                bne *                
                   
                   

                rts


*-----------------------------------------------------------
*-----------------------------------------------------------
* OPCODE : CMPA
*-----------------------------------------------------------
*-----------------------------------------------------------

op_CMPA:   


  ** <EA> to Register

                move.l #$a5a5a5a5, a0       * Initial Data-X  Inner loop
                move.l #$8167E123, d1       * Initial Data-Y  Outer loop
                move.l #$a5a5a5a5, d2
                move.l #$00000000, d3
                move.l #$00000000, d4       * Cumulative data results
                move.l #$00000000, d5       * Cumulative flag results
                move.l #$0000001E, d6       * Inner loop counter
                move.l #$0000001E, d7       * Outer loop counter
                move.l #$00000100, a1       * Address for memory EA operations


CMPA_OUTER1:    
  
 
    * WORD      
                move.l d1 , (a1)
                cmpa.w (a1) , a0             
                move SR , d3      
                andi.l #$0F , d3            * Isolate flags 
                add.l d3 , d5               * Copy flag results into accumulator
                add.l a0 , d4               * Copy data results into data accumulator   
 
    * LONG      
                move.l d1 , (a1)
                cmpa.l (a1) , a0             
                move SR , d3      
                andi.l #$0F , d3            * Isolate flags 
                add.l d3 , d5               * Copy flag results into accumulator
                add.l a0 , d4               * Copy data results into data accumulator   
                
                
                lsr.l #$1 , d1
                dbf d6 , CMPA_OUTER1
                lsr.l #$1 , d2
                move.l #$8167E123, d1       * Initial Data-Y
                move.l #$0000001E, d6       * Inner loop counter
                dbf d7 , CMPA_OUTER1
                
                cmpi.l #$a5a5a0ca , d4      * Check the data results
                bne *                
                cmpi.l #$00003A7D , d5      * Check the Flag results
                bne *                
                       

                rts



*-----------------------------------------------------------
*-----------------------------------------------------------
* OPCODE : CMPM
*-----------------------------------------------------------
*-----------------------------------------------------------

op_CMPM: 

                move.l #$00000100, a0       * Address for Data-X
                move.l #$00000200, a1       * Address for Data-Y
                move.l #$00000000, d0       
                move.l #$00000000, d1       
                move.l #$00000000, d2       
                
                move.l #$11FF5580 , (a0)+   * Populate test data
                move.l #$1111FFFF , (a0)+   * Populate test data
                move.l #$33333333 , (a0)+   * Populate test data
                move.l #$44444444 , (a0)+   * Populate test data
                
                move.l #$80FF337F , (a1)+   * Populate test data
                move.l #$FFFF1111 , (a1)+   * Populate test data
                move.l #$33333333 , (a1)+   * Populate test data
                move.l #$44444444 , (a1)+   * Populate test data
                
                move.l #$00000100, a0       * Address for Data-X
                move.l #$00000200, a1       * Address for Data-Y
                move.l #$0000000F, d6       * Loop counter
                
CMPM_LOOP1:     cmpm.b (a0)+ , (a1)+
                move SR , d3      
                andi.l #$0F , d3            * Isolate flags 
                add.l d3 , d0               * Copy flag results into accumulator                
                dbf d6 , CMPM_LOOP1


                move.l #$00000100, a0       * Address for Data-X
                move.l #$00000200, a1       * Address for Data-Y
                move.l #$00000007, d6       * Loop counter
                
CMPM_LOOP2:     cmpm.w (a0)+ , (a1)+
                move SR , d3      
                andi.l #$0F , d3            * Isolate flags 
                add.l d3 , d1               * Copy flag results into accumulator                
                dbf d6 , CMPM_LOOP2


                move.l #$00000100, a0       * Address for Data-X
                move.l #$00000200, a1       * Address for Data-Y
                move.l #$00000003, d6       * Loop counter
                
CMPM_LOOP3:     cmpm.l (a0)+ , (a1)+
                move SR , d3      
                andi.l #$0F , d3            * Isolate flags 
                add.l d3 , d2               * Copy flag results into accumulator                
                dbf d6 , CMPM_LOOP3


                cmpi.l #$0000004C , d0      * Check the data results
                bne *                
                cmpi.l #$00000024 , d1      
                bne *                
                cmpi.l #$00000012 , d2      
                bne *                
        
                rts


*-----------------------------------------------------------
*-----------------------------------------------------------
* OPCODE : ADD
*-----------------------------------------------------------
*-----------------------------------------------------------

op_ADD: 


  ** <EA> to Register
                move.l #$a5a5a5a5, d0       * Initial Data-X  Inner loop
                move.l #$8167E123, d1       * Initial Data-Y  Outer loop
                move.l #$a5a5a5a5, d2
                move.l #$00000000, d3
                move.l #$00000000, d4       * Cumulative data results
                move.l #$00000000, d5       * Cumulative flag results
                move.l #$0000001E, d6       * Inner loop counter
                move.l #$0000001E, d7       * Outer loop counter
                move.l #$00000100, a0       * Address for memory EA operations


ADD_OUTER1:    
 
    * BYTE     
                move.l d1 , (a0)
                add.b (a0) , d0             
                move SR , d3      
                andi.l #$1F , d3            * Isolate flags 
                add.l d3 , d5               * Copy flag results into accumulator
                add.l d0 , d4               * Copy data results into data accumulator   
 
    * WORD      
                move.l d1 , (a0)
                add.w (a0) , d0             
                move SR , d3      
                andi.l #$0C , d3            * Isolate flags 
                add.l d3 , d5               * Copy flag results into accumulator
                add.l d0 , d4               * Copy data results into data accumulator   
 
    * LONG      
                move.l d1 , (a0)
                add.l (a0) , d0             
                move SR , d3      
                andi.l #$0F , d3            * Isolate flags 
                add.l d3 , d5               * Copy flag results into accumulator
                add.l d0 , d4               * Copy data results into data accumulator   
                
                
                ror.l #$1 , d1
                dbf d6 , ADD_OUTER1
                ror.l #$1 , d2
                move.l #$8167E123, d1       * Initial Data-Y
                move.l #$0000001E, d6       * Inner loop counter
                dbf d7 , ADD_OUTER1
                
                cmpi.l #$23ED428F , d4      * Check the data results
                bne *                
                cmpi.l #$00004C96 , d5      * Check the Flag results
                bne *                
                   
                   
  ** Register to <EA>
                move.l #$86738374, d0       * Initial Data-X  Inner loop
                move.l #$FC55F2FE, d1       * Initial Data-Y  Outer loop
                move.l #$86738374, d2
                move.l #$00000000, d3
                move.l #$00000000, d4       * Cumulative data results
                move.l #$00000000, d5       * Cumulative flag results
                move.l #$0000001E, d6       * Inner loop counter
                move.l #$0000001D, d7       * Outer loop counter
                move.l #$00000100, a0       * Address for memory EA operations


ADD_OUTER2:    
 
    * BYTE     
                move.l d0 , (a0)
                add.b d1 , (a0)             
                move SR , d3      
                andi.l #$0C , d3            * Isolate flags 
                add.l d3 , d5               * Copy flag results into accumulator
                add.l (a0) , d4             * Copy data results into data accumulator   
 
    * WORD      
                move.l d0 , (a0)
                add.w d1 , (a0)  
                move SR , d3      
                andi.l #$1F , d3            * Isolate flags 
                add.l d3 , d5               * Copy flag results into accumulator
                add.l (a0) , d4             * Copy data results into data accumulator   
 
    * LONG      
                move.l d0 , (a0)
                add.l d1 , (a0)  
                move SR , d3      
                andi.l #$0F , d3            * Isolate flags 
                add.l d3 , d5               * Copy flag results into accumulator
                add.l (a0) , d4             * Copy data results into data accumulator   
                
                
                ror.l #$1 , d1
                dbf d6 , ADD_OUTER2
                ror.l #$1 , d2
                move.l #$8167E123, d1       * Initial Data-Y
                move.l #$0000001E, d6       * Inner loop counter
                dbf d7 , ADD_OUTER2
                
                cmpi.l #$6701B884 , d4      * Check the data results
                bne *                
                cmpi.l #$00005467 , d5      * Check the Flag results
                bne *                 
                   
                rts

*-----------------------------------------------------------
*-----------------------------------------------------------
* OPCODE : SUB
*-----------------------------------------------------------
*-----------------------------------------------------------

op_SUB: 

  ** <EA> to Register
                move.l #$a5a5a5a5, d0       * Initial Data-X  Inner loop
                move.l #$8167E123, d1       * Initial Data-Y  Outer loop
                move.l #$a5a5a5a5, d2
                move.l #$00000000, d3
                move.l #$00000000, d4       * Cumulative data results
                move.l #$00000000, d5       * Cumulative flag results
                move.l #$0000001E, d6       * Inner loop counter
                move.l #$0000001E, d7       * Outer loop counter
                move.l #$00000100, a0       * Address for memory EA operations


SUB_OUTER1:    
 
    * BYTE     
                move.l d1 , (a0)
                sub.b (a0) , d0             
                move SR , d3      
                andi.l #$1F , d3            * Isolate flags 
                add.l d3 , d5               * Copy flag results into accumulator
                add.l d0 , d4               * Copy data results into data accumulator   
 
    * WORD      
                move.l d1 , (a0)
                sub.w (a0) , d0             
                move SR , d3      
                andi.l #$0C , d3            * Isolate flags 
                add.l d3 , d5               * Copy flag results into accumulator
                add.l d0 , d4               * Copy data results into data accumulator   
 
    * LONG      
                move.l d1 , (a0)
                sub.l (a0) , d0             
                move SR , d3      
                andi.l #$0F , d3            * Isolate flags 
                add.l d3 , d5               * Copy flag results into accumulator
                add.l d0 , d4               * Copy data results into data accumulator   
                
                
                ror.l #$1 , d1
                dbf d6 , SUB_OUTER1
                ror.l #$1 , d2
                move.l #$8167E123, d1       * Initial Data-Y
                move.l #$0000001E, d6       * Inner loop counter
                dbf d7 , SUB_OUTER1
                
                cmpi.l #$1A8D14CF , d4      * Check the data results
                bne *                
                cmpi.l #$00004FC4 , d5      * Check the Flag results
                bne *                
                   
                   
  ** Register to <EA>
                move.l #$86738374, d0       * Initial Data-X  Inner loop
                move.l #$FC55F2FE, d1       * Initial Data-Y  Outer loop
                move.l #$86738374, d2
                move.l #$00000000, d3
                move.l #$00000000, d4       * Cumulative data results
                move.l #$00000000, d5       * Cumulative flag results
                move.l #$0000001E, d6       * Inner loop counter
                move.l #$0000001D, d7       * Outer loop counter
                move.l #$00000100, a0       * Address for memory EA operations


SUB_OUTER2:    
 
    * BYTE     
                move.l d0 , (a0)
                sub.b d1 , (a0)             
                move SR , d3      
                andi.l #$0C , d3            * Isolate flags 
                add.l d3 , d5               * Copy flag results into accumulator
                add.l (a0) , d4             * Copy data results into data accumulator   
 
    * WORD      
                move.l d0 , (a0)
                sub.w d1 , (a0)  
                move SR , d3      
                andi.l #$1F , d3            * Isolate flags 
                add.l d3 , d5               * Copy flag results into accumulator
                add.l (a0) , d4             * Copy data results into data accumulator   
 
    * LONG      
                move.l d0 , (a0)
                sub.l d1 , (a0)  
                move SR , d3      
                andi.l #$0F , d3            * Isolate flags 
                add.l d3 , d5               * Copy flag results into accumulator
                add.l (a0) , d4             * Copy data results into data accumulator   
                
                
                ror.l #$1 , d1
                dbf d6 , SUB_OUTER2
                ror.l #$1 , d2
                move.l #$8167E123, d1       * Initial Data-Y
                move.l #$0000001E, d6       * Inner loop counter
                dbf d7 , SUB_OUTER2
                
                cmpi.l #$36D38BEC , d4      * Check the data results
                bne *                
                cmpi.l #$000045A5 , d5      * Check the Flag results
                bne *                 
                   



                rts



*-----------------------------------------------------------
*-----------------------------------------------------------
* OPCODE : ADDA
*-----------------------------------------------------------
*-----------------------------------------------------------

op_ADDA: 

  ** <EA> to Register
                move.l #$a5a5a5a5, d0       * Initial Data-X  Inner loop
                move.l #$8167E123, d1       
                move.l #$a5a5a5a5, d2
                move.l #$00000000, d3
                move.l #$00000000, d4       * Cumulative data results
                move.l #$00000000, d5       * Cumulative flag results
                move.l #$0000001E, d6       * Inner loop counter
                move.l #$0000001E, d7       * Outer loop counter
                move.l #$00000100, a0       * Address for memory EA operations
                move.l #$8167E123, a1       * Initial Data-Y  Outer loop

ADDA_OUTER1:    

    * WORD      
                *move.l d1 , (a0)       * !!! Easy68K is not altering the whole 32-bits of the address register
                *adda.w (a0) , a1             
                *add.l a1 , d4               * Copy data results into data accumulator   
 
    * LONG      
                move.l d1 , (a0)
                adda.l (a0) , a1             
                add.l a1 , d4               * Copy data results into data accumulator   
                
                ror.l #$1 , d1
                dbf d6 , ADDA_OUTER1
                ror.l #$1 , d1
                move.l d1 , a1
                move.l #$8167E123, d1       * Initial Data-Y
                move.l #$0000001E, d6       * Inner loop counter
                dbf d7 , ADDA_OUTER1
                
                cmpi.l #$AC04DB4C , d4      * Check the data results
                bne *                
              
                 
                rts


*-----------------------------------------------------------
*-----------------------------------------------------------
* OPCODE : SUBA
*-----------------------------------------------------------
*-----------------------------------------------------------

op_SUBA: 

  ** <EA> to Register
                move.l #$a5a5a5a5, d0       * Initial Data-X  Inner loop
                move.l #$8167E123, d1       
                move.l #$a5a5a5a5, d2
                move.l #$00000000, d3
                move.l #$00000000, d4       * Cumulative data results
                move.l #$00000000, d5       * Cumulative flag results
                move.l #$0000001E, d6       * Inner loop counter
                move.l #$0000001E, d7       * Outer loop counter
                move.l #$00000100, a0       * Address for memory EA operations
                move.l #$8167E123, a1       * Initial Data-Y  Outer loop

SUBA_OUTER1:    

    * WORD      
                *move.l d1 , (a0) * !!! Easy68K is not altering the whole 32-bits of the address register
                *suba.w (a0) , a1             
                *add.l a1 , d4               * Copy data results into data accumulator   
 
    * LONG      
                move.l d1 , (a0)
                suba.l (a0) , a1             
                add.l a1 , d4               * Copy data results into data accumulator   
                
                ror.l #$1 , d1
                dbf d6 , SUBA_OUTER1
                ror.l #$1 , d1
                move.l d1 , a1
                move.l #$8167E123, d1       * Initial Data-Y
                move.l #$0000001E, d6       * Inner loop counter
                dbf d7 , SUBA_OUTER1
                
                cmpi.l #$E1E36D7A , d4      * Check the data results
                bne *                
              
                 
                rts



*-----------------------------------------------------------
*-----------------------------------------------------------
* OPCODE : ADDX
*-----------------------------------------------------------
*-----------------------------------------------------------

op_ADDX: 


  ** Register to Register
                move.l #$a5a5a5a5, d0       * Initial Data-X  Inner loop
                move.l #$8167E123, d1       * Initial Data-Y  Outer loop
                move.l #$a5a5a5a5, d2
                move.l #$00000000, d3
                move.l #$00000000, d4       * Cumulative data results
                move.l #$00000000, d5       * Cumulative flag results
                move.l #$0000001E, d6       * Inner loop counter
                move.l #$0000001E, d7       * Outer loop counter
                move.l #$00000100, a0       * Address for memory EA operations


ADDX_OUTER1:    
 
    * BYTE    
                move.l d2 , d0
                addx.b d1 , d0             
                move SR , d3      
                andi.l #$1F , d3            * Isolate flags 
                add.l d3 , d5               * Copy flag results into accumulator
                add.l d0 , d4               * Copy data results into data accumulator   
 
    * WORD      
                move.l d2 , d0
                addx.w d1 , d0             
                move SR , d3      
                andi.l #$1F , d3            * Isolate flags 
                add.l d3 , d5               * Copy flag results into accumulator
                add.l d0 , d4               * Copy data results into data accumulator   
 
    * LONG      
                move.l d2 , d0
                addx.l d1 , d0             
                move SR , d3      
                andi.l #$1F , d3            * Isolate flags 
                add.l d3 , d5               * Copy flag results into accumulator
                add.l d0 , d4               * Copy data results into data accumulator   
                
                ror.l #$1 , d1
                dbf d6 , ADDX_OUTER1
                ror.l #$1 , d2
                move.l #$8167E123, d1       * Initial Data-Y
                move.l #$0000001E, d6       * Inner loop counter
                dbf d7 , ADDX_OUTER1
                
                cmpi.l #$4E96A4D9 , d4      * Check the data results
                bne *                
                cmpi.l #$000085CD , d5      * Check the Flag results
                bne *                
                   
    
    
    * -(An) , -(An)
    
                move.l #$00000000, d0       * BYTE Flag Results Accumulator     
                move.l #$00000000, d1        
                move.l #$00000000, d2      
                move.l #$00000100, a0       * Address for Data-X
                move.l #$00000200, a1       * Address for Data-Y
                move.l #$11FF5580 , (a0)+   * Populate test data
                move.l #$1111FFFF , (a0)+   * Populate test data
                move.l #$33333333 , (a0)+   * Populate test data
                move.l #$44444444 , (a0)+   * Populate test data
                move.l #$80FF337F , (a1)+   * Populate test data
                move.l #$FFFF1111 , (a1)+   * Populate test data
                move.l #$33333333 , (a1)+   * Populate test data
                move.l #$44444444 , (a1)+   * Populate test data
                

                move.l #$0000000F, d6       * Loop counter
                
ADDX_LOOP3:     addx.b -(a0) , -(a1)
                move SR , d3      
                andi.l #$0F , d3            * Isolate flags 
                add.l d3 , d0               * Copy flag results into accumulator    
                add.b (a1) , d1     
                dbf d6 , ADDX_LOOP3


                move.l #$00000110, a0       * Address for Data-X
                move.l #$00000210, a1       * Address for Data-Y
                move.l #$00000007, d6       * Loop counter
                
ADDX_LOOP4:     addx.w -(a0) , -(a1)
                move SR , d3      
                andi.l #$0F , d3            * Isolate flags 
                add.l d3 , d0               * Copy flag results into accumulator    
                add.w (a1) , d1     
                dbf d6 , ADDX_LOOP4


                move.l #$00000110, a0       * Address for Data-X
                move.l #$00000210, a1       * Address for Data-Y
                move.l #$00000003, d6       * Loop counter
                
ADDX_LOOP5:     addx.l -(a0) , -(a1)
                move SR , d3      
                andi.l #$0F , d3            * Isolate flags 
                add.l d3 , d0               * Copy flag results into accumulator    
                add.l (a1) , d1     
                dbf d6 , ADDX_LOOP5


                cmpi.l #$00000095 , d0      * Check the flag results
                bne *                
                cmpi.l #$C812A682 , d1      * Check the data results 
                bne *                
 
                rts




*-----------------------------------------------------------
*-----------------------------------------------------------
* OPCODE : SUBX
*-----------------------------------------------------------
*-----------------------------------------------------------

op_SUBX: 


  ** Register to Register
                move.l #$a5a5a5a5, d0       * Initial Data-X  Inner loop
                move.l #$8167E123, d1       * Initial Data-Y  Outer loop
                move.l #$a5a5a5a5, d2
                move.l #$00000000, d3
                move.l #$00000000, d4       * Cumulative data results
                move.l #$00000000, d5       * Cumulative flag results
                move.l #$0000001E, d6       * Inner loop counter
                move.l #$0000001E, d7       * Outer loop counter
                move.l #$00000100, a0       * Address for memory EA operations


SUBX_OUTER1:    
 
    * BYTE    
                move.l d2 , d0
                subx.b d1 , d0             
                move SR , d3      
                andi.l #$1F , d3            * Isolate flags 
                add.l d3 , d5               * Copy flag results into accumulator
                add.l d0 , d4               * Copy data results into data accumulator   
 
    * WORD      
                move.l d2 , d0
                subx.w d1 , d0             
                move SR , d3      
                andi.l #$1F , d3            * Isolate flags 
                add.l d3 , d5               * Copy flag results into accumulator
                add.l d0 , d4               * Copy data results into data accumulator   
 
    * LONG      
                move.l d2 , d0
                subx.l d1 , d0             
                move SR , d3      
                andi.l #$1F , d3            * Isolate flags 
                add.l d3 , d5               * Copy flag results into accumulator
                add.l d0 , d4               * Copy data results into data accumulator   
                
                ror.l #$1 , d1
                dbf d6 , SUBX_OUTER1
                ror.l #$1 , d2
                move.l #$8167E123, d1       * Initial Data-Y
                move.l #$0000001E, d6       * Inner loop counter
                dbf d7 , SUBX_OUTER1
                
                cmpi.l #$FCAA913E , d4      * Check the data results
                bne *                
                cmpi.l #$00007E89 , d5      * Check the Flag results
                bne *                
                   
    
    
    * -(An) , -(An)
    
                move.l #$00000000, d0       * BYTE Flag Results Accumulator     
                move.l #$00000000, d1        
                move.l #$00000000, d2      
                move.l #$00000100, a0       * Address for Data-X
                move.l #$00000200, a1       * Address for Data-Y
                move.l #$11FF5580 , (a0)+   * Populate test data
                move.l #$1111FFFF , (a0)+   * Populate test data
                move.l #$80FF337F , (a0)+   * Populate test data
                move.l #$44444444 , (a0)+   * Populate test data
                move.l #$80FF337F , (a1)+   * Populate test data
                move.l #$1111FFFF , (a1)+   * Populate test data
                move.l #$33333333 , (a1)+   * Populate test data
                move.l #$5580EECC , (a1)+   * Populate test data
                

                move.l #$0000000F, d6       * Loop counter
                
SUBX_LOOP3:     subx.b -(a0) , -(a1)
                move SR , d3      
                andi.l #$0F , d3            * Isolate flags 
                add.l d3 , d0               * Copy flag results into accumulator    
                add.b (a1) , d1     
                dbf d6 , SUBX_LOOP3


                move.l #$00000110, a0       * Address for Data-X
                move.l #$00000210, a1       * Address for Data-Y
                move.l #$00000007, d6       * Loop counter
                
SUBX_LOOP4:     subx.w -(a0) , -(a1)
                move SR , d3      
                andi.l #$0F , d3            * Isolate flags 
                add.l d3 , d0               * Copy flag results into accumulator    
                add.w (a1) , d1     
                dbf d6 , SUBX_LOOP4


                move.l #$00000110, a0       * Address for Data-X
                move.l #$00000210, a1       * Address for Data-Y
                move.l #$00000003, d6       * Loop counter
                
SUBX_LOOP5:     subx.l -(a0) , -(a1)
                move SR , d3      
                andi.l #$0F , d3            * Isolate flags 
                add.l d3 , d0               * Copy flag results into accumulator    
                add.l (a1) , d1     
                dbf d6 , SUBX_LOOP5


                cmpi.l #$000000B1 , d0      * Check the flag results
                bne *                
                cmpi.l #$62C6F417 , d1      * Check the data results 
                bne *                
 
                rts


*-----------------------------------------------------------
*-----------------------------------------------------------
* OPCODE : MULU
*-----------------------------------------------------------
*-----------------------------------------------------------

op_MULU:     

                move.l #$FE805501, d0        * Initial 
                move.l #$5697EDB6, d1        * Initial Y
                move.l #$FE805501, d2
                move.l #$00000000, d3
                move.l #$00000000, d4        * Cumulative data results
                move.l #$00000000, d5       * Cumulative flag results
                move.l #$0000000E, d6       * Inner loop counter
                move.l #$0000000E, d7       * Outer loop counter


MULU_OUTER1:    mulu d1  , d0             
                move SR , d3      
                andi.l #$0C , d3            * Isolate flags 
                add.l d3 , d5               * Copy flag results into accumulator
                add.l d0 , d4               * Copy data results into data accumulator   
                ror.l #$1 , d1

                dbf d6 , MULU_OUTER1
                ror.l #$1 , d2
                move.l d2 , d0
                move.l #$0000000E, d6       * Inner loop counter
                dbf d7 , MULU_OUTER1
                
                cmpi.l #$76FB988C , d4      * Check the data results
                bne *                
                     
                cmpi.l #$00000170 , d5      * Check the Flag results
                bne *                 
          

                rts
                
                
*-----------------------------------------------------------
*-----------------------------------------------------------
* OPCODE : MULS
*-----------------------------------------------------------
*-----------------------------------------------------------

op_MULS:     

                move.l #$FE805501, d0        * Initial 
                move.l #$5697EDB6, d1        * Initial Y
                move.l #$FE805501, d2
                move.l #$00000000, d3
                move.l #$00000000, d4        * Cumulative data results
                move.l #$00000000, d5       * Cumulative flag results
                move.l #$0000000E, d6       * Inner loop counter
                move.l #$0000000E, d7       * Outer loop counter


MULS_OUTER1:    muls d1  , d0             
                move SR , d3      
                andi.l #$0C , d3            * Isolate flags 
                add.l d3 , d5               * Copy flag results into accumulator
                add.l d0 , d4               * Copy data results into data accumulator   
                ror.l #$1 , d1

                dbf d6 , MULS_OUTER1
                ror.l #$1 , d2
                move.l d2 , d0
                move.l #$0000000E, d6       * Inner loop counter
                dbf d7 , MULS_OUTER1
                
                cmpi.l #$D4E2988C , d4      * Check the data results
                bne *                
                     
                cmpi.l #$000003E0 , d5      * Check the Flag results
                bne *                 
          

                rts
                
  
                
*-----------------------------------------------------------
*-----------------------------------------------------------
* OPCODE : EXG
*-----------------------------------------------------------
*-----------------------------------------------------------

op_EXG:     
                move.l #$d1d1d1d1, d1      
                move.l #$d2d2d2d2, d2      
                move.l #$d3d3d3d3, d3      
                move.l #$a1a1a1a1, a1      
                move.l #$a2a2a2a2, a2  
                move.l #$a3a3a3a3, a3  
                
                exg d1 , d2    
                exg a1 , a2    
                exg d3 , a3  

                cmpi.l #$d2d2d2d2 , d1      * Check the results
                bne *                 
                cmpi.l #$d1d1d1d1 , d2    
                bne *                 
                cmpi.l #$a3a3a3a3 , d3    
                bne *                 
                
                move.l a1 , d1
                move.l a2 , d2
                move.l a3 , d3
 
                cmpi.l #$a2a2a2a2 , d1    
                bne *                 
                cmpi.l #$a1a1a1a1 , d2     
                bne *                 
                cmpi.l #$d3d3d3d3 , d3     
                bne *                 
 
                rts
      
                
*-----------------------------------------------------------
*-----------------------------------------------------------
* OPCODE : ROx
*-----------------------------------------------------------
*-----------------------------------------------------------

    * Subroutine to check and accumulate the flags 
ROx_FLAGS:      move SR , d3      
                andi.l #$0F , d3            * Isolate flags 
                add.l d3 , d5               * Copy flag results into accumulator
                rts
    
op_ROx:   
           
    * Shift a Register LEFT and RIGHT with shift_count ## IN A REGISTER ##
    
       * BYTE LEFT
                move.l #$80018FF1, d0   
                move.l #$00000000, d5  
                move.l #$00000011, d6  
ROx_LOOP1:
                rol.b d6 , d0       
                jsr ROx_FLAGS
                dbf d6 , ROx_LOOP1
                cmpi.l #$80018FE3 , d0     
                bne *                 
                cmpi.l #$0000006B, d5     
                bne *      
    
       * BYTE RIGHT
                move.l #$80018FF1, d0   
                move.l #$00000012, d6  
ROx_LOOP2:
                ror.b d6 , d0       
                jsr ROx_FLAGS
                dbf d6 , ROx_LOOP2
                cmpi.l #$80018F3E , d0     
                bne *                 
                cmpi.l #$000000C5, d5     
                bne *      

    
       * WORD LEFT
                move.l #$80018FF1, d0   
                move.l #$00000013, d6  
ROx_LOOP3:
                rol.w d6 , d0       
                jsr ROx_FLAGS
                dbf d6 , ROx_LOOP3
                cmpi.l #$800163FC , d0     
                bne *                 
                cmpi.l #$00000131, d5     
                bne *      
    
       * WORD RIGHT
                move.l #$80018FF1, d0   
                move.l #$0000001E, d6  
ROx_LOOP4:
                ror.w d6 , d0       
                jsr ROx_FLAGS
                dbf d6 , ROx_LOOP4
                cmpi.l #$8001C7F8 , d0     
                bne *                 
                cmpi.l #$000001DB, d5     
                bne *      

    
       * LONG LEFT
                move.l #$80018FF1, d0   
                move.l #$00000015, d6  
ROx_LOOP5:
                rol.l d6 , d0       
                jsr ROx_FLAGS
                dbf d6 , ROx_LOOP5
                cmpi.l #$00C7F8C0 , d0     
                bne *                 
                cmpi.l #$0000021A, d5     
                bne *      
    
       * LONG RIGHT
                move.l #$80018FF1, d0   
                move.l #$00000016, d6  
ROx_LOOP6:
                ror.l d6 , d0       
                jsr ROx_FLAGS
                dbf d6 , ROx_LOOP6
                cmpi.l #$000C7F8C , d0     
                bne *                 
                cmpi.l #$00000250, d5     
                bne *      

            
    * Shift a Register LEFT and RIGHT with shift_count ## IN THE OPCODE ##
    
                move.l #$80018FF1, d0   
                move.l #$00000000, d5   

       * BYTE LEFT
                rol.b #1 , d0       
                jsr ROx_FLAGS
                rol.b #5 , d0      
                jsr ROx_FLAGS
                rol.b #7 , d0   
                jsr ROx_FLAGS
                rol.b #8 , d0   
                jsr ROx_FLAGS
                cmpi.l #$80018F3E , d0     
                bne *                 
                cmpi.l #$00000009, d5     
                bne *                 
     
       * BYTE RIGHT
                ror.b #1 , d0       
                jsr ROx_FLAGS
                ror.b #5 , d0      
                jsr ROx_FLAGS
                ror.b #7 , d0   
                jsr ROx_FLAGS
                ror.b #8 , d0   
                jsr ROx_FLAGS
                cmpi.l #$80018FF1 , d0     
                bne *                 
                cmpi.l #$00000024, d5     
                bne *                 
     
       * WORD LEFT
                rol.w #1 , d0       
                jsr ROx_FLAGS
                rol.w #5 , d0      
                jsr ROx_FLAGS
                rol.w #7 , d0   
                jsr ROx_FLAGS
                rol.w #8 , d0   
                jsr ROx_FLAGS
                cmpi.l #$8001FE31 , d0     
                bne *                 
                cmpi.l #$00000037, d5     
                bne *                 
                  
       * WORD RIGHT
                ror.w #1 , d0       
                jsr ROx_FLAGS
                ror.w #5 , d0      
                jsr ROx_FLAGS
                ror.w #7 , d0   
                jsr ROx_FLAGS
                ror.w #8 , d0   
                jsr ROx_FLAGS
                cmpi.l #$80018FF1 , d0     
                bne *                 
                cmpi.l #$0000005B, d5     
                bne *                 
               
       * LONG LEFT
                rol.l #1 , d0       
                jsr ROx_FLAGS
                rol.l #5 , d0      
                jsr ROx_FLAGS
                rol.l #7 , d0   
                jsr ROx_FLAGS
                rol.l #8 , d0   
                jsr ROx_FLAGS
                cmpi.l #$FE300031 , d0     
                bne *                 
                cmpi.l #$00000065, d5     
                bne *                 
                                
       * LONG RIGHT
                ror.l #1 , d0       
                jsr ROx_FLAGS
                ror.l #5 , d0      
                jsr ROx_FLAGS
                ror.l #7 , d0   
                jsr ROx_FLAGS
                ror.l #8 , d0   
                jsr ROx_FLAGS
                cmpi.l #$80018FF1 , d0     
                bne *                 
                cmpi.l #$00000080, d5     
                bne *                 
   
            
    * Shift a Memory location LEFT and RIGHT with shift_count of 1 - WORD only
    
                move.l #$00000000, d5   
                move.l #$00000100, a0 
                move.w #$8FF1 , (a0)
                
       * WORD LEFT
                rol (a0)       
                jsr ROx_FLAGS
                rol (a0)       
                jsr ROx_FLAGS
                rol (a0)       
                jsr ROx_FLAGS
                rol (a0)       
                jsr ROx_FLAGS
                move.w (a0) , d0
                cmpi.l #$8001FF18 , d0     
                bne *                 
                cmpi.l #$00000009, d5     
                bne *                 
                  
       * WORD RIGHT
                ror (a0)       
                jsr ROx_FLAGS
                ror (a0)       
                jsr ROx_FLAGS
                ror (a0)       
                jsr ROx_FLAGS                
                ror (a0)       
                jsr ROx_FLAGS               
                ror (a0)       
                jsr ROx_FLAGS
                ror (a0)       
                jsr ROx_FLAGS
                move.w (a0) , d0
                cmpi.l #$800163FC , d0     
                bne *                 
                cmpi.l #$0000001B, d5     
                bne *                 

                rts
      
     
                
*-----------------------------------------------------------
*-----------------------------------------------------------
* OPCODE : ROXx
*-----------------------------------------------------------
*-----------------------------------------------------------

    * Subroutine to check and accumulate the flags 
ROXx_FLAGS:     move SR , d3      
                andi.l #$0F , d3            * Isolate flags 
                add.l d3 , d5               * Copy flag results into accumulator
                rts
    
op_ROXx:   
           
    * Shift a Register LEFT and RIGHT with shift_count ## IN A REGISTER ##
    
       * BYTE LEFT
                move.l #$80018FF1, d0   
                move.l #$00000000, d5  
                move.l #$00000011, d6  
ROXx_LOOP1:
                roxl.b d6 , d0       
                jsr ROXx_FLAGS
                dbf d6 , ROXx_LOOP1
                cmpi.l #$80018FD0 , d0     
                bne *                 
                cmpi.l #$00000042, d5     
                bne *      
    
       * BYTE RIGHT
                move.l #$80018FF1, d0   
                move.l #$00000012, d6  
ROXx_LOOP2:
                roxr.b d6 , d0       
                jsr ROXx_FLAGS
                dbf d6 , ROXx_LOOP2
                cmpi.l #$80018F51 , d0     
                bne *                 
                cmpi.l #$0000009C, d5     
                bne *      

    
       * WORD LEFT
                move.l #$80018FF1, d0   
                move.l #$00000013, d6  
ROXx_LOOP3:
                roxl.w d6 , d0       
                jsr ROXx_FLAGS
                dbf d6 , ROXx_LOOP3
                cmpi.l #$80013980 , d0     
                bne *                 
                cmpi.l #$000000C9, d5     
                bne *      
    
       * WORD RIGHT
                move.l #$80018FF1, d0   
                move.l #$0000001E, d6  
ROXx_LOOP4:
                roxr.w d6 , d0       
                jsr ROXx_FLAGS
                dbf d6 , ROXx_LOOP4
                cmpi.l #$80010A1D , d0     
                bne *                 
                cmpi.l #$0000014D, d5     
                bne *      

    
       * LONG LEFT
                move.l #$80018FF1, d0   
                move.l #$00000015, d6  
ROXx_LOOP5:
                roxl.l d6 , d0       
                jsr ROXx_FLAGS
                dbf d6 , ROXx_LOOP5
                cmpi.l #$800185D0 , d0     
                bne *                 
                cmpi.l #$000001A1, d5     
                bne *      
    
       * LONG RIGHT
                move.l #$80018FF1, d0   
                move.l #$00000016, d6  
ROXx_LOOP6:
                roxr.l d6 , d0       
                jsr ROXx_FLAGS
                dbf d6 , ROXx_LOOP6
                cmpi.l #$082D8200 , d0     
                bne *                 
                cmpi.l #$000001DE, d5     
                bne *      

            
    * Shift a Register LEFT and RIGHT with shift_count ## IN THE OPCODE ##
    
                move.l #$80018FF1, d0   
                move.l #$00000000, d5   

       * BYTE LEFT
                roxl.b #1 , d0       
                jsr ROXx_FLAGS
                roxl.b #5 , d0      
                jsr ROXx_FLAGS
                roxl.b #7 , d0   
                jsr ROXx_FLAGS
                roxl.b #8 , d0   
                jsr ROXx_FLAGS
                cmpi.l #$80018F09 , d0     
                bne *                 
                cmpi.l #$0000000B, d5     
                bne *                 
     
       * BYTE RIGHT
                roxr.b #1 , d0       
                jsr ROXx_FLAGS
                roxr.b #5 , d0      
                jsr ROXx_FLAGS
                roxr.b #7 , d0   
                jsr ROXx_FLAGS
                roxr.b #8 , d0   
                jsr ROXx_FLAGS
                cmpi.l #$80018F00 , d0     
                bne *                 
                cmpi.l #$00000015, d5     
                bne *                 
     
       * WORD LEFT
                roxl.w #1 , d0       
                jsr ROXx_FLAGS
                roxl.w #5 , d0      
                jsr ROXx_FLAGS
                roxl.w #7 , d0   
                jsr ROXx_FLAGS
                roxl.w #8 , d0   
                jsr ROXx_FLAGS
                cmpi.l #$8001B000 , d0     
                bne *                 
                cmpi.l #$00000027, d5     
                bne *                 
                  
       * WORD RIGHT
                roxr.w #1 , d0       
                jsr ROXx_FLAGS
                roxr.w #5 , d0      
                jsr ROXx_FLAGS
                roxr.w #7 , d0   
                jsr ROXx_FLAGS
                roxr.w #8 , d0   
                jsr ROXx_FLAGS
                cmpi.l #$80010A00 , d0     
                bne *                 
                cmpi.l #$00000028, d5     
                bne *                 
               
       * LONG LEFT
                roxl.l #1 , d0       
                jsr ROXx_FLAGS
                roxl.l #5 , d0      
                jsr ROXx_FLAGS
                roxl.l #7 , d0   
                jsr ROXx_FLAGS
                roxl.l #8 , d0   
                jsr ROXx_FLAGS
                cmpi.l #$40000010 , d0     
                bne *                 
                cmpi.l #$0000002A, d5     
                bne *                 
                                
       * LONG RIGHT
                roxr.l #1 , d0       
                jsr ROXx_FLAGS
                roxr.l #5 , d0      
                jsr ROXx_FLAGS
                roxr.l #7 , d0   
                jsr ROXx_FLAGS
                roxr.l #8 , d0   
                jsr ROXx_FLAGS
                cmpi.l #$00010200 , d0     
                bne *                 
                cmpi.l #$00000032, d5     
                bne *                 
   
            
    * Shift a Memory location LEFT and RIGHT with shift_count of 1 - WORD only
    
                move.l #$00000000, d5   
                move.l #$00000100, a0 
                move.w #$8FF1 , (a0)
                
       * WORD LEFT
                roxl (a0)       
                jsr ROXx_FLAGS
                roxl (a0)       
                jsr ROXx_FLAGS
                roxl (a0)       
                jsr ROXx_FLAGS
                roxl (a0)       
                jsr ROXx_FLAGS
                move.w (a0) , d0
                cmpi.l #$0001FF10 , d0     
                bne *                 
                cmpi.l #$00000009, d5     
                bne *                 
                  
       * WORD RIGHT
                roxr (a0)       
                jsr ROXx_FLAGS
                roxr (a0)       
                jsr ROXx_FLAGS
                roxr (a0)       
                jsr ROXx_FLAGS                
                roxr (a0)       
                jsr ROXx_FLAGS               
                roxr (a0)       
                jsr ROXx_FLAGS
                roxr (a0)       
                jsr ROXx_FLAGS
                move.w (a0) , d0
                cmpi.l #$000103FC , d0     
                bne *                 
                cmpi.l #$0000000A, d5     
                bne *                 

                rts        


 
                
*-----------------------------------------------------------
*-----------------------------------------------------------
* OPCODE : SHIFTS
*-----------------------------------------------------------
*-----------------------------------------------------------

    * Subroutine to check and accumulate the flags 
SHIFTS_FLAGS:   move SR , d3      
                andi.l #$0F , d3            * Isolate flags 
                add.l d3 , d5               * Copy flag results into accumulator
                rts
    
op_SHIFTS:   
           
    * Shift a Register LEFT and RIGHT with shift_count ## IN A REGISTER ##
    
       * BYTE LEFT
                move.l #$80018F81, d0   
                move.l #$00000000, d5  
                move.l #$00000002, d6  
SHIFTS_LOOP1:
                asl.b d6 , d0       
                jsr SHIFTS_FLAGS
                dbf d6 , SHIFTS_LOOP1
                cmpi.l #$80018F08 , d0     
                bne *                 
                cmpi.l #$00000002, d5     
                bne *      
    
       * BYTE RIGHT
                move.l #$80018F81, d0   
                move.l #$00000002, d6  
SHIFTS_LOOP2:
                asr.b d6 , d0       
                jsr SHIFTS_FLAGS
                dbf d6 , SHIFTS_LOOP2
                cmpi.l #$80018FF0 , d0     
                bne *                 
                cmpi.l #$0000001A, d5     
                bne *      

    
       * WORD LEFT
                move.l #$80018FF1, d0   
                move.l #$00000002, d6  
SHIFTS_LOOP3:
                asl.w d6 , d0       
                jsr SHIFTS_FLAGS
                dbf d6 , SHIFTS_LOOP3
                cmpi.l #$80017F88 , d0     
                bne *                 
                cmpi.l #$0000001C, d5     
                bne *      
    
       * WORD RIGHT
                move.l #$80018FF1, d0   
                move.l #$00000002, d6  
SHIFTS_LOOP4:
                asr.w d6 , d0       
                jsr SHIFTS_FLAGS
                dbf d6 , SHIFTS_LOOP4
                cmpi.l #$8001F1FE , d0     
                bne *                 
                cmpi.l #$00000034, d5     
                bne *      

    
       * LONG LEFT
                move.l #$80018FF1, d0   
                move.l #$00000002, d6  
SHIFTS_LOOP5:
                asl.l d6 , d0       
                jsr SHIFTS_FLAGS
                dbf d6 , SHIFTS_LOOP5
                cmpi.l #$000C7F88 , d0     
                bne *                 
                cmpi.l #$00000036, d5     
                bne *      
    
       * LONG RIGHT
                move.l #$80018FF1, d0   
                move.l #$00000002, d6  
SHIFTS_LOOP6:
                asr.l d6 , d0       
                jsr SHIFTS_FLAGS
                dbf d6 , SHIFTS_LOOP6
                cmpi.l #$F00031FE , d0     
                bne *                 
                cmpi.l #$0000004E, d5     
                bne *      

            
    * Shift a Register LEFT and RIGHT with shift_count ## IN THE OPCODE ##
    
                move.l #$80018FF1, d0   
                move.l #$00000000, d5   

       * BYTE LEFT
                asl.b #1 , d0       
                jsr SHIFTS_FLAGS
                asl.b #2 , d0      
                jsr SHIFTS_FLAGS
                asl.b #1 , d0   
                jsr SHIFTS_FLAGS
                asl.b #3 , d0   
                jsr SHIFTS_FLAGS
                cmpi.l #$80018F80 , d0     
                bne *                 
                cmpi.l #$0000001F, d5     
                bne *                 
     
       * BYTE RIGHT
                asr.b #1 , d0       
                jsr SHIFTS_FLAGS
                asr.b #2 , d0      
                jsr SHIFTS_FLAGS
                asr.b #3 , d0   
                jsr SHIFTS_FLAGS
                asr.b #1 , d0   
                jsr SHIFTS_FLAGS
                cmpi.l #$80018FFF , d0     
                bne *                 
                cmpi.l #$0000003F, d5     
                bne *                 
     
       * WORD LEFT
                asl.w #1 , d0       
                jsr SHIFTS_FLAGS
                asl.w #2 , d0      
                jsr SHIFTS_FLAGS
                asl.w #3 , d0   
                jsr SHIFTS_FLAGS
                asl.w #5 , d0   
                jsr SHIFTS_FLAGS
                cmpi.l #$8001F800 , d0     
                bne *                 
                cmpi.l #$00000056, d5     
                bne *                 
                  
       * WORD RIGHT
                asr.w #5 , d0       
                jsr SHIFTS_FLAGS
                asr.w #1 , d0      
                jsr SHIFTS_FLAGS
                asr.w #2 , d0   
                jsr SHIFTS_FLAGS
                asr.w #4 , d0   
                jsr SHIFTS_FLAGS
                cmpi.l #$8001FFFF , d0     
                bne *                 
                cmpi.l #$00000077, d5     
                bne *                 
               
       * LONG LEFT
                move.l #$80018FF1, d0   
                asl.l #1 , d0       
                jsr SHIFTS_FLAGS
                asl.l #2 , d0      
                jsr SHIFTS_FLAGS
                asl.l #7 , d0   
                jsr SHIFTS_FLAGS
                asl.l #4 , d0   
                jsr SHIFTS_FLAGS
                cmpi.l #$63FC4000  , d0     
                bne *                 
                cmpi.l #$0000007A, d5     
                bne *                 
                                
       * LONG RIGHT
                move.l #$80018FF1, d0   
                asr.l #1 , d0       
                jsr SHIFTS_FLAGS
                asr.l #5 , d0      
                jsr SHIFTS_FLAGS
                asr.l #7 , d0   
                jsr SHIFTS_FLAGS
                asr.l #8 , d0   
                jsr SHIFTS_FLAGS
                cmpi.l #$FFFFFC00 , d0     
                bne *                 
                cmpi.l #$0000009C, d5     
                bne *                 
   
            
    * Shift a Memory location LEFT and RIGHT with shift_count of 1 - WORD only
    
                move.l #$00000000, d5   
                move.l #$00000100, a0 
                move.w #$8FF1 , (a0)
                
       * WORD LEFT
                asl  (a0)       
                jsr SHIFTS_FLAGS
                asl  (a0)       
                jsr SHIFTS_FLAGS
                asl  (a0)       
                jsr SHIFTS_FLAGS
                asl  (a0)       
                jsr SHIFTS_FLAGS
                move.w (a0) , d0
                cmpi.l #$FFFFFF10 , d0     
                bne *                 
                cmpi.l #$0000000D, d5     
                bne *                 
                  
       * WORD RIGHT
                asr (a0)       
                jsr SHIFTS_FLAGS
                asr (a0)       
                jsr SHIFTS_FLAGS
                asr (a0)       
                jsr SHIFTS_FLAGS                
                asr (a0)       
                jsr SHIFTS_FLAGS               
                asr (a0)       
                jsr SHIFTS_FLAGS
                asr (a0)       
                jsr SHIFTS_FLAGS
                move.w (a0) , d0
                cmpi.l #$FFFFFFFC , d0     
                bne *                 
                cmpi.l #$0000003E, d5     
                bne *                 

                rts      
        

                
*-----------------------------------------------------------
*-----------------------------------------------------------
* OPCODE : SHIFTS2
*-----------------------------------------------------------
*-----------------------------------------------------------

    * Subroutine to check and accumulate the flags 
SHIFTS2_FLAGS:  move SR , d3      
                andi.l #$0F , d3            * Isolate flags 
                add.l d3 , d5               * Copy flag results into accumulator
                rts
    
op_SHIFTS2:   
           
    * Shift a Register LEFT and RIGHT with shift_count ## IN A REGISTER ##
    
       * BYTE LEFT
                move.l #$80018F81, d0   
                move.l #$00000000, d5  
                move.l #$00000002, d6  
SHIFTS2_LOOP1:
                lsl.b d6 , d0       
                jsr SHIFTS2_FLAGS
                dbf d6 , SHIFTS2_LOOP1
                cmpi.l #$80018F08 , d0     
                bne *                 
                cmpi.l #$00000000, d5     
                bne *      
    
       * BYTE RIGHT
                move.l #$80018F81, d0   
                move.l #$00000002, d6  
SHIFTS2_LOOP2:
                lsr.b d6 , d0       
                jsr SHIFTS2_FLAGS
                dbf d6 , SHIFTS2_LOOP2
                cmpi.l #$80018F10 , d0     
                bne *                 
                cmpi.l #$00000000, d5     
                bne *      

    
       * WORD LEFT
                move.l #$80018FF1, d0   
                move.l #$00000002, d6  
SHIFTS2_LOOP3:
                lsl.w d6 , d0       
                jsr SHIFTS2_FLAGS
                dbf d6 , SHIFTS2_LOOP3
                cmpi.l #$80017F88 , d0     
                bne *                 
                cmpi.l #$00000000, d5     
                bne *      
    
       * WORD RIGHT
                move.l #$80018FF1, d0   
                move.l #$00000002, d6  
SHIFTS2_LOOP4:
                lsr.w d6 , d0       
                jsr SHIFTS2_FLAGS
                dbf d6 , SHIFTS2_LOOP4
                cmpi.l #$800111FE , d0     
                bne *                 
                cmpi.l #$00000000, d5     
                bne *      

    
       * LONG LEFT
                move.l #$80018FF1, d0   
                move.l #$00000002, d6  
SHIFTS2_LOOP5:
                lsl.l d6 , d0       
                jsr SHIFTS2_FLAGS
                dbf d6 , SHIFTS2_LOOP5
                cmpi.l #$000C7F88 , d0     
                bne *                 
                cmpi.l #$00000000, d5     
                bne *      
    
       * LONG RIGHT
                move.l #$80018FF1, d0   
                move.l #$00000002, d6  
SHIFTS2_LOOP6:
                lsr.l d6 , d0       
                jsr SHIFTS2_FLAGS
                dbf d6 , SHIFTS2_LOOP6
                cmpi.l #$100031FE , d0     
                bne *                 
                cmpi.l #$00000000, d5     
                bne *      

            
    * Shift a Register LEFT and RIGHT with shift_count ## IN THE OPCODE ##
    
                move.l #$80018FF1, d0   
                move.l #$00000000, d5   

       * BYTE LEFT
                lsl.b #1 , d0       
                jsr SHIFTS2_FLAGS
                lsl.b #2 , d0      
                jsr SHIFTS2_FLAGS
                lsl.b #1 , d0   
                jsr SHIFTS2_FLAGS
                lsl.b #3 , d0   
                jsr SHIFTS2_FLAGS
                cmpi.l #$80018F80 , d0     
                bne *                 
                cmpi.l #$0000001B, d5     
                bne *                 
     
       * BYTE RIGHT
                lsr.b #1 , d0       
                jsr SHIFTS2_FLAGS
                lsr.b #2 , d0      
                jsr SHIFTS2_FLAGS
                lsr.b #3 , d0   
                jsr SHIFTS2_FLAGS
                lsr.b #1 , d0   
                jsr SHIFTS2_FLAGS
                cmpi.l #$80018F01 , d0     
                bne *                 
                cmpi.l #$0000001B, d5     
                bne *                 
     
       * WORD LEFT
                lsl.w #1 , d0       
                jsr SHIFTS2_FLAGS
                lsl.w #2 , d0      
                jsr SHIFTS2_FLAGS
                lsl.w #3 , d0   
                jsr SHIFTS2_FLAGS
                lsl.w #5 , d0   
                jsr SHIFTS2_FLAGS
                cmpi.l #$80010800 , d0     
                bne *                 
                cmpi.l #$00000025, d5     
                bne *                 
                  
       * WORD RIGHT
                lsr.w #5 , d0       
                jsr SHIFTS2_FLAGS
                lsr.w #1 , d0      
                jsr SHIFTS2_FLAGS
                lsr.w #2 , d0   
                jsr SHIFTS2_FLAGS
                lsr.w #4 , d0   
                jsr SHIFTS2_FLAGS
                cmpi.l #$80010000 , d0     
                bne *                 
                cmpi.l #$0000002A, d5     
                bne *                 
               
       * LONG LEFT
                move.l #$80018FF1, d0   
                lsl.l #1 , d0       
                jsr SHIFTS2_FLAGS
                lsl.l #2 , d0      
                jsr SHIFTS2_FLAGS
                lsl.l #7 , d0   
                jsr SHIFTS2_FLAGS
                lsl.l #4 , d0   
                jsr SHIFTS2_FLAGS
                cmpi.l #$63FC4000  , d0     
                bne *                 
                cmpi.l #$0000002B, d5     
                bne *                 
                                
       * LONG RIGHT
                move.l #$80018FF1, d0   
                lsr.l #1 , d0       
                jsr SHIFTS2_FLAGS
                lsr.l #5 , d0      
                jsr SHIFTS2_FLAGS
                lsr.l #7 , d0   
                jsr SHIFTS2_FLAGS
                lsr.l #8 , d0   
                jsr SHIFTS2_FLAGS
                cmpi.l #$00000400 , d0     
                bne *                 
                cmpi.l #$0000002D, d5     
                bne *                 
   
            
    * Shift a Memory location LEFT and RIGHT with shift_count of 1 - WORD only
    
                move.l #$00000000, d5   
                move.l #$00000100, a0 
                move.w #$8FF1 , (a0)
                
       * WORD LEFT
                lsl  (a0)       
                jsr SHIFTS2_FLAGS
                lsl  (a0)       
                jsr SHIFTS2_FLAGS
                lsl  (a0)       
                jsr SHIFTS2_FLAGS
                lsl  (a0)       
                jsr SHIFTS2_FLAGS
                move.w (a0) , d0
                cmpi.l #$0000FF10 , d0     
                bne *                 
                cmpi.l #$00000009, d5     
                bne *                 
                  
       * WORD RIGHT
                lsr (a0)       
                jsr SHIFTS2_FLAGS
                lsr (a0)       
                jsr SHIFTS2_FLAGS
                lsr (a0)       
                jsr SHIFTS2_FLAGS                
                lsr (a0)       
                jsr SHIFTS2_FLAGS               
                lsr (a0)       
                jsr SHIFTS2_FLAGS
                lsr (a0)       
                jsr SHIFTS2_FLAGS
                move.w (a0) , d0
                cmpi.l #$000003FC , d0     
                bne *                 
                cmpi.l #$0000000A, d5     
                bne *                 

                rts      
        

*------------------------------------------------------   
*------------------------------------------------------   
  SIMHALT            

  END     START       
  


















*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~

//
//
// File Name : riscv.c
// Used on :
// Author : Ted Fried, MicroCore Labs
// Creation : 3/29/2020
// Code Type : C Source
//
// Description:
// ============
//  
// Simple and compact RISC-V RS32I implementation written in C.
//
//------------------------------------------------------------------------
//
// Modification History:
// =====================
//
// Revision 1 3/29/2020
// Initial revision
//
// Revision 2 4/3/2020
// Fixed BLTU
//
//
//------------------------------------------------------------------------
//
// Copyright (c) 2020 Ted Fried
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//
//------------------------------------------------------------------------

#include <stdio.h>

#define U_immediate rv5_opcode >> 12
#define J_immediate_SE (rv5_opcode&0x80000000) ? 0xFFE00000 | (rv5_opcode&0x000FF000) | (rv5_opcode&0x00100000)>>9 | (rv5_opcode&0x80000000)>>11 | (rv5_opcode&0x7FE00000)>>20 : (rv5_opcode&0x000FF000) | (rv5_opcode&0x00100000)>>9 | (rv5_opcode&0x80000000)>>11 | (rv5_opcode&0x7FE00000)>>20  
#define B_immediate_SE (rv5_opcode&0x80000000) ? 0xFFFFE000 | (rv5_opcode&0xF00)>>7 | (rv5_opcode&0x7E000000)>>20 | (rv5_opcode&0x80)<<4 | (rv5_opcode&0x80000000)>> 19 : (rv5_opcode&0xF00)>>7 | (rv5_opcode&0x7E000000)>>20 | (rv5_opcode&0x80)<<4 | (rv5_opcode&0x80000000)>> 19
#define I_immediate_SE (rv5_opcode&0x80000000) ? 0xFFFFF000 | rv5_opcode >> 20 : rv5_opcode >> 20
#define S_immediate_SE (rv5_opcode&0x80000000) ? 0xFFFFF000 | (rv5_opcode&0xFE000000)>>20 | (rv5_opcode&0xF80)>>7 : (rv5_opcode&0xFE000000)>>20 | (rv5_opcode&0xF80)>>7

#define funct7 ((unsigned char) ((rv5_opcode&0xFE000000) >> 25) )
#define rs2 ((unsigned char) ((rv5_opcode&0x01F00000) >> 20) )
#define rs1 ((unsigned char) ((rv5_opcode&0x000F8000) >> 15) )
#define funct3 ((unsigned char) ((rv5_opcode&0x00007000) >> 12) )
#define rd ((unsigned char) ((rv5_opcode&0x00000F80) >> 7 ) )
#define opcode ((rv5_opcode&0x0000007F) )


unsigned int shamt;
unsigned long rv5_reg[32];
unsigned long rv5_instruction_RAM[4096];
unsigned long rv5_user_memory[4096] ;
unsigned long rv5_opcode;
unsigned long rv5_pc=0;
unsigned long temp;


int main()

{
  while (1)
  {

  rv5_opcode = rv5_instruction_RAM[rv5_pc>>2]; 
  shamt=rs2;
   
  printf("PC:0x%x Opcode:0x%x ", rv5_pc, rv5_opcode);
   
  if (opcode==0b0110111) { rv5_reg[rd] = U_immediate << 12; printf(" LUI "); } else // LUI
  if (opcode==0b0010111) { rv5_reg[rd] = (U_immediate << 12) + rv5_pc; printf(" AUIPC "); } else // AUIPC
  if (opcode==0b1101111) { rv5_reg[rd] = rv5_pc + 0x4; rv5_pc = (J_immediate_SE) + rv5_pc - 0x4; printf(" JAL "); } else // JAL
  if (opcode==0b1100111) { rv5_reg[rd] = rv5_pc + 0x4; rv5_pc = (((I_immediate_SE) + rv5_reg[rs1]) & 0xFFFFFFFE) - 0x4; printf(" JALR "); } else // JALR
  if (opcode==0b1100011 && funct3==0b000) { if (rv5_reg[rs1]==rv5_reg[rs2]) rv5_pc = ( (B_immediate_SE) + rv5_pc) - 0x4; printf(" BEQ "); } else // BEQ
  if (opcode==0b1100011 && funct3==0b001) { if (rv5_reg[rs1]!=rv5_reg[rs2]) rv5_pc = ( (B_immediate_SE) + rv5_pc) - 0x4; printf(" BNE "); } else // BNE
  if (opcode==0b1100011 && funct3==0b100) { if ((signed long)rv5_reg[rs1]< (signed long)rv5_reg[rs2]) rv5_pc = ((B_immediate_SE) + rv5_pc) - 0x4; printf(" BLT "); } else // BLT
  if (opcode==0b1100011 && funct3==0b101) { if ((signed long)rv5_reg[rs1]>=(signed long)rv5_reg[rs2]) rv5_pc = ((B_immediate_SE) + rv5_pc) - 0x4; printf(" BGE "); } else // BGE
  if (opcode==0b1100011 && funct3==0b110) { if (rv5_reg[rs1]<rv5_reg[rs2]) rv5_pc = ( (B_immediate_SE) + rv5_pc) - 0x4; printf(" BLTU ");  } else // BLTU
  if (opcode==0b1100011 && funct3==0b111) { if (rv5_reg[rs1]>=rv5_reg[rs2]) rv5_pc = ( (B_immediate_SE) + rv5_pc) - 0x4; printf(" BGTU "); } else // BGTU
  if (opcode==0b0000011 && funct3==0b000) { rv5_reg[rd] = (rv5_user_memory[(I_immediate_SE)+rv5_reg[rs1]] & 0x80) ? 0xFFFFFF00| rv5_user_memory[(I_immediate_SE)+rv5_reg[rs1]] : (rv5_user_memory[(I_immediate_SE)+rv5_reg[rs1]] & 0xFF); printf(" LB "); } else // LB
  if (opcode==0b0000011 && funct3==0b001) { rv5_reg[rd] = (rv5_user_memory[(I_immediate_SE)+rv5_reg[rs1]] & 0x8000) ? 0xFFFF0000| rv5_user_memory[(I_immediate_SE)+rv5_reg[rs1]] : (rv5_user_memory[(I_immediate_SE)+rv5_reg[rs1]] & 0xFFFF); printf(" LH "); } else // LH
  if (opcode==0b0000011 && funct3==0b010) { rv5_reg[rd] = rv5_user_memory[(I_immediate_SE)+rv5_reg[rs1]]; printf(" LW "); } else // LW
  if (opcode==0b0000011 && funct3==0b100) { rv5_reg[rd] = rv5_user_memory[(I_immediate_SE)+rv5_reg[rs1]] & 0x000000FF; printf(" LBU "); } else // LBU
  if (opcode==0b0000011 && funct3==0b101) { rv5_reg[rd] = rv5_user_memory[(I_immediate_SE)+rv5_reg[rs1]] & 0x0000FFFF; printf(" LHU "); } else // LHU
  if (opcode==0b0100011 && funct3==0b000) { rv5_user_memory[(S_immediate_SE)+rv5_reg[rs1]] = (rv5_user_memory[(S_immediate_SE)+rv5_reg[rs1]]&0xFFFFFF00) | (rv5_reg[rs2]&0xFF); printf(" SB "); } else // SB
  if (opcode==0b0100011 && funct3==0b001) { rv5_user_memory[(S_immediate_SE)+rv5_reg[rs1]] = (rv5_user_memory[(S_immediate_SE)+rv5_reg[rs1]]&0xFFFF0000) | (rv5_reg[rs2]&0xFFFF); printf(" SH "); } else // SH
  if (opcode==0b0100011 && funct3==0b010) { rv5_user_memory[(S_immediate_SE)+rv5_reg[rs1]] = rv5_reg[rs2]; printf(" SW "); } else // SW
  if (opcode==0b0010011 && funct3==0b000) { rv5_reg[rd] = (I_immediate_SE) + rv5_reg[rs1]; printf(" ADDI "); } else // ADDI
  if (opcode==0b0010011 && funct3==0b010) { if ((signed long)rv5_reg[rs1] < ((signed long)I_immediate_SE)) rv5_reg[rd]=1; else rv5_reg[rd]=0; printf(" SLTI "); } else // SLTI
  if (opcode==0b0010011 && funct3==0b011) { if (rv5_reg[rs1] < (I_immediate_SE)) rv5_reg[rd]=1; else rv5_reg[rd]=0; printf(" SLTIU "); } else // SLTIU
  if (opcode==0b0010011 && funct3==0b100) { rv5_reg[rd] = rv5_reg[rs1] ^ (I_immediate_SE); printf(" XORI "); } else // XORI
  if (opcode==0b0010011 && funct3==0b110) { rv5_reg[rd] = rv5_reg[rs1] | (I_immediate_SE); printf(" ORI "); } else // ORI
  if (opcode==0b0010011 && funct3==0b111) { rv5_reg[rd] = rv5_reg[rs1] & (I_immediate_SE); printf(" ANDI "); } else // ANDI
  if (opcode==0b0010011 && funct3==0b001 && funct7==0b0000000) { rv5_reg[rd] = rv5_reg[rs1] << shamt; printf(" SLLI "); } else // SLLI
  if (opcode==0b0010011 && funct3==0b101 && funct7==0b0100000) {rv5_reg[rd]=rv5_reg[rs1]; temp=rv5_reg[rs1]&0x80000000; while (shamt>0) { rv5_reg[rd]=(rv5_reg[rd]>>1)|temp; shamt--;} printf(" SRAI "); } else // SRAI
  if (opcode==0b0010011 && funct3==0b101 && funct7==0b0000000) { rv5_reg[rd] = rv5_reg[rs1] >> shamt; printf(" SRLI "); } else // SRLI
  if (opcode==0b0110011 && funct3==0b000 && funct7==0b0100000) { rv5_reg[rd] = rv5_reg[rs1] - rv5_reg[rs2]; printf(" SUB "); } else // SUB
  if (opcode==0b0110011 && funct3==0b000) { rv5_reg[rd] = rv5_reg[rs1] + rv5_reg[rs2]; printf(" ADD "); } else // ADD
  if (opcode==0b0110011 && funct3==0b001) { rv5_reg[rd] = rv5_reg[rs1] << (rv5_reg[rs2]&0x1F); printf(" SLL "); } else // SLL
  if (opcode==0b0110011 && funct3==0b010) { if ((signed long)rv5_reg[rs1] < (signed long)rv5_reg[rs2]) rv5_reg[rd]=1; else rv5_reg[rd]=0; printf(" SLT "); } else // SLT
  if (opcode==0b0110011 && funct3==0b011) { if (rv5_reg[rs1] < rv5_reg[rs2]) rv5_reg[rd]=1; else rv5_reg[rd]=0; printf(" SLTU "); } else // SLTU
  if (opcode==0b0110011 && funct3==0b100) { rv5_reg[rd] = rv5_reg[rs1] ^ rv5_reg[rs2]; printf(" XOR "); } else // XOR
  if (opcode==0b0110011 && funct3==0b101 && funct7==0b0100000) {rv5_reg[rd]=rv5_reg[rs1]; shamt=(rv5_reg[rs2]&0x1F); temp=rv5_reg[rs1]&0x80000000; while (shamt>0) { rv5_reg[rd]=(rv5_reg[rd]>>1)|temp; shamt--;} printf(" SRA "); } else // SRA
  if (opcode==0b0110011 && funct3==0b101 && funct7==0b0000000) { rv5_reg[rd] = rv5_reg[rs1] >> (rv5_reg[rs2]&0x1F); printf(" SRL "); } else // SRL
  if (opcode==0b0110011 && funct3==0b110) { rv5_reg[rd] = rv5_reg[rs1] | rv5_reg[rs2]; printf(" OR "); } else // OR
  if (opcode==0b0110011 && funct3==0b111) { rv5_reg[rd] = rv5_reg[rs1] & rv5_reg[rs2]; printf(" AND "); } else printf(" **INVALID** "); // AND
 
  rv5_pc = rv5_pc + 0x4;
  rv5_reg[0]=0;
   
  printf("rd:%d rs1:%d rs2:%d U_immediate:0x%x J_immediate:0x%x B_immediate:0x%x I_immediate:0x%x S_immediate:0x%x funct3:0x%x funct7:0x%x\n",rd,rs1,rs2,U_immediate,J_immediate_SE,B_immediate_SE,I_immediate_SE,S_immediate_SE,funct3,funct7);
  printf("Regs: "); for (int i=0; i<32; i++) { printf("r%d:%x ",i,rv5_reg[i]); } printf("\n"); //scanf("%c",&temp);
  printf("Memory: "); for (int i=0; i<7; i++) { printf("Addr%d:%x ",i,rv5_user_memory[i]); } printf("\n"); scanf("%c",&temp);
    
    }
  
}
//
//
//  File Name   :  MCL65.c
//  Used on     :  
//  Author      :  Ted Fried, MicroCore Labs
//  Creation    :  3/22/2020
//  Code Type   :  C code
//
//   Description:
//   ============
//   
//  C Code emulating the MCL65 Microsequencer of the MOS 6502 microprocessor
//  This is a C version of the MCL65 which is written in Verilog. It runs the 
//  exact same microcode. NMI and Interrupts are suppored.
//  Each loop of the code below is equivalent to one microsequencer clock
//  and will execute a new micro-instruction each time.
//  The user code and data RAM are held in a 64KB array.
//
//------------------------------------------------------------------------
//
// Modification History:
// =====================
//
// Revision 1 3/22/2020
// Initial revision
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
#include "mcl65.h"

#define rdwr_n           ( system_output & 0x1   ) >> 0      // system_output[0]
#define flag_i           ( register_flags & 0x04 ) >> 2      // register_flags[2]
#define opcode_type      ( rom_data & 0xF0000000 ) >> 28     // rom_data[30:28];
#define opcode_dst_sel   ( rom_data & 0x0F000000 ) >> 24     // rom_data[27:24];
#define opcode_op0_sel   ( rom_data & 0x00F00000 ) >> 20     // rom_data[23:20];
#define opcode_op1_sel   ( rom_data & 0x000F0000 ) >> 16     // rom_data[19:16];
#define opcode_immediate ( rom_data & 0x0000FFFF ) >> 00     // rom_data[15:0];
#define opcode_jump_call ( rom_data & 0x01000000 ) >> 24     // rom_data[24];
#define opcode_jump_src  ( rom_data & 0x00700000 ) >> 20     // rom_data[22:20];
#define opcode_jump_cond ( rom_data & 0x000F0000 ) >> 16     // rom_data[16:19];


unsigned char attached_memory[65536]={ };
unsigned char register_flags=0;
unsigned char add_carry7=0;
unsigned char add_carry8=0;
unsigned char nmi_asserted=0;
unsigned char irq_gated=0;
unsigned char add_overflow8=0;
unsigned char nmi_debounce=0;
unsigned char system_status=0;
unsigned char register_a=0;
unsigned char register_x=0;
unsigned char register_y=0;
unsigned short int register_r0=0;
unsigned short int register_r1=0;
unsigned short int register_r2=0;
unsigned short int register_r3=0;
unsigned short int register_pc=0x400;
unsigned short int register_sp=0;
unsigned short int address_out=0;
unsigned short int data_in=0;
unsigned short int data_out=0;
unsigned short int system_output=0;
unsigned short int alu_last_result=0;
unsigned short int alu_out=0;
unsigned short int rom_address=0x07D0; // Address for Microcode Reset procedure
unsigned short int operand0=0;
unsigned short int operand1=0;
unsigned long rom_data;
unsigned long calling_address;


// Main loop
//
int main() 
  {
    while (1)
      {
        // Optional INT and NMI Signals
        //  irq_gated = P6502_IRQ_n & ~flag_i;    
        //  if (nmi_debounce==1) nmi_asserted=0;  else if (P6502_NMI_n_old==1 && P6502_NMI_n==0)  nmi_asserted=1;   P6502_NMI_n_old = P6502_NMI_n;

        data_in = attached_memory[address_out];  // Read data from the Attached Memory RAM

        rom_data = microcode_rom[rom_address];   // Fetch the next microcode instruction 
  
        system_status =   (  add_carry8    << 0    |    // system_status[0]
                             nmi_asserted  << 3    |    // system_status[3]
                             irq_gated     << 5    |    // system_status[5]
                             add_overflow8 << 6    );   // system_status[6]


        switch (opcode_op0_sel)
        {
          case 0x0: operand0 = register_r0;                                break;
          case 0x1: operand0 = register_r1;                                break;
          case 0x2: operand0 = register_r2;                                break;
          case 0x3: operand0 = register_r3;                                break;
          case 0x4: operand0 = register_a & 0x00FF;                        break;
          case 0x5: operand0 = register_x & 0x00FF;                        break;
          case 0x6: operand0 = register_y & 0x00FF;                        break;
          case 0x7: operand0 = register_pc;                                break;
          case 0x8: operand0 = ((register_sp & 0x00FF) | 0x0100);          break;
          case 0x9: operand0 = register_flags & 0x00FF;                    break;
          case 0xA: operand0 = address_out;                                break;
          case 0xB: operand0 = ((data_in&0xFF) << 8)  | (data_in&0xFF);    break;
          case 0xC: operand0 = system_status;                              break;
          case 0xD: operand0 = system_output;                              break;
          case 0xE: operand0 = 0;                                          break;
          case 0xF: operand0 = 0;                                          break;
        }
       
        
        switch (opcode_op1_sel)
        {
          case 0x0: operand1 = register_r0;                                break;
          case 0x1: operand1 = register_r1;                                break;
          case 0x2: operand1 = register_r2;                                break;
          case 0x3: operand1 = register_r3;                                break;
          case 0x4: operand1 = register_a & 0x00FF;                        break;
          case 0x5: operand1 = register_x & 0x00FF;                        break;
          case 0x6: operand1 = register_y & 0x00FF;                        break;
          case 0x7: operand1 = ( (register_pc<<8) | (register_pc>>8) ) ;   break;
          case 0x8: operand1 = ((register_sp & 0x00FF) | 0x0100);          break;
          case 0x9: operand1 = register_flags & 0x00FF;                    break;
          case 0xA: operand1 = address_out;                                break;
          case 0xB: operand1 =( ( data_in << 8)  | data_in);               break;
          case 0xC: operand1 = system_status;                              break;
          case 0xD: operand1 = system_output;                              break;
          case 0xE: operand1 = 0;                                          break;
          case 0xF: operand1 = opcode_immediate;                           break;
        }
      
      
        switch (opcode_type)
        {
          case 0x2:  // ADD
                  alu_out = operand0 + operand1; 
                  add_carry7 = (( ((operand0&0x007F) + (operand1&0x007F)) & 0x0080) >> 7);
                  add_carry8 = (( ((operand0&0x00FF) + (operand1&0x00FF)) & 0x0100) >> 8);
                  add_overflow8 = (add_carry7 ^ add_carry8) & 0x1; 
                  break;    
          case 0x3: alu_out = operand0 & operand1;   break;    // AND
          case 0x4: alu_out = operand0 | operand1;   break;    // OR
          case 0x5: alu_out = operand0 ^ operand1;   break;    // XOR
          case 0x6: alu_out = operand0 >> 1;         break;    // SHR
          default:  alu_out = 0xEEEE;                break;   
        }
 

        // Register write-back   
        if (opcode_type > 1) 
          {       
            alu_last_result = alu_out;
            switch (opcode_dst_sel) 
              {
                case 0x0: register_r0    = alu_out;           break;
                case 0x1: register_r1    = alu_out;           break;
                case 0x2: register_r2    = alu_out;           break;
                case 0x3: register_r3    = alu_out;           break;
                case 0x4: register_a     = alu_out & 0x00FF;  break;
                case 0x5: register_x     = alu_out & 0x00FF;  break;
                case 0x6: register_y     = alu_out & 0x00FF;  break;
                case 0x7: register_pc    = alu_out;           break;
                case 0x8: register_sp    = alu_out & 0x00FF;  break;
                case 0x9: register_flags = alu_out | 0x30;    break;
                case 0xA: address_out    = alu_out;           break;
                case 0xB: data_out       = alu_out & 0x00FF;  break;
                case 0xD: system_output  = alu_out & 0x001F;  break;
               default: break;
              }
           }

         
           // JUMP Opcode
           if ( ( opcode_type==0x1 && opcode_jump_cond==0x0                       )   ||  // Unconditional jump
                ( opcode_type==0x1 && opcode_jump_cond==0x1 && alu_last_result!=0 )   ||  // Jump Not Zero
                ( opcode_type==0x1 && opcode_jump_cond==0x2 && alu_last_result==0 )    )   // Jump Zero
             {
               // For subroutine CALLs, store next opcode address
              if (opcode_jump_call==1)
                  calling_address = (calling_address<<11) | (rom_address&0x07FF) ;
         
              switch (opcode_jump_src)
                {
                  case 0x0: rom_address = opcode_immediate & 0x07FF;    break;  
                  case 0x1: rom_address = data_in & 0x00FF;             break;  // Opcode Jump Table
                  case 0x2: rom_address = (calling_address & 0x07FF) + 1;
                            calling_address = calling_address>>11;
                            break;
                }
             }        
           else
               rom_address = rom_address + 1; 
         
         
           // Writes to the 6502 Data RAM occur on the simulated rising edge of the clock 
           if (opcode_type==0x1 && opcode_jump_cond==0x3 && rdwr_n==0) attached_memory[address_out] = data_out;
      }
  }


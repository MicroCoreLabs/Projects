//
//
//  File Name   :  MCLR5_alu.v
//  Author      :  Ted Fried, MicroCore Labs
//  Creation    :  4/21/2018
//  Code Type   :  Synthesizable
//
//------------------------------------------------------------------------
//
//   Description:
//   ============
//   
//  Quad-issue Superscalar Risc V Processor ALU core
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

// Modification History:
// =====================
//
// Revision 1 4/21/18
// Initial revision
//
//
//------------------------------------------------------------------------


module MCLR5_alu
  (  
  
    input  [31:0]       OPCODE,
    input  [31:0]       PC,

    input  [31:0]       RS1,
    input  [31:0]       RS2,
    output reg [32:0]   RD,
    output reg [32:0]   NEWPC,
    input  [31:0]       LOAD_DATA,
    output [31:0]       STORE_DATA,
    output reg          LOAD_REQ,
    output reg          STORE_REQ,
    output reg [31:0]   LOAD_STORE_ADDRESS

  );

//------------------------------------------------------------------------
      

// Internal Signals

wire beq_taken;
wire bne_taken;
wire blt_taken;
wire bge_taken;
wire bltu_taken;
wire bgeu_taken;
wire slti_true;
wire sltiu_true;
wire slt_true;
wire sltu_true;
wire [31:0] i_immediate;
wire [31:0] s_immediate;
wire [31:0] b_immediate;
wire [31:0] u_immediate;
wire [31:0] j_immediate;
wire [31:0] slli_result;
wire [31:0] srli_result;
wire [31:0] srai_result;
wire [31:0] sll_result;
wire [31:0] srl_result;
wire [31:0] sra_result;
wire [31:0] pc_adjusted;



//------------------------------------------------------------------------
//
// RISC V ALU
//
//------------------------------------------------------------------------

assign i_immediate = { {21{OPCODE[31]}} , OPCODE[30:25] , OPCODE[24:21] , OPCODE[20] } ;
assign s_immediate = { {21{OPCODE[31]}} , OPCODE[30:25] , OPCODE[11:8] , OPCODE[7] } ;
assign b_immediate = { {20{OPCODE[31]}} , OPCODE[7] , OPCODE[30:25] , OPCODE[11:8] , 1'b0 } ;
assign u_immediate = { OPCODE[31] , OPCODE[30:20] , OPCODE[19:12] , 12'b0 } ;
assign j_immediate = { {12{OPCODE[31]}} , OPCODE[19:12] , OPCODE[20] , OPCODE[30:25] , OPCODE[24:21] , 1'b0 } ;


assign slti_true  = ($signed(RS1) < $signed(i_immediate))   ? 32'h0000_0001 : 32'h0000_0000;
assign sltiu_true = (RS1 < i_immediate)                     ? 32'h0000_0001 : 32'h0000_0000;
assign slt_true   = ($signed(RS1) < $signed(RS2))           ? 32'h0000_0001 : 32'h0000_0000;
assign sltu_true  = (RS1 < RS2)                             ? 32'h0000_0001 : 32'h0000_0000;


assign slli_result = 32'h0123_4567;
assign srli_result = 32'h0123_4567;
assign srai_result = 32'h0123_4567;
assign sll_result  = 32'h0123_4567;
assign srl_result  = 32'h0123_4567;
assign sra_result  = 32'h0123_4567;

assign beq_taken  = (RS1 == RS1)                    ? 1'b1 : 1'b0;
assign bne_taken  = (RS1 != RS1)                    ? 1'b1 : 1'b0;
assign blt_taken  = ($signed(RS1) < $signed(RS2))   ? 1'b1 : 1'b0;
assign bge_taken  = ($signed(RS1) >= $signed(RS2))  ? 1'b1 : 1'b0;
assign bltu_taken = (RS1 < RS2)                     ? 1'b1 : 1'b0;
assign bgeu_taken = (RS1 >= RS2)                    ? 1'b1 : 1'b0;

        
assign pc_adjusted = PC - 4'h4;  // Subtracts pipelined PC to the true PC
                                                                                    
assign STORE_DATA = RS2; 


always @* begin
  casex (OPCODE)

    32'b???????_?????_?????_???_?????_01101?? : RD = { 1'b1 , {u_immediate[31:12] , 12'b0 } }            ;   // LUI
    32'b???????_?????_?????_???_?????_00101?? : RD = { 1'b1 , PC + {u_immediate[31:12] , 12'b0 }  }      ;   // AUIPC
    32'b???????_?????_?????_???_?????_11011?? : RD = { 1'b1 , PC + 3'h4 }                                ;   // JAL
    32'b???????_?????_?????_???_?????_11001?? : RD = { 1'b1 , PC + 3'h4 }                                ;   // JALR
    32'b???????_?????_?????_000_?????_00100?? : RD = { 1'b1 , RS1 + i_immediate }                        ;   // ADDI
    32'b???????_?????_?????_010_?????_00100?? : RD = { 1'b1 , slti_true }                                ;   // SLTI
    32'b???????_?????_?????_011_?????_00100?? : RD = { 1'b1 , sltiu_true }                               ;   // SLTIU
    32'b???????_?????_?????_100_?????_00100?? : RD = { 1'b1 , RS1 ^ i_immediate }                        ;   // XORI
    32'b???????_?????_?????_110_?????_00100?? : RD = { 1'b1 , RS1 | i_immediate }                        ;   // ORI
    32'b???????_?????_?????_111_?????_00100?? : RD = { 1'b1 , RS1 & i_immediate }                        ;   // ANDI
    32'b???????_?????_?????_001_?????_00100?? : RD = { 1'b1 , slli_result }                              ;   // SLLI
    32'b?0?????_?????_?????_101_?????_00100?? : RD = { 1'b1 , srli_result }                              ;   // SRLI
    32'b?1?????_?????_?????_101_?????_00100?? : RD = { 1'b1 , srai_result }                              ;   // SRAI
    32'b?0?????_?????_?????_000_?????_01100?? : RD = { 1'b1 , RS1 + RS2 }                                ;   // ADD
    32'b?1?????_?????_?????_000_?????_01100?? : RD = { 1'b1 , RS1 - RS2 }                                ;   // SUB
    32'b???????_?????_?????_001_?????_01100?? : RD = { 1'b1 , sll_result }                               ;   // SLL
    32'b???????_?????_?????_010_?????_01100?? : RD = { 1'b1 , slt_true }                                 ;   // SLT
    32'b???????_?????_?????_011_?????_01100?? : RD = { 1'b1 , sltu_true }                                ;   // SLTU
    32'b???????_?????_?????_100_?????_01100?? : RD = { 1'b1 , RS1 ^ RS2 }                                ;   // XOR
    32'b?0?????_?????_?????_101_?????_01100?? : RD = { 1'b1 , srl_result }                               ;   // SRL
    32'b?1?????_?????_?????_101_?????_01100?? : RD = { 1'b1 , sra_result }                               ;   // SRA
    32'b???????_?????_?????_110_?????_01100?? : RD = { 1'b1 , RS1 | RS2 }                                ;   // OR
    32'b???????_?????_?????_111_?????_01100?? : RD = { 1'b1 , RS1 & RS2 }                                ;   // AND
        
    32'b???????_?????_?????_010_?????_00000?? : RD = { 1'b1 , LOAD_DATA }                                ;   // LW
    default :                                   RD = { 1'b0 , 32'h0000_0000 }                            ;      
    
  endcase
  
 
  casex (OPCODE)

    32'b???????_?????_?????_010_?????_00000?? : LOAD_STORE_ADDRESS = RS1 + i_immediate ; // Loads   
    32'b???????_?????_?????_010_?????_01000?? : LOAD_STORE_ADDRESS = RS1 + s_immediate ; // Stores      
    default : ;
  endcase
      
 
  casex (OPCODE)

    32'b???????_?????_?????_010_?????_00000?? : LOAD_REQ = 1'b1 ;
    32'b???????_?????_?????_010_?????_01000?? : STORE_REQ = 1'b1 ;      
    default :   begin LOAD_REQ = 1'b0 ; STORE_REQ = 1'b0;  end                             
    
  endcase
  
         
  casex (OPCODE)

    32'b???????_?????_?????_???_?????_11011?? : NEWPC = { 1'b1 ,  pc_adjusted + j_immediate                     }  ;   // JAL
    32'b???????_?????_?????_000_?????_11001?? : NEWPC = { 1'b1 , ( RS1 + i_immediate) & 32'hFFFF_FFFE           }  ;   // JALR
                                                                                                                
    32'b???????_?????_?????_010_?????_00000?? : NEWPC = { 1'b1 ,  pc_adjusted                                   }  ;   // LW
    32'b???????_?????_?????_010_?????_01000?? : NEWPC = { 1'b1 ,  pc_adjusted                                   }  ;   // SW

    //32'hBBBBBBBB : NEWPC = { 1'b1 ,  pc_adjusted + 4'h6                                   }  ;   // Temp jump code !!!!
    
    32'b???????_?????_?????_000_?????_11000?? : if (beq_taken ==  1'b1) NEWPC = { 1'b1 ,  pc_adjusted + b_immediate      }  ;   // BEQ
    32'b???????_?????_?????_001_?????_11000?? : if (bne_taken ==  1'b1) NEWPC = { 1'b1 ,  pc_adjusted + b_immediate      }  ;   // BNE
    32'b???????_?????_?????_100_?????_11000?? : if (blt_taken ==  1'b1) NEWPC = { 1'b1 ,  pc_adjusted + b_immediate      }  ;   // BLT
    32'b???????_?????_?????_101_?????_11000?? : if (bge_taken ==  1'b1) NEWPC = { 1'b1 ,  pc_adjusted + b_immediate      }  ;   // BGE
    32'b???????_?????_?????_110_?????_11000?? : if (bltu_taken == 1'b1) NEWPC = { 1'b1 ,  pc_adjusted + b_immediate      }  ;   // BLTU
    32'b???????_?????_?????_111_?????_11000?? : if (bgeu_taken == 1'b1) NEWPC = { 1'b1 ,  pc_adjusted + b_immediate      }  ;   // BGEU

    
    default :                                   NEWPC = { 1'b0 ,  32'h0000_0000                                 }  ;   // No Branch Taken   
    
  endcase
  
   
  
  
end


    


 
endmodule // MCLR5_alu.v

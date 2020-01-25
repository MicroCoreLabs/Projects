//
//
//  File Name   :  eu.v
//  Used on     :  MCL51
//  Author      :  Ted Fried, MicroCore Labs
//  Creation    :  3/13/2016
//  Code Type   :  Synthesizable
//
//   Description:
//   ============
//   
//  Execution Unit of the MCL51 processor - Microsequencer
//
//------------------------------------------------------------------------
//
// Modification History:
// =====================
//
// Revision 1.0 3/13/16
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


module eu
  (  
    input               CORE_CLK,               // Core Clock
    input               RST_n,
    
    
    output [7:0]        EU_BIU_STROBE,          // EU to BIU Signals
    output [7:0]        EU_BIU_DATAOUT,         
    output [15:0]       EU_REGISTER_R3, 
    output [15:0]       EU_REGISTER_IP, 
    
    
    input [7:0]         BIU_SFR_ACC,            // BIU to EU Signals
    input [15:0]        BIU_SFR_DPTR,
    input [7:0]         BIU_SFR_SP,
    input [7:0]         BIU_SFR_PSW,
    input [7:0]         BIU_RETURN_DATA,
    input               BIU_INTERRUPT

  );

//------------------------------------------------------------------------
      

// Internal Signals

reg  eu_add_carry;
reg  eu_add_carry16;
reg  eu_add_aux_carry;
reg  eu_add_overflow;
reg  eu_stall_pipeline;
wire eu_opcode_jump_call;
wire eu_jump_gate;
reg  [9:0]  eu_rom_address;
reg  [19:0] eu_calling_address;
reg  [15:0] eu_register_r0;
reg  [15:0] eu_register_r1;
reg  [15:0] eu_register_r2;
reg  [15:0] eu_register_r3;
reg  [15:0] eu_register_ip;
reg  [7:0]  eu_biu_strobe;
reg  [7:0] eu_biu_dataout;
reg  [15:0] eu_alu_last_result;
wire [15:0] adder_out;
wire [16:0] carry;
wire [2:0]  eu_opcode_type;
wire [2:0]  eu_opcode_dst_sel;
wire [3:0]  eu_opcode_op0_sel;
wire [2:0]  eu_opcode_op1_sel;
wire [15:0] eu_opcode_immediate;
wire [2:0]  eu_opcode_jump_src;
wire [2:0]  eu_opcode_jump_cond;
wire [15:0] eu_alu2;
wire [15:0] eu_alu3;
wire [15:0] eu_alu4;
wire [15:0] eu_alu5;
wire [15:0] eu_alu6;
wire [15:0] eu_alu7;
wire [15:0] eu_alu_out;
wire [15:0] eu_operand0;
wire [15:0] eu_operand1;
wire [31:0] eu_rom_data;
wire [15:0] eu_flags_r;




//------------------------------------------------------------------------
//
// EU Microcode ROM.  1Kx32
//
//------------------------------------------------------------------------                                    

/*
// For Lattice XO2 FPGAs
eu_rom              EU_1Kx32 
  (
    .Reset          (1'b0),   
    .OutClockEn     (1'b1), 
    .OutClock       (CORE_CLK),
    .Address        (eu_rom_address[9:0]),
    .Q              (eu_rom_data)  
  );
*/

// For Xilinx Artix FPGAs 
eu_rom          EU_1Kx32
  (
    .clka       (CORE_CLK),
    .addra      (eu_rom_address[9:0]),
    .douta      (eu_rom_data)
  );

    
 
 
 
   
//------------------------------------------------------------------------
//
// Combinationals
//
//------------------------------------------------------------------------

assign EU_BIU_STROBE        = eu_biu_strobe;
assign EU_BIU_DATAOUT       = eu_biu_dataout;
assign EU_REGISTER_R3       = eu_register_r3;
assign EU_REGISTER_IP       = eu_register_ip;


// EU ROM opcode decoder
assign eu_opcode_type       = eu_rom_data[30:28];
assign eu_opcode_dst_sel    = eu_rom_data[26:24];
assign eu_opcode_op0_sel    = eu_rom_data[23:20];
assign eu_opcode_op1_sel    = eu_rom_data[18:16];
assign eu_opcode_immediate  = eu_rom_data[15:0];

assign eu_opcode_jump_call  = eu_rom_data[24];
assign eu_opcode_jump_src   = eu_rom_data[22:20];
assign eu_opcode_jump_cond  = eu_rom_data[18:16];



assign  eu_operand0 = (eu_opcode_op0_sel==4'h0) ? eu_register_r0                :
                      (eu_opcode_op0_sel==4'h1) ? eu_register_r1                :
                      (eu_opcode_op0_sel==4'h2) ? eu_register_r2                :
                      (eu_opcode_op0_sel==4'h3) ? eu_register_r3                :
                      (eu_opcode_op0_sel==4'h4) ? { 8'h00 , BIU_RETURN_DATA }   :
                      (eu_opcode_op0_sel==4'h5) ? { eu_flags_r[15:0] }          :
                      (eu_opcode_op0_sel==4'h6) ? { 8'h00      , BIU_SFR_ACC }  :
                      (eu_opcode_op0_sel==4'h7) ? eu_register_ip                :
                                                  16'h0000                      ;

assign  eu_operand1 = (eu_opcode_op1_sel==3'h0) ? eu_register_r0                :
                      (eu_opcode_op1_sel==3'h1) ? eu_register_r1                :
                      (eu_opcode_op1_sel==3'h2) ? eu_register_r2                :
                      (eu_opcode_op1_sel==3'h3) ? eu_register_r3                :
                      (eu_opcode_op1_sel==3'h4) ? { 8'h00  , BIU_SFR_SP }       :
                      //(eu_opcode_op1_sel==3'h5) ? eu_alu_last_result              :
                      (eu_opcode_op1_sel==3'h6) ? BIU_SFR_DPTR                  :
                                                  eu_opcode_immediate           ;

    
// JUMP condition codes
assign eu_jump_gate =    (eu_opcode_jump_cond==4'h0)                               ? 1'b1 : // unconditional jump
                         (eu_opcode_jump_cond==4'h1 && eu_alu_last_result!=16'h0)  ? 1'b1 : 
                         (eu_opcode_jump_cond==4'h2 && eu_alu_last_result==16'h0)  ? 1'b1 : 
                                                                                     1'b0 ;


            
// ** Flags must be written to the PSW through the BIU 
    
assign eu_flags_r[15]       =  eu_add_carry;
assign eu_flags_r[14]       =  eu_add_aux_carry;
assign eu_flags_r[13]       =  eu_add_carry16;
//assign eu_flags_r[12]     = 
//assign eu_flags_r[11]     =  
assign eu_flags_r[10]       =  eu_add_overflow;
//assign eu_flags_r[9]      =  
assign eu_flags_r[8]        =  BIU_INTERRUPT;

assign eu_flags_r[7]        =  BIU_SFR_PSW[7];   // C
assign eu_flags_r[6]        =  BIU_SFR_PSW[6];   // AC
assign eu_flags_r[5]        =  BIU_SFR_PSW[5];   // F0
assign eu_flags_r[4]        =  BIU_SFR_PSW[4];   // RS1
assign eu_flags_r[3]        =  BIU_SFR_PSW[3];   // RS0
assign eu_flags_r[2]        =  BIU_SFR_PSW[2];   // Overflow
assign eu_flags_r[1]        =  BIU_SFR_PSW[1];   // User Defined Flag
assign eu_flags_r[0]        =  BIU_SFR_PSW[0];   // ACC Parity generated in the BIU




// EU ALU Operations
// ------------------------------------------
//     eu_alu0 = NOP
//     eu_alu1 = JUMP
assign eu_alu2 = adder_out;                                     // ADD
assign eu_alu3 = eu_operand0 ^ eu_operand1;                     // XOR
assign eu_alu4 = eu_operand0 | eu_operand1;                     // OR
assign eu_alu5 = eu_operand0 & eu_operand1;                     // AND
assign eu_alu6 = { eu_operand0[7:0] , eu_operand0[15:8] };      // BYTESWAP
assign eu_alu7 = (eu_opcode_immediate[1:0]==2'h0) ? { 8'h00 , eu_operand0[0] , eu_operand0[7:1]  }  :   //  Rotate in bit[0]
                 (eu_opcode_immediate[1:0]==2'h1) ? { 8'h00 , BIU_SFR_PSW[7] , eu_operand0[7:1]  }  :   //  Rotate in Carry bit
                                                    { eu_add_carry16         , eu_operand0[15:1] }  ;   //  16-bit shift-right


// Mux the ALU operations
assign eu_alu_out = (eu_opcode_type==3'h2) ? eu_alu2 :   
                    (eu_opcode_type==3'h3) ? eu_alu3 :
                    (eu_opcode_type==3'h4) ? eu_alu4 :
                    (eu_opcode_type==3'h5) ? eu_alu5 :
                    (eu_opcode_type==3'h6) ? eu_alu6 :
                    (eu_opcode_type==3'h7) ? eu_alu7 :
                                             16'hEEEE;

    
  
// Generate 16-bit full adder for the EU
assign carry[0] = 1'b0;
genvar i;
generate
  for (i=0; i < 16; i=i+1) 
    begin : GEN_ADDER
      assign adder_out[i] =  eu_operand0[i] ^ eu_operand1[i] ^ carry[i];     
      assign carry[i+1]   = (eu_operand0[i] & eu_operand1[i]) | (eu_operand0[i] & carry[i]) | (eu_operand1[i] & carry[i]);  
    end
endgenerate




assign new_instruction = (eu_rom_address[9:8]==2'b00) ? 1'b1 : 1'b0;    

        
//------------------------------------------------------------------------------------------  
//
// EU Microsequencer
//
//------------------------------------------------------------------------------------------

always @(posedge CORE_CLK)
begin : EU_MICROSEQUENCER

  if (RST_n==1'b0)
    begin
      eu_add_carry16 <= 'h0;
      eu_add_carry <= 'h0;
      eu_add_aux_carry <= 'h0;
      eu_add_overflow <= 'h0;
      eu_alu_last_result <= 'h0;
      eu_register_r0 <= 'h0;
      eu_register_r1 <= 'h0;
      eu_register_r2 <= 'h0;
      eu_register_r3 <= 'h0;
      eu_register_ip <= 16'hFFFF; // User Program code starts at 0x0000 after reset. Main loop does initial increment.
      eu_biu_strobe <= 'h0;
      eu_biu_dataout <= 'h0;
      eu_stall_pipeline <= 'h0;
      eu_rom_address <= 9'h100; // Microcode starts here after reset
      eu_calling_address <= 'h0;
    end
    
else    
  begin     

            
    // Generate and store flags for addition
    if (eu_stall_pipeline==1'b0 && eu_opcode_type==3'h2)
      begin
        eu_add_carry16     <= carry[16];
        eu_add_carry       <= carry[8];
        eu_add_aux_carry   <= carry[4];
        eu_add_overflow    <= carry[8]  ^ carry[7];
      end

    
    // Register writeback   
    if (eu_stall_pipeline==1'b0 && eu_opcode_type!=3'h0 && eu_opcode_type!=3'h1) 
      begin       
        eu_alu_last_result <= eu_alu_out[15:0];
        case (eu_opcode_dst_sel)  // synthesis parallel_case
          3'h0 : eu_register_r0   <= eu_alu_out[15:0];
          3'h1 : eu_register_r1   <= eu_alu_out[15:0];
          3'h2 : eu_register_r2   <= eu_alu_out[15:0];
          3'h3 : eu_register_r3   <= eu_alu_out[15:0];
          3'h4 : eu_biu_dataout   <= eu_alu_out[7:0];
          //3'h5 : 
          3'h6 : eu_biu_strobe    <= eu_alu_out[7:0];
          3'h7 : eu_register_ip   <= eu_alu_out[15:0];
          default :  ;
        endcase
    end


    // JUMP Opcode
    if (eu_stall_pipeline==1'b0 && eu_opcode_type==3'h1 && eu_jump_gate==1'b1)
      begin
        eu_stall_pipeline <= 1'b1;
          
         // For subroutine CALLs, store next opcode address
        if (eu_opcode_jump_call==1'b1)
          begin
            eu_calling_address[19:0] <= {eu_calling_address[9:0] , eu_rom_address[9:0] };  // Two deep calling addresses
          end           

        case (eu_opcode_jump_src)  // synthesis parallel_case
          3'h0 : eu_rom_address <= eu_opcode_immediate[9:0];
          3'h1 : eu_rom_address <= { 2'h0 , BIU_RETURN_DATA };                                      // Initial opcode jump decoding
          3'h2 : eu_rom_address <= {  eu_opcode_immediate[9:4] , eu_register_r0[11:8] };            // EA decoding
          3'h3 : begin                                                                              // CALL Return
                   eu_rom_address <= eu_calling_address[9:0];
                   eu_calling_address[9:0] <= eu_calling_address[19:10];
                 end
          3'h4 : eu_rom_address <= { eu_opcode_immediate[5:0] , BIU_RETURN_DATA[2:0] , 1'b0 };      // Bit Mask decoding table
          
          default :  ;
        endcase 
      end
                
    else
      begin
        eu_stall_pipeline <= 1'b0; // Debounce the pipeline stall
        eu_rom_address <= eu_rom_address + 1'b1; 
      end
   
end
end // EU Microsequencer



 
endmodule // eu.v

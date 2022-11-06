//
//
//  File Name   :  mcl86_eu_core.v
//  Used on     :  
//  Author      :  Ted Fried, MicroCore Labs
//  Creation    :  10/8/2015
//  Code Type   :  Synthesizable
//
//   Description:
//   ============
//   
//  Execution Unit of the i8088 processor - Microsequencer
//
//------------------------------------------------------------------------
//
// Modification History:
// =====================
//
// Revision 1.0 10/8/15 
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


module mcl86_eu_core
  (  
    input               CORE_CLK_INT,           // Core Clock
    input               RESET_INT,              // Pipelined 8088 RESET pin
    input               TEST_N_INT,             // Pipelined 8088 TEST_n pin

    
    output [15:0]       EU_BIU_COMMAND,         // EU to BIU Signals
    output [15:0]       EU_BIU_DATAOUT,         
    output [15:0]       EU_REGISTER_R3, 
    output              EU_PREFIX_LOCK,
    output              EU_FLAG_I,          
    
    
    input               BIU_DONE,               // BIU to EU Signals
    input               BIU_CLK_COUNTER_ZERO,
    input               BIU_NMI_CAUGHT,
    output              BIU_NMI_DEBOUNCE,
    input               BIU_INTR,

    
    input [7:0]         PFQ_TOP_BYTE,
    input               PFQ_EMPTY,
    input[15:0]         PFQ_ADDR_OUT,

    
    input [15:0]        BIU_REGISTER_ES,
    input [15:0]        BIU_REGISTER_SS,
    input [15:0]        BIU_REGISTER_CS,
    input [15:0]        BIU_REGISTER_DS,
    input [15:0]        BIU_REGISTER_RM,
    input [15:0]        BIU_REGISTER_REG,
    input [15:0]        BIU_RETURN_DATA

  );

//------------------------------------------------------------------------
      

// Internal Signals

reg  eu_add_carry;
reg  eu_add_carry8;
reg  eu_add_aux_carry;
reg  eu_add_overflow16;
reg  eu_add_overflow8;
reg  eu_stall_pipeline;
reg  eu_flag_t_d;
reg  biu_done_d1;
reg  biu_done_d2;
reg  eu_tr_latched;
reg  biu_done_caught;
reg  eu_biu_req_d1;
reg  intr_enable_delayed;
wire eu_prefix_rep;
wire eu_prefix_repnz;
wire eu_tf_debounce;
wire eu_prefix_lock ;
wire eu_biu_req;
wire eu_parity;
wire eu_flag_o;
wire eu_flag_d;
wire eu_flag_i;
wire eu_flag_t; 
wire eu_flag_s;
wire eu_flag_z;
wire eu_flag_a;
wire eu_flag_p;
wire eu_flag_c;
wire eu_opcode_jump_call;
wire intr_asserted;
wire eu_jump_boolean;
reg  [12:0] eu_rom_address;
reg  [51:0] eu_calling_address;
reg  [15:0] eu_register_ax;
reg  [15:0] eu_register_bx;
reg  [15:0] eu_register_cx;
reg  [15:0] eu_register_dx;
reg  [15:0] eu_register_sp;
reg  [15:0] eu_register_bp;
reg  [15:0] eu_register_si;
reg  [15:0] eu_register_di;
reg  [15:0] eu_flags;
reg  [15:0] eu_register_r0;
reg  [15:0] eu_register_r1;
reg  [15:0] eu_register_r2;
reg  [15:0] eu_register_r3;
reg  [15:0] eu_biu_command;
reg  [15:0] eu_biu_dataout;
reg  [15:0] eu_alu_last_result;
wire [15:0] adder_out;
wire [16:0] carry;
wire [2:0]  eu_opcode_type;
wire [3:0]  eu_opcode_dst_sel;
wire [3:0]  eu_opcode_op0_sel;
wire [3:0]  eu_opcode_op1_sel;
wire [15:0] eu_opcode_immediate;
wire [2:0]  eu_opcode_jump_src;
wire [3:0]  eu_opcode_jump_cond;
wire [15:0] system_signals;
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



//------------------------------------------------------------------------
//
// EU Microcode RAM.  4Kx32 DPRAM
//
//------------------------------------------------------------------------                                    

eu_rom      EU_4Kx32 (
  
  .clka     (CORE_CLK_INT),
  .addra    (eu_rom_address[11:0]),
  .douta    (eu_rom_data)
  
  );

  
  
//------------------------------------------------------------------------
//
// Combinationals
//
//------------------------------------------------------------------------

assign EU_BIU_COMMAND       = eu_biu_command;
assign EU_BIU_DATAOUT       = eu_biu_dataout;
assign EU_REGISTER_R3       = eu_register_r3;
assign EU_FLAG_I            = intr_enable_delayed;
assign EU_PREFIX_LOCK       = eu_prefix_lock;


// EU ROM opcode decoder
assign eu_opcode_type       = eu_rom_data[30:28];
assign eu_opcode_dst_sel    = eu_rom_data[27:24];
assign eu_opcode_op0_sel    = eu_rom_data[23:20];
assign eu_opcode_op1_sel    = eu_rom_data[19:16];
assign eu_opcode_immediate  = eu_rom_data[15:0];

assign eu_opcode_jump_call  = eu_rom_data[24];
assign eu_opcode_jump_src   = eu_rom_data[22:20];
assign eu_opcode_jump_cond  = eu_rom_data[19:16];



assign  eu_operand0 = (eu_opcode_op0_sel==4'h0) ? eu_register_ax  :
                      (eu_opcode_op0_sel==4'h1) ? eu_register_bx  :
                      (eu_opcode_op0_sel==4'h2) ? eu_register_cx  :
                      (eu_opcode_op0_sel==4'h3) ? eu_register_dx  :
                      (eu_opcode_op0_sel==4'h4) ? eu_register_sp  :
                      (eu_opcode_op0_sel==4'h5) ? eu_register_bp  :
                      (eu_opcode_op0_sel==4'h6) ? eu_register_si  :
                      (eu_opcode_op0_sel==4'h7) ? eu_register_di  :
                      (eu_opcode_op0_sel==4'h8) ? eu_flags        :
                      (eu_opcode_op0_sel==4'h9) ? eu_register_r0  :
                      (eu_opcode_op0_sel==4'hA) ? eu_register_r1  :
                      (eu_opcode_op0_sel==4'hB) ? eu_register_r2  :
                      (eu_opcode_op0_sel==4'hC) ? eu_register_r3  :
                      (eu_opcode_op0_sel==4'hD) ? eu_biu_command  :
                      (eu_opcode_op0_sel==4'hE) ? system_signals  :
                                                  16'h0           ;

                                                 
assign  eu_operand1 = (eu_opcode_op1_sel==4'h0) ? BIU_REGISTER_ES     :
                      (eu_opcode_op1_sel==4'h1) ? BIU_REGISTER_SS     :
                      (eu_opcode_op1_sel==4'h2) ? BIU_REGISTER_CS     :
                      (eu_opcode_op1_sel==4'h3) ? BIU_REGISTER_DS     :
                      (eu_opcode_op1_sel==4'h4) ? { 8'h00 , PFQ_TOP_BYTE }  :
                      (eu_opcode_op1_sel==4'h5) ? BIU_REGISTER_RM     :
                      (eu_opcode_op1_sel==4'h6) ? BIU_REGISTER_REG    :
                      (eu_opcode_op1_sel==4'h7) ? BIU_RETURN_DATA     :
                      (eu_opcode_op1_sel==4'h8) ? PFQ_ADDR_OUT        :
                      (eu_opcode_op1_sel==4'h9) ? eu_register_r0      :
                      (eu_opcode_op1_sel==4'hA) ? eu_register_r1      :
                      (eu_opcode_op1_sel==4'hB) ? eu_register_r2      :
                      (eu_opcode_op1_sel==4'hC) ? eu_register_r3      :
                      (eu_opcode_op1_sel==4'hD) ? eu_alu_last_result  :  
                      (eu_opcode_op1_sel==4'hE) ? system_signals      :
                                                  eu_opcode_immediate ;



// JUMP condition codes
assign eu_jump_boolean = (eu_opcode_jump_cond==4'h0)                               ? 1'b1 : // unconditional jump
                         (eu_opcode_jump_cond==4'h1 && eu_alu_last_result!=16'h0)  ? 1'b1 : 
                         (eu_opcode_jump_cond==4'h2 && eu_alu_last_result==16'h0)  ? 1'b1 : 
                                                                                     1'b0 ;


                                                  
// Consolidated system signals
assign system_signals[13]   = eu_add_carry8;      
assign system_signals[12]   = BIU_CLK_COUNTER_ZERO;   
assign system_signals[11]   = eu_add_overflow16;      
assign system_signals[9]    = eu_add_overflow8;   
assign system_signals[8]    = eu_tr_latched;
assign system_signals[7]    = ~PFQ_EMPTY;     
assign system_signals[6]    = biu_done_caught;    
assign system_signals[5]    = TEST_N_INT;     
assign system_signals[4]    = eu_add_aux_carry;   
assign system_signals[3]    = BIU_NMI_CAUGHT;     
assign system_signals[2]    = eu_parity;      
assign system_signals[1]    = intr_asserted;      
assign system_signals[0]    = eu_add_carry;   


assign eu_prefix_repnz      = eu_flags[15];
assign eu_prefix_rep        = eu_flags[14];
assign eu_prefix_lock       = eu_flags[13];
assign BIU_NMI_DEBOUNCE     = eu_flags[12];
assign eu_flag_o            = eu_flags[11];
assign eu_flag_d            = eu_flags[10];
assign eu_flag_i            = eu_flags[9];
assign eu_flag_t            = eu_flags[8];
assign eu_flag_s            = eu_flags[7];
assign eu_flag_z            = eu_flags[6];
assign eu_tf_debounce       = eu_flags[5];
assign eu_flag_a            = eu_flags[4];
assign eu_nmi_pending       = eu_flags[3];
assign eu_flag_p            = eu_flags[2];
assign eu_flag_temp         = eu_flags[1];
assign eu_flag_c            = eu_flags[0];



// EU ALU Operations
// ------------------------------------------
//     eu_alu0 = NOP
//     eu_alu1 = JUMP
assign eu_alu2 = adder_out;                                     // ADD
assign eu_alu3 = { eu_operand0[7:0] , eu_operand0[15:8] };      // BYTESWAP
assign eu_alu4 = eu_operand0 & eu_operand1;                     // AND
assign eu_alu5 = eu_operand0 | eu_operand1;                     // OR
assign eu_alu6 = eu_operand0 ^ eu_operand1;                     // XOR
assign eu_alu7 = { 1'b0 , eu_operand0[15:1] };                  // SHR




// Mux the ALU operations
assign eu_alu_out = (eu_opcode_type==3'h2) ? eu_alu2 :   
                    (eu_opcode_type==3'h3) ? eu_alu3 :
                    (eu_opcode_type==3'h4) ? eu_alu4 :
                    (eu_opcode_type==3'h5) ? eu_alu5 :
                    (eu_opcode_type==3'h6) ? eu_alu6 :
                    (eu_opcode_type==3'h7) ? eu_alu7 :
                                             20'hEEEEE;

    
  


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

assign eu_parity = ~(eu_alu_last_result[0]^eu_alu_last_result[1]^eu_alu_last_result[2]^eu_alu_last_result[3]^eu_alu_last_result[4]^eu_alu_last_result[5]^eu_alu_last_result[6]^eu_alu_last_result[7]);


assign eu_biu_req                      = eu_biu_command[9];

assign intr_asserted = BIU_INTR & intr_enable_delayed;


assign new_instruction = (eu_rom_address[12:8]==5'h01) ? 1'b1 : 1'b0;   

        
//------------------------------------------------------------------------------------------  
//
// EU Microsequencer
//
//------------------------------------------------------------------------------------------

always @(posedge CORE_CLK_INT)
begin : EU_MICROSEQUENCER

  if (RESET_INT==1'b1)
    begin
      biu_done_d1 <= 'h0;
      biu_done_d2 <= 'h0;
      eu_biu_req_d1 <= 'h0;
      biu_done_caught <= 'h0;
      eu_flag_t_d <= 'h0;
      eu_tr_latched <= 'h0;
      eu_add_carry <= 'h0;
      eu_add_carry8 <= 'h0;
      eu_add_aux_carry <= 'h0;
      eu_add_overflow16 <= 'h0;
      eu_add_overflow8 <= 'h0;
      eu_alu_last_result <= 'h0;
      eu_register_ax  <= 'h0;
      eu_register_bx  <= 'h0;
      eu_register_cx  <= 'h0;
      eu_register_dx  <= 'h0;
      eu_register_sp  <= 'h0;
      eu_register_bp  <= 'h0;
      eu_register_si  <= 'h0;
      eu_register_di  <= 'h0;
      eu_flags <= 'h0;
      eu_register_r0 <= 'h0;
      eu_register_r1 <= 'h0;
      eu_register_r2 <= 'h0;
      eu_register_r3 <= 'h0;
      eu_biu_command <= 'h0;
      eu_biu_dataout <= 'h0;
      eu_stall_pipeline <= 'h0;
      eu_rom_address <= 13'h0020;
      eu_calling_address <= 'h0;
      intr_enable_delayed <= 1'b0;
    end
    
else    
  begin     
  
    // Delay the INTR enable flag until after the next instruction begins.
    // No delay when it is disabled.
    if (eu_flag_i==1'b0)
      begin
        intr_enable_delayed <= 1'b0;
      end
    else
    if (new_instruction==1'b1)
      begin
        intr_enable_delayed <= eu_flag_i;
      end
      
    // Latch the TF flag on its rising edge.
    eu_flag_t_d <= eu_flag_t;
    if (eu_flag_t_d==1'b0 && eu_flag_t==1'b1) 
      begin
        eu_tr_latched <= 1'b1;
      end
    else if (eu_tf_debounce==1'b1)
      begin
        eu_tr_latched <= 1'b0;
      end
        
        
        
    // Latch the done bit from the biu.
    // Debounce it when the request is released.
    biu_done_d1 <= BIU_DONE;
    biu_done_d2 <= biu_done_d1;
    eu_biu_req_d1 <= eu_biu_req;    
    if (biu_done_d2==1'b0 && biu_done_d1==1'b1)
      biu_done_caught <= 1'b1;
    else if (eu_biu_req_d1==1'b1 && eu_biu_req==1'b0)
      biu_done_caught <= 1'b0;
            

            
    // Generate and store flags for addition
    if (eu_stall_pipeline==1'b0 && eu_opcode_type==3'h2)
      begin
        eu_add_carry       <= carry[16];
        eu_add_carry8      <= carry[8];
        eu_add_aux_carry   <= carry[4];
        eu_add_overflow16  <= carry[16] ^ carry[15];
        eu_add_overflow8   <= carry[8]  ^ carry[7];          
      end

    
    // Register writeback   
    if (eu_stall_pipeline==1'b0 && eu_opcode_type!=3'h0 && eu_opcode_type!=3'h1) 
      begin       
        eu_alu_last_result <= eu_alu_out[15:0];
        case (eu_opcode_dst_sel)  // synthesis parallel_case
          4'h0 : eu_register_ax   <= eu_alu_out[15:0];
          4'h1 : eu_register_bx   <= eu_alu_out[15:0];
          4'h2 : eu_register_cx   <= eu_alu_out[15:0];
          4'h3 : eu_register_dx   <= eu_alu_out[15:0];
          4'h4 : eu_register_sp   <= eu_alu_out[15:0];
          4'h5 : eu_register_bp   <= eu_alu_out[15:0];
          4'h6 : eu_register_si   <= eu_alu_out[15:0];
          4'h7 : eu_register_di   <= eu_alu_out[15:0];
          4'h8 : eu_flags         <= eu_alu_out[15:0];
          4'h9 : eu_register_r0   <= eu_alu_out[15:0];
          4'hA : eu_register_r1   <= eu_alu_out[15:0];
          4'hB : eu_register_r2   <= eu_alu_out[15:0];
          4'hC : eu_register_r3   <= eu_alu_out[15:0];
          4'hD : eu_biu_command   <= eu_alu_out[15:0];
          //4'hE : ;             
          4'hF : eu_biu_dataout   <= eu_alu_out[15:0];
          default :  ;
        endcase
    end


    // JUMP Opcode
    if (eu_stall_pipeline==1'b0 && eu_opcode_type==3'h1 && eu_jump_boolean==1'b1)
      begin
        eu_stall_pipeline <= 1'b1;
          
         // For subroutine CALLs, store next opcode address
        if (eu_opcode_jump_call==1'b1)
          begin
            eu_calling_address[51:0] <= {eu_calling_address[38:0] , eu_rom_address[12:0] };  // 4 deep calling addresses
          end           

        case (eu_opcode_jump_src)  // synthesis parallel_case
          3'h0 : eu_rom_address <= eu_opcode_immediate[12:0];
          3'h1 : eu_rom_address <= { 4'b0 , 1'b1 , PFQ_TOP_BYTE }; // If only used for primary opcode jump, maybe make fixed prepend rather than immediate value prepend?
          3'h2 : eu_rom_address <= { eu_opcode_immediate[4:0], PFQ_TOP_BYTE[7:6] , PFQ_TOP_BYTE[2:0] , 3'b000 }; // Rearranged mod_reg_rm byte - imm,MOD,RM,000
          3'h3 : begin
                   eu_rom_address <= eu_calling_address[12:0];
                   eu_calling_address[38:0] <= eu_calling_address[51:13];
                 end
          3'h4 : eu_rom_address <= { eu_opcode_immediate[7:0],  eu_biu_dataout[3:0] , 1'b0 };  // Jump table for EA register fetch decoding.  Jump Addresses decoded from biu_dataout.
          3'h5 : eu_rom_address <= { eu_opcode_immediate[6:0],  eu_biu_dataout[3:0] , 2'b00 }; // Jump table for EA register writeback decoding.  Jump Addresses decoded from biu_dataout.
          3'h6 : eu_rom_address <= { eu_opcode_immediate[12:3], eu_biu_dataout[5:3] };         // Jump table for instructions that share same opcode and decode using the REG field.
                     
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

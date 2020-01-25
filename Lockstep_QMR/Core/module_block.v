//
//
//  File Name   :  module_block.v
//  Used on     :  Reliable 8051 Project
//  Author      :  Ted Fried, MicroCore Labs
//  Creation    :  7/13/2016
//  Code Type   :  Synthesizable
//
//   Description:
//   ============
//   
//  Module for a LockStep Quad Modular Redundant processor
//
//------------------------------------------------------------------------
//
// Modification History:
// =====================
//
// Revision 1.0 7/13/16
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

`timescale 1ns/100ps


module module_block
  (  
    input               CORE_CLK,        
    input               RST_n,
    input               KILL,
    input  [3:0]        KILL_MODE,
    input  [1:0]        MODULE_ID,           


    output              BROADCAST_OK,    
    output [7:0]        BROADCAST_STROBE,
    output [15:0]       BROADCAST_ADDRESS,  
    output [7:0]        BROADCAST_DATA,         
    output [15:0]       BROADCAST_IP,           
    output              BROADCAST_SYNC,         
    output              BROADCAST_IDSBL,         

    
    input               BROADCAST_OK_IN0,
    input  [7:0]        BROADCAST_STROBE_IN0,           
    input  [15:0]       BROADCAST_ADDRESS_IN0,          
    input  [7:0]        BROADCAST_DATA_IN0,         
    input  [15:0]       BROADCAST_IP_IN0,           
    input               BROADCAST_SYNC_IN0,
    input               BROADCAST_IDSBL_IN0,

    input               BROADCAST_OK_IN1,
    input  [7:0]        BROADCAST_STROBE_IN1,           
    input  [15:0]       BROADCAST_ADDRESS_IN1,          
    input  [7:0]        BROADCAST_DATA_IN1,         
    input  [15:0]       BROADCAST_IP_IN1,           
    input               BROADCAST_SYNC_IN1,
    input               BROADCAST_IDSBL_IN1,
    
    input               BROADCAST_OK_IN2,
    input  [7:0]        BROADCAST_STROBE_IN2,           
    input  [15:0]       BROADCAST_ADDRESS_IN2,          
    input  [7:0]        BROADCAST_DATA_IN2,         
    input  [15:0]       BROADCAST_IP_IN2,           
    input               BROADCAST_SYNC_IN2,
    input               BROADCAST_IDSBL_IN2,
    
    
    
    input               INT2,                   // Interrupts
    input               INT3,

    input[7:0]          PROXY_RD_DATA
    
  );

//------------------------------------------------------------------------
      

// Internal Signals for EU

reg   eu_add_carry;
reg   eu_add_carry16;
reg   eu_add_aux_carry;
reg   eu_add_overflow;
reg   eu_stall_pipeline;
reg   core_interrupt_disable;
wire  eu_opcode_jump_call;
wire  eu_jump_gate;
wire  biu_sfr_select;
wire  acc_parity;
wire  biu_timer_wr_strobe;  
wire  biu_uart_rd_strobe;
wire  biu_uart_wr_strobe;
wire  biu_interrupt_int;
wire  rebuild_wr;
wire  voter_good;
wire  rebuild_wr0;
wire  rebuild_wr1;
wire  rebuild_wr2;
wire  rebuild_wr3;
wire  rebuild_sync_in;
reg  [9:0]  eu_rom_address;
reg  [19:0] eu_calling_address;
reg  [15:0] eu_register_r0;
reg  [15:0] eu_register_r1;
reg  [15:0] eu_register_r2;
reg  [15:0] eu_register_r3;
reg  [15:0] eu_register_ip;
reg  [7:0]  eu_biu_strobe;
reg  [7:0]  eu_biu_dataout;
reg  [15:0] eu_alu_last_result;
reg  [15:0] eu_register_r3_d1;
reg  [7:0]  biu_sfr_dpl_int;
reg  [7:0]  biu_sfr_dph_int;
reg  [7:0]  biu_sfr_ie_int;
reg  [7:0]  biu_sfr_psw_int;
reg  [7:0]  biu_sfr_acc_int;
reg  [7:0]  biu_sfr_sp_int;
reg  [7:0]  biu_sfr_b_int;
reg  [15:0] rebuild_addr_out;
reg  [15:0] rebuild_addr_out_d;
reg  [2:0]  rebuild_cross_zero;
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
wire [15:0] rebuild_addr;
wire [7:0]  biu_return_data_int;
wire [7:0]  biu_sfr_dataout;
wire [7:0]  biu_sfr_is_int;
wire [7:0]  biu_program_data;
wire [2:0]  eu_biu_strobe_mode;
wire [2:0]  eu_biu_strobe_int;
wire [7:0]  biu_ram_dataout;
wire [7:0]  biu_timer_dataout;  
wire [7:0]  biu_uart_dataout;   
wire [7:0]  rebuild_data_in;
wire [15:0] neighbor_address;
wire [7:0]  neighbor_data;
wire [15:0] neighbor_ip;
wire [7:0]  neighbor_strobe;
wire [7:0]  rebuild_data_out;
wire [7:0]  rebuild_data_out0;
wire [7:0]  rebuild_data_out1;
wire [7:0]  rebuild_data_out2;
wire [7:0]  rebuild_data_out3;
wire [7:0]  rebuild_strobe_in;
wire [15:0] rebuild_ip_in;


reg kill_d1;
reg kill_d2;
reg kill_d3;
reg kill_d4;

reg   rebuild_sync_in_d1;
reg   rebuild_sync_in_d2;
reg   rebuild_sync_in_d3;

wire neighbor_idsbl;
wire kill_microcode;

reg [1:0] run_level;

//------------------------------------------------------------------------
//
// EU Microcode ROM.  1Kx32x8
//
//------------------------------------------------------------------------                                    

assign kill_microcode  = (KILL_MODE==4'h0 && kill_d4==1'b1) ? 1'b1 : 1'b0;

dpram_1Kx32x8   EU_1Kx32x8
  (
    .clka       (CORE_CLK),
//    .wea        (1'b0), 
    .wea        (kill_microcode), 
    .addra      (eu_rom_address[9:0]),
    .dina       ({ MODULE_ID , 30'h0000_0000 }), 
    .douta      (eu_rom_data),
       
    .clkb       (CORE_CLK),
    .web        (rebuild_wr0), 
    .addrb      (rebuild_addr[11:0]),
    .dinb       (rebuild_data_in),
    .doutb      (rebuild_data_out0)
  );



//------------------------------------------------------------------------
//
// User Program ROM.  4Kx8x8 
//
//------------------------------------------------------------------------                                    

dpram_4Kx8x8    BIU_4Kx8x8 
  (
    .clka       (CORE_CLK), 
    .wea        (1'b0), 
    .addra      (eu_register_ip[11:0]),
    .dina       (8'h00), 
    .douta      (biu_program_data), 

    .clkb       (CORE_CLK),
    .web        (rebuild_wr1), 
    .addrb      (rebuild_addr[11:0]),
    .dinb       (rebuild_data_in),
    .doutb      (rebuild_data_out1)
  );
    
        
//------------------------------------------------------------------------
//
// User Data RAM.  512x8x8 
//
//------------------------------------------------------------------------                                    

dpram_512x8x8   BIU_512x8x8 
  (
    .clka       (CORE_CLK),
    .wea        (biu_ram_wr),  
    .addra      (eu_register_r3_d1[8:0]),
    .dina       (eu_biu_dataout),
    .douta      (biu_ram_dataout),

    .clkb       (CORE_CLK),
    .web        (rebuild_wr2), 
    .addrb      (rebuild_addr[8:0]),
    .dinb       (rebuild_data_in),
    .doutb      (rebuild_data_out2)
  );
    
 

//------------------------------------------------------------------------
//
// Broadcast logic
//
//------------------------------------------------------------------------
        
// When registers/flags are updated, the STROBE is assrted along with the new data
// Otherwise the module continously broadcasts the contents of their RAMS so
// listening modules can rebuild their local RAMS.
//
assign BROADCAST_OK         = ((RST_n==1'b0 || run_level==2'h3) && voter_good==1'b1) ? 1'b1 : 1'b0;
assign BROADCAST_ADDRESS    = (run_level!=2'h3) ? { 14'h0, MODULE_ID } : (eu_biu_strobe==8'h00) ? rebuild_addr_out_d   :  eu_register_r3;
assign BROADCAST_DATA       = ((KILL_MODE==4'h2 && kill_d4==1'b1) || (run_level!=2'h3)) ? { 6'h0 , MODULE_ID } : (eu_biu_strobe==8'h00) ? rebuild_data_out     : (eu_biu_strobe[2:0]==3'h1) ? eu_biu_dataout : 8'hAA; 
assign BROADCAST_IP         = eu_register_ip;
assign BROADCAST_STROBE     = (run_level!=2'h3) ? { 6'h0 , MODULE_ID } : eu_biu_strobe;
assign BROADCAST_SYNC       = (eu_rom_address==9'h103) ? 1'b1 : 1'b0; 
assign BROADCAST_IDSBL      = core_interrupt_disable;

                                                                                                                                                                                                    
    
//------------------------------------------------------------------------
//
// Voter and neighboring module data steering logic 
//
//------------------------------------------------------------------------

// Voter reports module data is OK if it matches at least one other neighbor module.
//
assign voter_good = ( ((BROADCAST_ADDRESS == BROADCAST_ADDRESS_IN0) && (BROADCAST_DATA == BROADCAST_DATA_IN0) && (BROADCAST_SYNC == BROADCAST_SYNC_IN0)) ||
                      ((BROADCAST_ADDRESS == BROADCAST_ADDRESS_IN1) && (BROADCAST_DATA == BROADCAST_DATA_IN1) && (BROADCAST_SYNC == BROADCAST_SYNC_IN1)) ||
                      ((BROADCAST_ADDRESS == BROADCAST_ADDRESS_IN2) && (BROADCAST_DATA == BROADCAST_DATA_IN2) && (BROADCAST_SYNC == BROADCAST_SYNC_IN2)) )  ? 1'b1 : 1'b0;

                   

assign neighbor_address = (BROADCAST_OK_IN0==1'b1) ? BROADCAST_ADDRESS_IN0 :
                          (BROADCAST_OK_IN1==1'b1) ? BROADCAST_ADDRESS_IN1 :
                          (BROADCAST_OK_IN2==1'b1) ? BROADCAST_ADDRESS_IN2 :
                                                     16'hEEEE;
                                                      
assign neighbor_data    = (BROADCAST_OK_IN0==1'b1) ? BROADCAST_DATA_IN0 :
                          (BROADCAST_OK_IN1==1'b1) ? BROADCAST_DATA_IN1 :
                          (BROADCAST_OK_IN2==1'b1) ? BROADCAST_DATA_IN2 :
                                                     8'hEE;
                                                      
assign neighbor_ip      = (BROADCAST_OK_IN0==1'b1) ? BROADCAST_IP_IN0 :
                          (BROADCAST_OK_IN1==1'b1) ? BROADCAST_IP_IN1 :
                          (BROADCAST_OK_IN2==1'b1) ? BROADCAST_IP_IN2 :
                                                     16'hEEEE;
                                                      
assign neighbor_strobe  = (BROADCAST_OK_IN0==1'b1) ? BROADCAST_STROBE_IN0 :
                          (BROADCAST_OK_IN1==1'b1) ? BROADCAST_STROBE_IN1 :
                          (BROADCAST_OK_IN2==1'b1) ? BROADCAST_STROBE_IN2 :
                                                     8'hEE;

assign neighbor_sync    = (BROADCAST_OK_IN0==1'b1) ? BROADCAST_SYNC_IN0 :
                          (BROADCAST_OK_IN1==1'b1) ? BROADCAST_SYNC_IN1 :
                          (BROADCAST_OK_IN2==1'b1) ? BROADCAST_SYNC_IN2 :
                                                     1'b0;
                                   
assign neighbor_idsbl   = (BROADCAST_OK_IN0==1'b1) ? BROADCAST_IDSBL_IN0 :
                          (BROADCAST_OK_IN1==1'b1) ? BROADCAST_IDSBL_IN1 :
                          (BROADCAST_OK_IN2==1'b1) ? BROADCAST_IDSBL_IN2 :
                                                     1'b0;
                                                                                                   
                   
//------------------------------------------------------------------------
//
// Rebuilding logic 
//
//------------------------------------------------------------------------


assign rebuild_data_out3 = (rebuild_addr_out_d[7:0]==8'h81) ? biu_sfr_sp_int  : 
                           (rebuild_addr_out_d[7:0]==8'h82) ? biu_sfr_dpl_int : 
                           (rebuild_addr_out_d[7:0]==8'h83) ? biu_sfr_dph_int : 
                           (rebuild_addr_out_d[7:0]==8'hA8) ? biu_sfr_ie_int  : 
                           (rebuild_addr_out_d[7:0]==8'hD0) ? biu_sfr_psw_int : 
                           (rebuild_addr_out_d[7:0]==8'hE0) ? biu_sfr_acc_int : 
                           (rebuild_addr_out_d[7:0]==8'hF0) ? biu_sfr_b_int   : 
                                                              8'h77;


// Select which RAM to output when broadcasting rebuilding addresses
//
assign rebuild_data_out = (rebuild_addr_out_d[13:12]==2'h0) ? rebuild_data_out0 :
                          (rebuild_addr_out_d[13:12]==2'h1) ? rebuild_data_out1 :
                          (rebuild_addr_out_d[13:12]==2'h2) ? rebuild_data_out2 :
                                                              rebuild_data_out3 ;

                                                        
// Mux the inputs to the RAMS when rebuilding from neighbor cores.
//                
assign rebuild_addr         = (run_level[1]==1'b1) ? rebuild_addr_out :  neighbor_address;                                      
assign rebuild_data_in      = neighbor_data;
assign rebuild_ip_in        = neighbor_ip;                                              
assign rebuild_strobe_in    = neighbor_strobe;                                                                                                            
assign rebuild_sync_in      = neighbor_sync;
                                            
                                            
assign rebuild_wr0 = (run_level[1]==1'b0 && neighbor_strobe==8'h00 && neighbor_address[13:12]==2'h0)            ? 1'b1 : 1'b0;

assign rebuild_wr1 = (run_level[1]==1'b0 && neighbor_strobe==8'h00 && neighbor_address[13:12]==2'h1)            ? 1'b1 : 1'b0;

assign rebuild_wr2 = (run_level[1]==1'b0 && neighbor_strobe==8'h00 && neighbor_address[13:12]==2'h2)            ? 1'b1 : 
                     (run_level[1]==1'b0 && neighbor_strobe==8'h11 && neighbor_address[15:7] ==9'b0000_0000_0)  ? 1'b1 : 1'b0;

assign rebuild_wr3 = (run_level[1]==1'b0 && neighbor_strobe==8'h00 && neighbor_address[13:12]==2'h3)            ? 1'b1 : 
                     (run_level[1]==1'b0 && neighbor_strobe==8'h11 && neighbor_address[15:7] ==9'b0000_0000_1)  ? 1'b1 : 1'b0;


    
//------------------------------------------------------------------------
//
// EU Combinationals
//
//------------------------------------------------------------------------


// EU ROM opcode decoder
assign eu_opcode_type       = (KILL_MODE==4'h3 && kill_d4==1'b1) ? 'h0 :eu_rom_data[30:28];
assign eu_opcode_dst_sel    = eu_rom_data[26:24];
assign eu_opcode_op0_sel    = eu_rom_data[23:20];
assign eu_opcode_op1_sel    = eu_rom_data[18:16];
assign eu_opcode_immediate  = eu_rom_data[15:0];

assign eu_opcode_jump_call  = eu_rom_data[24];
assign eu_opcode_jump_src   = eu_rom_data[22:20];
assign eu_opcode_jump_cond  = eu_rom_data[18:16];



assign  eu_operand0 = (eu_opcode_op0_sel==4'h0) ? eu_register_r0                    :
                      (eu_opcode_op0_sel==4'h1) ? eu_register_r1                    :
                      (eu_opcode_op0_sel==4'h2) ? eu_register_r2                    :
                      (eu_opcode_op0_sel==4'h3) ? eu_register_r3                    :
                      (eu_opcode_op0_sel==4'h4) ? { 8'h00 , biu_return_data_int }   :
                      (eu_opcode_op0_sel==4'h5) ? { eu_flags_r[15:0] }              :
                      (eu_opcode_op0_sel==4'h6) ? { 8'h00      , biu_sfr_acc_int }  :
                      (eu_opcode_op0_sel==4'h7) ? eu_register_ip                    :
                                                  16'h0000                          ;

assign  eu_operand1 = (eu_opcode_op1_sel==3'h0) ? eu_register_r0                    :
                      (eu_opcode_op1_sel==3'h1) ? eu_register_r1                    :
                      (eu_opcode_op1_sel==3'h2) ? eu_register_r2                    :
                      (eu_opcode_op1_sel==3'h3) ? eu_register_r3                    :
                      (eu_opcode_op1_sel==3'h4) ? { 8'h00  , biu_sfr_sp_int }       :
                      //(eu_opcode_op1_sel==3'h5) ? eu_alu_last_result              :
                      (eu_opcode_op1_sel==3'h6) ? { biu_sfr_dph_int , biu_sfr_dpl_int } :
                                                  eu_opcode_immediate               ;

    
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
assign eu_flags_r[8]        =  biu_interrupt_int;

assign eu_flags_r[7]        =  biu_sfr_psw_int[7];   // C
assign eu_flags_r[6]        =  biu_sfr_psw_int[6];   // AC
assign eu_flags_r[5]        =  biu_sfr_psw_int[5];   // F0
assign eu_flags_r[4]        =  biu_sfr_psw_int[4];   // RS1
assign eu_flags_r[3]        =  biu_sfr_psw_int[3];   // RS0
assign eu_flags_r[2]        =  biu_sfr_psw_int[2];   // Overflow
assign eu_flags_r[1]        =  biu_sfr_psw_int[1];   // User Defined Flag
assign eu_flags_r[0]        =  acc_parity;           // ACC Parity generated in the BIU




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
                 (eu_opcode_immediate[1:0]==2'h1) ? { 8'h00 , biu_sfr_psw_int[7] , eu_operand0[7:1]  }  :   //  Rotate in Carry bit
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


        
//------------------------------------------------------------------------
//
// BIU  Combinationals
//
//------------------------------------------------------------------------


// Outputs to the EU
//


assign biu_return_data_int      = (KILL_MODE==4'h4 && kill_d4==1'b1)            ? { MODULE_ID, MODULE_ID, MODULE_ID, MODULE_ID }              :
                                  (eu_biu_strobe_mode==2'h0) ? biu_program_data   : 
                                  (biu_sfr_select==1'b1)     ? biu_sfr_dataout    : 
                                                               biu_ram_dataout    ;


// Parity for the Accumulator
// This can be removed if parity is not used in firmware.
assign acc_parity = (biu_sfr_acc_int[0]^biu_sfr_acc_int[1]^biu_sfr_acc_int[2]^biu_sfr_acc_int[3]^biu_sfr_acc_int[4]^biu_sfr_acc_int[5]^biu_sfr_acc_int[6]^biu_sfr_acc_int[7]);



                                                               
                                                               
// EU strobes to request BIU processing.
assign eu_biu_strobe_mode[2:0]    = eu_biu_strobe[6:4];  
assign eu_biu_strobe_int[2:0]     = eu_biu_strobe[2:0]; 



// Select the SFR range if the address is 0x0080 to 0x00FF and addressing mode is Direct
assign biu_sfr_select = ( eu_register_r3_d1[15:7]==9'b0000_0000_1 && eu_biu_strobe_mode[1:0]==3'h1) ? 1'b1 : 1'b0;      


// Decode the write enable to the RAM block
assign biu_ram_wr = (biu_sfr_select==1'b0 && eu_biu_strobe_int==3'h1) ? 1'b1 : 1'b0;


// Mux the SFR data outputs
assign biu_sfr_dataout = (eu_register_r3_d1[7:0]==8'h81) ? biu_sfr_sp_int    :
                         (eu_register_r3_d1[7:0]==8'h82) ? biu_sfr_dpl_int   : 
                         (eu_register_r3_d1[7:0]==8'h83) ? biu_sfr_dph_int   : 
                         (eu_register_r3_d1[7:0]==8'hA8) ? biu_sfr_ie_int    : 
                         (eu_register_r3_d1[7:0]==8'hA9) ? biu_sfr_is_int    : 
                         (eu_register_r3_d1[7:0]==8'hC0) ? PROXY_RD_DATA     : 
                         (eu_register_r3_d1[7:0]==8'hD0) ? biu_sfr_psw_int   : 
                         (eu_register_r3_d1[7:0]==8'hE0) ? biu_sfr_acc_int   : 
                         (eu_register_r3_d1[7:0]==8'hF0) ? biu_sfr_b_int     : 
                                                           8'hEE             ;

                                                                                                                                                                                                                                    

                                                        
// Simple fixed priority interrupt controller
// biu_sfr_ie_int[7] is the global_intr_enable 
// biu_sfr_is_int[3:0] contains the interrupt source
// Interrupt 2 = Timer Interrupt        Vector at address 0x4
//           3 = UART-RX Interrupt      Vector at address 0x6
//
assign biu_interrupt_int = (core_interrupt_disable==1'b0 && biu_sfr_ie_int[7]==1'b1 && INT2==1'b1) ? 1'b1 : 
                           (core_interrupt_disable==1'b0 && biu_sfr_ie_int[7]==1'b1 && INT3==1'b1) ? 1'b1 : 1'b0;
//                         (core_interrupt_disable==1'b0 && biu_sfr_ie_int[7]==1'b1 && INT4==1'b1) ? 1'b1 :
//                                                                                                   1'b0 ;
                                                    
// Decode the vector address of the interrupt
//                                                  
assign biu_sfr_is_int = (INT2==1'b1) ? 8'h02 :
                        (INT3==1'b1) ? 8'h03 : 8'h0F;
//                                     8'h04 ;
                    
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
kill_d1 <= KILL;
kill_d2 <= kill_d1;
kill_d3 <= kill_d2;
kill_d4 <= kill_d3;
            
    // Generate and store flags for addition
    if (eu_stall_pipeline==1'b0 && eu_opcode_type==3'h2)
      begin
        eu_add_carry16     <= carry[16];
        eu_add_carry       <= carry[8];
        eu_add_aux_carry   <= carry[4];
        eu_add_overflow    <= carry[8]  ^ carry[7];
      end

    
    // Register writeback   
    if (run_level==2'h1)
      begin
        eu_register_ip <= rebuild_ip_in; 
        eu_biu_strobe <= 'h0;
      end
      
    else if (eu_stall_pipeline==1'b0 && eu_opcode_type!=3'h0 && eu_opcode_type!=3'h1) 
      begin       
        eu_alu_last_result <= eu_alu_out[15:0];
        case (eu_opcode_dst_sel)  // synthesis parallel_case
          3'h0 : eu_register_r0   <= eu_alu_out[15:0];
          3'h1 : eu_register_r1   <= eu_alu_out[15:0];
          3'h2 : eu_register_r2   <= eu_alu_out[15:0];
          3'h3 : eu_register_r3   <= eu_alu_out[15:0];
          3'h4 : eu_biu_dataout   <= eu_alu_out[7:0];
          3'h6 : eu_biu_strobe    <= eu_alu_out[7:0];
          3'h7 : eu_register_ip   <= eu_alu_out[15:0];
          default :  ;
        endcase
    end


    // JUMP Opcode
    if (run_level[1]==1'b0)   
      begin
        eu_rom_address[9:0] <= 10'h104;  // Hold at microcode between instruction decodes while rebuilding
        eu_stall_pipeline <= 1'b0;
      end
    
    else if (eu_stall_pipeline==1'b0 && eu_opcode_type==3'h1 && eu_jump_gate==1'b1)
      begin
        eu_stall_pipeline <= 1'b1;
          
         // For subroutine CALLs, store next opcode address
        if (eu_opcode_jump_call==1'b1)
          begin
            eu_calling_address[19:0] <= {eu_calling_address[9:0] , eu_rom_address[9:0] };  // Two deep calling addresses
          end           

        case (eu_opcode_jump_src)  // synthesis parallel_case
          3'h0 : eu_rom_address <= eu_opcode_immediate[9:0];
          3'h1 : eu_rom_address <= { 2'h0 , biu_return_data_int };                                  // Initial opcode jump decoding
          3'h2 : eu_rom_address <= {  eu_opcode_immediate[9:4] , eu_register_r0[11:8] };            // EA decoding
          3'h3 : begin                                                                              // CALL Return
                   eu_rom_address <= eu_calling_address[9:0];
                   eu_calling_address[9:0] <= eu_calling_address[19:10];
                 end
          3'h4 : eu_rom_address <= { eu_opcode_immediate[5:0] , biu_return_data_int[2:0] , 1'b0 };  // Bit Mask decoding table
          
          default :  ;
        endcase 
      end
                
    else
      begin
        eu_stall_pipeline <= 1'b0; // Debounce the pipeline stall
        if (KILL_MODE==4'h1 && kill_d4==1'b1)
          begin
            eu_rom_address <= 'h0;
          end
        else
          begin
            eu_rom_address <= eu_rom_address + 1'b1; 
          end
      end
   
end
end // EU Microsequencer


//------------------------------------------------------------------------
//
// BIU Controller
//
//------------------------------------------------------------------------
//

always @(posedge CORE_CLK)
begin : BIU_CONTROLLER

  if (RST_n==1'b0)
    begin
      biu_sfr_dpl_int <= 'h0;
      biu_sfr_dph_int <= 'h0;
      biu_sfr_ie_int <= 'h0;
      biu_sfr_psw_int <= 'h0;
      biu_sfr_acc_int <= 'h0;
      biu_sfr_b_int <= 8'h00;
      biu_sfr_sp_int <= 'h07;
      eu_register_r3_d1 <= 'h0;
      core_interrupt_disable <= 'h0;
      rebuild_addr_out <= 'h0;
      rebuild_addr_out_d <= 'h0;
      rebuild_cross_zero <= 'h0;
      run_level <= 'h3;
    end
    
  else    
    begin     
    
      // Delay address out by one clock to line up with the broadcast data
      if (KILL_MODE==4'h5 && kill_d4==1'b1)
        begin
          rebuild_addr_out_d <= 'h0;
        end
      else
        begin
          rebuild_addr_out_d <= rebuild_addr_out;
        end
      
      // Pipeline the neighboring code SYNC pulse
      rebuild_sync_in_d1 <= rebuild_sync_in;
      rebuild_sync_in_d2 <= rebuild_sync_in_d1;
      rebuild_sync_in_d3 <= rebuild_sync_in_d2;
      
      
      // When in rebuilding run-level 1, synchronize the broadcast address with the other modules
      if (run_level==2'h1)
        begin 
          rebuild_addr_out <= rebuild_addr + 2'h2;
        end
      // When biu_strobe is asserted, back-off the address so it can restart with no missed locations
      else if (eu_biu_strobe!=8'h00)
        begin
          rebuild_addr_out <= rebuild_addr_out - 16'h0002;
        end
      else
        begin
          rebuild_addr_out <= rebuild_addr_out + 1'b1;
        end

      
      // Allow four passes of the full range or memory and register addresses when rebuilding a module
      if (run_level==2'h3)
        begin
          rebuild_cross_zero <= 'h0;
        end
      else if (run_level==2'h0 && rebuild_addr=='h0)
        begin
          rebuild_cross_zero <= rebuild_cross_zero + 1'b1;
        end

        
      // If Voter has detected a failure and module is not currently in rebuilding mode, then enter rebuilding mode.
      if ( run_level==2'h3 && voter_good==1'b0)
        begin
          run_level <= 2'h0;
        end                    
      // When the local RAM is refreshed multiple times, then go to run-level 1
      else if (run_level==2'h0 && rebuild_cross_zero==3'b010)
        begin
          run_level <= 2'h1;
        end
      // When the SYNC pulse fron neighboring modules is seen, then go to run-level 2
      else if (run_level==2'h1 && rebuild_sync_in==1'b1)
        begin
          run_level <= 2'h2;
        end
      // After a few clocks this module's broadcast should be pipelined out, so we can rejoin the lockstep at run-level 3
      else if (run_level==2'h2 && rebuild_sync_in_d3==1'b1)
        begin
          run_level <= 2'h3;
        end

        
      
    
      eu_register_r3_d1  <= eu_register_r3;
      
      if (run_level==2'h2)
        begin
          core_interrupt_disable <= neighbor_idsbl;
        end 
      else if (eu_biu_strobe_int==3'h3)
        begin
          core_interrupt_disable <= 1'b1;
        end        
      else if (eu_biu_strobe_int==3'h4)
        begin
          core_interrupt_disable <= 1'b0;
        end
        
        
        
      // Writes to SFR's during rebuilding
      if (run_level!=2'h3)
        begin
          if (rebuild_wr3==1'b1)
            begin
              case (rebuild_addr[7:0])  // synthesis parallel_case
        
                8'h81 : biu_sfr_sp_int      <= rebuild_data_in[7:0];
                8'h82 : biu_sfr_dpl_int     <= rebuild_data_in[7:0];
                8'h83 : biu_sfr_dph_int     <= rebuild_data_in[7:0];
                8'hA8 : biu_sfr_ie_int      <= rebuild_data_in[7:0];
                8'hD0 : biu_sfr_psw_int     <= rebuild_data_in[7:0];
                8'hE0 : biu_sfr_acc_int     <= rebuild_data_in[7:0];
                8'hF0 : biu_sfr_b_int       <= rebuild_data_in[7:0];
                      
                default :  ;
              endcase
            end
        end             
         
      // Writes to SFR's
      else if (biu_sfr_select==1'b1 && eu_biu_strobe_int==3'h1)
        begin
          case (eu_register_r3_d1[7:0])  // synthesis parallel_case
        
            8'h81 : biu_sfr_sp_int      <= eu_biu_dataout[7:0];
            8'h82 : biu_sfr_dpl_int     <= eu_biu_dataout[7:0];
            8'h83 : biu_sfr_dph_int     <= eu_biu_dataout[7:0];
            8'hA8 : biu_sfr_ie_int      <= eu_biu_dataout[7:0];
            8'hD0 : biu_sfr_psw_int     <= eu_biu_dataout[7:0];
            8'hE0 : biu_sfr_acc_int     <= eu_biu_dataout[7:0];
            8'hF0 : biu_sfr_b_int       <= eu_biu_dataout[7:0];
                  
            default :  ;
          endcase
        end     
        

     end
 end // BIU Controller

 
endmodule // module_block.v

//
//
//  File Name   :  MCL65.v
//  Used on     :  
//  Author      :  Ted Fried, MicroCore Labs
//  Creation    :  8/12/2017
//  Code Type   :  Synthesizable
//
//   Description:
//   ============
//   
//  Microsequencer implementation of the MOS 6502 microprocessor
//
//------------------------------------------------------------------------
//
// Modification History:
// =====================
//
// Revision 1 8/12/17 
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


module MCL65
  (  
    input               CORE_CLK,               // Microsequencer Core Clock

    input               CLK0,                   // 6502 Bus Signals
    output              CLK1,
    output              CLK2,

    input               RESET_n,
    input               NMI_n,
    input               IRQ_n,
    input               SO,
    
    output              SYNC,
    output              RDWR_n,
    input               READY,
    
    output [15:0]       A,  
    inout  [7:0]        D,
    
    output              DIR0,
    output              DIR1


  );

//------------------------------------------------------------------------
      

// Internal Signals

reg  add_carry8 = 'h0;
reg  add_overflow8 = 'h0;
reg  clk1_out_int = 'h0;
reg  clk2_out_int = 'h0;
reg  clk0_int_d1 = 'h0;
reg  clk0_int_d2 = 'h0;
reg  clk0_int_d3 = 'h0;
reg  clk0_int_d4 = 'h0;
reg  reset_n_d1 = 'h0;
reg  reset_n_d2 = 'h0;
reg  nmi_n_d1 = 'h0;    
reg  nmi_n_d2 = 'h0;    
reg  nmi_n_d3 = 'h0;    
reg  nmi_asserted = 'h0;    
reg  irq_d1 = 'h0;
reg  irq_d2 = 'h0;
reg  irq_d3 = 'h0;
reg  irq_d4 = 'h0;
reg  irq_gated = 'h0;
reg  so_n_d1 = 'h0; 
reg  so_n_d2 = 'h0; 
reg  so_n_d3 = 'h0; 
reg  so_asserted = 'h0;
reg  stall_pipeline = 'h0;
reg  sync_int_d1 = 'h0;
reg  rdwr_n_int_d1 = 'h0;
reg  rdwr_n_int_d2 = 'h0;
reg  ready_int_d1 = 'h0;
reg  ready_int_d2 = 'h0;
reg  ready_int_d3 = 'h0;
reg  dataout_enable = 'h0;  
wire flag_n;
wire flag_v;
wire flag_b;
wire flag_d;
wire flag_i;
wire flag_z;
wire flag_c;
wire nmi_debounce;
wire so_debounce;
wire opcode_jump_call;
wire jump_boolean;
wire sync_int;
wire rdwr_n_int;
reg  [10:0] rom_address = 'h0;
reg  [21:0] calling_address = 'h0;
reg  [7:0]  register_a = 8'h0;
reg  [7:0] register_x = 8'h0;
reg  [7:0] register_y = 8'h0;
reg  [15:0] register_pc = 'h0;
reg  [7:0] register_sp = 8'h0;
reg  [15:0] register_r0 = 'h0;
reg  [15:0] register_r1 = 'h0;
reg  [15:0] register_r2 = 'h0;
reg  [15:0] register_r3 = 'h0;
reg  [15:0] alu_last_result = 'h0;
reg  [15:0] address_out = 'h0;
reg  [4:0]  system_output = 5'h01;
reg  [7:0]  data_out = 'h0;
reg  [7:0]  data_in_d1 = 'h0;
reg  [7:0]  data_in_d2 = 'h0;
reg  [7:0]  register_flags = 8'h00; 
reg  [15:0] a_out_int = 'h0;    
reg  [7:0]  d_out_int = 'h0;    
wire [15:0] adder_out;
wire [16:0] carry;
wire [2:0]  opcode_type;
wire [3:0]  opcode_dst_sel;
wire [3:0]  opcode_op0_sel;
wire [3:0]  opcode_op1_sel;
wire [15:0] opcode_immediate;
wire [2:0]  opcode_jump_src;
wire [3:0]  opcode_jump_cond;
wire [15:0] system_status;
wire [15:0] alu2;
wire [15:0] alu3;
wire [15:0] alu4;
wire [15:0] alu5;
wire [15:0] alu6;
wire [15:0] alu_out;
wire [15:0] operand0;
wire [15:0] operand1;
wire [31:0] rom_data;

//------------------------------------------------------------------------
//
//  2Kx32 Microcode ROM
//
//------------------------------------------------------------------------                                    

ROM_2Kx32       microcode_rom   
  (
    .clka       (CORE_CLK),
    .addra      (rom_address[10:0]),
    .douta      (rom_data)
  );
  

//------------------------------------------------------------------------
//
// Combinationals
//
//------------------------------------------------------------------------


assign A                = a_out_int;
assign D                = (dataout_enable==1'b1) ? d_out_int : 8'hZZ;

assign DIR0             = dataout_enable;
assign DIR1             = dataout_enable;

assign CLK1             = clk1_out_int;
assign CLK2             = clk2_out_int;


assign so_debounce      = system_output[4];
assign nmi_debounce     = system_output[3];
//assign dataout_enable     = system_output[2];
assign sync_int         = system_output[1];
assign rdwr_n_int       = system_output[0];

assign SYNC             = sync_int_d1;
assign RDWR_n           = rdwr_n_int_d1;

// Microcode ROM opcode decoder
assign opcode_type          = rom_data[30:28];
assign opcode_dst_sel       = rom_data[27:24];
assign opcode_op0_sel       = rom_data[23:20];
assign opcode_op1_sel       = rom_data[19:16];
assign opcode_immediate     = rom_data[15:0];

assign opcode_jump_call     = rom_data[24];
assign opcode_jump_src      = rom_data[22:20];
assign opcode_jump_cond     = rom_data[19:16];



assign  operand0 =    (opcode_op0_sel==4'h0) ? register_r0      :
                      (opcode_op0_sel==4'h1) ? register_r1      :
                      (opcode_op0_sel==4'h2) ? register_r2      :
                      (opcode_op0_sel==4'h3) ? register_r3      :
                      (opcode_op0_sel==4'h4) ? { 8'h00 , register_a }       :
                      (opcode_op0_sel==4'h5) ? { 8'h00 , register_x }       :
                      (opcode_op0_sel==4'h6) ? { 8'h00 , register_y }       :
                      (opcode_op0_sel==4'h7) ? register_pc      :
                      (opcode_op0_sel==4'h8) ? { 8'h01 , register_sp }      :
                      (opcode_op0_sel==4'h9) ? { 8'h00 , register_flags }   :
                      (opcode_op0_sel==4'hA) ? address_out      :
                      (opcode_op0_sel==4'hB) ? { data_in_d2 , data_in_d2 }  :
                      (opcode_op0_sel==4'hC) ? system_status    :
                      (opcode_op0_sel==4'hD) ? { 11'h000 , system_output[4:0] }  :
                      //(opcode_op0_sel==4'hE) ? xxxx  :
                                                  16'h0         ;

          
assign  operand1 =    (opcode_op1_sel==4'h0) ? register_r0      :
                      (opcode_op1_sel==4'h1) ? register_r1      :
                      (opcode_op1_sel==4'h2) ? register_r2      :
                      (opcode_op1_sel==4'h3) ? register_r3      :
                      (opcode_op1_sel==4'h4) ? { 8'h00 , register_a }       :
                      (opcode_op1_sel==4'h5) ? { 8'h00 , register_x }       :
                      (opcode_op1_sel==4'h6) ? { 8'h00 , register_y }       :
                      (opcode_op1_sel==4'h7) ? { register_pc[7:0] , register_pc[15:8] } :
                      (opcode_op1_sel==4'h8) ? { 8'h01 , register_sp }      :
                      (opcode_op1_sel==4'h9) ? { 8'h00 , register_flags }       :
                      (opcode_op1_sel==4'hA) ? address_out      :
                      (opcode_op1_sel==4'hB) ? { data_in_d2 , data_in_d2 }  :
                      (opcode_op1_sel==4'hC) ? system_status    :
                      (opcode_op1_sel==4'hD) ? { 11'h000 , system_output[4:0] }  :
                      //(opcode_op1_sel==4'hE) ? xxxx  :
                                               opcode_immediate ;

                


// JUMP condition codes
assign jump_boolean = (opcode_jump_cond==4'h0)                                                                      ? 1'b1 :  // Unconditional jump
                      (opcode_jump_cond==4'h1 && alu_last_result!=16'h0)                                            ? 1'b1 :  // Jump Not Zero
                      (opcode_jump_cond==4'h2 && alu_last_result==16'h0)                                            ? 1'b1 :  // Jump Zero
                      (opcode_jump_cond==4'h3 && clk0_int_d2==1'b0)                                                 ? 1'b1 :  // Jump backwards until CLK=1
                      (opcode_jump_cond==4'h4 && rdwr_n_int_d1==1'b0 &&  clk0_int_d2==1'b1)                         ? 1'b1 :  // Jump backwards until CLK=0 for write cycles. READY ignored
                      (opcode_jump_cond==4'h4 && rdwr_n_int_d1==1'b1 && (clk0_int_d2==1'b1 || ready_int_d3==1'b0))  ? 1'b1 :  // Jump backwards until CLK=0 for read cycles with READY active
                                                                                                                      1'b0 ;


                                                  
// System status      
assign system_status[15:7]  = 'h0;
assign system_status[6]     = add_overflow8;      
assign system_status[5]     = irq_gated;      
assign system_status[4]     = so_asserted;    
assign system_status[3]     = nmi_asserted;   
assign system_status[2]     = 1'b0;   
assign system_status[1]     = 1'b0;
assign system_status[0]     = add_carry8;     


assign flag_n               = register_flags[7];
assign flag_v               = register_flags[6];

assign flag_b               = register_flags[4];
assign flag_d               = register_flags[3];
assign flag_i               = register_flags[2];
assign flag_z               = register_flags[1];
assign flag_c               = register_flags[0];



// Microsequencer ALU Operations
// ------------------------------------------
//     alu0 = NOP
//     alu1 = JUMP
assign alu2 = adder_out;                                // ADD
assign alu3 = operand0 & operand1;                      // AND
assign alu4 = operand0 | operand1;                      // OR
assign alu5 = operand0 ^ operand1;                      // XOR
assign alu6 = { 1'b0 , operand0[15:1] };                // SHR 




// Mux the ALU operations
assign alu_out =  (opcode_type==3'h2) ? alu2 :   
                  (opcode_type==3'h3) ? alu3 :
                  (opcode_type==3'h4) ? alu4 :
                  (opcode_type==3'h5) ? alu5 :
                  (opcode_type==3'h6) ? alu6 :
                                     16'hEEEE;

    
  


// Generate 16-bit full adder 
assign carry[0] = 1'b0;
genvar i;
generate
  for (i=0; i < 16; i=i+1) 
    begin : GEN_ADDER
      assign adder_out[i] =  operand0[i] ^ operand1[i] ^ carry[i];   
      assign carry[i+1]   = (operand0[i] & operand1[i]) | (operand0[i] & carry[i]) | (operand1[i] & carry[i]);  
    end
endgenerate



//------------------------------------------------------------------------------------------  
//
// Microsequencer
//
//------------------------------------------------------------------------------------------

always @(posedge CORE_CLK)
begin : MICROSEQUENCER
   
    clk0_int_d1 <= CLK0;
    clk0_int_d2 <= clk0_int_d1;
    clk0_int_d3 <= clk0_int_d2;
    clk0_int_d4 <= clk0_int_d3;
    
    clk1_out_int <= ~clk0_int_d3;
    clk2_out_int <=  clk0_int_d2;
    
    reset_n_d1 <= RESET_n;
    reset_n_d2 <= reset_n_d1;
        
    ready_int_d1 <= READY;
    ready_int_d2 <= ready_int_d1;
    ready_int_d3 <= ready_int_d2;   
    
    sync_int_d1   <= sync_int;
    rdwr_n_int_d1 <= rdwr_n_int;
    rdwr_n_int_d2 <= rdwr_n_int_d1;
    
    a_out_int <= address_out;
    d_out_int <= data_out;
    
    irq_d1      <= ~IRQ_n;
    data_in_d1  <= D;   
    if (clk0_int_d3==1'b1 && clk0_int_d2==1'b0) // Store data and sample IRQ_n on falling edge of clk
      begin
        data_in_d2 <= data_in_d1;       
        irq_d2 <= irq_d1;
        irq_d3 <= irq_d2;
        irq_d4 <= irq_d3;
      end
  
    irq_gated <= irq_d4 & ~flag_i;              

    if (rdwr_n_int_d1==1'b0 && clk0_int_d4==1'b1)
      begin
        dataout_enable <= 1'b1;
      end
    else if (rdwr_n_int_d2==1'b0 && rdwr_n_int_d1==1'b1)
      begin
        dataout_enable <= 1'b0;
      end
      
    nmi_n_d1 <= NMI_n;
    nmi_n_d2 <= nmi_n_d1;
    nmi_n_d3 <= nmi_n_d2;       
    if (nmi_debounce==1'b1)
      begin
        nmi_asserted <= 1'b0;
      end
    else if (nmi_n_d3==1'b1 && nmi_n_d2==1'b0) // Falling edge of NMI_n
      begin
        nmi_asserted <= 1'b1;
      end

    so_n_d1 <= SO;
    so_n_d2 <=so_n_d1;
    so_n_d3 <=so_n_d2;      
    if (so_debounce==1'b1)
      begin
        so_asserted <= 1'b0;
      end
    else if (so_n_d3==1'b1 && so_n_d2==1'b0) // Falling edge of SO
      begin
        so_asserted <= 1'b1;
      end


    
    // Generate and store flags for addition
    if (stall_pipeline==1'b0 && opcode_type==3'h2)
      begin
        add_carry8      <= carry[8];
        add_overflow8   <= carry[8]  ^ carry[7];             
      end

    
    // Register writeback   
    if (stall_pipeline==1'b0 && opcode_type!=3'h0 && opcode_type!=3'h1) 
      begin       
        alu_last_result <= alu_out[15:0];
        case (opcode_dst_sel)  // synthesis parallel_case
          4'h0 : register_r0     <= alu_out[15:0];
          4'h1 : register_r1     <= alu_out[15:0];
          4'h2 : register_r2     <= alu_out[15:0];
          4'h3 : register_r3     <= alu_out[15:0];
          4'h4 : register_a      <= alu_out[7:0];
          4'h5 : register_x      <= alu_out[7:0];
          4'h6 : register_y      <= alu_out[7:0];
          4'h7 : register_pc     <= alu_out[15:0];
          4'h8 : register_sp     <= alu_out[7:0];
          4'h9 : register_flags  <= { alu_out[7:6] , 2'b11 , alu_out[3:0] };
          4'hA : address_out     <= alu_out[15:0];
          4'hB : data_out        <= alu_out[7:0];
          //4'hC :
          4'hD : system_output   <= alu_out[4:0];
          //4'hE : 
          //4'hF : 
          default :  ;
        endcase
    end

    
    if (reset_n_d2==1'b0)
      begin
        rom_address <= 11'h7D0; // Microcode starts here after reset
        stall_pipeline <= 'h0;
      end
  
    // JUMP Opcode
    else if (stall_pipeline==1'b0 && opcode_type==3'h1 && jump_boolean==1'b1)
      begin
        stall_pipeline <= 1'b1;
          
         // For subroutine CALLs, store next opcode address
        if (opcode_jump_call==1'b1)
          begin
            calling_address[21:0] <= {calling_address[10:0] , rom_address[10:0] };  // Two deep stack for calling addresses
          end           

        case (opcode_jump_src)  // synthesis parallel_case
          3'h0 : rom_address <= opcode_immediate[10:0];
          3'h1 : rom_address <= { 3'b000 , data_in_d2[7:0] }; // Opcode Jump Table
          3'h2 : begin
                   rom_address <= calling_address[10:0];
                   calling_address[10:0] <= calling_address[21:11];
                 end                    
          3'h3 : rom_address <= rom_address - 1'b1;                
          default :  ;
        endcase 
      end
                
    else
      begin
        stall_pipeline <= 1'b0; // Debounce the pipeline stall
        rom_address <= rom_address + 1'b1; 
      end
   
end // MCL65 Microsequencer



 
endmodule // MCL65.v

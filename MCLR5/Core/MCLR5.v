//
//
//  File Name   :  MCLR5.v
//  Author      :  Ted Fried, MicroCore Labs
//  Creation    :  4/27/2018
//  Code Type   :  Synthesizable
//
//------------------------------------------------------------------------
//
//   Description:
//   ============
//   
//  Quad-issue Superscalar Risc V Processor
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
// Revision 1 4/27/18
// Initial revision
//
//
//------------------------------------------------------------------------


module MCLR5
  (  
  input             CORE_CLK,
  input             RST_n,
  
  output [31:0]     LOAD_STORE_ADDRESS,
  output [31:0]     STORE_DATA,
  input  [31:0]     LOAD_DATA,
  output            LOAD_REQ,
  output            STORE_REQ

  );

//------------------------------------------------------------------------

// Internal Signals

reg new_pc_stall = 'h0;
reg alu0_load_req_d = 'h0;
reg alu1_load_req_d = 'h0;
reg alu2_load_req_d = 'h0;
reg alu3_load_req_d = 'h0;
reg [31:0] register_1 = 'h0;
reg [31:0] register_2 = 'h0;
reg [31:0] register_3 = 'h0;
reg [31:0] register_4 = 'h0;
reg [3:0] loadstore_stall = 'h0;
reg [31:0] new_pc = 'h0;
wire alu0_load_req;
wire alu1_load_req;
wire alu2_load_req;
wire alu3_load_req;
wire alu0_store_req;
wire alu1_store_req;
wire alu2_store_req;
wire alu3_store_req;
wire [31:0] i_immediate;
wire [255:0] program_rom_data;
wire [31:0] new_pc_plus1;
wire [32:0] alu0_rd;
wire [32:0] alu1_rd;
wire [32:0] alu2_rd;
wire [32:0] alu3_rd;
wire [32:0] alu0_newpc;
wire [32:0] alu1_newpc;
wire [32:0] alu2_newpc;
wire [32:0] alu3_newpc;
wire [31:0] alu0_opcode;
wire [31:0] alu1_opcode;
wire [31:0] alu2_opcode;
wire [31:0] alu3_opcode;
wire [31:0] alu0_pc;
wire [31:0] alu1_pc;
wire [31:0] alu2_pc;
wire [31:0] alu3_pc;
wire [31:0] alu0_rs1;
wire [31:0] alu1_rs1;
wire [31:0] alu2_rs1;
wire [31:0] alu3_rs1;
wire [31:0] alu0_rs2;
wire [31:0] alu1_rs2;
wire [31:0] alu2_rs2;
wire [31:0] alu3_rs2;
wire [31:0] alu0_load_store_address;
wire [31:0] alu0_store_data;
wire [31:0] alu0_load_data;
wire [4:0]  alu0_opcode_rs1;
wire [4:0]  alu1_opcode_rs1;
wire [4:0]  alu2_opcode_rs1;
wire [4:0]  alu3_opcode_rs1;
wire [4:0]  alu0_opcode_rs2;
wire [4:0]  alu1_opcode_rs2;
wire [4:0]  alu2_opcode_rs2;
wire [4:0]  alu3_opcode_rs2;
wire [4:0]  alu0_opcode_rd;
wire [4:0]  alu1_opcode_rd;
wire [4:0]  alu2_opcode_rd;
wire [4:0]  alu3_opcode_rd;





/*
// For Xilinx FPGAs 
DPROM_8Kx128    code_rom             
  (
    .clka       (CORE_CLK),
    .addra      (new_pc[14:2]),
    .douta      (program_rom_data[127:0]),

    .clkb       (CORE_CLK),
    .addrb      (new_pc_plus1[14:2]),
    .doutb      (program_rom_data[255:128])
  );

  */
  
    DPROM_8Kx128 code_rom (
        .address_a (new_pc[14:2]), //   input,   width = 13,  ram_input.address_a
        .address_b (new_pc_plus1[14:2]), //   input,   width = 13,           .address_b
        .clock     (CORE_CLK),     //   input,    width = 1,           .clock
        .q_a       (program_rom_data[127:0]),       //  output,  width = 128, ram_output.q_a
        .q_b       (program_rom_data[255:128])        //  output,  width = 128,           .q_b
    );




    
  
assign new_pc_plus1 = new_pc + 3'h4;


assign alu0_pc = new_pc;
assign alu1_pc = new_pc + 1;
assign alu2_pc = new_pc + 2;
assign alu3_pc = new_pc + 3;
  


assign alu0_opcode = (new_pc[1:0]==2'h0) ? program_rom_data[31:0]   :
                     (new_pc[1:0]==2'h1) ? program_rom_data[63:32]  :
                     (new_pc[1:0]==2'h2) ? program_rom_data[95:64]  :
                                           program_rom_data[127:96] ;
  

assign alu1_opcode = (new_pc[1:0]==2'h0) ? program_rom_data[63:32]   :
                     (new_pc[1:0]==2'h1) ? program_rom_data[95:64]   :
                     (new_pc[1:0]==2'h2) ? program_rom_data[127:96]  :
                                           program_rom_data[159:128] ;
    
assign alu2_opcode = (new_pc[1:0]==2'h0) ? program_rom_data[95:64]   :
                     (new_pc[1:0]==2'h1) ? program_rom_data[127:96]  :
                     (new_pc[1:0]==2'h2) ? program_rom_data[159:128] :
                                           program_rom_data[191:160] ;
                                    
assign alu3_opcode = (new_pc[1:0]==2'h0) ? program_rom_data[127:96]  :
                     (new_pc[1:0]==2'h1) ? program_rom_data[159:128] :
                     (new_pc[1:0]==2'h2) ? program_rom_data[191:160] :
                                           program_rom_data[223:192] ;
                                        
                                        

// Register decodes from the opcode
//
assign alu0_opcode_rs1 = alu0_opcode[19:15];  
assign alu0_opcode_rs2 = alu0_opcode[24:20];
assign alu0_opcode_rd  = alu0_opcode[11:7];

assign alu1_opcode_rs1 = alu1_opcode[19:15];  
assign alu1_opcode_rs2 = alu1_opcode[24:20];
assign alu1_opcode_rd  = alu1_opcode[11:7];

assign alu2_opcode_rs1 = alu2_opcode[19:15];  
assign alu2_opcode_rs2 = alu2_opcode[24:20];
assign alu2_opcode_rd  = alu2_opcode[11:7];

assign alu3_opcode_rs1 = alu3_opcode[19:15];  
assign alu3_opcode_rs2 = alu3_opcode[24:20];
assign alu3_opcode_rd  = alu3_opcode[11:7];


assign LOAD_STORE_ADDRESS = alu0_load_store_address;
assign STORE_DATA = alu0_store_data;
assign alu0_load_data = LOAD_DATA;
assign LOAD_REQ = alu0_load_req;
assign STORE_REQ = alu0_store_req;

  

// Register read-port routing
// If the previous alu has modified a register that this alu needs, then use this value,
// otherwise take the register from the main register-file.
//

assign alu0_rs1 = (alu0_opcode_rs1 == 5'h00) ? 32'h0      :
                  (alu0_opcode_rs1 == 5'h01) ? register_1 :
                  (alu0_opcode_rs1 == 5'h02) ? register_2 :
                  (alu0_opcode_rs1 == 5'h03) ? register_3 :
                                               register_4 ;



assign alu0_rs2 = (alu0_opcode_rs2 == 5'h00) ? 32'h0      :
                  (alu0_opcode_rs2 == 5'h01) ? register_1 :
                  (alu0_opcode_rs2 == 5'h02) ? register_2 :
                  (alu0_opcode_rs2 == 5'h03) ? register_3 :
                                               register_4 ;

                                                  
//------------------------------------------------------------------------
                                                  
                                                  
assign alu1_rs1 = ( alu0_rd[32]==1'b1 && (alu1_opcode_rs1==alu0_opcode_rd) ) ? alu0_rd[31:0] :
                  (alu1_opcode_rs1 == 5'h00) ? 32'h0      :
                  (alu1_opcode_rs1 == 5'h01) ? register_1 :
                  (alu1_opcode_rs1 == 5'h02) ? register_2 :
                  (alu1_opcode_rs1 == 5'h03) ? register_3 :
                                               register_4 ;
                  
                                                              
                                                  
assign alu1_rs2 = ( alu0_rd[32]==1'b1 && (alu1_opcode_rs2==alu0_opcode_rd) ) ? alu0_rd[31:0]  :
                  (alu1_opcode_rs2 == 5'h00) ? 32'h0      :
                  (alu1_opcode_rs2 == 5'h01) ? register_1 :
                  (alu1_opcode_rs2 == 5'h02) ? register_2 :
                  (alu1_opcode_rs2 == 5'h03) ? register_3 :
                                               register_4 ;
                  
//------------------------------------------------------------------------
                                                  
                                                  
assign alu2_rs1 = ( alu1_rd[32]==1'b1 && (alu2_opcode_rs1==alu1_opcode_rd) ) ? alu1_rd[31:0]  :
                  ( alu0_rd[32]==1'b1 && (alu2_opcode_rs1==alu0_opcode_rd) ) ? alu0_rd[31:0]  :
                  (alu2_opcode_rs1 == 5'h00) ? 32'h0      :
                  (alu2_opcode_rs1 == 5'h01) ? register_1 :
                  (alu2_opcode_rs1 == 5'h02) ? register_2 :
                  (alu2_opcode_rs1 == 5'h03) ? register_3 :
                                               register_4 ;
                  
                                                              
                                                  
                                                  
assign alu2_rs2 = ( alu1_rd[32]==1'b1 && (alu2_opcode_rs2==alu1_opcode_rd) ) ? alu1_rd[31:0]  :
                  ( alu0_rd[32]==1'b1 && (alu2_opcode_rs2==alu0_opcode_rd) ) ? alu0_rd[31:0]  :
                  (alu2_opcode_rs2 == 5'h00) ? 32'h0      :
                  (alu2_opcode_rs2 == 5'h01) ? register_1 :
                  (alu2_opcode_rs2 == 5'h02) ? register_2 :
                  (alu2_opcode_rs2 == 5'h03) ? register_3 :
                                               register_4 ;
                              
//------------------------------------------------------------------------
                                                  
                                                  
assign alu3_rs1 = ( alu2_rd[32]==1'b1 && (alu3_opcode_rs1==alu2_opcode_rd) ) ? alu2_rd[31:0]  :
                  ( alu1_rd[32]==1'b1 && (alu3_opcode_rs1==alu1_opcode_rd) ) ? alu1_rd[31:0]  :
                  ( alu0_rd[32]==1'b1 && (alu3_opcode_rs1==alu0_opcode_rd) ) ? alu0_rd[31:0]  :
                  (alu3_opcode_rs1 == 5'h00) ? 32'h0      :
                  (alu3_opcode_rs1 == 5'h01) ? register_1 :
                  (alu3_opcode_rs1 == 5'h02) ? register_2 :
                  (alu3_opcode_rs1 == 5'h03) ? register_3 :
                                               register_4 ;
                  
                                                              
                                                  
                                                  
assign alu3_rs2 = ( alu2_rd[32]==1'b1 && (alu3_opcode_rs2==alu2_opcode_rd) ) ? alu2_rd[31:0]  :
                  ( alu1_rd[32]==1'b1 && (alu3_opcode_rs2==alu1_opcode_rd) ) ? alu1_rd[31:0]  :
                  ( alu0_rd[32]==1'b1 && (alu3_opcode_rs2==alu0_opcode_rd) ) ? alu0_rd[31:0]  :
                  (alu3_opcode_rs2 == 5'h00) ? 32'h0      :
                  (alu3_opcode_rs2 == 5'h01) ? register_1 :
                  (alu3_opcode_rs2 == 5'h02) ? register_2 :
                  (alu3_opcode_rs2 == 5'h03) ? register_3 :
                                               register_4 ;
                  
                                            

    
//------------------------------------------------------------------------------------------  
//
// Register writebacks
//
//------------------------------------------------------------------------------------------

always @(posedge CORE_CLK or negedge RST_n)
begin : REGISTER_WRITEBACKS

  if (RST_n==1'b0)
    begin
      alu0_load_req_d <= 'h0;
      new_pc <= 32'hFFFF_FFFC;
    end
    
else    
  begin     
         
   if (  (loadstore_stall == 4'b0000 && (alu0_load_req==1'b1 || alu0_store_req==1'b1) ) ||
         (loadstore_stall == 4'b0000 && (alu1_load_req==1'b1 || alu1_store_req==1'b1) ) ||
         (loadstore_stall == 4'b0000 && (alu2_load_req==1'b1 || alu2_store_req==1'b1) ) ||
         (loadstore_stall == 4'b0000 && (alu3_load_req==1'b1 || alu3_store_req==1'b1) ) )        
      begin
        loadstore_stall <= 4'b1111; // new_pc_stall for three cycles
      end
    else
      begin
        loadstore_stall <= { 1'b0 , loadstore_stall[3:1] };
      end

      
      
  // Writeback register file
  // Only write back registers that have been updated.
  // Block register updates if a previous alu is taking a branch
  //
  if (new_pc_stall==1'b0 && ((loadstore_stall==4'b0001 || alu0_newpc[32]==1'b0) && alu1_newpc[32]==1'b0 && alu2_newpc[32]==1'b0) && alu3_rd[32]==1'b1)
    begin
      case (alu3_opcode_rd)
        5'h01 : register_1 <= alu3_rd[31:0];
        5'h02 : register_2 <= alu3_rd[31:0];
        5'h03 : register_3 <= alu3_rd[31:0];
        5'h04 : register_4 <= alu3_rd[31:0];
        default: ;
      endcase
    end
    
  else if (new_pc_stall==1'b0 && ((loadstore_stall==4'b0001 || alu0_newpc[32]==1'b0) && alu1_newpc[32]==1'b0) && alu2_rd[32]==1'b1)
    begin
      case (alu2_opcode_rd)
        5'h01 : register_1 <= alu2_rd[31:0];
        5'h02 : register_2 <= alu2_rd[31:0];
        5'h03 : register_3 <= alu2_rd[31:0];
        5'h04 : register_4 <= alu2_rd[31:0];
        default: ;
      endcase
    end

  else if (new_pc_stall==1'b0 && (loadstore_stall==4'b0001 || alu0_newpc[32]==1'b0) && alu1_rd[32]==1'b1)
    begin
      case (alu1_opcode_rd)
        5'h01 : register_1 <= alu1_rd[31:0];
        5'h02 : register_2 <= alu1_rd[31:0];
        5'h03 : register_3 <= alu1_rd[31:0];
        5'h04 : register_4 <= alu1_rd[31:0];
        default: ;
      endcase
    end
    
  else if (new_pc_stall==1'b0 && alu0_rd[32]==1'b1)
    begin
      case (alu0_opcode_rd)
        5'h01 : register_1 <= alu0_rd[31:0];
        5'h02 : register_2 <= alu0_rd[31:0];
        5'h03 : register_3 <= alu0_rd[31:0];
        5'h04 : register_4 <= alu0_rd[31:0];
        default: ;
      endcase
    end
  
  
//------------------------------------------------------------------------
//
// Update the PC for branches/jumps
// Otherwise increment the PC by four
//
//------------------------------------------------------------------------

  if ((new_pc_stall==1'b0 && alu0_newpc[32]==1'b1) && loadstore_stall!=4'b0001)
    begin
      new_pc_stall <= 1'b1;
      new_pc <= alu0_newpc[31:0];
    end
    
  else if (new_pc_stall==1'b0 && alu1_newpc[32]==1'b1)
    begin
      new_pc_stall <= 1'b1;
      new_pc <= alu1_newpc[31:0];
    end
    
  else if (new_pc_stall==1'b0 && alu2_newpc[32]==1'b1)
    begin
      new_pc_stall <= 1'b1;
      new_pc <= alu2_newpc[31:0];
    end
    
  else if (new_pc_stall==1'b0 && alu3_newpc[32]==1'b1)
    begin
      new_pc_stall <= 1'b1;
      new_pc <= alu3_newpc[31:0];
    end
    
  else
    begin   
      new_pc <= new_pc + 32'h0000_0004;
      new_pc_stall <= 1'b0;
    end
   
  end
end // Register writebacks



//------------------------------------------------------------------------
//
// MCLR5 ALU cores
//
//------------------------------------------------------------------------

MCLR5_alu                   mclr5_alu0
  (
    .OPCODE                 (alu0_opcode),
    .PC                     (alu0_pc),
    .RS1                    (alu0_rs1),
    .RS2                    (alu0_rs2),
    .RD                     (alu0_rd),
    .NEWPC                  (alu0_newpc),
    .LOAD_DATA              (alu0_load_data),
    .STORE_DATA             (alu0_store_data),
    .LOAD_REQ               (alu0_load_req),
    .STORE_REQ              (alu0_store_req),
    .LOAD_STORE_ADDRESS     (alu0_load_store_address)
  );


MCLR5_alu                   mclr5_alu1
  (
    .OPCODE                 (alu1_opcode),
    .PC                     (alu1_pc),
    .RS1                    (alu1_rs1),
    .RS2                    (alu1_rs2),
    .RD                     (alu1_rd),
    .NEWPC                  (alu1_newpc),
    .LOAD_DATA              (),
    .STORE_DATA             (),
    .LOAD_REQ               (alu1_load_req),
    .STORE_REQ              (alu1_store_req),
    .LOAD_STORE_ADDRESS     ()
  );


MCLR5_alu                   mclr5_alu2
  (
    .OPCODE                 (alu2_opcode),
    .PC                     (alu2_pc),
    .RS1                    (alu2_rs1),
    .RS2                    (alu2_rs2),
    .RD                     (alu2_rd),
    .NEWPC                  (alu2_newpc),
    .LOAD_DATA              (),
    .STORE_DATA             (),
    .LOAD_REQ               (alu2_load_req),
    .STORE_REQ              (alu2_store_req),
    .LOAD_STORE_ADDRESS     ()
  );



MCLR5_alu                   mclr5_alu3
  (
    .OPCODE                 (alu3_opcode),
    .PC                     (alu3_pc),
    .RS1                    (alu3_rs1),
    .RS2                    (alu3_rs2),
    .RD                     (alu3_rd),
    .NEWPC                  (alu3_newpc),
    .LOAD_DATA              (),
    .STORE_DATA             (),
    .LOAD_REQ               (alu3_load_req),
    .STORE_REQ              (alu3_store_req),
    .LOAD_STORE_ADDRESS     ()
  );


 
endmodule // MCLR5.v

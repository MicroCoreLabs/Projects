//
//
//  File Name   :  biu.v
//  Used on     :  
//  Author      :  Ted Fried, MicroCore Labs
//  Creation    :  3/2/16
//  Code Type   :  Synthesizable
//
//   Description:
//   ============
//   
//  Bus Interface Unit of the MCL86 processor 
//  ported to the Lattice XO2 Breakout Board.
//
// - All segments fixed to CS to save space.
// - UART fixed to 9600 baud
// - UART jumpers must me installed on the XO2 Breakout Board!
//
//------------------------------------------------------------------------
//
// Modification History:
// =====================
//
// Revision 1.0 3/2/16 
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


module biu
  (  
    input               CORE_CLK_INT,           // Core Signals
    input               RESET_n,

    
    input               UART_RX,                // UART
    output              UART_TX,
    output [7:0]        LEDS,
    
    
    input  [15:0]       EU_BIU_COMMAND,         // EU to BIU Signals
    input  [15:0]       EU_BIU_DATAOUT,
    input  [15:0]       EU_REGISTER_R3,
    
    
    output              BIU_DONE,               // BIU to EU Signals
    output [1:0]        BIU_SEGMENT,

    output [7:0]        PFQ_TOP_BYTE,
    output              PFQ_EMPTY,
    output[15:0]        PFQ_ADDR_OUT,

    output [15:0]       BIU_REGISTER_ES,
    output [15:0]       BIU_REGISTER_SS,
    output [15:0]       BIU_REGISTER_CS,
    output [15:0]       BIU_REGISTER_DS,
    output [15:0]       BIU_REGISTER_RM,
    output [15:0]       BIU_REGISTER_REG,
    output [15:0]       BIU_RETURN_DATA
    

  );

//------------------------------------------------------------------------
      

// Internal Signals

reg   biu_done_int;
reg   eu_biu_req_caught;
reg   eu_biu_req_d1;
reg   uart_cs_n;
reg   uart_wr_n;
reg   word_cycle;
reg   biu_ram_wr;
wire  eu_biu_req;
wire  eu_prefix_seg;
reg   pfq_empty;
reg  [15:0] biu_register_cs;
reg  [15:0] biu_register_rm;
reg  [15:0] biu_register_reg;
reg  [15:0] biu_return_data_int;
reg  [15:0] eu_register_r3_d;
reg  [1:0]  io_address;
reg  [15:0] pfq_addr_out;
reg  [3:0]  biu_state;
reg  [15:0] pfq_addr_out_d1;
wire [1:0]  eu_biu_strobe;
wire [1:0]  eu_biu_segment;
wire [4:0]  eu_biu_req_code;
wire [1:0]  eu_qs_out;
wire [1:0]  eu_segment_override_value; 
wire [19:0] code_rom_addr;
reg  [19:0] memory_address;
wire [7:0]  biu_ram_data;
wire [7:0]  uart_dataout;
reg  [7:0]  memory_data;


//------------------------------------------------------------------------
//
// BIU Code/Data RAM.  Lattice XO2 2Kx8 DPRAM
//
// Port-A is for EU x86 user code fetching
// Port-B is for BIU data accesses
//
//------------------------------------------------------------------------                                    

assign code_rom_addr = { biu_register_cs[15:0] , 4'h0 } + pfq_addr_out[15:0] ;

biu_ram         BIU_2Kx8 
  (
    .ResetA     (1'b0),
    .ClockEnA   (1'b1), 
    .ClockA     (CORE_CLK_INT),
    .AddressA   (code_rom_addr[10:0]),
    .DataInA    (8'h0),
    .QA         (PFQ_TOP_BYTE),
    .WrA        (1'b0),

    .ResetB     (1'b0),
    .ClockEnB   (1'b1),
    .ClockB     (CORE_CLK_INT),
    .AddressB   (memory_address[10:0]),
    .DataInB    (memory_data[7:0]),
    .QB         (biu_ram_data[7:0]),
    .WrB        (biu_ram_wr)  
  );

  
  
//------------------------------------------------------------------------
//
// UART - Fixed 9600 baud at 26.6Mhz
//
//------------------------------------------------------------------------                                    
  
uart        BIU_UART (
  
  .CLK      (CORE_CLK_INT),
  .RESET_n  (RESET_n),
  .UART_RX  (UART_RX),
  .UART_TX  (UART_TX),
  .LEDS     (LEDS),
  .ADDRESS  (io_address[1:0]),
  .DATA_IN  (EU_BIU_DATAOUT[7:0]),
  .DATA_OUT (uart_dataout[7:0]),
  .CS_n     (uart_cs_n),
  .WR_n     (uart_wr_n)
  
  );


  
  
//------------------------------------------------------------------------
//
// BIU  Combinationals
//
//------------------------------------------------------------------------



// Outputs to the EU
//
assign BIU_DONE                 = biu_done_int;
assign PFQ_EMPTY                = pfq_empty;
assign PFQ_ADDR_OUT             = pfq_addr_out_d1; 
assign BIU_SEGMENT              = 'h0;
assign BIU_REGISTER_ES          = biu_register_cs;
assign BIU_REGISTER_SS          = biu_register_cs;
assign BIU_REGISTER_CS          = biu_register_cs;
assign BIU_REGISTER_DS          = biu_register_cs;
assign BIU_REGISTER_RM          = biu_register_rm;
assign BIU_REGISTER_REG         = biu_register_reg;
assign BIU_RETURN_DATA          = biu_return_data_int; 



// Input signals from the EU requesting BIU processing.
//  eu_biu_strobe[1:0] are available for only one clock cycle and cause BIU to take immediate action.
//  eu_biu_req stays asserted until the BIU is available to service the request.
//  
assign eu_prefix_seg                   = EU_BIU_COMMAND[14];
assign eu_biu_strobe[1:0]              = EU_BIU_COMMAND[13:12]; // 01=opcode fetch 10=clock load 11=load segment register(eu_biu_req_code has the regiter#)
assign eu_biu_segment[1:0]             = EU_BIU_COMMAND[11:10];
assign eu_biu_req                      = EU_BIU_COMMAND[9];
assign eu_biu_req_code                 = EU_BIU_COMMAND[8:4];
assign eu_qs_out[1:0]                  = EU_BIU_COMMAND[3:2];  // Updated for every opcode fetch using biu_strobe and Jump request using eu_biu_rq
assign eu_segment_override_value[1:0]  = EU_BIU_COMMAND[1:0];



                                                        
//------------------------------------------------------------------------
//
// BIU Controller
//
//------------------------------------------------------------------------
//

always @(posedge CORE_CLK_INT)
begin : BIU_CONTROLLER

  if (RESET_n==1'b0)
    begin
      eu_register_r3_d <= 'h0;
      eu_biu_req_caught <= 'h0;
      biu_register_cs <= 16'hFFFF;
      biu_register_rm <= 'h0;
      biu_register_reg <= 'h0;
      pfq_addr_out <= 'h0;
      biu_done_int <= 'h0;
      eu_biu_req_d1 <= 'h0;
      uart_cs_n <= 1'b1;
      uart_wr_n <= 1'b1;
      biu_return_data_int <= 'h0;
      pfq_empty <= 1'b1;
      memory_address <= 'h0;
      word_cycle <= 'b0;
      io_address <= 'h0;
      biu_state <= 'h0;
      biu_ram_wr <= 1'b0;
    end
    
else    
  begin     

  
    // These signals may be pipelined from zero to one clock.
    // They are currently pipelined by one clock.
    pfq_addr_out_d1 <= pfq_addr_out;

    
    // Register pipelining in and out of the BIU.
    eu_register_r3_d <= EU_REGISTER_R3;     
        
        
    // Capture a bus request from the EU
    eu_biu_req_d1 <= eu_biu_req;
    if (eu_biu_req_d1==1'b0 && eu_biu_req==1'b1)
      begin
        eu_biu_req_caught <= 1'b1;
      end
    else if (biu_done_int==1'b1)
      begin
        eu_biu_req_caught <= 1'b0;
      end
                    
    
    // Strobe from EU to update the segment and addressing registers
    // To save logic, all segments will echo the CS.
    if (eu_biu_strobe==2'b11)
      begin
        case (eu_biu_req_code[2:0])  // synthesis parallel_case
          3'h2 : biu_register_cs      <= EU_BIU_DATAOUT[15:0];
          3'h4 : biu_register_rm      <= EU_BIU_DATAOUT[15:0];
          3'h5 : biu_register_reg     <= EU_BIU_DATAOUT[15:0];
          default :  ;
        endcase
      end   
      

    // Prefetch Queue 
    // --------------
    // Not actually a queue for this implementation.
    // Increment the output address of the queue upon EU fetch request strobe.
    // Reset the address when the EU asserts the Jump request.
    // Data is ready when pfq_empty is a zero to adjust for RAM pipelining.
    //---------------------------------------------------------------------------------
    if (eu_biu_req_caught==1'b1 && eu_biu_req_code==5'h19) 
      begin
        pfq_addr_out <= eu_register_r3_d; // Update the prefetch queue to the new address.
        pfq_empty <= 1'b1;
      end    
    else if (eu_biu_strobe==2'b01)
      begin  
        pfq_addr_out <= pfq_addr_out + 1;  // Increment the current IP - Instruction Pointer.
        pfq_empty <= 1'b1;              
      end        
    else
      begin
        pfq_empty <= 1'b0; // Give ROM time to respond.
      end
  
            
    // BIU State Machine        
    biu_state <= biu_state + 1'b1;
    case (biu_state) // synthesis parallel_case
      
      8'h00 : begin
      
                io_address[1:0] <= eu_register_r3_d[1:0];
                memory_address <= { biu_register_cs[15:0] , 4'h0 } + eu_register_r3_d[15:0];
                memory_data <= EU_BIU_DATAOUT[7:0];
                

                if (eu_biu_req_caught==1'b1)
                  begin                 
                        
                    case (eu_biu_req_code)  // synthesis parallel_case
                                        

                      // IO Byte Read 
                      8'h08 : begin
                                uart_cs_n <= 1'b0;
                                biu_state <= 4'h1;
                              end
                                                
                      // IO Byte Write 
                      8'h0A : begin
                                uart_cs_n <= 1'b0;
                                uart_wr_n <= 1'b0;
                                biu_state <= 4'h4;
                              end
                                                                
            
                      // Memory Byte Read 
                      8'h0C : begin
                                biu_state <= 4'h1;
                              end
                                                
                      // Memory Word Read 
                      8'h10 : begin                             
                                word_cycle <= 1'b1; 
                                biu_state <= 4'h1;
                              end

                              
                      // Memory Word Read from Stack Segment
                      8'h11 : begin
                                word_cycle <= 1'b1; 
                                biu_state <= 4'h1;
                              end
                                                            
                      // Memory Word Write to Stack Segment
                      8'h14 : begin
                                biu_ram_wr <= 1'b1;
                                word_cycle <= 1'b1; 
                                biu_state <= 4'h4;
                              end
                        
                        
                      // Memory Byte Write 
                      8'h0E : begin
                                biu_ram_wr <= 1'b1;
                                biu_state <= 4'h4;
                              end
                                                
                      // Memory Word Write 
                      8'h13 : begin
                                biu_ram_wr <= 1'b1;
                                word_cycle <= 1'b1; 
                                biu_state <= 4'h4;
                              end
                                                
                    
                      // Jump Request
                      8'h19 : begin
                                biu_done_int <= 1'b1;
                                biu_state <= 4'h5;
                              end
                                
                      default : ;             
                    endcase
                  end
                                  
                else
                  begin
                    biu_state <= 4'h0;
                  end
                  
              end

              
              
      // 8-bit processing
      8'h04 : 
              begin 
                uart_cs_n <= 1'b1;
                uart_wr_n <= 1'b1;              
                
                if (uart_cs_n==1'b0)
                  begin
                    biu_return_data_int <= { 8'h00 , uart_dataout[7:0] };
                  end
                else
                  begin
                    biu_return_data_int <= { 8'h00 , biu_ram_data[7:0] };
                  end
                  
                if (word_cycle==1'b1)
                  begin
                    memory_address <= memory_address + 1;
                    memory_data <= EU_BIU_DATAOUT[15:8];
                    biu_state <= 4'h7;
                  end
                else
                  begin
                    biu_ram_wr <= 1'b0;
                    biu_done_int <= 1'b1;
                  end
              end
                    
                    
      // Complete the cycle
      8'h05 : 
              begin 
                biu_done_int <= 1'b0;             
                biu_state <= 4'h0;
              end

              
      // 16-bit processing
      8'h08 : 
              begin 
                biu_return_data_int[15:8] <= biu_ram_data[7:0];                         
                biu_ram_wr <= 1'b0;
                biu_done_int <= 1'b1;
                word_cycle <= 1'b0;
                biu_state <= 4'h5;
              end                
                 
      default : ;             
    endcase



      
end

end

 
endmodule // biu.v
        
        
        
        
        
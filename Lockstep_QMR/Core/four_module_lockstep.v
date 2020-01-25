//
//
//  File Name   :  four_module_lockstep.v
//  Used on     :  
//  Author      :  Ted Fried, MicroCore Labs
//  Creation    :  9/16/16
//  Code Type   :  Synthesizable
//
//   Description:
//   ============
//   
//  
//
//------------------------------------------------------------------------
//
// Modification History:
// =====================
//
// Revision 1.0 9/16/16 
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


module four_module_lockstep
  (  
    input               CORE_CLK,               // Core Signals
    input               RST_n,

    
    input  [3:0]        KILL_MODE,
    input  [3:0]        PB_SWITCH,
    output [3:0]        LEDS,
    output [3:0]        PROBE,
        
    input               UART_RX,                // UART
    output              UART_TX,
    output              SPEAKER
        
  );

//------------------------------------------------------------------------
      

// Internal Signals


reg proxy_wr;
reg proxy_rd;
reg [15:0] proxy_address;
reg [7:0] prody_wr_data;
wire module0_broadcast_ok;
wire module1_broadcast_ok;
wire module2_broadcast_ok;
wire module3_broadcast_ok;
wire timer_wr_strobe;
wire uart_wr_strobe;
wire uart_rd_strobe;
wire core_clk_int;
wire module0_sync;
wire module1_sync;
wire module2_sync;
wire module3_sync;
wire interrupt2;
wire interrupt3;
wire [7:0]  module0_strobe;
wire [7:0]  module1_strobe;
wire [7:0]  module2_strobe;
wire [7:0]  module3_strobe;
wire [7:0]  top_strobe;
wire [15:0] module0_address;
wire [15:0] module1_address;
wire [15:0] module2_address;
wire [15:0] module3_address;
wire [15:0] top_address;
wire [7:0]  module0_data;
wire [7:0]  module1_data;
wire [7:0]  module2_data;
wire [7:0]  module3_data;
wire [7:0]  top_data;
wire [7:0]  proxy_rd_data_int;
wire [7:0]  timer_dataout;
wire [7:0]  uart_dataout;
wire [15:0] module0_ip;
wire [15:0] module1_ip;
wire [15:0] module2_ip;
wire [15:0] module3_ip;


reg [3:0] pbsw_d1;
reg [3:0] pbsw_d2;
reg [3:0] pbsw_d3;
reg [3:0] pbsw_d4;
reg [3:0] pbsw_d5;

reg rst_n_d1;
reg rst_n_d2;
reg rst_n_d3;
reg rst_n_d4;

reg [3:0] kmode_d1;
reg [3:0] kmode_d2;
reg [3:0] kmode_d3;
reg [3:0] kmode_d4;

reg kill0;
reg kill1;
reg kill2;
reg kill3;

wire core_clk_locked;

reg   speaker_int_d1;
reg   speaker_int_d2;
reg   speaker_int_d3;
wire  speaker_int;


assign core_clk_int = CORE_CLK;



assign LEDS[3]  = ~module3_broadcast_ok;
assign LEDS[2]  = ~module2_broadcast_ok;
assign LEDS[1]  = ~module1_broadcast_ok;
assign LEDS[0]  = ~module0_broadcast_ok;

assign PROBE[3] = ~module3_broadcast_ok;
assign PROBE[2] = ~module2_broadcast_ok;
assign PROBE[1] = ~module1_broadcast_ok;
assign PROBE[0] = ~module0_broadcast_ok;

assign SPEAKER = speaker_int_d3;


always @(posedge core_clk_int)
begin : BUTTON_DEBOUNCE

  speaker_int_d1 <= speaker_int;
  speaker_int_d2 <= speaker_int_d1;
  speaker_int_d3 <= speaker_int_d2;

  rst_n_d1 <= RST_n;
  rst_n_d2 <= rst_n_d1;
  rst_n_d3 <= rst_n_d2;
  rst_n_d4 <= rst_n_d3;
  
  pbsw_d1 <= PB_SWITCH;
  pbsw_d2 <= pbsw_d1;
  pbsw_d3 <= pbsw_d2;
  pbsw_d4 <= pbsw_d3;
  pbsw_d5 <= pbsw_d4;  
  
  kmode_d1 <= KILL_MODE;
  kmode_d2 <= kmode_d1;
  kmode_d3 <= kmode_d2;
  kmode_d4 <= kmode_d3;
  
       if (pbsw_d5[3]==1'b1 && pbsw_d4[3]==1'b1 && pbsw_d3[3]==1'b1 && pbsw_d2[3]==1'b1)  begin  kill3 <= 1'b1;  end
  else if (pbsw_d5[3]==1'b0 && pbsw_d4[3]==1'b0 && pbsw_d3[3]==1'b0 && pbsw_d2[3]==1'b0)  begin  kill3 <= 1'b0;  end 
                                                                               
       if (pbsw_d5[2]==1'b1 && pbsw_d4[2]==1'b1 && pbsw_d3[2]==1'b1 && pbsw_d2[2]==1'b1)  begin  kill2 <= 1'b1;  end
  else if (pbsw_d5[2]==1'b0 && pbsw_d4[2]==1'b0 && pbsw_d3[2]==1'b0 && pbsw_d2[2]==1'b0)  begin  kill2 <= 1'b0;  end 
                                                                               
       if (pbsw_d5[1]==1'b1 && pbsw_d4[1]==1'b1 && pbsw_d3[1]==1'b1 && pbsw_d2[1]==1'b1)  begin  kill1 <= 1'b1;  end
  else if (pbsw_d5[1]==1'b0 && pbsw_d4[1]==1'b0 && pbsw_d3[1]==1'b0 && pbsw_d2[1]==1'b0)  begin  kill1 <= 1'b0;  end 
                                                                               
       if (pbsw_d5[0]==1'b1 && pbsw_d4[0]==1'b1 && pbsw_d3[0]==1'b1 && pbsw_d2[0]==1'b1)  begin  kill0 <= 1'b1;  end
  else if (pbsw_d5[0]==1'b0 && pbsw_d4[0]==1'b0 && pbsw_d3[0]==1'b0 && pbsw_d2[0]==1'b0)  begin  kill0 <= 1'b0;  end 


  
 end // BIU Controller

 

    
//------------------------------------------------------------------------
//
// Lockstep Modules
//
//------------------------------------------------------------------------                                    
                                                         
module_block                    MODULE0
  (
    .CORE_CLK                   (core_clk_int),
    .RST_n                      (rst_n_d4),
    .KILL                       (kill0),
    .KILL_MODE                  (kmode_d4),
    .MODULE_ID                  (2'h0),
        
    .BROADCAST_OK               (module0_broadcast_ok),
    .BROADCAST_STROBE           (module0_strobe),
    .BROADCAST_ADDRESS          (module0_address),
    .BROADCAST_DATA             (module0_data),
    .BROADCAST_IP               (module0_ip),
    .BROADCAST_SYNC             (module0_sync),
    .BROADCAST_IDSBL            (module0_idsbl),

    .BROADCAST_OK_IN0           (module1_broadcast_ok),
    .BROADCAST_STROBE_IN0       (module1_strobe),
    .BROADCAST_ADDRESS_IN0      (module1_address),
    .BROADCAST_DATA_IN0         (module1_data),
    .BROADCAST_IP_IN0           (module1_ip),
    .BROADCAST_SYNC_IN0         (module1_sync),
    .BROADCAST_IDSBL_IN0        (module1_idsbl),
    
    .BROADCAST_OK_IN1           (module2_broadcast_ok),
    .BROADCAST_STROBE_IN1       (module2_strobe),
    .BROADCAST_ADDRESS_IN1      (module2_address),
    .BROADCAST_DATA_IN1         (module2_data),
    .BROADCAST_IP_IN1           (module2_ip),
    .BROADCAST_SYNC_IN1         (module2_sync),
    .BROADCAST_IDSBL_IN1        (module2_idsbl),

    .BROADCAST_OK_IN2           (module3_broadcast_ok),
    .BROADCAST_STROBE_IN2       (module3_strobe),
    .BROADCAST_ADDRESS_IN2      (module3_address),
    .BROADCAST_DATA_IN2         (module3_data),
    .BROADCAST_IP_IN2           (module3_ip),
    .BROADCAST_SYNC_IN2         (module3_sync),
    .BROADCAST_IDSBL_IN2        (module3_idsbl),

    . INT2                      (interrupt2),
    . INT3                      (interrupt3),

    .PROXY_RD_DATA              (proxy_rd_data_int)

  );    

                                                             
module_block                    MODULE1
  (
    .CORE_CLK                   (core_clk_int),
    .RST_n                      (rst_n_d4),
    .KILL                       (kill1),
    .KILL_MODE                  (kmode_d4),
    .MODULE_ID                  (2'h1),
        
    .BROADCAST_OK               (module1_broadcast_ok),
    .BROADCAST_STROBE           (module1_strobe),
    .BROADCAST_ADDRESS          (module1_address),
    .BROADCAST_DATA             (module1_data),
    .BROADCAST_IP               (module1_ip),
    .BROADCAST_SYNC             (module1_sync),
    .BROADCAST_IDSBL            (module1_idsbl),

    .BROADCAST_OK_IN0           (module2_broadcast_ok),
    .BROADCAST_STROBE_IN0       (module2_strobe),
    .BROADCAST_ADDRESS_IN0      (module2_address),
    .BROADCAST_DATA_IN0         (module2_data),
    .BROADCAST_IP_IN0           (module2_ip),
    .BROADCAST_SYNC_IN0         (module2_sync),
    .BROADCAST_IDSBL_IN0        (module2_idsbl),
    
    .BROADCAST_OK_IN1           (module3_broadcast_ok),
    .BROADCAST_STROBE_IN1       (module3_strobe),
    .BROADCAST_ADDRESS_IN1      (module3_address),
    .BROADCAST_DATA_IN1         (module3_data),
    .BROADCAST_IP_IN1           (module3_ip),
    .BROADCAST_SYNC_IN1         (module3_sync),
    .BROADCAST_IDSBL_IN1        (module3_idsbl),

    .BROADCAST_OK_IN2           (module0_broadcast_ok),
    .BROADCAST_STROBE_IN2       (module0_strobe),
    .BROADCAST_ADDRESS_IN2      (module0_address),
    .BROADCAST_DATA_IN2         (module0_data),
    .BROADCAST_IP_IN2           (module0_ip),
    .BROADCAST_SYNC_IN2         (module0_sync),
    .BROADCAST_IDSBL_IN2        (module0_idsbl),

    . INT2                      (interrupt2),
    . INT3                      (interrupt3),

    .PROXY_RD_DATA              (proxy_rd_data_int)

  );    

                                                             
module_block                    MODULE2
  (
    .CORE_CLK                   (core_clk_int),
    .RST_n                      (rst_n_d4),
    .KILL                       (kill2),
    .KILL_MODE                  (kmode_d4),
    .MODULE_ID                  (2'h2),
        
    .BROADCAST_OK               (module2_broadcast_ok),
    .BROADCAST_STROBE           (module2_strobe),
    .BROADCAST_ADDRESS          (module2_address),
    .BROADCAST_DATA             (module2_data),
    .BROADCAST_IP               (module2_ip),
    .BROADCAST_SYNC             (module2_sync),
    .BROADCAST_IDSBL            (module2_idsbl),

    .BROADCAST_OK_IN0           (module3_broadcast_ok),
    .BROADCAST_STROBE_IN0       (module3_strobe),
    .BROADCAST_ADDRESS_IN0      (module3_address),
    .BROADCAST_DATA_IN0         (module3_data),
    .BROADCAST_IP_IN0           (module3_ip),
    .BROADCAST_SYNC_IN0         (module3_sync),
    .BROADCAST_IDSBL_IN0        (module3_idsbl),
    
    .BROADCAST_OK_IN1           (module0_broadcast_ok),
    .BROADCAST_STROBE_IN1       (module0_strobe),
    .BROADCAST_ADDRESS_IN1      (module0_address),
    .BROADCAST_DATA_IN1         (module0_data),
    .BROADCAST_IP_IN1           (module0_ip),
    .BROADCAST_SYNC_IN1         (module0_sync),
    .BROADCAST_IDSBL_IN1        (module0_idsbl),

    .BROADCAST_OK_IN2           (module1_broadcast_ok),
    .BROADCAST_STROBE_IN2       (module1_strobe),
    .BROADCAST_ADDRESS_IN2      (module1_address),
    .BROADCAST_DATA_IN2         (module1_data),
    .BROADCAST_IP_IN2           (module1_ip),
    .BROADCAST_SYNC_IN2         (module1_sync),
    .BROADCAST_IDSBL_IN2        (module1_idsbl),

    . INT2                      (interrupt2),
    . INT3                      (interrupt3),

    .PROXY_RD_DATA              (proxy_rd_data_int)

  );    

                                                             
module_block                    MODULE3
  (
    .CORE_CLK                   (core_clk_int),
    .RST_n                      (rst_n_d4),
    .KILL                       (kill3),
    .KILL_MODE                  (kmode_d4),
    .MODULE_ID                  (2'h3),
        
    .BROADCAST_OK               (module3_broadcast_ok),
    .BROADCAST_STROBE           (module3_strobe),
    .BROADCAST_ADDRESS          (module3_address),
    .BROADCAST_DATA             (module3_data),
    .BROADCAST_IP               (module3_ip),
    .BROADCAST_SYNC             (module3_sync),
    .BROADCAST_IDSBL            (module3_idsbl),

    .BROADCAST_OK_IN0           (module0_broadcast_ok),
    .BROADCAST_STROBE_IN0       (module0_strobe),
    .BROADCAST_ADDRESS_IN0      (module0_address),
    .BROADCAST_DATA_IN0         (module0_data),
    .BROADCAST_IP_IN0           (module0_ip),
    .BROADCAST_SYNC_IN0         (module0_sync),
    .BROADCAST_IDSBL_IN0        (module0_idsbl),
    
    .BROADCAST_OK_IN1           (module1_broadcast_ok),
    .BROADCAST_STROBE_IN1       (module1_strobe),
    .BROADCAST_ADDRESS_IN1      (module1_address),
    .BROADCAST_DATA_IN1         (module1_data),
    .BROADCAST_IP_IN1           (module1_ip),
    .BROADCAST_SYNC_IN1         (module1_sync),
    .BROADCAST_IDSBL_IN1        (module1_idsbl),

    .BROADCAST_OK_IN2           (module2_broadcast_ok),
    .BROADCAST_STROBE_IN2       (module2_strobe),
    .BROADCAST_ADDRESS_IN2      (module2_address),
    .BROADCAST_DATA_IN2         (module2_data),
    .BROADCAST_IP_IN2           (module2_ip),
    .BROADCAST_SYNC_IN2         (module2_sync),
    .BROADCAST_IDSBL_IN2        (module2_idsbl),

    . INT2                      (interrupt2),
    . INT3                      (interrupt3),

    .PROXY_RD_DATA              (proxy_rd_data_int)

  );    

  
  
//------------------------------------------------------------------------                                    
  
// Fixed-priority arbiter that chooses which 
// core's outputs to direct to the peripherals.
//  

assign top_strobe  = (module0_broadcast_ok==1'b1) ? module0_strobe :
                     (module1_broadcast_ok==1'b1) ? module1_strobe : 
                     (module2_broadcast_ok==1'b1) ? module2_strobe : 
                     (module3_broadcast_ok==1'b1) ? module3_strobe : 
                                                    8'hEE;
                    

assign top_address = (module0_broadcast_ok==1'b1) ? module0_address :
                     (module1_broadcast_ok==1'b1) ? module1_address : 
                     (module2_broadcast_ok==1'b1) ? module2_address : 
                     (module3_broadcast_ok==1'b1) ? module3_address : 
                                                    16'hEEEE;
                    
        

assign top_data    = (module0_broadcast_ok==1'b1) ? module0_data :
                     (module1_broadcast_ok==1'b1) ? module1_data : 
                     (module2_broadcast_ok==1'b1) ? module2_data : 
                     (module3_broadcast_ok==1'b1) ? module3_data : 
                                                    8'hEE;
                    


    
//------------------------------------------------------------------------
//
// Proxy addressing for peripherals 
//
// This code mirrors the module accesses to the proxy addressing 
// registers and buffers them to the peripherals.
//
//------------------------------------------------------------------------


always @(posedge core_clk_int)
begin : PROXY_ADDRESSING

  if (rst_n_d4==1'b0)
    begin
      proxy_wr <= 'h0;
      proxy_rd <= 'h0;
      proxy_address <= 'h0;
      prody_wr_data <= 'h0;
    end
    
  else    
    begin     
    
      if (top_strobe[7:0]==8'h11 && top_address[15:0]==16'h00C1)
        begin
          proxy_wr <= 1'b1;
          prody_wr_data <= top_data;
        end
      else
        begin
          proxy_wr <= 1'b0;
        end
            
      if (top_strobe[7:0]==8'h11 && top_address[15:0]==16'h00C2)
        begin
          proxy_rd <= 1'b1;
          proxy_address <= top_data;
        end
      else
        begin
          proxy_rd <= 1'b0;
        end
    end
end 
     

        
//------------------------------------------------------------------------
//------------------------------------------------------------------------
//
// Peripherals accessed with proxy addressing  
//
// BIU SFR  proxy_address  - 0xC2  = Address[7:0]
//          proxy_wr_data  - 0xC1  = Write Data and strobe to the peripherals
//          proxy_rd_data  - 0xC0  = Read Data from the peripherals
//
//
//
//------------------------------------------------------------------------
//

// Steer the peripheral read data back to the modules
//
assign proxy_rd_data_int  = (proxy_address[7:4]==4'h0) ? timer_dataout  :
                            (proxy_address[7:4]==4'h1) ? uart_dataout   :
                                                         8'hEE          ;
                                            
// Gate the peripheral read and write strobes
assign  timer_wr_strobe = (proxy_address[7:4]==4'h0) ? proxy_wr : 1'b0; 
assign  uart_wr_strobe  = (proxy_address[7:4]==4'h1) ? proxy_wr : 1'b0; 
assign  uart_rd_strobe  = (proxy_address[7:4]==4'h1) ? proxy_rd : 1'b0; 




//------------------------------------------------------------------------
//
// Timer - Dual output 24-bit programmable timer
//
// Timer-0 = Frequency generator
// Timer-1 = Pulse generator
//
//------------------------------------------------------------------------                                    
                                                         
timer                TIMER 
  (
    .CORE_CLK       (core_clk_int),
    .RST_n          (rst_n_d4),
    .ADDRESS        (proxy_address[3:0]),
    .DATA_IN        (prody_wr_data),
    .DATA_OUT       (timer_dataout),
    .STROBE_WR      (timer_wr_strobe),
    .TIMER0_OUT     (speaker_int),
    .TIMER1_OUT     (interrupt2)  
  );
  

          
//------------------------------------------------------------------------
//
// UART - Fixed 9600 baud 
//
//------------------------------------------------------------------------                                    
  
uart                 UART 
  (  
    .CLK            (core_clk_int),
    .RST_n          (rst_n_d4),
    .ADDRESS        (proxy_address[1:0]),
    .DATA_IN        (prody_wr_data),
    .DATA_OUT       (uart_dataout),
    .STROBE_RD      (uart_rd_strobe),
    .STROBE_WR      (uart_wr_strobe),
    .UART_RX        (UART_RX),
    .UART_TX        (UART_TX),
    .UART_INT       (interrupt3)
  );

   
endmodule // four_module_lockstep.v

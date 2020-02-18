//
//
//  File Name   :  uart.v
//  Used on     :  
//  Author      :  Ted Fried, MicroCore Labs
//  Creation    :  3/1/16
//  Code Type   :  Synthesizable
//
//   Description:
//   ============
//   
//  Fixed 9600 baud rate UART
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


module uart
  (  
    input               CLK,
    input               RESET_n,

    
    input               UART_RX,
    output              UART_TX,
    output reg [7:0]    LEDS,
    
    

    input  [1:0]        ADDRESS,
    input  [7:0]        DATA_IN,
    output [7:0]        DATA_OUT,
    input               CS_n,
    input               WR_n
    

  );

//------------------------------------------------------------------------
      

// Internal Signals

reg   RX_STATE;
reg   uart_rx_d;
reg   uart_rx_d1;
reg   uart_rx_d2;
reg   bit_clk;
reg   bit_clk_d;
reg   rx_havebyte;
reg   host_tx_go;
reg   host_tx_go_d;
reg   rx_byte_available;
reg [7:0]  tx_byte;
reg [10:0] tx_count;
reg [10:0] tx_shift_out;
reg [8:0]  rx_byte;
reg [11:0] rx_count;
reg [4:0]  rx_bits;
reg [11:0] prescaler;
wire [1:0] uart_status;

  
//------------------------------------------------------------------------
//
// Combinationals
//
//------------------------------------------------------------------------

assign UART_TX = tx_shift_out[0];

assign DATA_OUT = (ADDRESS==2'h0) ? rx_byte[7:0]  :
                  (ADDRESS==2'h1) ? uart_status   :   
                                    8'hEE;
      
assign uart_status[1] = (tx_count[9:0]==10'b0000000000) ? 1'b0 : 1'b1; // 1=TX_BUSY 
assign uart_status[0] = rx_byte_available;

        
//------------------------------------------------------------------------
//
// UART Controller
//
//------------------------------------------------------------------------

always @(posedge CLK)
begin : STATE_MACHINE

  if (RESET_n==1'b0)
    begin
      RX_STATE <= 'h0;
      uart_rx_d <= 'h0;
      uart_rx_d1 <= 'h0;
      uart_rx_d2 <= 'h0;
      bit_clk <= 'h0;
      bit_clk_d <= 'h0;
      prescaler <= 'h0;
      rx_havebyte <= 'h0;
      rx_count <= 'h0;
      rx_byte <= 9'b1111_1111_1;
      tx_shift_out <= 10'b1111111111;
      tx_count <= 'h0;    
      host_tx_go <= 'h0;
      host_tx_go_d <= 'h0;
      tx_byte <= 8'hFF;
      rx_byte_available <= 'h0;  
      rx_bits <= 'h0;
    end
    
else    
  begin     
                                    
                                    
//------------------------------------------------------------------------
//
// Host interface and prescaler
//
//------------------------------------------------------------------------   
  
// Host
// Address:  0x0 - RO - RX_BYTE - reading clears the RX_HAS_BYTE bit
//           0x1 - RO - UART status  [1]=TX_BUSY  [0]=RX_HAS_BYTE
//           0x2 - WO - TX Byte - Automatically initiates the TX
  


    if (CS_n==1'b0 && WR_n==1'b0 && ADDRESS==2'h2)
      begin
        host_tx_go <= 1'b1;
        tx_byte <= DATA_IN;
      end
    else
      begin
        host_tx_go <= 1'b0;
      end
      
      
    if (rx_havebyte==1'b1)
      begin
        rx_byte_available <= 1'b1;
      end     
    else if (CS_n==1'b0 && ADDRESS==2'h0)
      begin
        rx_byte_available <= 1'b0;
      end

    if (CS_n==1'b0 && WR_n==1'b0 && ADDRESS==2'h3)
      begin
        LEDS <= DATA_IN;
      end

      
    
    if (prescaler[11:0]==12'hAD2)
      begin
        bit_clk <= ~ bit_clk;
        prescaler <= 'h0;
      end
    else
      begin
        prescaler <= prescaler + 1;
      end

    bit_clk_d <= bit_clk;

   
//------------------------------------------------------------------------
//
// RX Controller
//
//------------------------------------------------------------------------


    uart_rx_d <= UART_RX;   
    uart_rx_d1 <= uart_rx_d;
    uart_rx_d2 <= uart_rx_d1;
      
          
    case (RX_STATE) // synthesis parallel_case
      
      1'h0 : begin
               // Debounce signals
               rx_havebyte <= 1'b0;
               rx_bits <= 'h0;
                
               // Look for start bit
               if (uart_rx_d2==1'b0)
                 begin
                   rx_count <= rx_count +1;
                 end
                
               // Count half-way into the start bit
               if (rx_count==12'h569)
                 begin 
                   rx_count <= 'h0;        
                   rx_byte <= 9'b1_11111111;        
                   RX_STATE <= 1'h1;
                 end
             end
        
        
      1'h1 : begin
               rx_count <= rx_count + 1;
               
               // Count complete bit-times
               if (rx_count==12'hAD2)
                 begin
                   rx_byte[8:0] <= { uart_rx_d2 , rx_byte[8:1] };
                   rx_bits <= rx_bits + 1'b1;
                   rx_count <= 'h0;
                 end
                 
               // Complete byte has been shifted in
               if (rx_bits==4'h9)
                 begin
                   rx_havebyte <= 1'b1;
                   RX_STATE <= 1'h0;
                 end
             end
                 
      default : ;             
    endcase

              
   
//------------------------------------------------------------------------
//
// TX Controller
//
//------------------------------------------------------------------------
    
    // Load transmit shifter on rising edge of host request
    host_tx_go_d <= host_tx_go; 
    if (host_tx_go_d==1'b0 && host_tx_go==1'b1)
      begin
        tx_shift_out <= { 1'b1 , tx_byte , 1'b0 , 1'b1 };
        tx_count <= 11'b11111111111;
      end
      
    // Otherwise shift out bits at each bit clock.
    // When tx_count is all zeros tye byte has been sent.
    else
      begin
        if (bit_clk_d != bit_clk)
          begin
            tx_shift_out[10:0] <= { 1'b1 , tx_shift_out[10:1] };
            tx_count[10:0] <= { 1'b0 , tx_count[10:1] };
          end
      end
 
  
  end  
end
  
endmodule

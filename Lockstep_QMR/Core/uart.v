//
//
//  File Name   :  uart.v
//  Used on     :  
//  Author      :  Ted Fried, MicroCore Labs
//  Creation    :  4/30/16
//  Code Type   :  Synthesizable
//
//   Description:
//   ============
//   
//  Fixed 9600 baud rate UART
//
//
//------------------------------------------------------------------------


module uart
  (  
    input				CLK,
    input				RST_n,	
	
    input  [1:0]		ADDRESS,
    input  [7:0]		DATA_IN,
    output [7:0]		DATA_OUT,
    input				STROBE_RD,
    input				STROBE_WR,
	
	input				UART_RX,
    output        		UART_TX,
    output        		UART_INT

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
reg [15:0] prescaler;
wire [1:0] uart_status;

  
//------------------------------------------------------------------------
//
// Combinationals
//
//------------------------------------------------------------------------

assign UART_TX = tx_shift_out[0];

assign UART_INT = rx_byte_available;

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

  if (RST_n==1'b0)
    begin
      RX_STATE <= 'h0;
	  uart_rx_d <= 1'b1;
	  uart_rx_d1 <= 1'b1;
	  uart_rx_d2 <= 1'b1;
	  bit_clk <= 'h0;
	  bit_clk_d <= 'h0;
	  prescaler <= 'h0;
	  rx_havebyte <= 'h0;
	  rx_count <= 'h0;
	  rx_byte <= 9'b1111_1111_1;
	  tx_shift_out <= 11'b111_1111_1111;
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


    
    // Prescaler fixed for 9600 baud - Xilinx 100Mhz   = 16'h28B0
    // Prescaler fixed for 9600 baud - Xilinx 50Mhz    = 16'h1458
    if (prescaler[15:0]==16'h1458)
	  begin
	    bit_clk <= ~ bit_clk;
		prescaler <= 'h0;
      end
	else
	  begin
	    prescaler <= prescaler + 1'b1;
	  end

    bit_clk_d <= bit_clk;

	
    // Address:  0x0 - RO - RX_BYTE - reading clears the RX_HAS_BYTE bit
    //           0x1 - RO - UART status  [1]=TX_BUSY  [0]=RX_HAS_BYTE
    //           0x2 - WO - TX Byte - Sends the TX byte over UART
  

    // Writes to Registers
	if (STROBE_WR==1'b1 && ADDRESS[1:0]==2'h2) 
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
	else if (STROBE_RD==1'b1 && ADDRESS[1:0]==2'h0)
	  begin
	    rx_byte_available <= 1'b0;
      end

	  

   
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
				   rx_count <= rx_count + 1'b1;
				 end
				
			   // Count half-way into the start bit
			   if (rx_count==14'h1458)
				 begin 
				   rx_count <= 'h0;        
				   rx_byte <= 9'b1_11111111;        
				   RX_STATE <= 1'h1;
			     end
			 end
        
		
	  1'h1 : begin
	           rx_count <= rx_count + 1'b1;
			   
			   // Count complete bit-times
			   if (rx_count==14'h28B0)
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

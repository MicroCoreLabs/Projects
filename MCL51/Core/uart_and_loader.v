//
//
//  File Name   :  uart_and_loader.v
//  Used on     :  
//  Author      :  MicroCore Labs
//  Creation    :  5/3/16
//  Code Type   :  Synthesizable
//
//   Description:
//   ============
//   
//  Fixed 9600 baud rate UART
//  Also a Program ROM loader that decodes Intel-Hex format
//
//
// RS232 control characters:
//
// '{' = Put the CPU into RESET and enable the loader
// '}' = Take the CPU out of RESET
//
//
//------------------------------------------------------------------------


module uart_and_loader
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
    output        		UART_INT,
	
    output reg [15:0]	LOADER_ADDR,
    output reg [7:0]	LOADER_DATA,
    output reg     		LOADER_WR,
    output      		RESET_OUT



  );

//------------------------------------------------------------------------
 	  

// Internal Signals

reg   RX_STATE = 'h0;
reg   uart_rx_d = 1'b1;
reg   uart_rx_d1 = 1'b1;
reg   uart_rx_d2 = 1'b1;
reg   bit_clk = 'h0;
reg   bit_clk_d = 'h0;
reg   rx_havebyte = 'h0;
reg   host_tx_go = 'h0;
reg   host_tx_go_d = 'h0;
reg   rx_byte_available = 'h0;
reg   reset_out_int = 'h0;
reg [7:0]  tx_byte = 8'hFF;
reg [10:0] tx_count = 'h0;
reg [10:0] tx_shift_out = 11'b111_1111_1111;
reg [8:0]  rx_byte = 9'b1111_1111_1;
reg [13:0] rx_count = 'h0;
reg [4:0]  rx_bits = 'h0;
reg [13:0] prescaler = 'h0;	 
reg [3:0]  loader_state = 'h0;	  
reg [7:0]  loader_bytes = 'h0;	  
reg [15:0] loader_adder_int = 'h0;	
wire [1:0] uart_status;
wire [3:0] hex_nibble ;


  
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


assign hex_nibble = (rx_byte[6]==1'b0) ? rx_byte[3:0] : rx_byte[3:0] + 4'h9;

assign RESET_OUT = reset_out_int;

		
//------------------------------------------------------------------------
//
// UART Controller
//
//------------------------------------------------------------------------

always @(posedge CLK)
begin : STATE_MACHINE
 
  begin  
  
        							
									
//------------------------------------------------------------------------
//
// Host interface and prescaler
//
//------------------------------------------------------------------------	 


    // Prescaler fixed for 9600 baud - Xilinx 100Mhz    = 14'h28B0
    if (prescaler[13:0]==14'h28B0)
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
			  
   
   
   
//------------------------------------------------------------------------
//
// Program ROM Loader
//
// Snoops the RX line at 9600 baud and decodes Intel-Hex format
//
//------------------------------------------------------------------------
    
// Perform the steps as each byte is received
//
if (rx_havebyte==1'b1)
  begin
  
	// '{' asserts RESET_OUT
    if (rx_byte[7:0] == 8'h7B)
	  begin  
	    reset_out_int <= 1'b1;
      end  
    
	// '}' deasserts RESET_OUT
    if (rx_byte[7:0] == 8'h7D)
	  begin  
	    reset_out_int <= 1'b0;
      end  
  
  
    loader_state <= loader_state + 1'b1;
	 
	case (loader_state)  // synthesis parallel_case
	  
	  
	  // Stay in state-0 until the ':' character is received and RESET_OUT is asserted
	  // 
	  4'h0: begin  
	          if (reset_out_int==1'b1 && rx_byte[7:0] == 8'h3A)
			    begin  
				  loader_state <= 4'h1;  
				end  
			  else
			    begin  
				  loader_state <= 4'h0;  
				end  
		      end
		
		
      // Decode the number of bytes in the Intel-Hex string
	  //
	  4'h1: begin  loader_bytes[7:4] <= hex_nibble;   end
	  4'h2: begin  loader_bytes[3:0] <= hex_nibble;   end
	  				
				
      // Decode the start Address for the following bytes 
	  //
	  4'h3: begin  loader_adder_int[15:12] <= hex_nibble;   end
	  4'h4: begin  loader_adder_int[11:8]  <= hex_nibble;   end
	  4'h5: begin  loader_adder_int[7:4]   <= hex_nibble;   end
	  4'h6: begin  loader_adder_int[3:0]   <= hex_nibble;   end
	  
	  
	  // Ignore the Record Type for now
	  //
	  4'h7: ;
	  4'h8: ;
	  	 
	  
	  // Load bytes and increment the loader address until loader_bytes reaches zero
	  //
	  4'h9: begin  
	          LOADER_WR <= 1'b0;
			  LOADER_ADDR <= loader_adder_int;
	          LOADER_DATA[7:4]   <= hex_nibble;   
			  if (loader_bytes == 8'h00)
			    begin
				  loader_state <= 4'h0;
				end
		    end
				
	  4'hA: begin  
	          LOADER_WR <= 1'b1;
	          LOADER_DATA[3:0]   <= hex_nibble;   
	          loader_adder_int <= loader_adder_int + 1'b1;
			  loader_bytes <= loader_bytes - 1'b1;
			  loader_state <= 4'h9;  
			end 
		  
  	  default :  ;
  	endcase
	  
     end

  
  end  
end
  
endmodule

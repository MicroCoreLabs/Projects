//
//
//  File Name   :  mclwr1.v
//  Author      :  Ted Fried, MicroCore Labs
//  Creation    :  11/3/2019
//  Code Type   :  Synthesizable
//
//   Description:
//   ============
//   
//  FPGA version of the Printer Option for the IBM Wheelwriter
//
//------------------------------------------------------------------------
//
// Version History:
// ================
//
// Revision 1 11/3/19
// Initial revision
//
//
//------------------------------------------------------------------------

`timescale 1ns/100ps



module mclwr1 
  (
    inout               IBM_BUS,
    output              BUFFER_DIR,

    output              UART_TX,
    input               UART_RX,
	
    output              UART_TX2,
    input               UART_RX2,
	
    output[8:0]         SNOOP_OUT
    
   );
          

//------------------------------------------------------------------------


// Internal Signals
reg rx_fifo_wr   = 'h0;
reg rx_fifo_rd   = 'h0;
reg tx_fifo_wr   = 'h0;
reg tx_fifo_rd   = 'h0;
reg ibm_clock    = 'h0;
reg ibm_load_tx  = 'h0;
reg ibm_clock_d  = 'h0;
reg uart_rx_d    = 1'b1;
reg uart_rx_d1   = 1'b1;
reg uart_rx_d2   = 1'b1;
reg uart_clock   = 'h0;
reg uart_clock_d = 'h0;
reg ibm_bus_d    = 1'b1;
reg ibm_bus_d1   = 1'b1;
reg ibm_bus_d2   = 1'b1;
reg rx_fifo_almost_full_d ='h0;
reg [8:0]  uart_prescaler ='h0;
reg [10:0] uart_tx_shiftout = 11'b11111111111;
reg [15:0] rx_count        = 'h0;
reg [7:0]  main_count      = 'h0;
reg [15:0] tx_bytes        = 'h0;
reg [15:0] ibm_count       = 'h0;
reg [7:0]  prescaler       = 'h0;
reg [8:0]  tx_fifo_data_in = 'h0;
reg [9:0]  ibm_shift_out   = 10'b1111111111;
reg [7:0]  uart_rx_byte    = 'h0;
reg [15:0] snoop_count     = 'h0;
reg [8:0]  snoop_byte      = 9'b111111111;
reg [8:0]  snoop_byte_all  = 9'b111111111;
wire clk_int;
wire tx_fifo_full;
wire tx_fifo_empty;
wire rx_fifo_full;
wire rx_fifo_almost_full;
wire rx_fifo_empty;
wire [8:0] rx_fifo_data_out;
wire [8:0] tx_fifo_data_out;
wire [8:0] ibm_byte;

    
//------------------------------------------------------------------------
// OSCH - Internal clock oscillator for Lattice XO2
//------------------------------------------------------------------------

defparam OSCILLATOR_INST.NOM_FREQ = "2.22";
OSCH        OSCILLATOR_INST
  ( 
    .STDBY      (1'b0),
    .OSC        (clk_int),
    .SEDSTDBY   ()              
  );

//------------------------------------------------------------------------
// RX FIFO - Holds 1K characters from the UART
//------------------------------------------------------------------------

rx_fifo         RX_FIFO 
  (
    .Reset      (1'b0 ), 
    .RPReset    (1'b0 ), 

    .WrClock    (clk_int ), 
    .Data       (ibm_byte), 
    .WrEn       (rx_fifo_wr ), 
    .Full       (rx_fifo_full ), 
    .AlmostFull (rx_fifo_almost_full ),
    
    .RdClock    (clk_int ), 
    .Q          (rx_fifo_data_out ), 
    .RdEn       (rx_fifo_rd), 
    .Empty      (rx_fifo_empty ), 
    .AlmostEmpty( )
  );

//------------------------------------------------------------------------
// TX FIFO - Holds 1K commands to be sent to the IBM Wheelwriter
//------------------------------------------------------------------------

rx_fifo         TX_FIFO 
  (
    .Reset      (1'b0 ), 
    .RPReset    (1'b0 ), 

    .WrClock    (clk_int ), 
    .Data       (tx_fifo_data_in ), 
    .WrEn       (tx_fifo_wr ), 
    .Full       ( ), 
    .AlmostFull ( ),
    
    .RdClock    (clk_int ), 
    .Q          (tx_fifo_data_out ), 
    .RdEn       (tx_fifo_rd), 
    .Empty      (tx_fifo_empty ), 
    .AlmostEmpty( )
  );

  
//------------------------------------------------------------------------
//
// Combinationals
//
//------------------------------------------------------------------------

assign SNOOP_OUT = {8'h0 , rx_fifo_full, rx_fifo_almost_full };
//assign SNOOP_OUT = snoop_byte_all;
//assign SNOOP_OUT = rx_fifo_data_out[7:0];
//assign SNOOP_OUT = uart_rx_byte[7:0];

assign UART_TX = uart_tx_shiftout[0];
assign UART_TX2 = uart_tx_shiftout[0];

assign BUFFER_DIR = ~ibm_shift_out[0];
    
assign IBM_BUS = (ibm_shift_out[0]==1'b0) ? 1'b0 : 1'bZ; // open collector

assign ibm_byte =
                  (uart_rx_byte==8'h0D) ? 9'h099 : // Carriage Return
                  
                  (uart_rx_byte==8'h20) ? 9'h000 : // Space
                  (uart_rx_byte==8'h21) ? 9'h049 : // !
                  (uart_rx_byte==8'h22) ? 9'h04b : // "
                  (uart_rx_byte==8'h23) ? 9'h038 : // #
                  (uart_rx_byte==8'h24) ? 9'h037 : // $
                  (uart_rx_byte==8'h25) ? 9'h039 : // %
                  (uart_rx_byte==8'h26) ? 9'h03F : // &
                  (uart_rx_byte==8'h27) ? 9'h04C : // `
                  (uart_rx_byte==8'h28) ? 9'h023 : // (
                  (uart_rx_byte==8'h29) ? 9'h016 : // )
                  (uart_rx_byte==8'h2A) ? 9'h036 : // *
                  (uart_rx_byte==8'h2B) ? 9'h03B : // +
                  (uart_rx_byte==8'h2C) ? 9'h00C : // ,
                  (uart_rx_byte==8'h2D) ? 9'h00E : // -
                  (uart_rx_byte==8'h2E) ? 9'h057 : // .
                  (uart_rx_byte==8'h2F) ? 9'h028 : // /
                  
                  (uart_rx_byte==8'h30) ? 9'h030  : // 0
                  (uart_rx_byte==8'h31) ? 9'h02E  : // 1
                  (uart_rx_byte==8'h32) ? 9'h02F  : // 2
                  (uart_rx_byte==8'h33) ? 9'h02C  : // 3
                  (uart_rx_byte==8'h34) ? 9'h032  : // 4
                  (uart_rx_byte==8'h35) ? 9'h031  : // 5
                  (uart_rx_byte==8'h36) ? 9'h033  : // 6
                  (uart_rx_byte==8'h37) ? 9'h035  : // 7
                  (uart_rx_byte==8'h38) ? 9'h034  : // 8
                  (uart_rx_byte==8'h39) ? 9'h02A  : // 9
                  (uart_rx_byte==8'h3A) ? 9'h04E  : // :
                  (uart_rx_byte==8'h3B) ? 9'h050  : // ;
              //  (uart_rx_byte==8'h3C) ? 9'h000  : // <
                  (uart_rx_byte==8'h3D) ? 9'h04D  : // =
              //  (uart_rx_byte==8'h3E) ? 9'h000  : // >
                  (uart_rx_byte==8'h3F) ? 9'h04A  : // ?
                  
                  (uart_rx_byte==8'h40) ? 9'h03D  : // @
                  (uart_rx_byte==8'h41) ? 9'h020  : // A
                  (uart_rx_byte==8'h42) ? 9'h012  : // B
                  (uart_rx_byte==8'h43) ? 9'h01B  : // C
                  (uart_rx_byte==8'h44) ? 9'h01D  : // D
                  (uart_rx_byte==8'h45) ? 9'h01E  : // E
                  (uart_rx_byte==8'h46) ? 9'h011  : // F
                  (uart_rx_byte==8'h47) ? 9'h00F  : // G
                  (uart_rx_byte==8'h48) ? 9'h014  : // H
                  (uart_rx_byte==8'h49) ? 9'h01F  : // I
                  (uart_rx_byte==8'h4A) ? 9'h021  : // J
                  (uart_rx_byte==8'h4B) ? 9'h02B  : // K
                  (uart_rx_byte==8'h4C) ? 9'h018  : // L
                  (uart_rx_byte==8'h4D) ? 9'h024  : // M
                  (uart_rx_byte==8'h4E) ? 9'h01A  : // N
                  (uart_rx_byte==8'h4F) ? 9'h022  : // O
                  
                  (uart_rx_byte==8'h50) ? 9'h015  : // P
                  (uart_rx_byte==8'h51) ? 9'h03E  : // Q
                  (uart_rx_byte==8'h52) ? 9'h017  : // R
                  (uart_rx_byte==8'h53) ? 9'h019  : // S
                  (uart_rx_byte==8'h54) ? 9'h01C  : // T
                  (uart_rx_byte==8'h55) ? 9'h010  : // U
                  (uart_rx_byte==8'h56) ? 9'h00D  : // V
                  (uart_rx_byte==8'h57) ? 9'h029  : // W
                  (uart_rx_byte==8'h58) ? 9'h02D  : // X
                  (uart_rx_byte==8'h59) ? 9'h026  : // Y
                  (uart_rx_byte==8'h5A) ? 9'h013  : // Z
                  (uart_rx_byte==8'h5B) ? 9'h041  : // [
              //  (uart_rx_byte==8'h5C) ? 9'h000  : // 
                  (uart_rx_byte==8'h5D) ? 9'h040  : // ]
              //  (uart_rx_byte==8'h5E) ? 9'h000  : // ^
                  (uart_rx_byte==8'h5F) ? 9'h04F  : // _
                  
                  (uart_rx_byte==8'h60) ? 9'h000  : // `
                  (uart_rx_byte==8'h61) ? 9'h001  : // a
                  (uart_rx_byte==8'h62) ? 9'h059  : // b
                  (uart_rx_byte==8'h63) ? 9'h005  : // c
                  (uart_rx_byte==8'h64) ? 9'h007  : // d
                  (uart_rx_byte==8'h65) ? 9'h060  : // e
                  (uart_rx_byte==8'h66) ? 9'h00A  : // f
                  (uart_rx_byte==8'h67) ? 9'h05A  : // g
                  (uart_rx_byte==8'h68) ? 9'h008  : // h
                  (uart_rx_byte==8'h69) ? 9'h05D  : // i
                  (uart_rx_byte==8'h6A) ? 9'h056  : // j
                  (uart_rx_byte==8'h6B) ? 9'h00B  : // k
                  (uart_rx_byte==8'h6C) ? 9'h009  : // l
                  (uart_rx_byte==8'h6D) ? 9'h004  : // m
                  (uart_rx_byte==8'h6E) ? 9'h002  : // n
                  (uart_rx_byte==8'h6F) ? 9'h05F  : // o
                  
                  (uart_rx_byte==8'h70) ? 9'h05C  : // p
                  (uart_rx_byte==8'h71) ? 9'h052  : // q
                  (uart_rx_byte==8'h72) ? 9'h003  : // r
                  (uart_rx_byte==8'h73) ? 9'h006  : // s
                  (uart_rx_byte==8'h74) ? 9'h05E  : // t
                  (uart_rx_byte==8'h75) ? 9'h05B  : // u
                  (uart_rx_byte==8'h76) ? 9'h053  : // v
                  (uart_rx_byte==8'h77) ? 9'h055  : // w
                  (uart_rx_byte==8'h78) ? 9'h051  : // x
                  (uart_rx_byte==8'h79) ? 9'h058  : // y
                  (uart_rx_byte==8'h7A) ? 9'h054  : // z
                //(uart_rx_byte==8'h7B) ? 9'h000  : // {
                //(uart_rx_byte==8'h7C) ? 9'h000  : // |
                //(uart_rx_byte==8'h7D) ? 9'h000  : // }
                //(uart_rx_byte==8'h7E) ? 9'h000  : // ~
                //(uart_rx_byte==8'h7F) ? 9'h000  : // DEL  
                  
                                       9'h000;
                      
                  
//------------------------------------------------------------------------
//
// UART RX Controller
//
//------------------------------------------------------------------------

always @(posedge clk_int)
  begin
  
    uart_rx_d <= UART_RX & UART_RX2;    		// Either of the two serial ports can send data
    uart_rx_d1 <= uart_rx_d;
    uart_rx_d2 <= uart_rx_d1;
    
    rx_count <= rx_count + 1'b1;
    
    case (rx_count)
      16'h0000: if (uart_rx_d2!=1'b0)			// Look for Start Bit
               begin
                 rx_count <= 'h0;
               end
      16'h0100: uart_rx_byte[7:0] <= 8'h00;
      16'h019E: uart_rx_byte[0] <= uart_rx_d2;
      16'h027F: uart_rx_byte[1] <= uart_rx_d2;
      16'h0367: uart_rx_byte[2] <= uart_rx_d2;
      16'h0443: uart_rx_byte[3] <= uart_rx_d2;
      16'h0532: uart_rx_byte[4] <= uart_rx_d2;
      16'h0611: uart_rx_byte[5] <= uart_rx_d2;
      16'h06F9: uart_rx_byte[6] <= uart_rx_d2;
      16'h07DC: uart_rx_byte[7] <= uart_rx_d2;
      16'h07DD: rx_fifo_wr <= 1'b1;
      16'h07DE: rx_fifo_wr <= 1'b0;
      16'h08D0: rx_count <= 'h0;
      default: ;
    endcase
  end


//------------------------------------------------------------------------
//
// UART TX Controller
//
//------------------------------------------------------------------------

always @(posedge clk_int)
  begin
  
    uart_prescaler <= uart_prescaler + 1'b1;
    if (uart_prescaler[7:0]==8'h72)  // 9600 baud 
      begin
        uart_clock <= ~ uart_clock;
        uart_prescaler <= 'h0;
      end
      
    uart_clock_d <= uart_clock;
    
      
    rx_fifo_almost_full_d <= rx_fifo_almost_full;  

    if (rx_fifo_almost_full_d==1'b0 && rx_fifo_almost_full==1'b1)
      begin
        uart_tx_shiftout <= 11'b1_00010011_01; // XOFF
      end   
    else  if (rx_fifo_almost_full_d==1'b1 && rx_fifo_almost_full==1'b0)
      begin
        uart_tx_shiftout <= 11'b1_00010001_01; // XON
      end   
    else
      begin
        if (uart_clock_d==1'b0 && uart_clock==1'b1)
          begin
            uart_tx_shiftout[10:0] <= {1'b1 , uart_tx_shiftout[10:1] };
          end
      end   
     

  end
              
//------------------------------------------------------------------------
//
// Main Controller
//
//------------------------------------------------------------------------


always @(posedge clk_int)
  begin

    main_count <= main_count + 1'b1;
    
    case (main_count)
      8'h00: if (rx_fifo_empty==1'b1)                                               // Poll the rx_fifo for a new character to send
               begin
                 main_count <= 'h0;
               end
      8'h01: rx_fifo_rd <= 1'b1;                                                    // Strobe the rx_fifo to get the next character
      8'h02: rx_fifo_rd <= 1'b0;
      
      8'h03: if (rx_fifo_data_out[7:0]=='h99)                                       // Check character for carriage return
               begin
                 main_count <= 8'h10;
               end
               
      8'h04: begin  tx_fifo_wr <= 1'b1; tx_fifo_data_in <= 9'h121;  end             // Fill the TX_FIFO with the commands to send a character
      8'h05: begin  tx_fifo_wr <= 1'b1; tx_fifo_data_in <= 9'h00B;  end
      8'h06: begin  tx_fifo_wr <= 1'b1; tx_fifo_data_in <= 9'h0A6;  end             // Delay
      8'h07: begin  tx_fifo_wr <= 1'b1; tx_fifo_data_in <= 9'h121;  end
      8'h08: begin  tx_fifo_wr <= 1'b1; tx_fifo_data_in <= 9'h003;  end
      8'h09: begin  tx_fifo_wr <= 1'b1; tx_fifo_data_in <= rx_fifo_data_out;  end    // Letter to send
      8'h0A: begin  tx_fifo_wr <= 1'b1; tx_fifo_data_in <= 9'h00A;  end
      8'h0B: tx_fifo_wr <= 1'b0;
      8'h0C: begin
               if (tx_bytes==16'h8000)
                 begin
                   tx_bytes <= 16'h000A;
                 end
               else
                 begin
                   tx_bytes <= tx_bytes + 4'hA;                                     // Keep track of how many characters have been printed so far for this row
                 end
             end
      8'h0D: if (tx_fifo_empty==1'b0)                                               // Dont add to the TX_FIFO until previous command sequence has completed
               begin
                 main_count <= main_count;
               end
      8'h0E: main_count <= 'h0; 
      
                   
      8'h10: begin  tx_fifo_wr <= 1'b1; tx_fifo_data_in <= 9'h121;  end             // Fill the TX_FIFO with the carriage return commands
      8'h11: begin  tx_fifo_wr <= 1'b1; tx_fifo_data_in <= 9'h00B;  end
      8'h12: begin  tx_fifo_wr <= 1'b1; tx_fifo_data_in <= 9'h0A6;  end             // Delay
      8'h13: begin  tx_fifo_wr <= 1'b1; tx_fifo_data_in <= 9'h121;  end 
      8'h14: begin  tx_fifo_wr <= 1'b1; tx_fifo_data_in <= 9'h00D;  end
      8'h15: begin  tx_fifo_wr <= 1'b1; tx_fifo_data_in <= 9'h007;  end
      8'h16: begin  tx_fifo_wr <= 1'b1; tx_fifo_data_in <= 9'h121;  end
      8'h17: begin  tx_fifo_wr <= 1'b1; tx_fifo_data_in <= 9'h006;  end
      8'h18: begin  tx_fifo_wr <= 1'b1; tx_fifo_data_in <= { 1'b0 , tx_bytes[15:8] };  end 
      8'h19: begin  tx_fifo_wr <= 1'b1; tx_fifo_data_in <= { 1'b0 , tx_bytes[07:0] };  end 
      8'h1A: begin  tx_fifo_wr <= 1'b1; tx_fifo_data_in <= 9'h0A6;  end             // Delay
      8'h1B: begin  tx_fifo_wr <= 1'b1; tx_fifo_data_in <= 9'h121;  end
      8'h1C: begin  tx_fifo_wr <= 1'b1; tx_fifo_data_in <= 9'h005;  end
      8'h1D: begin  tx_fifo_wr <= 1'b1; tx_fifo_data_in <= 9'h090;  end
      8'h1E: tx_fifo_wr <= 1'b0;
      8'h1F: tx_bytes <= 16'h8000;                                                  // Zero out the character count for this row
      8'h20: if (tx_fifo_empty==1'b0)                                               // Dont add to the TX_FIFO until previous command sequence has completed
               begin
                 main_count <= main_count;
               end
      8'h21: main_count <= 'h0;                                         
          
      default: ;
    endcase
  end
 
//------------------------------------------------------------------------
//
// IBM Bus Controller
//
//------------------------------------------------------------------------

always @(posedge clk_int)
  begin
  
    ibm_bus_d <= IBM_BUS;   
    ibm_bus_d1 <= ibm_bus_d;
    ibm_bus_d2 <= ibm_bus_d1;
    
    prescaler <= prescaler + 1'b1;

    if (prescaler[7:0]==8'h05)  // IBM Serial Bus clock period = 5.34uS 
      begin
        ibm_clock <= ~ ibm_clock;
        prescaler <= 'h0;
      end
      
    ibm_clock_d <= ibm_clock;
    
    // IBM Serial Bus shift register
    if (ibm_load_tx==1'b1)
      begin
        ibm_shift_out[9:0] <= { tx_fifo_data_out[8:0] , 1'b0 };
      end
    else if (ibm_clock_d==1'b0 && ibm_clock==1'b1)
      begin
       ibm_shift_out[9:0] <= { 1'b1 , ibm_shift_out[9:1] }; 
      end      

    
    
    ibm_count <= ibm_count + 1'b1;
    
    case (ibm_count)
      16'h0000: if (tx_fifo_empty==1'b1)                                // Poll the tx_fifo 
               begin
                 ibm_count <= 'h0;
               end
      16'h0001: tx_fifo_rd <= 1'b1;                                     // Strobe the tx_fifo to get the next character to print
      16'h0002: tx_fifo_rd <= 1'b0;
      
      16'h0003: if (tx_fifo_data_out[7:0]==8'hA6)                       // Check character for the DELAY command byte
               begin
                 ibm_count <= 16'h0600;
               end
              
      16'h0004: if (ibm_clock_d==1'b0 && ibm_clock==1'b1) 
                  begin
                    ibm_load_tx <= 1'b1;
                  end
                else
                  begin
                    ibm_count <= ibm_count;
                  end

      16'h0005: ibm_load_tx <= 1'b0;
      


      //
      // Wait n clocks for end of the sequence to shift out
      //
  
      16'h007A: if (ibm_bus_d2!=1'b1)                                   // Check for ACK from IBM
               begin
                 ibm_count <= ibm_count;
               end
      16'h007C: if (ibm_bus_d2!=1'b0)                                   // Check for ACK from IBM
               begin
                 ibm_count <= ibm_count;
               end    
      16'h007E: if (ibm_bus_d2!=1'b1)                                   // Check for ACK from IBM
               begin
                 ibm_count <= ibm_count;
               end
      16'h00EC: ibm_count <= 'h0;
      
      
      16'h0600:  ;                                                      // Start of Delay
      16'h1050: ibm_count <= 'h0;                                       // End of Delay
              
          
      default: ;
    endcase

end                                          




//------------------------------------------------------------------------
//
// IBM Bus Snooper
//
//------------------------------------------------------------------------


always @(posedge clk_int)
  begin
  
    snoop_count <= snoop_count + 1'b1;
    
    case (snoop_count)
      16'h0000: if (ibm_bus_d2!=1'b0)
               begin
                 snoop_count <= 'h0;
               end
      16'h0012: snoop_byte[0] <= ibm_bus_d2;
      16'h001E: snoop_byte[1] <= ibm_bus_d2;
      16'h002A: snoop_byte[2] <= ibm_bus_d2;
      16'h0036: snoop_byte[3] <= ibm_bus_d2;
      
      16'h0041: snoop_byte[4] <= ibm_bus_d2;
      16'h004D: snoop_byte[5] <= ibm_bus_d2;
      16'h0059: snoop_byte[6] <= ibm_bus_d2;
      16'h0065: snoop_byte[7] <= ibm_bus_d2;
      
      16'h0071: snoop_byte[8] <= ibm_bus_d2;
      16'h0072: snoop_byte_all <= snoop_byte;
    
      16'h0075: if (ibm_bus_d2!=1'b1)
               begin
                 snoop_count <= snoop_count;
               end
      16'h0077: if (ibm_bus_d2!=1'b0)
               begin
                 snoop_count <= snoop_count;
               end
      16'h0079: if (ibm_bus_d2!=1'b1)
               begin
                 snoop_count <= snoop_count;
               end             
      16'h009D: snoop_count <= 'h0;
      
      default: ;
    endcase
  end
  

                 


//------------------------------------------------------------------------

endmodule 


//------------------------------------------------------------------------

                   
     

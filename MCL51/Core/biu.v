//
//
//  File Name   :  biu.v
//  Used on     :  
//  Author      :  Ted Fried, MicroCore Labs
//  Creation    :  3/13/16
//  Code Type   :  Synthesizable
//
//   Description:
//   ============
//   
//  Bus Interface Unit of the MCL51 processor 
//  ported to the Lattice XO2 Breakout Board.
//
//------------------------------------------------------------------------
//
// Modification History:
// =====================
//
// Revision 1.0 3/13/16 
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
    input               CORE_CLK,               // Core Signals
    input               RST_n,

    
    input               UART_RX,                // Peripheral IOs
    output              UART_TX,
    output              SPEAKER,

    
    input  [7:0]        EU_BIU_STROBE,          // EU to BIU Signals
    input  [7:0]        EU_BIU_DATAOUT,
    input  [15:0]       EU_REGISTER_R3,
    input  [15:0]       EU_REGISTER_IP,     
    
    
    output [7:0]        BIU_SFR_ACC,            // BIU to EU Signals
    output [15:0]       BIU_SFR_DPTR,
    output [7:0]        BIU_SFR_SP,
    output [7:0]        BIU_SFR_PSW,
    output [7:0]        BIU_RETURN_DATA,
    output              BIU_INTERRUPT,

    output              RESET_OUT
        
  );

//------------------------------------------------------------------------
      

// Internal Signals

reg   biu_pxy_rd;
reg   biu_pxy_wr;
reg   core_interrupt_disable;
wire  biu_int2;
wire  biu_int3;
wire  biu_sfr_select;
wire  acc_parity;
wire  biu_timer_wr_strobe;  
wire  biu_uart_rd_strobe;
wire  biu_uart_wr_strobe;
wire  loader_wr;
reg  [15:0] eu_register_r3_d1;
reg  [7:0]  biu_sfr_dpl_int;
reg  [7:0]  biu_sfr_dph_int;
reg  [7:0]  biu_sfr_ie_int;
reg  [7:0]  biu_sfr_psw_int;
reg  [7:0]  biu_sfr_acc_int;
reg  [7:0]  biu_sfr_sp_int;
reg  [7:0]  biu_sfr_b_int;
reg  [7:0]  biu_sfr_pxy_addr;
reg  [7:0]  biu_sfr_pxy_dout;
wire [7:0]  biu_sfr_pxy_din;
wire [7:0]  biu_sfr_dataout;
wire [7:0]  biu_sfr_is_int;
wire [7:0]  biu_program_data;
wire [2:0]  eu_biu_strobe_mode;
wire [2:0]  eu_biu_strobe_int;
wire [7:0]  biu_ram_dataout;
wire [7:0]  biu_timer_dataout;  
wire [7:0]  biu_uart_dataout;   
wire [15:0] loader_addr_int;
wire [7:0]  loader_data_int;



//------------------------------------------------------------------------
//
// User Program ROM.  4Kx8 
//
//------------------------------------------------------------------------                                    

/* Program ROM without interface to the UART Loader
biu_rom         BIU_4Kx8 
  (
    .Reset      (1'b0),
    .OutClockEn (1'b1),
    .OutClock   (CORE_CLK),
    .Address    (EU_REGISTER_IP[11:0]),
    .Q          (biu_program_data)
  );
*/
 
//  For Lattice XO2 Series FPGAs 
biu_rom_dp      BIU_4Kx8 
  (
  .ResetA       (1'b0), 
  .ClockEnA     (1'b1), 
  .ClockA       (CORE_CLK), 
  .WrA          (1'b0), 
  .AddressA     (EU_REGISTER_IP[11:0]),
  .DataInA      (8'h00), 
  .QA           (biu_program_data), 

  .ResetB       (1'b0),   
  .ClockEnB     (1'b1), 
  .ClockB       (CORE_CLK),
  .WrB          (loader_wr), 
  .AddressB     (loader_addr_int[11:0]),
  .DataInB      (loader_data_int),
  .QB           ( )
  );

        
//------------------------------------------------------------------------
//
// User Data RAM.  512x8 
//
//------------------------------------------------------------------------                                    

//  For Lattice XO2 Series FPGAs
biu_ram         BIU_512x8 
  (
    .Reset      (1'b0),
    .ClockEn    (1'b1),
    .Clock      (CORE_CLK),
    .Address    (eu_register_r3_d1[8:0]),  
    .Data       (EU_BIU_DATAOUT),
    .Q          (biu_ram_dataout),
    .WE         (biu_ram_wr)  
  );

//------------------------------------------------------------------------
//
// BIU  Combinationals
//
//------------------------------------------------------------------------


// Outputs to the EU
//
assign BIU_SFR_ACC              = biu_sfr_acc_int;
assign BIU_SFR_DPTR             = { biu_sfr_dph_int , biu_sfr_dpl_int };
assign BIU_SFR_SP               = biu_sfr_sp_int;
assign BIU_SFR_PSW              = { biu_sfr_psw_int[7:1] , acc_parity }; 


assign BIU_RETURN_DATA          = (eu_biu_strobe_mode==2'h0) ? biu_program_data     : 
                                  (biu_sfr_select==1'b1)     ? biu_sfr_dataout      : 
                                                               biu_ram_dataout      ;


// Parity for the Accumulator
// This can be removed if parity is not used in firmware.
assign acc_parity = (biu_sfr_acc_int[0]^biu_sfr_acc_int[1]^biu_sfr_acc_int[2]^biu_sfr_acc_int[3]^biu_sfr_acc_int[4]^biu_sfr_acc_int[5]^biu_sfr_acc_int[6]^biu_sfr_acc_int[7]);



                                                               
                                                               
// EU strobes to request BIU processing.
assign eu_biu_strobe_mode[2:0]    = EU_BIU_STROBE[6:4];  
assign eu_biu_strobe_int[2:0]     = EU_BIU_STROBE[2:0]; 



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
                         (eu_register_r3_d1[7:0]==8'hC0) ? biu_sfr_pxy_din   : 
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
assign BIU_INTERRUPT = (core_interrupt_disable==1'b0 && biu_sfr_ie_int[7]==1'b1 && biu_int2==1'b1) ? 1'b1 : 
                       (core_interrupt_disable==1'b0 && biu_sfr_ie_int[7]==1'b1 && biu_int3==1'b1) ? 1'b1 : 1'b0;
//                     (core_interrupt_disable==1'b0 && biu_sfr_ie_int[7]==1'b1 && biu_int4==1'b1) ? 1'b1 :
//                                                                                                   1'b0 ;
                                                              
assign biu_sfr_is_int[7:4] = 4'h0;
assign biu_sfr_is_int[3:0] = (biu_int2==1'b1) ? 4'h2 :
                             (biu_int3==1'b1) ? 4'h3 : 4'hF;
//                                              4'h4 ;
                    
    
    
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
      biu_pxy_rd <= 'h0;
      biu_pxy_wr <= 'h0;
      biu_sfr_pxy_addr <= 'h0;
      biu_sfr_pxy_dout <= 'h0;
      core_interrupt_disable <= 'h0;
    end
    
  else    
    begin     
  
      eu_register_r3_d1  <= EU_REGISTER_R3;
      
      if (eu_biu_strobe_int==3'h3)
        begin
          core_interrupt_disable <= 1'b1;
        end
        
      if (eu_biu_strobe_int==3'h4)
        begin
          core_interrupt_disable <= 1'b0;
        end
        
        
         
      // Writes to SFR's
      if (biu_sfr_select==1'b1 && eu_biu_strobe_int==3'h1)
        begin
          case (eu_register_r3_d1[7:0])  // synthesis parallel_case
        
            8'h81 : biu_sfr_sp_int      <= EU_BIU_DATAOUT[7:0];
            8'h82 : biu_sfr_dpl_int     <= EU_BIU_DATAOUT[7:0];
            8'h83 : biu_sfr_dph_int     <= EU_BIU_DATAOUT[7:0];
            8'hA8 : biu_sfr_ie_int      <= EU_BIU_DATAOUT[7:0];
            8'hD0 : biu_sfr_psw_int     <= EU_BIU_DATAOUT[7:0];
            8'hE0 : biu_sfr_acc_int     <= EU_BIU_DATAOUT[7:0];
            8'hF0 : biu_sfr_b_int       <= EU_BIU_DATAOUT[7:0];
            
            // Proxy Addressing Registers
            8'hC1 : biu_sfr_pxy_dout    <= EU_BIU_DATAOUT[7:0];
            8'hC2 : biu_sfr_pxy_addr    <= EU_BIU_DATAOUT[7:0];
          
            default :  ;
          endcase
        end     
        
        
      // Assert the write strobe to the proxy addressed peripherals
      if (biu_sfr_select==1'b1 && eu_biu_strobe_int==3'h1 && eu_register_r3_d1[7:0]==8'hC1)
        begin
          biu_pxy_wr <= 1'b1;
        end
      else
        begin
          biu_pxy_wr <= 1'b0;
        end     
                    
        
      // Assert the read strobe to the proxy addressed peripherals
      if (biu_sfr_select==1'b1 && eu_biu_strobe_int==3'h1 && eu_register_r3_d1[7:0]==8'hC2)
        begin
          biu_pxy_rd <= 1'b1;
        end
      else
        begin
          biu_pxy_rd <= 1'b0;
        end     
        
        
        
     end
end



    
//------------------------------------------------------------------------
//------------------------------------------------------------------------
//------------------------------------------------------------------------

//
// Peripherals accessed with proxy addressing  
//
// BIU SFR  biu_sfr_pxy_addr - 0xC2  = Address[7:0]
//          biu_sfr_pxy_dout - 0xC1  = Write Data and strobe to the peripherals
//          biu_sfr_pxy_din  - 0xC0  = Read Data from the peripherals
//
//
//
//------------------------------------------------------------------------
//

// Steer the peripheral read data
assign biu_sfr_pxy_din = (biu_sfr_pxy_addr[7:4]==4'h0) ? biu_timer_dataout  :
                         (biu_sfr_pxy_addr[7:4]==4'h1) ? biu_uart_dataout   :
                                                         8'hEE              ;
                                            
// Gate the peripheral read and write strobes
assign biu_timer_wr_strobe = (biu_sfr_pxy_addr[7:4]==4'h0) ? biu_pxy_wr : 1'b0; 
assign biu_uart_wr_strobe  = (biu_sfr_pxy_addr[7:4]==4'h1) ? biu_pxy_wr : 1'b0; 
assign biu_uart_rd_strobe  = (biu_sfr_pxy_addr[7:4]==4'h1) ? biu_pxy_rd : 1'b0; 




//------------------------------------------------------------------------
//
// Timer - Dual output 24-bit programmable timer
//
// Timer-0 = Frequency generator
// Timer-1 = Pulse generator
//
//------------------------------------------------------------------------                                    
                                                         
timer               BIU_TIMER 
  (
    .CORE_CLK       (CORE_CLK),
    .RST_n          (RST_n),
    .ADDRESS        (biu_sfr_pxy_addr[3:0]),
    .DATA_IN        (biu_sfr_pxy_dout),
    .DATA_OUT       (biu_timer_dataout),
    .STROBE_WR      (biu_timer_wr_strobe),
    .TIMER0_OUT     (SPEAKER),
    .TIMER1_OUT     (biu_int2)  
  );
  

          
//------------------------------------------------------------------------
//
// UART - Fixed 9600 baud 
//
//------------------------------------------------------------------------                                    
  
uart_and_loader     BIU_UART 
  (  
    .CLK            (CORE_CLK),
    .RST_n          (RST_n),
    .ADDRESS        (biu_sfr_pxy_addr[1:0]),
    .DATA_IN        (biu_sfr_pxy_dout),
    .DATA_OUT       (biu_uart_dataout),
    .STROBE_RD      (biu_uart_rd_strobe),
    .STROBE_WR      (biu_uart_wr_strobe),
    .UART_RX        (UART_RX),
    .UART_TX        (UART_TX),
    .UART_INT       (biu_int3),

    .LOADER_ADDR    (loader_addr_int ),
    .LOADER_DATA    (loader_data_int ),
    .LOADER_WR      (loader_wr ),
    .RESET_OUT      (RESET_OUT )
            
  );

    
endmodule // biu.v
    
        
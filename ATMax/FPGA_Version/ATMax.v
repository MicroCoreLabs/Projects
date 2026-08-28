//
//
//  File Name   :  ATMax.v
//  Used on     :  
//  Author      :  MicroCore Labs
//  Creation    :  7/1/2026
//  Code Type   :  Synthesizable
//
//   Description:
//   ============
//   
//  Lattice XO2-2000 FPGA used on ATMax which is a 16-bit ISA memory card.
//
//------------------------------------------------------------------------
//
// Modification History:
// =====================
//
// Revision 1.0 7/1/2026 
// Initial revision
//
//
//------------------------------------------------------------------------
//
// Copyright (c) 2026 Ted Fried
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

module ATMax
  (  
  
    // ISA Bus Interface
    // -------------------------------------------------------------------
    input               ISA_RST,        

    input  [23:0]       ISA_ADDR,
    inout  [15:0]       ISA_DATA,
    input               ISA_SBHE_n, 
    
    input               ISA_AEN,    
    input               ISA_MEM_WR_n,               
    input               ISA_MEM_RD_n,               
    input               ISA_IO_WR_n,                
    input               ISA_IO_RD_n,    
    input               ISA_REFRESH_n,  

    output              ISA_NOWAIT_n,               
    output              ISA_MEM16_n,  
    output              ISA_XCVR_DIR,   
    
    
    // SDRAM Interface
    // -------------------------------------------------------------------
    output              SDRAM_CLK,             
    output              SDRAM_CKE,             
    output [1:0]        SDRAM_BA,
    output [12:0]       SDRAM_ADDR,
    inout  [15:0]       SDRAM_DATA,

    output              SDRAM_CS_n,     
    output              SDRAM_RAS_n,        
    output              SDRAM_CAS_n,        
    output              SDRAM_WE_n,     
    output  [1:0]       SDRAM_DQM,       
    
    
    // Configuration Switches
    // -------------------------------------------------------------------
    input [7:0]         PIANO_SWITCH
           
  );

  
//------------------------------------------------------------------------


// SDRAM Commands       CS_n  RAS_n  CAS_n  WE_n
//
`define NOP             'b1111
`define RFSH            'b0001
`define MODE            'b0000
`define PRE             'b0010
`define RAS             'b0011
`define READ            'b0101
`define WRITE           'b0100

// SDRAM Mode                    Write Single Location Access , Standard Operation , Cas latency=2 , Burst Type=sequential , Burst Length=1 
//
`define SDRAM_MODE_SETTINGS     'b000_000_1_00_010_0_000

   
 

// Internal Signals
//

(* syn_useioff = 1 *) reg [1:0]  isa_data_out_oe_d1;        //Force the hi-Z enable into the IOB
(* syn_useioff = 1 *) reg  sdram_data_out_oe_d1;

reg  sdram_data_out_oe;
reg  isa_rst_d1;
reg  isa_rst_d2;
reg  sdram_cke_int;
reg  isa_refresh_n_d1;
reg  isa_refresh_n_d2;
reg  isa_mem_rd_n_d1;
reg  isa_mem_rd_n_d2;
reg  isa_mem_wr_n_d1;
reg  isa_mem_wr_n_d2;
reg  isa_io_rd_n_d1;
reg  isa_io_rd_n_d2;
reg  isa_io_wr_n_d1;
reg  isa_io_wr_n_d2;
reg  isa_xcvr_dir_int;
reg  isa_xcvr_dir_out;
reg  sdram_cs_n_int_out;
reg  sdram_ras_n_int_out;
reg  sdram_cas_n_int_out;
reg  sdram_we_n_int_out;
reg  sdram_cke_int_out;     

wire osch_clk_int;
wire clk_100mhz_int;
wire clk_100mhz_int_shifted;
wire isa_io_mman_match;

reg  [1:0]  isa_data_out_oe;
reg  [1:0]  isa_memory_match_latched;
reg  [15:0] ems_frame_pointer0;
reg  [15:0] ems_frame_pointer1;
reg  [15:0] ems_frame_pointer2;
reg  [15:0] ems_frame_pointer3;
reg  [15:0] ems_base_segment;
reg  [15:0] umb_base_segment;
reg  [15:0] sdram_data_in_d1;
reg  [15:0] isa_data_out;
reg  [15:0] isa_data_out_d1;
reg  [15:0] sdram_data_out;
reg  [15:0] sdram_data_out_d1;
reg  [14:0] sdram_address_out;
reg  [3:0]  sdram_cmd;
reg  [1:0]  sdram_dqm_int;
reg  [15:0] delay_counter;
reg  [15:0] delay_counter_d;
reg  [7:0]  main_state;
reg  [1:0]  sdram_ba_int_out;
reg  [12:0] sdram_addr_int_out;
reg  [1:0]  sdram_dqm_int_out;
      
wire [24:0] memory_address;
wire [1:0]  isa_memory_match;

      
//
// Internal Oscillator and PLL for Lattice XO2
// DDR IO block to generate 100Mhz to the SDRAM chip
//
//------------------------------------------------------------------------
  
OSCH #( .NOM_FREQ("133.00"))    i_OSCH
        (
          .STDBY                (1'b0),
          .OSC                  (osch_clk_int),
          .SEDSTDBY             ()
        );
        
        
ATMax_PLL                       i_ATMax_PLL

        (
          .CLKI                 (osch_clk_int),
          .CLKOP                (clk_100mhz_int),
          .CLKOS                (clk_100mhz_int_shifted)
        );           


ODDRXE                          i_ODDRXE 
        (
            .D0                 (1'b1),        
            .D1                 (1'b0),        
            .RST                (1'b0),        
            .SCLK               (clk_100mhz_int_shifted),            
            .Q                  (SDRAM_CLK)  
        );


                                                             
                  
//------------------------------------------------------------------------
// GSR - Global Set/Reset for Lattice XO2
// POR - Power On reset for Lattice XO2
//------------------------------------------------------------------------

GSR       GSR_INST  (   
.GSR      ( )    );

PUR       PUR_INST  (   
.PUR      ( )    );



//------------------------------------------------------------------------
//
// Combinationals
//
//------------------------------------------------------------------------

assign ISA_XCVR_DIR     = isa_xcvr_dir_out;   
assign ISA_DATA[15:8]   = (isa_data_out_oe_d1[1]=='h1)   ? isa_data_out_d1[15:8]   : 8'hZ;
assign ISA_DATA[ 7:0]   = (isa_data_out_oe_d1[0]=='h1)   ? isa_data_out_d1[ 7:0]   : 8'hZ;
assign ISA_NOWAIT_n     = ( (isa_memory_match[0]!=1'b0) &&  (ISA_MEM_WR_n==1'b0) ) ? 1'b0 : 1'b1; // Just 0WS for Writes for now == Add qualified for reads later
assign ISA_MEM16_n      = (isa_memory_match[0]!=1'b0) ? 1'b0 : 1'b1;

 
assign SDRAM_CKE        = sdram_cke_int_out;       
assign SDRAM_BA         = sdram_ba_int_out;
assign SDRAM_ADDR       = sdram_addr_int_out;
assign SDRAM_CS_n       = sdram_cs_n_int_out;
assign SDRAM_RAS_n      = sdram_ras_n_int_out;
assign SDRAM_CAS_n      = sdram_cas_n_int_out;
assign SDRAM_WE_n       = sdram_we_n_int_out;
assign SDRAM_DQM        = sdram_dqm_int_out;
assign SDRAM_DATA[15:0] = (sdram_data_out_oe_d1=='h1) ? sdram_data_out_d1[15:0] : 16'hZ;


// Asynchronous address checkers
assign isa_io_mman_match  = (ISA_ADDR[11:04] == 8'h26) ? 1'h1 : 1'h0; // Memory Manager Base = 0x260



assign isa_memory_match[1] = (ISA_ADDR[23:16]=={ 4'h0 , ems_base_segment[15:12] } )  ? 1'b1 : 1'b0;                 // EMS
assign isa_memory_match[0] = ( (ISA_ADDR[23:19]>=PIANO_SWITCH[7:3]) ||                                              // XMS
                               (ISA_ADDR[23:17]<7'h05) && (ISA_ADDR[19:17]>=PIANO_SWITCH[2:0]) )  ? 1'b1 : 1'b0;    // Backfill


assign memory_address = ( (isa_memory_match[1]==1'b1) && (ISA_ADDR[15:14]==2'b11) ) ? { 1'b1 , ems_frame_pointer3[9:0] , ISA_ADDR[13:0] } :
                        ( (isa_memory_match[1]==1'b1) && (ISA_ADDR[15:14]==2'b10) ) ? { 1'b1 , ems_frame_pointer2[9:0] , ISA_ADDR[13:0] } :
                        ( (isa_memory_match[1]==1'b1) && (ISA_ADDR[15:14]==2'b01) ) ? { 1'b1 , ems_frame_pointer1[9:0] , ISA_ADDR[13:0] } :
                        ( (isa_memory_match[1]==1'b1) && (ISA_ADDR[15:14]==2'b00) ) ? { 1'b1 , ems_frame_pointer0[9:0] , ISA_ADDR[13:0] } :
                        
                        (  isa_memory_match[0]==1'b1)                               ? { 1'b0 , ISA_ADDR[23:0] } : 'h0;


   
//------------------------------------------------------------------------------------------  
//
// Main State Machine
//
//------------------------------------------------------------------------------------------

always @(posedge clk_100mhz_int)
begin : MAIN_STATE_MACHINE

  // Registered Inputs
  //
  isa_rst_d1 <= ISA_RST;
  isa_rst_d2 <= isa_rst_d1;
  
  sdram_data_in_d1 <= SDRAM_DATA;

  isa_refresh_n_d1 <= ISA_REFRESH_n;
  isa_refresh_n_d2 <= isa_refresh_n_d1;
  
  isa_mem_wr_n_d1 <= ISA_MEM_WR_n;
  isa_mem_wr_n_d2 <= isa_mem_wr_n_d1;
 
  isa_mem_rd_n_d1 <= ISA_MEM_RD_n;
  isa_mem_rd_n_d2 <= isa_mem_rd_n_d1;

  
  isa_io_rd_n_d1 <= ISA_IO_RD_n;
  isa_io_rd_n_d2 <= isa_io_rd_n_d1;
  
  isa_io_wr_n_d1 <= ISA_IO_WR_n;
  isa_io_wr_n_d2 <= isa_io_wr_n_d1;
    

  // Registered Outputs
  //   
  sdram_ba_int_out     <= sdram_address_out[14:13];  
  sdram_addr_int_out   <= sdram_address_out[12:0];  
  sdram_cs_n_int_out   <= sdram_cmd[3];
  sdram_ras_n_int_out  <= sdram_cmd[2];
  sdram_cas_n_int_out  <= sdram_cmd[1];
  sdram_we_n_int_out   <= sdram_cmd[0];
  sdram_dqm_int_out    <= sdram_dqm_int;
  sdram_cke_int_out    <= sdram_cke_int;
  isa_data_out_d1      <= isa_data_out;
  sdram_data_out_d1    <= sdram_data_out;
  sdram_data_out_oe_d1 <= sdram_data_out_oe;
  isa_data_out_oe_d1   <= isa_data_out_oe;
  isa_xcvr_dir_out     <= isa_xcvr_dir_int;
   


  if (isa_rst_d2==1'b1)
    begin
      sdram_cmd <= `NOP;
      isa_data_out_oe <= 2'b00;
      sdram_data_out_oe <= 'h0;
      sdram_dqm_int <= 'b11;
      sdram_cke_int <= 'h0;
      delay_counter <= 'h0;
      isa_xcvr_dir_int <= 'h0;
      ems_base_segment <= 16'hD000;
      main_state <= 'h0;
    end
    
  else    
    begin   

      main_state <= main_state + 1'b1;
      delay_counter <= delay_counter + 1'b1;
      delay_counter_d <= delay_counter;
      
      case (main_state)
      
        'h0 : begin  
                isa_data_out_oe <= 2'b00;
                sdram_cmd <= `NOP;
                sdram_data_out_oe <= 'h0;
                sdram_address_out <= 'h0;
                sdram_address_out[10] <= 'h1; // Precharge all banks
                sdram_dqm_int <= 'b11;
                sdram_cke_int <= 'h0;  
                sdram_data_out <= `SDRAM_MODE_SETTINGS;             
              end

        // Initialize the SDRAM
        'h1 : if (delay_counter_d=='h2700)  sdram_cke_int <= 'h1; else main_state <= main_state;   // Hold SDRAM CKE low for 120uS to let clock and power stabilize  
        'h2 : if (delay_counter_d!='h4E00)  main_state <= main_state;   // Hold SDRAM CKE high for 120uS
        
        'h3 : sdram_cmd <= `PRE;                                                // Precharge all banks
        'h4 : sdram_cmd <= `NOP;                                                // Wait tRP

        'h5 : if (delay_counter_d!='h4E10)   main_state <= main_state;     // Pause for 16 clocks

        'h6 : sdram_cmd <= `RFSH;                                               // Auto Refresh then wait tRFC
        'h7 : begin
                sdram_cmd <= `NOP;                                              // Wait tRFC
                if (delay_counter_d!='h4E20)  main_state <= main_state;     // Pause for 16 clocks
              end
    
        'h8 : sdram_cmd <= `RFSH;                                               // Auto Refresh then wait tRFC
        'h9 : begin
                sdram_cmd <= `NOP;                                              // Wait tRFC
                if (delay_counter_d=='h4E30) sdram_data_out_oe <= 'h1; else main_state <= main_state;     // Pause for 16 clocks
              end
              
        'hA : begin                                                             // Program SDRAM Mode register
                sdram_cmd <= `MODE;
                sdram_dqm_int <= 'b11;
              end               
        'hB : sdram_cmd <= `NOP;
        'hC : sdram_data_out_oe <= 'h0;

              
        // IDLE                                                             
        'h10 : begin
        
                 // memory_address and isa_memory_match asynchronous but well established before MEMRD/WR goes low
                 sdram_address_out <= memory_address[24:10]; 
                 isa_memory_match_latched <= isa_memory_match;
                 isa_xcvr_dir_int <= 1'b0;
                 
                 if (isa_refresh_n_d2==1'b0) 
                   begin
                     sdram_cmd <= `RFSH;
                     main_state <= 'h20;
                   end
                   
                 else if ( (isa_memory_match!='h0) && (isa_mem_rd_n_d2==1'b0) )
                   begin
                     isa_xcvr_dir_int <= 1'b1;
                     sdram_cmd <= `RAS;
                     main_state <= 'h30;
                   end
                               
                 else if ( (isa_memory_match!='h0) && (isa_mem_wr_n_d2==1'b0) )
                   begin
                     sdram_cmd <= `RAS;
                     main_state <= 'h40;
                   end
                                               
                 else if ( (ISA_AEN=='h0) && (isa_io_rd_n_d2==1'b0) )
                   begin
                     isa_xcvr_dir_int <= 1'b1;
                     main_state <= 'h60;
                   end
                                                               
                 else if ( (ISA_AEN=='h0) && (isa_io_wr_n_d2==1'b0) )
                   begin
                     main_state <= 'h70;
                   end
                 
                 else
                   begin
                     main_state <= 'h10;
                   end
                   
               end
              
           
        // Refresh recovery
        'h20 : sdram_cmd <= `NOP;
        'h26 : main_state <= 'h10;
                   
                   
        // Memory Read
        'h30 : begin
                 sdram_cmd <= `NOP;
                 sdram_address_out <= { memory_address[24:23] , 4'b0000 , memory_address[9:1]  };  
                 if (isa_memory_match_latched[1]==1'b0) isa_data_out_oe <= { ~ISA_SBHE_n , ~ISA_ADDR[0] }; else isa_data_out_oe <= 2'b01;            
               end
        'h31 : begin
                 sdram_cmd <= `READ;
                 sdram_dqm_int <= 'b00;
               end
        'h32 : begin
                 sdram_cmd <= `NOP;
                 sdram_dqm_int <= 'b11;
               end
        'h35 : sdram_cmd <= `PRE;
        'h36 : begin
                 sdram_cmd <= `NOP;
                 if ( (isa_memory_match_latched[1]==1'b1) && (ISA_ADDR[0]==1'b1) ) isa_data_out[7:0] <= sdram_data_in_d1[15:8] ; else isa_data_out <= sdram_data_in_d1;
               end
        'h37 : main_state <= 'h50;
                     
                     
        // Memory Write
        'h40 : begin
                 if (isa_memory_match_latched[1]==1'b0)                             // XMS and backfill 16-bit accesses
                   begin
                     sdram_data_out <= ISA_DATA;
                     sdram_dqm_int <= { ISA_SBHE_n , ISA_ADDR[0] };
                   end
                 else
                   begin                                                    // EMS 8-bit accesses
                     sdram_data_out <= { ISA_DATA[7:0] , ISA_DATA[7:0] };
                     if (ISA_ADDR[0]==1'b0) sdram_dqm_int <= 2'b10; else sdram_dqm_int <= 2'b01;
                   end
                 
                 sdram_cmd <= `NOP;
                 sdram_data_out_oe <= 'h1;
               end
        'h41 : begin
                 sdram_address_out <= { memory_address[24:23] , 4'b0000 , memory_address[9:1]  };  
                 sdram_cmd <= `WRITE;
               end    
        'h42 : begin
                 sdram_cmd <= `NOP;
                 sdram_dqm_int <= 'b11;
               end
        'h43 : begin
                 sdram_cmd <= `PRE;
                 sdram_data_out_oe <= 'h0;
               end
        'h44 : sdram_cmd <= `NOP;
        'h45 : main_state <= 'h50;
                     
                     
        // Wait for host to end the cycle by deasserting Read/Write signals
        'h50 : if (isa_mem_rd_n_d2=='h1 && isa_mem_wr_n_d2=='h1 && isa_io_rd_n_d2=='h1 && isa_io_wr_n_d2=='h1 ) 
                 begin
                   isa_data_out_oe <= 2'b00;
                   main_state <= 'h10;
                 end
               else 
                 begin
                   main_state <= 'h50;
                 end
                 
                 
        // IO Read Cycles                
        'h60 : begin
               if (isa_io_mman_match=='h1)
                 begin
                   isa_data_out_oe <= 2'b01;
                   main_state <= 'h50;
                   case (ISA_ADDR[3:0])
                     'h0: isa_data_out[7:0] <= ems_frame_pointer0[7:0];
                     'h1: isa_data_out[7:0] <= ems_frame_pointer0[15:8];
                     'h2: isa_data_out[7:0] <= ems_frame_pointer1[7:0];
                     'h3: isa_data_out[7:0] <= ems_frame_pointer1[15:8];
                     'h4: isa_data_out[7:0] <= ems_frame_pointer2[7:0];
                     'h5: isa_data_out[7:0] <= ems_frame_pointer2[15:8];
                     'h6: isa_data_out[7:0] <= ems_frame_pointer3[7:0];
                     'h7: isa_data_out[7:0] <= ems_frame_pointer3[15:8];
                     default : isa_data_out[7:0] <= 'hFF;
                   endcase
                 end
               else 
                 begin
                   main_state <= 'h50;
                 end
               end               

                 
        // IO Write Cycles               
        'h70 : begin
               if (isa_io_mman_match=='h1)
                 begin
                   main_state <= 'h50;
                   case (ISA_ADDR[4:0])
                     'h00: ems_frame_pointer0[7:0]  <= ISA_DATA[7:0];
                     'h01: ems_frame_pointer0[15:8] <= ISA_DATA[7:0];
                     'h02: ems_frame_pointer1[7:0]  <= ISA_DATA[7:0];
                     'h03: ems_frame_pointer1[15:8] <= ISA_DATA[7:0];
                     'h04: ems_frame_pointer2[7:0]  <= ISA_DATA[7:0];
                     'h05: ems_frame_pointer2[15:8] <= ISA_DATA[7:0];
                     'h06: ems_frame_pointer3[7:0]  <= ISA_DATA[7:0];
                     'h07: ems_frame_pointer3[15:8] <= ISA_DATA[7:0];
                     
                     'h10: ems_base_segment[7:0]    <= ISA_DATA[7:0];
                     'h11: ems_base_segment[15:8]   <= ISA_DATA[7:0];
                     
                     //'h12: // Populate this later == XTMax memory array
                     
                     'h13: umb_base_segment[7:0]    <= ISA_DATA[7:0];
                     'h14: umb_base_segment[15:8]   <= ISA_DATA[7:0];
                     
                     //'h15: // Populate this later == XTMax memory array
                     default : ;
                   endcase
                 end
               else 
                 begin
                   main_state <= 'h50;
                 end
               end
            
            
        default : ;
      endcase
    end              


  end
       
       
            
     
endmodule // ATMax.v

//

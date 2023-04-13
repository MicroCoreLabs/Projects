//
//  File Name   :  MDA_Video_core_v1_0.v
//  Used on     :  
//  Author      :  Ted Fried
//  Creation    :  4/10/2023
//  Code Type   :  Synthesizable
//
//   Description:
//   ============
//   
//   This AXI slave reads an image held in dul ported RAM and
//   sends it out to an MDA Display
//
//------------------------------------------------------------------------
//
// Modification History:
// =====================
//
// Revision 1.0 4/10/23
// Initial revision
//
//
//------------------------------------------------------------------------
//
// Copyright (c) 2023 Ted Fried
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


`timescale 1 ns / 1 ps


    module MDA_Video_core_v1_0 #
    (
        // Users to add parameters here

        // User parameters ends
        // Do not modify the parameters beyond this line


        // Parameters of Axi Slave Bus Interface S00_AXI
        parameter integer C_S00_AXI_DATA_WIDTH  = 32,
        parameter integer C_S00_AXI_ADDR_WIDTH  = 4,

        // Parameters of Axi Master Bus Interface M00_AXI
        parameter  C_M00_AXI_TARGET_SLAVE_BASE_ADDR = 32'h40000000,
        parameter integer C_M00_AXI_BURST_LEN   = 4,
        parameter integer C_M00_AXI_ID_WIDTH    = 1,
        parameter integer C_M00_AXI_ADDR_WIDTH  = 32,
        parameter integer C_M00_AXI_DATA_WIDTH  = 32,
        parameter integer C_M00_AXI_AWUSER_WIDTH    = 0,
        parameter integer C_M00_AXI_ARUSER_WIDTH    = 0,
        parameter integer C_M00_AXI_WUSER_WIDTH = 0,
        parameter integer C_M00_AXI_RUSER_WIDTH = 0,
        parameter integer C_M00_AXI_BUSER_WIDTH = 0
    )
  (
        // AXI Slave Interface
        // ------------------------------------------------------------------------------------
        input wire          s00_axi_aclk,       // Clock and Reset
        input wire          s00_axi_aresetn,

        input wire [31:0]   s00_axi_awaddr,     // Write Address Channel
        input wire          s00_axi_awvalid,
        output wire         s00_axi_awready,
        
        input wire [31:0]   s00_axi_wdata,      // Write Data Channel
        input wire [3:0]    s00_axi_wstrb,
        input wire          s00_axi_wvalid,
        output wire         s00_axi_wready,
        
        output wire [1:0]   s00_axi_bresp,      // Write Response Channel
        output wire         s00_axi_bvalid,
        input wire          s00_axi_bready,
        
        input wire [31:0]   s00_axi_araddr,     // Read Address Channel
        input wire          s00_axi_arvalid,
        output wire         s00_axi_arready,
        
        output wire [31:0]  s00_axi_rdata,      // Read Data Channel
        output wire [1:0]   s00_axi_rresp,
        output wire         s00_axi_rvalid,
        input wire          s00_axi_rready,

        input wire [2:0]    s00_axi_awprot,     // AXI Protection
        input wire [2:0]    s00_axi_arprot,
        
        
        // MDA Video display signals
        // ------------------------------------------------------------------------------------
        output               MDA_HSYNC,
        output               MDA_VSYNC,
        output               MDA_DATA,
        output               MDA_INTENSITY


    );
        


// Internal Signals
//------------------------------------------------------------------------

reg s00_axi_bvalid_int      = 'h0;
reg s00_axi_rvalid_int      = 'h0;
reg s00_axi_awready_int     = 'h0;
reg s00_axi_wready_int      = 'h0;
reg mda_hsync_int           = 'h0;
reg mda_vsync_int           = 'h0;
reg mda_data_int            = 'h0;
reg mda_intensity_int       = 'h0;
reg dpram_a_wr              = 'h0;
reg mda_shifter_load        = 'h0;

reg [31:0]   s00_axi_rdata_int;
reg [8:0]    dpram_a_addr       = 'h0;
reg [719:0]  dpram_a_data       = 'h0;
reg [8:0]    dpram_b_addr       = 'h0;
reg [719:0]  mda_shift_out      = 'h0;
reg [15:0]   mda_bit_counter    = 'h0;

wire mda_clock;

wire [719:0] dpram_b_data;



//------------------------------------------------------------------------
//
// Combinationals
//
//------------------------------------------------------------------------

// AXI Slave Controller signals
assign s00_axi_awready  = s00_axi_awready_int;
assign s00_axi_arready  = 1'b1;
assign s00_axi_wready   = s00_axi_wready_int;
assign s00_axi_bresp    = 2'b00;
assign s00_axi_rresp    = 2'b00;
assign s00_axi_bvalid   = s00_axi_bvalid_int;
assign s00_axi_rvalid   = s00_axi_rvalid_int;
assign s00_axi_rdata    = s00_axi_rdata_int;


assign MDA_HSYNC     = mda_hsync_int;
assign MDA_VSYNC     = mda_vsync_int;
assign MDA_DATA      = mda_shift_out[719];
assign MDA_INTENSITY = mda_intensity_int;



//------------------------------------------------------------------------
//
// AXI Slave Controller
//
//------------------------------------------------------------------------

always @(posedge s00_axi_aclk)
  begin : AXI_SLAVE_CONTROLLER
  

    
    // For AXI Writes, the write data can come before the write address.
    //  We will enforce that the address and data arrive simultaneously.
  
    if (s00_axi_aresetn==1'b0)
      begin
        s00_axi_awready_int <= 1'b0;
        s00_axi_wready_int  <= 1'b0;
        s00_axi_bvalid_int  <= 1'b0;
        s00_axi_rvalid_int  <= 1'b0;
      end

    else
      begin
      

        // AXI Write Controller
        //
        //  Accept write data only when the address and data are available from the host
        //  Assert the write response as soon as data is received
        //
        if (s00_axi_awvalid==1'b1 && s00_axi_wvalid==1'b1)
          begin
            s00_axi_awready_int <= 1'b1;
            s00_axi_wready_int  <= 1'b1;
            s00_axi_bvalid_int  <= 1'b1;   // Assert write response
            

        // Debounce the write address and data ready signals
        //
        if (s00_axi_awready_int==1'b1)
          begin
            s00_axi_awready_int <= 1'b0;
            s00_axi_wready_int  <= 1'b0;
          end   
        
        // Debounce the write response when the host is ready
        //
        if (s00_axi_bvalid_int==1'b1 && s00_axi_bready==1'b1)
          begin
            s00_axi_bvalid_int <= 1'b0;
            
            case (s00_axi_awaddr[7:0])
            
              8'h10 : dpram_a_data[31:0]     <=  s00_axi_wdata[31:0];
              8'h14 : dpram_a_data[63:32]    <=  s00_axi_wdata[31:0];
              8'h18 : dpram_a_data[95:64]    <=  s00_axi_wdata[31:0];
              8'h1C : dpram_a_data[127:96]   <=  s00_axi_wdata[31:0];

              8'h20 : dpram_a_data[159:128]  <=  s00_axi_wdata[31:0];
              8'h24 : dpram_a_data[191:160]  <=  s00_axi_wdata[31:0];
              8'h28 : dpram_a_data[223:192]  <=  s00_axi_wdata[31:0];
              8'h2C : dpram_a_data[255:224]  <=  s00_axi_wdata[31:0];

              8'h30 : dpram_a_data[287:256]  <=  s00_axi_wdata[31:0];
              8'h34 : dpram_a_data[319:288]  <=  s00_axi_wdata[31:0];
              8'h38 : dpram_a_data[351:320]  <=  s00_axi_wdata[31:0];
              8'h3C : dpram_a_data[383:352]  <=  s00_axi_wdata[31:0];

              8'h40 : dpram_a_data[415:384]  <=  s00_axi_wdata[31:0];
              8'h44 : dpram_a_data[447:416]  <=  s00_axi_wdata[31:0];
              8'h48 : dpram_a_data[479:448]  <=  s00_axi_wdata[31:0];
              8'h4C : dpram_a_data[511:480]  <=  s00_axi_wdata[31:0];

              8'h50 : dpram_a_data[543:512]  <=  s00_axi_wdata[31:0];
              8'h54 : dpram_a_data[575:544]  <=  s00_axi_wdata[31:0];
              8'h58 : dpram_a_data[607:576]  <=  s00_axi_wdata[31:0];
              8'h5C : dpram_a_data[639:608]  <=  s00_axi_wdata[31:0];

              8'h60 : dpram_a_data[671:640]  <=  s00_axi_wdata[31:0];
              8'h64 : dpram_a_data[703:672]  <=  s00_axi_wdata[31:0];
              8'h68 : dpram_a_data[719:704]  <=  s00_axi_wdata[15:0];
              
              8'h70 : dpram_a_addr  <=  s00_axi_wdata[8:0];
              8'h74 : dpram_a_wr    <=  s00_axi_wdata[0];

              default: ;
            endcase
          end
        end
        
        
        // AXI Read Controller
        //
        if (s00_axi_arvalid==1'b1)
          begin
            s00_axi_rvalid_int <= 1'b1;   // Assert read response
                        
            case (s00_axi_araddr[8:0])
              9'h000: s00_axi_rdata_int <= 32'hDEAD_BEEF;        // FPGA_ID 
              9'h004: s00_axi_rdata_int <= 32'h0000_0088;        // FPGA Version

              default: ;
            endcase
          end

        // Debounce Read Response
        //
        if (s00_axi_rvalid_int==1'b1 && s00_axi_rready==1'b1)
          begin
            s00_axi_rvalid_int <= 1'b0;
          end

    end
    
end



//------------------------------------------------------------------------
//
// MDA Clock Generator
//
//------------------------------------------------------------------------

MDA_DCM             i_MDA_DCM  (
     .clk_in1       (s00_axi_aclk),
     .clk_out1      (mda_clock)    
 );    


//------------------------------------------------------------------------
//
// MDA Video RAM
//
//------------------------------------------------------------------------

MDA_VIDEO_DPRAM     i_MDA_VIDEO_DPRAM (
  .clka             (s00_axi_aclk), 
  .wea              (dpram_a_wr),   
  .addra            (dpram_a_addr), 
  .dina             (dpram_a_data), 
  
  .clkb             (mda_clock),   
  .addrb            (dpram_b_addr), 
  .doutb            (dpram_b_data)  
);



//------------------------------------------------------------------------
//
// MDA Video Controller
//
//------------------------------------------------------------------------

always @(posedge mda_clock)
  begin : MDA_CONTROLLER
  
  
    // Shift out a video row
    //
    if (mda_shifter_load==1'b1)  mda_shift_out <= dpram_b_data[719:0];
    else                         mda_shift_out <= { mda_shift_out[718:0] , 1'b0 };
    
    
    mda_bit_counter <= mda_bit_counter + 1'b1;
    case (mda_bit_counter)
        
      'd000 : mda_shifter_load <= 1'b1;                                 // Load DPRAM contents into shift register
      'd001 : mda_shifter_load <= 1'b0;                                 // Debounce shift register loader
      'd002 : dpram_b_addr <= dpram_b_addr + 1'b1;                      // Advance to the next DPRAM row
      
      'd731 : mda_hsync_int <= 1'b1;                                    // 720 clocks for active video and another 10 clocks, then assert HSYNC
      'd866 : mda_hsync_int <= 1'b0;                                    // 135 clocks for HSYNC active
          
      'd883 : begin
                mda_bit_counter <= 'd0;                                 // Return to the beginning of this state machine  
                if (dpram_b_addr=='d349)  mda_vsync_int <= 1'b0;        // 17 clocks after HSYNC de-asserted, then check to start VSYNC at end of 350 lines
                if (dpram_b_addr=='d365)  mda_vsync_int <= 1'b1;        // De-assert VSYNC after 16 lines
                if (dpram_b_addr=='d369)  dpram_b_addr <= 'h0;          // After four lines of nothing, return to the beginning of the video DPRAM
              end
                                        
       default: ;
     endcase  
  end



endmodule

//
//
//  File Name   :  MCL86jr.v
//  Used on     :  MCL86jr Board
//  Author      :  Ted Fried, MicroCore Labs
//  Creation    :  10/8/2015
//  Code Type   :  Synthesizable
//
//   Description:
//   ============
//   
//  Top level for the MCL86 8088 CPU core running with minimum mode BIU
//
//------------------------------------------------------------------------
//
// Modification History:
// =====================
//
// Revision 1.0 10/8/15 
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

module MCL86jr
  (  
    input               CORE_CLK,

    input               CLK,
    input               RESET,

    input               READY,
    input               INTR,
    input               NMI,

    
    output              A19,
    output              A18,
    output              A17,
    output              A16,
    output              A15,
    output              A14,
    output              A13,
    output              A12,
    output              A11,
    output              A10,
    output              A9,
    output              A8,
    inout               AD7,
    inout               AD6,
    inout               AD5,
    inout               AD4,
    inout               AD3,
    inout               AD2,
    inout               AD1,
    inout               AD0,

    output              ALE,
    output              INTA_n,
    output              RD_n,
    output              WR_n,
    output              IOM,
    output              DTR,
    output              DEN,
    output              SSO_n,
    
    output [18:0]       SRAM_A,
    inout  [7:0]        SRAM_D,
    output              SRAM_CE_n,
    output              SRAM_OE_n,
    output              SRAM_WE_n,

    output [7:0]        LED,
    
    output              BUF1_OE_n,
    output              BUF2_OE_n,
    output              BUF2_DIR
    

  );

//------------------------------------------------------------------------
      

// Internal Signals

reg  t_reset_d1='h0;   
reg  t_reset_d2='h0;   
reg  t_reset_d3='h0;   
reg  t_reset_d4='h0;   
reg  t_eu_flag_i_d;
reg  t_biu_ad_oe_d1;
reg  t_biu_ad_oe_d2;
reg  t_biu_lock_n_d;
reg  prescaler_d;
reg  led_go_left;
reg  fpga_config_done;
wire core_clk_int;
wire t_eu_prefix_lock;
wire t_eu_flag_i;
wire t_biu_lock_n;
wire t_pfq_empty;
wire t_biu_done;
wire t_biu_clk_counter_zero;
wire t_biu_ad_oe;
wire t_biu_nmi_caught;
wire t_biu_nmi_debounce;
wire t_sram_d_oe;  
wire t_biu_intr;
reg  [26:0] prescaler;  
reg  [7:0]  led_int; 
reg  [19:0] trigger_address;
reg  [19:0] t_biu_ad_out_d;
wire [19:0] t_biu_ad_out;
wire [7:0]  t_biu_ad_in;
wire [2:0]  t_s2_s0_out;
wire [15:0] t_eu_biu_command;
wire [15:0] t_eu_biu_dataout;
wire [15:0] t_eu_register_r3;
wire [7:0]  t_pfq_top_byte;
wire [15:0] t_pfq_addr_out;
wire [15:0] t_biu_register_es;
wire [15:0] t_biu_register_ss;
wire [15:0] t_biu_register_cs;
wire [15:0] t_biu_register_ds;
wire [15:0] t_biu_register_rm;
wire [15:0] t_biu_register_reg;
wire [15:0] t_biu_return_data;
wire [7:0] t_sram_d_out;  

    

  spartan6_pll SPARTAN6PLL
  (
    .CLK_IN1    (CORE_CLK), 
    .CLK_OUT1   (core_clk_int) 
  ); 
  


//------------------------------------------------------------------------
//
// CPU Bus Combinationals
//
//------------------------------------------------------------------------

assign A19      = t_biu_ad_out_d[19];
assign A18      = t_biu_ad_out_d[18];
assign A17      = t_biu_ad_out_d[17];
assign A16      = t_biu_ad_out_d[16];
assign A15      = t_biu_ad_out_d[15];
assign A14      = t_biu_ad_out_d[14];
assign A13      = t_biu_ad_out_d[13];
assign A12      = t_biu_ad_out_d[12];
assign A11      = t_biu_ad_out_d[11];
assign A10      = t_biu_ad_out_d[10];
assign A9       = t_biu_ad_out_d[9];
assign A8       = t_biu_ad_out_d[8];

assign AD7      = (t_biu_ad_oe_d2==1'b1) ?  t_biu_ad_out_d[7] : 'hZ; 
assign AD6      = (t_biu_ad_oe_d2==1'b1) ?  t_biu_ad_out_d[6] : 'hZ; 
assign AD5      = (t_biu_ad_oe_d2==1'b1) ?  t_biu_ad_out_d[5] : 'hZ; 
assign AD4      = (t_biu_ad_oe_d2==1'b1) ?  t_biu_ad_out_d[4] : 'hZ; 
assign AD3      = (t_biu_ad_oe_d2==1'b1) ?  t_biu_ad_out_d[3] : 'hZ; 
assign AD2      = (t_biu_ad_oe_d2==1'b1) ?  t_biu_ad_out_d[2] : 'hZ; 
assign AD1      = (t_biu_ad_oe_d2==1'b1) ?  t_biu_ad_out_d[1] : 'hZ; 
assign AD0      = (t_biu_ad_oe_d2==1'b1) ?  t_biu_ad_out_d[0] : 'hZ; 

assign t_biu_ad_in[7:0] = { AD7, AD6, AD5, AD4, AD3, AD2, AD1, AD0 };


assign BUF1_OE_n =  1'b0; // Always enabled for now, but fix when HLD/HLDA is added
assign BUF2_OE_n =  1'b0; // ~ t_biu_ad_oe_d2;
assign BUF2_DIR =   ~ t_biu_ad_oe_d2;

assign SRAM_CE_n = 1'b0;
assign SRAM_D = (t_sram_d_oe==1'b1) ? t_sram_d_out : 8'hZ;

assign LED[7] = ~led_int[7];
assign LED[6] = ~led_int[6];
assign LED[5] = ~led_int[5];
assign LED[4] = ~led_int[4];
assign LED[3] = ~led_int[3];
assign LED[2] = ~led_int[2];
assign LED[1] = ~led_int[1];
assign LED[0] = ~led_int[0];

    
//------------------------------------------------------------------------

always @(posedge core_clk_int)
begin : REGISTER_IOS
    
    t_biu_ad_oe_d1 <= t_biu_ad_oe;
    t_biu_ad_oe_d2 <= t_biu_ad_oe_d1;
  
    t_biu_ad_out_d <= t_biu_ad_out;
    
    t_eu_flag_i_d <= t_eu_flag_i;
  
    t_biu_lock_n_d <= t_biu_lock_n;
  
    t_reset_d1 <= RESET;
    t_reset_d2 <= t_reset_d1;
    t_reset_d3 <= t_reset_d2;
    
    // Use either the PCjr board reset or an internal timer for a reset 
    if ( (t_reset_d3==1'b1 && t_reset_d2==1'b1) || (fpga_config_done==1'b0) )
      begin
        t_reset_d4 <= 1'b1;
        led_int <= 8'b10000000;
      end   
    else
      begin
        t_reset_d4 <= t_reset_d3;
      end
      
  
    prescaler <= prescaler + 1'b1;
    prescaler_d <= prescaler[21];

    if (prescaler[26]==1'b1) fpga_config_done <= 1'b1;

    
    // Blink the sweeping LEDs
    if (prescaler_d==1'b0 && prescaler[21]==1'b1)
      begin   

        if (led_go_left==1'b0)
          led_int[7:0] <= {led_int[0] , led_int[7:1] };
        else
          led_int[7:0] <= {led_int[6:0] , led_int[7] };
          
        if (led_int[6]==1'b1)  led_go_left <= 1'b0;
        if (led_int[1]==1'b1)  led_go_left <= 1'b1;
        
      end

  
end


//------------------------------------------------------------------------
// BIU Core 
//------------------------------------------------------------------------

biu_min                     BIU_CORE
  (
    .CORE_CLK_INT           (core_clk_int),
    .RESET_INT              (t_reset_d4),
    .CLK                    (CLK),
    .READY_IN               (READY),
    .NMI                    (NMI),
    .INTR                   (INTR),
    .INTA_n                 (INTA_n),
    .ALE                    (ALE),
    .RD_n                   (RD_n),
    .WR_n                   (WR_n),
    .SSO_n                  (SSO_n),
    .IOM                    (IOM),
    .DTR                    (DTR),
    .DEN                    (DEN),
    .AD_OE                  (t_biu_ad_oe),
    .AD_OUT                 (t_biu_ad_out),
    .AD_IN                  (t_biu_ad_in),
    .EU_BIU_COMMAND         (t_eu_biu_command),
    .EU_BIU_DATAOUT         (t_eu_biu_dataout),
    .EU_REGISTER_R3         (t_eu_register_r3),
    .EU_PREFIX_LOCK         (t_eu_prefix_lock),
    .BIU_DONE               (t_biu_done),
    .BIU_CLK_COUNTER_ZERO   (t_biu_clk_counter_zero), 
    .BIU_SEGMENT            ( ),    
    .BIU_NMI_CAUGHT         (t_biu_nmi_caught),
    .BIU_NMI_DEBOUNCE       (t_biu_nmi_debounce),
    .BIU_INTR               (t_biu_intr),
    .PFQ_TOP_BYTE           (t_pfq_top_byte),
    .PFQ_EMPTY              (t_pfq_empty),
    .PFQ_ADDR_OUT           (t_pfq_addr_out),
    .BIU_REGISTER_ES        (t_biu_register_es),
    .BIU_REGISTER_SS        (t_biu_register_ss),
    .BIU_REGISTER_CS        (t_biu_register_cs),
    .BIU_REGISTER_DS        (t_biu_register_ds),
    .BIU_REGISTER_RM        (t_biu_register_rm),
    .BIU_REGISTER_REG       (t_biu_register_reg),
    .BIU_RETURN_DATA        (t_biu_return_data),
    .SRAM_A                 (SRAM_A),
    .SRAM_D_OE              (t_sram_d_oe),
    .SRAM_D_OUT             (t_sram_d_out),
    .SRAM_D_IN              (SRAM_D),
    .SRAM_OE_n              (SRAM_OE_n),
    .SRAM_WE_n              (SRAM_WE_n)

  );    


//------------------------------------------------------------------------
// EU Core 
//------------------------------------------------------------------------

mcl86_eu_core               EU_CORE
  (
    .CORE_CLK_INT           (core_clk_int),
    .RESET_INT              (t_reset_d4),
    .TEST_N_INT             (1'b1),
    .EU_BIU_COMMAND         (t_eu_biu_command),
    .EU_BIU_DATAOUT         (t_eu_biu_dataout),
    .EU_REGISTER_R3         (t_eu_register_r3),
    .EU_PREFIX_LOCK         (t_eu_prefix_lock),
    .EU_FLAG_I              (t_eu_flag_i),
    .BIU_DONE               (t_biu_done),
    .BIU_CLK_COUNTER_ZERO   (t_biu_clk_counter_zero),
    .BIU_NMI_CAUGHT         (t_biu_nmi_caught),
    .BIU_NMI_DEBOUNCE       (t_biu_nmi_debounce),
    .BIU_INTR               (t_biu_intr),
    .PFQ_TOP_BYTE           (t_pfq_top_byte),
    .PFQ_EMPTY              (t_pfq_empty),
    .PFQ_ADDR_OUT           (t_pfq_addr_out),
    .BIU_REGISTER_ES        (t_biu_register_es),
    .BIU_REGISTER_SS        (t_biu_register_ss),
    .BIU_REGISTER_CS        (t_biu_register_cs),
    .BIU_REGISTER_DS        (t_biu_register_ds),
    .BIU_REGISTER_RM        (t_biu_register_rm),
    .BIU_REGISTER_REG       (t_biu_register_reg),
    .BIU_RETURN_DATA        (t_biu_return_data)
  );    
    

  
endmodule


//------------------------------------------------------------------------

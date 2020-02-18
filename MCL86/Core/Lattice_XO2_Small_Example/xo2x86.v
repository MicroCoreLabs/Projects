//
//
//  File Name   :  XO2x86.v
//  Used on     :  
//  Author      :  Ted Fried, MicroCore Labs
//  Creation    :  2/29/2016
//  Code Type   :  Synthesizable
//
//   Description:
//   ============
//   
//  MCL86 ported to the Lattice XO2-7000 Breakout Board - Top Level
//
//------------------------------------------------------------------------
//
// Modification History:
// =====================
//
// Revision 1.0 3/3/15 
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

module xo2x86
  (  
    input               RESET_n ,

    input               UART_RX,
    output              UART_TX,
    
    output [7:0]        LEDS
        

  );

//------------------------------------------------------------------------
      

// Internal Signals

wire clk_int;
wire t_eu_prefix_lock;
wire t_eu_flag_i;
wire t_pfq_empty;
wire t_biu_done;
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
wire [1:0]  t_biu_segment;


//------------------------------------------------------------------------
// GSR  - Global Set/Reset for Lattice XO2
// POR  - Power On reset for Lattice XO2
// OSCH - Internal clock oscillator for Lattice XO2
//------------------------------------------------------------------------

GSR       GSR_INST  (   
.GSR      (RESET_n)    );


PUR       PUR_INST  (   
.PUR      (RESET_n)    );


defparam OSCILLATOR_INST.NOM_FREQ = "26.60";
OSCH        OSCILLATOR_INST
  ( 
    .STDBY      (1'b0),
    .OSC        (clk_int),
    .SEDSTDBY   ()              
  );




    
//------------------------------------------------------------------------
// BIU Core 
//------------------------------------------------------------------------
biu                         BIU_CORE
  (
    .CORE_CLK_INT           (clk_int),
    .RESET_n                (RESET_n),
    .UART_RX                (UART_RX),
    .UART_TX                (UART_TX),
    .LEDS                   (LEDS),
    .EU_BIU_COMMAND         (t_eu_biu_command),
    .EU_BIU_DATAOUT         (t_eu_biu_dataout),
    .EU_REGISTER_R3         (t_eu_register_r3),
    .BIU_DONE               (t_biu_done),
    .BIU_SEGMENT            (t_biu_segment),    
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
    
    
//------------------------------------------------------------------------
// EU Core 
//------------------------------------------------------------------------
mcl86_eu_core               EU_CORE
  (
    .CORE_CLK_INT           (clk_int),
    .RESET_n                (RESET_n),
    .TEST_N_INT             (1'b1),
    .EU_BIU_COMMAND         (t_eu_biu_command),
    .EU_BIU_DATAOUT         (t_eu_biu_dataout),
    .EU_REGISTER_R3         (t_eu_register_r3),
    .EU_PREFIX_LOCK         (t_eu_prefix_lock),
    .EU_FLAG_I              (t_eu_flag_i),
    .BIU_DONE               (t_biu_done),
    .BIU_CLK_COUNTER_ZERO   (1'b1),
    .BIU_NMI_CAUGHT         (1'b0),
    .BIU_NMI_DEBOUNCE       (),
    .BIU_INTR               (1'b0),
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

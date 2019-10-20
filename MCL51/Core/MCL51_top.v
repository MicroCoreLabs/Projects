//
//
//  File Name   :  MCL51_top.v
//  Used on     :  
//  Author      :  MicroCore Labs
//  Creation    :  5/9/2016
//  Code Type   :  Synthesizable
//
//   Description:
//   ============
//   
//  MCL51 processor - Top Level  For 'Arty' Artix-7 Test Board
//
//------------------------------------------------------------------------
//
// Modification History:
// =====================
//
// Revision 1.0 5/1/16
// Initial revision
//
//
//------------------------------------------------------------------------

module MCL51_top
  (  
    input				CLK,
    input				RESET_n,

    input				UART_RX,
    output        		UART_TX,
    output        		SPEAKER	

  );

//------------------------------------------------------------------------
 	  

// Internal Signals

wire clk_int;
wire t_rst_n_int;
wire t_biu_reset_out;
wire t_biu_interrupt;
wire [7:0]  t_eu_biu_strobe;
wire [7:0]  t_eu_biu_dataout;
wire [15:0] t_eu_register_r3;
wire [7:0]  t_biu_sfr_psw;
wire [7:0]  t_biu_sfr_acc;
wire [7:0]  t_biu_sfr_sp;
wire [15:0] t_eu_register_ip;
wire [15:0] t_biu_sfr_dptr;
wire [7:0]  t_biu_return_data;




assign clk_int = CLK;
assign t_rst_n_int = (t_biu_reset_out==1'b0 && RESET_n==1'b1) ? 1'b1 : 1'b0;

	
//------------------------------------------------------------------------
// EU Core 
//------------------------------------------------------------------------
eu							EU_CORE
  (
	.CORE_CLK				(clk_int),
	.RST_n					(t_rst_n_int),
	
	.EU_BIU_STROBE			(t_eu_biu_strobe),
	.EU_BIU_DATAOUT			(t_eu_biu_dataout),
	.EU_REGISTER_R3			(t_eu_register_r3),
	.EU_REGISTER_IP			(t_eu_register_ip),
	
	.BIU_SFR_ACC			(t_biu_sfr_acc),
	.BIU_SFR_DPTR			(t_biu_sfr_dptr),
	.BIU_SFR_SP 			(t_biu_sfr_sp),
	.BIU_SFR_PSW			(t_biu_sfr_psw),
	.BIU_RETURN_DATA		(t_biu_return_data),
	.BIU_INTERRUPT			(t_biu_interrupt)	

  );	
	
	
	
//------------------------------------------------------------------------
// BIU Core 
//------------------------------------------------------------------------
biu							BIU_CORE
  (
	.CORE_CLK				(clk_int),
	.RST_n				    (t_rst_n_int),
	.UART_RX				(UART_RX),
	.UART_TX				(UART_TX),
	.SPEAKER				(SPEAKER),
	.EU_BIU_STROBE			(t_eu_biu_strobe),
	.EU_BIU_DATAOUT			(t_eu_biu_dataout),
	.EU_REGISTER_R3			(t_eu_register_r3),
	.EU_REGISTER_IP			(t_eu_register_ip),
	.BIU_SFR_ACC			(t_biu_sfr_acc),
	.BIU_SFR_DPTR			(t_biu_sfr_dptr),
	.BIU_SFR_SP 			(t_biu_sfr_sp),
	.BIU_SFR_PSW			(t_biu_sfr_psw),
	.BIU_RETURN_DATA		(t_biu_return_data),
	.BIU_INTERRUPT			(t_biu_interrupt),	
	.RESET_OUT				(t_biu_reset_out)	
		
  );	
	
	
	


 
endmodule // MCL51_top.v


//------------------------------------------------------------------------

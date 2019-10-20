//
//  File Name   :  biu_rom_dp_behav.v
//  Used on     :  
//  Author      :  MicroCore Labs
//  Creation    :  3/17/2016
//  Code Type   :  Behavioral
//
//   Description:
//   ============
//   DPRAM behavioral model.
// 
//

//------------------------------------------------------------------------


`timescale 1ns/100ps



module biu_rom_dp
  (
	input			    clka,
	input			    wea,
	input[11:0]		    addra,
	input[7:0]		    dina,
	output reg[7:0]     douta,


	input			    clkb,
	input			    web,
	input[11:0]		    addrb,
	input[7:0]		    dinb,
	output reg[7:0]		doutb

  );
      
 
  
//------------------------------------------------------------------------

integer file, k, l;
reg  [7:0]     ram_dataouta;
reg  [7:0]     ram_dataoutb;
reg  [7:0]     ram_array[0:4095];


									  
//------------------------------------------------------------------------


initial
  begin

    // Zero out the RAM so there are no X's
    for (k = 0; k < 4096 ; k = k + 1)
	  begin
	    ram_array[k] = 8'h00;
	  end

  
	// Load the 8051 instruction into the array  
	// Using Binary file
    file = $fopen("C:/MCL/MCL51/Production_Base/Xilinx_Artix/Loader/Assembly_Code/Loader_Only/Objects/Loader.bin","rb");
    for (l = 0; l < 4096 ; l = l + 1)
	  begin
        k = $fread(ram_array[l] , file);
	  end
	  
  end											  

  
always @(posedge clka)
  begin
    douta <= ram_array[addra];
	
	if (wea==1'b1)
	  begin
	    ram_array[addra] = dina;
      end
	else if (web==1'b1)
	  begin
	    ram_array[addrb] = dinb;	
	  end
	  
  end

  
always @(posedge clkb)
  begin
    doutb <= ram_array[addrb];
  end

  
												 


//------------------------------------------------------------------------

endmodule 


//------------------------------------------------------------------------

                   
     

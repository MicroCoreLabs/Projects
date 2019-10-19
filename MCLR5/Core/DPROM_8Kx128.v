//
//  File Name   :  DPROM_8Kx128.v
//  Used on     :  
//  Author      :  Ted Fried, MicroCore Labs
//  Creation    :  8/57/2017
//  Code Type   :  Behavioral
//
//   Description:
//   ============
//   Xilinx ROM behavioral model.
// 
//

//------------------------------------------------------------------------


`timescale 1ns/100ps



module DPROM_8Kx128
  (
	input			    clka,
	input[12:0]		    addra,
	output reg[127:0]   douta,
	
	input			    clkb,
	input[12:0]		    addrb,
	output reg[127:0]   doutb

  );

//------------------------------------------------------------------------

integer file, k, l;
reg  [127:0]     ram_array[0:8191];


									  
//------------------------------------------------------------------------


initial
  begin

    // Zero out the RAM so there are no X's
    for (k = 0; k < 8192 ; k = k + 1)
	  begin
	    ram_array[k] = 'h0;
	  end
	  
	  
	// Load the instructions into the array using ASCII byte file
    $readmemh("D:/MCL/MCLR5/Quad_Issue/usercode_rom.hex", ram_array);
    //$readmemb("C:/MCL/MCLR5/Quad_Issue/usercode_rom.hex", ram_array);
	
  end											  

  
  
always @(posedge clka)
  begin
  
    douta <= ram_array[addra];
    doutb <= ram_array[addrb];
	  
  end

												 


//------------------------------------------------------------------------

endmodule 


//------------------------------------------------------------------------

                   
     

//
//
//  File Name   :  timer.v
//  Used on     :  
//  Author      :  MicroCore Labs
//  Creation    :  4/15/16
//  Code Type   :  Synthesizable
//
//   Description:
//   ============
//   
//  Two channel, 24-bit timers.
//
// Timer-0 = Frequency generator
// Timer-1 = One-shot generator
//
//------------------------------------------------------------------------
//
// Modification History:
// =====================
//
// Revision 1.0 4/15/16 
// Initial revision
//
//
//------------------------------------------------------------------------


module timer
  (  
  
    input				CORE_CLK,
    input				RST_n,
	
    input  [3:0]		ADDRESS,				
    input  [7:0] 		DATA_IN,
    output [7:0] 		DATA_OUT,
    input				STROBE_WR,
	
    output 		  		TIMER0_OUT,
    output 		  		TIMER1_OUT
	
  );

//------------------------------------------------------------------------
 	  

// Internal Signals

reg   timer0_enable;
reg   timer1_enable;
reg   timer1_debounce;
reg   timer0_out_int;
reg   timer1_out_int;
reg [23:0] timer0_counter;
reg [23:0] timer1_counter;
reg [23:0] timer0_count_max;
reg [23:0] timer1_count_max;


   
//------------------------------------------------------------------------
//
// Combinationals
//
//------------------------------------------------------------------------


assign TIMER0_OUT = (timer0_enable==1'b1 && timer0_out_int==1'b1) ? 1'b1 : 1'b0;
assign TIMER1_OUT = (timer1_enable==1'b1 && timer1_out_int==1'b1) ? 1'b1 : 1'b0;

assign DATA_OUT = 8'h5A; // Timer Device ID

						 
//------------------------------------------------------------------------
//
// Timer
//
//------------------------------------------------------------------------
//

always @(posedge CORE_CLK)
begin : BIU_CONTROLLER

  if (RST_n==1'b0)
    begin
	  timer0_count_max <= 24'h02EA85; // C4 - Middle C  261.63Hz @ 100Mhz core frequency
	  timer0_enable <= 1'b1;
	  timer0_counter <= 'h0;
	  timer0_out_int <= 1'b0;
	  timer1_count_max <= 'h0;
	  timer1_enable <= 'h0;
	  timer1_counter <= 'h0;
	  timer1_out_int <= 1'b0;	  
	  timer1_debounce <= 'h0;
    end
    
  else    
    begin     
	  
      // Writes to Registers
	  if (STROBE_WR==1'b1)
  	    begin
	      case (ADDRESS[3:0])  // synthesis parallel_case
    	    4'h0 : timer0_count_max[23:16]  <= DATA_IN[7:0];
    	    4'h1 : timer0_count_max[15:8]   <= DATA_IN[7:0];
    	    4'h2 : timer0_count_max[7:0]    <= DATA_IN[7:0];
    	    4'h3 : timer0_enable            <= DATA_IN[0];		
    	    4'h4 : timer1_count_max[23:16]  <= DATA_IN[7:0];
    	    4'h5 : timer1_count_max[15:8]   <= DATA_IN[7:0];
    	    4'h6 : timer1_count_max[7:0]    <= DATA_IN[7:0];
    	    4'h7 : timer1_enable            <= DATA_IN[0];		 
    	    4'h8 : timer1_debounce          <= 1'b1;
  	  	    default :  ;
  	      endcase
        end  
      else
	    begin	  
		  timer1_debounce <= 1'b0;
		end
	  

	  // Timer0 - Frequency Generator	
	  if (timer0_enable==1'b0 || timer0_counter==timer0_count_max)
	    begin
		  timer0_counter <= 'h0;
		  timer0_out_int <= ~ timer0_out_int;
		end
	  else 
	    begin
		  timer0_counter <= timer0_counter + 1'b1;
		end
		
		
		
	  // Timer1 - One-shot Generator
	  if (timer1_enable==1'b0 || timer1_counter==timer1_count_max)
	    begin
		  timer1_counter <= 'h0;
		end
	  else 
	    begin
		  timer1_counter <= timer1_counter + 1'b1;
		end
				
	  if (timer1_enable==1'b0 || timer1_debounce==1'b1)
	    begin
		  timer1_out_int <= 1'b0;
		end
	  else if (timer1_counter==timer1_count_max)
	    begin
		  timer1_out_int <= 1'b1;
		end

		
	
		
			  
    end

end

 
endmodule // timer.v
		
			
		
		
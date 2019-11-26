//
//
//  File Name   :  timer.v
//  Used on     :  
//  Author      :  Ted Fried, MicroCore Labs
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
// Revision 2.0 5/23/16 
// Hard-wired MIDI note to 24-bit counter value converter for use with Music Player.
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
reg   strobe_wr_d;
reg  [23:0] timer0_counter;
reg  [23:0] timer1_counter;
reg  [23:0] timer1_count_max;
reg  [7:0]  timer0_note;
wire [23:0] timer0_count_max;

															  // Notes @ 100Mhz FPGA core frequency
assign timer0_count_max = (timer0_note==8'h3B) ? 24'h0316EE : // B3    - 246.94Hz 
                          (timer0_note==8'h3C) ? 24'h02EA85 : // C4    - 261.63     ** Middle C 
                          (timer0_note==8'h3D) ? 24'h02C0A4 : // Db4   - 277.18
                          (timer0_note==8'h3E) ? 24'h029913 : // D4    - 293.67
                          (timer0_note==8'h3F) ? 24'h0273C0 : // Eb4   - 311.13
                          (timer0_note==8'h40) ? 24'h025085 : // E4    - 329.63
                          (timer0_note==8'h41) ? 24'h022F44 : // F4    - 349.23
                          (timer0_note==8'h42) ? 24'h020FDF : // Gb4   - 370.00
                          (timer0_note==8'h43) ? 24'h01F23F : // G4    - 392.00
                          (timer0_note==8'h44) ? 24'h01D647 : // Ab4   - 415.31
                          (timer0_note==8'h45) ? 24'h01BBE4 : // A4    - 440.00
                          (timer0_note==8'h46) ? 24'h01A2FB : // Bb4   - 466.16
                          (timer0_note==8'h47) ? 24'h018B77 : // B4    - 493.88
                          (timer0_note==8'h48) ? 24'h017544 : // C5    - 523.25
                          (timer0_note==8'h49) ? 24'h016050 : // Db5   - 554.37
                          (timer0_note==8'h4A) ? 24'h014C86 : // D5    - 587.33
                          (timer0_note==8'h4B) ? 24'h0139E1 : // Eb5   - 622.25
                          (timer0_note==8'h4C) ? 24'h012842 : // E5    - 659.26
                          (timer0_note==8'h4D) ? 24'h0117A2 : // F5    - 698.46
                          (timer0_note==8'h4E) ? 24'h0107F0 : // Gb5   - 739.99
                          (timer0_note==8'h4F) ? 24'h00F920 : // G5    - 783.99
                          (timer0_note==8'h50) ? 24'h00EB24 : // Ab5   - 830.61
                          (timer0_note==8'h51) ? 24'h00DDF2 : // A5    - 880.00
                          (timer0_note==8'h52) ? 24'h00D17D : // Bb5   - 932.33
                          (timer0_note==8'h53) ? 24'h00C5BB : // B5    - 987.77
                          (timer0_note==8'h54) ? 24'h00BAA2 : // C6    - 1046.50
                          (timer0_note==8'h55) ? 24'h00B028 : // Db6   - 1108.73
                          (timer0_note==8'h56) ? 24'h00A645 : // D6    - 1174.66
                          (timer0_note==8'h57) ? 24'h009CF0 : // Eb6   - 1244.51
                          (timer0_note==8'h58) ? 24'h009421 : // E6    - 1318.51
						                           'hFFFFFF ;
						  

			
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
//	  timer0_count_max <= 24'h02EA85; // C4 - Middle C  261.63Hz @ 100Mhz core frequency
	  timer0_note <= 'h0;
	  timer0_enable <= 1'b0;
	  timer0_counter <= 'h0;
	  timer0_out_int <= 1'b0;
	  timer1_count_max <= 'h0;
	  timer1_enable <= 'h0;
	  timer1_counter <= 'h0;
	  timer1_out_int <= 1'b0;	  
	  timer1_debounce <= 'h0;
	  strobe_wr_d <= 'h0;
    end
    
  else    
    begin     
	
	  strobe_wr_d <= STROBE_WR;
	  
      // Writes to Registers
	  if (STROBE_WR==1'b1 || strobe_wr_d==1'b1)
  	    begin
	      case (ADDRESS[3:0])  // synthesis parallel_case
    	    //4'h0 : timer0_count_max[23:16]  <= DATA_IN[7:0];
    	    //4'h1 : timer0_count_max[15:8]   <= DATA_IN[7:0];
    	    4'h2 : timer0_note[7:0]         <= DATA_IN[7:0];
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
	  if (timer1_enable==1'b0 || timer1_counter[22:0]==timer1_count_max[23:1])
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
	  else if (timer1_counter[22:0]==timer1_count_max[23:1])
	    begin
		  timer1_out_int <= 1'b1;
		end

		
	
		
			  
    end

end

 
endmodule // timer.v
		
			
		
		
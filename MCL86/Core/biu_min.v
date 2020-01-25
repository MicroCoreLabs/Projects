//
//
//  File Name   :  biu_min.v
//  Used on     :  
//  Author      :  Ted Fried, MicroCore Labs
//  Creation    :  10/8/2015
//  Code Type   :  Synthesizable
//
//   Description:
//   ============
//   
//  Bus Interface Unit of the i8088 processor in Minimum Bus Mode
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


module biu_min
  (  
    input               CORE_CLK_INT,           // Core Clock

    
    input               CLK,                    // 8088 Pins
    input               RESET_INT,
    input               READY_IN,
    input               NMI,
    input               INTR,
    output reg          INTA_n,
    output reg          ALE,
    output reg          RD_n,
    output reg          WR_n,
    output reg          IOM,
    output reg          DTR,
    output reg          DEN,
    output reg          AD_OE,
    output reg [19:0]   AD_OUT,
    input  [7:0]        AD_IN,

    
    input  [15:0]       EU_BIU_COMMAND,         // EU to BIU Signals
    input  [15:0]       EU_BIU_DATAOUT,
    input  [15:0]       EU_REGISTER_R3,
    input               EU_PREFIX_LOCK,
    
    
    output              BIU_DONE,               // BIU to EU Signals
    output              BIU_CLK_COUNTER_ZERO,
    output [1:0]        BIU_SEGMENT,
    output              BIU_NMI_CAUGHT,
    input               BIU_NMI_DEBOUNCE,
    output reg          BIU_INTR,

    output [7:0]        PFQ_TOP_BYTE,
    output              PFQ_EMPTY,
    output[15:0]        PFQ_ADDR_OUT,

    output [15:0]       BIU_REGISTER_ES,
    output [15:0]       BIU_REGISTER_SS,
    output [15:0]       BIU_REGISTER_CS,
    output [15:0]       BIU_REGISTER_DS,
    output [15:0]       BIU_REGISTER_RM,
    output [15:0]       BIU_REGISTER_REG,
    output [15:0]       BIU_RETURN_DATA
    

  );

//------------------------------------------------------------------------
      

// Internal Signals

reg   biu_done_int;
reg   byte_num;
reg   clk_d1;
reg   clk_d2;
reg   clk_d3;
reg   clk_d4;
reg   eu_biu_req_caught;
reg   eu_biu_req_d1;
reg   eu_prefix_lock_d1;
reg   eu_prefix_lock_d2;
reg   intr_d1;
reg   intr_d2;
reg   intr_d3;
reg   nmi_caught;
reg   nmi_d1;
reg   nmi_d2;
reg   nmi_d3;
reg   pfq_write;
reg   ready_d1;
reg   ready_d2;
reg   ready_d3;
reg   word_cycle;
wire  eu_biu_req;
wire  eu_prefix_seg;
wire  pfq_empty;
reg  [7:0]  ad_in_int;
reg  [19:0] addr_out_temp;
reg  [7:0]  biu_state;
reg  [15:0] biu_register_cs;
reg  [15:0] biu_register_es;
reg  [15:0] biu_register_ss;
reg  [15:0] biu_register_ds;
reg  [15:0] biu_register_rm;
reg  [15:0] biu_register_reg;
reg  [15:0] biu_register_cs_d1;
reg  [15:0] biu_register_es_d1;
reg  [15:0] biu_register_ss_d1;
reg  [15:0] biu_register_ds_d1;
reg  [15:0] biu_register_rm_d1;
reg  [15:0] biu_register_reg_d1;
reg  [15:0] biu_register_cs_d2;
reg  [15:0] biu_register_es_d2;
reg  [15:0] biu_register_ss_d2;
reg  [15:0] biu_register_ds_d2;
reg  [15:0] biu_register_rm_d2;
reg  [15:0] biu_register_reg_d2;
reg  [15:0] biu_return_data_int;
reg  [15:0] biu_return_data_int_d1;
reg  [15:0] biu_return_data_int_d2;
reg  [12:0] clock_cycle_counter;
reg  [15:0] eu_register_r3_d;
reg  [7:0]  latched_data_in;
reg  [15:0] pfq_addr_out;
reg  [7:0]  pfq_entry0;
reg  [7:0]  pfq_entry1;
reg  [7:0]  pfq_entry2;
reg  [7:0]  pfq_entry3;
reg  [15:0] pfq_addr_in;
reg  [7:0]  pfq_top_byte_int_d1;
reg  [15:0] pfq_addr_out_d1;
reg  [2:0]  s_bits;
wire [15:0] biu_muxed_segment;   
wire [1:0]  biu_segment;    
wire [1:0]  eu_biu_strobe;
wire [1:0]  eu_biu_segment;
wire [4:0]  eu_biu_req_code;
wire [1:0]  eu_qs_out;
wire [1:0]  eu_segment_override_value; 
wire [7:0]  pfq_top_byte_int;

  
//------------------------------------------------------------------------
//
// BIU  Combinationals
//
//------------------------------------------------------------------------

// Outputs to the EU
//
assign BIU_DONE                 = biu_done_int;
assign PFQ_EMPTY                = pfq_empty;
assign PFQ_ADDR_OUT             = pfq_addr_out_d1; 
assign BIU_SEGMENT              = biu_segment;
assign BIU_REGISTER_ES          = biu_register_es_d2;
assign BIU_REGISTER_SS          = biu_register_ss_d2;
assign BIU_REGISTER_CS          = biu_register_cs_d2;
assign BIU_REGISTER_DS          = biu_register_ds_d2;
assign BIU_REGISTER_RM          = biu_register_rm_d2;
assign BIU_REGISTER_REG         = biu_register_reg_d2;
assign BIU_RETURN_DATA          = biu_return_data_int_d2;
assign BIU_NMI_CAUGHT           = nmi_caught;



// Input signals from the EU requesting BIU processing.
//  eu_biu_strobe[1:0] are available for only one clock cycle and cause BIU to take immediate action.
//  eu_biu_req stays asserted until the BIU is available to service the request.
//  
assign eu_prefix_seg                   = EU_BIU_COMMAND[14];
assign eu_biu_strobe[1:0]              = EU_BIU_COMMAND[13:12]; // 01=opcode fetch 10=clock load 11=load segment register(eu_biu_req_code has the regiter#)
assign eu_biu_segment[1:0]             = EU_BIU_COMMAND[11:10];
assign eu_biu_req                      = EU_BIU_COMMAND[9];
assign eu_biu_req_code                 = EU_BIU_COMMAND[8:4];
assign eu_qs_out[1:0]                  = EU_BIU_COMMAND[3:2];  // Updated for every opcode fetch using biu_strobe and Jump request using eu_biu_rq
assign eu_segment_override_value[1:0]  = EU_BIU_COMMAND[1:0];



// Select either the current EU Segment or the Segment Override value.
assign biu_segment =  (eu_prefix_seg==1'b1) ? eu_segment_override_value  : eu_biu_segment;  

                                                   
assign biu_muxed_segment = (biu_segment==2'b00) ? biu_register_es :
                           (biu_segment==2'b01) ? biu_register_ss :
                           (biu_segment==2'b10) ? biu_register_cs :
                                                  biu_register_ds ;

                                                            
// Steer the Prefetch Queue to the EU
assign pfq_top_byte_int = (pfq_addr_out[1:0]==2'b00) ? pfq_entry0 : 
                      (pfq_addr_out[1:0]==2'b01) ? pfq_entry1 : 
                      (pfq_addr_out[1:0]==2'b10) ? pfq_entry2 : 
                                                   pfq_entry3 ;
  
assign PFQ_TOP_BYTE = pfq_top_byte_int_d1;  

// Generate the Prefetch Queue Flags
assign pfq_full  = ( (pfq_addr_in[2]!=pfq_addr_out[2]) && (pfq_addr_in[1:0]==pfq_addr_out[1:0]) ) ?  1'b1 : 1'b0;
assign pfq_empty = ( (pfq_addr_in[2]==pfq_addr_out[2]) && (pfq_addr_in[1:0]==pfq_addr_out[1:0]) ) ?  1'b1 : 1'b0;


// Instruction cycle accuracy counter. This can be tied to '1' to disable x86 cycle compatibiliy.
assign BIU_CLK_COUNTER_ZERO = (clock_cycle_counter==13'h0000) ? 1'b1 : 1'b0;


                                                        
//------------------------------------------------------------------------
//
// BIU State Machine
//
//------------------------------------------------------------------------
//

always @(posedge CORE_CLK_INT)
begin : BIU_STATE_MACHINE

  if (RESET_INT==1'b1)
    begin
      clk_d1 <= 'h0;
      clk_d2 <= 'h0;
      clk_d3 <= 'h0;
      clk_d4 <= 'h0;
      nmi_d1 <= 'h0;
      nmi_d2 <= 'h0;
      nmi_d3 <= 'h0;
      nmi_caught <= 'h0;
      eu_register_r3_d <= 'h0;
      eu_biu_req_caught <= 'h0;
      biu_register_cs <= 16'hFFFF;
      biu_register_es <= 'h0;
      biu_register_ss <= 'h0;
      biu_register_ds <= 'h0;
      biu_register_rm <= 'h0;
      biu_register_reg <= 'h0;
      clock_cycle_counter <= 'h0;
      pfq_addr_out <= 'h0;
      pfq_entry0 <= 'h0;
      pfq_entry1 <= 'h0;
      pfq_entry2 <= 'h0;
      pfq_entry3 <= 'h0;
      biu_state <= 8'hD0;
      pfq_write <= 'h0;
      pfq_addr_in <= 'h0;
      biu_return_data_int <= 'h0;
      biu_done_int <= 'h0;
      ready_d1 <= 'h0;
      ready_d2 <= 'h0;
      ready_d3 <= 'h0;
      eu_biu_req_d1 <= 'h0;
      latched_data_in <= 'h0;
      addr_out_temp <= 'h0;
      s_bits <= 3'b111;
      AD_OUT <= 'h0;
      word_cycle <= 1'b0;
      byte_num <= 1'b0;
      ad_in_int <= 'h0;
      BIU_INTR <= 'h0;
      eu_prefix_lock_d1 <= 'h0;
      eu_prefix_lock_d2 <= 'h0;
      intr_d1 <= 'h0;
      intr_d2 <= 'h0;
      intr_d3 <= 'h0;    
      
      AD_OE <= 'h0;
      RD_n <= 1'b1;
      WR_n <= 1'b1;
      IOM <= 'h0;
      DTR <= 'h0;
      DEN <= 1'b1;   
      INTA_n <= 1'b1;
      
    end
    
else    
  begin     

  
    // Register pipelining
    clk_d1 <= CLK;
    clk_d2 <= clk_d1;
    clk_d3 <= clk_d2;
    clk_d4 <= clk_d3;
    
    ready_d1 <= READY_IN;
    ready_d2 <= ready_d1;
    ready_d3 <= ready_d2;
    
    nmi_d1 <= NMI;
    nmi_d2 <= nmi_d1;
    nmi_d3 <= nmi_d2;
    
    intr_d1 <= INTR;
    intr_d2 <= intr_d1;
    intr_d3 <= intr_d2;
    
    
    // These signals may be pipelined from zero to two clocks.
    // They are currently pipelined by two clocks.
    biu_register_es_d1   <= biu_register_es;
    biu_register_ss_d1   <= biu_register_ss;      
    biu_register_cs_d1   <= biu_register_cs;      
    biu_register_ds_d1   <= biu_register_ds; 
    biu_register_rm_d1   <= biu_register_rm; 
    biu_register_reg_d1  <= biu_register_reg;
    biu_register_es_d2   <= biu_register_es_d1;
    biu_register_ss_d2   <= biu_register_ss_d1;       
    biu_register_cs_d2   <= biu_register_cs_d1;       
    biu_register_ds_d2   <= biu_register_ds_d1; 
    biu_register_rm_d2   <= biu_register_rm_d1; 
    biu_register_reg_d2  <= biu_register_reg_d1;
        

    // These signals may be pipelined from zero to one clock.
    // They are currently pipelined by one clock.
    pfq_top_byte_int_d1 <= pfq_top_byte_int;     
    pfq_addr_out_d1 <= pfq_addr_out;

    
    // This signal may be pipelined any number of clocks as 
    // long as is stable before BIU_DONE is asserted.
    biu_return_data_int_d1 <= biu_return_data_int;
    biu_return_data_int_d2 <= biu_return_data_int_d1;

    
      
    // NMI caught on it's rising edge
    if (nmi_d3==1'b0 && nmi_d2==1'b0 && nmi_d1==1'b1)
      begin
        nmi_caught <= 1'b1;
      end
    else if (BIU_NMI_DEBOUNCE==1'b1)
      begin
        nmi_caught <= 1'b0;
      end

    // INTR sampled on the rising edge of the CLK
    if (clk_d4==1'b0 && clk_d3==1'b0 && clk_d2==1'b1)
      begin
        BIU_INTR <= intr_d3;
      end
    
    eu_prefix_lock_d1 <= EU_PREFIX_LOCK;
    eu_prefix_lock_d2 <= eu_prefix_lock_d1;               

    
    // Register pipelining in and out of the BIU.
    eu_register_r3_d <= EU_REGISTER_R3;
    ad_in_int <= AD_IN;
        


    // Capture a bus request from the EU
    eu_biu_req_d1 <= eu_biu_req;
    if (eu_biu_req_d1==1'b0 && eu_biu_req==1'b1)
      begin
        eu_biu_req_caught <= 1'b1;
      end
    else if (biu_done_int==1'b1)
      begin
        eu_biu_req_caught <= 1'b0;
      end
                    

    
    // Strobe from EU to update the segment and addressing registers
    if (eu_biu_strobe==2'b11)
      begin
        case (eu_biu_req_code[2:0])  // synthesis parallel_case
          3'h0 : biu_register_es      <= EU_BIU_DATAOUT[15:0];
          3'h1 : biu_register_ss      <= EU_BIU_DATAOUT[15:0];
          3'h2 : biu_register_cs      <= EU_BIU_DATAOUT[15:0];
          3'h3 : biu_register_ds      <= EU_BIU_DATAOUT[15:0];
          3'h4 : biu_register_rm      <= EU_BIU_DATAOUT[15:0];
          3'h5 : biu_register_reg     <= EU_BIU_DATAOUT[15:0];
          default :  ;
        endcase
      end   

    
    // Strobe from EU to set the 8088 clock cycle counter
    if (eu_biu_strobe==2'b10)
      begin
        clock_cycle_counter <= EU_BIU_DATAOUT[12:0];
      end
    else if (clock_cycle_counter!=13'h0000)
      begin
        clock_cycle_counter <= clock_cycle_counter - 1;
      end
        


    // Prefetch Queue 
    // --------------
    // Increment the output address of the queue upon EU fetch request strobe.
    // Update/flush the Prefetch Queue when the EU asserts the Jump request.
    // Increment the input address during prefetch queue fetches.
    //---------------------------------------------------------------------------------
    if (eu_biu_req_caught==1'b1 && eu_biu_req_code==5'h19) 
      begin
        pfq_addr_out <= eu_register_r3_d; // Update the prefetch queue to the new address.
      end    
    else if (eu_biu_strobe==2'b01 && pfq_empty==1'b0)
      begin  
        pfq_addr_out <= pfq_addr_out + 1;  // Increment the current IP - Instruction Pointer
      end                         
        
        
    if (eu_biu_req_caught==1'b1 && eu_biu_req_code==5'h19) 
      begin
        pfq_addr_in <= eu_register_r3_d; // Update the prefetch queue to the new address.
      end    
    else if (pfq_write==1'b1)
      begin  
        pfq_addr_in <= pfq_addr_in + 1;
      end                         
      
      
      
    // Write to the selected prefetch queue entry.
    if (pfq_write==1'b1)
      begin
        case (pfq_addr_in[1:0])  // synthesis parallel_case
          2'b00 : pfq_entry0 <= latched_data_in[7:0];
          2'b01 : pfq_entry1 <= latched_data_in[7:0];
          2'b10 : pfq_entry2 <= latched_data_in[7:0];
          2'b11 : pfq_entry3 <= latched_data_in[7:0];
          default :  ;
          endcase    
      end       
      

      
      
    
    // 8088 BIU State Machine
    // ----------------------
    
    biu_state <= biu_state + 1'b1;
    case (biu_state) // synthesis parallel_case
      
      8'h00 : begin
                // Debounce signals
                pfq_write <= 1'b0;
                byte_num <= 1'b0;   
                word_cycle <= 1'b0;     
                

                if (eu_biu_req_caught==1'b1)
                  begin                 
                        
                    case (eu_biu_req_code)  // synthesis parallel_case
                                        
                      // Interrupt ACK Cycle 
                      8'h16 : begin                   
                                addr_out_temp <= { 4'h0 , eu_register_r3_d[15:0] };
                                //AD_OE <= 'h0;                   
                                word_cycle <= 1'b1;
                                s_bits <= 3'b000;
                                biu_state <= 8'h01;
                              end
                                  
                      // IO Byte Read 
                      8'h08 : begin
                                addr_out_temp <= { 4'h0 , eu_register_r3_d[15:0] };
                                s_bits <= 3'b001;
                                biu_state <= 8'h01;
                              end
                                 
                      // IO Word Read 
                      8'h1A : begin
                                addr_out_temp <= { 4'h0 , eu_register_r3_d[15:0] };
                                word_cycle <= 1'b1; 
                                s_bits <= 3'b001;
                                biu_state <= 8'h01;
                              end
                                                
                      // IO Byte Write 
                      8'h0A : begin
                                addr_out_temp <= { 4'h0 , eu_register_r3_d[15:0] };
                                s_bits <= 3'b010;
                                biu_state <= 8'h01;
                              end
                                                
                      // IO Word Write 
                      8'h1C : begin
                                addr_out_temp <= { 4'h0 , eu_register_r3_d[15:0] };
                                word_cycle <= 1'b1; 
                                s_bits <= 3'b010;
                                biu_state <= 8'h01;
                              end
                                                
                      // Halt Request 
                      8'h18 : begin
                                addr_out_temp <= { biu_register_cs[15:0] , 4'h0 } + pfq_addr_out[15:0] ;
                                s_bits <= 3'b011;
                                biu_state <= 8'h01;
                              end
                                            
                      // Memory Byte Read 
                      8'h0C : begin
                                addr_out_temp <= { biu_muxed_segment[15:0] , 4'h0 } + eu_register_r3_d[15:0];
                                s_bits <= 3'b101;
                                biu_state <= 8'h01;
                              end
                                                
                      // Memory Word Read 
                      8'h10 : begin
                                addr_out_temp <= { biu_muxed_segment[15:0] , 4'h0 } + eu_register_r3_d[15:0];
                                word_cycle <= 1'b1; 
                                s_bits <= 3'b101;
                                biu_state <= 8'h01;
                              end
                                                
                      // Memory Word Read from Stack Segment
                      8'h11 : begin
                                addr_out_temp <= { biu_register_ss[15:0] , 4'h0 } + eu_register_r3_d[15:0];
                                word_cycle <= 1'b1; 
                                s_bits <= 3'b101;
                                biu_state <= 8'h01;
                              end
                                                
                      // Memory Word Read from Segment 0x0000 - Used for interrupt vector fetches
                      8'h12 : begin
                                addr_out_temp <= { 4'h0 , eu_register_r3_d[15:0] };
                                word_cycle <= 1'b1; 
                                s_bits <= 3'b101;
                                biu_state <= 8'h01;
                              end
                                                
                      // Memory Byte Write 
                      8'h0E : begin
                                addr_out_temp <= { biu_muxed_segment[15:0] , 4'h0 } + eu_register_r3_d[15:0];
                                s_bits <= 3'b110;
                                biu_state <= 8'h01;
                              end
                                                
                      // Memory Word Write 
                      8'h13 : begin
                                addr_out_temp <= { biu_muxed_segment[15:0] , 4'h0 } + eu_register_r3_d[15:0];
                                word_cycle <= 1'b1; 
                                s_bits <= 3'b110;
                                biu_state <= 8'h01;
                              end
                                                
                      // Memory Word Write to Stack Segment
                      8'h14 : begin
                                addr_out_temp <= { biu_register_ss[15:0] , 4'h0 } + eu_register_r3_d[15:0];
                                word_cycle <= 1'b1; 
                                s_bits <= 3'b110;
                                biu_state <= 8'h01;
                              end
                                                    
                      // Jump Request
                      8'h19 : begin
                                biu_done_int <= 1'b1;
                                biu_state <= 8'h46;
                              end
                                
                      default : ;             
                    endcase
                  end
                  
                  
                else if (pfq_full==1'b0)
                  begin
                    addr_out_temp <= { biu_register_cs[15:0] , 4'h0 } + pfq_addr_in[15:0] ;
                    s_bits <= 3'b100;
                    biu_state <= 8'h01;
                  end
                  
                else
                  begin
                    biu_state <= 8'h00;
                  end
                  
              end

              
              
      // 1 Wait for the rising edge of CLK to start the bus cycle; then assert IOM and DTR
      8'h01 : 
              begin                   
                if (clk_d4==1'b0 && clk_d3==1'b0 && clk_d2==1'b1) // Wait until next CLK rising edge
                  begin
                    IOM <= ~s_bits[2]; // Memory cycles
                    DTR <=  s_bits[1]; // Read cycles
                  end
                else
                  begin
                    biu_state <= 8'h01;
                  end
              end
        
      
      
      // 2 On the next falling CLK edge, assert the ALE and the address
      8'h04 : begin
                AD_OUT[19:0] <= addr_out_temp[19:0];
                AD_OE <= 1'b1;
                ALE <= 1'b1;

              end

              
              
      // 3 On the next rising CLK edge, disable ALE, drive early DEN
      8'h13 : begin
                ALE <= 1'b0;

                if (s_bits[1]==1'b1)
                  begin
                    DEN <= 1'b0;
                  end                               
                  
              end

              
      // 4 On the next falling CLK edge, float the AD[7:0] bus if it is a read cycle, and drive AD with write data
      8'h19 : begin
                AD_OE <= s_bits[1];  // Turn off bus drivers for read cycles
                RD_n  <= s_bits[1]; // Assert RD_n for read cycles
                WR_n  <= ~s_bits[1]; // Assert WR_n for write cycles
                
                if (s_bits==3'b000)
                  begin
                    INTA_n <= 1'b0;
                  end
                
                if (word_cycle==1'b1 && byte_num==1'b1)
                  begin
                    AD_OUT[7:0] <= EU_BIU_DATAOUT[15:8];
                  end
                else
                  begin
                    AD_OUT[7:0] <= EU_BIU_DATAOUT[7:0];
                  end   
          
              end
              
          
      // 5 On the next rising CLK edge, assert DEN is if has not been already
      8'h28 : begin
                DEN <= 1'b0;
              end
              
              
              
              
      // 6 On the next falling CLK edge, sample the READY signal
      8'h2F : begin  
                if (ready_d3==1'b0)    // Not ready yet, wait another clock cycle
                  begin
                    biu_state <= 8'h1A;
                  end
              end

              
              
      // 7 On the next rising CLK edge, sample the data.
      8'h3D : begin
                latched_data_in <= ad_in_int;
                
                // If a code fetch, then write data to the prefetch queue
                if (s_bits==3'b100)
                  begin
                     pfq_write <= 1'b1;
                  end            
                  
              end
                    
            
              
                    
      //  Debounce the prefetch queue write pulse and increment the prefetch queue address.
      8'h3E : begin
                pfq_write <= 1'b0; 
              end
            
            
            
      //  8 Steer the data
      8'h40 : begin
                if (s_bits!=3'b000 && (word_cycle==1'b1 && byte_num==1'b1))
                  begin
                    biu_return_data_int[15:8] <= latched_data_in[7:0];
                  end
                else
                  begin
                    biu_return_data_int[15:0] <= { 8'h00 , latched_data_in[7:0] };
                  end
              end
                
                
                
      // 8 On the next falling CLK edge, the cycle is complete.
      8'h45 : begin           
                WR_n <= 1'b1;
                RD_n <= 1'b1;
                DEN <= 1'b1;
                INTA_n <= 1'b1;

                
                 addr_out_temp[15:0] <=  addr_out_temp[15:0] + 1;
                 if (word_cycle==1'b1 && byte_num==1'b0)
                   begin        
                     byte_num <= 1'b1;                   
                     biu_state <= 8'h50;
                   end
                 else
                   begin
                     if (s_bits!=3'b100)
                       begin
                         biu_done_int <= 1'b1;
                       end
                   end
              end
             
              
      8'h46 : begin 
                biu_done_int <= 1'b0;               
              end
             
              
      8'h4E : begin 
                biu_state <= 8'h00;
              end
                
              
      8'h58 : begin 
                biu_state <= 8'h01;
              end

                 
      default : ;             
    endcase


    
end

end  // BIU

 
endmodule // biu.v
        
        
        
        
        
//
//
//  File Name   :  XTMax.ino
//  Used on     :  
//  Author      :  Ted Fried, MicroCore Labs
//  Creation    :  9/7/2024
//
//   Description:
//   ============
//   
//  Multi-function 8-bit ISA card using a Teensy 4.1.
//
//------------------------------------------------------------------------
//
// Modification History:
// =====================
//
// Revision 1 9/7/2024
// Initial revision
//
// Revision 2 10/5/2024
// Added support for SD to Parallel interface
//
// Revision 3 10/11/2024
// Added variable wait states for Expanded RAM
//  - For 4.77 Mhz, can be changed to zero wait states for Write cycles and two for Read cycles
//
//------------------------------------------------------------------------
//
// Copyright (c) 2024 Ted Fried
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
                                                  


#include <stdint.h>
#include <stdio.h>


// Teensy 4.1 pin assignments
//
#define PIN_BCLK            34      
#define PIN_BALE            5 
#define PIN_AEN             29      
#define PIN_CHRDY_OE_n      28 
#define PIN_CHRDY_OUT       6 
#define PIN_REFRESH         32      
#define PIN_MEMWR_n         33  
#define PIN_MEMRD_n         4 
#define PIN_IOWR_n          3 
#define PIN_IORD_n          2 
   
#define PIN_MUX_DATA_n      31      
#define PIN_DATA_OE_n       30      
#define PIN_MUX_ADDR_n      9 
#define PIN_TRIG_OUT        35 
  
#define PIN_ADDR19          27
#define PIN_ADDR18          26
#define PIN_ADDR17          39
#define PIN_ADDR16          38
#define PIN_ADDR15          21
#define PIN_ADDR14          20
#define PIN_ADDR13          23
#define PIN_ADDR12          22
#define PIN_ADDR11          16
#define PIN_ADDR10          17
#define PIN_ADDR9           41
#define PIN_ADDR8           40
#define PIN_AD7             15
#define PIN_AD6             14
#define PIN_AD5             18
#define PIN_AD4             19
#define PIN_AD3             25
#define PIN_AD2             24
#define PIN_AD1             0 
#define PIN_AD0             1 

#define PIN_DOUT7           37
#define PIN_DOUT6           36
#define PIN_DOUT5           7 
#define PIN_DOUT4           8 
#define PIN_DOUT3           13
#define PIN_DOUT2           11
#define PIN_DOUT1           12
#define PIN_DOUT0           10

#define PIN_PSRAM_D3        54    // GPIO9-29
#define PIN_PSRAM_D2        50    // GPIO9-28
#define PIN_PSRAM_D1        49    // GPIO9-27
#define PIN_PSRAM_D0        52    // GPIO9-26
#define PIN_PSRAM_CLK       53    // GPIO9-25
#define PIN_PSRAM_CS_n      48    // GPIO9-24

#define PIN_SD_CS_n         46    // GPIO8-17
#define PIN_SD_MOSI         45    // GPIO8-12
#define PIN_SD_CLK          44    // GPIO8-13
#define PIN_SD_MISO         43    // GPIO8-14



#define ADDRESS_DATA_GPIO6_UNSCRAMBLE   ( ((gpio6_int&0xFFFF0000)>>12) | ((gpio6_int&0x3000)>>10) | ((gpio6_int&0xC)>>2) )

#define GPIO7_DATA_OUT_UNSCRAMBLE        ( ( (isa_data_out&0xF0)<<12) | (isa_data_out&0x0F) )


#define DATA_OE_n_LOW      0x0
#define DATA_OE_n_HIGH     0x00800000
  
#define TRIG_OUT_LOW       0x0
#define TRIG_OUT_HIGH      0x10000000
                           
#define MUX_DATA_n_LOW     0x0
#define MUX_DATA_n_HIGH    0x00400000
                           
#define CHRDY_OUT_LOW      0x0
#define CHRDY_OUT_HIGH     0x00000400
                           
#define CHRDY_OE_n_LOW     0x0
#define CHRDY_OE_n_HIGH    0x00040000
                           
#define MUX_ADDR_n_LOW     0x0
#define MUX_ADDR_n_HIGH    0x00000800

#define PSRAM_RESET_VALUE  0x01000000
#define PSRAM_CLK_HIGH     0x02000000

    
// --------------------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------------------


uint32_t  trigger_out = 0;
uint32_t  gpio6_int = 0;
uint32_t  gpio9_int = 0;
uint32_t  isa_address = 0;
uint32_t  page_base_address = 0;
uint32_t  psram_address = 0;
uint32_t  sd_pin_outputs = 0;

uint8_t  data_in = 0;
uint8_t  isa_data_out = 0;
uint8_t  lpt_data = 0;
uint8_t  lpt_status = 0x6F;
uint8_t  lpt_control = 0xEC;
uint8_t  nibble_in =0;
uint8_t  nibble_out =0;
uint8_t  read_byte =0;
uint8_t  reg_0x260 =0;
uint8_t  reg_0x261 =0;
uint8_t  reg_0x262 =0;
uint8_t  reg_0x263 =0;

uint8_t  internal_RAM[0x60000];


// --------------------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------------------

// Setup Teensy 4.1 IO's
//
void setup() {
 
  pinMode(PIN_BCLK,           INPUT);    
  pinMode(PIN_BALE,           INPUT);
  pinMode(PIN_AEN,            INPUT);    
  pinMode(PIN_CHRDY_OE_n,     OUTPUT);
  pinMode(PIN_CHRDY_OUT,      OUTPUT);
  pinMode(PIN_REFRESH,        INPUT);    
  pinMode(PIN_MEMWR_n,        INPUT);
  pinMode(PIN_MEMRD_n,        INPUT);
  pinMode(PIN_IOWR_n,         INPUT);
  pinMode(PIN_IORD_n,         INPUT);
  
  pinMode(PIN_MUX_DATA_n,     OUTPUT);    
  pinMode(PIN_DATA_OE_n,      OUTPUT);    
  pinMode(PIN_MUX_ADDR_n,     OUTPUT);
  pinMode(PIN_TRIG_OUT,       OUTPUT);
  
  pinMode(PIN_ADDR19,         INPUT);
  pinMode(PIN_ADDR18,         INPUT);
  pinMode(PIN_ADDR17,         INPUT);
  pinMode(PIN_ADDR16,         INPUT);
  pinMode(PIN_ADDR15,         INPUT);
  pinMode(PIN_ADDR14,         INPUT);
  pinMode(PIN_ADDR13,         INPUT);
  pinMode(PIN_ADDR12,         INPUT);
  pinMode(PIN_ADDR11,         INPUT);
  pinMode(PIN_ADDR10,         INPUT);
  pinMode(PIN_ADDR9,          INPUT);
  pinMode(PIN_ADDR8,          INPUT);
  pinMode(PIN_AD7,            INPUT);
  pinMode(PIN_AD6,            INPUT);
  pinMode(PIN_AD5,            INPUT);
  pinMode(PIN_AD4,            INPUT);
  pinMode(PIN_AD3,            INPUT);
  pinMode(PIN_AD2,            INPUT);
  pinMode(PIN_AD1,            INPUT);
  pinMode(PIN_AD0,            INPUT);
  
  pinMode(PIN_DOUT7,          OUTPUT);
  pinMode(PIN_DOUT6,          OUTPUT);
  pinMode(PIN_DOUT5,          OUTPUT);
  pinMode(PIN_DOUT4,          OUTPUT);
  pinMode(PIN_DOUT3,          OUTPUT);
  pinMode(PIN_DOUT2,          OUTPUT);
  pinMode(PIN_DOUT1,          OUTPUT);
  pinMode(PIN_DOUT0,          OUTPUT);
  
  pinMode(PIN_PSRAM_CLK,      OUTPUT);                   
  pinMode(PIN_PSRAM_CS_n,     OUTPUT);                   
  pinMode(PIN_PSRAM_D3,       INPUT);                    
  pinMode(PIN_PSRAM_D2,       INPUT);
  pinMode(PIN_PSRAM_D1,       INPUT);
  pinMode(PIN_PSRAM_D0,       OUTPUT);
  
  
  pinMode(PIN_SD_CLK,         OUTPUT);
  pinMode(PIN_SD_CS_n,        OUTPUT);
  pinMode(PIN_SD_MOSI,        OUTPUT);
  pinMode(PIN_SD_MISO,        INPUT_PULLUP);


  GPIO9_DR = PSRAM_RESET_VALUE;  // Set CLK=0, CS_n=1, DATA=0
  
  digitalWriteFast(PIN_CHRDY_OE_n,   0x1);
  digitalWriteFast(PIN_CHRDY_OUT,    0x0);
  
  digitalWriteFast(PIN_DATA_OE_n,    0x1);
  digitalWriteFast(PIN_MUX_ADDR_n,   0x0);
  digitalWriteFast(PIN_MUX_DATA_n,   0x1);
  digitalWriteFast(PIN_TRIG_OUT,     0x1);
  

  //noInterrupts();                                   // Disable Teensy interupts
  
  //Serial.begin(9600);

}





// --------------------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------------------

inline void PSRAM_Write_Clk_Cycle() {
  
  GPIO9_DR = (nibble_out&0xF) << 26;               // Drive nibble data , CLK=0 , CS_n=0
  delayNanoseconds(1);
  GPIO9_DR = (nibble_out<<26) | PSRAM_CLK_HIGH;    // Drive nibble data and CLK=1
  delayNanoseconds(1);
  
  return;
}

// --------------------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------------------

inline void PSRAM_Read_Clk_Cycle() {
  
  GPIO9_DR = 0x0;                                  // Drive  CLK=0 , CS_n=0
  delayNanoseconds(1);
  GPIO9_DR = PSRAM_CLK_HIGH;                       // Drive  CLK=1
  delayNanoseconds(1);
  nibble_in = (GPIO9_DR>>26) & 0xF;                // Sample nibble data  
  
  return;
}


// --------------------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------------------

inline void PSRAM_Configure() {

  delayMicroseconds(200);

  nibble_out = 0x0;    PSRAM_Write_Clk_Cycle();     // Set PSRAM to Quad Mode 0x35
  nibble_out = 0x0;    PSRAM_Write_Clk_Cycle();  
  nibble_out = 0x1;    PSRAM_Write_Clk_Cycle();  
  nibble_out = 0x1;    PSRAM_Write_Clk_Cycle();  
  
  nibble_out = 0x0;    PSRAM_Write_Clk_Cycle();  
  nibble_out = 0x1;    PSRAM_Write_Clk_Cycle();  
  nibble_out = 0x0;    PSRAM_Write_Clk_Cycle();  
  nibble_out = 0x1;    PSRAM_Write_Clk_Cycle();  
  
  GPIO9_DR = PSRAM_RESET_VALUE;                     // Drive  CLK=0 , CS_n=1

  
  GPIO9_GDIR = 0x3F000000;                          // Change Data[3:0] to outputs quickly

  
  return;
}

// --------------------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------------------

inline uint8_t PSRAM_Read(uint32_t address_in) {

// Send Command = Quad Read = 0x0B
//
  nibble_out = 0x0;    PSRAM_Write_Clk_Cycle();  
  nibble_out = 0xB;    PSRAM_Write_Clk_Cycle();  


// Send 24-bit address in four clock cycles
//
  nibble_out = address_in >> 20;   PSRAM_Write_Clk_Cycle();
  nibble_out = address_in >> 16;   PSRAM_Write_Clk_Cycle();
  nibble_out = address_in >> 12;   PSRAM_Write_Clk_Cycle();
  nibble_out = address_in >> 8;    PSRAM_Write_Clk_Cycle();
  nibble_out = address_in >> 4;    PSRAM_Write_Clk_Cycle();
  nibble_out = address_in;         PSRAM_Write_Clk_Cycle();

  //GPIO8_DR = sd_pin_outputs + MUX_DATA_n_HIGH + CHRDY_OE_n_HIGH + DATA_OE_n_LOW;  // De-assert CHRDY early for 4.77 Mhz

  
 // Four clocks of hi-Z - Make PSRAM Data signals hi-Z during this time
 //
 GPIO9_GDIR = 0x03000000;                               // Change Data[3:0] to inputs quickly 
 PSRAM_Write_Clk_Cycle();  
 PSRAM_Write_Clk_Cycle();   
 PSRAM_Write_Clk_Cycle();   
 PSRAM_Write_Clk_Cycle();  


// Clock in the data
//
                   
  PSRAM_Read_Clk_Cycle();  read_byte = nibble_in;
  PSRAM_Read_Clk_Cycle();  read_byte = (read_byte<<4) | nibble_in;

  GPIO9_DR = PSRAM_RESET_VALUE;                       // Drive  CLK=0 , CS_n=1
  GPIO9_GDIR = 0x3F000000;                            // Change Data[3:0] to outputs quickly

return read_byte;
 }

 
// --------------------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------------------

inline uint8_t PSRAM_Write(uint32_t address_in , int8_t local_data) {


// Send Command = Quad Write = 0x02
//
  nibble_out = 0x0;    PSRAM_Write_Clk_Cycle(); 
  nibble_out = 0x2;    PSRAM_Write_Clk_Cycle(); 


// Send 24-bit address in four clock cycles
//
  nibble_out = address_in >> 20;   PSRAM_Write_Clk_Cycle();
  nibble_out = address_in >> 16;   PSRAM_Write_Clk_Cycle();
  nibble_out = address_in >> 12;   PSRAM_Write_Clk_Cycle();
  nibble_out = address_in >> 8;    PSRAM_Write_Clk_Cycle();
  nibble_out = address_in >> 4;    PSRAM_Write_Clk_Cycle();
  nibble_out = address_in;         PSRAM_Write_Clk_Cycle();

  //GPIO8_DR = sd_pin_outputs + MUX_DATA_n_HIGH + CHRDY_OE_n_HIGH + DATA_OE_n_LOW;  // De-assert CHRDY early for 4.77 Mhz

  
// Send byte data in twp clock cycles
//
  nibble_out = local_data >> 4;   PSRAM_Write_Clk_Cycle();
  nibble_out = local_data;        PSRAM_Write_Clk_Cycle();

  GPIO9_DR = PSRAM_RESET_VALUE;                       // Drive  CLK=0 , CS_n=1

return read_byte;
 }
 

// --------------------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------------------

inline void Mem_Read_Cycle() {
    
    isa_address = ADDRESS_DATA_GPIO6_UNSCRAMBLE;
    
    if ( (isa_address>=0xE0000) && (isa_address<0xF0000) )  {    // Expanded RAM page frame
      
      page_base_address   = (isa_address & 0xFC000);
 
           if (page_base_address == 0xEC000)  {  psram_address = (reg_0x263<<14) | (isa_address & 0x03FFF);  }
      else if (page_base_address == 0xE8000)  {  psram_address = (reg_0x262<<14) | (isa_address & 0x03FFF);  }
      else if (page_base_address == 0xE4000)  {  psram_address = (reg_0x261<<14) | (isa_address & 0x03FFF);  }
      else if (page_base_address == 0xE0000)  {  psram_address = (reg_0x260<<14) | (isa_address & 0x03FFF);  }
      
      GPIO7_DR = MUX_ADDR_n_LOW  + CHRDY_OUT_LOW + trigger_out;
      GPIO8_DR = sd_pin_outputs + MUX_DATA_n_HIGH + CHRDY_OE_n_LOW + DATA_OE_n_LOW ;  // Assert CHRDY_n=0 to begin wait states

      isa_data_out = PSRAM_Read(psram_address);      
      GPIO7_DR = GPIO7_DATA_OUT_UNSCRAMBLE + MUX_ADDR_n_LOW  + CHRDY_OUT_LOW + trigger_out;  // Output data 
	    GPIO8_DR = sd_pin_outputs + MUX_DATA_n_HIGH + CHRDY_OE_n_HIGH + DATA_OE_n_LOW;  // De-assert CHRDY

      
      
      while ( (gpio9_int&0xF0) != 0xF0 ) { gpio9_int = GPIO9_DR; }  // Wait here until cycle is complete
      
      GPIO8_DR = sd_pin_outputs + MUX_DATA_n_HIGH + CHRDY_OE_n_HIGH + DATA_OE_n_HIGH;
    }
    
    
  else if ( (isa_address>=0x40000) && (isa_address<0xA0000) )  {    // 384 KB
      isa_data_out = internal_RAM[isa_address-0x40000];
      GPIO7_DR = GPIO7_DATA_OUT_UNSCRAMBLE + MUX_ADDR_n_LOW  + CHRDY_OUT_LOW + trigger_out;
      GPIO8_DR = sd_pin_outputs + MUX_DATA_n_HIGH + CHRDY_OE_n_HIGH + DATA_OE_n_LOW;
      
      while ( (gpio9_int&0xF0) != 0xF0 ) { gpio9_int = GPIO9_DR; }  // Wait here until cycle is complete
      
      GPIO8_DR = sd_pin_outputs + MUX_DATA_n_HIGH + CHRDY_OE_n_HIGH + DATA_OE_n_HIGH;
    }
    return;
}


// --------------------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------------------

inline void Mem_Write_Cycle() {
    
    isa_address = ADDRESS_DATA_GPIO6_UNSCRAMBLE;
    
    if ( (isa_address>=0xE0000) && (isa_address<0xF0000) )  {    // Expanded RAM page frame
      
      page_base_address   = (isa_address & 0xFC000);
 
           if (page_base_address == 0xEC000)  {  psram_address = (reg_0x263<<14) | (isa_address & 0x03FFF);  }
      else if (page_base_address == 0xE8000)  {  psram_address = (reg_0x262<<14) | (isa_address & 0x03FFF);  }
      else if (page_base_address == 0xE4000)  {  psram_address = (reg_0x261<<14) | (isa_address & 0x03FFF);  }
      else if (page_base_address == 0xE0000)  {  psram_address = (reg_0x260<<14) | (isa_address & 0x03FFF);  }
    
      GPIO7_DR = GPIO7_DATA_OUT_UNSCRAMBLE + MUX_ADDR_n_HIGH  + CHRDY_OUT_LOW + trigger_out;
      GPIO8_DR = sd_pin_outputs + MUX_DATA_n_LOW + CHRDY_OE_n_LOW + DATA_OE_n_HIGH;    // Steer data mux to Data[7:0] and Assert CHRDY_n=0 to begin wait states

      delayNanoseconds(10);  // Wait some time for buffers to switch from address to data
    
      gpio6_int = GPIO6_DR;
      data_in = 0xFF & ADDRESS_DATA_GPIO6_UNSCRAMBLE;
      PSRAM_Write(psram_address , data_in);  
	    GPIO8_DR = sd_pin_outputs + MUX_DATA_n_LOW + CHRDY_OE_n_HIGH + DATA_OE_n_HIGH;  // De-assert CHRDY

     
      while ( (gpio9_int&0xF0) != 0xF0 ) {   // Wait here until cycle is complete
        gpio6_int = GPIO6_DR;   // Needed?
        gpio9_int = GPIO9_DR; 
        }  
      
      GPIO7_DR = GPIO7_DATA_OUT_UNSCRAMBLE + MUX_ADDR_n_LOW  + CHRDY_OUT_LOW + trigger_out;
      GPIO8_DR = sd_pin_outputs + MUX_DATA_n_HIGH + CHRDY_OE_n_HIGH + DATA_OE_n_HIGH;
    }   
        
    
    else if ( (isa_address>=0x40000) && (isa_address<0xA0000) )  {    // 384 KB
      GPIO7_DR = GPIO7_DATA_OUT_UNSCRAMBLE + MUX_ADDR_n_HIGH  + CHRDY_OUT_LOW + trigger_out;
      GPIO8_DR = sd_pin_outputs + MUX_DATA_n_LOW + CHRDY_OE_n_HIGH + DATA_OE_n_HIGH;
    
      while ( (gpio9_int&0xF0) != 0xF0 ) {   // Wait here until cycle is complete
        gpio6_int = GPIO6_DR;   // Needed?
        gpio9_int = GPIO9_DR; 
        }  
      
      internal_RAM[isa_address-0x40000] = 0xFF & ADDRESS_DATA_GPIO6_UNSCRAMBLE;
      
      GPIO7_DR = GPIO7_DATA_OUT_UNSCRAMBLE + MUX_ADDR_n_LOW  + CHRDY_OUT_LOW + trigger_out;
      GPIO8_DR = sd_pin_outputs + MUX_DATA_n_HIGH + CHRDY_OE_n_HIGH + DATA_OE_n_HIGH;
    }
    return;
}



// --------------------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------------------

inline void IO_Read_Cycle() {
    
    isa_address = 0xFFFF & ADDRESS_DATA_GPIO6_UNSCRAMBLE;
    
    if ((isa_address&0x0FFC)==0x260 )  {   // Location of 16 KB Expanded Memory page frame pointers
  
      switch (isa_address)  {
        case 0x260:  isa_data_out = reg_0x260;  break;
        case 0x261:  isa_data_out = reg_0x261;  break;
        case 0x262:  isa_data_out = reg_0x262;  break;
        case 0x263:  isa_data_out = reg_0x263;  break;
      }
      
      GPIO7_DR = GPIO7_DATA_OUT_UNSCRAMBLE + MUX_ADDR_n_LOW  + CHRDY_OUT_LOW + trigger_out;
      GPIO8_DR = sd_pin_outputs + MUX_DATA_n_HIGH + CHRDY_OE_n_HIGH + DATA_OE_n_LOW;
      
      while ( (gpio9_int&0xF0) != 0xF0 ) { gpio9_int = GPIO9_DR; }  // Wait here until cycle is complete
      
      GPIO8_DR = sd_pin_outputs + MUX_DATA_n_HIGH + CHRDY_OE_n_HIGH + DATA_OE_n_HIGH;
    }
    
        
    else if ((isa_address&0x0FF8)==0x378 )  {   // Location of Parallel Port
  
      if ((GPIO8_DR&0x00004000)!=0) { lpt_status = lpt_status | 0xFF;   }  
      else                          { lpt_status = lpt_status & 0x00;   } // PIN_SD_MISO    43    GPIO8-14
  

      switch (isa_address)  {
          case 0x378:  isa_data_out = lpt_data;     break;
          case 0x379:  isa_data_out = lpt_status;   break;
          case 0x37A:  isa_data_out = lpt_control;  break;
      }
      
      GPIO7_DR = GPIO7_DATA_OUT_UNSCRAMBLE + MUX_ADDR_n_LOW  + CHRDY_OUT_LOW + trigger_out;
      GPIO8_DR = sd_pin_outputs + MUX_DATA_n_HIGH + CHRDY_OE_n_HIGH + DATA_OE_n_LOW;
      
      while ( (gpio9_int&0xF0) != 0xF0 ) { gpio9_int = GPIO9_DR; }  // Wait here until cycle is complete
      
      GPIO8_DR = sd_pin_outputs + MUX_DATA_n_HIGH + CHRDY_OE_n_HIGH + DATA_OE_n_HIGH;
    }
    
    return;
}
    

// --------------------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------------------

inline void IO_Write_Cycle() {
    
    isa_address = 0xFFFF & ADDRESS_DATA_GPIO6_UNSCRAMBLE;
    
    if ((isa_address&0x0FFC)==0x260 )  {   // Location of 16 KB Expanded Memory page frame pointers
      GPIO7_DR = GPIO7_DATA_OUT_UNSCRAMBLE + MUX_ADDR_n_HIGH  + CHRDY_OUT_LOW + trigger_out;
      GPIO8_DR = sd_pin_outputs + MUX_DATA_n_LOW + CHRDY_OE_n_HIGH + DATA_OE_n_HIGH;
    
      while ( (gpio9_int&0xF0) != 0xF0 ) {   // Wait here until cycle is complete
        gpio6_int = GPIO6_DR;  // Needed?
        gpio9_int = GPIO9_DR; 
        }  

      data_in = 0xFF & ADDRESS_DATA_GPIO6_UNSCRAMBLE;
      
      switch (isa_address)  {
        case 0x260:  reg_0x260 = data_in;  break;
        case 0x261:  reg_0x261 = data_in;  break;
        case 0x262:  reg_0x262 = data_in;  break;
        case 0x263:  reg_0x263 = data_in;  break;
      }
           
      GPIO7_DR = GPIO7_DATA_OUT_UNSCRAMBLE + MUX_ADDR_n_LOW  + CHRDY_OUT_LOW + trigger_out;
      GPIO8_DR = sd_pin_outputs + MUX_DATA_n_HIGH + CHRDY_OE_n_HIGH + DATA_OE_n_HIGH;
    }
    
    else if ((isa_address&0x0FF8)==0x378 )  {   // Location of Parallel Port
      GPIO7_DR = GPIO7_DATA_OUT_UNSCRAMBLE + MUX_ADDR_n_HIGH  + CHRDY_OUT_LOW + trigger_out;
      GPIO8_DR = sd_pin_outputs + MUX_DATA_n_LOW + CHRDY_OE_n_HIGH + DATA_OE_n_HIGH;
    
      while ( (gpio9_int&0xF0) != 0xF0 ) {   // Wait here until cycle is complete
        gpio6_int = GPIO6_DR;  // Needed?
        gpio9_int = GPIO9_DR; 
        }  

      data_in = 0xFF & ADDRESS_DATA_GPIO6_UNSCRAMBLE;
      
      switch (isa_address)  {
        case 0x378:  lpt_data    = data_in;  break;
        case 0x37A:  lpt_control = data_in;  break;
      }

      sd_pin_outputs = ((lpt_data&0x4)<<15) | ((lpt_data&0x2)<<12) | ((lpt_data&0x1)<<12);   // lpt_data[2]=SD_CS_n - lpt_data[1]=SD_CLK - lpt_data[0]=SD_MOSI
      
      //trigger_out = ((lpt_data&0x1)<<28); // SD_MOSI
      //trigger_out = ((lpt_data&0x2)<<27); // SD_CLK
      //trigger_out = ((lpt_data&0x4)<<26); // SD_CS_n
           
      GPIO7_DR = GPIO7_DATA_OUT_UNSCRAMBLE + MUX_ADDR_n_LOW  + CHRDY_OUT_LOW + trigger_out;
      GPIO8_DR = sd_pin_outputs + MUX_DATA_n_HIGH + CHRDY_OE_n_HIGH + DATA_OE_n_HIGH;
    }
    
    return;
}


    
// -------------------------------------------------
//
// Main loop
//
// -------------------------------------------------
void loop() {


  // Give Teensy 4.1 a moment
  //
  //delay (1000);

  PSRAM_Configure();

  while (1) {
      
      
      gpio6_int = GPIO6_DR;
      gpio9_int = GPIO9_DR;
      
           if ((gpio9_int&0x80000010)==0)  IO_Read_Cycle();  // Isolate and check AEN and IO Rd/Wr
      else if ((gpio9_int&0x80000020)==0)  IO_Write_Cycle();
      else if ((gpio9_int&0x00000040)==0)  Mem_Read_Cycle();
      else if ((gpio9_int&0x00000080)==0)  Mem_Write_Cycle();     
  } 
}     
    

  
  
  

   
   

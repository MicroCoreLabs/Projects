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


# define ADDRESS_DATA_GPIO6_UNSCRAMBLE   ( ((gpio6_int&0xFFFF0000)>>12) | ((gpio6_int&0x3000)>>10) | ((gpio6_int&0xC)>>2) )


#define DATA_OE_n_LOW     0xFF7FFFFF
#define DATA_OE_n_HIGH    0x00800000

#define MUX_DATA_n_LOW    0xFFBFFFFF
#define MUX_DATA_n_HIGH   0x00400000

#define CHRDY_OE_n_LOW    0xFFFBFFFF
#define CHRDY_OE_n_HIGH   0x00040000

#define MUX_ADDR_n_LOW    0xFFFFF7FF
#define MUX_ADDR_n_HIGH   0x00000800


    
// --------------------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------------------

uint8_t   io_scratch = 0x5A;
uint32_t  gpio6_int = 0;
uint32_t  gpio9_int = 0;
uint32_t  isa_address = 0;

uint8_t  data_in = 0;
uint8_t  isa_data_out = 0;
uint8_t  lpt_data = 0;
uint8_t  lpt_status = 0xD8;
uint8_t  lpt_control = 0xC;
      
uint8_t   internal_RAM[0x60000];


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

void Mem_Read_Cycle() {
    
    gpio6_int = GPIO6_DR;
    isa_address = ADDRESS_DATA_GPIO6_UNSCRAMBLE;
    
  if ( (isa_address>=0x40000) && (isa_address<0xA0000) )  {    // 384 KB
      isa_data_out = internal_RAM[isa_address-0x40000];
      GPIO7_DR = ((isa_data_out&0xF0)<<12) | (isa_data_out&0x0F) ;
      GPIO8_DR = (MUX_DATA_n_HIGH | CHRDY_OE_n_HIGH) & DATA_OE_n_LOW;
      
      while ( (gpio9_int&0xF0) != 0xF0 ) { gpio9_int = GPIO9_DR; }  // Wait here until cycle is complete
      
      GPIO8_DR = DATA_OE_n_HIGH | MUX_DATA_n_HIGH | CHRDY_OE_n_HIGH;
    }
    return;
}

// --------------------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------------------

void Mem_Write_Cycle() {
    
    gpio6_int = GPIO6_DR;
    isa_address = ADDRESS_DATA_GPIO6_UNSCRAMBLE;
    
    if ( (isa_address>=0x40000) && (isa_address<0xA0000) )  {    // 384 KB
      GPIO7_DR = MUX_ADDR_n_HIGH;   
      GPIO8_DR = (DATA_OE_n_HIGH | CHRDY_OE_n_HIGH) & MUX_DATA_n_LOW;
    
      while ( (gpio9_int&0xF0) != 0xF0 ) {   // Wait here until cycle is complete
        gpio6_int = GPIO6_DR; 
        gpio9_int = GPIO9_DR; 
        }  
      
      internal_RAM[isa_address-0x40000] = 0xFF & ADDRESS_DATA_GPIO6_UNSCRAMBLE;
      
      GPIO7_DR = MUX_ADDR_n_LOW; 
      GPIO8_DR = DATA_OE_n_HIGH | MUX_DATA_n_HIGH | CHRDY_OE_n_HIGH;
    }
    return;
}

// --------------------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------------------

void IO_Read_Cycle() {
    
    gpio6_int = GPIO6_DR;
    isa_address = 0xFFFF & ADDRESS_DATA_GPIO6_UNSCRAMBLE;
    
    if ((isa_address&0x0FF8)==0x378 )  {   // Location of Parallel Port
      switch (isa_address)  {
          case 0x378:  isa_data_out = lpt_data;     break;
          case 0x379:  isa_data_out = lpt_status;   break;
          case 0x37A:  isa_data_out = lpt_control;  break;
      }
      
      GPIO7_DR = ((isa_data_out&0xF0)<<12) | (isa_data_out&0x0F) ;
      GPIO8_DR = (MUX_DATA_n_HIGH | CHRDY_OE_n_HIGH) & DATA_OE_n_LOW;
      
      while ( (gpio9_int&0xF0) != 0xF0 ) { gpio9_int = GPIO9_DR; }  // Wait here until cycle is complete
      
      GPIO8_DR = DATA_OE_n_HIGH | MUX_DATA_n_HIGH | CHRDY_OE_n_HIGH;
    }
    return;
}



// --------------------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------------------

void IO_Write_Cycle() {
    
    gpio6_int = GPIO6_DR;
    isa_address = 0xFFFF & ADDRESS_DATA_GPIO6_UNSCRAMBLE;
    
  if ((isa_address&0x0FF8)==0x378 )  {   // Location of Parallel Port
      GPIO7_DR = MUX_ADDR_n_HIGH;   
      GPIO8_DR = (DATA_OE_n_HIGH | CHRDY_OE_n_HIGH) & MUX_DATA_n_LOW;
    
      while ( (gpio9_int&0xF0) != 0xF0 ) {   // Wait here until cycle is complete
        gpio6_int = GPIO6_DR; 
        gpio9_int = GPIO9_DR; 
        }  

      data_in = 0xFF & ADDRESS_DATA_GPIO6_UNSCRAMBLE;
      
    switch (isa_address)  {
        case 0x378:  lpt_data    = data_in;  break;
        case 0x37A:  lpt_control = data_in;  break;
      }
      
      
      GPIO7_DR = MUX_ADDR_n_LOW; 
      GPIO8_DR = DATA_OE_n_HIGH | MUX_DATA_n_HIGH | CHRDY_OE_n_HIGH;

    //Serial.printf("%x %x",gpio6_int,data_in);
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


  while (1) {
      
      
      gpio9_int = GPIO9_DR;
      
           if ((gpio9_int&0x80000010)==0)  IO_Read_Cycle();  // Isolate and check AEN and IO Rd/Wr
      else if ((gpio9_int&0x80000020)==0)  IO_Write_Cycle();
      else if ((gpio9_int&0x00000040)==0)  Mem_Read_Cycle();
      else if ((gpio9_int&0x00000080)==0)  Mem_Write_Cycle();     
  } 
}     
    

  
  
  

   
   

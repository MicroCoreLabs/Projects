//
//
//  File Name   :  ROM_Emulator
//  Used on     :  
//  Author      :  Ted Fried, MicroCore Labs
//  Creation    :  3/20/2021
//
//   Description:
//   ============
//   
//  27Cxxx EPROM Emulator. When Teensy 4.0 run at 816Mhz the address to 
// data access time is less than 200ns.
//
//------------------------------------------------------------------------
//
// Modification History:
// =====================
//
// Revision 1 3/20/2021
// Initial revision
//
//
//------------------------------------------------------------------------
//
// Copyright (c) 2021 Ted Fried
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

// Teensy 4.0 pin assignments
//
#define PIN_DATA0          10
#define PIN_DATA1          11
#define PIN_DATA2          12
#define PIN_DATA3          13
#define PIN_DATA4          14
#define PIN_DATA5          15
#define PIN_DATA6          16
#define PIN_DATA7          17

#define PIN_ADDR0          18
#define PIN_ADDR1          19
#define PIN_ADDR2          20
#define PIN_ADDR3          9
#define PIN_ADDR4          7
#define PIN_ADDR5          5
#define PIN_ADDR6          22
#define PIN_ADDR7          4
#define PIN_ADDR8          23
#define PIN_ADDR9          21
#define PIN_ADDR10         8
#define PIN_ADDR11         6
#define PIN_ADDR12         2
#define PIN_ADDR13         3
#define PIN_ADDR14         1
#define PIN_ADDR15         0


uint8_t   memory_array[65536];



// Setup Teensy 4.0 IO's
//
void setup() {
    
  pinMode(PIN_DATA0,   OUTPUT);
  pinMode(PIN_DATA1,   OUTPUT);
  pinMode(PIN_DATA2,   OUTPUT);
  pinMode(PIN_DATA3,   OUTPUT);
  pinMode(PIN_DATA4,   OUTPUT);
  pinMode(PIN_DATA5,   OUTPUT);
  pinMode(PIN_DATA6,   OUTPUT);
  pinMode(PIN_DATA7,   OUTPUT);
  
  pinMode(PIN_ADDR0,   INPUT);
  pinMode(PIN_ADDR1,   INPUT);
  pinMode(PIN_ADDR2,   INPUT);
  pinMode(PIN_ADDR3,   INPUT);
  pinMode(PIN_ADDR4,   INPUT);
  pinMode(PIN_ADDR5,   INPUT);
  pinMode(PIN_ADDR6,   INPUT);
  pinMode(PIN_ADDR7,   INPUT);

  pinMode(PIN_ADDR8,   INPUT);
  pinMode(PIN_ADDR9,   INPUT);
  pinMode(PIN_ADDR10,  INPUT);
  pinMode(PIN_ADDR11,  INPUT);
  pinMode(PIN_ADDR12,  INPUT);
  pinMode(PIN_ADDR13,  INPUT);
  pinMode(PIN_ADDR14,  INPUT);
  pinMode(PIN_ADDR15,  INPUT);

}



// -------------------------------------------------
//
// Main loop
//
// -------------------------------------------------
void loop() {

  register uint8_t   data_out; 
  register uint16_t  address; 

  register uint32_t  GPIO6_data=0;
  register uint32_t  GPIO7_data=0;
  register uint32_t  GPIO9_data=0;


  GPIO6_data = GPIO6_DR;
  GPIO7_data = GPIO7_DR;
  GPIO9_data = GPIO9_DR;


  address   =   ( (GPIO6_data&0x00020000) >> 17 ) |   // A0  Teensy 4.0 PIN_18  GPIO6_DR[17]
                ( (GPIO6_data&0x00010000) >> 15 ) |   // A1  Teensy 4.0 PIN_19  GPIO6_DR[16]
                ( (GPIO6_data&0x04000000) >> 24 ) |   // A2  Teensy 4.0 PIN_20  GPIO6_DR[26]
                ( (GPIO7_data&0x00000800) >> 8  ) |   // A3  Teensy 4.0 PIN_9   GPIO7_DR[11]
               
                ( (GPIO7_data&0x00020000) >> 13 ) |   // A4  Teensy 4.0 PIN_7   GPIO7_DR[17]
                ( (GPIO9_data&0x00000100) >> 3  ) |   // A5  Teensy 4.0 PIN_5   GPIO9_DR[8]
                ( (GPIO6_data&0x01000000) >> 18 ) |   // A6  Teensy 4.0 PIN_22  GPIO6_DR[24]
                ( (GPIO9_data&0x00000040) << 1  ) |   // A7  Teensy 4.0 PIN_4   GPIO9_DR[6]
               
                ( (GPIO6_data&0x02000000) >> 17 ) |   // A8  Teensy 4.0 PIN_23  GPIO6_DR[25]
                ( (GPIO6_data&0x08000000) >> 18 ) |   // A9  Teensy 4.0 PIN_21  GPIO6_DR[27]
                ( (GPIO7_data&0x00010000) >> 6  ) |   // A10 Teensy 4.0 PIN_8   GPIO7_DR[16]
                ( (GPIO7_data&0x00000400) << 1  ) |   // A11 Teensy 4.0 PIN_6   GPIO7_DR[10]
               
                ( (GPIO9_data&0x00000010) << 8  ) |   // A12 Teensy 4.0 PIN_2   GPIO9_DR[4]
                ( (GPIO9_data&0x00000020) << 8  ) |   // A13 Teensy 4.0 PIN_3   GPIO9_DR[5]
                ( (GPIO6_data&0x00000004) << 12 ) |   // A14 Teensy 4.0 PIN_1   GPIO6_DR[2] 
                ( (GPIO6_data&0x00000008) << 12 ) ;   // A15 Teensy 4.0 PIN_0   GPIO6_DR[3] 


  address = (0x7FFF & address);  // PCjr has 32KB ROM
   
  data_out  = memory_array[address];
  GPIO6_DR  =((data_out & 0x80)<<15) | ((data_out & 0x40)<<17) |              ((data_out & 0x30)<<14) ;       // D[7:4]
  GPIO7_DR  = (data_out & 0x08)      | ((data_out & 0x02)<<1 ) | ((data_out & 0x04)>>1) |  (data_out & 0x01); // D[3:0]
    
 }

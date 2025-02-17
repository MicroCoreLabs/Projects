//
//
//  File Name   :  XTMax.ino
//  Used on     : 
//  Authors     :  Ted Fried, MicroCore Labs
//                 Matthieu Bucchianeri
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
// Revision 4 11/11/2024
// - Updated MicroSD support and conventional memory to 640 KB
//
// Revision 5 11/26/2024
// - XTMax automatically configured addition to conventional memory to 640 KB
//
// Revision 6 12/14/2024
// - Made SD LPT base a # define
//
// Revision 7 01/12/2025
// - Refactor SD card I/O
// - Add support for 16-bit EMS page offsets
//
// Revision 8 01/20/2025
// - Added chip select for a second PSRAM to allow access to 16 MB of Expanded RAM
//
// Revision 9 01/26/2025
// - Add support for BIOS ROM extension (Boot ROM)
// - Add scrach registers for Boot ROM hooking
//
// Revision 10 02/17/2025
// - Use a lookup table for the memory map
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

#include "bootrom.h"


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
#define PIN_DOUT2           11  // temp spi_mosi
#define PIN_DOUT1           12  // temp spi_cs
#define PIN_DOUT0           10  // temp spi clk

#define PIN_PSRAM_D3        54    // GPIO9-29
#define PIN_PSRAM_D2        50    // GPIO9-28
#define PIN_PSRAM_D1        49    // GPIO9-27
#define PIN_PSRAM_D0        52    // GPIO9-26
#define PIN_PSRAM_CLK       53    // GPIO9-25
#define PIN_PSRAM_CS_n      48    // GPIO9-24
#define PIN_PSRAM_CS1_n     51    // GPIO9-22

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

#define PSRAM_RESET_VALUE  0x01400000
#define PSRAM_CLK_HIGH     0x02000000

#define EMS_BASE_IO        0x260    // Must be a multiple of 8.
#define EMS_BASE_MEM       0xD0000

#define EMS_TOTAL_SIZE     (16*1024*1024)

#define SD_BASE            0x280  // Must be a multiple of 8.
#define SD_CONFIG_BYTE     0

    
// --------------------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------------------

uint32_t  trigger_out = 0;
uint32_t  gpio6_int = 0;
uint32_t  gpio9_int = 0;
uint32_t  isa_address = 0;
uint32_t  page_base_address = 0;
uint32_t  psram_address = 0;
uint32_t  sd_pin_outputs = 0;
uint32_t  databit_out = 0;

uint8_t   data_in = 0;
uint8_t   isa_data_out = 0;
uint8_t   nibble_in =0;
uint8_t   nibble_out =0;
uint8_t   read_byte =0;
uint16_t  ems_frame_pointer[4] = {0, 0, 0, 0};
uint8_t   spi_shift_out =0;
uint8_t   sd_spi_datain =0;
uint32_t  sd_spi_cs_n = 0x0;
uint32_t  sd_spi_dataout =0;
uint8_t   sd_scratch_register[6] = {0, 0, 0, 0, 0, 0};
uint16_t  sd_requested_timeout = 0;
elapsedMillis sd_timeout;

uint8_t XTMax_MEM_Response_Array[16];

DMAMEM  uint8_t  internal_RAM1[0x60000];
        uint8_t  internal_RAM2[0x40000];

uint8_t psram_cs =0;

enum Region {
  Unused,
  Ram,
  EmsWindow,
  BootRom,
  SdCard
};

Region memmap[512];

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
  pinMode(PIN_PSRAM_CS1_n,    OUTPUT);                   
  pinMode(PIN_PSRAM_D3,       INPUT);                   
  pinMode(PIN_PSRAM_D2,       INPUT);
  pinMode(PIN_PSRAM_D1,       INPUT);
  pinMode(PIN_PSRAM_D0,       OUTPUT);
 
 
  pinMode(PIN_SD_CLK,         OUTPUT);
  pinMode(PIN_SD_CS_n,        OUTPUT);
  pinMode(PIN_SD_MOSI,        OUTPUT);
  pinMode(PIN_SD_MISO,        INPUT_PULLUP);


  GPIO9_DR = PSRAM_RESET_VALUE;  // Set CLK=0, CSx_n=1, DATA=0
 
  digitalWriteFast(PIN_CHRDY_OE_n,   0x1);
  digitalWriteFast(PIN_CHRDY_OUT,    0x0);
 
  digitalWriteFast(PIN_DATA_OE_n,    0x1);
  digitalWriteFast(PIN_MUX_ADDR_n,   0x0);
  digitalWriteFast(PIN_MUX_DATA_n,   0x1);
  digitalWriteFast(PIN_TRIG_OUT,     0x1);
 

  //noInterrupts();                                   // Disable Teensy interupts
 
  //Serial.begin(9600);

  // Populate the memory map.
  unsigned int i;
  for (i = 0; i < sizeof(memmap)/sizeof(memmap[0]); i++) {
    memmap[i] = Unused;
  }

  for (i = 0;
       i < (0xA0000 >> 11);
       i++) {
    memmap[i] = Ram;
  }

  static_assert((EMS_BASE_MEM & 0x7FF) == 0);
  for (i = (EMS_BASE_MEM >> 11);
       i < ((EMS_BASE_MEM+0x10000) >> 11);
       i++) {
    memmap[i] = EmsWindow;
  }

  static_assert((BOOTROM_ADDR & 0x7FF) == 0);
  static_assert((sizeof(BOOTROM) % 2048) == 0, "BootROM must be in blocks of 2KB");
  for (i = (BOOTROM_ADDR >> 11);
       i < ((BOOTROM_ADDR+sizeof(BOOTROM)) >> 11);
       i++) {
    memmap[i] = BootRom;
  }

  memmap[(BOOTROM_ADDR+sizeof(BOOTROM)) >> 11] = SdCard;
}


// --------------------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------------------

inline void SD_SPI_TXRXBit()  {
   
    // Drive CLK low and MOSI
    //
    GPIO7_DR = GPIO7_DR & 0xE0000000;  // Trigger out
    sd_pin_outputs = (sd_spi_cs_n<<17) | (0x0<<13) | databit_out;                      // SD_CS_n - SD_CLK - SD_MOSI
    GPIO8_DR = sd_pin_outputs + MUX_DATA_n_HIGH + CHRDY_OE_n_LOW + DATA_OE_n_HIGH;
    delayNanoseconds(10);
   
    // Drive CLK high
    //
    GPIO7_DR = GPIO7_DR | 0x10000000;  // Trigger out
    sd_pin_outputs = (sd_spi_cs_n<<17) | (0x1<<13) | databit_out;                      // SD_CS_n - SD_CLK - SD_MOSI
    GPIO8_DR = sd_pin_outputs + MUX_DATA_n_HIGH + CHRDY_OE_n_LOW + DATA_OE_n_HIGH;
    sd_spi_datain = sd_spi_datain << 1;
    if ((GPIO8_DR&0x00004000)!=0) {sd_spi_datain = sd_spi_datain | 0x01; }             // Shift in MISO data
    delayNanoseconds(10);

    // Drive CLK and MOSI low
    //
    sd_pin_outputs = (sd_spi_cs_n<<17) | (0x0<<13) | 0x0;                              // SD_CS_n - SD_CLK - SD_MOSI
    GPIO8_DR = sd_pin_outputs + MUX_DATA_n_HIGH + CHRDY_OE_n_LOW + DATA_OE_n_HIGH;
   
    return;
}

// --------------------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------------------

inline void SD_SPI_Cycle()  {
   
    GPIO8_DR = sd_pin_outputs + MUX_DATA_n_HIGH + CHRDY_OE_n_LOW + DATA_OE_n_HIGH ;  // Assert CHRDY_n=0 to begin wait states

    databit_out = ((sd_spi_dataout&0x80)<<5 );  SD_SPI_TXRXBit();  // Bit 7
    databit_out = ((sd_spi_dataout&0x40)<<6 );  SD_SPI_TXRXBit();  // Bit 6
    databit_out = ((sd_spi_dataout&0x20)<<7 );  SD_SPI_TXRXBit();  // Bit 5
    databit_out = ((sd_spi_dataout&0x10)<<8 );  SD_SPI_TXRXBit();  // Bit 4
    databit_out = ((sd_spi_dataout&0x08)<<9 );  SD_SPI_TXRXBit();  // Bit 3
    databit_out = ((sd_spi_dataout&0x04)<<10);  SD_SPI_TXRXBit();  // Bit 2
    databit_out = ((sd_spi_dataout&0x02)<<11);  SD_SPI_TXRXBit();  // Bit 1
    databit_out = ((sd_spi_dataout&0x01)<<12);  SD_SPI_TXRXBit();  // Bit 0

    GPIO8_DR = sd_pin_outputs + MUX_DATA_n_HIGH + CHRDY_OE_n_HIGH + DATA_OE_n_HIGH;  // De-assert CHRDY


  return;
}

// --------------------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------------------

inline void PSRAM_Write_Clk_Cycle() {
    
       if (psram_cs==7) GPIO9_DR = ((nibble_out&0xF) << 26) | 0x00000000;      // Drive nibble data , CLK=0 , CSx_n=0
  else if (psram_cs==0) GPIO9_DR = ((nibble_out&0xF) << 26) | 0x00400000;      // Drive nibble data , CLK=0 , CS_n=0
  else                  GPIO9_DR = ((nibble_out&0xF) << 26) | 0x01000000;      // Drive nibble data , CLK=0 , CS1_n=0
    
  delayNanoseconds(1);
  GPIO9_DR = GPIO9_DR | PSRAM_CLK_HIGH;    // Drive nibble data and CLK=1
  delayNanoseconds(1);
 
  return;
}

// --------------------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------------------

inline void PSRAM_Read_Clk_Cycle() {
 
       if (psram_cs==7) GPIO9_DR = 0x00000000;      // Drive CLK=0 , CSx_n=0
  else if (psram_cs==0) GPIO9_DR = 0x00400000;      // Drive CLK=0 , CS_n=0
  else                  GPIO9_DR = 0x01000000;      // Drive CLK=0 , CS1_n=0
    
  delayNanoseconds(1);
  GPIO9_DR = GPIO9_DR | PSRAM_CLK_HIGH;             // Drive  CLK=1
  delayNanoseconds(1);
  nibble_in = (GPIO9_DR>>26) & 0xF;                 // Sample nibble data 
 
  return;
}


// --------------------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------------------

inline void PSRAM_Configure() {

  delayMicroseconds(200);

  psram_cs=7;

  nibble_out = 0x0;    PSRAM_Write_Clk_Cycle();     // Set PSRAM to Quad Mode 0x35
  nibble_out = 0x0;    PSRAM_Write_Clk_Cycle(); 
  nibble_out = 0x1;    PSRAM_Write_Clk_Cycle(); 
  nibble_out = 0x1;    PSRAM_Write_Clk_Cycle(); 
 
  nibble_out = 0x0;    PSRAM_Write_Clk_Cycle(); 
  nibble_out = 0x1;    PSRAM_Write_Clk_Cycle(); 
  nibble_out = 0x0;    PSRAM_Write_Clk_Cycle(); 
  nibble_out = 0x1;    PSRAM_Write_Clk_Cycle(); 
 
  GPIO9_DR = PSRAM_RESET_VALUE;                     // Drive  CLK=0 , CS_n=1

 
  GPIO9_GDIR = 0x3F400000;                          // Change Data[3:0] to outputs quickly

 
  return;
}

// --------------------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------------------

inline uint8_t PSRAM_Read(uint32_t address_in) {
    
  if (address_in >= EMS_TOTAL_SIZE) {
      return 0xff;
  }  
  if (address_in >= 0x7FFFFF)  psram_cs=1; else psram_cs=0;  

  // Send Command = Quad Read = 0x0B
  //
  nibble_out = 0x0;    PSRAM_Write_Clk_Cycle(); 
  nibble_out = 0xB;    PSRAM_Write_Clk_Cycle(); 


  // Send 24-bit address in six clock cycles
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
 GPIO9_GDIR = 0x03400000;                               // Change Data[3:0] to inputs quickly
 PSRAM_Write_Clk_Cycle(); 
 PSRAM_Write_Clk_Cycle();   
 PSRAM_Write_Clk_Cycle();   
 PSRAM_Write_Clk_Cycle(); 


  // Clock in the data
  //                  
  PSRAM_Read_Clk_Cycle();  read_byte = nibble_in;
  PSRAM_Read_Clk_Cycle();  read_byte = (read_byte<<4) | nibble_in;

  GPIO9_DR = PSRAM_RESET_VALUE;                       // Drive  CLK=0 , CS_n=1
  GPIO9_GDIR = 0x3F400000;                            // Change Data[3:0] to outputs quickly

  return read_byte;
}

 
// --------------------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------------------

inline void PSRAM_Write(uint32_t address_in , int8_t local_data) {
  if (address_in >= EMS_TOTAL_SIZE) {
    return;
  }
  if (address_in >= 0x7FFFFF)  psram_cs=1; else psram_cs=0;  


  // Send Command = Quad Write = 0x02
  //
  nibble_out = 0x0;    PSRAM_Write_Clk_Cycle();
  nibble_out = 0x2;    PSRAM_Write_Clk_Cycle();


  // Send 24-bit address in six clock cycles
  //
  nibble_out = address_in >> 20;   PSRAM_Write_Clk_Cycle();
  nibble_out = address_in >> 16;   PSRAM_Write_Clk_Cycle();
  nibble_out = address_in >> 12;   PSRAM_Write_Clk_Cycle();
  nibble_out = address_in >> 8;    PSRAM_Write_Clk_Cycle();
  nibble_out = address_in >> 4;    PSRAM_Write_Clk_Cycle();
  nibble_out = address_in;         PSRAM_Write_Clk_Cycle();

  //GPIO8_DR = sd_pin_outputs + MUX_DATA_n_HIGH + CHRDY_OE_n_HIGH + DATA_OE_n_LOW;  // De-assert CHRDY early for 4.77 Mhz

 
  // Send byte data in two clock cycles
  //
  nibble_out = local_data >> 4;   PSRAM_Write_Clk_Cycle();
  nibble_out = local_data;        PSRAM_Write_Clk_Cycle();

  GPIO9_DR = PSRAM_RESET_VALUE;                       // Drive  CLK=0 , CS_n=1
}
 
 
// --------------------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------------------

inline uint8_t Internal_RAM_Read() {
    uint8_t local_temp;
   
    if (isa_address<0x60000)    local_temp = internal_RAM1[isa_address];
    else                        local_temp = internal_RAM2[isa_address-0x60000];
   
    return local_temp;
}

inline void Internal_RAM_Write() {
   
    if (isa_address<0x60000)    internal_RAM1[isa_address]         = 0xFF & ADDRESS_DATA_GPIO6_UNSCRAMBLE;
    else                        internal_RAM2[isa_address-0x60000] = 0xFF & ADDRESS_DATA_GPIO6_UNSCRAMBLE;
   
    return;
}

// --------------------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------------------

inline void Mem_Read_Cycle()
{
  isa_address = ADDRESS_DATA_GPIO6_UNSCRAMBLE;

  Region region = memmap[isa_address >> 11];
  switch (region) {
    case EmsWindow:
      page_base_address = (isa_address & 0xFC000);

           if (page_base_address == (EMS_BASE_MEM | 0xC000)) { psram_address = (ems_frame_pointer[3]<<14) | (isa_address & 0x03FFF); }
      else if (page_base_address == (EMS_BASE_MEM | 0x8000)) { psram_address = (ems_frame_pointer[2]<<14) | (isa_address & 0x03FFF); }
      else if (page_base_address == (EMS_BASE_MEM | 0x4000)) { psram_address = (ems_frame_pointer[1]<<14) | (isa_address & 0x03FFF); }
      else if (page_base_address == (EMS_BASE_MEM | 0x0000)) { psram_address = (ems_frame_pointer[0]<<14) | (isa_address & 0x03FFF); }

      GPIO7_DR = MUX_ADDR_n_LOW  + CHRDY_OUT_LOW + trigger_out;
      GPIO8_DR = sd_pin_outputs + MUX_DATA_n_HIGH + CHRDY_OE_n_LOW + DATA_OE_n_LOW ;  // Assert CHRDY_n=0 to begin wait states

      isa_data_out = PSRAM_Read(psram_address);
      GPIO7_DR = GPIO7_DATA_OUT_UNSCRAMBLE + MUX_ADDR_n_LOW  + CHRDY_OUT_LOW + trigger_out;  // Output data
      GPIO8_DR = sd_pin_outputs + MUX_DATA_n_HIGH + CHRDY_OE_n_HIGH + DATA_OE_n_LOW;  // De-assert CHRDY

      while ( (gpio9_int&0xF0) != 0xF0 ) { gpio9_int = GPIO9_DR; }  // Wait here until cycle is complete

      GPIO8_DR = sd_pin_outputs + MUX_DATA_n_HIGH + CHRDY_OE_n_HIGH + DATA_OE_n_HIGH;
      break;

    case Ram:
      isa_data_out = Internal_RAM_Read();
      GPIO7_DR = GPIO7_DATA_OUT_UNSCRAMBLE + MUX_ADDR_n_LOW  + CHRDY_OUT_LOW + trigger_out;

      // XTMax_MEM_Response_Array
      // - Array holds value 0,1,2
      //   0 = unitiailzed - add wait states and snoop
      //   1 = No wait states and no response
      //   2 = No wait states and yes respond
      //
      // If XTMax has not seen a read access to this 64 KB page yet, add wait states to give physical RAM (if present) a chance to respond
      if (XTMax_MEM_Response_Array[(isa_address>>16)] == 2) {
        GPIO8_DR = sd_pin_outputs + MUX_DATA_n_HIGH + CHRDY_OE_n_HIGH + DATA_OE_n_LOW;   // Physical RAM is NOT present at this page so XTMax will respond
      }
      else if (XTMax_MEM_Response_Array[(isa_address>>16)] == 0) {
        GPIO8_DR = sd_pin_outputs + MUX_DATA_n_HIGH + CHRDY_OE_n_LOW + DATA_OE_n_HIGH;   // Assert CHRDY_n=0 to begin wait states
        delayNanoseconds(800);
        GPIO8_DR = sd_pin_outputs + MUX_DATA_n_HIGH + CHRDY_OE_n_HIGH + DATA_OE_n_HIGH;  // De-assert CHRDY

        gpio6_int = GPIO6_DR;                                //  Read the data bus value currently on the ISA bus
        data_in = 0xFF & ADDRESS_DATA_GPIO6_UNSCRAMBLE;

        if (data_in == isa_data_out) {
          XTMax_MEM_Response_Array[(isa_address>>16)] = 1;   // Physical RAM is present at this page so XTMax should not respond
        }
        else {
          XTMax_MEM_Response_Array[(isa_address>>16)] = 2;
          GPIO8_DR = sd_pin_outputs + MUX_DATA_n_HIGH + CHRDY_OE_n_HIGH + DATA_OE_n_LOW;    // Physical RAM is NOT present at this page so XTMax will respond
        }
      }

      while ( (gpio9_int&0xF0) != 0xF0 ) { gpio9_int = GPIO9_DR; }  // Wait here until cycle is complete

      GPIO8_DR = sd_pin_outputs + MUX_DATA_n_HIGH + CHRDY_OE_n_HIGH + DATA_OE_n_HIGH;
      break;

    case BootRom:
      isa_data_out = BOOTROM[isa_address-BOOTROM_ADDR];
      GPIO7_DR = GPIO7_DATA_OUT_UNSCRAMBLE + MUX_ADDR_n_LOW + CHRDY_OUT_LOW + trigger_out;
      GPIO8_DR = sd_pin_outputs + MUX_DATA_n_HIGH + CHRDY_OE_n_HIGH + DATA_OE_n_LOW;

      while ( (gpio9_int&0xF0) != 0xF0 ) { gpio9_int = GPIO9_DR; }  // Wait here until cycle is complete

      GPIO8_DR = sd_pin_outputs + MUX_DATA_n_HIGH + CHRDY_OE_n_HIGH + DATA_OE_n_HIGH;
      break;

    case SdCard:
      GPIO7_DR = MUX_ADDR_n_LOW  + CHRDY_OUT_LOW + trigger_out;
      GPIO8_DR = sd_pin_outputs + MUX_DATA_n_HIGH + CHRDY_OE_n_LOW + DATA_OE_n_LOW ;  // Assert CHRDY_n=0 to begin wait states

      // Receive a byte to the SD Card
      sd_spi_dataout = 0xff; SD_SPI_Cycle(); isa_data_out = sd_spi_datain;
      GPIO7_DR = GPIO7_DATA_OUT_UNSCRAMBLE + MUX_ADDR_n_LOW  + CHRDY_OUT_LOW + trigger_out;  // Output data
      GPIO8_DR = sd_pin_outputs + MUX_DATA_n_HIGH + CHRDY_OE_n_HIGH + DATA_OE_n_LOW;  // De-assert CHRDY

      while ( (gpio9_int&0xF0) != 0xF0 ) { gpio9_int = GPIO9_DR; }  // Wait here until cycle is complete

      GPIO8_DR = sd_pin_outputs + MUX_DATA_n_HIGH + CHRDY_OE_n_HIGH + DATA_OE_n_HIGH;
      break;

    default:
      break;
  }
}


// --------------------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------------------

inline void Mem_Write_Cycle()
{
  isa_address = ADDRESS_DATA_GPIO6_UNSCRAMBLE;

  Region region = memmap[isa_address >> 11];
  switch (region) {
    case EmsWindow:
      page_base_address = (isa_address & 0xFC000);
 
           if (page_base_address == (EMS_BASE_MEM | 0xC000)) { psram_address = (ems_frame_pointer[3]<<14) | (isa_address & 0x03FFF); }
      else if (page_base_address == (EMS_BASE_MEM | 0x8000)) { psram_address = (ems_frame_pointer[2]<<14) | (isa_address & 0x03FFF); }
      else if (page_base_address == (EMS_BASE_MEM | 0x4000)) { psram_address = (ems_frame_pointer[1]<<14) | (isa_address & 0x03FFF); }
      else if (page_base_address == (EMS_BASE_MEM | 0x0000)) { psram_address = (ems_frame_pointer[0]<<14) | (isa_address & 0x03FFF); }

      GPIO7_DR = GPIO7_DATA_OUT_UNSCRAMBLE + MUX_ADDR_n_HIGH  + CHRDY_OUT_LOW + trigger_out;
      GPIO8_DR = sd_pin_outputs + MUX_DATA_n_LOW + CHRDY_OE_n_LOW + DATA_OE_n_HIGH;    // Steer data mux to Data[7:0] and Assert CHRDY_n=0 to begin wait states

      delayNanoseconds(10);  // Wait some time for buffers to switch from address to data

      gpio6_int = GPIO6_DR;
      data_in = 0xFF & ADDRESS_DATA_GPIO6_UNSCRAMBLE;
      PSRAM_Write(psram_address , data_in);
      GPIO8_DR = sd_pin_outputs + MUX_DATA_n_LOW + CHRDY_OE_n_HIGH + DATA_OE_n_HIGH;  // De-assert CHRDY
     
      while ( (gpio9_int&0xF0) != 0xF0 ) {   // Wait here until cycle is complete
        gpio6_int = GPIO6_DR;     
        gpio9_int = GPIO9_DR;
      }

      GPIO7_DR = GPIO7_DATA_OUT_UNSCRAMBLE + MUX_ADDR_n_LOW  + CHRDY_OUT_LOW + trigger_out;
      GPIO8_DR = sd_pin_outputs + MUX_DATA_n_HIGH + CHRDY_OE_n_HIGH + DATA_OE_n_HIGH;
      break;

    case Ram:
      GPIO7_DR = GPIO7_DATA_OUT_UNSCRAMBLE + MUX_ADDR_n_HIGH  + CHRDY_OUT_LOW + trigger_out;
      GPIO8_DR = sd_pin_outputs + MUX_DATA_n_LOW + CHRDY_OE_n_HIGH + DATA_OE_n_HIGH;

      while ( (gpio9_int&0xF0) != 0xF0 ) {   // Wait here until cycle is complete
        gpio6_int = GPIO6_DR;
        gpio9_int = GPIO9_DR;
      }

      Internal_RAM_Write();

      GPIO7_DR = GPIO7_DATA_OUT_UNSCRAMBLE + MUX_ADDR_n_LOW  + CHRDY_OUT_LOW + trigger_out;
      GPIO8_DR = sd_pin_outputs + MUX_DATA_n_HIGH + CHRDY_OE_n_HIGH + DATA_OE_n_HIGH;
      break;

    case SdCard:
      GPIO7_DR = GPIO7_DATA_OUT_UNSCRAMBLE + MUX_ADDR_n_HIGH  + CHRDY_OUT_LOW + trigger_out;
      GPIO8_DR = sd_pin_outputs + MUX_DATA_n_LOW + CHRDY_OE_n_LOW + DATA_OE_n_HIGH;    // Steer data mux to Data[7:0] and Assert CHRDY_n=0 to begin wait states

      delayNanoseconds(10);  // Wait some time for buffers to switch from address to data

      gpio6_int = GPIO6_DR;
      data_in = 0xFF & ADDRESS_DATA_GPIO6_UNSCRAMBLE;

      // Send a byte to the SD Card
      sd_spi_dataout = data_in;  SD_SPI_Cycle();
      GPIO8_DR = sd_pin_outputs + MUX_DATA_n_LOW + CHRDY_OE_n_HIGH + DATA_OE_n_HIGH;  // De-assert CHRDY

      while ( (gpio9_int&0xF0) != 0xF0 ) {   // Wait here until cycle is complete
        gpio6_int = GPIO6_DR;
        gpio9_int = GPIO9_DR;
      }

      GPIO7_DR = GPIO7_DATA_OUT_UNSCRAMBLE + MUX_ADDR_n_LOW  + CHRDY_OUT_LOW + trigger_out;
      GPIO8_DR = sd_pin_outputs + MUX_DATA_n_HIGH + CHRDY_OE_n_HIGH + DATA_OE_n_HIGH;
      break;

    default:
      break;
  }
}


// --------------------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------------------

inline void IO_Read_Cycle()
{
  isa_address = 0xFFFF & ADDRESS_DATA_GPIO6_UNSCRAMBLE;

  if ((isa_address&0x0FF8)==EMS_BASE_IO) {   // Location of 16 KB Expanded Memory page frame pointers
    switch (isa_address)  {
      case EMS_BASE_IO  :  isa_data_out = ems_frame_pointer[0]; break;
      case EMS_BASE_IO+1:  isa_data_out = ems_frame_pointer[0] >> 8; break;
      case EMS_BASE_IO+2:  isa_data_out = ems_frame_pointer[1]; break;
      case EMS_BASE_IO+3:  isa_data_out = ems_frame_pointer[1] >> 8; break;
      case EMS_BASE_IO+4:  isa_data_out = ems_frame_pointer[2]; break;
      case EMS_BASE_IO+5:  isa_data_out = ems_frame_pointer[2] >> 8; break;
      case EMS_BASE_IO+6:  isa_data_out = ems_frame_pointer[3]; break;
      case EMS_BASE_IO+7:  isa_data_out = ems_frame_pointer[3] >> 8; break;
    }

    GPIO7_DR = GPIO7_DATA_OUT_UNSCRAMBLE + MUX_ADDR_n_LOW  + CHRDY_OUT_LOW + trigger_out;
    GPIO8_DR = sd_pin_outputs + MUX_DATA_n_HIGH + CHRDY_OE_n_HIGH + DATA_OE_n_LOW;

    while ( (gpio9_int&0xF0) != 0xF0 ) { gpio9_int = GPIO9_DR; }  // Wait here until cycle is complete

    GPIO8_DR = sd_pin_outputs + MUX_DATA_n_HIGH + CHRDY_OE_n_HIGH + DATA_OE_n_HIGH;
  }
  else if ((isa_address&0x0FF8)==SD_BASE) {   // Location of SD Card registers
    switch (isa_address)  {
      case SD_BASE+0:  sd_spi_dataout = 0xff; SD_SPI_Cycle(); isa_data_out = sd_spi_datain; break;
      case SD_BASE+1:  isa_data_out = SD_CONFIG_BYTE; break;
      case SD_BASE+2:  isa_data_out = sd_scratch_register[0]; break;
      case SD_BASE+3:  isa_data_out = sd_scratch_register[1]; break;
      case SD_BASE+4:  isa_data_out = sd_scratch_register[2]; break;
      case SD_BASE+5:  isa_data_out = sd_scratch_register[3]; break;
      case SD_BASE+6:  isa_data_out = sd_scratch_register[4]; break;
      case SD_BASE+7:  isa_data_out = sd_timeout >= sd_requested_timeout; break;
      default:         isa_data_out = 0xff; break;
    }

    GPIO7_DR = GPIO7_DATA_OUT_UNSCRAMBLE + MUX_ADDR_n_LOW  + CHRDY_OUT_LOW + trigger_out;
    GPIO8_DR = sd_pin_outputs + MUX_DATA_n_HIGH + CHRDY_OE_n_HIGH + DATA_OE_n_LOW;

    while ( (gpio9_int&0xF0) != 0xF0 ) { gpio9_int = GPIO9_DR; }  // Wait here until cycle is complete

    GPIO8_DR = sd_pin_outputs + MUX_DATA_n_HIGH + CHRDY_OE_n_HIGH + DATA_OE_n_HIGH;
  }
}
   

// --------------------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------------------

inline void IO_Write_Cycle()
{
  isa_address = 0xFFFF & ADDRESS_DATA_GPIO6_UNSCRAMBLE;

  if ((isa_address&0x0FF8)==EMS_BASE_IO) {   // Location of 16 KB Expanded Memory page frame pointers
    GPIO7_DR = GPIO7_DATA_OUT_UNSCRAMBLE + MUX_ADDR_n_HIGH  + CHRDY_OUT_LOW + trigger_out;
    GPIO8_DR = sd_pin_outputs + MUX_DATA_n_LOW + CHRDY_OE_n_HIGH + DATA_OE_n_HIGH;

    while ( (gpio9_int&0xF0) != 0xF0 ) {   // Wait here until cycle is complete
      gpio6_int = GPIO6_DR;
      gpio9_int = GPIO9_DR;
    }

    data_in = 0xFF & ADDRESS_DATA_GPIO6_UNSCRAMBLE;

    switch (isa_address)  {
      case EMS_BASE_IO  :  ems_frame_pointer[0] = (ems_frame_pointer[0] & 0xFF00) | data_in; break;
      case EMS_BASE_IO+1:  ems_frame_pointer[0] = (ems_frame_pointer[0] & 0x00FF) | ((uint16_t)data_in << 8); break;
      case EMS_BASE_IO+2:  ems_frame_pointer[1] = (ems_frame_pointer[1] & 0xFF00) | data_in; break;
      case EMS_BASE_IO+3:  ems_frame_pointer[1] = (ems_frame_pointer[1] & 0x00FF) | ((uint16_t)data_in << 8); break;
      case EMS_BASE_IO+4:  ems_frame_pointer[2] = (ems_frame_pointer[2] & 0xFF00) | data_in; break;
      case EMS_BASE_IO+5:  ems_frame_pointer[2] = (ems_frame_pointer[2] & 0x00FF) | ((uint16_t)data_in << 8); break;
      case EMS_BASE_IO+6:  ems_frame_pointer[3] = (ems_frame_pointer[3] & 0xFF00) | data_in; break;
      case EMS_BASE_IO+7:  ems_frame_pointer[3] = (ems_frame_pointer[3] & 0x00FF) | ((uint16_t)data_in << 8); break;
    }

    GPIO7_DR = GPIO7_DATA_OUT_UNSCRAMBLE + MUX_ADDR_n_LOW  + CHRDY_OUT_LOW + trigger_out;
    GPIO8_DR = sd_pin_outputs + MUX_DATA_n_HIGH + CHRDY_OE_n_HIGH + DATA_OE_n_HIGH;
  }
  else if ((isa_address&0x0FF8)==SD_BASE) {   // Location of SD Card registers
    GPIO7_DR = GPIO7_DATA_OUT_UNSCRAMBLE + MUX_ADDR_n_HIGH  + CHRDY_OUT_LOW + trigger_out;
    GPIO8_DR = sd_pin_outputs + MUX_DATA_n_LOW + CHRDY_OE_n_HIGH + DATA_OE_n_HIGH;

    delayNanoseconds(50); // Give some time for write data to be available after IOWR_n goes low
    gpio6_int = GPIO6_DR;
    data_in = 0xFF & ADDRESS_DATA_GPIO6_UNSCRAMBLE;

    switch (isa_address)  {
      case SD_BASE+0:  sd_spi_dataout = data_in;  SD_SPI_Cycle(); break;
      case SD_BASE+1:  sd_spi_cs_n    = data_in&0x1; break;
      case SD_BASE+2:  sd_scratch_register[0] = data_in; break;
      case SD_BASE+3:  sd_scratch_register[1] = data_in; break;
      case SD_BASE+4:  sd_scratch_register[2] = data_in; break;
      case SD_BASE+5:  sd_scratch_register[3] = data_in; break;
      case SD_BASE+6:  sd_scratch_register[4] = data_in; break;
      case SD_BASE+7:  sd_timeout = 0; sd_requested_timeout = data_in * 10; break;
    }

    //gpio9_int = GPIO9_DR;
    while ( (gpio9_int&0xF0) != 0xF0 ) {   // Wait here until cycle is complete
      gpio6_int = GPIO6_DR;
      gpio9_int = GPIO9_DR;
    }

    sd_pin_outputs = (sd_spi_cs_n<<17);   // SD_CS_n - SD_CLK - SD_MOSI

    GPIO7_DR = GPIO7_DATA_OUT_UNSCRAMBLE + MUX_ADDR_n_LOW  + CHRDY_OUT_LOW + trigger_out;
    GPIO8_DR = sd_pin_outputs + MUX_DATA_n_HIGH + CHRDY_OE_n_HIGH + DATA_OE_n_HIGH;
  }
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
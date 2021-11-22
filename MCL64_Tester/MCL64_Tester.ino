//
//
//  File Name   :  MCL64_Tester.c
//  Used on     :  
//  Author      : Ted Fried, MicroCore Labs
//  Creation    : 11/20/2021
//
//   Description:
//   ============
//   
//  Commodore 64 motherboard tester which uses the CPU bus interface.
//
//------------------------------------------------------------------------
//
// Modification History:
// =====================
//
// Revision 1 11/20/2021
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

// Teensy 4.1 pin assignments
//
#define PIN_CLK0            24
#define PIN_READY_n         26
#define PIN_IRQ             25
#define PIN_NMI             41
#define PIN_RESET           40
#define PIN_RDWR_n          12
#define PIN_P0              22
#define PIN_P1              13
#define PIN_P2              39
                    
#define PIN_ADDR0           27 
#define PIN_ADDR1           38 
#define PIN_ADDR2           28 
#define PIN_ADDR3           37 
#define PIN_ADDR4           29 
#define PIN_ADDR5           36 
#define PIN_ADDR6           30 
#define PIN_ADDR7           35         
#define PIN_ADDR8           31 
#define PIN_ADDR9           34 
#define PIN_ADDR10          32 
#define PIN_ADDR11          33 
#define PIN_ADDR12          1  
#define PIN_ADDR13          0  
#define PIN_ADDR14          2  
#define PIN_ADDR15          23 
        
#define PIN_DATAIN0         14 
#define PIN_DATAIN1         15 
#define PIN_DATAIN2         16 
#define PIN_DATAIN3         17 
#define PIN_DATAIN4         18 
#define PIN_DATAIN5         19 
#define PIN_DATAIN6         20 
#define PIN_DATAIN7         21 
        
#define PIN_DATAOUT0        11 
#define PIN_DATAOUT1        10 
#define PIN_DATAOUT2        9 
#define PIN_DATAOUT3        8 
#define PIN_DATAOUT4        7 
#define PIN_DATAOUT5        6 
#define PIN_DATAOUT6        5 
#define PIN_DATAOUT7        4 
#define PIN_DATAOUT_OE_n    3 



uint8_t   direct_datain=0;
uint8_t   direct_reset=0;
uint8_t   direct_ready_n=0;
uint8_t   direct_irq=0;
uint8_t   direct_nmi=0;
uint8_t   global_temp=0;
uint8_t   sid_sound_on=0;
int       incomingByte;    



    
// ------------------------------------------------------------------------------
// ------------------------------------------------------------------------------

// Setup Teensy 4.1 IO's
//
void setup() {
  
  pinMode(PIN_CLK0,        INPUT);  
  pinMode(PIN_RESET,       INPUT);  
  pinMode(PIN_READY_n,     INPUT);  
  pinMode(PIN_IRQ,         INPUT);  
  pinMode(PIN_NMI,         INPUT);  
  pinMode(PIN_RDWR_n,      OUTPUT); 
  pinMode(PIN_P0,          OUTPUT); 
  pinMode(PIN_P1,          OUTPUT); 
  pinMode(PIN_P2,          OUTPUT); 
  
  pinMode(PIN_ADDR0,       OUTPUT); 
  pinMode(PIN_ADDR1,       OUTPUT); 
  pinMode(PIN_ADDR2,       OUTPUT); 
  pinMode(PIN_ADDR3,       OUTPUT); 
  pinMode(PIN_ADDR4,       OUTPUT); 
  pinMode(PIN_ADDR5,       OUTPUT); 
  pinMode(PIN_ADDR6,       OUTPUT); 
  pinMode(PIN_ADDR7,       OUTPUT);
  pinMode(PIN_ADDR8,       OUTPUT); 
  pinMode(PIN_ADDR9,       OUTPUT); 
  pinMode(PIN_ADDR10,      OUTPUT); 
  pinMode(PIN_ADDR11,      OUTPUT); 
  pinMode(PIN_ADDR12,      OUTPUT); 
  pinMode(PIN_ADDR13,      OUTPUT); 
  pinMode(PIN_ADDR14,      OUTPUT); 
  pinMode(PIN_ADDR15,      OUTPUT);  
  
  pinMode(PIN_DATAIN0,     INPUT); 
  pinMode(PIN_DATAIN1,     INPUT); 
  pinMode(PIN_DATAIN2,     INPUT); 
  pinMode(PIN_DATAIN3,     INPUT); 
  pinMode(PIN_DATAIN4,     INPUT); 
  pinMode(PIN_DATAIN5,     INPUT); 
  pinMode(PIN_DATAIN6,     INPUT); 
  pinMode(PIN_DATAIN7,     INPUT);
    
  pinMode(PIN_DATAOUT0,    OUTPUT); 
  pinMode(PIN_DATAOUT1,    OUTPUT); 
  pinMode(PIN_DATAOUT2,    OUTPUT); 
  pinMode(PIN_DATAOUT3,    OUTPUT); 
  pinMode(PIN_DATAOUT4,    OUTPUT); 
  pinMode(PIN_DATAOUT5,    OUTPUT); 
  pinMode(PIN_DATAOUT6,    OUTPUT); 
  pinMode(PIN_DATAOUT7,    OUTPUT);
  pinMode(PIN_DATAOUT_OE_n,  OUTPUT); 

  digitalWriteFast(PIN_P0, 0x0 ); 
  digitalWriteFast(PIN_P1, 0x0 ); 
  digitalWriteFast(PIN_P2, 0x1 ); 
  digitalWriteFast(PIN_RDWR_n,  0x1);

  Serial.begin(9600);
}


// --------------------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------------------
//
// Begin 6502 Bus Interface Unit 
//
// --------------------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------------------


// -------------------------------------------------
// Wait for the CLK1 rising edge and sample signals
// -------------------------------------------------
inline void wait_for_CLK_rising_edge() {
  register uint32_t GPIO6_data=0;
  uint32_t   d10, d2, d3, d4, d5, d76;

    while (((GPIO6_DR >> 12) & 0x1)!=0) {}            // Teensy 4.1 Pin-24  GPIO6_DR[12]     CLK
    
    while (((GPIO6_DR >> 12) & 0x1)==0) {GPIO6_data=GPIO6_DR;}                  // This method is ok for VIC-20 and Apple-II+ non-DRAM ranges 
    
    //do {  GPIO6_data_d1=GPIO6_DR;   } while (((GPIO6_data_d1 >> 12) & 0x1)==0);   // This method needed to support Apple-II+ DRAM read data setup time
    //GPIO6_data=GPIO6_data_d1;
    
    d10             = (GPIO6_data&0x000C0000) >> 18;  // Teensy 4.1 Pin-14  GPIO6_DR[19:18]  D1:D0
    d2              = (GPIO6_data&0x00800000) >> 21;  // Teensy 4.1 Pin-16  GPIO6_DR[23]     D2
    d3              = (GPIO6_data&0x00400000) >> 19;  // Teensy 4.1 Pin-17  GPIO6_DR[22]     D3
    d4              = (GPIO6_data&0x00020000) >> 13;  // Teensy 4.1 Pin-18  GPIO6_DR[17]     D4
    d5              = (GPIO6_data&0x00010000) >> 11;  // Teensy 4.1 Pin-19  GPIO6_DR[16]     D5
    d76             = (GPIO6_data&0x0C000000) >> 20;  // Teensy 4.1 Pin-20  GPIO6_DR[27:26]  D7:D6
    
    direct_irq      = (GPIO6_data&0x00002000) >> 13;  // Teensy 4.1 Pin-25  GPIO6_DR[13]     IRQ
    direct_ready_n  = (GPIO6_data&0x40000000) >> 30;  // Teensy 4.1 Pin-26  GPIO6_DR[30]     READY
    direct_reset    = (GPIO6_data&0x00100000) >> 20;  // Teensy 4.1 Pin-40  GPIO6_DR[20]     RESET
    direct_nmi      = (GPIO6_data&0x00200000) >> 21;  // Teensy 4.1 Pin-41  GPIO6_DR[21]     NMI
    
    direct_datain = d76 | d5 | d4 | d3 | d2 | d10;
    
    return; 
}


// -------------------------------------------------
// Wait for the CLK1 falling edge 
// -------------------------------------------------
inline void wait_for_CLK_falling_edge() {

  while (((GPIO6_DR >> 12) & 0x1)==0) {}   // Teensy 4.1 Pin-24  GPIO6_DR[12]  CLK
  while (((GPIO6_DR >> 12) & 0x1)!=0) {}
  return; 
}


// -------------------------------------------------
// Drive the 6502 Address pins
// -------------------------------------------------
inline void send_address(uint32_t local_address) {
  register uint32_t writeback_data=0;
  
    writeback_data = (0x6DFFFFF3 & GPIO6_DR);   // Read in current GPIOx register value and clear the bits we intend to update
    writeback_data = writeback_data | (local_address & 0x8000)<<10 ;  // 6502_Address[15]   TEENSY_PIN23   GPIO6_DR[25]
    writeback_data = writeback_data | (local_address & 0x2000)>>10 ;  // 6502_Address[13]   TEENSY_PIN0    GPIO6_DR[3]
    writeback_data = writeback_data | (local_address & 0x1000)>>10 ;  // 6502_Address[12]   TEENSY_PIN1    GPIO6_DR[2]
    writeback_data = writeback_data | (local_address & 0x0002)<<27 ;  // 6502_Address[1]    TEENSY_PIN38   GPIO6_DR[28]
    GPIO6_DR       = writeback_data | (local_address & 0x0001)<<31 ;  // 6502_Address[0]    TEENSY_PIN27   GPIO6_DR[31]
    
    writeback_data = (0xCFF3EFFF & GPIO7_DR);   // Read in current GPIOx register value and clear the bits we intend to update
    writeback_data = writeback_data | (local_address & 0x0400)<<2  ;  // 6502_Address[10]   TEENSY_PIN32   GPIO7_DR[12]
    writeback_data = writeback_data | (local_address & 0x0200)<<20 ;  // 6502_Address[9]    TEENSY_PIN34   GPIO7_DR[29]
    writeback_data = writeback_data | (local_address & 0x0080)<<21 ;  // 6502_Address[7]    TEENSY_PIN35   GPIO7_DR[28]
    writeback_data = writeback_data | (local_address & 0x0020)<<13 ;  // 6502_Address[5]    TEENSY_PIN36   GPIO7_DR[18]
    GPIO7_DR       = writeback_data | (local_address & 0x0008)<<16 ;  // 6502_Address[3]    TEENSY_PIN37   GPIO7_DR[19]
                
    writeback_data = (0xFF3BFFFF & GPIO8_DR);   // Read in current GPIOx register value and clear the bits we intend to update
    writeback_data = writeback_data | (local_address & 0x0100)<<14 ;  // 6502_Address[8]    TEENSY_PIN31   GPIO8_DR[22]
    writeback_data = writeback_data | (local_address & 0x0040)<<17 ;  // 6502_Address[6]    TEENSY_PIN30   GPIO8_DR[23]
    GPIO8_DR       = writeback_data | (local_address & 0x0004)<<16 ;  // 6502_Address[2]    TEENSY_PIN28   GPIO8_DR[18]
    
    writeback_data = (0x7FFFFF6F & GPIO9_DR);   // Read in current GPIOx register value and clear the bits we intend to update
    writeback_data = writeback_data | (local_address & 0x4000)>>10 ;  // 6502_Address[14]   TEENSY_PIN2    GPIO9_DR[4]
    writeback_data = writeback_data | (local_address & 0x0800)>>4  ;  // 6502_Address[11]   TEENSY_PIN33   GPIO9_DR[7]
    GPIO9_DR       = writeback_data | (local_address & 0x0010)<<27 ;  // 6502_Address[4]    TEENSY_PIN29   GPIO9_DR[31]
    
    return;
}

        

// -------------------------------------------------
// Full read cycle with address and data read in
// -------------------------------------------------
inline uint8_t read_byte(uint16_t local_address) {
   
   digitalWriteFast(PIN_RDWR_n,  0x1);
   send_address(local_address);
   do {  wait_for_CLK_rising_edge();  }  while (direct_ready_n == 0x1);  // Delay a clock cycle until ready is active 

   wait_for_CLK_rising_edge(); // wait a few extra clocks between bus cycles
   wait_for_CLK_rising_edge();
   wait_for_CLK_rising_edge();
   wait_for_CLK_rising_edge();
       
return direct_datain;                  
     
} 


// -------------------------------------------------
// Full write cycle with address and data written
// -------------------------------------------------
inline void write_byte(uint16_t local_address , uint8_t local_write_data) {

       digitalWriteFast(PIN_RDWR_n,  0x0);
       send_address(local_address);

       
     // Drive the data bus pins from the Teensy to the bus driver which is inactive
     //
       digitalWriteFast(PIN_DATAOUT0,  (local_write_data & 0x01)    );
       digitalWriteFast(PIN_DATAOUT1,  (local_write_data & 0x02)>>1 ); 
       digitalWriteFast(PIN_DATAOUT2,  (local_write_data & 0x04)>>2 ); 
       digitalWriteFast(PIN_DATAOUT3,  (local_write_data & 0x08)>>3 ); 
       digitalWriteFast(PIN_DATAOUT4,  (local_write_data & 0x10)>>4 ); 
       digitalWriteFast(PIN_DATAOUT5,  (local_write_data & 0x20)>>5 ); 
       digitalWriteFast(PIN_DATAOUT6,  (local_write_data & 0x40)>>6 ); 
       digitalWriteFast(PIN_DATAOUT7,  (local_write_data & 0x80)>>7 ); 

       
       // During the second CLK phase, enable the data bus output drivers
       //
       wait_for_CLK_falling_edge();
       digitalWriteFast(PIN_DATAOUT_OE_n,  0x0 ); 
       
       wait_for_CLK_rising_edge();
       digitalWriteFast(PIN_DATAOUT_OE_n,  0x1 ); 
       digitalWriteFast(PIN_RDWR_n,  0x1);
                    
   return;
}

  
// --------------------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------------------
//
// End 6502 Bus Interface Unit
//
// --------------------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------------------



void test_0() {
    
    Serial.println("");
    Serial.println("");
    Serial.println("");
    Serial.println("");
    
    Serial.println("Probe the Cartridge Port Edge Connector, pin 2 and 3 to verify 5 volts DC");
    Serial.println("Probe the User Port Edge Connector, pin 10 and 11 to verify 9 volts **AC**");
    Serial.println("Probe the VIC-II, pin 13 to verify 12 volts DC");
    Serial.println("Probe the CPU, pin 1 to verify the 1Mhz clock input from the VIC-II. -- If using volt-meter you should measure around 1.6V-DC");
    Serial.println("Probe the CPU, pin 39 to verify the 1Mhz clock output. -- If using volt-meter you should measure around 1.6V-DC");
    return;
}


void test_1() {
    
    uint32_t failcount=0;
    uint32_t addr=0;
    uint8_t data=0;
    uint8_t pass=0;
    uint8_t character_1=0;
    uint8_t character_2=0;
    uint8_t character_3=0;
    uint8_t character_4=0;
    uint8_t character_5=0;

    
    Serial.println("");
    Serial.println("");
    Serial.println("");
    Serial.println("");
    Serial.println("Running some initial tests of the motherboard IC's:");
    Serial.println("");
    Serial.println("");
    
    
    // Testing 64KB of DRAM
    // ---------------------------------------------------------------------------------------------
    // ---------------------------------------------------------------------------------------------
    
    // Set bank mode 24,28 -- All DRAM
    //
    digitalWriteFast(PIN_P2, 0x0);  // CHAREN_n
    digitalWriteFast(PIN_P1, 0x0);  // HIRAM_n
    digitalWriteFast(PIN_P0, 0x0);  // LORAM_n
    delay (50);

    Serial.print("64KB DRAM..........");
    failcount=0;
    for (addr=0x0; addr<=0xFFFF; addr++)    write_byte(addr , addr);  
    for (addr=0x0; addr<=0xFFFF; addr++)  { data = read_byte(addr);   if ((0xFF&addr) != data) { failcount++; } }
    
    if (failcount==0) { Serial.println("PASSED");  }
    else              { Serial.print  ("FAILED -- "); Serial.print(failcount,DEC); Serial.println("failures"); }
          
          
    

    // Testing the KERNAL, BASIC, and CHARACTER ROMS
    // ---------------------------------------------------------------------------------------------
    // ---------------------------------------------------------------------------------------------
    
    // Set bank mode 27 -- All ROMS accessible
    //
    digitalWriteFast(PIN_P2, 0x0);  // CHAREN_n
    digitalWriteFast(PIN_P1, 0x1);  // HIRAM_n
    digitalWriteFast(PIN_P0, 0x1);  // LORAM_n
    delay (50); 
    
    Serial.print("KERNAL ROM.........");
    pass=0;
    for (addr=0xE000; addr<=0xFFFF; addr++)  {
        character_1 = character_2;
        character_2 = character_3;
        character_3 = character_4;
        character_4 = character_5;
        character_5 = read_byte(addr);
        
        if (character_1=='B' && character_2=='A' && character_3=='S' && character_4=='I' && character_5=='C') { pass=1; }
    }
    if (pass==1) { Serial.println("PASSED");  } else { Serial.println("FAILED ####");  }
    
    
    Serial.print("BASIC ROM..........");
    pass=0;
    for (addr=0xA000; addr<=0xBFFF; addr++)  {
        character_1 = character_2;
        character_2 = character_3;
        character_3 = character_4;
        character_4 = character_5;
        character_5 = read_byte(addr);
        
        if (character_1=='B' && character_2=='A' && character_3=='S' && character_4=='I' && character_5=='C') { pass=1; }
    }
    if (pass==1) { Serial.println("PASSED");  } else { Serial.println("FAILED ####");  }

            
    
    Serial.print("CHARACTER ROM......");
    pass=0;
    for (addr=0xD000; addr<=0xDFFF; addr++)  {
        character_1 = character_2;
        character_2 = character_3;
        character_3 = character_4;
        character_4 = character_5;
        character_5 = read_byte(addr);
        
        if (character_1==0x63 && character_2==0x77 && character_3==0x7F && character_4==0x6B && character_5==0x63) { pass=1; }
    }
    if (pass==1) { Serial.println("PASSED");  } else { Serial.println("FAILED ####");  }


  
    // Testing Color RAM
    // ---------------------------------------------------------------------------------------------
    // ---------------------------------------------------------------------------------------------
  
    // Bank Mode 31 -- I/O Range is accessible
    //
    digitalWriteFast(PIN_P2, 0x1);  // CHAREN_n
    digitalWriteFast(PIN_P1, 0x1);  // HIRAM_n
    digitalWriteFast(PIN_P0, 0x1);  // LORAM_n
    delay (50);

    Serial.print("Color RAM..........");
    failcount=0;
    for (addr=0xD800; addr<=0xDBE7; addr++)    write_byte(addr , addr);  
    for (addr=0xD800; addr<=0xDBE7; addr++)  { data = read_byte(addr);   if ((0x0F&addr) !=(0x0F&data)) { failcount++; } }
    
    if (failcount==0) { Serial.println("PASSED");  }
    else              { Serial.print  ("FAILED -- "); Serial.print(failcount,DEC); Serial.println("failures"); }
          
      
 

    // Testing the VIC-II
    // ---------------------------------------------------------------------------------------------
    // ---------------------------------------------------------------------------------------------
      
    // Bank Mode 31 -- I/O Range is accessible
    //
    digitalWriteFast(PIN_P2, 0x1);  // CHAREN_n
    digitalWriteFast(PIN_P1, 0x1);  // HIRAM_n
    digitalWriteFast(PIN_P0, 0x1);  // LORAM_n
    delay (50);

    Serial.print("VIC-II Registers...");
    pass=1;
    for (addr=0xD000; addr<=0xD00F; addr++)  {
      write_byte(addr , addr);
      character_5 = read_byte(addr);
      if ((0xFF&addr) != character_5) {  pass=0; }
    }
    if (pass==1) { Serial.println("PASSED");  } else { Serial.println("FAILED ####");  }
  
  
    Serial.println("VIC-II - Setting screen background to BLUE ");
    write_byte(0xd020 , 0x6);
    write_byte(0xd021 , 0x6);
  
  
    Serial.println("SID - Playing a note for one second ");
  
    write_byte(0xD400+0  , 0x00);  // frequency voice 1 
    write_byte(0xD400+1  , 0x40);  // frequency voice 1    
    write_byte(0xD400+2  , 0x55);  // pulse width 1 
    write_byte(0xD400+3  , 0x55);  // pulse width 1   
    write_byte(0xD400+4  , 0x45);  // control register voice 1 - Sawtooth
    write_byte(0xD400+5  , 0xCC);  // attack/decay duration voice 1
    write_byte(0xD400+6  , 0xC8);  // sustain level, release duration
    write_byte(0xD400+24 , 0x0F);  // filter mode and main volume control
    delay (1000);  
    write_byte(0xD400+0  , 0x00);  
    write_byte(0xD400+1  , 0x00);  
    write_byte(0xD400+2  , 0x00);  
    write_byte(0xD400+3  , 0x00);  
    write_byte(0xD400+4  , 0x00);  
    write_byte(0xD400+5  , 0x00);  
    write_byte(0xD400+6  , 0x00);  
    write_byte(0xD400+24 , 0x00);  
    
    return;
}


void test_2() {


    // Set bank mode 24,28 -- All DRAM
    //
    digitalWriteFast(PIN_P2, 0x0);  // CHAREN_n
    digitalWriteFast(PIN_P1, 0x0);  // HIRAM_n
    digitalWriteFast(PIN_P0, 0x0);  // LORAM_n
    delay (50);

    // Perform an initial write/read
    write_byte(0x0 , 0x0);
    global_temp = read_byte(0x0);
    
    while (1) {
      
      Serial.println("");
      Serial.println("");
      Serial.println("");
      Serial.println("PLA Output Toggling Test Menu");
      Serial.println("Will toggle just the selected outputs");
      Serial.println("-------------------------------------");
      Serial.println("0) PLA Pin-18                             CASRAM due to VIC-II activity only");
      Serial.println("1) PLA Pin-18                             CASRAM due to VIC-II and CPU activity");
      Serial.println("2) PLA Pin-17                             BASIC  ROM with PLA inputs [CHARGEN=1, HIRAM=1, LORAM=1]");
      Serial.println("3) PLA Pin-17                             BASIC  ROM with PLA inputs [CHARGEN=0, HIRAM=1, LORAM=1]");
      Serial.println("4) PLA Pin-16                             KERNAL ROM with PLA inputs [CHARGEN=1, HIRAM=1, LORAM=1]");
      Serial.println("5) PLA Pin-16                             KERNAL ROM with PLA inputs [CHARGEN=1, HIRAM=1, LORAM=0]");
      Serial.println("6) PLA Pin-16                             KERNAL ROM with PLA inputs [CHARGEN=0, HIRAM=1, LORAM=1]");
      Serial.println("7) PLA Pin-16                             KERNAL ROM with PLA inputs [CHARGEN=0, HIRAM=1, LORAM=0]");
      Serial.println("8) PLA Pin-15                             CHARACTER ROM");
      Serial.println("9) PLA Pin-12 & U15 Pin-4                 VIC-II ");
      Serial.println("a) PLA Pin-12 & U15 Pin-5                 SID ");
      Serial.println("b) PLA Pin-12 & U15 Pin-7 & U15 Pin-12    CIA U1 ");
      Serial.println("c) PLA Pin-12 & U15 Pin-7 & U15 Pin-11    CIA U2 ");
      Serial.println("");
      Serial.println("d) PLA Pin-13 & U15 Pin-6                !!! Color RAM Write Enable and Chip Select !!! Infinite loop, so will need to reset the board to exit !!!  ");
      Serial.println("x) Exit to Main Menu ");
      Serial.println("");
      
      while (Serial.available()==0 ) { }
      incomingByte = Serial.read();   
      switch (incomingByte){
        case 48:   digitalWriteFast(PIN_P2,0); digitalWriteFast(PIN_P1,0); digitalWriteFast(PIN_P0,0); delay (50); send_address(0xFFFF); break; // case 0 - CASRAM
        case 49:   digitalWriteFast(PIN_P2,0); digitalWriteFast(PIN_P1,0); digitalWriteFast(PIN_P0,0); delay (50); send_address(0x0000); break; // case 1 - CASRAM
        case 50:   digitalWriteFast(PIN_P2,1); digitalWriteFast(PIN_P1,1); digitalWriteFast(PIN_P0,1); delay (50); send_address(0xA000); break; // case 2 - BASIC ROM
        case 51:   digitalWriteFast(PIN_P2,0); digitalWriteFast(PIN_P1,1); digitalWriteFast(PIN_P0,1); delay (50); send_address(0xA000); break; // case 3 - BASIC ROM
        case 52:   digitalWriteFast(PIN_P2,1); digitalWriteFast(PIN_P1,1); digitalWriteFast(PIN_P0,1); delay (50); send_address(0xE000); break; // case 4 - KERNAL ROM
        case 53:   digitalWriteFast(PIN_P2,1); digitalWriteFast(PIN_P1,1); digitalWriteFast(PIN_P0,0); delay (50); send_address(0xE000); break; // case 5 - KERNAL ROM
        case 54:   digitalWriteFast(PIN_P2,0); digitalWriteFast(PIN_P1,1); digitalWriteFast(PIN_P0,1); delay (50); send_address(0xE000); break; // case 6 - KERNAL ROM
        case 55:   digitalWriteFast(PIN_P2,0); digitalWriteFast(PIN_P1,1); digitalWriteFast(PIN_P0,0); delay (50); send_address(0xE000); break; // case 7 - KERNAL ROM
        case 56:   digitalWriteFast(PIN_P2,0); digitalWriteFast(PIN_P1,1); digitalWriteFast(PIN_P0,0); delay (50); send_address(0xD000); break; // case 8 - CHARACTER ROM
        case 57:   digitalWriteFast(PIN_P2,1); digitalWriteFast(PIN_P1,1); digitalWriteFast(PIN_P0,1); delay (50); send_address(0xD000); break; // case a - VIC-II
        case 97:   digitalWriteFast(PIN_P2,1); digitalWriteFast(PIN_P1,1); digitalWriteFast(PIN_P0,1); delay (50); send_address(0xD400); break; // case b - SID
        case 98:   digitalWriteFast(PIN_P2,1); digitalWriteFast(PIN_P1,1); digitalWriteFast(PIN_P0,1); delay (50); send_address(0xDC02); break; // case c - CIA U1
        case 99:   digitalWriteFast(PIN_P2,1); digitalWriteFast(PIN_P1,1); digitalWriteFast(PIN_P0,1); delay (50); send_address(0xDD02); break; // case d - CIA U1
        case 100:  digitalWriteFast(PIN_P2,1); digitalWriteFast(PIN_P1,1); digitalWriteFast(PIN_P0,1); delay (50); while (1){write_byte(0xD800,0x5A); } break; // case 9 - Color RAM Write Enable and Chip Select
        case 120:  return; break;
      }
  }

return;
}
      

void search_stuck_databits(uint32_t local_start_address , uint32_t local_stop_address ) {
    
    uint32_t x=0;
    uint32_t full_address=0;
    uint8_t ones_seen=0;
    uint8_t zeros_seen=0;
    uint8_t local_data=0;


    while (full_address <= local_stop_address) {
        local_data = read_byte(local_start_address+x);
        x++;
        full_address = local_start_address+x;
    
        if ( (local_data & 0x01) == 0 ) zeros_seen = zeros_seen | 0x01;  else  ones_seen  = ones_seen  | 0x01;
        if ( (local_data & 0x02) == 0 ) zeros_seen = zeros_seen | 0x02;  else  ones_seen  = ones_seen  | 0x02;
        if ( (local_data & 0x04) == 0 ) zeros_seen = zeros_seen | 0x04;  else  ones_seen  = ones_seen  | 0x04;
        if ( (local_data & 0x08) == 0 ) zeros_seen = zeros_seen | 0x08;  else  ones_seen  = ones_seen  | 0x08;
        if ( (local_data & 0x10) == 0 ) zeros_seen = zeros_seen | 0x10;  else  ones_seen  = ones_seen  | 0x10;
        if ( (local_data & 0x20) == 0 ) zeros_seen = zeros_seen | 0x20;  else  ones_seen  = ones_seen  | 0x20;
        if ( (local_data & 0x40) == 0 ) zeros_seen = zeros_seen | 0x40;  else  ones_seen  = ones_seen  | 0x40;
        if ( (local_data & 0x80) == 0 ) zeros_seen = zeros_seen | 0x80;  else  ones_seen  = ones_seen  | 0x80;
    }

    if (ones_seen != 0xFF)  { Serial.print("Some data bits are stuck at 0: ");  Serial.println(ones_seen,BIN);  }
    if (zeros_seen != 0xFF){  Serial.print("Some data bits are stuck at 1: ");  Serial.println(zeros_seen,BIN); }
    if ( (ones_seen==0xFF) && (zeros_seen==0xFF) ){  Serial.print("PASSED");  }

    return;
}


void test_3() {
    
    uint8_t  temp_array[0x10000];
    uint32_t addr=0;
    uint32_t failcount=0;
      
    Serial.println("KERNAL ROM Tests");
    Serial.println("----------------");
    
    
    // Fill all DRAM with 0x00
    //
    // Set bank mode 24,28 -- All DRAM
    //
    digitalWriteFast(PIN_P2, 0x0);  // CHAREN_n
    digitalWriteFast(PIN_P1, 0x0);  // HIRAM_n
    digitalWriteFast(PIN_P0, 0x0);  // LORAM_n
    delay (50);
    for (addr=0x0; addr<=0xFFFF; addr++)    write_byte(addr , 0x00);  
    
    
    // Set bank mode 27 -- All ROMS accessible
    //
    digitalWriteFast(PIN_P2, 0x0);  // CHAREN_n
    digitalWriteFast(PIN_P1, 0x1);  // HIRAM_n
    digitalWriteFast(PIN_P0, 0x1);  // LORAM_n
    delay (50); 
    
    Serial.println("Dumping KERNAL ROM:");
    for (addr=0xE000; addr<=0xFFFF; addr++) {   Serial.print(read_byte(addr),HEX); Serial.print(" "); } 
    
    Serial.println("");
    Serial.println("");
    Serial.print("Searching for stuck data bits.................................................. ");
    search_stuck_databits(0xE000 , 0xFFFF);
    
    Serial.println("");
    Serial.print("Reading entire ROM contents five times to see if data is consistent/stable...... ");
    
    // Read the ROM contents four times to establish if data is stable
    //
    failcount=0;
    for (addr=0xE000; addr<=0xFFFF; addr++) temp_array[addr] = read_byte(addr);
    for (addr=0xE000; addr<=0xFFFF; addr++) { if (temp_array[addr] != read_byte(addr)) failcount++; } 
    for (addr=0xE000; addr<=0xFFFF; addr++) { if (temp_array[addr] != read_byte(addr)) failcount++; }
    for (addr=0xE000; addr<=0xFFFF; addr++) { if (temp_array[addr] != read_byte(addr)) failcount++; }
    for (addr=0xE000; addr<=0xFFFF; addr++) { if (temp_array[addr] != read_byte(addr)) failcount++; }
    for (addr=0xE000; addr<=0xFFFF; addr++) { if (temp_array[addr] != read_byte(addr)) failcount++; }  
    for (addr=0xE000; addr<=0xFFFF; addr++) { if (temp_array[addr] != read_byte(addr)) failcount++; } 
    for (addr=0xE000; addr<=0xFFFF; addr++) { if (temp_array[addr] != read_byte(addr)) failcount++; }
    for (addr=0xE000; addr<=0xFFFF; addr++) { if (temp_array[addr] != read_byte(addr)) failcount++; }
    for (addr=0xE000; addr<=0xFFFF; addr++) { if (temp_array[addr] != read_byte(addr)) failcount++; }
    for (addr=0xE000; addr<=0xFFFF; addr++) { if (temp_array[addr] != read_byte(addr)) failcount++; }
   
    if (failcount==0) { Serial.println("PASSED");  }
    else              { Serial.print  ("FAILED -- "); Serial.print(failcount,DEC); Serial.println(" failures"); }
            
    return;
}



void test_4() {
    
    uint8_t  temp_array[0x10000];
    uint32_t addr=0;
    uint32_t failcount=0;
      
    Serial.println("BASIC ROM Tests");
    Serial.println("---------------");


    // Fill all DRAM with 0x00
    //
    // Set bank mode 24,28 -- All DRAM
    //
    digitalWriteFast(PIN_P2, 0x0);  // CHAREN_n
    digitalWriteFast(PIN_P1, 0x0);  // HIRAM_n
    digitalWriteFast(PIN_P0, 0x0);  // LORAM_n
    delay (50);
    for (addr=0x0; addr<=0xFFFF; addr++)    write_byte(addr , 0x00);  


    // Set bank mode 27 -- All ROMS accessible
    //
    digitalWriteFast(PIN_P2, 0x0);  // CHAREN_n
    digitalWriteFast(PIN_P1, 0x1);  // HIRAM_n
    digitalWriteFast(PIN_P0, 0x1);  // LORAM_n
    delay (50); 

    Serial.println("Dumping BASIC ROM:");
    for (addr=0xA000; addr<=0xBFFF; addr++) {   Serial.print(read_byte(addr),HEX); Serial.print(" "); } 

    Serial.println("");
    Serial.println("");
    Serial.print("Searching for stuck data bits............................................ ");
    search_stuck_databits(0xE000 , 0xFFFF);
    
    Serial.println("");
    Serial.print("Reading entire ROM contents ten times to see if data is consistent/stable...... ");
    
    // Read the ROM contents four times to establish if data is stable
    //
    failcount=0;
    for (addr=0xA000; addr<=0xBFFF; addr++) temp_array[addr] = read_byte(addr);
    for (addr=0xA000; addr<=0xBFFF; addr++) { if (temp_array[addr] != read_byte(addr)) failcount++; } 
    for (addr=0xA000; addr<=0xBFFF; addr++) { if (temp_array[addr] != read_byte(addr)) failcount++; }
    for (addr=0xA000; addr<=0xBFFF; addr++) { if (temp_array[addr] != read_byte(addr)) failcount++; }
    for (addr=0xA000; addr<=0xBFFF; addr++) { if (temp_array[addr] != read_byte(addr)) failcount++; }
    for (addr=0xA000; addr<=0xBFFF; addr++) { if (temp_array[addr] != read_byte(addr)) failcount++; }  
    for (addr=0xA000; addr<=0xBFFF; addr++) { if (temp_array[addr] != read_byte(addr)) failcount++; } 
    for (addr=0xA000; addr<=0xBFFF; addr++) { if (temp_array[addr] != read_byte(addr)) failcount++; }
    for (addr=0xA000; addr<=0xBFFF; addr++) { if (temp_array[addr] != read_byte(addr)) failcount++; }
    for (addr=0xA000; addr<=0xBFFF; addr++) { if (temp_array[addr] != read_byte(addr)) failcount++; }
    for (addr=0xA000; addr<=0xBFFF; addr++) { if (temp_array[addr] != read_byte(addr)) failcount++; }

    if (failcount==0) { Serial.println("PASSED");  }
    else              { Serial.print  ("FAILED -- "); Serial.print(failcount,DEC); Serial.println(" failures"); }
          
  
    return;
}



void test_5() {
    
    uint8_t  temp_array[0x10000];
    uint32_t addr=0;
    uint32_t failcount=0;
      
    Serial.println("CHARACTER ROM Tests");
    Serial.println("-------------------");


    // Fill all DRAM with 0x00
    //
    // Set bank mode 24,28 -- All DRAM
    //
    digitalWriteFast(PIN_P2, 0x0);  // CHAREN_n
    digitalWriteFast(PIN_P1, 0x0);  // HIRAM_n
    digitalWriteFast(PIN_P0, 0x0);  // LORAM_n
    delay (50);
    for (addr=0x0; addr<=0xFFFF; addr++)    write_byte(addr , 0x00);  


    // Set bank mode 27 -- All ROMS accessible
    //
    digitalWriteFast(PIN_P2, 0x0);  // CHAREN_n
    digitalWriteFast(PIN_P1, 0x1);  // HIRAM_n
    digitalWriteFast(PIN_P0, 0x1);  // LORAM_n
    delay (50); 

    Serial.println("Dumping CHARACTER ROM:");
    for (addr=0xD000; addr<=0xDFFF; addr++) {   Serial.print(read_byte(addr),HEX); Serial.print(" "); } 
  
    Serial.println("");
    Serial.println("");
    Serial.print("Searching for stuck data bits............................................ ");
    search_stuck_databits(0xE000 , 0xFFFF);
    
    Serial.println("");
    Serial.print("Reading entire ROM contents ten times to see if data is consistent/stable...... ");
    
    // Read the ROM contents ten times to establish if data is stable
    //
    failcount=0;
    for (addr=0xD000; addr<=0xDFFF; addr++) temp_array[addr] = read_byte(addr);
    for (addr=0xD000; addr<=0xDFFF; addr++) { if (temp_array[addr] != read_byte(addr)) failcount++; } 
    for (addr=0xD000; addr<=0xDFFF; addr++) { if (temp_array[addr] != read_byte(addr)) failcount++; }
    for (addr=0xD000; addr<=0xDFFF; addr++) { if (temp_array[addr] != read_byte(addr)) failcount++; }
    for (addr=0xD000; addr<=0xDFFF; addr++) { if (temp_array[addr] != read_byte(addr)) failcount++; }
    for (addr=0xD000; addr<=0xDFFF; addr++) { if (temp_array[addr] != read_byte(addr)) failcount++; }
    for (addr=0xD000; addr<=0xDFFF; addr++) { if (temp_array[addr] != read_byte(addr)) failcount++; } 
    for (addr=0xD000; addr<=0xDFFF; addr++) { if (temp_array[addr] != read_byte(addr)) failcount++; }
    for (addr=0xD000; addr<=0xDFFF; addr++) { if (temp_array[addr] != read_byte(addr)) failcount++; }
    for (addr=0xD000; addr<=0xDFFF; addr++) { if (temp_array[addr] != read_byte(addr)) failcount++; }
    for (addr=0xD000; addr<=0xDFFF; addr++) { if (temp_array[addr] != read_byte(addr)) failcount++; }

    if (failcount==0) { Serial.println("PASSED");  }
    else              { Serial.print  ("FAILED -- "); Serial.print(failcount,DEC); Serial.println(" failures"); }
          
  
return;
}


void dram_test_0() {
    
    uint32_t addr=0;

    // Set bank mode 24,28 -- All DRAM
    //
    digitalWriteFast(PIN_P2, 0x0);  // CHAREN_n
    digitalWriteFast(PIN_P1, 0x0);  // HIRAM_n
    digitalWriteFast(PIN_P0, 0x0);  // LORAM_n
    delay (50);
    
    // Fill DRAM with random data
    for (addr=0x0; addr<=0xFFFF; addr++)    write_byte(addr , random(255));  

    Serial.println("");
    Serial.println("");
    Serial.print("Searching for stuck data bits............................................ ");
    search_stuck_databits(0x0000 , 0xFF00);

    return;
}

void dram_test_1() {
    
    uint8_t  temp_array[0x10000];
    uint8_t  loopcount=0;
    uint32_t addr=0;
    uint32_t failcount=0;
    
    // Set bank mode 24,28 -- All DRAM
    //
    digitalWriteFast(PIN_P2, 0x0);  // CHAREN_n
    digitalWriteFast(PIN_P1, 0x0);  // HIRAM_n
    digitalWriteFast(PIN_P0, 0x0);  // LORAM_n
    delay (50);
    
    Serial.println("");
    Serial.print("Reading all 64KB of DRAM contents twenty times to see if data is consistent/stable...... ");
    
    // Fill all 64KB of DRAM with random data, then readback twenty times to establish if data is stable
    //
    failcount=0;
    for (addr=0x0000; addr<=0xFFFF; addr++) { temp_array[addr] = random(255);  write_byte(addr, (temp_array[addr])); }
    
    for (loopcount=0; loopcount<=20; loopcount++) { 
      for (addr=0x0000; addr<=0xFFFF; addr++) { if (temp_array[addr] != read_byte(addr)) failcount++; } 
    }
    
    if (failcount==0) { Serial.println("PASSED");  }
    else              { Serial.print  ("FAILED -- "); Serial.print(failcount,DEC); Serial.println(" failures"); }
          
    return;
}

void dram_test_2() {
    
    uint32_t   loopcount=0;
    uint32_t failcount0=0;
    uint32_t failcount1=0;
    uint32_t failcount2=0;
    uint32_t failcount3=0;
    uint32_t failcount4=0;
    uint32_t failcount5=0;
    uint32_t failcount6=0;
    uint32_t failcount7=0;
      
      
    // Set bank mode 24,28 -- All DRAM
    //
    digitalWriteFast(PIN_P2, 0x0);  // CHAREN_n
    digitalWriteFast(PIN_P1, 0x0);  // HIRAM_n
    digitalWriteFast(PIN_P0, 0x0);  // LORAM_n
    delay (50);
    
    Serial.println("");
    Serial.println("Testing each DRAM Data bit 10,000 times ...... ");
    
    for (loopcount=0; loopcount<=10000; loopcount++) { 
      write_byte(0x0000, 0x01);   if (read_byte(0x0000) != 0x01) failcount0++;
      write_byte(0x0000, 0x02);   if (read_byte(0x0000) != 0x02) failcount1++;
      write_byte(0x0000, 0x04);   if (read_byte(0x0000) != 0x04) failcount2++;
      write_byte(0x0000, 0x08);   if (read_byte(0x0000) != 0x08) failcount3++;
      write_byte(0x0000, 0x10);   if (read_byte(0x0000) != 0x10) failcount4++;
      write_byte(0x0000, 0x20);   if (read_byte(0x0000) != 0x20) failcount5++;
      write_byte(0x0000, 0x40);   if (read_byte(0x0000) != 0x40) failcount6++;
      write_byte(0x0000, 0x80);   if (read_byte(0x0000) != 0x80) failcount7++;
       
    }

    if (failcount0==0) { Serial.println("Data Bit 0 PASSED");  }
    else               { Serial.print  ("Data Bit 0 FAILED -- "); Serial.print(failcount0,DEC); Serial.println(" failures"); }
     
    if (failcount1==0) { Serial.println("Data Bit 1 PASSED");  }
    else               { Serial.print  ("Data Bit 1 FAILED -- "); Serial.print(failcount1,DEC); Serial.println(" failures"); }
     
    if (failcount2==0) { Serial.println("Data Bit 2 PASSED");  }
    else               { Serial.print  ("Data Bit 2 FAILED -- "); Serial.print(failcount2,DEC); Serial.println(" failures"); }
     
    if (failcount3==0) { Serial.println("Data Bit 3 PASSED");  }
    else               { Serial.print  ("Data Bit 3 FAILED -- "); Serial.print(failcount3,DEC); Serial.println(" failures"); }
     
    if (failcount4==0) { Serial.println("Data Bit 4 PASSED");  }
    else               { Serial.print  ("Data Bit 4 FAILED -- "); Serial.print(failcount4,DEC); Serial.println(" failures"); }
     
    if (failcount5==0) { Serial.println("Data Bit 5 PASSED");  }
    else               { Serial.print  ("Data Bit 5 FAILED -- "); Serial.print(failcount5,DEC); Serial.println(" failures"); }
     
    if (failcount6==0) { Serial.println("Data Bit 6 PASSED");  }
    else               { Serial.print  ("Data Bit 6 FAILED -- "); Serial.print(failcount6,DEC); Serial.println(" failures"); }
     
    if (failcount7==0) { Serial.println("Data Bit 7 PASSED");  }
    else               { Serial.print  ("Data Bit 7 FAILED -- "); Serial.print(failcount7,DEC); Serial.println(" failures"); }
          
    return;
}


void dram_test_3() {
    
    uint32_t loopcount=0;
    uint32_t failcount0=0;

      
    // Set bank mode 24,28 -- All DRAM
    //
    digitalWriteFast(PIN_P2, 0x0);  // CHAREN_n
    digitalWriteFast(PIN_P1, 0x0);  // HIRAM_n
    digitalWriteFast(PIN_P0, 0x0);  // LORAM_n
    delay (50);
    
    Serial.println("");
    Serial.println("Writing DRAM, waiting one second, then reading back to see if refresh working ...... ");
    
    
    for (loopcount=0; loopcount<=5; loopcount++) { 
      Serial.print("Writing ");  write_byte(0x0000, 0x5A);   delay(1000);   Serial.println("Reading "); if (read_byte(0x0000) != 0x5A) failcount0++;
      Serial.print("Writing ");  write_byte(0x0000, 0xA5);   delay(1000);   Serial.println("Reading "); if (read_byte(0x0000) != 0xA5) failcount0++;
     
    }

    if (failcount0==0) { Serial.println("PASSED");  }
    else               { Serial.print  ("FAILED -- "); Serial.print(failcount0,DEC); Serial.println(" failures"); }
     
    return;
}


void dram_test_4() {
    
    uint32_t loopcount=0;
    uint32_t failcount0=0;
    uint32_t failcount1=0;
    uint32_t failcount2=0;
    uint32_t failcount3=0;
    uint32_t failcount4=0;
    uint32_t failcount5=0;
    uint32_t failcount6=0;
    uint32_t failcount7=0;      
    uint32_t failcount8=0;
    uint32_t failcount9=0;
    uint32_t failcounta=0;
    uint32_t failcountb=0;
    uint32_t failcountc=0;
    uint32_t failcountd=0;
    uint32_t failcounte=0;
    uint32_t failcountf=0;
      
    // Set bank mode 24,28 -- All DRAM
    //
    digitalWriteFast(PIN_P2, 0x0);  // CHAREN_n
    digitalWriteFast(PIN_P1, 0x0);  // HIRAM_n
    digitalWriteFast(PIN_P0, 0x0);  // LORAM_n
    delay (50);
    
    Serial.println("");
    Serial.println("Testing each DRAM Address bit 10,000 times ...... ");

    for (loopcount=0; loopcount<=10000; loopcount++) { 
      write_byte(0x0001, 0x00);  
      write_byte(0x0002, 0x11);  
      write_byte(0x0004, 0x22);  
      write_byte(0x0008, 0x33);  
      write_byte(0x0010, 0x44);  
      write_byte(0x0020, 0x55);  
      write_byte(0x0040, 0x66);  
      write_byte(0x0080, 0x77);  
      write_byte(0x0100, 0x88);  
      write_byte(0x0200, 0x99);  
      write_byte(0x0400, 0xaa);  
      write_byte(0x0800, 0xbb);  
      write_byte(0x1000, 0xcc);  
      write_byte(0x2000, 0xdd);  
      write_byte(0x4000, 0xee);  
      write_byte(0x8000, 0xff);  
      
      if (read_byte(0x0001) != 0x00) failcount0++;
      if (read_byte(0x0002) != 0x11) failcount1++;
      if (read_byte(0x0004) != 0x22) failcount2++;
      if (read_byte(0x0008) != 0x33) failcount3++;
      if (read_byte(0x0010) != 0x44) failcount4++;
      if (read_byte(0x0020) != 0x55) failcount5++;
      if (read_byte(0x0040) != 0x66) failcount6++;
      if (read_byte(0x0080) != 0x77) failcount7++;
      if (read_byte(0x0100) != 0x88) failcount8++;
      if (read_byte(0x0200) != 0x99) failcount9++;
      if (read_byte(0x0400) != 0xaa) failcounta++;
      if (read_byte(0x0800) != 0xbb) failcountb++;
      if (read_byte(0x1000) != 0xcc) failcountc++;
      if (read_byte(0x2000) != 0xdd) failcountd++;
      if (read_byte(0x4000) != 0xee) failcounte++;
      if (read_byte(0x8000) != 0xff) failcountf++;
    }

    if (failcount0==0) { Serial.println("Address Bit 0 PASSED");  }
    else               { Serial.print  ("Address Bit 0 FAILED -- "); Serial.print(failcount0,DEC); Serial.println(" failures"); }
     
    if (failcount1==0) { Serial.println("Address Bit 1 PASSED");  }
    else               { Serial.print  ("Address Bit 1 FAILED -- "); Serial.print(failcount1,DEC); Serial.println(" failures"); }
     
    if (failcount2==0) { Serial.println("Address Bit 2 PASSED");  }
    else               { Serial.print  ("Address Bit 2 FAILED -- "); Serial.print(failcount2,DEC); Serial.println(" failures"); }
     
    if (failcount3==0) { Serial.println("Address Bit 3 PASSED");  }
    else               { Serial.print  ("Address Bit 3 FAILED -- "); Serial.print(failcount3,DEC); Serial.println(" failures"); }
     
    if (failcount4==0) { Serial.println("Address Bit 4 PASSED");  }
    else               { Serial.print  ("Address Bit 4 FAILED -- "); Serial.print(failcount4,DEC); Serial.println(" failures"); }
     
    if (failcount5==0) { Serial.println("Address Bit 5 PASSED");  }
    else               { Serial.print  ("Address Bit 5 FAILED -- "); Serial.print(failcount5,DEC); Serial.println(" failures"); }
     
    if (failcount6==0) { Serial.println("Address Bit 6 PASSED");  }
    else               { Serial.print  ("Address Bit 6 FAILED -- "); Serial.print(failcount6,DEC); Serial.println(" failures"); }
     
    if (failcount7==0) { Serial.println("Address Bit 7 PASSED");  }
    else               { Serial.print  ("Address Bit 7 FAILED -- "); Serial.print(failcount7,DEC); Serial.println(" failures"); }
          
    
    if (failcount8==0) { Serial.println("Address Bit 8 PASSED");  }
    else               { Serial.print  ("Address Bit 8 FAILED -- "); Serial.print(failcount8,DEC); Serial.println(" failures"); }
     
    if (failcount9==0) { Serial.println("Address Bit 9 PASSED");  }
    else               { Serial.print  ("Address Bit 9 FAILED -- "); Serial.print(failcount9,DEC); Serial.println(" failures"); }
     
    if (failcounta==0) { Serial.println("Address Bit 10 PASSED");  }
    else               { Serial.print  ("Address Bit 10 FAILED -- "); Serial.print(failcounta,DEC); Serial.println(" failures"); }
     
    if (failcountb==0) { Serial.println("Address Bit 11 PASSED");  }
    else               { Serial.print  ("Address Bit 11 FAILED -- "); Serial.print(failcountb,DEC); Serial.println(" failures"); }
     
    if (failcountc==0) { Serial.println("Address Bit 12 PASSED");  }
    else               { Serial.print  ("Address Bit 12 FAILED -- "); Serial.print(failcountc,DEC); Serial.println(" failures"); }
     
    if (failcountd==0) { Serial.println("Address Bit 13 PASSED");  }
    else               { Serial.print  ("Address Bit 13 FAILED -- "); Serial.print(failcountd,DEC); Serial.println(" failures"); }
     
    if (failcounte==0) { Serial.println("Address Bit 14 PASSED");  }
    else               { Serial.print  ("Address Bit 14 FAILED -- "); Serial.print(failcounte,DEC); Serial.println(" failures"); }
     
    if (failcountf==0) { Serial.println("Address Bit 15 PASSED");  }
    else               { Serial.print  ("Address Bit 15 FAILED -- "); Serial.print(failcountf,DEC); Serial.println(" failures"); }
          
    return;
}


void dram_test_5() {
    
    uint32_t addr=0;


    Serial.println("");
    Serial.println("###########################################################");
    Serial.println("DRAM Probing Tests - All data bits are set to 0 ");
    Serial.println("Use oscilloscope to see if each data bit is always 0");
    Serial.println("Data bit for each DRAM is on pin-2");
    Serial.println("###########################################################");
    

    // Set bank mode 24,28 -- All DRAM
    //
    digitalWriteFast(PIN_P2, 0x0);  // CHAREN_n
    digitalWriteFast(PIN_P1, 0x0);  // HIRAM_n
    digitalWriteFast(PIN_P0, 0x0);  // LORAM_n
    delay (50);
    
    // Fill all 64KB of DRAM with 0x00
    //    
    for (addr=0x0; addr<=0xFFFF; addr++)    write_byte(addr , 0x00);  
    write_byte(0x0000 , 0x00);  
    
    return;
}


void dram_test_6() {
    
    uint32_t addr=0;


    Serial.println("");
    Serial.println("###########################################################");
    Serial.println("DRAM Probing Tests - All data bits are set to 1 ");
    Serial.println("Use oscilloscope to confirm that each data bit is toggling");
    Serial.println("Data bit for each DRAM is on pin-2");
    Serial.println("###########################################################");
    

    // Set bank mode 24,28 -- All DRAM
    //
    digitalWriteFast(PIN_P2, 0x0);  // CHAREN_n
    digitalWriteFast(PIN_P1, 0x0);  // HIRAM_n
    digitalWriteFast(PIN_P0, 0x0);  // LORAM_n
    delay (50);
    
    // Fill all 64KB of DRAM with 0xFF
    //
    for (addr=0x0; addr<=0xFFFF; addr++)    write_byte(addr , 0xFF);  
    write_byte(0x0000 , 0xFF);  

    return;
}


void dram_test_7() {
    
    uint32_t addr=0;


    Serial.println("");
    Serial.println("###########################################################");
    Serial.println("###########################################################");
    Serial.println("");
    Serial.println("---------------------------------------------------------------");
    Serial.println(" !!! INFINITE LOOP - POWER MUST BE CYCLED TO EXIT THIS TEST !!!");
    Serial.println("---------------------------------------------------------------");
    Serial.println("");
    Serial.println("These bits should be toggling on all DRAMS: ");
    Serial.println("Each DRAM pin-4    RAS");
    Serial.println("Each DRAM pin-15   CAS");
    Serial.println("Each DRAM pin-3    WE");
    Serial.println("U8 pin-4           AEC-inverted");
    Serial.println("U13 pin-9          Muxed address bit 7");
    Serial.println("U13 pin-4          Muxed address bit 6");
    Serial.println("U13 pin-7          Muxed address bit 5");
    Serial.println("U13 pin-12         Muxed address bit 4");  
    Serial.println("U25 pin-4          Muxed address bit 3");
    Serial.println("U25 pin-7          Muxed address bit 2");
    Serial.println("U25 pin-9          Muxed address bit 1");
    Serial.println("U25 pin-12         Muxed address bit 0");
    Serial.println("###########################################################");
    Serial.println("###########################################################");
    
    // Fill all DRAM with 0xFF
    //
    // Set bank mode 24,28 -- All DRAM
    //
    digitalWriteFast(PIN_P2, 0x0);  // CHAREN_n
    digitalWriteFast(PIN_P1, 0x0);  // HIRAM_n
    digitalWriteFast(PIN_P0, 0x0);  // LORAM_n
    delay (50);
    
    while (1) {
      for (addr=0x0; addr<=0xFFFF; addr++)    write_byte(addr , addr);  
    }

    return;
}


void test_6() {
    
    while (1) {
        
        Serial.println("");
        Serial.println("");
        Serial.println("DRAM Tests");
        Serial.println("Menu");
        Serial.println("----");
        Serial.println("0) DATA: Stuck Data bit");
        Serial.println("1) DATA: Stability");
        Serial.println("2) DATA: Walking Data bit");
        Serial.println("3) DATA: Refresh");
        Serial.println("4) ADDRESS: Walking Address bit");
        Serial.println("5) PROBE: All Data Bits Set To 0");
        Serial.println("6) PROBE: All Data Bits Set To 1");
        Serial.println("7) PROBE: DRAM Control Logic");
        Serial.println("x) Exit to Main Menu ");
        Serial.println("");
        
        while (Serial.available()==0 ) { }
        incomingByte = Serial.read();   
        switch (incomingByte){
          case 48: dram_test_0();  break;
          case 49: dram_test_1();  break;
          case 50: dram_test_2();  break;
          case 51: dram_test_3();  break;
          case 52: dram_test_4();  break;
          case 53: dram_test_5();  break;
          case 54: dram_test_6();  break;
          case 55: dram_test_7();  break;
          case 120: return;  break;
        
        }
    }
    return;
}



void color_ram_test_0() {
    
    uint32_t addr=0;

    // Bank Mode 31 -- I/O Range is accessible
    //
    digitalWriteFast(PIN_P2, 0x1);  // CHAREN_n
    digitalWriteFast(PIN_P1, 0x1);  // HIRAM_n
    digitalWriteFast(PIN_P0, 0x1);  // LORAM_n
    delay (50);
        
    for (addr=0x0; addr<=0x00FF; addr++)    write_byte(addr , random(255));  

    Serial.println("");
    Serial.println("");
    Serial.print("Searching for stuck data bits............................................ ");
    search_stuck_databits(0xD800 , 0xDBE7);

    return;
}


void color_ram_test_1() {
    
    uint8_t  temp_array[0x10000];
    uint8_t  loopcount=0;
    uint32_t addr=0;
    uint32_t failcount=0;

    // Bank Mode 31 -- I/O Range is accessible
    //
    digitalWriteFast(PIN_P2, 0x1);  // CHAREN_n
    digitalWriteFast(PIN_P1, 0x1);  // HIRAM_n
    digitalWriteFast(PIN_P0, 0x1);  // LORAM_n
    delay (50);
    
    Serial.println("");
    Serial.print("Reading Color RAM contents two hundred times to see if data is consistent/stable...... ");
    
    // Fill Color RAM with random data, then readback twenty times to establish if data is stable
    //
    failcount=0;
    for (addr=0xD800; addr<=0xDBE7; addr++) { temp_array[addr] = (0x0F&random(255));  write_byte(addr, (temp_array[addr])); }
    
    for (loopcount=0; loopcount<=200; loopcount++) { 
      for (addr=0xD800; addr<=0xDBE7; addr++) { if (temp_array[addr] != (0x0F&read_byte(addr))) failcount++; } 
    }
    
      if (failcount==0) { Serial.println("PASSED");  }
      else              { Serial.print  ("FAILED -- "); Serial.print(failcount,DEC); Serial.println(" failures"); }
            
    
    return;
}


void color_ram_test_2() {
    
    uint32_t loopcount=0;
    uint32_t failcount0=0;
    uint32_t failcount1=0;
    uint32_t failcount2=0;
    uint32_t failcount3=0;

      
    // Bank Mode 31 -- I/O Range is accessible
    //
    digitalWriteFast(PIN_P2, 0x1);  // CHAREN_n
    digitalWriteFast(PIN_P1, 0x1);  // HIRAM_n
    digitalWriteFast(PIN_P0, 0x1);  // LORAM_n
    delay (50);
    
    Serial.println("");
    Serial.println("Testing each Color RAM Data bit 10,000 times ...... ");


    for (loopcount=0; loopcount<=10000; loopcount++) { 
      write_byte(0xD800, 0x01);   if ((0x0F&read_byte(0xD800)) != 0x01) failcount0++;
      write_byte(0xD800, 0x02);   if ((0x0F&read_byte(0xD800)) != 0x02) failcount1++;
      write_byte(0xD800, 0x04);   if ((0x0F&read_byte(0xD800)) != 0x04) failcount2++;
      write_byte(0xD800, 0x08);   if ((0x0F&read_byte(0xD800)) != 0x08) failcount3++;     
    }

    if (failcount0==0) { Serial.println("Data Bit 0 PASSED");  }
    else               { Serial.print  ("Data Bit 0 FAILED -- "); Serial.print(failcount0,DEC); Serial.println(" failures"); }
     
    if (failcount1==0) { Serial.println("Data Bit 1 PASSED");  }
    else               { Serial.print  ("Data Bit 1 FAILED -- "); Serial.print(failcount1,DEC); Serial.println(" failures"); }
     
    if (failcount2==0) { Serial.println("Data Bit 2 PASSED");  }
    else               { Serial.print  ("Data Bit 2 FAILED -- "); Serial.print(failcount2,DEC); Serial.println(" failures"); }
     
    if (failcount3==0) { Serial.println("Data Bit 3 PASSED");  }
    else               { Serial.print  ("Data Bit 3 FAILED -- "); Serial.print(failcount3,DEC); Serial.println(" failures"); }
    

    return;
}


void color_ram_test_3() {
    
    uint32_t addr=0;


    Serial.println("");
    Serial.println("###########################################################");
    Serial.println("Color RAM Probing Tests - All data bits are set to 0 ");
    Serial.println("Use oscilloscope to see if each data bit is always 0");
    Serial.println("Data bits for Color RAM are on U6 pins 11,12,13,14");
    Serial.println("###########################################################");
    
    // Bank Mode 31 -- I/O Range is accessible
    //
    digitalWriteFast(PIN_P2, 0x1);  // CHAREN_n
    digitalWriteFast(PIN_P1, 0x1);  // HIRAM_n
    digitalWriteFast(PIN_P0, 0x1);  // LORAM_n
    delay (50);
    for (addr=0x0; addr<=0xFFFF; addr++)    write_byte(addr , 0x00);  
    write_byte(0xD800 , 0x00);  

    return;
}


void color_ram_test_4() {
    
    uint32_t addr=0;


    Serial.println("");
    Serial.println("###########################################################");
    Serial.println("Color RAM Probing Tests - All data bits are set to 1 ");
    Serial.println("Use oscilloscope to confirm that each data bit is toggling");
    Serial.println("Data bits for Color RAM are on U6 pins 11,12,13,14");
    Serial.println("###########################################################");
    
    // Bank Mode 31 -- I/O Range is accessible
    //
    digitalWriteFast(PIN_P2, 0x1);  // CHAREN_n
    digitalWriteFast(PIN_P1, 0x1);  // HIRAM_n
    digitalWriteFast(PIN_P0, 0x1);  // LORAM_n
    delay (50);
    for (addr=0x0; addr<=0xFFFF; addr++)    write_byte(addr , 0xFF);  
    write_byte(0xD800 , 0xFF);  

    return;
}


void color_ram_test_5() {
    
    uint32_t addr=0;


    Serial.println("");
    Serial.println("###########################################################");
    Serial.println("###########################################################");
    Serial.println("");
    Serial.println("INFINITE LOOP - POWER MUST BE CYCLED TO EXIT THIS TEST");
    Serial.println("------------------------------------------------------");
    Serial.println("");
    Serial.println("These bits should be toggling on the Color RAM - U6: ");
    Serial.println("Color RAM pin-8    Chip Select");
    Serial.println("Color RAM pin-10   Write Enable");
    Serial.println("U27 pin-11         Chip Select Source");
    Serial.println("U27 pin-12         AEC from VIC-II");
    Serial.println("U15 pin-6          Chip Select Source from PLA");
    Serial.println("###########################################################");
    Serial.println("###########################################################");
    
    // Bank Mode 31 -- I/O Range is accessible
    //
    digitalWriteFast(PIN_P2, 0x1);  // CHAREN_n
    digitalWriteFast(PIN_P1, 0x1);  // HIRAM_n
    digitalWriteFast(PIN_P0, 0x1);  // LORAM_n
    delay (50);
    
    while (1) {
      for (addr=0xD800; addr<=0xDBE7; addr++)    write_byte(addr , addr);  
    }

    return;
}


void test_7() {
    
    while (1) {
        Serial.println("");
        Serial.println("");
        Serial.println("Color RAM Tests");
        Serial.println("Menu");
        Serial.println("----");
        Serial.println("0) DATA: Stuck Data bit");
        Serial.println("1) DATA: Stability");
        Serial.println("2) DATA: Walking Data bit");
        Serial.println("3) PROBE: All Data Bits Set To 0");
        Serial.println("4) PROBE: All Data Bits Set To 1");
        Serial.println("5) PROBE: Color RAM Control Logic");
        Serial.println("x) Exit to Main Menu ");
        Serial.println("");
        
        while (Serial.available()==0 ) { }
        incomingByte = Serial.read();   
        switch (incomingByte){
          case 48: color_ram_test_0();  break;
          case 49: color_ram_test_1();  break;
          case 50: color_ram_test_2();  break;
          case 51: color_ram_test_3();  break;
          case 52: color_ram_test_4();  break;
          case 53: color_ram_test_5();  break;
          case 120: return;  break;

        }
    }
    return;
}


void vic2_test_0() {
    
    uint8_t  pass=0;
    uint8_t  character_5=0;
    uint32_t addr=0;


    // Bank Mode 31 -- I/O Range is accessible
    //
    digitalWriteFast(PIN_P2, 0x1);  // CHAREN_n
    digitalWriteFast(PIN_P1, 0x1);  // HIRAM_n
    digitalWriteFast(PIN_P0, 0x1);  // LORAM_n
    delay (50);
    
    Serial.print("VIC-II Registers...");
    pass=1;
    for (addr=0xD000; addr<=0xD00F; addr++)  {
      write_byte(addr , addr);
      character_5 = read_byte(addr);
      if ((0xFF&addr) != character_5) {  pass=0; }
    }
    if (pass==1) { Serial.println("PASSED");  } else { Serial.println("FAILED ####");  }

    return;
}


void vic2_test_1() {
    
    uint8_t   temp_array[0x10000];
    uint8_t   loopcount=0;
    uint32_t  addr=0;
    uint32_t  failcount=0;


    // Bank Mode 31 -- I/O Range is accessible
    //
    digitalWriteFast(PIN_P2, 0x1);  // CHAREN_n
    digitalWriteFast(PIN_P1, 0x1);  // HIRAM_n
    digitalWriteFast(PIN_P0, 0x1);  // LORAM_n
    delay (50);
    
    Serial.println("");
    Serial.print("Reading VIC-II register contents two hundred times to see if data is consistent/stable...... ");
    
    // Fill Color RAM with random data, then readback two hundred times to establish if data is stable
    //
    failcount=0;
    for (addr=0xD000; addr<=0xD003; addr++) { temp_array[addr] = random(255);  write_byte(addr, (temp_array[addr])); }
    
    for (loopcount=0; loopcount<=200; loopcount++) { 
      for (addr=0xD000; addr<=0xD003; addr++) { if (temp_array[addr] != read_byte(addr)) failcount++; } 
    }
    
      if (failcount==0) { Serial.println("PASSED");  }
      else              { Serial.print  ("FAILED -- "); Serial.print(failcount,DEC); Serial.println(" failures"); }
          
  
    return;
}

void vic2_test_2() {
    
    uint32_t loopcount=0;
    uint32_t failcount0=0;
    uint32_t failcount1=0;
    uint32_t failcount2=0;
    uint32_t failcount3=0;
    uint32_t failcount4=0;
    uint32_t failcount5=0;
    uint32_t failcount6=0;
    uint32_t failcount7=0;
      
      
    // Bank Mode 31 -- I/O Range is accessible
    //
    digitalWriteFast(PIN_P2, 0x1);  // CHAREN_n
    digitalWriteFast(PIN_P1, 0x1);  // HIRAM_n
    digitalWriteFast(PIN_P0, 0x1);  // LORAM_n
    delay (50);
    
    Serial.println("");
    Serial.println("Testing each VIC-II Data bit 10,000 times ...... ");
    
    for (loopcount=0; loopcount<=10000; loopcount++) { 
      write_byte(0xD000, 0x01);   if (read_byte(0xD000) != 0x01) failcount0++;
      write_byte(0xD000, 0x02);   if (read_byte(0xD000) != 0x02) failcount1++;
      write_byte(0xD000, 0x04);   if (read_byte(0xD000) != 0x04) failcount2++;
      write_byte(0xD000, 0x08);   if (read_byte(0xD000) != 0x08) failcount3++;
      write_byte(0xD000, 0x10);   if (read_byte(0xD000) != 0x10) failcount4++;
      write_byte(0xD000, 0x20);   if (read_byte(0xD000) != 0x20) failcount5++;
      write_byte(0xD000, 0x40);   if (read_byte(0xD000) != 0x40) failcount6++;
      write_byte(0xD000, 0x80);   if (read_byte(0xD000) != 0x80) failcount7++;
    }

    if (failcount0==0) { Serial.println("Data Bit 0 PASSED");  }
    else               { Serial.print  ("Data Bit 0 FAILED -- "); Serial.print(failcount0,DEC); Serial.println(" failures"); }
     
    if (failcount1==0) { Serial.println("Data Bit 1 PASSED");  }
    else               { Serial.print  ("Data Bit 1 FAILED -- "); Serial.print(failcount1,DEC); Serial.println(" failures"); }
     
    if (failcount2==0) { Serial.println("Data Bit 2 PASSED");  }
    else               { Serial.print  ("Data Bit 2 FAILED -- "); Serial.print(failcount2,DEC); Serial.println(" failures"); }
     
    if (failcount3==0) { Serial.println("Data Bit 3 PASSED");  }
    else               { Serial.print  ("Data Bit 3 FAILED -- "); Serial.print(failcount3,DEC); Serial.println(" failures"); }
     
    if (failcount4==0) { Serial.println("Data Bit 4 PASSED");  }
    else               { Serial.print  ("Data Bit 4 FAILED -- "); Serial.print(failcount4,DEC); Serial.println(" failures"); }
     
    if (failcount5==0) { Serial.println("Data Bit 5 PASSED");  }
    else               { Serial.print  ("Data Bit 5 FAILED -- "); Serial.print(failcount5,DEC); Serial.println(" failures"); }
     
    if (failcount6==0) { Serial.println("Data Bit 6 PASSED");  }
    else               { Serial.print  ("Data Bit 6 FAILED -- "); Serial.print(failcount6,DEC); Serial.println(" failures"); }
     
    if (failcount7==0) { Serial.println("Data Bit 7 PASSED");  }
    else               { Serial.print  ("Data Bit 7 FAILED -- "); Serial.print(failcount7,DEC); Serial.println(" failures"); } 

    return;
}


void vic2_test_3() {
    
    uint32_t addr=0;


    Serial.println("");
    Serial.println("################################################################");
    Serial.println("VIC-II Probing Tests - All data bits are set to 0 ");
    Serial.println("Use oscilloscope to see that data appears like a CLOCK PATTERN");
    Serial.println("Data bits for VIC-II are on U19 pins 7,6,5,4,3,2,1,39");
    Serial.println("################################################################");
    
    // Bank Mode 31 -- I/O Range is accessible
    //
    digitalWriteFast(PIN_P2, 0x1);  // CHAREN_n
    digitalWriteFast(PIN_P1, 0x1);  // HIRAM_n
    digitalWriteFast(PIN_P0, 0x1);  // LORAM_n
    delay (50);
    for (addr=0xD000; addr<=0xD00F; addr++)    write_byte(addr , 0x00);  
    write_byte(0xD000 , 0x00);  

    return;
}


void vic2_test_4() {
    
    uint32_t addr=0;


    Serial.println("");
    Serial.println("################################################################");
    Serial.println("VIC-II Probing Tests - All data bits are set to 1 ");
    Serial.println("Use oscilloscope to see that data appears LIKE A BURST PATTERN");
    Serial.println("Data bits for VIC-II are on U19 pins 7,6,5,4,3,2,1,39");
    Serial.println("################################################################");
    
    // Bank Mode 31 -- I/O Range is accessible
    //
    digitalWriteFast(PIN_P2, 0x1);  // CHAREN_n
    digitalWriteFast(PIN_P1, 0x1);  // HIRAM_n
    digitalWriteFast(PIN_P0, 0x1);  // LORAM_n
    delay (50);
    for (addr=0xD000; addr<=0xD00F; addr++)    write_byte(addr , 0xFF);  
    write_byte(0xD000 , 0xFF);   
    
    return;
}


void vic2_test_5() {
    
    uint32_t addr=0;


    Serial.println("");
    Serial.println("###########################################################");
    Serial.println("###########################################################");
    Serial.println("");
    Serial.println("INFINITE LOOP - POWER MUST BE CYCLED TO EXIT THIS TEST");
    Serial.println("------------------------------------------------------");
    Serial.println("");
    Serial.println("These bits should be toggling on the VIC-II - U19: ");
    Serial.println("VIC-II pin-10      Chip Select");
    Serial.println("VIC-II pin-11      Write Enable");
    Serial.println("VIC-II pin-22      DOT Clock - 7-8 Mhz");
    Serial.println("VIC-II pin-21      Color Clock - 14-17 Mhz");
    Serial.println("###########################################################");
    Serial.println("###########################################################");
    

    // Bank Mode 31 -- I/O Range is accessible
    //
    digitalWriteFast(PIN_P2, 0x1);  // CHAREN_n
    digitalWriteFast(PIN_P1, 0x1);  // HIRAM_n
    digitalWriteFast(PIN_P0, 0x1);  // LORAM_n
    delay (50);

    while (1) {
      for (addr=0xD000; addr<=0xD003; addr++)    write_byte(addr , addr);  
    }

    return;
}

void vic2_test_6() {
    
    uint32_t addr=0;


    // Bank Mode 31 -- I/O Range is accessible
    //
    digitalWriteFast(PIN_P2, 0x1);  // CHAREN_n
    digitalWriteFast(PIN_P1, 0x1);  // HIRAM_n
    digitalWriteFast(PIN_P0, 0x1);  // LORAM_n
    delay (50);

    Serial.print("VIC-II Background Color toggle.   *** Last color should be blue ***");
    for (addr=0; addr<= 0x6; addr++)  {
      // Change VIC-II screen background color
      //
      write_byte(0xd020 , addr);
      write_byte(0xd021 , addr);
      delay(500);
    }
  
    return;
}


void test_8() {
    
    while (1) {
        Serial.println("");
        Serial.println("");
        Serial.println("VIC-II Tests");
        Serial.println("Menu");
        Serial.println("----");
        Serial.println("0) Register Test");
        Serial.println("1) DATA: Stability");
        Serial.println("2) DATA: Walking Data bit");
        Serial.println("3) PROBE: All Data Bits Set To 0");
        Serial.println("4) PROBE: All Data Bits Set To 1");
        Serial.println("5) PROBE: VIC-II Control Logic");
        Serial.println("6) Change backgroud screen colors");
        Serial.println("x) Exit to Main Menu ");
        Serial.println("");
        
        while (Serial.available()==0 ) { }
        incomingByte = Serial.read();   
        switch (incomingByte){
          case 48: vic2_test_0();  break;
          case 49: vic2_test_1();  break;
          case 50: vic2_test_2();  break;
          case 51: vic2_test_3();  break;
          case 52: vic2_test_4();  break;
          case 53: vic2_test_5();  break;
          case 54: vic2_test_6();  break;
          case 120: return;  break;
        }
    }
    return;
}


void test_9() {
    
    // Bank Mode 31 -- I/O Range is accessible
    //
    digitalWriteFast(PIN_P2, 0x1);  // CHAREN_n
    digitalWriteFast(PIN_P1, 0x1);  // HIRAM_n
    digitalWriteFast(PIN_P0, 0x1);  // LORAM_n
    delay (50);

    if (sid_sound_on==0) {
      sid_sound_on=1;
      
      Serial.println("########################");
      Serial.println("########################");
      Serial.println("SID now generating sound");
      Serial.println("########################");
      Serial.println("########################");

      write_byte(0xD400+0  , 0x00);  // frequency voice 1 
      write_byte(0xD400+1  , 0x40);  // frequency voice 1 
      
      write_byte(0xD400+2  , 0x55);  // pulse width 1 
      write_byte(0xD400+3  , 0x55);  // pulse width 1 
      
      write_byte(0xD400+4  , 0x45);  // control register voice 1 - Sawtooth
      write_byte(0xD400+5  , 0xCC);  // attack/decay duration voice 1
      write_byte(0xD400+6  , 0xC8);  // sustain level, release duration
      write_byte(0xD400+24 , 0x0F);  // filter mode and main volume control
    }
    else {
      sid_sound_on=0;

      Serial.println("########################");
      Serial.println("########################");
      Serial.println("SID output turned off");
      Serial.println("########################");
      Serial.println("########################");
      
      write_byte(0xD400+0  , 0x00);  // frequency voice 1 
      write_byte(0xD400+4  , 0x00);  // control register voice 1 - Sawtooth
      write_byte(0xD400+5  , 0x00);  // attack/decay duration voice 1
      write_byte(0xD400+6  , 0x00);  // sustain level, release duration
      write_byte(0xD400+24 , 0x00);  // filter mode and main volume control    
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
  delay (2000);
  wait_for_CLK_rising_edge();
  wait_for_CLK_rising_edge();
  wait_for_CLK_rising_edge();
  
  
  while (1) {
      
      Serial.println("");
      Serial.println("");
      Serial.println("MicroCore Labs");
      Serial.println("MCL64  -- Commodore 64 Board Tester");
      Serial.println("-----------------------------------");
      Serial.println("");
      Serial.println("Menu");
      Serial.println("----");
      Serial.println("0) Initial tests user can perform with a voltmeter or oscilloscope");
      Serial.println("1) Run basic test of all chips");
      Serial.println("2) Test PLA");
      Serial.println("3) Test KERNAL ROM ");
      Serial.println("4) Test BASIC ROM ");
      Serial.println("5) Test CHARACTER ROM ");
      Serial.println("6) Test DRAM");
      Serial.println("7) Test Color RAM");
      Serial.println("8) Test VIC-II");
      Serial.println("9) Toggle SIC Sound ON/OFF");
      Serial.println("");
      
      while (Serial.available()==0 ) { }
      incomingByte = Serial.read();   
      switch (incomingByte){
        case 48: test_0();  break;
        case 49: test_1();  break;
        case 50: test_2();  break;
        case 51: test_3();  break;
        case 52: test_4();  break;
        case 53: test_5();  break;
        case 54: test_6();  break;
        case 55: test_7();  break; 
        case 56: test_8();  break; 
        case 57: test_9();  break; 
      }


  delay(100);

  }
 }

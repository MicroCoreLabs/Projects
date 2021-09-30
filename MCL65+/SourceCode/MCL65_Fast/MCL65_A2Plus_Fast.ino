//
//
//  File Name   :  MCL65_A2Plus_Fast.c
//  Used on     :  
//  Author      :  Ted Fried, MicroCore Labs
//  Creation    :  9/26/2021
//
//   Description:
//   ============
//   
//  ML65 Fast drop-in to replace the MOS 6502 in an Apple II Computer
//
//  ** This code does not emulate the 6502 **
//
// This code provides functions to allow the user to run C code compiled
// compiled on the Arduino GUI and run it directly on the Teensy 4.1's 
// 600Mhz processor while using the Apple II's keyboard and display.
//
//
// Functions provided:
//
//  - xputchar - Accepts characters to display to the Apple II's video
//  - xprintf  - Printf modified to display to the Apple II's video
//  - xscanf   - Scanf modified to take input from th Apple II's keyboard
//
//
//------------------------------------------------------------------------
//
// Modification History:
// =====================
//
// Revision 1 9/26/2021
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
#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>

// Teensy 4.1 pin assignments
//
#define PIN_CLK0            24
#define PIN_RESET           40
#define PIN_READY_n         26
#define PIN_IRQ             25
#define PIN_NMI             41
#define PIN_RDWR_n          12
#define PIN_SYNC            39
                    
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


// 6502 Flags
//
#define flag_n    (register_flags & 0x80) >> 7    // register_flags[7]
#define flag_v    (register_flags & 0x40) >> 6    // register_flags[6]
#define flag_b    (register_flags & 0x10) >> 4    // register_flags[4]
#define flag_d    (register_flags & 0x08) >> 3    // register_flags[3]
#define flag_i    (register_flags & 0x04) >> 2    // register_flags[2]
#define flag_z    (register_flags & 0x02) >> 1    // register_flags[1]
#define flag_c    (register_flags & 0x01) >> 0    // register_flags[0]


// 6502 stack always in Page 1
//
#define register_sp_fixed  (0x0100 | register_sp)


// CPU register for direct reads of the GPIOs
//
uint8_t   register_flags=0x34; 
uint8_t   next_instruction;
uint8_t   internal_memory_range=0;
uint8_t   nmi_n_old=1;
uint8_t   register_a=0;
uint8_t   register_x=0;
uint8_t   register_y=0;
uint8_t   register_sp=0xFF;
uint8_t   direct_datain=0;
uint8_t   direct_reset=0;
uint8_t   direct_ready_n=0;
uint8_t   direct_irq=0;
uint8_t   direct_nmi=0;
uint8_t   assert_sync=0;
uint8_t   global_temp=0;
uint8_t   last_access_internal_RAM=0;
uint8_t   rx_byte_state=0;
uint8_t   mode=1;
uint8_t   internal_RAM[65536];
uint8_t   Video_RAM_Miror[0x0800];

uint16_t  register_pc=0;
uint16_t  current_address=0;
uint16_t  effective_address=0;
uint16_t  current_video_character_location = 0x07D0;




    
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
  pinMode(PIN_SYNC,        OUTPUT); 
  
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
  

 // Serial.begin(9600);

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
  register uint32_t GPIO6_data_d1=0;
  uint32_t   d10, d2, d3, d4, d5, d76;

    while (((GPIO6_DR >> 12) & 0x1)!=0) {}            // Teensy 4.1 Pin-24  GPIO6_DR[12]     CLK
    
    //while (((GPIO6_DR >> 12) & 0x1)==0) {GPIO6_data=GPIO6_DR;}                  // This method is ok for VIC-20 and Apple-II+ non-DRAM ranges 
    
    do {  GPIO6_data_d1=GPIO6_DR;   } while (((GPIO6_data_d1 >> 12) & 0x1)==0);   // This method needed to support Apple-II+ DRAM read data setup time
    GPIO6_data=GPIO6_data_d1;
    
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

       return direct_datain;                  
     
} 


// -------------------------------------------------
// Full write cycle with address and data written
// -------------------------------------------------
inline void write_byte(uint16_t local_address , uint8_t local_write_data) {
  
     digitalWriteFast(PIN_RDWR_n,  0x0);
       digitalWriteFast(PIN_SYNC,    0x0); 
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
           
   return;
}

  
// --------------------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------------------
//
// End 6502 Bus Interface Unit
//
// --------------------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------------------


// --------------------------------------------------------------------------------------------------
// Begin xprintf code
// --------------------------------------------------------------------------------------------------

/*-
 * Copyright (c) 1991 The Regents of the University of California.
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 * 3. All advertising materials mentioning features or use of this software
 *    must display the following acknowledgement:
 *  This product includes software developed by the University of
 *  California, Berkeley and its contributors.
 * 4. Neither the name of the University nor the names of its contributors
 *    may be used to endorse or promote products derived from this software
 *    without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE REGENTS AND CONTRIBUTORS ``AS IS'' AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED.  IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 *
 *  @(#)printf.c  5.6 (Berkeley) 5/25/91
 */
#include <sys/cdefs.h>
#include <sys/types.h>

/*
 * Note that stdarg.h and the ANSI style va_start macro is used for both
 * ANSI and traditional C compilers.
 */
#define KERNEL
#include <stdarg.h>
#undef KERNEL

static void kprintn __P((u_long, int));

void

inline xprintf(const char *fmt, ...)

{
  register char *p;
  register int ch, n;
  unsigned long ul;
  int lflag, set;
  va_list ap;

  va_start(ap, fmt);
  for (;;) {
    while ((ch = *fmt++) != '%') {
      if (ch == '\0')
        return;
      xputchar(ch);
    }
    lflag = 0;
reswitch: switch (ch = *fmt++) {
    case 'l':
      lflag = 1;
      goto reswitch;
    case 'b':
      ul = va_arg(ap, int);
      p = va_arg(ap, char *);
      kprintn(ul, *p++);

      if (!ul)
        break;

      for (set = 0; n = *p++;) {
        if (ul & (1 << (n - 1))) {
          xputchar(set ? ',' : '<');
          for (; (n = *p) > ' '; ++p)
            xputchar(n);
          set = 1;
        } else
          for (; *p > ' '; ++p);
      }
      if (set)
        xputchar('>');
      break;
    case 'c':
      ch = va_arg(ap, int);
        xputchar(ch & 0x7f);
      break;
    case 's':
      p = va_arg(ap, char *);
      while (ch = *p++)
        xputchar(ch);
      break;
    case 'd':
      ul = lflag ?
          va_arg(ap, long) : va_arg(ap, int);
      if ((long)ul < 0) {
        xputchar('-');
        ul = -(long)ul;
      }
      kprintn(ul, 10);
      break;
    case 'o':
      ul = lflag ?
          va_arg(ap, u_long) : va_arg(ap, u_int);
      kprintn(ul, 8);
      break;
    case 'u':
      ul = lflag ?
          va_arg(ap, u_long) : va_arg(ap, u_int);
      kprintn(ul, 10);
      break;
    case 'x':
      ul = lflag ?
          va_arg(ap, u_long) : va_arg(ap, u_int);
      kprintn(ul, 16);
      break;
    default:
      xputchar('%');
      if (lflag)
        xputchar('l');
      xputchar(ch);
    }
  }
  va_end(ap);
}

inline static void kprintn (  unsigned long ul ,   int base )
{
          /* hold a long in base 8 */
  char *p, buf[(sizeof(long) * 8 / 3) + 1];

  p = buf;
  do {
    *p++ = "0123456789abcdef"[ul % base];
  } while (ul /= base);
  do {
    xputchar(*--p);
    
  } while (p > buf);
}



inline void xputchar(uint16_t local_char) {

  
    // Force character to Apple II non-inverted and non-blinking
    //
    local_char = local_char & 0x3F;
    local_char = local_char | 0x80;


    // If we have reached the end of the bottom row, scroll all rows upwards and blank the bottom row
    //
    if (current_video_character_location==0x07F8 || local_char==0x8A) {   // 0x0A is the character for \n

      for (uint8_t i=0 ; i<0x28 ; i++)  {
        write_byte( 0x0400+i , Video_RAM_Miror[0x0480+i] );     Video_RAM_Miror[ 0x0400+i] =  Video_RAM_Miror[0x0480+i];     
        write_byte( 0x0480+i , Video_RAM_Miror[0x0500+i] );     Video_RAM_Miror[ 0x0480+i] =  Video_RAM_Miror[0x0500+i];
        write_byte( 0x0500+i , Video_RAM_Miror[0x0580+i] );     Video_RAM_Miror[ 0x0500+i] =  Video_RAM_Miror[0x0580+i];
        write_byte( 0x0580+i , Video_RAM_Miror[0x0600+i] );     Video_RAM_Miror[ 0x0580+i] =  Video_RAM_Miror[0x0600+i];
        write_byte( 0x0600+i , Video_RAM_Miror[0x0680+i] );     Video_RAM_Miror[ 0x0600+i] =  Video_RAM_Miror[0x0680+i];
        write_byte( 0x0680+i , Video_RAM_Miror[0x0700+i] );     Video_RAM_Miror[ 0x0680+i] =  Video_RAM_Miror[0x0700+i];
        write_byte( 0x0700+i , Video_RAM_Miror[0x0780+i] );     Video_RAM_Miror[ 0x0700+i] =  Video_RAM_Miror[0x0780+i];
        write_byte( 0x0780+i , Video_RAM_Miror[0x0428+i] );     Video_RAM_Miror[ 0x0780+i] =  Video_RAM_Miror[0x0428+i];    
                                             
        write_byte( 0x0428+i , Video_RAM_Miror[0x04a8+i] );     Video_RAM_Miror[ 0x0428+i] =  Video_RAM_Miror[0x04a8+i];     
        write_byte( 0x04A8+i , Video_RAM_Miror[0x0528+i] );     Video_RAM_Miror[ 0x04A8+i] =  Video_RAM_Miror[0x0528+i];
        write_byte( 0x0528+i , Video_RAM_Miror[0x05a8+i] );     Video_RAM_Miror[ 0x0528+i] =  Video_RAM_Miror[0x05a8+i];
        write_byte( 0x05a8+i , Video_RAM_Miror[0x0628+i] );     Video_RAM_Miror[ 0x05a8+i] =  Video_RAM_Miror[0x0628+i];
        write_byte( 0x0628+i , Video_RAM_Miror[0x06a8+i] );     Video_RAM_Miror[ 0x0628+i] =  Video_RAM_Miror[0x06a8+i];
        write_byte( 0x06a8+i , Video_RAM_Miror[0x0728+i] );     Video_RAM_Miror[ 0x06a8+i] =  Video_RAM_Miror[0x0728+i];
        write_byte( 0x0728+i , Video_RAM_Miror[0x07a8+i] );     Video_RAM_Miror[ 0x0728+i] =  Video_RAM_Miror[0x07a8+i];
        write_byte( 0x07a8+i , Video_RAM_Miror[0x0450+i] );     Video_RAM_Miror[ 0x07a8+i] =  Video_RAM_Miror[0x0450+i];     
                                             
        write_byte( 0x0450+i , Video_RAM_Miror[0x04d0+i] );     Video_RAM_Miror[ 0x0450+i] =  Video_RAM_Miror[0x04d0+i];     
        write_byte( 0x04d0+i , Video_RAM_Miror[0x0550+i] );     Video_RAM_Miror[ 0x04d0+i] =  Video_RAM_Miror[0x0550+i];
        write_byte( 0x0550+i , Video_RAM_Miror[0x05d0+i] );     Video_RAM_Miror[ 0x0550+i] =  Video_RAM_Miror[0x05d0+i];
        write_byte( 0x05d0+i , Video_RAM_Miror[0x0650+i] );     Video_RAM_Miror[ 0x05d0+i] =  Video_RAM_Miror[0x0650+i];
        write_byte( 0x0650+i , Video_RAM_Miror[0x06d0+i] );     Video_RAM_Miror[ 0x0650+i] =  Video_RAM_Miror[0x06d0+i];
        write_byte( 0x06d0+i , Video_RAM_Miror[0x0750+i] );     Video_RAM_Miror[ 0x06d0+i] =  Video_RAM_Miror[0x0750+i];
        write_byte( 0x0750+i , Video_RAM_Miror[0x07D0+i] );     Video_RAM_Miror[ 0x0750+i] =  Video_RAM_Miror[0x07D0+i];     
        write_byte( 0x07D0+i , 0xA0 );                          Video_RAM_Miror[ 0x07D0+i] =  0xA0;                             
        
      }     
      current_video_character_location = 0x07D0;          // Reset video pointer to the first character on the bottom row
    }


   // Dont print the carriage return/linefeed character
   //
   if (local_char!=0x8A) {  
     write_byte(current_video_character_location , local_char );  
     Video_RAM_Miror[current_video_character_location] = local_char;
     current_video_character_location++;
     }      


}

// --------------------------------------------------------------------------------------------------
// Begin xscanf code
// --------------------------------------------------------------------------------------------------

// Scanf source provided by:  https://iq.opengenus.org/how-printf-and-scanf-function-works-in-c-internally/
// 

int xscanf (char * str, ...)
{
    va_list vl;
    int i = 0, j=0, ret = 0;
    char buff[100] = {0}, tmp[20], c, xx;
    char *out_loc;
    
    // Clear out any existing keystrokes
    //
    xx = read_byte(0xC010);   delay (1);
    xx = read_byte(0xC010);   delay (1);

    while(c != 0x08D) 
    {
      c = read_byte(0xC000); // Read character from keyboard
      
        if (c>=0x80) 
        {
          if (c==0x8D) xprintf ("%c", 0x0A); else  xprintf ("%c", c);  // Echo each typed characteer
          buff[i] = c & 0x7F;
         i++;
      }
      xx=c;
    while(xx >= 0x80) {  xx= read_byte(0xC010);  }
  }
  
  
  va_start( vl, str );
  i = 0;
  while (str && str[i])
  {
      if (str[i] == '%') 
      {
         i++;
         switch (str[i]) 
         {
             case 'c': 
             {
               *(char *)va_arg( vl, char* ) = buff[j];
               j++;
               ret ++;
               break;
             }
             case 'd': 
             {
               *(int *)va_arg( vl, int* ) =strtol(&buff[j], &out_loc, 10);
               j+=out_loc -&buff[j];
               ret++;
               break;
              }
              case 'x': 
              {
               *(int *)va_arg( vl, int* ) =strtol(&buff[j], &out_loc, 16);
               j+=out_loc -&buff[j];
               ret++;
               break;
              }
          }
      } 
      else 
      {
          buff[j] =str[i];
            j++;
        }
        i++;
    }
    va_end(vl);
    return ret;
}


// --------------------------------------------------------------------------------
//
// User code begins here
//
// --------------------------------------------------------------------------------


bool isPrime(uint32_t n)
{
    // Corner case
    if (n <= 1)
        return false;
 
    // Check from 2 to n-1
    for (int i = 2; i < n; i++)
        if (n % i == 0)
            return false;
 
    return true;
}

// Function to print primes
void printPrime(uint32_t n)
{
    for (int i = 2; i <= n; i++) {
        if (isPrime(i))
            xprintf("%d\n",i);
    }
}


void demo_countdown()  {
  uint16_t ret=0;
  uint32_t i=0;
  xprintf ("ENTER NUMBER TO COUNT DOWN FROM: ");
  ret = xscanf("%d", &i);
  while (i>0) { xprintf ("%d\n", i--); }
  return;
}


void demo_prime()  {
  uint16_t ret=0;
  uint32_t n=0;
  //xprintf ("ENTER MAX NUMBER FOR PRIMES: ");
  xprintf ("FIND PRIMES TO WHAT NUMBER: ");
  ret = xscanf("%d", &n);
  printPrime(n);
  return;
}

void demo_fillscreen()  {
  uint16_t x=0;
  uint16_t ret=0;
  while (1) { xprintf ("%d ",x++); }
  return;
}


void demo_testmem() {
  uint16_t i=0;
  uint16_t x=0;

  for (i=0 ; i<0xC000 ; i++) {
    write_byte (i , i);
    x=read_byte(i);

    if ((0xFF&x) != (0xFF&i) ) xprintf ("FAIL WROTE %x READ %x\n",i,x);

    xprintf ("\n\n*** TEST PASSED ***\n");
    return;
    
  }
 }


// -------------------------------------------------
//
// Main loop 
//
// -------------------------------------------------
 void loop() {
  
  int choice=0;
  int ret=0;

    
  // Give Teensy 4.1 a moment
  //
  delay (50);
  wait_for_CLK_rising_edge();
  wait_for_CLK_rising_edge();
  wait_for_CLK_rising_edge();

  
  // Set Apple II Soft-Switches to the correct video mode and page
  //
  write_byte(0xC051 , 0x0 ); // Set Apple II Text Mode
  write_byte(0xC054 , 0x0 ); // Set Apple II Text Page 1

  
  // Clear video memory by scrolliing text off the screen with printf's
  //
  for (uint16_t i=0 ; i<2000; i++) { xprintf (" "); }

  // Menu
  //
  while (1) {
    
    xprintf ("\n");
    xprintf ("MICROCORE LABS\n");
    xprintf ("MCL65-FAST DEMO\n");
    xprintf ("---------------\n\n");
    xprintf ("1) COUNTDOWN \n");
    xprintf ("2) PRIME NUMBERS \n");
    xprintf ("3) TEST APPLE II+ 48K MEMORY \n");
    xprintf ("4) FILL SCREEN \n\n");
    xprintf ("ENTER CHOICE: ");
    ret = xscanf("%d", &choice);

    switch (choice)  {
      case 1: demo_countdown();   break;
      case 2: demo_prime();       break;
      case 3: demo_testmem();  break;
      case 4: demo_fillscreen();  break;
    }
  }
   
}

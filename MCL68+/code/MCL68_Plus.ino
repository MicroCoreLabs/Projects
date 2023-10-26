//
//
//  File Name   :  MCL68_Plus.ino
//  Used on     : 
//  Author      :  Ted Fried, MicroCore Labs
//  Creation    :  10/25/2023
//
//   Description:
//   ============
//   
//  Drop-in replacement for the Motorola 68000
//
//------------------------------------------------------------------------
//
// Modification History:
// =====================
//
// Revision 1 10/25/2023
// Initial revision
//
//
//------------------------------------------------------------------------
//
// Copyright (c) 2023 Ted Fried
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

#include <stdio.h>



// Defines
// ----------------------------------------------------------------------

 
// Teensy 4.1 pin assignments
//
#define PIN_CLK              0        
#define PIN_DTACK_n          1 
#define PIN_VPA_n            24 
#define PIN_BR_n             25 
#define PIN_BGACK_n          30 
               
#define PIN_INPUT_MUX        28  // Muxes between Data_in[15:0] and Halt/Reset/IPL[2:0]
#define PIN_DATA15_IN        27  
#define PIN_DATA14_IN        26   
#define PIN_DATA13_IN        39  
#define PIN_DATA12_IN        38  
#define PIN_DATA11_IN        21  
#define PIN_DATA10_IN        20 
#define PIN_DATA9_IN         23 
#define PIN_DATA8_IN         22 
#define PIN_DATA7_IN         16 
#define PIN_DATA6_IN         17 
#define PIN_DATA5_IN         41 
#define PIN_DATA4_IN         40 // muxed with HALT_n
#define PIN_DATA3_IN         15 // muxed with RESET_n
#define PIN_DATA2_IN         14 // muxed with IPL[2]
#define PIN_DATA1_IN         18 // muxed with IPL[1]
#define PIN_DATA0_IN         19 // muxed with IPL[0]

#define PIN_ADDR_574_CLK     32 // CK for the 574's
#define PIN_AD_SHIFTOUT_7    13 // Shifts out Addr[23:1] and Data_out[15:0]
#define PIN_AD_SHIFTOUT_6    12 
#define PIN_AD_SHIFTOUT_5    11 
#define PIN_AD_SHIFTOUT_4    10 
#define PIN_AD_SHIFTOUT_3    9 
#define PIN_AD_SHIFTOUT_2    8 
#define PIN_AD_SHIFTOUT_1    7 
#define PIN_AD_SHIFTOUT_0    6 

#define PIN_DATAOUT_OE_n     34 // OE for the Data_out 574's used for write cycles
#define PIN_ARB_OE_n         31 // OE for buffers when arbitration hands bus to another master

#define PIN_FC_1             35 
#define PIN_FC_0             36 
#define PIN_AS_n             37 
#define PIN_UDS_n            5 
#define PIN_LDS_n            4 
#define PIN_WR_n             3 
#define PIN_E                2 
#define PIN_VMA_n            33 
#define PIN_BG_n             29 



// --------------------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------------------

#define TRUE                    1
#define FALSE                   0
#define SIZE_BYTE               8
#define SIZE_WORD               16

#define ADDRESS_REG             1
#define DATA_REG                2
#define IMMEDIATE               3
#define MEMORY                  4


// Calculate data sizes for different opcode encoding types
#define DATA_SIZE_TYPE_A        (((0x00C0&first_opcode)>>6)==0)  ? 8  : (((0x00C0&first_opcode)>>6)==1)  ? 16 : 32
#define DATA_SIZE_TYPE_B        (((0x3000&first_opcode)>>12)==1) ? 8  : (((0x3000&first_opcode)>>12)==3) ? 16 : 32
#define DATA_SIZE_TYPE_C        (((0x0040&first_opcode)>>6)==0)  ? 16 : 32
#define DATA_SIZE_TYPE_D        (((0x0100&first_opcode)>>8)==0)  ? 16 : 32


// Flag bits
#define mc68k_flag_T            ((mc68k_flags & 0x8000) >> 15)  // 15
#define mc68k_flag_S            ((mc68k_flags & 0x2000) >> 13)  // 13
#define mc68k_flag_INTR_Mask    ((mc68k_flags & 0x0700) >> 8)   // [10:8]
#define mc68k_flag_X            ((mc68k_flags & 0x0010) >> 4)   // 4
#define mc68k_flag_N            ((mc68k_flags & 0x0008) >> 3)   // 3
#define mc68k_flag_Z            ((mc68k_flags & 0x0004) >> 2)   // 2
#define mc68k_flag_V            ((mc68k_flags & 0x0002) >> 1)   // 1
#define mc68k_flag_C            ( mc68k_flags & 0x0001)         // 0
  

#define direct_intr_raw   (GPIO6_raw_data&0x04000000)
#define direct_reset_raw  (GPIO6_raw_data&0x02000000)


#define GPIO6_BIT_M68K_CLK 0x00000008

#define LS574_CLK_HIGH      0x00001000   // GPIO7 bit 12
#define AS_n_HIGH           0x00080000   // GPIO7 bit 19
#define AS_n_LOW            0xFFF7FFFF   // GPIO7 bit 19
#define DATA_OE_n_HIGH      0x20000000   // GPIO7 bit 29
#define DATA_OE_n_LOW       0xDFFFFFFF   // GPIO7 bit 29

#define WR_n_HIGH           0x00000020   // GPIO9 bit 5 
#define WR_n_LOW            0xFFFFFFDF   // GPIO9 bit 5 
#define VMA_n_HIGH          0x00000080   // GPIO9 bit 7 
#define VMA_n_LOW           0xFFFFFF7F   // GPIO9 bit 7 
#define BG_n_HIGH           0x80000000   // GPIO9 bit 31 
#define BG_n_LOW            0x7FFFFFFF   // GPIO9 bit 31

#define E_HIGH              0x00000010   // GPIO9 bit 4 
#define E_LOW               0xFFFFFFEF   // GPIO9 bit 4 
#define UDS_n_LOW           0xFFFFFEFF   // GPIO9 bit 8 
#define UDS_n_HIGH          0x00000100   // GPIO9 bit 8 
#define LDS_n_LOW           0xFFFFFFBF   // GPIO9 bit 6 
#define LDS_n_HIGH          0x00000040   // GPIO9 bit 6 
#define UDS_LDS_n_HIGH      0x00000140   // GPIO9 bit 8&6 

#define DTACK_n_BIT         0x00000004   // GPIO6 bit 2
#define VPA_n_BIT           0x00001000   // GPIO6 bit 12
#define BR_n_BIT            0x00002000   // GPIO6 bit 13
#define RESET_n_BIT         0x00100000   // GPIO6 bit 20
#define HALT_n_BIT          0x00080000   // GPIO6 bit 19

#define IPL2_0_BITs         0x00070000   // GPIO6 bit 18,17,16

#define ARBOE_n_HIGH        0x00400000   // GPIO8 bit 22 
#define ARBOE_n_LOW         0xFFBFFFFF   // GPIO8 bit 22
#define BGACK_n_BIT         0xFF7FFFFF   // GPIO8 bit 23
#define INPUTMUX_n_HIGH     0x00040000   // GPIO8 bit 18 
#define INPUTMUX_n_LOW      0xFFFBFFFF   // GPIO8 bit 18


// Variables
// ----------------------------------------------------------------------
unsigned char  biu_size;
unsigned char  reg_num;
unsigned char  data_size;
unsigned char  EA_register;
unsigned char  ea_type;
unsigned char  reset_status_d;
unsigned char  source_ea_type;
unsigned char  destination_ea_type;
unsigned char  last_mc68k_flag_T;

unsigned int  last_exception=0;
unsigned int  mc68k_flags=0x2700;
unsigned int  biu_read_data;
unsigned int  biu_dataout;
unsigned int  first_opcode;

unsigned long  immediate;
unsigned long  m68k_data_reg[8];
unsigned long  m68k_address_reg[8];
uint32_t       m68k_a7_S=0x4000;
unsigned long  mc68k_pc=0;
unsigned long  biu_address;
unsigned long  calculated_EA;
unsigned long  EA_Data;
unsigned long  result;
unsigned long  access_address;
unsigned long  source_ea;
unsigned long  destination_ea;
unsigned long  num=0;
unsigned long  original_mc68k_pc;


int16_t  clock_counter=0;


uint32_t GPIO6_raw_data=0;
uint32_t gpio6_dtack_n=0;
uint8_t   mode=0;


uint8_t mc68k_fc=0x1; // Normally set to Address Space Type = User Data
 
uint32_t  GPIO7_array[256] = {0x0,0x400,0x20000,0x20400,0x10000,0x10400,0x30000,0x30400,0x800,0xc00,0x20800,0x20c00,0x10800,0x10c00,0x30800,0x30c00,0x1,0x401,0x20001,0x20401,0x10001,0x10401,0x30001,0x30401,0x801,0xc01,0x20801,0x20c01,0x10801,0x10c01,0x30801,0x30c01,0x4,0x404,0x20004,0x20404,0x10004,0x10404,0x30004,0x30404,0x804,0xc04,0x20804,0x20c04,0x10804,0x10c04,0x30804,0x30c04,0x5,0x405,0x20005,0x20405,0x10005,0x10405,0x30005,0x30405,0x805,0xc05,0x20805,0x20c05,0x10805,0x10c05,0x30805,0x30c05,0x2,0x402,0x20002,0x20402,0x10002,0x10402,0x30002,0x30402,0x802,0xc02,0x20802,0x20c02,0x10802,0x10c02,0x30802,0x30c02,0x3,0x403,0x20003,0x20403,0x10003,0x10403,0x30003,0x30403,0x803,0xc03,0x20803,0x20c03,0x10803,0x10c03,0x30803,0x30c03,0x6,0x406,0x20006,0x20406,0x10006,0x10406,0x30006,0x30406,0x806,0xc06,0x20806,0x20c06,0x10806,0x10c06,0x30806,0x30c06,0x7,0x407,0x20007,0x20407,0x10007,0x10407,0x30007,0x30407,0x807,0xc07,0x20807,0x20c07,0x10807,0x10c07,0x30807,0x30c07,0x8,0x408,0x20008,0x20408,0x10008,0x10408,0x30008,0x30408,0x808,0xc08,0x20808,0x20c08,0x10808,0x10c08,0x30808,0x30c08,0x9,0x409,0x20009,0x20409,0x10009,0x10409,0x30009,0x30409,0x809,0xc09,0x20809,0x20c09,0x10809,0x10c09,0x30809,0x30c09,0xc,0x40c,0x2000c,0x2040c,0x1000c,0x1040c,0x3000c,0x3040c,0x80c,0xc0c,0x2080c,0x20c0c,0x1080c,0x10c0c,0x3080c,0x30c0c,0xd,0x40d,0x2000d,0x2040d,0x1000d,0x1040d,0x3000d,0x3040d,0x80d,0xc0d,0x2080d,0x20c0d,0x1080d,0x10c0d,0x3080d,0x30c0d,0xa,0x40a,0x2000a,0x2040a,0x1000a,0x1040a,0x3000a,0x3040a,0x80a,0xc0a,0x2080a,0x20c0a,0x1080a,0x10c0a,0x3080a,0x30c0a,0xb,0x40b,0x2000b,0x2040b,0x1000b,0x1040b,0x3000b,0x3040b,0x80b,0xc0b,0x2080b,0x20c0b,0x1080b,0x10c0b,0x3080b,0x30c0b,0xe,0x40e,0x2000e,0x2040e,0x1000e,0x1040e,0x3000e,0x3040e,0x80e,0xc0e,0x2080e,0x20c0e,0x1080e,0x10c0e,0x3080e,0x30c0e,0xf,0x40f,0x2000f,0x2040f,0x1000f,0x1040f,0x3000f,0x3040f,0x80f,0xc0f,0x2080f,0x20c0f,0x1080f,0x10c0f,0x3080f,0x30c0f };

uint32_t  GPIO7_fcmode_array[8] = { 0x00080000, 0x000C0000, 0x20080000, 0x200C0000 , 0x00080000, 0x000C0000, 0x10080000, 0x100C0000 };

uint32_t gpio6_reset_n;
uint32_t gpio6_halt_n;
uint32_t gpio6_vpa_n;
uint32_t gpio6_ipl;
uint32_t  gpio6_data=0;

uint8_t nmi_gate=0;

uint8_t sync_cycle=0;
uint16_t pfq_word_A;
uint16_t pfq_word_B;
uint8_t  prefetch_queue_count=0;
uint32_t pfq_in_address;

uint32_t gpio6_br_n;
uint32_t E_input;
uint32_t E_input_d;


FASTRUN uint8_t INTERNAL_ROM[0x10000];


DMAMEM  uint8_t INTERNAL_RAM1[0x40000];  // 256KB    - Cant fit all 512KB in Teensy 4.1 RAM2, so splitting up 
FASTRUN uint8_t INTERNAL_RAM2[0x40000];  // 256KB    -

uint8_t OVERLAY = 0x1;
uint8_t write_through = 0x1;
uint8_t temp16;
uint8_t rom_readthrough=0;





// --------------------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------------------

void setup() {
    
  pinMode(PIN_CLK,             INPUT);    // GPIO6_20       
  pinMode(PIN_DTACK_n,         INPUT);    // GPIO6_20 
  pinMode(PIN_VPA_n,           INPUT);    // GPIO6_20 
  pinMode(PIN_BR_n,            INPUT);    // GPIO6_20 
  pinMode(PIN_BGACK_n,         INPUT);    // GPIO8_3 

  pinMode(PIN_INPUT_MUX,       OUTPUT);   // GPIO8_3
  pinMode(PIN_DATA15_IN,       INPUT);    // GPIO6_20
  pinMode(PIN_DATA14_IN,       INPUT);    // GPIO6_20
  pinMode(PIN_DATA13_IN,       INPUT);    // GPIO6_20
  pinMode(PIN_DATA12_IN,       INPUT);    // GPIO6_20
  pinMode(PIN_DATA11_IN,       INPUT);    // GPIO6_20
  pinMode(PIN_DATA10_IN,       INPUT);    // GPIO6_20
  pinMode(PIN_DATA9_IN,        INPUT);    // GPIO6_20
  pinMode(PIN_DATA8_IN,        INPUT);    // GPIO6_20
  pinMode(PIN_DATA7_IN,        INPUT);    // GPIO6_20
  pinMode(PIN_DATA6_IN,        INPUT);    // GPIO6_20
  pinMode(PIN_DATA5_IN,        INPUT);    // GPIO6_20
  pinMode(PIN_DATA4_IN,        INPUT);    // GPIO6_20
  pinMode(PIN_DATA3_IN,        INPUT);    // GPIO6_20
  pinMode(PIN_DATA2_IN,        INPUT);    // GPIO6_20
  pinMode(PIN_DATA1_IN,        INPUT);    // GPIO6_20
  pinMode(PIN_DATA0_IN,        INPUT);    // GPIO6_20

  pinMode(PIN_ADDR_574_CLK,    OUTPUT);   // GPIO7_13
  pinMode(PIN_AD_SHIFTOUT_7,   OUTPUT);   // GPIO7_13
  pinMode(PIN_AD_SHIFTOUT_6,   OUTPUT);   // GPIO7_13
  pinMode(PIN_AD_SHIFTOUT_5,   OUTPUT);   // GPIO7_13
  pinMode(PIN_AD_SHIFTOUT_4,   OUTPUT);   // GPIO7_13
  pinMode(PIN_AD_SHIFTOUT_3,   OUTPUT);   // GPIO7_13
  pinMode(PIN_AD_SHIFTOUT_2,   OUTPUT);   // GPIO7_13
  pinMode(PIN_AD_SHIFTOUT_1,   OUTPUT);   // GPIO7_13
  pinMode(PIN_AD_SHIFTOUT_0,   OUTPUT);   // GPIO7_13

  pinMode(PIN_DATAOUT_OE_n,    OUTPUT);   // GPIO7_13
  pinMode(PIN_ARB_OE_n,        OUTPUT);   // GPIO8_3

  pinMode(PIN_FC_1,            OUTPUT);   // GPIO7_13
  pinMode(PIN_FC_0,            OUTPUT);   // GPIO7_13
  pinMode(PIN_AS_n,            OUTPUT);   // GPIO7_13
  pinMode(PIN_UDS_n,           OUTPUT);   // GPIO9_6
  pinMode(PIN_LDS_n,           OUTPUT);   // GPIO9_6
  pinMode(PIN_WR_n,            OUTPUT);   // GPIO9_6
  pinMode(PIN_E,               OUTPUT);   // GPIO9_6
  pinMode(PIN_VMA_n,           OUTPUT);   // GPIO9_6
  pinMode(PIN_BG_n,            OUTPUT);   // GPIO9_6


  // Set initial values for outputs
  //
  digitalWriteFast(PIN_INPUT_MUX,1);
  digitalWriteFast(PIN_DATAOUT_OE_n,1);
  digitalWriteFast(PIN_ARB_OE_n,0);
  digitalWriteFast(PIN_FC_1,1);
  digitalWriteFast(PIN_FC_0,1);
  digitalWriteFast(PIN_AS_n,1);
  digitalWriteFast(PIN_UDS_n,1);
  digitalWriteFast(PIN_LDS_n,1);
  digitalWriteFast(PIN_WR_n,1);
  digitalWriteFast(PIN_VMA_n,1);
  digitalWriteFast(PIN_BG_n,1);

  Serial.begin(9600);
  
  // Generate E clock output which is 1/10 the CPU clock
  analogWriteFrequency(PIN_E, 780000); 
  analogWrite(PIN_E, 128);

}

// --------------------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------------------




// --------------------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------------------
//
// Begin 68000 Bus Interface Unit - BIU
//
// --------------------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------------------

void Exception_Handler(unsigned int exception_type); // Prototype 


// -------------------------------------------------
// Wait for the 68000 CLK rising edge  
// -------------------------------------------------         
inline void wait_for_CLK_rising_edge() {
    register uint32_t  gpio6_data=0;
  
    while ( (GPIO6_DR & GPIO6_BIT_M68K_CLK) != 0) {}                                      // First ensure clock is at a low level
    do { gpio6_data = GPIO6_DR;   } while ( (gpio6_data & GPIO6_BIT_M68K_CLK) == 0);      // Then poll for the first instance where clock is not low

    return;
}
    

// -------------------------------------------------
// Wait for the 68000 CLK falling edge      
// -------------------------------------------------
inline void wait_for_CLK_falling_edge() { 
  
    while ( (GPIO6_DR & GPIO6_BIT_M68K_CLK) == 0) {}                                      // First ensure clock is at a low level
    do { gpio6_data = GPIO6_DR;   } while ( (gpio6_data & GPIO6_BIT_M68K_CLK) != 0);      // Then poll for the first instance where clock is not low
  
    return;
}
    

// -------------------------------------------------
// Wait for the E CLK rising edge  
// -------------------------------------------------         
inline void wait_for_E_rising_edge() {
    register uint32_t  gpio6_data=0;
  
    while ( (GPIO6_DR & BR_n_BIT) != 0) {}                                      // First ensure clock is at a low level
    do { gpio6_data = GPIO6_DR;   } while ( (gpio6_data & BR_n_BIT) == 0);      // Then poll for the first instance where clock is not low

    return;
}
    

// -------------------------------------------------
// Wait for the E CLK falling edge      
// -------------------------------------------------
inline void wait_for_E_falling_edge() { 
  
    while ( (GPIO6_DR & BR_n_BIT) == 0) {}                                      // First ensure clock is at a low level
    do { gpio6_data = GPIO6_DR;   } while ( (gpio6_data & BR_n_BIT) != 0);      // Then poll for the first instance where clock is not low
  
    return;
}
    

 

// Requests BIU to perform a Data Write cycle 
// ----------------------------------------------------------------------
void BIU_Write(uint32_t local_address , uint16_t local_write_data , uint8_t local_size) 
{
    register uint32_t muxout_clock0, muxout_clock1, muxout_clock2, muxout_clock3, muxout_clock4;
    register uint32_t muxout_clock5, muxout_clock6, muxout_clock7, muxout_clock8, muxout_clock9;
    register uint32_t precalculate_uls_lds;
    register uint32_t address_512K;
    register uint32_t address_256K;

    local_address = local_address & 0xFFFFFF;

    
    if ( (local_address==0xEFFFFE) && (local_size==8)  && ((local_write_data&0x10)==0x00) )         OVERLAY=0;  
    if ( (local_address==0xEFFFFE) && (local_size==16) && ((local_write_data&0x1000)==0x0000) )     OVERLAY=0;  
    
    if ( (local_address==0xEFFFFE) && (local_size==8)  && ((local_write_data&0x10)==0x10) )         OVERLAY=1;  
    if ( (local_address==v) && (local_size==16) && ((local_write_data&0x1000)==0x1000) )            OVERLAY=1;  

    local_size = local_size | (0x1 & local_address);
    write_through=1;


    // Check Alignment for Words
    if     ( (0x1&local_address)==1 && local_size==SIZE_WORD) { access_address=local_address; Exception_Handler(3); }


    // Macintosh 512KB DRAM
    //
    else if (  ((OVERLAY==1) && (local_address>=0x600000) && (local_address<0x800000)  ) || ( (OVERLAY==0) && (local_address<0x400000))  )   {   

      address_512K = local_address & 0x07FFFF;  // Limit to 512K
      address_256K = local_address & 0x03FFFF;  // Limit to 256K
           if ( (address_512K>=0x07A700) && (address_512K<0x07FC80) )   { write_through=1;  }    // Video Page 1  0x5580 bytes
      else if ( (address_512K>=0x072700) && (address_512K<0x077C80) )   { write_through=1;  }    // Video Page 2      
      else if ( (address_512K>=0x07FD00) && (address_512K<0x07FFE4) )   { write_through=1;  }    // Audio Page 1  0x02E4 bytes
      else if ( (address_512K>=0x07A100) && (address_512K<0x07A3E4) )   { write_through=1;  }    // Audio Page 2
      else                                                              { write_through=0;  }
      
      if (address_512K < 0x040000)  {  // 0x000000 - 0x03FFFF   = 256KB
        if (local_size>9)     { INTERNAL_RAM1[address_256K] = (local_write_data>>8);   INTERNAL_RAM1[address_256K+1] = (0xFF&local_write_data);  }
        else                  { INTERNAL_RAM1[address_256K] = local_write_data; }
      }
      else  {                           // 0x040000 - 0x07FFFF   = 256KB
        if (local_size>9)     { INTERNAL_RAM2[address_256K] = (local_write_data>>8);   INTERNAL_RAM2[address_256K+1] = (0xFF&local_write_data);  }
        else                  { INTERNAL_RAM2[address_256K] = local_write_data; }
      }
      //write_through=0;
     }
     


    if (write_through==0) { 
      wait_for_CLK_falling_edge();
      wait_for_CLK_falling_edge();
      wait_for_CLK_falling_edge();
      wait_for_CLK_falling_edge();
      return; }
    else {
        //if (OVERLAY==0)  Serial.printf("local_address:%x\n\r",local_address);

      if (local_size<10)  { local_write_data = ( (local_write_data&0x00FF) | (local_write_data<<8)); }
          
    // Pre-calculate GPIO7 values
    //
    muxout_clock0 = GPIO7_array[ (0x000000FE&local_address)>>0 | (mc68k_flag_S) ]  |  GPIO7_fcmode_array[mc68k_fc]; // Also asserts AS_n and DATABUS_OE_n high
    muxout_clock2 = GPIO7_array[ (0x0000FF00&local_address)>>8                  ]  |  GPIO7_fcmode_array[mc68k_fc];     
    muxout_clock4 = GPIO7_array[ (0x00FF0000&local_address)>>16                 ]  |  GPIO7_fcmode_array[mc68k_fc];     
    muxout_clock6 = GPIO7_array[ (0x0000FF00&local_write_data)>>8               ]  |  GPIO7_fcmode_array[mc68k_fc];     
    muxout_clock8 = GPIO7_array[ (0x000000FF&local_write_data)                  ]  |  GPIO7_fcmode_array[mc68k_fc];
  
    muxout_clock1 = muxout_clock0 | LS574_CLK_HIGH;   // These are the odd words that assert the 574 clock bit high
    muxout_clock3 = muxout_clock2 | LS574_CLK_HIGH;   // Even bits set this bit low
    muxout_clock5 = muxout_clock4 | LS574_CLK_HIGH;
    muxout_clock7 = muxout_clock6 | LS574_CLK_HIGH;
    muxout_clock9 = muxout_clock8 | LS574_CLK_HIGH;



    noInterrupts();     // Disable Teensy interupts so the 68000 bus cycle can complete without interruption


  // S0 Rising edge of CLK
  // Shift out FC[2:0], Addr[23:1] and Data[15:0]
  // -----------------------------------------------------------------------------
  GPIO7_DR = muxout_clock0;  delayNanoseconds(1);
  GPIO7_DR = muxout_clock1;  delayNanoseconds(1);
  GPIO7_DR = muxout_clock2;  delayNanoseconds(1);
  GPIO7_DR = muxout_clock3;  delayNanoseconds(1);
  GPIO7_DR = muxout_clock4;  delayNanoseconds(1);
  GPIO7_DR = muxout_clock5;  delayNanoseconds(1);
  GPIO7_DR = muxout_clock6;  delayNanoseconds(1);
  GPIO7_DR = muxout_clock7;  delayNanoseconds(1);
  GPIO7_DR = muxout_clock8;  delayNanoseconds(1);
  GPIO7_DR = muxout_clock9;  delayNanoseconds(1);  
  //GPIO8_DR = GPIO8_DR & ARBOE_n_LOW;  // FIX!!!!!!


   / S2 Rising edge of CLK
  // - Assert AS_n, WR_n, Databus_OE_n
  // -----------------------------------------------------------------------------
  wait_for_CLK_rising_edge();  
  GPIO7_DR = muxout_clock9 & AS_n_LOW & DATA_OE_n_LOW;   
  GPIO9_DR = GPIO9_DR & WR_n_LOW ;
  precalculate_uls_lds = ( (GPIO9_DR | UDS_n_HIGH) | LDS_n_HIGH) ;

  

  // S3 Falling edge of CLK
  // - Do nothing
  // -----------------------------------------------------------------------------
  wait_for_CLK_falling_edge();
  switch(local_size)  {
    case (8):   { precalculate_uls_lds = ( (GPIO9_DR & UDS_n_LOW ) | LDS_n_HIGH) ;    break;  }
    case (9):   { precalculate_uls_lds = ( (GPIO9_DR | UDS_n_HIGH) & LDS_n_LOW ) ;    break;  }
    case (16):   { precalculate_uls_lds = ( (GPIO9_DR & UDS_n_LOW ) & LDS_n_LOW ) ;    break;  }
    case (17):   { precalculate_uls_lds = ( (GPIO9_DR | UDS_n_HIGH) | LDS_n_HIGH) ;    break;  }
  }

  // S4 Rising edge of CLK
  // - Assert UDS_n, LDS_n
  // -----------------------------------------------------------------------------
  wait_for_CLK_rising_edge(); 
  GPIO9_DR = precalculate_uls_lds;



  // S5 Falling edge of CLK
  // - Poll for DTACK_n
  // - Handle 6800 Bus Timing (VPA/VMA Cycles)
  // - Poll for BERR_n   ** Future
  // -----------------------------------------------------------------------------
   wait_for_CLK_falling_edge();  
   do { wait_for_CLK_falling_edge();  
   gpio6_dtack_n  = GPIO6_DR & DTACK_n_BIT; 
   gpio6_vpa_n    = GPIO6_DR & VPA_n_BIT;   
   } while ( (gpio6_dtack_n != 0) && ( gpio6_vpa_n != 0) );  

   

   if ( gpio6_vpa_n == 0) {    
     
     wait_for_E_falling_edge();

     wait_for_CLK_falling_edge();
     wait_for_CLK_falling_edge();
     GPIO9_DR = GPIO9_DR & VMA_n_LOW;     // Assert VMA_n
     
      wait_for_E_rising_edge();
      wait_for_E_falling_edge();

      GPIO7_DR = (muxout_clock9 | AS_n_HIGH | DATA_OE_n_HIGH);
      GPIO9_DR = GPIO9_DR | UDS_LDS_n_HIGH | VMA_n_HIGH | WR_n_HIGH; 

      interrupts();                       // Re-enable Teensy's interrupts so the UART and downloading works
  return;
   }


  // S6 Rising edge of CLK
  // - Do nothing
  // -----------------------------------------------------------------------------
  wait_for_CLK_rising_edge(); 
  
  
  // S7 Falling edge of CLK
  // - Deassert AS_n, UDS_n, LDS_n
  // -----------------------------------------------------------------------------
  wait_for_CLK_falling_edge();  
  GPIO7_DR = muxout_clock9 | AS_n_HIGH | DATA_OE_n_HIGH;
  GPIO9_DR = GPIO9_DR | UDS_LDS_n_HIGH | WR_n_HIGH; 


  interrupts();                       // Re-enable Teensy's interrupts so the UART and downloading works
    return;
}
}
  


// Requests BIU to perform a Read cycle 
// ----------------------------------------------------------------------
uint16_t BIU_Read(uint32_t local_address , uint8_t local_size) 
{
    register uint32_t muxout_clock0, muxout_clock1, muxout_clock2, muxout_clock3, muxout_clock4;
    register uint32_t muxout_clock5, muxout_clock6, muxout_clock7, muxout_clock8, muxout_clock9;
    register uint32_t precalculate_uls_lds;
  uint16_t read_data;

      local_address = local_address & 0xFFFFFF;

    local_size = local_size | (0x1 & local_address);

    
    // Check Alignment for Words
    if     ( (0x1&local_address)==1 && local_size==SIZE_WORD) { access_address=local_address; Exception_Handler(3);  return 0xEEEE;}

   
    // ROM 64KB
      if ( (rom_readthrough==0) &&  ((OVERLAY==1) && (local_address<0x600000)) || ((OVERLAY==0) && (rom_readthrough==0) && (local_address>=0x400000) &&(local_address<0x800000))  )   {   
      local_address = local_address & 0x00FFFF;  // Limit to 64K
      if (local_size>9)     { read_data = (INTERNAL_ROM[local_address]<<8) | INTERNAL_ROM[local_address+1]; }
      else                  { read_data =  INTERNAL_ROM[local_address];}
      wait_for_CLK_falling_edge();
      wait_for_CLK_falling_edge();
      wait_for_CLK_falling_edge();
      wait_for_CLK_falling_edge();
      return read_data;
      }

    // RAM 512KB
    else if (  ((OVERLAY==1) && (local_address>=0x600000) && (local_address<0x800000)  ) || ( (OVERLAY==0) && (local_address<0x400000))  )   {   
      local_address = local_address & 0x07FFFF;  // Limit to 512K
      if (local_address < 0x040000)  {  // 0x000000 - 0x03FFFF   = 256KB
        if (local_size>9)     { read_data = (INTERNAL_RAM1[local_address]<<8) | INTERNAL_RAM1[local_address+1]; }
        else                  { read_data =  INTERNAL_RAM1[local_address];}
      }    
      else  {                           // 0x040000 - 0x07FFFF   = 256KB
        local_address = local_address - 0x040000;
        if (local_size>9)     { read_data = (INTERNAL_RAM2[local_address]<<8) | INTERNAL_RAM2[local_address+1]; }
        else                  { read_data =  INTERNAL_RAM2[local_address];}
      }
      wait_for_CLK_falling_edge();
      wait_for_CLK_falling_edge();
      wait_for_CLK_falling_edge();
      wait_for_CLK_falling_edge();
      return read_data;
      }


    else  {
    
    // Pre-calculate GPIO7 values
    //
    muxout_clock0 = GPIO7_array[ (0x000000FE&local_address)>>0 | (mc68k_flag_S) ]  |  GPIO7_fcmode_array[mc68k_fc]; // Also asserts AS_n and DATABUS_OE_n high
    muxout_clock2 = GPIO7_array[ (0x0000FF00&local_address)>>8                  ]  |  GPIO7_fcmode_array[mc68k_fc];     
    muxout_clock4 = GPIO7_array[ (0x00FF0000&local_address)>>16                 ]  |  GPIO7_fcmode_array[mc68k_fc];     
    muxout_clock6 = GPIO7_array[  0x0                             ]  |  GPIO7_fcmode_array[mc68k_fc];     
    muxout_clock8 = GPIO7_array[  0x0                               ]  |  GPIO7_fcmode_array[mc68k_fc];
  
    muxout_clock1 = muxout_clock0 | LS574_CLK_HIGH;   // These are the odd words that assert the 574 clock bit high
    muxout_clock3 = muxout_clock2 | LS574_CLK_HIGH;   // Even bits set this bit low
    muxout_clock5 = muxout_clock4 | LS574_CLK_HIGH;
    muxout_clock7 = muxout_clock6 | LS574_CLK_HIGH;
    muxout_clock9 = muxout_clock8 | LS574_CLK_HIGH | DATA_OE_n_HIGH;



    noInterrupts();     // Disable Teensy interupts so the 68000 bus cycle can complete without interruption


    // S0 Rising edge of CLK
  // Shift out FC[2:0], Addr[23:1] and Data[15:0]
    // -----------------------------------------------------------------------------
  GPIO7_DR = muxout_clock0;  delayNanoseconds(1);
  GPIO7_DR = muxout_clock1;  delayNanoseconds(1);
  GPIO7_DR = muxout_clock2;  delayNanoseconds(1);
  GPIO7_DR = muxout_clock3;  delayNanoseconds(1);
  GPIO7_DR = muxout_clock4;  delayNanoseconds(1);
  GPIO7_DR = muxout_clock5;  delayNanoseconds(1);
  GPIO7_DR = muxout_clock6;  delayNanoseconds(1);
  GPIO7_DR = muxout_clock7;  delayNanoseconds(1);
  GPIO7_DR = muxout_clock8;  delayNanoseconds(1);
  GPIO7_DR = muxout_clock9;  
  //GPIO8_DR = GPIO8_DR & ARBOE_n_LOW;  // FIX!!!!!!
  precalculate_uls_lds = ( (GPIO9_DR | UDS_n_HIGH) | LDS_n_HIGH) ;


  switch(local_size)  {
    case (8):   { precalculate_uls_lds = ( (GPIO9_DR & UDS_n_LOW ) | LDS_n_HIGH) ;    break;  }
    case (9):   { precalculate_uls_lds = ( (GPIO9_DR | UDS_n_HIGH) & LDS_n_LOW ) ;    break;  }
    case (16):   { precalculate_uls_lds = ( (GPIO9_DR & UDS_n_LOW ) & LDS_n_LOW ) ;    break;  }
    case (17):   { precalculate_uls_lds = ( (GPIO9_DR | UDS_n_HIGH) | LDS_n_HIGH) ;    break;  }
  }
//if (local_address>0xE00000)  Serial.printf("local_address: %x local_size:%x\n\r",local_address,local_size);



  // S2 Rising edge of CLK
  // - Assert AS_n
  // - Assert UDS_n, LDS_n
    // -----------------------------------------------------------------------------
  wait_for_CLK_rising_edge();  
  GPIO7_DR = muxout_clock9 & AS_n_LOW;   
  GPIO9_DR = precalculate_uls_lds | 0x80;

  // S3 Falling edge of CLK
  // - Store the values for RESET_n, HALT_n
  // -----------------------------------------------------------------------------
  wait_for_CLK_falling_edge();
  sync_cycle=0;
  digitalWriteFast(PIN_INPUT_MUX,0);
  

  // S4 Rising edge of CLK
  // - Do nothing
  // -----------------------------------------------------------------------------
    wait_for_CLK_rising_edge(); 



  // S5 Falling edge of CLK
  // - Poll for DTACK_n
  // - Handle 6800 Bus Timing (VPA/VMA Cycles)
  // - Poll for BERR_n   ** Future
  // -----------------------------------------------------------------------------
   wait_for_CLK_falling_edge();  
   do { wait_for_CLK_falling_edge();  
   gpio6_dtack_n  = GPIO6_DR & DTACK_n_BIT; 
   gpio6_vpa_n    = GPIO6_DR & VPA_n_BIT;   
   } while ( (gpio6_dtack_n != 0) && ( gpio6_vpa_n != 0) );  

   
   if ( gpio6_vpa_n == 0) {    
      sync_cycle=1;
     
     wait_for_E_falling_edge();

     wait_for_CLK_falling_edge();
     wait_for_CLK_falling_edge();
     GPIO9_DR = GPIO9_DR & VMA_n_LOW;     // Assert VMA_n
     
      wait_for_E_rising_edge();
      wait_for_E_falling_edge();

      GPIO7_DR = (muxout_clock9 | AS_n_HIGH | DATA_OE_n_HIGH);
      GPIO9_DR = GPIO9_DR | UDS_LDS_n_HIGH | VMA_n_HIGH; 
      read_data = GPIO6_DR >> 16;
      digitalWriteFast(PIN_INPUT_MUX,1);

           if (local_size==8)  { read_data = (read_data>>8); }
      else if (local_size==9)  { read_data = (read_data&0x00FF); }

      
       interrupts();                       // Re-enable Teensy's interrupts so the UART and downloading works

     if  ( (local_address&0xFF0000)==0xF80000) read_data = 0xFFFF;
      
       return read_data;
   }
     
  
  // S6 Rising edge of CLK
  // - Steer the '257 to pass read data
  // -----------------------------------------------------------------------------
  wait_for_CLK_rising_edge(); 

  
  
  // S7 Falling edge of CLK
  // - Deassert AS_n, UDS_n, LDS_n
  // - Sample the Data Bus
  // - Steer the '257 to pass the reset, halt, IPL, BERR
  // -----------------------------------------------------------------------------
  wait_for_CLK_falling_edge();  
  GPIO7_DR = muxout_clock9 | AS_n_HIGH | DATA_OE_n_HIGH;
  GPIO9_DR = GPIO9_DR | UDS_LDS_n_HIGH; 
  
  read_data = gpio6_data >> 16;
  digitalWriteFast(PIN_INPUT_MUX,1);


           if (local_size==8)  { read_data = (read_data>>8); }
      else if (local_size==9)  { read_data = (read_data&0x00FF); }
      
  interrupts();                       // Re-enable Teensy's interrupts so the UART and downloading works


    return read_data;
}
}
  


// Requests BIU to perform an Interrupt IACK cycle 
// ----------------------------------------------------------------------
uint8_t BIU_IACK() {    
  uint8_t  local_fc_copy;
  uint32_t local_address;
  uint16_t  local_data;
  //uint8_t  local_intr_mask;
  
 // local_intr_mask=mc68k_flag_INTR_Mask;    //Serial.printf("BIU_IACK\n\r");

  local_fc_copy = mc68k_fc;
  mc68k_fc = 0x7;                                 // Set to Address Space Type = CPU Space for IACK
  local_address = 0xFFFFFFF1 | (gpio6_ipl << 1);                  // Set Address output for IACK
  local_data  = BIU_Read(local_address, SIZE_BYTE);                 // Read the vector
  
  if (sync_cycle==1) local_data = 0x18 + gpio6_ipl;               // Autovector Interrupt = 0x18 + the IPL number   

  mc68k_fc = local_fc_copy;
  return local_data;
}


// BIU Read 32 bits
// ----------------------------------------------------------------------
unsigned long BIU_Read_32(unsigned long local_address)
{ 
  return (BIU_Read(local_address , 16) << 16) | BIU_Read(local_address+0x2 , 16);
}


// BIU Write 32 bits
// ----------------------------------------------------------------------
void BIU_Write_32(unsigned long local_address , unsigned long local_data )
{ 
  BIU_Write(local_address ,     (0xFFFF0000&local_data)>>16 , 16);                                  // Write upper word of the 32-bit data
  BIU_Write(local_address+0x2,  (0x0000FFFF&local_data)     , 16);                                  // Write lower word of the 32-bit data at next word address
  return;
}


// Add a word to the prefetch queue
// ------------------------------------------------------
void BIU_PFQ_add_word()  {
    uint16_t local_word;
    
    if (prefetch_queue_count>1) return;  // Prefetch queue limited to two words

    mc68k_fc = ((mc68k_flags & 0x2000) >> 11) | 0x2;    // Set FC to Address Space Type = Program
    local_word = BIU_Read(pfq_in_address , SIZE_WORD);  // Fetch the word
    mc68k_fc = ((mc68k_flags & 0x2000) >> 11) | 0x1;    // Return FC to Address Space Type = Data

    pfq_in_address = pfq_in_address + 2;

    
    switch(prefetch_queue_count)  {
    case 0: pfq_word_A = local_word; break;
    case 1: pfq_word_B = local_word; break;
    }
    prefetch_queue_count++;
                                 //Serial.printf("PFQ  %d  %x  %x\n\r",prefetch_queue_count-1,pfq_word_A,pfq_word_B);

    
    return;
}


// Fetch a word from the prefetch queue
// ------------------------------------------------------
uint16_t BIU_PFQ_Fetch()  {
    uint16_t pfq_top_word;
    
    if (prefetch_queue_count==0) BIU_PFQ_add_word();  // Prefetch queue empty, so must fill at least one word in the queue
  
    pfq_top_word = pfq_word_A;  
    pfq_word_A   = pfq_word_B;  
    pfq_word_B   = 0x00;  
    prefetch_queue_count--;
    
    mc68k_pc = mc68k_pc + 2;
                                   //Serial.printf("PFQ Fetchiing %x      %d  %x  %x\n\r",pfq_top_word,prefetch_queue_count,pfq_word_A,pfq_word_B);
//Serial.printf("%x ",pfq_top_word);
    return pfq_top_word;
}


// Flushes the prefetch queue and begins fetching instructions from the new PC address
// -------------------------------------------------------------------------------------
void BIU_Jump(uint32_t jump_address)  {   
    jump_address = 0xFFFFFFFF & jump_address;

    // Check Alignment for Words
    if ( (0x1&jump_address)==1) { access_address=jump_address; Exception_Handler(3); }
    else
    {
      mc68k_pc = jump_address;                        // Set PC to the Jump Address  
    
    prefetch_queue_count = 0;             // Flush the Prefetch Queue
    pfq_in_address = mc68k_pc;
    }
    return;

}

// --------------------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------------------
//
// End MC68000 Bus Interface Unit 
//
// --------------------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------------------




// Write data back to the Data register pool with the correct data size
// ----------------------------------------------------------------------
void Store_Data_Register(unsigned char reg_num , unsigned long reg_data , unsigned char reg_size)
{
    if      (reg_size==8)  { m68k_data_reg[reg_num] = ( (m68k_data_reg[reg_num]&0xFFFFFF00)  | (reg_data&0x000000FF) ); }
    else if (reg_size==16) { m68k_data_reg[reg_num] = ( (m68k_data_reg[reg_num]&0xFFFF0000)  | (reg_data&0x0000FFFF) ); }
    else if (reg_size==32) { m68k_data_reg[reg_num] = (reg_data&0xFFFFFFFF); }
    return;
}

// Read data from the Data register pool
// ----------------------------------------------------------------------
unsigned long Fetch_Data_Register(unsigned char reg_num , unsigned char size)
{
    if       (size==8)   { return (m68k_data_reg[reg_num]&0x000000FF); }
    else if  (size==16)  { return (m68k_data_reg[reg_num]&0x0000FFFF); }
    else if  (size==32)  { return (m68k_data_reg[reg_num]&0xFFFFFFFF); }
    else return 0xEEEEEEEE;
}


// Return the sign-extended value of a B/W/L register 
// ----------------------------------------------------------------------
unsigned long Sign_Extend(unsigned long reg_data , unsigned char reg_size)
{
    if (reg_size==8) 
      {
        if ((reg_data&0x0080)!=0x0)   { return (reg_data | 0xFFFFFF00); } else { return (reg_data & 0x000000FF);  }
      }
    else if (reg_size==16)
      {     
        if ((reg_data&0x8000)!=0x0)   { return (reg_data | 0xFFFF0000); } else { return (reg_data & 0x0000FFFF);  }
      }
    else { return  (reg_data&0xFFFFFFFF);  }
}


// Write data back to the Address register pool
// Byte writes cause an exception
// Write back to the proper SP (A7) depending on the Supervisor mode
// ----------------------------------------------------------------------
void Store_Address_Register(unsigned char reg_num , unsigned long reg_data , unsigned char reg_size)
{
    if (reg_size==8) { Exception_Handler(3); }
   
    else if (mc68k_flag_S==1 && reg_num==0x7) {  m68k_a7_S                 = (reg_data&0xFFFFFFFF);  }
    else                                      {  m68k_address_reg[reg_num] = (reg_data&0xFFFFFFFF);  }

    return;
}



// Read data from the Address register pool
// ----------------------------------------------------------------------
unsigned long Fetch_Address_Register(unsigned char reg_num , unsigned char size)
{
    if (mc68k_flag_S==1 && reg_num==0x7)  return m68k_a7_S;

    else  return m68k_address_reg[reg_num];

}



// Calculate the selected condition results 
// ----------------------------------------------------------------------
unsigned char Test_Condition(unsigned int local_opcode)
{
    unsigned int condition_code;
   
    condition_code = (local_opcode&0x0F00) >> 8; // Isolate opcode bits[11:8]
   
    switch(condition_code)
    {
        case 0x0: return TRUE;                                                                              // Always
        case 0x1: return FALSE;                                                                             // Never
        case 0x2: if (mc68k_flag_C==0 && mc68k_flag_Z==0)                return TRUE; else return FALSE;    // Higher Than         C=0 AND Z=0
        case 0x3: if (mc68k_flag_C==1 || mc68k_flag_Z==1)                return TRUE; else return FALSE;    // Lower or Same       C=1 OR Z=1
        case 0x4: if (mc68k_flag_C==0)                                   return TRUE; else return FALSE;    // Carry Clear         C=0
        case 0x5: if (mc68k_flag_C==1)                                   return TRUE; else return FALSE;    // Carry Set           C=1
        case 0x6: if (mc68k_flag_Z==0)                                   return TRUE; else return FALSE;    // Not Equal           Z=0
        case 0x7: if (mc68k_flag_Z==1)                                   return TRUE; else return FALSE;    // Equal               Z=1
        case 0x8: if (mc68k_flag_V==0)                                   return TRUE; else return FALSE;    // V Clear             V=0
        case 0x9: if (mc68k_flag_V==1)                                   return TRUE; else return FALSE;    // V Set               V=1
        case 0xA: if (mc68k_flag_N==0)                                   return TRUE; else return FALSE;    // Plus                N=0
        case 0xB: if (mc68k_flag_N==1)                                   return TRUE; else return FALSE;    // Minus               N=1
        case 0xC: if (mc68k_flag_N == mc68k_flag_V)                      return TRUE; else return FALSE;    // Greater or Equal    N=V
        case 0xD: if (mc68k_flag_N != mc68k_flag_V)                      return TRUE; else return FALSE;    // Less Than           N!=V
        case 0xE: if ((mc68k_flag_N==mc68k_flag_V) && mc68k_flag_Z==0)   return TRUE; else return FALSE;    // Greater Than        N=V  AND Z=0
        case 0xF: if ((mc68k_flag_N!=mc68k_flag_V) || mc68k_flag_Z==1)   return TRUE; else return FALSE;    // Less Than or Equal  N!=V AND Z=1
    }
    return 0;
}


// Push a word to the Stack
// ----------------------------------------------------------------------
void Push(unsigned int push_data)
{
   
  if (mc68k_flag_S==0x0)
  {
    m68k_address_reg[7] = m68k_address_reg[7] - 0x2;
    BIU_Write(m68k_address_reg[7] , push_data, SIZE_WORD);
  }
  else
  {
    m68k_a7_S = m68k_a7_S - 0x2;
    BIU_Write(m68k_a7_S , push_data, SIZE_WORD);
  }
  return;
}


// Pop a word to from the Stack
// ----------------------------------------------------------------------
unsigned int Pop()
{
  unsigned int temp=0;
   
  if (mc68k_flag_S==0x0)
  {
    temp = BIU_Read(m68k_address_reg[7] , SIZE_WORD);
    m68k_address_reg[7] = m68k_address_reg[7] + 0x2;
  }
  else
  {
    temp = BIU_Read(m68k_a7_S , SIZE_WORD);
    m68k_a7_S = m68k_a7_S + 0x2;
  }
  return temp;
}


// Runs Reset routine to put CPU back to initial conditions
// ----------------------------------------------------------------------
void Reset_routine()
{
  unsigned long  pc_temp=0;

  OVERLAY=1;

  for (uint32_t i=0x7FA700 ; i<=0x7FFF00 ; i=i+1) {  BIU_Write(i, random(0,0xFF) , SIZE_BYTE); }    delay(1000);
  for (uint32_t i=0x7FA700 ; i<=0x7FFF00 ; i=i+1) {  BIU_Write(i, random(0,0xFF) , SIZE_BYTE); }    delay(1000);
    
  
  do { wait_for_CLK_falling_edge();  
  gpio6_reset_n  = gpio6_data & RESET_n_BIT; 
  gpio6_halt_n   = gpio6_data & HALT_n_BIT;
  } while ((gpio6_reset_n == 0) && (gpio6_halt_n == 0) );                 // Wait here until RESET_n and HALT_n signal de-asserted 
  
  
  mc68k_flags=0x2700;                                                                // Initialize flags T=0, S=1, Mask=111
                               
  BIU_Jump(0x000000);                                                                   // Flush prefetch queue and start fetching data at address 0x00
                               
  m68k_a7_S = BIU_PFQ_Fetch();                                                          // Fetch upper word of the Supervisor Stack Pointer

  m68k_a7_S = (m68k_a7_S<<16) | BIU_PFQ_Fetch();                                        // Fetch lower word of the Supervisor Stack Pointer
                                   
  pc_temp = BIU_PFQ_Fetch();                                                            // Fetch upper word of the Program Counter
  mc68k_pc = (pc_temp<<16) | BIU_PFQ_Fetch();                                           // Fetch lower word of the Program Counter

  BIU_Jump(mc68k_pc);                                                                   // Jump to the new PC

  return; 
}


// ----------------------------------------------------------------------
void Exception_Handler(unsigned int vector_number)
{
  unsigned int  temp=0;
  unsigned int  mc68k_flags_copy=0x2700;
  unsigned long exception_address=0;
 
  last_exception = vector_number;                                                       // Store the value of this exception

  mc68k_flags_copy = mc68k_flags;                                                       // Store the original Flags register value
  temp = mc68k_flags | 0x2000;                                                          // Set the S flag
  temp = temp & 0x7FFF;                                                                 // Clear the T flag
  mc68k_flags = temp;                                                               // Update the System Flags
  
  if (vector_number==0x8) clock_counter=6;
 
  if (vector_number <= 3)                                                               // Additional data is stacked for Group 0
  {                                             
    //Push(BIU_Get_Failed_Access_Type());                                                 // Stack the BIU Access Type
    clock_counter=50;
  Push(0x5B);                                                             // !! Set to 0x5A for now
    Push(access_address&0xFFFF);                                                        // Stack the lower portion of the failed access address
    Push(access_address>>16);                                                           // Stack the upper portion of the failed access address
    Push(first_opcode);                                                                 // Stack the Opcode
  }         

  if (vector_number==99)                                                              // 0x99=Interrupt -- Fetch the vector number from the BIU
    {   
      clock_counter=12;
    temp = mc68k_flags & 0xF8FF;                                                      // Clear the Interrupt Flags
      mc68k_flags = (temp | (gpio6_ipl<<8) );                                           // Set the Interrupt Flags to the current IRQ from the BIU
      vector_number = BIU_IACK();                                                       // Fetch the vector from the BIU IACK Cycle
    }
  
  if ( (vector_number == 10) || (vector_number == 11) ) {                 // for the Line-A and Line-F trap the PC is 2 less
     clock_counter=6;
   mc68k_pc -=2 ;
  }

  Push(mc68k_pc&0xFFFF);                                                                // Stack the lower PC
  Push(mc68k_pc>>16);                                                                   // Stack the upper PC
  Push(mc68k_flags_copy);                                                               // Stack the Original copy of the Flags
       
  exception_address = BIU_Read_32(vector_number<<2);                                    // Fetch the 32-bit exception address
  BIU_Jump(exception_address);                                                          // Jump to the exception address


  return; 
}


// ----------------------------------------------------------------------
void op_BOOL_I_TO_CCR(unsigned char bool_type)
{
  clock_counter=8;
  if (bool_type==1) mc68k_flags = (0xFF00&mc68k_flags) |  ( (0x00FF&mc68k_flags) | (0x001F&BIU_PFQ_Fetch()) ); else
  if (bool_type==2) mc68k_flags = (0xFF00&mc68k_flags) |  ( (0x00FF&mc68k_flags) & (0x001F&BIU_PFQ_Fetch()) ); else
  if (bool_type==3) mc68k_flags = (0xFF00&mc68k_flags) |  ( (0x00FF&mc68k_flags) ^ (0x001F&BIU_PFQ_Fetch()) );
  return;
}


// ----------------------------------------------------------------------
void op_BOOL_I_TO_SR(unsigned char bool_type)
{
  if (mc68k_flag_S==0x0) { Exception_Handler(8); }      // Verify that supervisor privilege is set
  else
  {
    clock_counter=clock_counter+8;
  if (bool_type==1) mc68k_flags = (mc68k_flags | BIU_PFQ_Fetch() ); else
    if (bool_type==2) mc68k_flags = (mc68k_flags & BIU_PFQ_Fetch() ); else
    if (bool_type==3) mc68k_flags = (mc68k_flags ^ BIU_PFQ_Fetch() );
  }
  return;
}


// ----------------------------------------------------------------------
unsigned long Calculate_EA(unsigned int allowed_modes)
{
  unsigned long address_register;
  unsigned long temp_address;
  unsigned long ea_extension;
  unsigned long offset=0;
  unsigned long extension_displacement;
  unsigned long extension_register;
  unsigned char ea_A_bit;
  unsigned char ea_L_bit;


  ea_type=99;   // Reset ea_type value

  EA_register =(0x0007&first_opcode); 

  switch( (0x0038&first_opcode)>>3 )
  {
      case 0x0: if ((0x2000&allowed_modes)==0) Exception_Handler(4); else           // Dn
                  { ea_type=DATA_REG;
                    return (EA_register);
                  } break;                           
     
      case 0x1: if ((0x1000&allowed_modes)==0) Exception_Handler(4); else           // An
                  { ea_type=ADDRESS_REG;                                                   
                    return (EA_register);
                  } break;                           
     
      case 0x2: if ((0x0800&allowed_modes)==0) Exception_Handler(4); else           // (An)
                  { ea_type=MEMORY;                                                       
                    address_register=Fetch_Address_Register(EA_register,32);                 
                    return address_register;
                  } break;

      case 0x3: if ((0x0400&allowed_modes)==0) Exception_Handler(4); else           // (An)+
                  { ea_type=MEMORY;                                                       
                    address_register=Fetch_Address_Register(EA_register,32);                     
                    temp_address = address_register;
                    address_register = (data_size==8 && EA_register==0x7) ? address_register+2 : // Special case for SSP
                                       (data_size==8)                     ? address_register+1 :
                                       (data_size==16)                    ? address_register+2 :
                                                                            address_register+4 ;
                    Store_Address_Register(EA_register, address_register , 32);
                    return temp_address;
                  } break;
                                                                           
      case 0x4: if ((0x0200&allowed_modes)==0) Exception_Handler(4); else           // -(An)
                  { clock_counter=clock_counter+2;
              ea_type=MEMORY;                                                       
                    address_register=Fetch_Address_Register(EA_register,32);                     
                    address_register = (data_size==8 && EA_register==0x7) ? address_register-2 : // Special case for SSP
                                       (data_size==8)                     ? address_register-1 :
                                       (data_size==16)                    ? address_register-2 :
                                                                            address_register-4 ;                                                                           
                    Store_Address_Register(EA_register, address_register , 32);
                    return address_register;
                  } break;
                                                                           
      case 0x5: if ((0x0100&allowed_modes)==0) Exception_Handler(4); else           // d16(An)
                  { ea_type=MEMORY;                                                       
                    address_register=Fetch_Address_Register(EA_register,32);                     
                    offset=Sign_Extend(BIU_PFQ_Fetch() ,16);
                    return (0xFFFFFFFF&(address_register+offset));
                  } break;
                                                                                    // d8(An,Xn)
      case 0x6: if ((0x0080&allowed_modes)==0) Exception_Handler(4); else
                  { clock_counter=clock_counter+2;
            ea_type=MEMORY;                                                       
                    address_register=Fetch_Address_Register(EA_register,32);                     
                    ea_extension = BIU_PFQ_Fetch(); 
                    extension_displacement = Sign_Extend( (0x00FF&ea_extension) , 8);
                    extension_register = (0x7000&ea_extension)>>12; 
                    ea_A_bit = ((ea_extension & 0x8000) >> 15);
                    ea_L_bit = ((ea_extension & 0x0800) >> 11);
                    if (ea_A_bit==1 && ea_L_bit==0) offset=Sign_Extend(Fetch_Address_Register(extension_register,16) ,16); else
                    if (ea_A_bit==0 && ea_L_bit==0) offset=Sign_Extend(Fetch_Data_Register(extension_register,16) ,16); else
                    if (ea_A_bit==1 && ea_L_bit==1) offset=Fetch_Address_Register(extension_register,32); else
                    if (ea_A_bit==0 && ea_L_bit==1) offset=Fetch_Data_Register(extension_register,32);
                    return (0xFFFFFFFF&(address_register+offset+extension_displacement));
                  } break;

      case 0x7:
        switch (EA_register)
        {
            case 0x0: if ((0x0040&allowed_modes)==0) Exception_Handler(4); else     // Absolute short   
                      { ea_type=MEMORY;                                                 
                        temp_address = Sign_Extend(BIU_PFQ_Fetch(),16);
                        return temp_address;
                      } break;                 
           
            case 0x1: if ((0x0020&allowed_modes)==0) Exception_Handler(4); else     // Absolute long
                      { ea_type=MEMORY;                                                   
                        temp_address = BIU_PFQ_Fetch();                                         
                        temp_address = ( (temp_address<<16) | BIU_PFQ_Fetch() );   
                        return temp_address;
                      } break;
     
            case 0x2: if ((0x0010&allowed_modes)==0) Exception_Handler(4); else     // x(PC)
                      { ea_type=MEMORY;                                               
                        temp_address = (0xFFFFFFFF&(mc68k_pc-2 + Sign_Extend(BIU_PFQ_Fetch(),16))); // This was ok on the Macbook
                        //Serial.printf("LEA2 %x \n\r",temp_address);
                        return temp_address;
                      } break;
         
            case 0x3: if ((0x0008&allowed_modes)==0) Exception_Handler(4); else     // d8(PC,Xn)
                      { clock_counter=clock_counter+2;
                ea_type=MEMORY;                                                 
                        original_mc68k_pc = mc68k_pc;
                        ea_extension = BIU_PFQ_Fetch();                                 
                        extension_displacement = Sign_Extend( (0x00FF&ea_extension) , 8);
                        extension_register = (0x7000&ea_extension)>>12;
                        ea_A_bit = ((ea_extension & 0x8000) >> 15);
                        ea_L_bit = ((ea_extension & 0x0800) >> 11);
                        if (ea_A_bit==1 && ea_L_bit==0) offset=Sign_Extend(Fetch_Address_Register(extension_register,16) ,16); else
                        if (ea_A_bit==0 && ea_L_bit==0) offset=Sign_Extend(Fetch_Data_Register(extension_register,16) ,16); else
                        if (ea_A_bit==1 && ea_L_bit==1) offset=Fetch_Address_Register(extension_register,32); else
                        if (ea_A_bit==0 && ea_L_bit==1) offset=Fetch_Data_Register(extension_register,32);
                        return (0xFFFFFFFF&(original_mc68k_pc+offset+extension_displacement));
                      } break;
       
            case 0x4: if ((0x0040&allowed_modes)==0) Exception_Handler(4); else     // Immediate
                      {  ea_type=IMMEDIATE;                                               
                         if (data_size==8)  { return (0x00FF&BIU_PFQ_Fetch()); }
                         if (data_size==16) { return (0xFFFF&BIU_PFQ_Fetch()); }
                         if (data_size==32) { temp_address = BIU_PFQ_Fetch();
                                              temp_address = ( (temp_address<<16) | BIU_PFQ_Fetch() );
                                              return temp_address;
                                            }
                      } break;                                       
        }
    }
return 0;
}


// ----------------------------------------------------------------------
unsigned long Fetch_EA(unsigned long local_EA , unsigned char local_ea_type)
{
    if (local_ea_type==ADDRESS_REG && data_size==8 ) return (Fetch_Address_Register(local_EA,8));    else 
    if (local_ea_type==ADDRESS_REG && data_size==16) return (Fetch_Address_Register(local_EA,16));   else
    if (local_ea_type==ADDRESS_REG && data_size==32) return (Fetch_Address_Register(local_EA,32));   else
   
    if (local_ea_type==DATA_REG && data_size==8 )    return (Fetch_Data_Register(local_EA,8));       else
    if (local_ea_type==DATA_REG && data_size==16)    return (Fetch_Data_Register(local_EA,16));      else
    if (local_ea_type==DATA_REG && data_size==32)    return (Fetch_Data_Register(local_EA,32));      else
   
    if (local_ea_type==MEMORY && data_size==8)    return (0xFF&BIU_Read(local_EA , data_size));      else
    if (local_ea_type==MEMORY && data_size==16)   return BIU_Read(local_EA , data_size);             else
    if (local_ea_type==MEMORY && data_size==32)   return BIU_Read_32(local_EA);                      else
       
    if (local_ea_type==IMMEDIATE)  { return local_EA; } // Immediate data held in the calculated EA
                                                                                               
    return 0xEEEE;
}

// ----------------------------------------------------------------------
void Writeback_EA(unsigned long local_EA , unsigned char local_ea_type , unsigned long writeback_data)
{
  if (local_ea_type==ADDRESS_REG)  { Store_Address_Register(local_EA , writeback_data , data_size);  return;  } 
  if (local_ea_type==DATA_REG)     { Store_Data_Register(local_EA , writeback_data , data_size);     return;  }
 
 
  if (local_ea_type==MEMORY && data_size==8)   { BIU_Write(local_EA , writeback_data , data_size); return; }
  if (local_ea_type==MEMORY && data_size==16)  { BIU_Write(local_EA , writeback_data , data_size); return; }
  if (local_ea_type==MEMORY && data_size==32)  { BIU_Write_32(local_EA , writeback_data);          return; }
   
  return;                                             
}   
     
     
// ----------------------------------------------------------------------
unsigned long Fetch_Immediate(unsigned char local_size)
{
    unsigned long temp_data;

    if (local_size==8)  { return (0xFF&BIU_PFQ_Fetch()); }
    if (local_size==16) { return BIU_PFQ_Fetch(); }
    if (local_size==32) { temp_data = BIU_PFQ_Fetch();
                          temp_data = ( (temp_data<<16) | BIU_PFQ_Fetch() );
                          return temp_data;
                        }                     
    return 0xEEEE;
}
     
     
// ----------------------------------------------------------------------
void Calculate_Flag_N(unsigned long result_data)
{
    if (data_size==8 && (0x80&result_data)==0)         mc68k_flags = (mc68k_flags & 0xFFF7);  else
    if (data_size==8 && (0x80&result_data)!=0)         mc68k_flags = (mc68k_flags | 0x0008);  else
     
    if (data_size==16 && (0x8000&result_data)==0)      mc68k_flags = (mc68k_flags & 0xFFF7);  else
    if (data_size==16 && (0x8000&result_data)!=0)      mc68k_flags = (mc68k_flags | 0x0008);  else
   
    if (data_size==32 && (0x80000000&result_data)==0)  mc68k_flags = (mc68k_flags & 0xFFF7);  else
    if (data_size==32 && (0x80000000&result_data)!=0)  mc68k_flags = (mc68k_flags | 0x0008);
   
    return ;
}
     
     
// ----------------------------------------------------------------------
void Calculate_Flag_Z(unsigned long result_data , unsigned char clear_only)
{

    if (data_size==8 && (0xFF&result_data)!=0)                              mc68k_flags = (mc68k_flags & 0xFFFB);  else
    if (data_size==8 && (0xFF&result_data)==0 && clear_only==FALSE)         mc68k_flags = (mc68k_flags | 0x0004);  else
     
    if (data_size==16 && (0xFFFF&result_data)!=0)                           mc68k_flags = (mc68k_flags & 0xFFFB);  else
    if (data_size==16 && (0xFFFF&result_data)==0&& clear_only==FALSE)       mc68k_flags = (mc68k_flags | 0x0004);  else
   
    if (data_size==32 && (0xFFFFFFFF&result_data)!=0)                       mc68k_flags = (mc68k_flags & 0xFFFB);  else
    if (data_size==32 && (0xFFFFFFFF&result_data)==0 && clear_only==FALSE)  mc68k_flags = (mc68k_flags | 0x0004);

    return ;
}
     

// ----------------------------------------------------------------------
void op_MOVE()
{
  data_size             = DATA_SIZE_TYPE_B;                                                     // Get the data size from the opcode bits[13:12]

  source_ea             = Calculate_EA(0x3FFC);                                                 // Calculate the Source EA, checking supported modes
  source_ea_type        = ea_type;

  first_opcode          = (0x0FC0&first_opcode);                                                // Re-arrange the second EA bit fields to the usual locations for the MOVE instruction
  first_opcode          = ( ((0x01C0&first_opcode)>>3) | ((0x0E00&first_opcode)>>9) );     
 
  destination_ea        = Calculate_EA(0x3FE0);                                                 // Calculate the Destination  EA, checking supported modes
  destination_ea_type   = ea_type; 
 

  EA_Data = Fetch_EA(source_ea , source_ea_type);                                               // Fetch the Source EA operand

  if ( (destination_ea_type==ADDRESS_REG) && data_size==16)  { Writeback_EA(destination_ea , destination_ea_type ,(Sign_Extend(EA_Data ,16)) );  } // Write-back to Destination EA     
  else                                                       { Writeback_EA(destination_ea , destination_ea_type ,       EA_Data             );  } 


  if (destination_ea_type != ADDRESS_REG)                                                       // Don't update flags for MOVEA
  {
    mc68k_flags = ( mc68k_flags & 0xFFFC);                                                      // Always clear V, C Flags
    Calculate_Flag_N(EA_Data);                                                                  // Calculate the N Flag
    Calculate_Flag_Z(EA_Data , FALSE);                                                          // Calculate the Z Flag - Clear_only = FALSE
  }
 clock_counter=0;
  return;
}


// ----------------------------------------------------------------------
void op_MOVE_TO_CCR()
{
  clock_counter=clock_counter+8;
  data_size = 8;
  source_ea     = Calculate_EA(0x2FFC);                                                         // Calculate the Source EA, checking supported modes
  EA_Data       = Fetch_EA(source_ea , ea_type);                                                // Fetch the Source EA operand
  mc68k_flags   = ( (0xFF00&mc68k_flags) | (0x001F&EA_Data) );                                  // Update the CCR Flags
  return;
}


// ----------------------------------------------------------------------
void op_MOVE_TO_SR()
{
  if (mc68k_flag_S==0x0) { Exception_Handler(8); }                                              // Verify that supervisor privilege is set
  else
  {
    clock_counter=clock_counter+4;
  data_size = 16;
    source_ea   = Calculate_EA(0x2FFC);                                                         // Calculate the Source EA, checking supported modes
    EA_Data     = Fetch_EA(source_ea , ea_type);                                                // Fetch the Source EA operand
    mc68k_flags = (EA_Data);                                                               // Update the SR Flags
  }
  return;
}


// ----------------------------------------------------------------------
void op_MOVE_FROM_SR()
{
  clock_counter=clock_counter+2;
  data_size         = 16;
  calculated_EA     = Calculate_EA(0x2FE0);                                                     // Calculate the Source EA, checking supported modes
  EA_Data           = Fetch_EA(calculated_EA , ea_type);                                        // Unnecessary fetch the EA operand ** Unoptimized 68000 **
  Writeback_EA(calculated_EA , ea_type ,mc68k_flags);                                           // Write-back to the Destination EA
  return;
}


// ----------------------------------------------------------------------
void op_MOVE_USP()
{
  if (mc68k_flag_S==0x0) { Exception_Handler(8); }                                              // Verify that supervisor privilege is set
  else
  {
    data_size = 32;
    EA_register =(0x0007&first_opcode);

    if ((0x8&first_opcode)==0) {  m68k_address_reg[7] = Fetch_Address_Register(EA_register,32);      } else    // Address Register --> USP
                               {  Store_Address_Register(EA_register , m68k_address_reg[7] , 32); }            // USP --> Address Register 
  }
  return;
}


// ----------------------------------------------------------------------
void op_JMP()
{
  calculated_EA = Calculate_EA(0x09F8);                                                         // Calculate the EA, checking supported modes
  BIU_Jump(calculated_EA);                                                                      // Jump to the new PC
  return; 
}


// ----------------------------------------------------------------------
void op_JSR()
{
  calculated_EA = Calculate_EA(0x09F8);                                                         // Calculate the EA, checking supported modes
  Push(mc68k_pc&0xFFFF);                                                                        // Stack the lower PC
  Push(mc68k_pc>>16);                                                                           // Stack the upper PC
  BIU_Jump(calculated_EA);                                                                      // Jump to the new PC
  return; 
}


// ----------------------------------------------------------------------
void op_BSR()
{
  unsigned long opcode_pc;
  unsigned long displacement;
 
  clock_counter=clock_counter+2;
  displacement = (0x00FF&first_opcode);                                                         // Isolate the displacement field of the opcode
  opcode_pc     = mc68k_pc ;                                                                    // Store the PC of the initial opcode
               
  if (displacement==0)  {  displacement=Sign_Extend(BIU_PFQ_Fetch() , 16);  }                   // Sign extend the 16-bit displacement held in the next opcode word
  else                  {  displacement=Sign_Extend(displacement     , 8);  }                   // Sign extend the 8-bit displacement held in the initial opcode
                   
  Push(mc68k_pc&0xFFFF);                                                                        // Stack the lower PC of address of the next opcode
  Push(mc68k_pc>>16);                                                                           // Stack the upper PC of address of the next opcode
  BIU_Jump(opcode_pc + displacement);                                                           // Jump to the new PC calculated using the address of first byte of the opcode
               
  return;               
}               
               
               
// ----------------------------------------------------------------------               
void op_RTS()               
{               
  mc68k_pc = Pop()<<16;                                                                         // Pop the upper PC
  mc68k_pc = mc68k_pc | Pop();                                                                  // Pop the lower PC
  BIU_Jump(mc68k_pc);                                                                           // Jump to the new PC
  return; 
}


// ----------------------------------------------------------------------
void op_RTR()
{
  clock_counter=clock_counter+16;
  mc68k_flags   = ( (0xFFE0&mc68k_flags) | (0x001F&Pop()) );                                    // Update the CCR Flags
  mc68k_pc = Pop()<<16;                                                                         // Pop the upper PC
  mc68k_pc = mc68k_pc | Pop();                                                                  // Pop the lower PC
  BIU_Jump(mc68k_pc);                                                                           // Jump to the new PC
  return; 
}


// ----------------------------------------------------------------------
void op_BCC()
{
  unsigned long opcode_pc;
  unsigned long displacement;
 
  displacement  = (0x00FF&first_opcode);                                                        // Isolate the displacement field of the opcode
  opcode_pc     = mc68k_pc ;                                                                    // Store the PC of the initial opcode
           
  if (displacement==0)  {  displacement=Sign_Extend(BIU_PFQ_Fetch() , 16);  }                   // Sign extend the 16-bit displacement held in the next opcode word
  else                  {  displacement=Sign_Extend(displacement     , 8);  }                   // Sign extend the 8-bit displacement held in the initial opcode

  BIU_PFQ_add_word(); // To match 68000
               
  if (Test_Condition(first_opcode)==TRUE) { clock_counter=clock_counter+2; BIU_Jump(opcode_pc + displacement); }               // Jump to the new PC
  else                                    { clock_counter=clock_counter+4; return;                             }
  return;
}


// ----------------------------------------------------------------------
void op_SCC()
{ 
  data_size         = 8;
  calculated_EA     = Calculate_EA(0x2FE0);                                                     // Calculate the EA, checking supported modes
  EA_Data           = Fetch_EA(calculated_EA , ea_type);                                        // Unnecessary fetch the EA operand ** Unoptimized 68000 **

  if (Test_Condition(first_opcode)==TRUE)  {  EA_Data=0x000000FF;  }                            // Condition TRUE, so set the byte to 0xFF
  else                                     {  EA_Data=0xFFFFFF00;  }                            // Condition FALSE, so clear the byte to 0

  Writeback_EA(calculated_EA , ea_type ,EA_Data);                                               // Write-back to the EA

  return; 
}


// ----------------------------------------------------------------------
void op_dBCC()
{ 
  unsigned long opcode_pc;
  unsigned long displacement;
  unsigned int  counter;
 
  reg_num = (0x0007&first_opcode);                                                              // Isolate the register number from the opcode
  opcode_pc     = mc68k_pc;                                                                     // Store the PC of the initial opcode

  displacement=Sign_Extend(BIU_PFQ_Fetch() , 16);                                               // Fetch and sign-extend the 16-bit displacement from the second opcode
 
  counter = Fetch_Data_Register(reg_num,16);                                                    // Fetch the Loop counter value from the register - just lower 16-bits
 
  if ( Test_Condition(first_opcode)==FALSE )
  {
    counter = counter - 1;
    Store_Data_Register(reg_num , counter , 16);                                                // Write-back the counter value to the register
 
    if ((0x0000FFFF&counter)==0xFFFF)  { clock_counter=clock_counter+2; return;        }        // When the counter equals (-1), continue to next opcode, else jump to the new PC
    else                               { clock_counter=0; BIU_Jump(opcode_pc + displacement);  return;  }                     

  }
  else
  {
    clock_counter=clock_counter+2;
  }

  
  return;
}


// ----------------------------------------------------------------------
void op_LEA()
{   

  data_size         = 32;
  calculated_EA     = Calculate_EA(0x09F8);                                                     // Calculate the EA, checking supported modes
  reg_num = (0x0E00&first_opcode)>>9;                                                           // Isolate the register number from the opcode
  Store_Address_Register(reg_num , calculated_EA , 32);                                         // Write-back the EA value to the register
  return; 
}


// ----------------------------------------------------------------------
void op_PEA()
{ 
  data_size         = 32;
  calculated_EA     = Calculate_EA(0x09F8);                                                     // Calculate the EA, checking supported modes
  Push(calculated_EA&0xFFFF);                                                                   // Stack the lower portion of the EA
  Push(calculated_EA>>16);                                                                      // Stack the upper portion of the EA
  return;       
}       
       
       
// ----------------------------------------------------------------------       
void op_CHK()               
{       
  signed short int  reg_data;       
       
  clock_counter=6;
  data_size         = 16;       
  calculated_EA     = Calculate_EA(0x02FFC);                                                    // Calculate the EA, checking supported modes
  EA_Data = Fetch_EA(calculated_EA , ea_type);                                                  // Fetch the EA operand
       
  reg_num  = (0x0E00&first_opcode)>>9;                                                          // Isolate the register number from the opcode
  reg_data = Fetch_Data_Register(reg_num,16);                                                   // Fetch the lower 16-bits of the Data Register

  if ( (0x8000&reg_data) != 0)                                                                  // Is number negative?               
    {     
      mc68k_flags = mc68k_flags | 0x08;                                                         // Set the N flag
      Exception_Handler(6);
      return;
    }   
  else if ( (signed short int)reg_data > (signed short int)EA_Data )   
    { 
      mc68k_flags = mc68k_flags & 0xFFF7;                                                       // Clear the N flag
      Exception_Handler(6);
      return;
    }   
  else                                             
    {
      return; 
    }
}


// ----------------------------------------------------------------------
void op_TRAPV()
{ 
  clock_counter=2;
  if (mc68k_flag_V==1) { Exception_Handler(7);  return;  }
  else                 { return;                         }
}


// ----------------------------------------------------------------------
void op_TRAP()
{                               
  clock_counter=6;
  Exception_Handler( (0x000F&first_opcode) + 32 );                                              // Isolate the register number from the opcode and add 32 to create the vector number
  return;
}


// ----------------------------------------------------------------------
void op_LINK()
{                   
  signed long reg_data;
 
  reg_num = (0x0007&first_opcode);                                                              // Isolate the register number from the opcode
  reg_data = Fetch_Address_Register(reg_num,32);                                                // Fetch the Address Register
  Push(reg_data&0xFFFF);                                                                        // Stack the lower portion of the Address Register
  Push(reg_data>>16);                                                                           // Stack the upper portion of the Address Register
       
  if (mc68k_flag_S==1)     
    {       
      Store_Address_Register(reg_num, m68k_a7_S , 32);                                          //  Copy the active Stack Pointer to the selected Address Register
      m68k_a7_S = m68k_a7_S + Sign_Extend(BIU_PFQ_Fetch() ,16);
    }
  else                 
    {
      Store_Address_Register(reg_num, m68k_address_reg[7] , 32);
      m68k_address_reg[7] = m68k_address_reg[7] + Sign_Extend(BIU_PFQ_Fetch() ,16);
    }

  return;
}


// ----------------------------------------------------------------------
void op_UNLK()
{                   
  unsigned long reg_data;
 
  reg_num = (0x0007&first_opcode);                                                              // Isolate the register number from the opcode
  reg_data = Fetch_Address_Register(reg_num,32);                                                   // Fetch the Address Register
       
  if (mc68k_flag_S==1) {  m68k_a7_S = reg_data;             }                                   // Copy Address contents to the current Stack Pointer
  else                 {  m68k_address_reg[7] = reg_data;   }       
       
  reg_data = Pop()<<16;                                                                         // Pop the upper Address Register
  reg_data = reg_data | Pop();                                                                  // Pop the lower Address Register
  Store_Address_Register(reg_num, reg_data , 32);                                               // Write-back the stacked address to the Address Register
 
  return;
}


// ----------------------------------------------------------------------
void op_RTE()
{     
  uint16_t temp_flags;    
  
  if (mc68k_flag_S==0x0) { Exception_Handler(8); }                                              // Verify that supervisor privilege is set
  else     
  {         
    //Update_System_Flags(Pop());                                                                 // Pop the SR Flags
    //mc68k_pc    = Pop()<<16;                                                                    // Pop the upper PC
    //mc68k_pc    = mc68k_pc | Pop();                                                             // Pop the lower PC
    //BIU_Jump(mc68k_pc);                                                                         // Jump to the new PC
  
  temp_flags = Pop(); 
    mc68k_pc = Pop()<<16; 
    mc68k_pc = mc68k_pc | Pop(); 
    mc68k_flags = (temp_flags); 
    BIU_Jump(mc68k_pc); 
  }     
  return;       
}       
       
       
// ----------------------------------------------------------------------       
void op_RESET()     
{                           
  if (mc68k_flag_S==0x0) {  Exception_Handler(8); }                                             // Verify that supervisor privilege is set
 // else                   {  BIU_Force_Reset();    }     
  else                   {  Reset_routine();    }     
  return;       
}       
       
       
// ----------------------------------------------------------------------       
void op_STOP()     
{                           
  if (mc68k_flag_S==0x0) { Exception_Handler(8); }                                              // Verify that supervisor privilege is set
  else     
  {     
    clock_counter=4;
    mc68k_flags = (BIU_PFQ_Fetch());                                                       // Fetch the SR Flags
           
    while ( gpio6_reset_n!=0 && gpio6_ipl==0 && mc68k_flag_T==0)  { 
  gpio6_ipl    = 0x7 & (0x7 ^ ((gpio6_data & IPL2_0_BITs)>>16 ));  // Invert the IPL bits which are active low on the pins
  gpio6_reset_n  = GPIO6_DR & RESET_n_BIT;
  }                   // Proceed if Trace is active, or RESET/Interrupt occurs
  }
  return; 
}


// ----------------------------------------------------------------------
void op_SWAP()
{                   
  unsigned long reg_data;
 
  clock_counter=4;
  data_size     = 32;
  reg_num       = (0x0007&first_opcode);                                                        // Isolate the register number from the opcode
 
  reg_data = Fetch_Data_Register(reg_num,32);                                                   // Swap the upper and lower words of the register, then write it back
  reg_data = (reg_data<<16 | reg_data>>16);
  Store_Data_Register(reg_num , reg_data , 32);
 
  mc68k_flags = ( mc68k_flags & 0xFFFC);                                                        // Always clear V, C Flags
  Calculate_Flag_N(reg_data);                                                                   // Calculate the N Flag
  Calculate_Flag_Z(reg_data , FALSE);                                                           // Calculate the Z Flag - Clear_only = FALSE
 
  return; 
}


// ----------------------------------------------------------------------
void op_EXT()
{                   
  unsigned long reg_data;
 
  reg_num       = (0x0007&first_opcode);                                                        // Isolate the register number from the opcode
 
  if ( ((0x00C0&first_opcode)>>6) == 2) 
  {
    reg_data = Sign_Extend(Fetch_Data_Register(reg_num,8) ,8);
    Store_Data_Register(reg_num , reg_data , 16);
    data_size = 16;                                                                             // Set size for flag calculation
  }
  else
  {
    reg_data = Sign_Extend(Fetch_Data_Register(reg_num,16) ,16);
    Store_Data_Register(reg_num , reg_data , 32); 
    data_size = 32;                                                                             // Set size for flag calculation
  }

  mc68k_flags = ( mc68k_flags & 0xFFFC);                                                        // Always clear V, C Flags
  Calculate_Flag_N(reg_data);                                                                   // Calculate the N Flag
  Calculate_Flag_Z(reg_data , FALSE);                                                           // Calculate the Z Flag - Clear_only = FALSE
  return; 
}


// ----------------------------------------------------------------------
void op_MOVEQ()
{                   
  unsigned long reg_data;
 
  reg_num       = (0x0E00&first_opcode)>>9;                                                     // Isolate the register number from the opcode
 
  reg_data = Sign_Extend(first_opcode ,8);                                                      // Sign-extend the data held in the opcode and write-back to selected register
  Store_Data_Register(reg_num , reg_data , 32);
 
  data_size     = 32;                                                                           // Set size for flag calculation
  mc68k_flags = ( mc68k_flags & 0xFFFC);                                                        // Always clear V, C Flags
  Calculate_Flag_N(reg_data);                                                                   // Calculate the N Flag
  Calculate_Flag_Z(reg_data , FALSE);                                                           // Calculate the Z Flag - Clear_only = FALSE
 
  return; 
}


// ----------------------------------------------------------------------
void op_MOVEM()
{                   
  unsigned short increment_size;
  unsigned int reg_list;

  data_size      = DATA_SIZE_TYPE_C;                                                             // Get the data size from the opcode bit[6]
  increment_size = data_size>>3;                                                                 // increment_size is +2 for Word,  +4 for Long
 
  if ( ((0x0400&first_opcode)>>10) == 1)                                                         // ** Memory to Registers **
  { 
    reg_list        = BIU_PFQ_Fetch();                                                           // Get the Register_list from the second opcode word
    calculated_EA=Calculate_EA(0x0DF8);
    BIU_PFQ_add_word();

    if ( (0x0001&reg_list)!=0)  { Store_Data_Register   (0 , Sign_Extend(Fetch_EA(calculated_EA , ea_type) ,data_size) , 32); calculated_EA=calculated_EA+increment_size; }  // D0
    if ( (0x0002&reg_list)!=0)  { Store_Data_Register   (1 , Sign_Extend(Fetch_EA(calculated_EA , ea_type) ,data_size) , 32); calculated_EA=calculated_EA+increment_size; }  // D1
    if ( (0x0004&reg_list)!=0)  { Store_Data_Register   (2 , Sign_Extend(Fetch_EA(calculated_EA , ea_type) ,data_size) , 32); calculated_EA=calculated_EA+increment_size; }  // D2
    if ( (0x0008&reg_list)!=0)  { Store_Data_Register   (3 , Sign_Extend(Fetch_EA(calculated_EA , ea_type) ,data_size) , 32); calculated_EA=calculated_EA+increment_size; }  // D3
    if ( (0x0010&reg_list)!=0)  { Store_Data_Register   (4 , Sign_Extend(Fetch_EA(calculated_EA , ea_type) ,data_size) , 32); calculated_EA=calculated_EA+increment_size; }  // D4
    if ( (0x0020&reg_list)!=0)  { Store_Data_Register   (5 , Sign_Extend(Fetch_EA(calculated_EA , ea_type) ,data_size) , 32); calculated_EA=calculated_EA+increment_size; }  // D5
    if ( (0x0040&reg_list)!=0)  { Store_Data_Register   (6 , Sign_Extend(Fetch_EA(calculated_EA , ea_type) ,data_size) , 32); calculated_EA=calculated_EA+increment_size; }  // D6
    if ( (0x0080&reg_list)!=0)  { Store_Data_Register   (7 , Sign_Extend(Fetch_EA(calculated_EA , ea_type) ,data_size) , 32); calculated_EA=calculated_EA+increment_size; }  // D7
    if ( (0x0100&reg_list)!=0)  { Store_Address_Register(0 , Sign_Extend(Fetch_EA(calculated_EA , ea_type) ,data_size) , 32); calculated_EA=calculated_EA+increment_size; }  // A0
    if ( (0x0200&reg_list)!=0)  { Store_Address_Register(1 , Sign_Extend(Fetch_EA(calculated_EA , ea_type) ,data_size) , 32); calculated_EA=calculated_EA+increment_size; }  // A1
    if ( (0x0400&reg_list)!=0)  { Store_Address_Register(2 , Sign_Extend(Fetch_EA(calculated_EA , ea_type) ,data_size) , 32); calculated_EA=calculated_EA+increment_size; }  // A2
    if ( (0x0800&reg_list)!=0)  { Store_Address_Register(3 , Sign_Extend(Fetch_EA(calculated_EA , ea_type) ,data_size) , 32); calculated_EA=calculated_EA+increment_size; }  // A3
    if ( (0x1000&reg_list)!=0)  { Store_Address_Register(4 , Sign_Extend(Fetch_EA(calculated_EA , ea_type) ,data_size) , 32); calculated_EA=calculated_EA+increment_size; }  // A4
    if ( (0x2000&reg_list)!=0)  { Store_Address_Register(5 , Sign_Extend(Fetch_EA(calculated_EA , ea_type) ,data_size) , 32); calculated_EA=calculated_EA+increment_size; }  // A5
    if ( (0x4000&reg_list)!=0)  { Store_Address_Register(6 , Sign_Extend(Fetch_EA(calculated_EA , ea_type) ,data_size) , 32); calculated_EA=calculated_EA+increment_size; }  // A6
    if ( (0x8000&reg_list)!=0)  { Store_Address_Register(7 , Sign_Extend(Fetch_EA(calculated_EA , ea_type) ,data_size) , 32); calculated_EA=calculated_EA+increment_size; }  // A7

    data_size = 16;
    //immediate = Fetch_EA(calculated_EA , ea_type);                                                          // Extra fetch due to 68000 anomaly
   
    if ( ((0x0038&first_opcode)>>3) == 0x3 ) Store_Address_Register(EA_register, calculated_EA , 32);       // Write-back the address register for (An)+ Mode
  }
   
     
  else if ( ((0x0400&first_opcode)>>10) == 0 && ((0x0038&first_opcode)>>3) == 0x4 )                         // **  Registers to Memory    -(An) Addressing Mode **
  {
    reg_list        = BIU_PFQ_Fetch();                                                                      // Get the Register_list from the second opcode word
    calculated_EA = Calculate_EA(0x0BE0) + increment_size;                                                  // Get the Address but adjust so decrementing can start fresh below
    Store_Address_Register(EA_register, (calculated_EA) , 32);                                              // Write-back the address register to the initial value

    if ( (0x0001&reg_list)!=0)  {  calculated_EA=calculated_EA-increment_size; Writeback_EA(calculated_EA , ea_type , Fetch_Address_Register(7,32) );  }  // A7
    if ( (0x0002&reg_list)!=0)  {  calculated_EA=calculated_EA-increment_size; Writeback_EA(calculated_EA , ea_type , Fetch_Address_Register(6,32) );  }  // A6
    if ( (0x0004&reg_list)!=0)  {  calculated_EA=calculated_EA-increment_size; Writeback_EA(calculated_EA , ea_type , Fetch_Address_Register(5,32) );  }  // A5
    if ( (0x0008&reg_list)!=0)  {  calculated_EA=calculated_EA-increment_size; Writeback_EA(calculated_EA , ea_type , Fetch_Address_Register(4,32) );  }  // A4
    if ( (0x0010&reg_list)!=0)  {  calculated_EA=calculated_EA-increment_size; Writeback_EA(calculated_EA , ea_type , Fetch_Address_Register(3,32) );  }  // A3
    if ( (0x0020&reg_list)!=0)  {  calculated_EA=calculated_EA-increment_size; Writeback_EA(calculated_EA , ea_type , Fetch_Address_Register(2,32) );  }  // A2
    if ( (0x0040&reg_list)!=0)  {  calculated_EA=calculated_EA-increment_size; Writeback_EA(calculated_EA , ea_type , Fetch_Address_Register(1,32) );  }  // A1
    if ( (0x0080&reg_list)!=0)  {  calculated_EA=calculated_EA-increment_size; Writeback_EA(calculated_EA , ea_type , Fetch_Address_Register(0,32) );  }  // A0   
    if ( (0x0100&reg_list)!=0)  {  calculated_EA=calculated_EA-increment_size; Writeback_EA(calculated_EA , ea_type , Fetch_Data_Register   (7,32) );  }  // D7
    if ( (0x0200&reg_list)!=0)  {  calculated_EA=calculated_EA-increment_size; Writeback_EA(calculated_EA , ea_type , Fetch_Data_Register   (6,32) );  }  // D6
    if ( (0x0400&reg_list)!=0)  {  calculated_EA=calculated_EA-increment_size; Writeback_EA(calculated_EA , ea_type , Fetch_Data_Register   (5,32) );  }  // D5
    if ( (0x0800&reg_list)!=0)  {  calculated_EA=calculated_EA-increment_size; Writeback_EA(calculated_EA , ea_type , Fetch_Data_Register   (4,32) );  }  // D4
    if ( (0x1000&reg_list)!=0)  {  calculated_EA=calculated_EA-increment_size; Writeback_EA(calculated_EA , ea_type , Fetch_Data_Register   (3,32) );  }  // D3
    if ( (0x2000&reg_list)!=0)  {  calculated_EA=calculated_EA-increment_size; Writeback_EA(calculated_EA , ea_type , Fetch_Data_Register   (2,32) );  }  // D2
    if ( (0x4000&reg_list)!=0)  {  calculated_EA=calculated_EA-increment_size; Writeback_EA(calculated_EA , ea_type , Fetch_Data_Register   (1,32) );  }  // D1
    if ( (0x8000&reg_list)!=0)  {  calculated_EA=calculated_EA-increment_size; Writeback_EA(calculated_EA , ea_type , Fetch_Data_Register   (0,32) );  }  // D0
   
    Store_Address_Register(EA_register, calculated_EA , 32);                                                // Write-back the address register
  }
 
     
  else if ( ((0x0400&first_opcode)>>10) == 0 && ((0x0038&first_opcode)>>3) != 0x4 )                         //  ** Registers to Memory   All except -(An) Addressing Mode **
  {
    reg_list        = BIU_PFQ_Fetch();                                                                      // Get the Register_list from the second opcode word
    calculated_EA=Calculate_EA(0x0BE0);

    if ( (0x0001&reg_list)!=0)  { Writeback_EA(calculated_EA , ea_type , Fetch_Data_Register   (0,32) );  calculated_EA=calculated_EA+increment_size; }  // D0
    if ( (0x0002&reg_list)!=0)  { Writeback_EA(calculated_EA , ea_type , Fetch_Data_Register   (1,32) );  calculated_EA=calculated_EA+increment_size; }  // D1
    if ( (0x0004&reg_list)!=0)  { Writeback_EA(calculated_EA , ea_type , Fetch_Data_Register   (2,32) );  calculated_EA=calculated_EA+increment_size; }  // D2
    if ( (0x0008&reg_list)!=0)  { Writeback_EA(calculated_EA , ea_type , Fetch_Data_Register   (3,32) );  calculated_EA=calculated_EA+increment_size; }  // D3
    if ( (0x0010&reg_list)!=0)  { Writeback_EA(calculated_EA , ea_type , Fetch_Data_Register   (4,32) );  calculated_EA=calculated_EA+increment_size; }  // D4
    if ( (0x0020&reg_list)!=0)  { Writeback_EA(calculated_EA , ea_type , Fetch_Data_Register   (5,32) );  calculated_EA=calculated_EA+increment_size; }  // D5
    if ( (0x0040&reg_list)!=0)  { Writeback_EA(calculated_EA , ea_type , Fetch_Data_Register   (6,32) );  calculated_EA=calculated_EA+increment_size; }  // D6
    if ( (0x0080&reg_list)!=0)  { Writeback_EA(calculated_EA , ea_type , Fetch_Data_Register   (7,32) );  calculated_EA=calculated_EA+increment_size; }  // D7
    if ( (0x0100&reg_list)!=0)  { Writeback_EA(calculated_EA , ea_type , Fetch_Address_Register(0,32) );  calculated_EA=calculated_EA+increment_size; }  // A0
    if ( (0x0200&reg_list)!=0)  { Writeback_EA(calculated_EA , ea_type , Fetch_Address_Register(1,32) );  calculated_EA=calculated_EA+increment_size; }  // A1
    if ( (0x0400&reg_list)!=0)  { Writeback_EA(calculated_EA , ea_type , Fetch_Address_Register(2,32) );  calculated_EA=calculated_EA+increment_size; }  // A2
    if ( (0x0800&reg_list)!=0)  { Writeback_EA(calculated_EA , ea_type , Fetch_Address_Register(3,32) );  calculated_EA=calculated_EA+increment_size; }  // A3
    if ( (0x1000&reg_list)!=0)  { Writeback_EA(calculated_EA , ea_type , Fetch_Address_Register(4,32) );  calculated_EA=calculated_EA+increment_size; }  // A4
    if ( (0x2000&reg_list)!=0)  { Writeback_EA(calculated_EA , ea_type , Fetch_Address_Register(5,32) );  calculated_EA=calculated_EA+increment_size; }  // A5
    if ( (0x4000&reg_list)!=0)  { Writeback_EA(calculated_EA , ea_type , Fetch_Address_Register(6,32) );  calculated_EA=calculated_EA+increment_size; }  // A6
    if ( (0x8000&reg_list)!=0)  { Writeback_EA(calculated_EA , ea_type , Fetch_Address_Register(7,32) );  calculated_EA=calculated_EA+increment_size; }  // A7
  }
  return; 
}


// ----------------------------------------------------------------------
void op_TAS()
{                   
  data_size     = 8;                                                               
  calculated_EA = Calculate_EA(0x2FE0);                                                         // Calculate the EA, checking supported modes

 // BIU_RMW(TRUE);                                                                                // Signal the BIU to perform an atomic R-M-W Cycle

  EA_Data = Fetch_EA(calculated_EA , ea_type);                                                  // Fetch the data
  Writeback_EA(calculated_EA , ea_type , (0x80|EA_Data));                                       // Write-back the data with bit[7] set to 1
 
  //BIU_RMW(FALSE);                                                                               // Debounce R-M-W Cycle

  mc68k_flags = ( mc68k_flags & 0xFFFC);                                                        // Always clear V, C Flags
  Calculate_Flag_N(EA_Data);                                                                    // Calculate the N Flag
  Calculate_Flag_Z(EA_Data , FALSE);                                                            // Calculate the Z Flag - Clear_only = FALSE

  return; 
}


// ----------------------------------------------------------------------
void op_TST()
{           
       
  data_size     = DATA_SIZE_TYPE_A;                                                             // Get the data size from the opcode bits[7:6]
  calculated_EA = Calculate_EA(0x2FE0);                                                         // Calculate the EA, checking supported modes

  EA_Data = Fetch_EA(calculated_EA , ea_type);                                                  // Fetch the data

  mc68k_flags = ( mc68k_flags & 0xFFFC);                                                        // Always clear V, C Flags
  Calculate_Flag_N(EA_Data);                                                                    // Calculate the N Flag
  Calculate_Flag_Z(EA_Data , FALSE);                                                            // Calculate the Z Flag - Clear_only = FALSE

  return; 
}

// op_type  0=ADD  1=SUB
// ----------------------------------------------------------------------
void Calculate_Flags_C(unsigned long long operand0 , unsigned long long operand1 , unsigned char op_type)
{
  unsigned long long carry=0;
 
  if (op_type==0)
  {
    if      (data_size==8)   {  carry  = ( ((operand0&0x000000FF)+(operand1&0x000000FF)) &  0x00000100 );  }
    else if (data_size==16)  {  carry  = ( ((operand0&0x0000FFFF)+(operand1&0x0000FFFF)) &  0x00010000 );  } 
    else if (data_size==32)  {  carry  = ( ((operand0&0xFFFFFFFF)+(operand1&0xFFFFFFFF)) & 0x100000000 );  }   
  }
  else
  {
    if      (data_size==8)   {  carry  = ( ((operand0&0x000000FF)-(operand1&0x000000FF)) &  0x00000100 );  }
    else if (data_size==16)  {  carry  = ( ((operand0&0x0000FFFF)-(operand1&0x0000FFFF)) &  0x00010000 );  } 
    else if (data_size==32)  {  carry  = ( ((operand0&0xFFFFFFFF)-(operand1&0xFFFFFFFF)) & 0x100000000 );  }   
  }
 
  if (carry!=0)   { mc68k_flags = ( mc68k_flags | 0x0001);  }                                   //Set C Flag                           
  return;
}                         
   

void Calculate_Flags_V(unsigned long operand0 , unsigned long operand1 , unsigned long result , unsigned char op_size , unsigned char op_type)
{
  unsigned char overflow=0;
 
  if      (op_size==8)    {  operand0 = (operand0&0x00000080);  operand1 = (operand1&0x00000080);  result = (result&0x00000080); }
  else if (op_size==16)   {  operand0 = (operand0&0x00008000);  operand1 = (operand1&0x00008000);  result = (result&0x00008000); }
  else if (op_size==32)   {  operand0 = (operand0&0x80000000);  operand1 = (operand1&0x80000000);  result = (result&0x80000000); }
   
  if (op_type==0 )
  {
    if      (operand0==0 && operand1==0 && result!=0)   { overflow=1;   }      //Set V Flag for ADD
    else if (operand0!=0 && operand1!=0 && result==0)   { overflow=1;   }       
  }
  else
  {
    if      (operand0==0 && operand1!=0 && result!=0)   {  overflow=1;   }      //Set V Flag for SUB
    else if (operand0!=0 && operand1==0 && result==0)   {  overflow=1;   } 
  }
 
  if  (overflow==1) {  mc68k_flags = ( mc68k_flags | 0x0002);  }        // Set V Flag
  else              {  mc68k_flags = ( mc68k_flags & 0xFFFD);  }          // Clear V Flag
 

  return;
}                         
   
                             
   
// op_type  1=NOT  2=NEG  3=NEGX  4=CLR
// ----------------------------------------------------------------------
void op_NEGS(unsigned char op_type)
{                   
 
  data_size     = DATA_SIZE_TYPE_A;                                                             // Get the data size from the opcode bits[7:6]
  calculated_EA = Calculate_EA(0x2FE0);                                                         // Calculate the EA, checking supported modes
  mc68k_flags = ( mc68k_flags & 0xFFFC);                                                        // Pre-clear V, C Flags

  EA_Data = Fetch_EA(calculated_EA , ea_type);                                                  // Fetch the data

  if (op_type==1) { EA_Data=(~EA_Data);                                                         // NOT                 
                    Calculate_Flag_Z(EA_Data , FALSE);
                  } else   
                     
  if (op_type==2) { Calculate_Flags_C(0 , EA_Data , 1);                                         // NEG
                    Calculate_Flags_V(0 , EA_Data , -EA_Data , data_size , 1);
                    EA_Data= -EA_Data;                                           
                    Calculate_Flag_Z(EA_Data , FALSE);
                    if (EA_Data==0) { mc68k_flags=(mc68k_flags & 0xFFEE); } else                // Set/Clear X and C Flags
                                    { mc68k_flags=(mc68k_flags | 0x0011); }                 
                  } else
                     
  if (op_type==3) { Calculate_Flags_C(0 , EA_Data , 1);                                         // NEGX   ** Z Flag - Clear_only = TRUE
                    Calculate_Flags_V(0 , EA_Data , (0-EA_Data) , data_size , 1);
                    EA_Data= -EA_Data;                                   
                    Calculate_Flags_C(EA_Data , mc68k_flag_X , 1);                                   
                    Calculate_Flags_V(EA_Data , mc68k_flag_X , (EA_Data+mc68k_flag_X) , data_size , 1);
                    EA_Data=(EA_Data - mc68k_flag_X);
                    Calculate_Flag_Z(EA_Data , TRUE);
                    if (mc68k_flag_C != 0)  { mc68k_flags=(mc68k_flags | 0x0010);  } else       // Copy C flag to X flag
                                            { mc68k_flags=(mc68k_flags & 0xFFEF);  }
                  } else   
                     
  if (op_type==4) { EA_Data=(0x0);                                                              // CLR                       
                    Calculate_Flag_Z(EA_Data , FALSE);
                  }
                 
  Writeback_EA(calculated_EA,ea_type,EA_Data); 
 
  Calculate_Flag_N(EA_Data);   
  return; 
}


// ----------------------------------------------------------------------
void op_EXG()
{       
  unsigned char regX;
  unsigned char regY;
  unsigned long tempX;
  unsigned long tempY;
 
  clock_counter=clock_counter+2;
  
  regX = (0x0E00&first_opcode)>>9;                                                              // Isolate register numbers from the opcode
  regY = (0x0007&first_opcode);                                                     
 
  if ( (0x01F8&first_opcode) == 0x0140)       {  tempX = Fetch_Data_Register(regX,32);             // Exchange the registers
                                                 tempY = Fetch_Data_Register(regY,32);
                                                 Store_Data_Register(regX , tempY , 32);
                                                 Store_Data_Register(regY , tempX , 32);
                                              }
  else if ( (0x01F8&first_opcode) == 0x0148)  {  tempX = Fetch_Address_Register(regX,32);
                                                 tempY = Fetch_Address_Register(regY,32);
                                                 Store_Address_Register(regX , tempY , 32);
                                                 Store_Address_Register(regY , tempX , 32);
                                              }
  else if ( (0x01F8&first_opcode) == 0x0188)  {  tempX = Fetch_Data_Register(regX,32);
                                                 tempY = Fetch_Address_Register(regY,32);
                                                 Store_Data_Register(regX , tempY , 32);
                                                 Store_Address_Register(regY , tempX , 32);
                                              }
  return; 
}


// op_type  00=BSET_Dynamic  10=BCLR_Dynamic  20=BCHG_Dynamic  30=BTST_Dynamic
//          01=BSET_Static   11=BCLR_Static   21=BCHG_Static   31=BTST_Static
// ------------------------------------------------------------------------------
void op_BMOD(unsigned char op_type)
{       
  unsigned long bit_num;
  
  clock_counter=clock_counter+4;
   
  if ( (0x0F&op_type)==0x0)                                                                     // ** Bit-number Dynamic **
  {
    reg_num = (0x0E00&first_opcode)>>9;                                                         // Isolate the register number from the opcode
   
    data_size = 8;    // Force EA Calculation to use BYTE mode so pre-decrement and post-increment address modifications as well as immediate fetching are correct
    if ((0xF0&op_type)==0x30)  calculated_EA = Calculate_EA(0x2FFC); else calculated_EA = Calculate_EA(0x2FE0);  //  BTST allowed EA types different from rest
 
    if (ea_type==MEMORY) { bit_num = (0x7&Fetch_Data_Register(reg_num,8));                      // Isolate a byte's worth of bit addressing
                           EA_Data = (0xFF&Fetch_EA(calculated_EA , ea_type));                  // Fetch the byte data from the Memory EA
                         }
    else                 { bit_num = (0x1F&Fetch_Data_Register(reg_num,8));                     // Isolate 32-bits worth of bit addressing
                           data_size = 32;                                                      // Force data size to 32-bit for non-memory locations
                           clock_counter=clock_counter+2;
               EA_Data = (Fetch_EA(calculated_EA , ea_type));                       // Fetch the register or immediate data
                         }
  }

  else                                                                                          // ** Bit-number Static **
  {
    bit_num = Fetch_Immediate(8);                                                               // Fetch the Bit Number field first
   
    data_size = 8;    // Force EA Calculation to use BYTE mode so pre-decrement and post-increment address modifications as well as immediate fetching are correct
    if ((0xF0&op_type)==0x30)  calculated_EA = Calculate_EA(0x2FF8); else calculated_EA = Calculate_EA(0x2FE0);  // BTST allowed EA types different from rest
 
    if (ea_type==MEMORY) { bit_num = (0x7&bit_num);                                             // Isolate a byte's worth of bit addressing from the second opcode
                           EA_Data = (0xFF&Fetch_EA(calculated_EA , ea_type));                  // Fetch the byte data from the Memory EA
                         }
    else                 { bit_num = (0x1F&bit_num);                                            // Isolate 32-bits worth of bit addressing from the second opcode
                           data_size = 32;                                                      // Force data size to 32-bit for non-memory locations
                           clock_counter=clock_counter+2;
               EA_Data = (Fetch_EA(calculated_EA , ea_type));                       // Fetch the register or immediate data
                           
                         }
  }
                         
  bit_num = 0x1<<bit_num;                                                                       // Convert encoded bit number to a one-bit-active vector
  if ( (EA_Data & bit_num) == 0) {  mc68k_flags = ( mc68k_flags | 0x0004);  }                   // Calculate Z Flag
  else                           {  mc68k_flags = ( mc68k_flags & 0xFFFB);  }
 
 
  if ( (0xF0&op_type)==0x00) { EA_Data = (EA_Data | bit_num);  Writeback_EA(calculated_EA , ea_type , EA_Data); } else      // BSET - Set the selected bit in the EA's Data
  if ( (0xF0&op_type)==0x10) { EA_Data = (EA_Data & ~bit_num); Writeback_EA(calculated_EA , ea_type , EA_Data); } else      // BCLR - Clear the selected bit in the EA's Data
  if ( (0xF0&op_type)==0x20) { EA_Data = (EA_Data ^ bit_num);  Writeback_EA(calculated_EA , ea_type , EA_Data); }           // BCHG - Change the selected bit in the EA's Data
   
  return; 
}


// op_type   1=ASL  2=LSL
// ----------------------------------------------------------------------
void op_xSL(unsigned char dst_is_register , unsigned char op_type)
{       
  unsigned long data;
  unsigned char shift_count;
 
  mc68k_flags=(mc68k_flags&0xFFFD);                                                             // Pre-clear the V flag
 
  if (dst_is_register==1) { if (data_size==32) {clock_counter=clock_counter+4;} else {clock_counter=clock_counter+2;}
                            data_size  = DATA_SIZE_TYPE_A;                                      // Get the data size from the opcode bits[7:6]
                            immediate = (0x0E00&first_opcode)>>9;                               // Isolate the Immediate number from the opcode
                            reg_num   = (0x0007&first_opcode);                                  // Isolate the register number from the opcode
                            data = Fetch_Data_Register(reg_num,data_size);                      // Fetch the register we want to shift
                            if ((0x0020&first_opcode) == 0)   //   T=0 for Immediate field contains the shift_count   T=1 for shift_count contained in a register - Modulo-64
                              {  if(immediate==0)  shift_count=8; else shift_count = immediate;
                              }     
                            else
                              { shift_count = (0x3F&Fetch_Data_Register(immediate,8));
                              }
                          }                             
                             
  else                    { clock_counter=clock_counter-2;
                            data_size  = 16;                                                    // Size is always 16 for memory
                            shift_count = 1;                                                    // Shift count is always 1 for memory
                            calculated_EA = Calculate_EA(0x0FE0);                               // Calculate the EA, checking supported modes
                            data = (Fetch_EA(calculated_EA , ea_type));                         // Fetch the word data we want to shift from the EA
                          }

  while (shift_count!=0)
  {
    clock_counter=clock_counter+2;
  if (data_size==8)  { if( (0x00000080&data)==0) mc68k_flags=(mc68k_flags&0xFFEE); else mc68k_flags=(mc68k_flags|0x0011); }       // Copy data[MSB] to the X and C flags
    if (data_size==16) { if( (0x00008000&data)==0) mc68k_flags=(mc68k_flags&0xFFEE); else mc68k_flags=(mc68k_flags|0x0011); }   
    if (data_size==32) { if( (0x80000000&data)==0) mc68k_flags=(mc68k_flags&0xFFEE); else mc68k_flags=(mc68k_flags|0x0011); }   
   
    if (data_size==8)  { if( (0x000000C0&data)==0x00000080 || (0x000000C0&data)==0x00000040 ) mc68k_flags=(mc68k_flags|0x0002); }   //  Set V if the MSB ever changes
    if (data_size==16) { if( (0x0000C000&data)==0x00008000 || (0x0000C000&data)==0x00004000 ) mc68k_flags=(mc68k_flags|0x0002); }   
    if (data_size==32) { if( (0xC0000000&data)==0x80000000 || (0xC0000000&data)==0x40000000 ) mc68k_flags=(mc68k_flags|0x0002); }   

    data = data << 1;                                                                           // Shift data to the left by one bit
    shift_count--;                                                                              // Decrement the shift_counter
  }     

  if (dst_is_register==1) { Store_Data_Register(reg_num , data , data_size);  }                 // Write-back the results to the register
  else                    { Writeback_EA(calculated_EA , ea_type , data);     }                 // Write-back the results to the EA
 
  Calculate_Flag_Z(data , FALSE);                                                               // Calculate the Z Flag - Clear_only = FALSE
  Calculate_Flag_N(data);                                                                       // Calculate the N Flag
  if (op_type==2) { mc68k_flags=(mc68k_flags&0xFFFD);  }                                        // Always clear the V flag for LSL
  return;
}
                   

// ----------------------------------------------------------------------
void op_ROL(unsigned char dst_is_register)
{       
  unsigned long data;
  unsigned char shift_count;
 
  if (dst_is_register==1) { if (data_size==32) {clock_counter=clock_counter+4;} else {clock_counter=clock_counter+2;}
                            data_size  = DATA_SIZE_TYPE_A;                                      // Get the data size from the opcode bits[7:6]
                            immediate = (0x0E00&first_opcode)>>9;                               // Isolate the Immediate number from the opcode
                            reg_num   = (0x0007&first_opcode);                                  // Isolate the register number from the opcode
                            data = Fetch_Data_Register(reg_num,data_size);                      // Fetch the register we want to shift
                            if ((0x0020&first_opcode) == 0)   //   T=0 for Immediate field contains the shift_count   T=1 for shift_count contained in a register - Modulo-64
                              {  if(immediate==0)  shift_count=8; else shift_count = immediate;
                              }     
                            else
                              { shift_count = (0x3F&Fetch_Data_Register(immediate,8));
                              }
                            }   
  else                    { clock_counter=clock_counter-2;
                            data_size  = 16;
                            calculated_EA = Calculate_EA(0x0FE0);                               // Calculate the EA, checking supported modes
                            data = (Fetch_EA(calculated_EA , ea_type));                         // Fetch the word data we want to shift from the EA
                            shift_count = 1;
                          }
 

  while (shift_count!=0)
  {
    clock_counter=clock_counter+2;
  if (data_size==8)  { if( (0x00000080&data)==0) mc68k_flags=(mc68k_flags&0xFFFE); else mc68k_flags=(mc68k_flags|0x0001); }   // Copy data[MSB] to the C flag
    if (data_size==16) { if( (0x00008000&data)==0) mc68k_flags=(mc68k_flags&0xFFFE); else mc68k_flags=(mc68k_flags|0x0001); }   
    if (data_size==32) { if( (0x80000000&data)==0) mc68k_flags=(mc68k_flags&0xFFFE); else mc68k_flags=(mc68k_flags|0x0001); }   

    data = data << 1;                                                                           // Shift data to the left by one bit
    data = ( (mc68k_flags&0x0001) | data );                                                     // Or the Carry Flag into bit[0] of the new data                                   
    shift_count--;                                                                              // Decrement the shift_counter
  }     

  if (dst_is_register==1) { Store_Data_Register(reg_num , data , data_size);  }                 // Write-back the results to the register
  else                    { Writeback_EA(calculated_EA , ea_type , data);     }                 // Write-back the results to the EA
  mc68k_flags=(mc68k_flags&0xFFFD);                                                             // Always clear the V flag
  Calculate_Flag_Z(data , FALSE);                                                               // Calculate the Z Flag - Clear_only = FALSE
  Calculate_Flag_N(data);                                                                       // Calculate the N Flag
  return;
}
                       

// ----------------------------------------------------------------------
void op_ROXL(unsigned char dst_is_register)
{       
  unsigned long data;
  unsigned int old_X_Flag;
  unsigned char shift_count;
 
  if (dst_is_register==1) { if (data_size==32) {clock_counter=clock_counter+4;} else {clock_counter=clock_counter+2;}
                            data_size  = DATA_SIZE_TYPE_A;                                      // Get the data size from the opcode bits[7:6]
                            immediate = (0x0E00&first_opcode)>>9;                               // Isolate the Immediate number from the opcode
                            reg_num   = (0x0007&first_opcode);                                  // Isolate the register number from the opcode
                            data = Fetch_Data_Register(reg_num,data_size);                                // Fetch the register we want to shift
                            if ((0x0020&first_opcode) == 0)   //   T=0 for Immediate field contains the shift_count   T=1 for shift_count contained in a register - Modulo-64
                              {  if(immediate==0)  shift_count=8; else shift_count = immediate;
                              }     
                            else
                              { shift_count = (0x3F&Fetch_Data_Register(immediate,8));
                              }
                            }   
  else                    { clock_counter=clock_counter-2;
                            data_size  = 16;
                            calculated_EA = Calculate_EA(0x0FE0);                               // Calculate the EA, checking supported modes
                            data = (Fetch_EA(calculated_EA , ea_type));                         // Fetch the word data we want to shift from the EA
                            shift_count = 1;
                          }
 

  while (shift_count!=0)
  {
  clock_counter=clock_counter+2;
    old_X_Flag = mc68k_flag_X;
    if (data_size==8)  { if( (0x00000080&data)==0) mc68k_flags=(mc68k_flags&0xFFEE); else mc68k_flags=(mc68k_flags|0x0011); }   // Copy data[MSB] to the X and C flags
    if (data_size==16) { if( (0x00008000&data)==0) mc68k_flags=(mc68k_flags&0xFFEE); else mc68k_flags=(mc68k_flags|0x0011); }   
    if (data_size==32) { if( (0x80000000&data)==0) mc68k_flags=(mc68k_flags&0xFFEE); else mc68k_flags=(mc68k_flags|0x0011); }   

    data = data << 1;                                                                           // Shift data to the left by one bit
    data = (old_X_Flag | data);                                                                 // Or the original  X Flag into bit[0] of the new data                                 
    shift_count--;                                                                              // Decrement the shift_counter
  }     

  if (dst_is_register==1) { Store_Data_Register(reg_num , data , data_size);  }                 // Write-back the results to the register
  else                    { Writeback_EA(calculated_EA , ea_type , data);     }                 // Write-back the results to the EA
  mc68k_flags=(mc68k_flags&0xFFFD);                                                             // Always clear the V flag
  Calculate_Flag_Z(data , FALSE);                                                               // Calculate the Z Flag - Clear_only = FALSE
  Calculate_Flag_N(data);                                                                       // Calculate the N Flag
  return;
}
                   


// op_type  1=ASR  2=LSR
// ----------------------------------------------------------------------
void op_xSR(unsigned char op_type , unsigned char dst_is_register)
{       
  unsigned long data;
  unsigned char shift_count;
 
  mc68k_flags=(mc68k_flags&0xFFFD);                                                             // Pre-clear the V flag
 
  if (dst_is_register==1) { if (data_size==32) {clock_counter=clock_counter+4;} else {clock_counter=clock_counter+2;}
                            data_size  = DATA_SIZE_TYPE_A;                                      // Get the data size from the opcode bits[7:6]
                            immediate = (0x0E00&first_opcode)>>9;                               // Isolate the Immediate number from the opcode
                            reg_num   = (0x0007&first_opcode);                                  // Isolate the register number from the opcode
                            data = Fetch_Data_Register(reg_num,data_size);                                // Fetch the register we want to shift
                            if ((0x0020&first_opcode) == 0)   //   T=0 for Immediate field contains the shift_count   T=1 for shift_count contained in a register - Modulo-64
                              {  if(immediate==0)  shift_count=8; else shift_count = immediate;
                              }     
                            else
                              { shift_count = (0x3F&Fetch_Data_Register(immediate,8));
                              }
                            }   
  else                    { clock_counter=clock_counter-2;
                            data_size  = 16;
                            calculated_EA = Calculate_EA(0x0FE0);                               // Calculate the EA, checking supported modes
                            data = (Fetch_EA(calculated_EA , ea_type));                         // Fetch the word data we want to shift from the EA
                            shift_count = 1;
                          }
 

  while (shift_count!=0)
  { 
    clock_counter=clock_counter+2;
  if( (0x1&data)==0) mc68k_flags=(mc68k_flags&0xFFEE); else mc68k_flags=(mc68k_flags|0x0011);                             // Copy  current data[0] to the X and C flags

    if (data_size==8)  { data = (0x000000FF&data)>>1;  if (op_type==1 && (0x00000040&data)!=0) data=(0x00000080|data);  }   // Shift right.
    if (data_size==16) { data = (0x0000FFFF&data)>>1;  if (op_type==1 && (0x00004000&data)!=0) data=(0x00008000|data);  }   //  For ASR: Copy old MSBit to new MSbit
    if (data_size==32) { data = data >> 1;             if (op_type==1 && (0x40000000&data)!=0) data=(0x80000000|data);  }

    shift_count--;                                                                                                          // Decrement the shift_counter
  }     

  if (dst_is_register==1) { Store_Data_Register(reg_num , data , data_size);  }                 // Write-back the results to the register
  else                    { Writeback_EA(calculated_EA , ea_type , data);     }                 // Write-back the results to the EA
  Calculate_Flag_Z(data , FALSE);                                                               // Calculate the Z Flag - Clear_only = FALSE
  Calculate_Flag_N(data);                                                                       // Calculate the N Flag
  return; 
}
   
   
// ----------------------------------------------------------------------
void op_ROR(unsigned char dst_is_register)
{       
  unsigned long data;
  unsigned char shift_count;
 
  if (dst_is_register==1) { if (data_size==32) {clock_counter=clock_counter+4;} else {clock_counter=clock_counter+2;}
                            data_size  = DATA_SIZE_TYPE_A;                                      // Get the data size from the opcode bits[7:6]
                            immediate = (0x0E00&first_opcode)>>9;                               // Isolate the Immediate number from the opcode
                            reg_num   = (0x0007&first_opcode);                                  // Isolate the register number from the opcode
                            data = Fetch_Data_Register(reg_num,data_size);                      // Fetch the register we want to shift
                            if ((0x0020&first_opcode) == 0)   //   T=0 for Immediate field contains the shift_count   T=1 for shift_count contained in a register - Modulo-64
                              {  if(immediate==0)  shift_count=8; else shift_count = immediate;
                              }     
                            else
                              { shift_count = (0x3F&Fetch_Data_Register(immediate,8));
                              }
                            }   
  else                    { clock_counter=clock_counter-2;
                            data_size  = 16;
                            calculated_EA = Calculate_EA(0x0FE0);                               // Calculate the EA, checking supported modes
                            data = (Fetch_EA(calculated_EA , ea_type));                         // Fetch the word data we want to shift from the EA
                            shift_count = 1;
                          }
 

  while (shift_count!=0)
  {
    clock_counter=clock_counter+2;
  if( (0x1&data)==0) mc68k_flags=(mc68k_flags&0xFFFE); else mc68k_flags=(mc68k_flags|0x0001); // Copy data[0] to the C flag
           
    data = data >> 1;
    if (data_size==8)  { if (mc68k_flag_C==1) data=(0x00000080 | data); else  data=(0xFFFFFF7F & data); }    // Shift right. Copy data[0] to the MSbit
    if (data_size==16) { if (mc68k_flag_C==1) data=(0x00008000 | data); else  data=(0xFFFF7FFF & data); }
    if (data_size==32) { if (mc68k_flag_C==1) data=(0x80000000 | data); else  data=(0x7FFFFFFF & data); }

    shift_count--;                                                                              // Decrement the shift_counter
  }     

  if (dst_is_register==1) { Store_Data_Register(reg_num , data , data_size);  }                 // Write-back the results to the register
  else                    { Writeback_EA(calculated_EA , ea_type , data);     }                 // Write-back the results to the EA
  mc68k_flags=(mc68k_flags&0xFFFD);                                                             // Always clear the V flag
  Calculate_Flag_Z(data , FALSE);                                                               // Calculate the Z Flag - Clear_only = FALSE
  Calculate_Flag_N(data);                                                                       // Calculate the N Flag
  return;
}
               
   
// ----------------------------------------------------------------------
void op_ROXR(unsigned char dst_is_register)
{       
  unsigned long data;
  unsigned int old_X_Flag;
  unsigned char shift_count;
  
 
  if (dst_is_register==1) { if (data_size==32) {clock_counter=clock_counter+4;} else {clock_counter=clock_counter+2;}
                            data_size  = DATA_SIZE_TYPE_A;                                      // Get the data size from the opcode bits[7:6]
                            immediate = (0x0E00&first_opcode)>>9;                               // Isolate the Immediate number from the opcode
                            reg_num   = (0x0007&first_opcode);                                  // Isolate the register number from the opcode
                            data = Fetch_Data_Register(reg_num,data_size);                                // Fetch the register we want to shift
                            if ((0x0020&first_opcode) == 0)   //   T=0 for Immediate field contains the shift_count   T=1 for shift_count contained in a register - Modulo-64
                              {  if(immediate==0)  shift_count=8; else shift_count = immediate;
                              }     
                            else
                              { shift_count = (0x3F&Fetch_Data_Register(immediate,8));
                              }
                            }   
  else                    { clock_counter=clock_counter-2;
                            data_size  = 16;
                            calculated_EA = Calculate_EA(0x0FE0);                               // Calculate the EA, checking supported modes
                            data = (Fetch_EA(calculated_EA , ea_type));                         // Fetch the word data we want to shift from the EA
                            shift_count = 1;
                          }
 
  while (shift_count!=0)
  {
    clock_counter=clock_counter+2;
  old_X_Flag = mc68k_flag_X;
    if( (0x1&data)==0) mc68k_flags=(mc68k_flags&0xFFEE); else mc68k_flags=(mc68k_flags|0x0011); // Copy data[0] to the C and X flags
           
    data = data >> 1;
    if (data_size==8)  { if (old_X_Flag==1) data=(0x00000080 | data); else  data=(0xFFFFFF7F & data); } else   // Shift right. Copy X flag to the MSbit
    if (data_size==16) { if (old_X_Flag==1) data=(0x00008000 | data); else  data=(0xFFFF7FFF & data); } else
    if (data_size==32) { if (old_X_Flag==1) data=(0x80000000 | data); else  data=(0x7FFFFFFF & data); }

    shift_count--;                                                                              // Decrement the shift_counter
  }                 

  if (dst_is_register==1) { Store_Data_Register(reg_num , data , data_size);  }                 // Write-back the results to the register
  else                    { Writeback_EA(calculated_EA , ea_type , data);     }                 // Write-back the results to the EA
  mc68k_flags=(mc68k_flags&0xFFFD);                                                             // Always clear the V flag
  Calculate_Flag_Z(data , FALSE);                                                               // Calculate the Z Flag - Clear_only = FALSE
  Calculate_Flag_N(data);                                                                       // Calculate the N Flag
  return;
}
       
   
// bool_type:  1=OR  2=AND  3=EOR  4=CMP
// ----------------------------------------------------------------------
void op_BOOL(unsigned char bool_type)
{       
  unsigned long Reg_Data;
 
  data_size     = DATA_SIZE_TYPE_A;                                                             // Get the data size from the opcode bits[7:6] 
  reg_num = (0x0E00&first_opcode)>>9;
  Reg_Data = Fetch_Data_Register(reg_num,data_size);
  mc68k_flags = ( mc68k_flags & 0xFFFC);                                                        // Pre-clear V, C Flags -- Will be calculated for CMP opcode

 
  if ( (0x0100&first_opcode)==0)                                                                // EA is the source
    {
      if (bool_type==1) { calculated_EA=Calculate_EA(0x2FFC); EA_Data=Fetch_EA(calculated_EA,ea_type); result=EA_Data | Reg_Data;  Store_Data_Register(reg_num,result,data_size); } else   
      if (bool_type==2) { calculated_EA=Calculate_EA(0x2FFC); EA_Data=Fetch_EA(calculated_EA,ea_type); result=EA_Data & Reg_Data;  Store_Data_Register(reg_num,result,data_size); } else
      if (bool_type==4) { calculated_EA=Calculate_EA(0x3FFC); EA_Data=Fetch_EA(calculated_EA,ea_type); result=Reg_Data - EA_Data;  Calculate_Flags_C(Reg_Data , EA_Data , 1);  Calculate_Flags_V(Reg_Data , EA_Data , result , data_size , 1); }                                                     
    }
 
  else                                                                                          // Register is the source
    {
      if (bool_type==1) { calculated_EA=Calculate_EA(0x0FE0); EA_Data=Fetch_EA(calculated_EA,ea_type); result = EA_Data | Reg_Data;  Writeback_EA(calculated_EA , ea_type , result); }  else   
      if (bool_type==2) { calculated_EA=Calculate_EA(0x0FE0); EA_Data=Fetch_EA(calculated_EA,ea_type); result = EA_Data & Reg_Data;  Writeback_EA(calculated_EA , ea_type , result); }  else
      if (bool_type==3) { calculated_EA=Calculate_EA(0x2FE0); EA_Data=Fetch_EA(calculated_EA,ea_type); result = EA_Data ^ Reg_Data;  Writeback_EA(calculated_EA , ea_type , result); } 
    }   
 
  Calculate_Flag_N(result);                                                                     // Calculate the N Flag
  Calculate_Flag_Z(result , FALSE);                                                             // Calculate the Z Flag - Clear_only = FALSE

  return; 
}

                             
// bool_type:  1=ORI  2=ANDI  3=EORI  4=CMPI
// ----------------------------------------------------------------------
void op_BOOL_I(unsigned char bool_type)
{
  data_size     = DATA_SIZE_TYPE_A;                                                             // Get the data size from the opcode bits[7:6]
  immediate     = Fetch_Immediate(data_size);                                                   // Fetch the immediate operand of the correct data size
  
  if (data_size==32) clock_counter=clock_counter+3;

  calculated_EA = Calculate_EA(0x2FE3);                                                         // Calculate the EA, checking supported modes
  mc68k_flags = ( mc68k_flags & 0xFFFC);                                                        // Pre-clear V, C Flags
 
  EA_Data = Fetch_EA(calculated_EA , ea_type);                                                  // Fetch the EA operand
   
  // Perform the operation then write-back the result to the EA
  if (bool_type==1) { result = EA_Data | immediate;  Writeback_EA(calculated_EA , ea_type , result); }  else   
  if (bool_type==2) { result = EA_Data & immediate;  Writeback_EA(calculated_EA , ea_type , result); }  else
  if (bool_type==3) { result = EA_Data ^ immediate;  Writeback_EA(calculated_EA , ea_type , result); }  else
  if (bool_type==4) { result = EA_Data - immediate;  Calculate_Flags_C(EA_Data , immediate , 1); Calculate_Flags_V(EA_Data , immediate , result , data_size , 1);     }  // Calculate the V and C Flags for CMPI
  Calculate_Flag_N(result);                                                                     // Calculate the N Flag
  Calculate_Flag_Z(result , FALSE);                                                             // Calculate the Z Flag - Clear_only = FALSE
 
  return;
}


// ----------------------------------------------------------------------
void op_CMPA()
{   
  unsigned long Reg_Data;
  
  clock_counter=clock_counter+2;

  data_size     = DATA_SIZE_TYPE_D;                                                             // Get the data size from the opcode bits8]
  calculated_EA=Calculate_EA(0x3FFC);                                                           // Calculate the EA, checking supported modes
  EA_Data=Fetch_EA(calculated_EA,ea_type);                                                      // Fetch the EA data
 
  reg_num = (0x0E00&first_opcode)>>9;                                                           // Isolate the register number from the opcode
  Reg_Data = Fetch_Address_Register(reg_num,32);                                                // Fetch the Address Register data

  if (data_size==16) { EA_Data=Sign_Extend(EA_Data,16);  }                                      // Sign extend source operand for word
 
  result = Reg_Data - EA_Data ;   
 
  data_size     = 32;                                                                           // Force the size to 32-bit for flag calculations
  mc68k_flags = ( mc68k_flags & 0xFFFC);                                                        // Pre-clear V, C Flags
  Calculate_Flags_C(Reg_Data , EA_Data , 1);
  Calculate_Flags_V(Reg_Data , EA_Data , result , data_size , 1);                                                       // Calculate the V and C Flags
  Calculate_Flag_N(result);                                                                     // Calculate the N Flag
  Calculate_Flag_Z(result , FALSE);                                                             // Calculate the Z Flag - Clear_only = FALSE
  return; 
}


// ----------------------------------------------------------------------
void op_CMPM()
{   
  unsigned char regX;
  unsigned char regY;
  unsigned long AddrX;
  unsigned long AddrY; 
  unsigned long DataX;
  unsigned long DataY;
 
  clock_counter=clock_counter+2;
 
  data_size     = DATA_SIZE_TYPE_A;                                                             // Get the data size from the opcode bits[7:6] 
 
  regX = (0x0E00&first_opcode)>>9;                                                              // Isolate the register X number from the opcode
  regY = (0x0007&first_opcode);                                                                 // Isolate the register Y number from the opcode
 
 
  AddrX = Fetch_Address_Register(regX,32);                                                      // Fetch Address Register X data
  AddrY = Fetch_Address_Register(regY,32);                                                      // Fetch Address Register Y data
   
  if (data_size==8)  {  Store_Address_Register(regX,AddrX+0x1,32);   Store_Address_Register(regY,AddrY+0x1,32);  }      // Post-increment both addresses  (An)+
  if (data_size==16) {  Store_Address_Register(regX,AddrX+0x2,32);   Store_Address_Register(regY,AddrY+0x2,32);  }                 
  if (data_size==32) {  Store_Address_Register(regX,AddrX+0x4,32);   Store_Address_Register(regY,AddrY+0x4,32);  }     


  if (data_size==32) { DataX=BIU_Read_32(AddrX);        DataY=BIU_Read_32(AddrY);         }     // Fetch data from both addresses
  else               { DataX=BIU_Read(AddrX,data_size); DataY=BIU_Read(AddrY,data_size);  }

  result = DataX - DataY ;                                                     

  Calculate_Flag_N(result);                                                                     // Calculate the N Flag
  Calculate_Flag_Z(result , FALSE);                                                             // Calculate the Z Flag - Clear_only = FALSE
  mc68k_flags = ( mc68k_flags & 0xFFFC);                                                        // Pre-clear V, C Flags
  Calculate_Flags_C(DataX , DataY , 1);
  Calculate_Flags_V(DataX , DataY , result , data_size , 1);                                    // Calculate the V and C Flags
  return; 
}


// math_type  0=SUB   1=ADD
// ----------------------------------------------------------------------
void op_ADDSUB(unsigned char math_type)
{       
  signed long long Reg_Data;

  if ( (0x0100&first_opcode)==0)                                                                // ** EA is the source **
  {
    data_size     = DATA_SIZE_TYPE_A;                                                           // Get the data size from the opcode bits[7:6]
    calculated_EA = Calculate_EA(0x3FFF);                                                       // Calculate the EA, checking supported modes
    EA_Data       = Fetch_EA(calculated_EA , ea_type);                                          // Fetch the EA data
    mc68k_flags = ( mc68k_flags & 0xFFFC);                                                      // Pre-clear V, C Flags

    reg_num = (0x0E00&first_opcode)>>9;                                                         // Isolate the register number from the opcode
    Reg_Data = Fetch_Data_Register(reg_num,data_size);                                          // Fetch the Register data
   
    if (math_type==0) { result = Reg_Data - EA_Data;  Calculate_Flags_C(Reg_Data , EA_Data , 1);  Calculate_Flags_V(Reg_Data , EA_Data , result , data_size , 1);  } // Calculate the results and the C,V Flags
    if (math_type==1) { result = Reg_Data + EA_Data;  Calculate_Flags_C(Reg_Data , EA_Data , 0);  Calculate_Flags_V(Reg_Data , EA_Data , result , data_size , 0);  }

    Store_Data_Register(reg_num,result,data_size);                                              // Write-back the results to the Data Register
  }
 
  else                                                                                          // ** Register is the source **
  {
    data_size     = DATA_SIZE_TYPE_A;                                                           // Get the data size from the opcode bits[7:6]
    calculated_EA = Calculate_EA(0x0FE0);                                                       // Calculate the EA, checking supported modes
    EA_Data       = Fetch_EA(calculated_EA , ea_type);                                          // Fetch the EA data
   
    reg_num = (0x0E00&first_opcode)>>9;                                                         // Isolate the register number from the opcode
    Reg_Data = Fetch_Data_Register(reg_num,data_size);                                          // Fetch the Register data
   
    if (math_type==0) { result = EA_Data - Reg_Data;   Calculate_Flags_C(EA_Data , Reg_Data , 1); Calculate_Flags_V(EA_Data , Reg_Data , result , data_size , 1);  } // Calculate the results and the C,V Flags
    if (math_type==1) { result = EA_Data + Reg_Data;   Calculate_Flags_C(EA_Data , Reg_Data , 0); Calculate_Flags_V(EA_Data , Reg_Data , result , data_size , 0);  }                                   

    Writeback_EA(calculated_EA , ea_type , result);                                             // Write-back the results to the EA
  } 
 
  Calculate_Flag_N(result);                                                                     // Calculate the N Flag
  Calculate_Flag_Z(result , FALSE);                                                             // Calculate the Z Flag - Clear_only = FALSE
  if (mc68k_flag_C != 0)  { mc68k_flags=(mc68k_flags | 0x0010);  }                              // Copy C flag to X flag
  else                    { mc68k_flags=(mc68k_flags & 0xFFEF);  }
 

  return; 
}


// math_type  0=SUB   1=ADD
// ----------------------------------------------------------------------
void op_ADDSUBA(unsigned char math_type)
{       
  unsigned long Reg_Data;
  unsigned long result=0;


  data_size     = DATA_SIZE_TYPE_D;                                                             // Get the data size from the opcode bit[8]
  calculated_EA = Calculate_EA(0x3FFC);                                                         // Calculate the EA, checking supported modes
  EA_Data       = Fetch_EA(calculated_EA , ea_type);                                            // Fetch the EA data
   
  reg_num = (0x0E00&first_opcode)>>9;                                                           // Isolate the register number from the opcode
  Reg_Data = Fetch_Address_Register(reg_num,data_size);                                         // Fetch the Register data
   
  if (math_type==0) result = Reg_Data - EA_Data;                                                // Calculate the results
  if (math_type==1) result = Reg_Data + EA_Data;       
     
  Store_Address_Register(reg_num,result,32);                                                    // Write-back the results to the 32-bits of the Address Register
  return; 
}


// math_type  0=SUB   1=ADD
// ----------------------------------------------------------------------
void op_ADDSUBI(unsigned char math_type)
{       
  unsigned long result=0;
 
  data_size     = DATA_SIZE_TYPE_A;                                                             // Get the data size from the opcode bits[7:6]
  immediate     = Fetch_Immediate(data_size);                                                   // Fetch the immediate operand of the correct data size
  
  if (data_size==32) clock_counter=clock_counter+4;

  calculated_EA = Calculate_EA(0x2FE0);                                                         // Calculate the EA, checking supported modes
  EA_Data       = Fetch_EA(calculated_EA , ea_type);                                            // Fetch the EA data
  mc68k_flags = ( mc68k_flags & 0xFFFC);                                                        // Pre-clear V, C Flags

 
  if (math_type==0) { result = EA_Data - immediate; Calculate_Flags_C(EA_Data , immediate , 1);  Calculate_Flags_V(EA_Data , immediate , result , data_size , 1);  }  // Calculate the results and the C,V Flags
  if (math_type==1) { result = EA_Data + immediate; Calculate_Flags_C(EA_Data , immediate , 0);  Calculate_Flags_V(EA_Data , immediate , result , data_size , 0);  }                                   
     
  Writeback_EA(calculated_EA , ea_type , result);                                               // Write-back the results to the EA

  Calculate_Flag_N(result);                                                                     // Calculate the N Flag
  Calculate_Flag_Z(result , FALSE);                                                             // Calculate the Z Flag - Clear_only = FALSE
  if (mc68k_flag_C != 0)  { mc68k_flags=(mc68k_flags | 0x0010);  }                              // Copy C flag to X flag
  else                    { mc68k_flags=(mc68k_flags & 0xFFEF);  }
 
  return; 
}


// math_type  0=SUB   1=ADD
// ----------------------------------------------------------------------
void op_ADDSUBQ(unsigned char math_type)
{       
  unsigned long long result=0;
  unsigned long opcode_data;

  data_size     = DATA_SIZE_TYPE_A;                                                             // Get the data size from the opcode bits[7:6]
  calculated_EA = Calculate_EA(0x3FE0);                                                         // Calculate the EA, checking supported modes
  EA_Data       = Fetch_EA(calculated_EA , ea_type);                                            // Fetch the EA data

  opcode_data = (0x0E00&first_opcode)>>9;                                                       // Isolate the immediate "Q" data from the opcode
  if (opcode_data==0) opcode_data=8;

  if (math_type==0) { result = EA_Data - opcode_data;  }                      // Calculate the results 
  if (math_type==1) { result = EA_Data + opcode_data;  }                                   
   
  Writeback_EA(calculated_EA , ea_type , result);                                               // Write-back the results to the EA
 
  if (ea_type != ADDRESS_REG)                                                                   // Don't set flags if destination is an Address register
  { 
    mc68k_flags = ( mc68k_flags & 0xFFFC);                                                        // Pre-clear V, C Flags
    if (math_type==0) { Calculate_Flags_C(EA_Data , opcode_data , 1); Calculate_Flags_V(EA_Data , opcode_data , result , data_size , 1 );    }   
    if (math_type==1) { Calculate_Flags_C(EA_Data , opcode_data , 0); Calculate_Flags_V(EA_Data , opcode_data , result , data_size , 0 );    }                                   
    Calculate_Flag_N(result);                                                                   // Calculate the N Flag
    Calculate_Flag_Z(result , FALSE);                                                           // Calculate the Z Flag - Clear_only = FALSE
    if (mc68k_flag_C != 0)  { mc68k_flags=(mc68k_flags | 0x0010);  }                            // Copy C flag to X flag
    else                    { mc68k_flags=(mc68k_flags & 0xFFEF);  }
  }
  else
  {
    clock_counter=clock_counter+4;
  }
 
  return; 
}


// math_type  0=SUBX   1=ADDX
// ----------------------------------------------------------------------
void op_ADDSUBX(unsigned char math_type)
{       
  unsigned char regX;
  unsigned char regY;
  unsigned long AddrX;
  unsigned long AddrY; 
  unsigned long DataX;
  unsigned long DataY;
  unsigned long long result=0;
 
  data_size     = DATA_SIZE_TYPE_A;                                                             // Get the data size from the opcode bits[7:6]
   
  regX = (0x0E00&first_opcode)>>9;                                                              // Isolate the register X number from the opcode
  regY = (0x0007&first_opcode);                                                                 // Isolate the register Y number from the opcode
  mc68k_flags = ( mc68k_flags & 0xFFFC);                                                        // Pre-clear V, C Flags
   
 
  if ( (0x0008&first_opcode)==0)                                                                // ** Register to Register **
  {
    DataX = Fetch_Data_Register(regX,data_size);                                                // Fetch Data Register X data
    DataY = Fetch_Data_Register(regY,data_size);                                                // Fetch Data Register Y data     
     

    if (math_type==0) { Calculate_Flags_C(DataX , DataY , 1);   
                        result = DataX - DataY;                                                 // Subtract the two operands first and calculate the V,C Flags
                        Calculate_Flags_C(result , mc68k_flag_X , 1); 
                        result = result - mc68k_flag_X;     
                        Calculate_Flags_V(DataX , DataY , result , data_size , 1);                     
                      }
 
    if (math_type==1) { Calculate_Flags_C(DataX , DataY , 0);
                        result = DataX + DataY;                                                 // Add the two operands first and calculate the V,C Flags
                        Calculate_Flags_C(result , mc68k_flag_X , 0);                         
                        result = result + mc68k_flag_X;
                        Calculate_Flags_V(DataX , DataY , result , data_size , 0);                     
                      }
                   
    Store_Data_Register(regX,result,data_size);                                                 // Write-back the results to the Data Register
  }
 
  else                                                                                          // ** Memory to Memory **
  {

    clock_counter=clock_counter+2;
  AddrX = Fetch_Address_Register(regX,32);                                                    // Fetch Address Register X data
    AddrY = Fetch_Address_Register(regY,32);                                                    // Fetch Address Register Y data
   
    if (data_size==8)   {  AddrX = AddrX - 0x1;  AddrY = AddrY - 0x1;  }                        // Pre-decrement both addresses  -(An)
    if (data_size==16)  {  AddrX = AddrX - 0x2;  AddrY = AddrY - 0x2;  }
    if (data_size==32)  {  AddrX = AddrX - 0x4;  AddrY = AddrY - 0x4;  }
   
    Store_Address_Register(regX,AddrX,32);                                                      // Write-back the -(An) address both Address Registers
    Store_Address_Register(regY,AddrY,32);
   
   
    if (data_size==32) { DataX=BIU_Read_32(AddrX);        DataY=BIU_Read_32(AddrY);         }   // Fetch data from both addresses
    else               { DataX=BIU_Read(AddrX,data_size); DataY=BIU_Read(AddrY,data_size);  }

    if (math_type==0) { Calculate_Flags_C(DataX , DataY , 1);
                        result = DataX - DataY;                                                 // Subtract the two operands first and calculate the V,C Flags
                        Calculate_Flags_C(result , mc68k_flag_X , 1);                         
                        result = result - mc68k_flag_X;   
                        Calculate_Flags_V(DataX , DataY , result , data_size , 1);                     
                      }
 
    if (math_type==1) { Calculate_Flags_C(DataX , DataY , 0);
                        result = DataX + DataY;                                                 // Add the two operands first and calculate the V,C Flags
                        Calculate_Flags_C(result , mc68k_flag_X , 0);                         
                        result = result + mc68k_flag_X;   
                        Calculate_Flags_V(DataX , DataY , result , data_size , 0);                     
                      }
                   
    if (data_size==8)   { BIU_Write(AddrX ,    result  , 8);  }
    if (data_size==16)  { BIU_Write(AddrX ,    result , 16);  }
    if (data_size==32)  { clock_counter=clock_counter+4; BIU_Write_32(AddrX , result );      }
   
       
  } 
  Calculate_Flag_N(result);                                                                     // Calculate the N Flag
  Calculate_Flag_Z(result , TRUE);                                                              // Calculate the Z Flag - Clear_only = TRUE
  if (mc68k_flag_C != 0)  { mc68k_flags=(mc68k_flags | 0x0010);  }                              // Copy C flag to X flag
  else                    { mc68k_flags=(mc68k_flags & 0xFFEF);  }
 
  return; 
}


// ----------------------------------------------------------------------
void op_DIVS()
{       
  signed long long dividend;
  signed long long divisor;
  signed long long quotient;
  signed long long remainder;
  unsigned long long result;
  
  clock_counter=clock_counter+154;

  data_size     = 16;                                                                           // Get the data size from the opcode bits[7:6]
  calculated_EA = Calculate_EA(0x2FFC);                                                         // Calculate the EA, checking supported modes
  divisor       = (signed short int) (Fetch_EA(calculated_EA , ea_type) );                      // Fetch the EA data and convert to a signed 16-bit number

  reg_num  = (0x0E00&first_opcode)>>9;                                                          // Isolate the register number from the opcode
  dividend = (signed long) Fetch_Data_Register(reg_num,32);                                     // Fetch the Register data and convert to a signed 32-bit number
 
  if (divisor==0)  { clock_counter=6; Exception_Handler(5);  return;  }                        // Check for division by zero. Trap if true
  else
  {
    quotient  = dividend / divisor;                                                             // Calculate the results
    remainder = (0xFFFF & (dividend % divisor ) );
    result = ( (remainder<<16) | (0x0000FFFF&quotient) );

 
    if ( (quotient > 32767) || (quotient < -32768)  )  {  mc68k_flags = (mc68k_flags | 0x0002);         // If overflow, set the V Flag and don't update the register
                              mc68k_flags=(mc68k_flags&0xFFFE);           // Always clear the C Flag
                             }       
           
    else                                   {  Store_Data_Register(reg_num,result,32);           // Else, write-back the 32-bit results to the Data Register
                                mc68k_flags=(mc68k_flags&0xFFFC);           // Clear the V and C flag
                              Calculate_Flag_N((0x0000FFFF&quotient));
                              Calculate_Flag_Z((0x0000FFFF&quotient) , FALSE); 
                             } 
 
  }
  return; 
}


// ----------------------------------------------------------------------
void op_DIVU()
{       
  unsigned long dividend;
  unsigned long divisor;
  unsigned long quotient;
  unsigned long remainder;
  unsigned long result;
  
  clock_counter=clock_counter+136;

  data_size     = 16;                                                                           // Get the data size from the opcode bits[7:6]
  calculated_EA = Calculate_EA(0x2FFC);                                                         // Calculate the EA, checking supported modes
  divisor       = Fetch_EA(calculated_EA , ea_type);                                            // Fetch the EA data
   
  reg_num = (0x0E00&first_opcode)>>9;                                                           // Isolate the register number from the opcode
  dividend = Fetch_Data_Register(reg_num,32);                                                   // Fetch the Register data
 
  if (divisor==0)  { Exception_Handler(5);  return;  }                                          // Check for division by zero. Trap if true
  else
  {
    quotient  = dividend / divisor;                                                             // Calculate the results
    remainder = (0xFFFF & (dividend % divisor ) );
    result = ( (remainder<<16) | (0x0000FFFF&quotient) );
     
    if ( (quotient>0xFFFF) )  {  mc68k_flags = (mc68k_flags | 0x0002);              // If overflow, set the V Flag and don't update the register
                                 mc68k_flags=(mc68k_flags&0xFFFE);                // Always clear the C Flag
                }       

    else                      {  Store_Data_Register(reg_num,result,32);              // Else, write-back the 32-bit results to the Data Register
                 mc68k_flags=(mc68k_flags&0xFFFC);                // Clear the V and C flag
                   Calculate_Flag_N((0x0000FFFF&quotient));
                   Calculate_Flag_Z((0x0000FFFF&quotient) , FALSE);
                }             

  }
  return; 
}


// ----------------------------------------------------------------------
void op_MULS()
{       
  signed short int reg_data_s;
  signed short int ea_data_s;
  signed long result;
  unsigned long wb_result;

  clock_counter=clock_counter+66;

  data_size     = 16;                                                                           // Force size to 16
  calculated_EA = Calculate_EA(0x2FFC);                                                         // Calculate the EA, checking supported modes
  ea_data_s     = (signed short int) Fetch_EA(calculated_EA , ea_type);                         // Fetch the EA data and convert to a signed 16-bit number
   
  reg_num    = (0x0E00&first_opcode)>>9;                                                        // Isolate the register number from the opcode
  reg_data_s = (signed short int) Fetch_Data_Register(reg_num,16);                              // Fetch the Register data and convert to a signed 16-bit number
 
  result  = (signed long)ea_data_s * (signed long)reg_data_s;                                   // Calculate the results

  wb_result = (unsigned long ) result;

  Store_Data_Register(reg_num,result,32);                                                       // Write-back the full 32-bits of the results to the Data Register

  data_size     = 32;                                                                           // Force size to 32-bits so flags are calculated correctly
  Calculate_Flag_N(wb_result);                                                                  // Calculate the N Flag
  Calculate_Flag_Z(wb_result , FALSE);                                                          // Calculate the Z Flag - Clear_only = FALSE
  mc68k_flags = ( mc68k_flags & 0xFFFC);                                                        // Always clear V, C Flags
  return; 
}


// ----------------------------------------------------------------------
void op_MULU()
{       
  unsigned long reg_data;
  unsigned long result;
  
  clock_counter=clock_counter+66;

  data_size     = 16;                                                                           // Force size to 16
  calculated_EA = Calculate_EA(0x2FFC);                                                         // Calculate the EA, checking supported modes
  EA_Data       = Fetch_EA(calculated_EA , ea_type);                                            // Fetch the EA data
   
  reg_num = (0x0E00&first_opcode)>>9;                                                           // Isolate the register number from the opcode
  reg_data = Fetch_Data_Register(reg_num,16);                                                   // Fetch the Register data

  result  = (unsigned long)EA_Data * (unsigned long)reg_data;                                   // Calculate the results

  Store_Data_Register(reg_num,result,32);                                                       // Write-back the full 32-bits of the results to the Data Register

  data_size     = 32;                                                                           // Force size to 32-bits so flags are calculated correctly
  Calculate_Flag_N(result);                                                                     // Calculate the N Flag
  Calculate_Flag_Z(result , FALSE);                                                             // Calculate the Z Flag - Clear_only = FALSE
  mc68k_flags = ( mc68k_flags & 0xFFFC);                                                        // Always clear V, C Flags
  return; 
}
   

// bcd_type  0=ABCD   1=SBCD
// ----------------------------------------------------------------------
void op_xBCD(unsigned char bcd_type)
{       
  unsigned char regX;
  unsigned char regY;
  unsigned long AddrX;
  unsigned long AddrY; 
  signed long result;
  signed long DataX;
  signed long DataY;
  int result_lower;
  int result_upper;
  signed char carry=0;

  clock_counter=clock_counter+2;
  data_size     = 8;                                                                            // Byte only
 
  regX = (0x0E00&first_opcode)>>9;                                                              // Isolate the register X number from the opcode
  regY = (0x0007&first_opcode);                                                                 // Isolate the register Y number from the opcode
     
  if ( (0x0008&first_opcode)==0)                                                                // ** Opcode[3]=0 for Register to Register **
  {
    DataX = Fetch_Data_Register(regX,data_size);                                                // Fetch Data Register X data
    DataY = Fetch_Data_Register(regY,data_size);                                                // Fetch Data Register Y data     
   

    if (bcd_type==0)                                                                            // ## ABCD##
    {
      carry = 0;
    result_lower = (0x0F&DataX) + (0x0F&DataY) + mc68k_flag_X;                                // Lower BCD digit
      if (result_lower>9) { result_lower = result_lower - 10;    carry = 1; }
     
      result_upper = ((0xF0&DataX)>>4) + ((0xF0&DataY)>>4) + carry;                             // Upper BCD digit                                 
      carry = 0;                                                                               
      if (result_upper>9) { result_upper = result_upper - 10;  carry = 1; }
     
      result = (result_upper<<4) + result_lower;
    }
   
    else                                                                                        // ## SBCD ##
    {
      carry = 0;
    result_lower = (0x0F&DataX) - (0x0F&DataY) - mc68k_flag_X;                                // Lower BCD digit
      if (result_lower<0) { result_lower = result_lower + 10;    carry = 1; }
     
      result_upper = ((0xF0&DataX)>>4) - ((0xF0&DataY)>>4) - carry;                             // Upper BCD digit                                 
      carry = 0;                                                                               
      if (result_upper<0) { result_upper = result_upper + 10;  carry = 1; }
     
      result = (result_upper<<4) + result_lower;
    }
     
    Store_Data_Register(regX,result,data_size);                                                 // Write-back the results to the Data Register
  }
 
  else                                                                                          // ** Memory to Memory **
  {
    AddrX = Fetch_Address_Register(regX,32);                                                    // Fetch Address Register X data
    AddrY = Fetch_Address_Register(regY,32);                                                    // Fetch Address Register Y data
 
    AddrX = AddrX - 0x1;                                                                        // Pre-decrement both addresses  -(An)
    AddrY = AddrY - 0x1;                                                   
   
    Store_Address_Register(regX,AddrX,32);                                                      // Write-back the -(An) address both Address Registers
    Store_Address_Register(regY,AddrY,32);
   
    DataX = BIU_Read(AddrX , data_size);                                                        // Fetch data from both addresses
    DataY = BIU_Read(AddrY , data_size); 


    if (bcd_type==0)                                                                            // ## ABCD##
    {
      carry = 0;
    result_lower = (0x0F&DataX) + (0x0F&DataY) + mc68k_flag_X;                                // Lower BCD digit
      if (result_lower>9) { result_lower = result_lower - 10;  carry = 1; }
     
      result_upper = ((0xF0&DataX)>>4) + ((0xF0&DataY)>>4) + carry;                             // Upper BCD digit                                 
      carry = 0;                                                                               
      if (result_upper>9) { result_upper = result_upper - 10;  carry = 1; }
     
      result = (result_upper<<4) + result_lower;
    }
   
    else                                                                                        // ## SBCD ##
    {
      carry = 0;
    result_lower = (0x0F&DataX) - (0x0F&DataY) - mc68k_flag_X;                                // Lower BCD digit
      if (result_lower<0) { result_lower = result_lower + 10;  carry = 1; }
     
      result_upper = ((0xF0&DataX)>>4) - ((0xF0&DataY)>>4) - carry;                             // Upper BCD digit                                 
      carry = 0;                                                                               
      if (result_upper<0) { result_upper = result_upper + 10;  carry = 1; }
     
      result = (result_upper<<4) + result_lower;
    }   

    Writeback_EA(AddrX , MEMORY , result);                                                      // Write-back the results to Memory
  } 
 
  if (carry==1)  mc68k_flags=(mc68k_flags|0x0011); else mc68k_flags=(mc68k_flags&0xFFEE);       // Set X and C Flags to the Carry bit
  Calculate_Flag_Z(result , TRUE);                                                              // Calculate the Z Flag - Clear_only = TRUE

  return; 
}
   

// ----------------------------------------------------------------------
void op_NBCD()
{
  int result_lower;
  int result_upper;
  signed long result;
  signed char carry=0;
 
  data_size         = 8;
  calculated_EA     = Calculate_EA(0x2FE0);                                                     // Calculate the Source EA, checking supported modes
  EA_Data           = Fetch_EA(calculated_EA , ea_type);                                        // Fetch the EA data
 
 
  result_lower = (0x0) - (0x0F&EA_Data) - mc68k_flag_X;                                         // Lower BCD digit
  if (result_lower<0) { result_lower = result_lower + 10;  carry = 1; }
 
  result_upper = (0x0) - ((0xF0&EA_Data)>>4) - carry;                                           // Upper BCD digit                                 
  carry = 0;                                                                                   
  if (result_upper<0) { result_upper = result_upper + 10;  carry = 1; }
 
  result = (result_upper<<4) + result_lower;
 
  Writeback_EA(calculated_EA , ea_type ,result);                                                // Write-back data to the EA
 
  if (carry==1)  mc68k_flags=(mc68k_flags|0x0011); else mc68k_flags=(mc68k_flags&0xFFEE);       // Set X and C Flags to the Carry bit
  Calculate_Flag_Z(result , TRUE);                                                              // Calculate the Z Flag - Clear_only = TRUE

  return;
}


// ----------------------------------------------------------------------
void op_MOVEP()
{
  unsigned char regX;
  unsigned long DataX;
  unsigned long result=0;
 
  if ( (0x0040&first_opcode) == 0)  data_size = 16;  else  data_size = 32;                      // Isolate opcode[6] to set the size
 
  first_opcode   = first_opcode | 0x20;                                                         // Force the EA field to d16(An) mode
  calculated_EA  = Calculate_EA(0x0100);                                                        // Calculate the EA with the forced EA mode
  regX = (0x0E00&first_opcode)>>9;                                                              // Isolate the register X number from the opcode
 
 
  if ( (0x0080&first_opcode) == 0)                                                              // ## Memory to Register ##
  {
                         clock_counter=16;
             result = (0xFF&BIU_Read(calculated_EA+0x0 , SIZE_BYTE));            result = result<<8;    // Byte #0
                         result = result | (0xFF&BIU_Read(calculated_EA+0x2 , SIZE_BYTE));                          // Byte #1
                         Store_Data_Register(regX,result,16);                                                       // Write-back the results to 16 bits of the Data Register
                         result = result<<8;                                                                        // Keep shifting for possible word operation
    if (data_size==32) { clock_counter=clock_counter+8;
                       result = result | (0xFF&BIU_Read(calculated_EA+0x4 , SIZE_BYTE));   result = result<<8;    // Byte #2 for Long data
                         result = result | (0xFF&BIU_Read(calculated_EA+0x6 , SIZE_BYTE));                          // Byte #3 for Long data
                         Store_Data_Register(regX,result,32);                                                       // Write-back the results to the full Data Register
                       }
  }
 
  else                                                                                          // ## Register to Memory ##
  {
    DataX = Fetch_Data_Register(regX,32);                                                          // Fetch Data Register X data
   
    if (data_size==16) {  clock_counter=16;
                        BIU_Write(calculated_EA+0x0 , ( (0x0000FF00&DataX)>>8) , SIZE_BYTE);  // Byte #0
                          BIU_Write(calculated_EA+0x2 , ( (0x000000FF&DataX)>>0) , SIZE_BYTE);  // Byte #1
                       }
                       
    else               {  clock_counter=clock_counter+8;
                        BIU_Write(calculated_EA+0x0 , ( (0xFF000000&DataX)>>24) , SIZE_BYTE); // Byte #0
                          BIU_Write(calculated_EA+0x2 , ( (0x00FF0000&DataX)>>16) , SIZE_BYTE); // Byte #1
                          BIU_Write(calculated_EA+0x4 , ( (0x0000FF00&DataX)>>8 ) , SIZE_BYTE); // Byte #2
                          BIU_Write(calculated_EA+0x6 , ( (0x000000FF&DataX)>>0 ) , SIZE_BYTE); // Byte #3
                       }               
  }
  return;
}



// Main MCL68 loop
// ----------------------------------------------------------------------
 void loop() {

  uint8_t inchar=0;
  uint16_t joe16, joe17=0;
  uint16_t failcnt=0;
//setup();

  delay(2000);                // Delay a few seconds to give the UART to establish a link with the host PC
  for (uint32_t i=0 ; i<=3200 ; i++)       {   wait_for_E_falling_edge(); }



  // Load the Macintosh 512K's ROM into internal 64KB ROM
  rom_readthrough=1;
   for (uint32_t i=0x0 ; i<=0x0FFFF ; i=i+1) { INTERNAL_ROM[i] = BIU_Read(i , SIZE_BYTE);  }
  rom_readthrough=0;



  Reset_routine();


  while (1)
    {
 
   // Wait for opcode cycle counter to expire before processing traps or next instruction
   // Allow prefetch queue to fill during this time
     while (clock_counter>0)  {
       wait_for_CLK_falling_edge();  //Serial.printf("%d\n\r",clock_counter);
     clock_counter--;                                       
       if (prefetch_queue_count<2)  BIU_PFQ_add_word();                                                       
      }
    

   // Extract these signals at the last clock edge
   gpio6_data = GPIO6_DR;
   gpio6_reset_n  = gpio6_data & RESET_n_BIT;
   gpio6_halt_n   = gpio6_data & HALT_n_BIT;
   gpio6_ipl    = (0x7 ^ (gpio6_data & IPL2_0_BITs)>>16 );  // Invert the IPL bits which are active low on the pins
   if (gpio6_ipl != 7)  nmi_gate=0;                                                    // Debounce NMI

   
   // Handle a RESET from the BIU
   if ((gpio6_reset_n == 0) && (gpio6_halt_n == 0) )  Reset_routine();          

   //if (mc68k_flag_INTR_Mask != 7) Serial.printf("\n\r gpio6_ipl:%x: mc68k_flag_INTR_Mask:%x ",gpio6_ipl,mc68k_flag_INTR_Mask);
   // Interrupts
        if (nmi_gate==0 && gpio6_ipl==7)             {   nmi_gate=1;  Exception_Handler(99);  } // NMI - only allow once until IPL[2:0] changes to different value
   else if (gpio6_ipl > mc68k_flag_INTR_Mask)   {                 Exception_Handler(99);  } // Maskable interrupt

    
     else 
     
     {
    first_opcode = BIU_PFQ_Fetch();

   //Serial.printf("first_opcode %x\n\r",first_opcode);
   //Serial.printf("\n\r %x: %x ",(mc68k_pc-2),first_opcode);
         
      switch (first_opcode&0xF000)
      {
        case (0x0000):
          if ((first_opcode&0x0FFF)==0x003C) { op_BOOL_I_TO_CCR(1);       break; }    
          if ((first_opcode&0x0FFF)==0x007C) { op_BOOL_I_TO_SR(1);        break; }      
          if ((first_opcode&0x0FFF)==0x0A3C) { op_BOOL_I_TO_CCR(3);       break; } 
          if ((first_opcode&0x0FFF)==0x0A7C) { op_BOOL_I_TO_SR(3);        break; } 
          if ((first_opcode&0x0FFF)==0x023C) { op_BOOL_I_TO_CCR(2);       break; } 
          if ((first_opcode&0x0FFF)==0x027C) { op_BOOL_I_TO_SR(2);        break; } 
          if ((first_opcode&0x0FC0)==0x0800) { op_BMOD(0x31);             break; } 
          if ((first_opcode&0x0FC0)==0x0840) { op_BMOD(0x21);             break; } 
          if ((first_opcode&0x0FC0)==0x0880) { op_BMOD(0x11);             break; } 
          if ((first_opcode&0x0FC0)==0x08C0) { op_BMOD(0x01);             break; } 
          if ((first_opcode&0x0138)==0x0108) { op_MOVEP();                break; } 
          if ((first_opcode&0x0F00)==0x0A00) { op_BOOL_I(3);              break; } 
          if ((first_opcode&0x0F00)==0x0000) { op_BOOL_I(1);              break; } 
          if ((first_opcode&0x0F00)==0x0200) { op_BOOL_I(2);              break; } 
          if ((first_opcode&0x0F00)==0x0400) { op_ADDSUBI(0);             break; } 
          if ((first_opcode&0x0F00)==0x0600) { op_ADDSUBI(1);             break; } 
          if ((first_opcode&0x0F00)==0x0C00) { op_BOOL_I(4);              break; }          
          if ((first_opcode&0x01C0)==0x0100) { op_BMOD(0x30);             break; } 
          if ((first_opcode&0x01C0)==0x0140) { op_BMOD(0x20);             break; } 
          if ((first_opcode&0x01C0)==0x0180) { op_BMOD(0x10);             break; } 
          if ((first_opcode&0x01C0)==0x01C0) { op_BMOD(0x00);             break; } 
           Exception_Handler(4);                                                                                                   
           break;                                                                                                                   
                                                                                                                                   
         case (0x1000):  case (0x2000):  case (0x3000):                                                                             
                                             {   op_MOVE();               break; } 
                                                                                                                                   
                                                                                                                                   
         case (0x4000):                                                                                                             
           if ((first_opcode&0x0FC0)==0x00C0) { op_MOVE_FROM_SR();          break; } 
           if ((first_opcode&0x0FC0)==0x04C0) { op_MOVE_TO_CCR();           break; } 
           if ((first_opcode&0x0FC0)==0x06C0) { op_MOVE_TO_SR();            break; } 
           if ((first_opcode&0x0F00)==0x0000) { op_NEGS(3);                 break; } 
           if ((first_opcode&0x0F00)==0x0200) { op_NEGS(4);                 break; } 
           if ((first_opcode&0x0F00)==0x0400) { op_NEGS(2);                 break; } 
           if ((first_opcode&0x0F00)==0x0600) { op_NEGS(1);                 break; } 
           if ((first_opcode&0x0FB8)==0x0880) { op_EXT();                   break; } 
           if ((first_opcode&0x0FC0)==0x0800) { op_NBCD();                  break; } 
           if ((first_opcode&0x0FF8)==0x0840) { op_SWAP();                  break; } 
           if ((first_opcode&0x0FC0)==0x0840) { op_PEA();                   break; } 
           if ((first_opcode&0x0FFF)==0x0AFC) { Exception_Handler(4);       break; } 
           if ((first_opcode&0x0FC0)==0x0AC0) { op_TAS();                   break; } 
           if ((first_opcode&0x0F00)==0x0A00) { op_TST();                   break; } 
           if ((first_opcode&0x0FF0)==0x0E40) { op_TRAP();                  break; } 
           if ((first_opcode&0x0FF8)==0x0E50) { op_LINK();                  break; } 
           if ((first_opcode&0x0FF8)==0x0E58) { op_UNLK();                  break; } 
           if ((first_opcode&0x0FF0)==0x0E60) { op_MOVE_USP();              break; } 
           if ((first_opcode&0x0FFF)==0x0E71) { /* Do Nothing */            break; } 
           if ((first_opcode&0x0FFF)==0x0E70) { op_RESET();                 break; } 
           if ((first_opcode&0x0FFF)==0x0E72) { op_STOP();                  break; } 
           if ((first_opcode&0x0FFF)==0x0E73) { op_RTE();                   break; } 
           if ((first_opcode&0x0FFF)==0x0E75) { op_RTS();                   break; } 
           if ((first_opcode&0x0FFF)==0x0E76) { op_TRAPV();                 break; } 
           if ((first_opcode&0x0FFF)==0x0E77) { op_RTR();                   break; } 
           if ((first_opcode&0x0FC0)==0x0E80) { op_JSR();                   break; } 
           if ((first_opcode&0x0FC0)==0x0EC0) { op_JMP();                   break; } 
           if ((first_opcode&0x0B80)==0x0880) { op_MOVEM();                 break; } 
           if ((first_opcode&0x01C0)==0x01C0) { op_LEA();                   break; } 
           if ((first_opcode&0x01C0)==0x0180) { op_CHK();                   break; } 
           Exception_Handler(4);                                                                                                   
           break;                                                                                                                   
                                                                                                                                   
         case (0x5000):                                                                                                             
           if ((first_opcode&0x00F8)==0x00C8) { op_dBCC();                  break; } 
           if ((first_opcode&0x00C0)==0x00C0) { op_SCC();                   break; } 
           if ((first_opcode&0x0100)==0x0000) { op_ADDSUBQ(1);              break; } 
           if ((first_opcode&0x0100)==0x0100) { op_ADDSUBQ(0);              break; } 
           Exception_Handler(4);                                                     
           break;                                                                                                                   
                                                                                                                                   
         case (0x6000):                                                                                                             
           if ((first_opcode&0x0F00)==0x0100) { op_BSR();                   break; }          
           if ((first_opcode&0x0000)==0x0000) { op_BCC();                   break; }  
           Exception_Handler(4);                                                                                                   
           break;                                                                                                                   
                                                                                                                                   
         case (0x7000):                                                                                                             
           if ((first_opcode&0x0100)==0x0000) { op_MOVEQ();                 break; } 
           Exception_Handler(4);                                                                                                   
           break;                                                                                                                   
                                                                                                                                   
         case (0x8000):                                                                                                             
           if ((first_opcode&0x01C0)==0x00C0) { op_DIVU();                  break; } 
           if ((first_opcode&0x01C0)==0x01C0) { op_DIVS();                  break; } 
           if ((first_opcode&0x01F0)==0x0100) { op_xBCD(1);                 break; } 
           if ((first_opcode&0x0000)==0x0000) { op_BOOL(1);                 break; } 
           Exception_Handler(4);                                                                                                   
           break;                                                                                                                   
                                                                                                                                   
         case (0x9000):                                                                                                             
           if ((first_opcode&0x00C0)==0x00C0) { op_ADDSUBA(0);              break; } 
           if ((first_opcode&0x0130)==0x0100) { op_ADDSUBX(0);              break; }          
           if ((first_opcode&0x0000)==0x0000) { op_ADDSUB(0);               break; } 
           Exception_Handler(4);                                                                                                   
           break;                                                                                                                   
                                                                                                                                     
         case (0xA000):   {  Exception_Handler(10);                         break; } 
                                                                                                                                   
         case (0xB000):                                                                                                             
           if ((first_opcode&0x00C0)==0x00C0) { op_CMPA();                  break; } 
           if ((first_opcode&0x0138)==0x0108) { op_CMPM();                  break; } 
           if ((first_opcode&0x0100)==0x0100) { op_BOOL(3);                 break; } 
           if ((first_opcode&0x0100)==0x0000) { op_BOOL(4);                 break; } 
           Exception_Handler(4);                                                   
           break;                                                                   
                                                                                   
         case (0xC000):                                                             
           if ((first_opcode&0x01C0)==0x00C0) { op_MULU();                  break; } 
           if ((first_opcode&0x01C0)==0x01C0) { op_MULS();                  break; } 
           if ((first_opcode&0x01F0)==0x0100) { op_xBCD(0);                 break; } 
           if ((first_opcode&0x0130)==0x0100) { op_EXG();                   break; } 
           if ((first_opcode&0x0000)==0x0000) { op_BOOL(2);                 break; } 
           Exception_Handler(4);                                                                                                   
           break;                                                                                                                   
                                                                                                                                   
         case (0xD000):                                                                                                             
           if ((first_opcode&0x00C0)==0x00C0) { op_ADDSUBA(1);              break; } 
           if ((first_opcode&0x0130)==0x0100) { op_ADDSUBX(1);              break; } 
           if ((first_opcode&0x0000)==0x0000) { op_ADDSUB(1);               break; } 
           Exception_Handler(4);                                                   
           break;                                                                   
                                                                                   
         case (0xE000):                                                             
           if ((first_opcode&0x0FC0)==0x01C0) { op_xSL(0,1);                break; }   // MEMORY Left
           if ((first_opcode&0x0FC0)==0x03C0) { op_xSL(0,2);                break; } 
           if ((first_opcode&0x0FC0)==0x05C0) { op_ROXL(0);                 break; } 
           if ((first_opcode&0x0FC0)==0x07C0) { op_ROL(0);                  break; } 
       
           if ((first_opcode&0x0FC0)==0x00C0) { op_xSR(1,2);                break; }   // MEMORY Right
           if ((first_opcode&0x0FC0)==0x02C0) { op_xSR(2,2);                break; } 
           if ((first_opcode&0x0FC0)==0x04C0) { op_ROXR(0);                 break; } 
           if ((first_opcode&0x0FC0)==0x06C0) { op_ROR(0);                  break; } 
                                                                                   
           if ((first_opcode&0x0118)==0x0100) { op_xSL(1,1);                break; }   // REGISTER Left
           if ((first_opcode&0x0118)==0x0108) { op_xSL(1,2);                break; } 
           if ((first_opcode&0x0118)==0x0110) { op_ROXL(1);                 break; } 
           if ((first_opcode&0x0118)==0x0118) { op_ROL(1);                  break; }  
       
           if ((first_opcode&0x0118)==0x0000) { op_xSR(1,1);                break; }   // REGISTER Right 
           if ((first_opcode&0x0118)==0x0008) { op_xSR(2,1);                break; } 
           if ((first_opcode&0x0118)==0x0010) { op_ROXR(1);                 break; } 
           if ((first_opcode&0x0118)==0x0018) { op_ROR(1);                  break; }  
           Exception_Handler(4);       
           break;
           
         case (0xF000):                       { Exception_Handler(11);      break; } 
   
      default: ;
     }
   
   } 

     // Process Trace if flag is set, but don't allow if last opcode caused ILLEGAL or PRIVILEGE exception
     // Also don't allow Trace if it was just set/restored. This allows one instruction to be executed between Traces
     //
     if ( (last_mc68k_flag_T==1 && mc68k_flag_T==1) && last_exception!=4 && last_exception!=8)   { clock_counter=6;  Exception_Handler(9); }
     else                                                                                        { last_exception = 0;                      } // Debounce

     last_mc68k_flag_T = mc68k_flag_T;
   
   
   }
   
}

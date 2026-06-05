//
//
//  File Name   :  MCL8080+
//  Used on     : 
//  Author      :  Ted Fried, MicroCore Labs
//  Creation    :  6/4/2026
//
//   Description:
//   ============
//   
//  Intel 8080 emulator running in an ATTiny85 microcontroller using a SPI
//  bus for the local bus.
//
//------------------------------------------------------------------------
//
// Modification History:
// =====================
//
// Revision 1 6/4/2026
// Initial revision
//
//------------------------------------------------------------------------
//
// Copyright (c) 2026 Ted Fried
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
                                                 

#include <avr/io.h>
#include <stdint.h>


#define PIN_SPI_CS_n            PB3     
//#define PIN_SPI_CLK             7       
//#define PIN_SPI_MOSI            6       
//#define PIN_SPI_MISO            5       

// USI_CLOCK_STROBE:
// USIWM0 = 3-wire mode
// USICS1 = External/Software clock source
// USICLK = Clock Strobe (links USITC to the shift register)
// USITC  = Toggle Clock Pin (PB2/USCK)
#define USI_FAST_CLK ((1 << USIWM0) | (1 << USICS0)| (1 << USICS1) | (1 << USICLK) | (1 << USITC))


#define MEM_WRITE_BYTE             0x02   
#define MEM_READ_BYTE              0x03   
#define IO_WRITE_BYTE              0x04   
#define IO_READ_BYTE               0x05   
#define INTERRUPT_ACK              0x09


#define flag_s (  (register_f & 0x80)==0 ? 0 : 1  )
#define flag_z (  (register_f & 0x40)==0 ? 0 : 1  )
#define flag_h (  (register_f & 0x10)==0 ? 0 : 1  )
#define flag_p (  (register_f & 0x04)==0 ? 0 : 1  )
#define flag_n (  (register_f & 0x02)==0 ? 0 : 1  )
#define flag_c (  (register_f & 0x01)==0 ? 0 : 1  )


#define REGISTER_BC  ( (register_b<<8)   | register_c )
#define REGISTER_DE  ( (register_d<<8)   | register_e )
#define REGISTER_HL  ( (register_h<<8)   | register_l )
#define REGISTER_AF  ( (register_a<<8)   | register_f )

#define REG_BC 1
#define REG_DE 2
#define REG_HL 3
#define REG_AF 4

 
// --------------------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------------------
 

uint8_t  temp8=0;
uint8_t  opcode_byte=0;
uint8_t  and_opcode=0;
uint8_t  inc_dec=0;
uint8_t  with_carry=0;
uint8_t  halt_in_progress=0;
uint8_t  assert_iack_type0=0;
uint8_t  register_a    = 0;         
uint8_t  register_b    = 0;
uint8_t  register_c    = 0;
uint8_t  register_d    = 0;
uint8_t  register_e    = 0;
uint8_t  register_f    = 0x2;                                     
uint8_t  register_h    = 0;
uint8_t  register_l    = 0;
uint8_t  register_iff  = 0;
uint8_t  direct_intr   = 1;
uint8_t  direct_reset  = 1;
uint8_t  last_command_type=9;

uint16_t register_sp      = 0;                   
uint16_t register_pc      = 0xFF00;                   
uint16_t temp16;             
uint16_t previous_address = 0x1234;


uint16_t cache_addr[128]; //  Cache format:    [A15 A14 A13 A12 A11, A10 A9 A8]   [A7 A6 A5 A4 A3 A2 A1 A0]
uint8_t  cache_data[128]; //  Cache format:                                       [D7 D6 D  D  D3 D2 D1 D0]


// Pre-calculated 8-bit parity
const uint8_t Parity_Array[256]PROGMEM  = {4,0,0,4,0,4,4,0,0,4,4,0,4,0,0,4,0,4,4,0,4,0,0,4,4,0,0,4,0,4,4,0,0,4,4,0,4,0,0,4,4,0,0,4,0,4,4,0,4,0,0,4,0,4,4,0,0,4,4,0,4,0,0,4,0,4,4,0,4,0,0,4,4,0,0,4,0,4,4,0,4,0,0,4,0,4,4,0,0,4,4,0,4,0,0,4,4,0,0,4,0,4,4,0,0,4,4,0,4,0,0,4,0,4,4,0,4,0,0,4,4,0,0,4,0,4,4,0,0,4,4,0,4,0,0,4,4,0,0,4,0,4,4,0,4,0,0,4,0,4,4,0,0,4,4,0,4,0,0,4,4,0,0,4,0,4,4,0,0,4,4,0,4,0,0,4,0,4,4,0,4,0,0,4,4,0,0,4,0,4,4,0,4,0,0,4,0,4,4,0,0,4,4,0,4,0,0,4,0,4,4,0,4,0,0,4,4,0,0,4,0,4,4,0,0,4,4,0,4,0,0,4,4,0,0,4,0,4,4,0,4,0,0,4,0,4,4,0,0,4,4,0,4,0,0,4 };



void setup() {

    DDRB |= (1 << PB1) | (1 << PB2) | (1 << PB3); // DO, USCK, and your CS (PB3) as Output
    DDRB &= ~(1 << PB0);                          // DI as Input

    // Initialize USI for SPI Mode 1
    // USIWM0 = 3-wire mode
    // USICS1 = Software strobe source
    // USICS0 = Sample on Falling Edge (Required for Mode 1)
    USICR = (1 << USIWM0) | (1 << USICS1) | (1 << USICS0);

    // Ensure Clock and CS_n starts LOW
    PORTB &= ~(1 << PB2);
    PORTB &= ~(1 << PIN_SPI_CS_n);

return;
}


static inline uint8_t Send_SPI_Byte(uint8_t local_data) { 
 
    USIDR = local_data;       // Load data to send
    USISR = (1 << USIOIF);    // Clear overflow flag + reset counter

    // 16 clock toggles = 8 bits shifted
    USICR = USI_FAST_CLK;   __asm__ __volatile__ ("nop\n\t" "nop\n\t");   
    USICR = USI_FAST_CLK;   __asm__ __volatile__ ("nop\n\t" "nop\n\t");   
    USICR = USI_FAST_CLK;   __asm__ __volatile__ ("nop\n\t" "nop\n\t");   
    USICR = USI_FAST_CLK;   __asm__ __volatile__ ("nop\n\t" "nop\n\t");   
                                                                          
    USICR = USI_FAST_CLK;   __asm__ __volatile__ ("nop\n\t" "nop\n\t");   
    USICR = USI_FAST_CLK;   __asm__ __volatile__ ("nop\n\t" "nop\n\t");   
    USICR = USI_FAST_CLK;   __asm__ __volatile__ ("nop\n\t" "nop\n\t");   
    USICR = USI_FAST_CLK;   __asm__ __volatile__ ("nop\n\t" "nop\n\t");   
                                                                          
    USICR = USI_FAST_CLK;   __asm__ __volatile__ ("nop\n\t" "nop\n\t");   
    USICR = USI_FAST_CLK;   __asm__ __volatile__ ("nop\n\t" "nop\n\t");   
    USICR = USI_FAST_CLK;   __asm__ __volatile__ ("nop\n\t" "nop\n\t");   
    USICR = USI_FAST_CLK;   __asm__ __volatile__ ("nop\n\t" "nop\n\t");   
                                                                          
    USICR = USI_FAST_CLK;   __asm__ __volatile__ ("nop\n\t" "nop\n\t");   
    USICR = USI_FAST_CLK;   __asm__ __volatile__ ("nop\n\t" "nop\n\t");   
    USICR = USI_FAST_CLK;   __asm__ __volatile__ ("nop\n\t" "nop\n\t");   
    USICR = USI_FAST_CLK;   __asm__ __volatile__ ("nop\n\t" "nop\n\t");   

    return USIDR;  // Received byte
    
}


// --------------------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------------------
//
// Begin Bus Interface Unit
//
// --------------------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------------------


uint8_t SPI_Cycle(uint8_t local_command , uint16_t local_addr , uint8_t local_data) {
  
  noInterrupts();

if (local_command==MEM_READ_BYTE)  {
  if ((last_command_type==MEM_READ_BYTE) &&  (local_addr == (previous_address + 1) ) ) {
    temp8 = Send_SPI_Byte(local_data);    // Stream bytes with autoincrement address
  }

  else { PINB = (1<<PB3); // Toggle SPI_CS_n quickly
        Send_SPI_Byte(MEM_READ_BYTE);   
        Send_SPI_Byte(local_addr); 
        Send_SPI_Byte(local_addr>>8); 
        temp8 = Send_SPI_Byte(local_data);
      }                                                                               
}

else if (local_command==MEM_WRITE_BYTE)  {   
  if ((last_command_type==MEM_WRITE_BYTE) && (local_addr == (previous_address + 1) ) ) { 
     Send_SPI_Byte(local_data);     // Stream bytes with autoincrement address
  }

  else { PINB = (1<<PB3); // Toggle SPI_CS_n quickly
         Send_SPI_Byte(MEM_WRITE_BYTE);   
         Send_SPI_Byte(local_addr); 
         Send_SPI_Byte(local_addr>>8); 
         Send_SPI_Byte(local_data);   
       }                                                                             
}

else if (local_command==IO_READ_BYTE) {
  PINB = (1<<PB3); // Toggle SPI_CS_n quickly
  Send_SPI_Byte(IO_READ_BYTE);
  Send_SPI_Byte(local_addr); 
  temp8=Send_SPI_Byte(local_data);
}

else if (local_command==IO_WRITE_BYTE) {
  PINB = (1<<PB3); // Toggle SPI_CS_n quickly
  Send_SPI_Byte(IO_WRITE_BYTE); 
  Send_SPI_Byte(local_addr); 
  temp8=Send_SPI_Byte(local_data);
}

  previous_address  = local_addr;
  last_command_type = local_command;
  interrupts();

  return temp8;
}



// -------------------------------------------------
// Initiate a Bus Cycle
// -------------------------------------------------
//
// Speed improved with a 128-byte cache:
//
// uint16_t cache_addr[128]; //  Cache format:    [A15 A14 A13 A12 A11, A10 A9 A8]   [A7 A6 A5 A4 A3 A2 A1 A0]
// uint8_t  cache_data[128]; //  Cache format:                                       [D7 D6 D  D  D3 D2 D1 D0]


uint8_t BIU_Bus_Cycle(uint8_t biu_operation, uint16_t local_address , uint8_t local_data)  {

  uint8_t  local_address_low  = (local_address & 0x007F);

  if (biu_operation==MEM_READ_BYTE) {
    if ( local_address == (cache_addr[local_address_low]) ) {
      temp8=cache_data[local_address_low];
      return temp8; 
    }
  else {
    temp8 = SPI_Cycle(MEM_READ_BYTE  , local_address , 0x00); 
    cache_addr[local_address_low] = local_address;
    cache_data[local_address_low] = temp8;
    return temp8;
   }
  }

  if (biu_operation==MEM_WRITE_BYTE) { 
    cache_addr[local_address_low] = local_address;
    cache_data[local_address_low] = local_data;
    SPI_Cycle(MEM_WRITE_BYTE , local_address,local_data);
    return 0xEE;
  }

  if (biu_operation==IO_READ_BYTE)     return SPI_Cycle(IO_READ_BYTE  , local_address , 0x00);
  if (biu_operation==IO_WRITE_BYTE)  {        SPI_Cycle(IO_WRITE_BYTE , local_address,local_data);  return 0xEE; }

  if (biu_operation==INTERRUPT_ACK)  return 0xC7; // RST0 Opcode

  return 0;

}

// --------------------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------------------
//
// End Bus Interface Unit
//
// --------------------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------------------


void reset_sequence()  {
   
    while (direct_reset==0) {   }                                   // Stay here until RESET is de-aserted

    halt_in_progress=0;
    register_pc         = 0xFF00;                                     
    //register_pc         = 0x0100;                                     
    return;
}

void INTR_Handler() {
    uint8_t local_intr_vector;
   
    register_iff = 0;               // Disable Interrupt
    halt_in_progress=0;             // Debounce HALT
    assert_iack_type0 = 1;          // BIU performs IACK during the next opcode fetch
    return;
}
 
uint8_t Fetch_byte()  {   
    uint8_t local_byte;
   
    if (assert_iack_type0==1)  local_byte = BIU_Bus_Cycle(INTERRUPT_ACK  , 0x0000      , 0x00 );
    else                       local_byte = BIU_Bus_Cycle(MEM_READ_BYTE  , register_pc , 0x00 );
   
    assert_iack_type0=0;   
    register_pc++;
    return local_byte;
}

static inline uint8_t Read_byte(uint16_t local_address)                        {  return(BIU_Bus_Cycle(MEM_READ_BYTE , local_address , 0x00 ) );        }
static inline void    Write_byte(uint16_t local_address , uint8_t local_data)  {  BIU_Bus_Cycle(MEM_WRITE_BYTE , local_address , local_data ); return;  }

static inline void Writeback_Reg16(uint8_t local_reg , uint16_t local_data)  {
    switch (local_reg)  {
        case REG_BC: register_b=(local_data>>8);    register_c=(0xFF&local_data);    break;
        case REG_DE: register_d=(local_data>>8);    register_e=(0xFF&local_data);    break;
        case REG_HL: register_h=(local_data>>8);    register_l=(0xFF&local_data);    break;
        case REG_AF: register_a=(local_data>>8);    register_f=(0xFF&local_data);    break;
    }
    return;
}

/*
void Push(uint16_t local_data)  {   
    register_sp--; 
    BIU_Bus_Cycle(MEM_WRITE_BYTE , register_sp   , local_data>>8    );  // High Byte
    register_sp--;
    BIU_Bus_Cycle(MEM_WRITE_BYTE , register_sp , local_data );          // Low Byte
    return;
}
*/

static inline void Push(uint16_t local_data)  {    // Shuffle so the writes are to incrementing addresses
    register_sp = register_sp - 2;
    BIU_Bus_Cycle(MEM_WRITE_BYTE , register_sp , local_data );          // Low Byte
    BIU_Bus_Cycle(MEM_WRITE_BYTE , (register_sp+1)  , local_data>>8    );  // High Byte
    return;
}


static inline uint16_t Pop()  {   
    uint8_t local_data_low;
    uint8_t local_data_high;
   
    local_data_low  = BIU_Bus_Cycle(MEM_READ_BYTE , register_sp , 0x00    ); // Low Byte
    register_sp++;
    local_data_high = BIU_Bus_Cycle(MEM_READ_BYTE , register_sp , 0x00    ); // High Byte
    register_sp++;
    return( (local_data_high<<8) | local_data_low);
}

static inline void Flags_Boolean() {
    if  (and_opcode==0)  register_f = register_f & 0x02;                        // Clear flags
    register_f = register_f | pgm_read_byte(&Parity_Array[register_a]);
    register_f = register_f | (register_a&0x80);                                // Set S flag
    if (register_a==0)  register_f = register_f | 0x40;                         // Set Z flag
    and_opcode=0;
    return;
}
   
uint8_t ADD_Bytes(uint8_t local_data1 , uint8_t local_data2)  {
    uint8_t   local_nibble_results;
    uint16_t  local_byte_results;
    uint8_t   local_cf=0; 
   
    local_cf=(flag_c); 
   
    register_f = register_f & 0x3;                                                                     // Clear flags

    if (with_carry==1) {  local_nibble_results = (0x0F&local_data1) + (0x0F&local_data2) + local_cf;    // Perform the nibble math
                          local_byte_results   = local_data1 + local_data2 + local_cf;                  // Perform the byte math
    }
    else               {  local_nibble_results = (0x0F&local_data1) + (0x0F&local_data2);               // Perform the nibble math
                          local_byte_results   = local_data1 + local_data2;                             // Perform the byte math
    }

    if (local_nibble_results > 0x0F)                 register_f = (register_f | 0x10);                  // Set AC Flag
    if ( inc_dec==0 )  {  if (local_byte_results > 0xFF)  register_f = (register_f | 0x01); else register_f = (register_f & 0xFE);  }           // Set C Flag if not INC or DEC opcodes
    inc_dec = 0;                                                                                        // Debounce inc_dec
 
    register_f = register_f | (local_byte_results&0x80);                                                // Set S flag
    if ((0xFF&local_byte_results)==0)  register_f = register_f | 0x40;                                  // Set Z flag
    register_f = register_f | pgm_read_byte(&Parity_Array[0xFF&local_byte_results]);
    with_carry=0;
       
    return local_byte_results& 0xFF;
}

uint16_t ADD_Words(uint16_t local_data1 , uint16_t local_data2)  {
    uint32_t  local_word_results;
   
    local_word_results   =(uint32_t) local_data1 + local_data2; 
    if (local_word_results > 0xFFFF)  register_f = (register_f | 0x01); else register_f = (register_f & 0xFE);    // Set C Flag 

    return local_word_results;
}

uint8_t SUB_Bytes(uint8_t local_data1 , uint8_t local_data2)  {
    uint8_t   local_nibble_results;
    uint16_t  local_byte_results;
    uint8_t   local_cf=0; 
   
    local_cf=(flag_c);
   
    register_f = register_f & 0x3;                                                                     // Clear flags
 
    if (with_carry==1) {  local_nibble_results = (0x0F&local_data1) - (0x0F&local_data2) - local_cf;    // Perform the nibble math
                          local_byte_results   = local_data1 - local_data2 - local_cf;                  // Perform the byte math
    }
    else               {  local_nibble_results = (0x0F&local_data1) - (0x0F&local_data2);               // Perform the nibble math
                          local_byte_results   = local_data1 - local_data2;                             // Perform the byte math
    }

    if ( (~(local_data1 ^ local_byte_results ^ local_data2) & 0x10) != 0)                  register_f = (register_f | 0x10);                  // Set AC Flag

    if ( inc_dec==0 )  {  if (local_byte_results > 0xFF)  register_f = (register_f | 0x01); else register_f = (register_f & 0xFE);  }                  // Set C Flag if not INC or DEC opcodes
    inc_dec = 0;                                                                                        // Debounce inc_dec
 
    register_f = register_f | (local_byte_results&0x80);                                                // Set S flag
    if ((0xFF&local_byte_results)==0)  register_f = register_f | 0x40;                                  // Set Z flag
    register_f = register_f | pgm_read_byte(&Parity_Array[0xFF&local_byte_results]);

    with_carry=0;
    return local_byte_results&0xFF;
}


                                                                       
// -------------------------------------------------------------------------------------
// -------------------------------------------------------------------------------------
// -------------------------------------------------------------------------------------


// -------------------------------------------------
//
// Main loop
//
// -------------------------------------------------
void loop() {
    
    uint16_t    local_addr16;
    uint8_t    local_data8;
    uint16_t local_address_low;
    uint16_t local_address_high;
    uint16_t local_address;
    uint8_t low;
    uint8_t high;


  reset_sequence();


  while (1) {

      if (direct_reset==0) reset_sequence();

     
      // Poll for interrupts between instructions,
      //
      //if (direct_intr==0 && register_iff==1)     { INTR_Handler(); }


      // Process new instruction
      //
      opcode_byte = Fetch_byte();     


    switch (opcode_byte)  {
       
       case 0x00:   break; // NOP
       case 0x01:   register_c = Fetch_byte();  register_b = Fetch_byte();    break;
       case 0x02:   Write_byte(REGISTER_BC , register_a);     break;
       case 0x03:   Writeback_Reg16(REG_BC , (REGISTER_BC) + 1);    break;
       case 0x04:   inc_dec=1;  register_b = ADD_Bytes(register_b , 0x1);    break;
       case 0x05:   inc_dec=1;  register_b = SUB_Bytes(register_b , 0x1);    break;
       case 0x06:   register_b = Fetch_byte();    break;
       case 0x07:   register_f = register_f & 0xFE;  register_f = register_f | (register_a>>7);  register_a = (register_a<<1);  register_a = register_a | (register_f&0x01);     break;
       case 0x08:   break; // NOP
       case 0x09:   Writeback_Reg16(REG_HL , ADD_Words(REGISTER_HL , REGISTER_BC) );    break;
       case 0x0A:   register_a = Read_byte(REGISTER_BC);    break;
       case 0x0B:   Writeback_Reg16(REG_BC , (REGISTER_BC) - 1);     break;
       case 0x0C:   inc_dec=1;  register_c = ADD_Bytes(register_c , 0x1);   break;
       case 0x0D:   inc_dec=1;  register_c = SUB_Bytes(register_c , 0x1);    break;
       case 0x0E:   register_c = Fetch_byte();    break;
       case 0x0F:   register_f = register_f & 0xFE; register_f = register_f | (register_a&0x01);  register_a = (register_a>>1); register_a = register_a | ((register_f&0x01)<<7);    break;
       case 0x10:   break; // NOP
       case 0x11:   register_e = Fetch_byte();  register_d = Fetch_byte();    break;
       case 0x12:   Write_byte(REGISTER_DE , register_a);     break;
       case 0x13:   Writeback_Reg16(REG_DE , (REGISTER_DE) + 1);    break;
       case 0x14:   inc_dec=1;  register_d = ADD_Bytes(register_d , 0x1);    break;
       case 0x15:   inc_dec=1;  register_d = SUB_Bytes(register_d , 0x1);    break;
       case 0x16:   register_d = Fetch_byte();    break;
       case 0x17:   temp8      = register_f & 0x01;  register_f = register_f & 0xFE; register_f = register_f | (register_a>>7);  register_a = (register_a<<1);  register_a = register_a | temp8;    break;
       case 0x18:   break; // NOP
       case 0x19:   Writeback_Reg16(REG_HL , ADD_Words(REGISTER_HL , REGISTER_DE) );    break;
       case 0x1A:   register_a = Read_byte(REGISTER_DE);    break;
       case 0x1B:   Writeback_Reg16(REG_DE , (REGISTER_DE) - 1);    break;
       case 0x1C:   inc_dec=1;  register_e = ADD_Bytes(register_e , 0x1);    break;
       case 0x1D:   inc_dec=1;  register_e = SUB_Bytes(register_e , 0x1);   break;
       case 0x1E:   register_e = Fetch_byte();    break;
       case 0x1F:   temp8      = register_f & 0x01; register_f = register_f & 0xFE;  register_f = register_f | (register_a&0x01);  register_a = (register_a>>1);  register_a = register_a | (temp8<<7);    break;
       case 0x20:   break; // NOP
       case 0x21:   register_l   = Fetch_byte(); register_h   = Fetch_byte();    break;
       case 0x22:   temp16 = Fetch_byte(); temp16 = (Fetch_byte()<<8) | temp16; Write_byte(temp16,register_l); Write_byte( temp16+1,register_h);    break;
       case 0x23:   Writeback_Reg16(REG_HL , (REGISTER_HL) + 1);     break;
       case 0x24:   inc_dec=1;  register_h=ADD_Bytes(register_h   , 0x1);     break;
       case 0x25:   inc_dec=1;  register_h=SUB_Bytes(register_h   , 0x1);     break;
       case 0x26:   register_h = Fetch_byte();    break;
       case 0x27: 
                        low  = (0x0F&register_a);
                        high = (0xF0&register_a)>>4;
                        temp8=0;
                   
                        if ( (low > 0x9) || (flag_h==1) )                              {  temp8=temp8+0x06;  }
                        if ( (high > 0x9) || (flag_c==1) || (high >= 9 && low > 9) )   {  temp8=temp8+0x60;  register_f=register_f|0x01; }
                        else                                                           { register_f=register_f&0xFE;                     }
                   
                        if ( (low  + (temp8 & 0x0F)) & 0x10) register_f=register_f|0x10; else register_f=register_f&0xEF;   
                   
                        register_a = register_a + temp8;   
                       
                        register_f = register_f & 0x3B;
                        if (register_a&0x80)  register_f = register_f | 0x80;       // Set S Flag
                        if (register_a==0)         register_f = register_f | 0x40;  // Set Z Flag
                        register_f = register_f | pgm_read_byte(&Parity_Array[register_a]);     // Set P flag
            break;
       case 0x28:   break; // NOP
       case 0x29:   Writeback_Reg16(REG_HL , ADD_Words(REGISTER_HL , REGISTER_HL) );    break;
       case 0x2A: 
                    local_address_low  = Fetch_byte();
                    local_address_high = Fetch_byte();
                    local_address =  (local_address_high<<8) | local_address_low;
               
                    register_l   = Read_byte(local_address);
                    register_h   = Read_byte(local_address+1);     
                    break;

       case 0x2B:   Writeback_Reg16(REG_HL , (REGISTER_HL) - 1);    break;
       case 0x2C:   inc_dec=1;  register_l=ADD_Bytes(register_l   , 0x1);    break;
       case 0x2D:   inc_dec=1;  register_l=SUB_Bytes(register_l   , 0x1);    break;
       case 0x2E:   register_l = Fetch_byte();    break;
       case 0x2F:   register_a = 0xFF ^ register_a;     break;
       case 0x30:   break; // NOP
       case 0x31:   temp16 = Fetch_byte(); temp16 = (Fetch_byte()<<8) | temp16; register_sp = temp16;     break;
       case 0x32:   temp16 = Fetch_byte(); temp16 = (Fetch_byte()<<8) | temp16; Write_byte(temp16 , register_a);    break;
       case 0x33:   register_sp++;    break;
       case 0x34:   inc_dec=1;  Write_byte(REGISTER_HL , ADD_Bytes(Read_byte(REGISTER_HL),0x1) );    break;
       case 0x35:   inc_dec=1;  Write_byte(REGISTER_HL , SUB_Bytes(Read_byte(REGISTER_HL),0x1) );   break;
       case 0x36:   Write_byte(REGISTER_HL , Fetch_byte() );    break;
       case 0x37:   register_f = register_f | 0x01;    break;
       case 0x38:   break; // NOP
       case 0x39:   Writeback_Reg16(REG_HL , ADD_Words(REGISTER_HL , register_sp) );    break;
       case 0x3a:   temp8 = Fetch_byte();  register_a = Read_byte((temp8|(Fetch_byte()<<8)));    break;
       case 0x3B:   register_sp--;     break;
       case 0x3C:   inc_dec=1;  register_a = ADD_Bytes(register_a , 0x1);   break;
       case 0x3D:   inc_dec=1;  register_a = SUB_Bytes(register_a , 0x1);     break;
       case 0x3E:   register_a = Fetch_byte();    break;
       case 0x3F:   temp8 = register_f & 0x01;  register_f = register_f & 0xFE;  if (temp8==0) register_f = register_f | 0x01;     break;
       case 0x40:   break; // NOP
       case 0x41:   register_b = register_c;    break;
       case 0x42:   register_b = register_d;    break;
       case 0x43:   register_b = register_e;     break;
       case 0x44:   register_b = register_h;    break;
       case 0x45:   register_b = register_l;    break;
       case 0x46:   register_b = Read_byte(REGISTER_HL);    break;
       case 0x47:   register_b = register_a;     break;
       case 0x48:   register_c = register_b;    break;
       case 0x49:   break; // NOP
       case 0x4A:   register_c = register_d;    break;
       case 0x4B:   register_c = register_e;     break;
       case 0x4C:   register_c = register_h;    break;
       case 0x4D:   register_c = register_l;    break;
       case 0x4E:   register_c = Read_byte(REGISTER_HL);   break;
       case 0x4F:   register_c = register_a;    break;
       case 0x50:   register_d = register_b;     break;
       case 0x51:   register_d = register_c;    break;
       case 0x52:   break; // NOP
       case 0x53:   register_d = register_e;    break;
       case 0x54:   register_d = register_h;    break;
       case 0x55:   register_d = register_l;    break;
       case 0x56:   register_d = Read_byte(REGISTER_HL);    break;
       case 0x57:   register_d = register_a;    break;
       case 0x58:   register_e = register_b;    break;
       case 0x59:   register_e = register_c;    break;
       case 0x5A:   register_e = register_d;    break;
       case 0x5B:   register_e = register_e;    break;
       case 0x5C:   register_e = register_h;    break;
       case 0x5D:   register_e = register_l;    break;
       case 0x5E:   register_e = Read_byte(REGISTER_HL);   break;
       case 0x5F:   register_e = register_a;    break;
       case 0x60:   register_h = register_b;    break;
       case 0x61:   register_h = register_c;    break;
       case 0x62:   register_h = register_d;    break;
       case 0x63:   register_h = register_e;    break;
       case 0x64:   register_h = register_h;     break;
       case 0x65:   register_h = register_l;    break;
       case 0x66:   register_h = Read_byte(REGISTER_HL);   break;
       case 0x67:   register_h = register_a;    break;
       case 0x68:   register_l = register_b;    break;
       case 0x69:   register_l = register_c;    break;
       case 0x6A:   register_l = register_d;    break;
       case 0x6B:   register_l = register_e;    break;
       case 0x6C:   register_l = register_h;    break;
       case 0x6D:   register_l = register_l;    break;
       case 0x6E:   register_l = Read_byte(REGISTER_HL);    break;
       case 0x6F:   register_l = register_a;    break;
       case 0x70:   Write_byte( REGISTER_HL, register_b );    break;
       case 0x71:   Write_byte( REGISTER_HL, register_c );    break;
       case 0x72:   Write_byte( REGISTER_HL, register_d );    break;
       case 0x73:   Write_byte( REGISTER_HL, register_e );    break;
       case 0x74:   Write_byte( REGISTER_HL, register_h );    break;
       case 0x75:   Write_byte( REGISTER_HL, register_l );     break;
       case 0x76:   halt_in_progress=1;  register_pc--;    break;
       case 0x77:   Write_byte( REGISTER_HL, register_a );    break;
       case 0x78:   register_a = register_b;   break;
       case 0x79:   register_a = register_c;     break;
       case 0x7A:   register_a = register_d;    break;
       case 0x7B:   register_a = register_e;    break;
       case 0x7C:   register_a = register_h;    break;
       case 0x7D:   register_a = register_l;    break;
       case 0x7E:   register_a = Read_byte(REGISTER_HL);    break;
       case 0x7F:   register_a = register_a;    break;
       case 0x80:   register_a = ADD_Bytes(register_a , register_b);     break;
       case 0x81:   register_a = ADD_Bytes(register_a , register_c);    break;
       case 0x82:   register_a = ADD_Bytes(register_a , register_d);    break;
       case 0x83:   register_a = ADD_Bytes(register_a , register_e);    break;
       case 0x84:   register_a = ADD_Bytes(register_a , register_h);    break;
       case 0x85:   register_a = ADD_Bytes(register_a , register_l);    break;
       case 0x86:   register_a = ADD_Bytes(register_a , Read_byte(REGISTER_HL));   break;
       case 0x87:   register_a = ADD_Bytes(register_a , register_a);    break;
       case 0x88:   with_carry=1; register_a = ADD_Bytes(register_a , register_b);    break;
       case 0x89:   with_carry=1; register_a = ADD_Bytes(register_a , register_c);    break;
       case 0x8A:   with_carry=1; register_a = ADD_Bytes(register_a , register_d);    break;
       case 0x8B:   with_carry=1; register_a = ADD_Bytes(register_a , register_e);    break;
       case 0x8C:   with_carry=1; register_a = ADD_Bytes(register_a , register_h);                break;
       case 0x8D:   with_carry=1; register_a = ADD_Bytes(register_a , register_l);                break;
       case 0x8E:   with_carry=1; register_a = ADD_Bytes(register_a , Read_byte(REGISTER_HL));    break;
       case 0x8F:   with_carry=1; register_a = ADD_Bytes(register_a , register_a);    break;
       case 0x90:   register_a = SUB_Bytes(register_a , register_b);    break;
       case 0x91:   register_a = SUB_Bytes(register_a , register_c);    break;
       case 0x92:   register_a = SUB_Bytes(register_a , register_d);    break;
       case 0x93:   register_a = SUB_Bytes(register_a , register_e);    break;
       case 0x94:   register_a = SUB_Bytes(register_a , register_h);                break;
       case 0x95:   register_a = SUB_Bytes(register_a , register_l);                break;
       case 0x96:   register_a = SUB_Bytes(register_a , Read_byte(REGISTER_HL));    break;
       case 0x97:   register_a = SUB_Bytes(register_a , register_a);    break;
       case 0x98:   with_carry=1; register_a = SUB_Bytes(register_a , register_b);         break;
       case 0x99:   with_carry=1; register_a = SUB_Bytes(register_a , register_c);         break;
       case 0x9A:   with_carry=1; register_a = SUB_Bytes(register_a , register_d);         break;
       case 0x9B:   with_carry=1; register_a = SUB_Bytes(register_a , register_e);         break;
       case 0x9C:   with_carry=1; register_a = SUB_Bytes(register_a , register_h);         break;
       case 0x9D:   with_carry=1; register_a = SUB_Bytes(register_a , register_l);         break;
       case 0x9E:   with_carry=1; register_a = SUB_Bytes(register_a , Read_byte(REGISTER_HL));    break;
       case 0x9F:   with_carry=1; register_a = SUB_Bytes(register_a , register_a);          break;
       case 0xA0:   register_f=register_f&0x02; if (((register_a|register_b)&0x08)!=0) register_f=register_f|0x10; register_a=(register_a & register_b); and_opcode=1; Flags_Boolean();    break;
       case 0xA1:   register_f=register_f&0x02; if (((register_a|register_c)&0x08)!=0) register_f=register_f|0x10; register_a=(register_a & register_c); and_opcode=1; Flags_Boolean();    break;
       case 0xA2:   register_f=register_f&0x02; if (((register_a|register_d)&0x08)!=0) register_f=register_f|0x10; register_a=(register_a & register_d); and_opcode=1; Flags_Boolean();    break;
       case 0xA3:   register_f=register_f&0x02; if (((register_a|register_e)&0x08)!=0) register_f=register_f|0x10; register_a=(register_a & register_e); and_opcode=1; Flags_Boolean();    break;
       case 0xA4:   register_f=register_f&0x02; if (((register_a|register_h)&0x08)!=0) register_f=register_f|0x10; register_a=(register_a & register_h); and_opcode=1; Flags_Boolean();    break;
       case 0xA5:   register_f=register_f&0x02; if (((register_a|register_l)&0x08)!=0) register_f=register_f|0x10; register_a=(register_a & register_l); and_opcode=1; Flags_Boolean();    break;
       case 0xA6:   temp8=Read_byte(REGISTER_HL); register_f=register_f&0x02; if (((register_a|temp8)&0x08)!=0) register_f=register_f|0x10; register_a=(register_a & temp8);  and_opcode=1; Flags_Boolean();    break;
       case 0xA7:   register_f=register_f&0x02; if (((register_a|register_a)&0x08)!=0) register_f=register_f|0x10; register_a=(register_a & register_a); and_opcode=1; Flags_Boolean();    break;       
       case 0xA8:   register_a=(register_a ^ register_b);                Flags_Boolean();    break;
       case 0xA9:   register_a=(register_a ^ register_c);                Flags_Boolean();    break;
       case 0xAA:   register_a=(register_a ^ register_d);                Flags_Boolean();    break;
       case 0xAB:   register_a=(register_a ^ register_e);                Flags_Boolean();    break;
       case 0xAC:   register_a=(register_a ^ register_h);                Flags_Boolean();    break;
       case 0xAD:   register_a=(register_a ^ register_l);                Flags_Boolean();    break;
       case 0xAE:   register_a=(register_a ^ Read_byte(REGISTER_HL));    Flags_Boolean();    break;
       case 0xAF:   register_a=(register_a ^ register_a);                Flags_Boolean();    break;
       case 0xB0:   register_a=(register_a | register_b);                Flags_Boolean();    break;
       case 0xB1:   register_a=(register_a | register_c);                Flags_Boolean();    break;
       case 0xB2:   register_a=(register_a | register_d);                Flags_Boolean();    break;
       case 0xB3:   register_a=(register_a | register_e);                Flags_Boolean();    break;
       case 0xB4:   register_a=(register_a | register_h);                Flags_Boolean();    break;
       case 0xB5:   register_a=(register_a | register_l);                Flags_Boolean();    break;
       case 0xB6:   register_a=(register_a | Read_byte(REGISTER_HL));    Flags_Boolean();    break;
       case 0xB7:   register_a=(register_a | register_a);                Flags_Boolean();    break;
       case 0xB8:   SUB_Bytes(register_a , register_b);                break;
       case 0xB9:   SUB_Bytes(register_a , register_c);                break;
       case 0xBA:   SUB_Bytes(register_a , register_d);                break;
       case 0xBB:   SUB_Bytes(register_a , register_e);                break;
       case 0xBC:   SUB_Bytes(register_a , register_h);                break;
       case 0xBD:   SUB_Bytes(register_a , register_l);                break;
       case 0xBE:   SUB_Bytes(register_a , Read_byte(REGISTER_HL));    break;
       case 0xBF:   SUB_Bytes(register_a , register_a);                break;
       case 0xC0:   if (flag_z == 0)      register_pc = Pop();    break;
       case 0xC1:   temp16 = Pop();   register_b  =(temp16>>8); register_c  =(temp16&0xFF);    break;
       case 0xC2:   if (flag_z == 0)                           {temp16 = Fetch_byte();  register_pc = (Fetch_byte()<<8) | temp16;}  else {register_pc = register_pc + 2;}   break;
       case 0xC3:   {temp16 = Fetch_byte();  register_pc = (Fetch_byte()<<8) | temp16;}    break;
       case 0xC4:   if (flag_z == 0) {     Push(register_pc+2); {temp16 = Fetch_byte();  register_pc = (Fetch_byte()<<8) | temp16;}   }  else {register_pc = register_pc + 2;}    break;
       case 0xC5:   Push(REGISTER_BC);    break;
       case 0xC6:   register_a = ADD_Bytes(register_a , Fetch_byte() );    break;
       case 0xC7:   Push(register_pc); register_pc = 0x00;    break;
       case 0xC8:   if (flag_z == 1)      register_pc = Pop();     break;
       case 0xC9:   register_pc = Pop();    break;
       case 0xCA:   if (flag_z == 1)                           {temp16 = Fetch_byte();  register_pc = (Fetch_byte()<<8) | temp16;}  else {register_pc = register_pc + 2;}     break;
       case 0xCB:   {temp16 = Fetch_byte();  register_pc = (Fetch_byte()<<8) | temp16;}    break;
       case 0xCC:   if (flag_z == 1) {     Push(register_pc+2); {temp16 = Fetch_byte();  register_pc = (Fetch_byte()<<8) | temp16;}   }  else {register_pc = register_pc + 2;}     break;
       case 0xCD:   Push(register_pc+2); {temp16 = Fetch_byte();  register_pc = (Fetch_byte()<<8) | temp16;}     break;
       case 0xCE:   with_carry=1; register_a = ADD_Bytes(register_a , Fetch_byte() );    break;
       case 0xCF:   Push(register_pc); register_pc = 0x08;    break;
       case 0xD0:   if (flag_c == 0)      register_pc = Pop();    break;
       case 0xD1:   temp16 = Pop();    register_d  =(temp16>>8); register_e  =(temp16&0xFF);    break;
       case 0xD2:   if (flag_c == 0)                           {temp16 = Fetch_byte();  register_pc = (Fetch_byte()<<8) | temp16;}  else {register_pc = register_pc + 2;}     break;
       case 0xD3:   BIU_Bus_Cycle(IO_WRITE_BYTE , Fetch_byte() ,      register_a );    break;
       case 0xD4:   if (flag_c == 0) {     Push(register_pc+2); {temp16 = Fetch_byte();  register_pc = (Fetch_byte()<<8) | temp16;}   }  else {register_pc = register_pc + 2;}     break;
       case 0xD5:   Push(REGISTER_DE);    break;
       case 0xD6:   register_a = SUB_Bytes(register_a , Fetch_byte() );    break;
       case 0xD7:   Push(register_pc); register_pc = 0x10;    break;
       case 0xD8:   if (flag_c == 1)      register_pc = Pop();    break;
       case 0xD9:   register_pc = Pop();    break;
       case 0xDA:   if (flag_c == 1)                           {temp16 = Fetch_byte();  register_pc = (Fetch_byte()<<8) | temp16;}  else {register_pc = register_pc + 2;}     break;
       case 0xDB:   register_a = BIU_Bus_Cycle(IO_READ_BYTE , Fetch_byte()  , 0x00 );   break;
       case 0xDC:   if (flag_c == 1) {     Push(register_pc+2); {temp16 = Fetch_byte();  register_pc = (Fetch_byte()<<8) | temp16;}   }  else {register_pc = register_pc + 2;}    break;
       case 0xDD:   Push(register_pc+2); {temp16 = Fetch_byte();  register_pc = (Fetch_byte()<<8) | temp16;}     break;
       case 0xDE:   with_carry=1; register_a = SUB_Bytes(register_a , Fetch_byte() );    break;
       case 0xDF:   Push(register_pc); register_pc = 0x18;     break;
       case 0xE0:   if (flag_p == 0)      register_pc = Pop();    break;
       case 0xE1:   temp16 = Pop();   register_h  =(temp16>>8); register_l  =(temp16&0xFF);    break;
       case 0xE2:   if (flag_p == 0)                           {temp16 = Fetch_byte();  register_pc = (Fetch_byte()<<8) | temp16;}  else {register_pc = register_pc + 2;}    break;
       case 0xE3:   temp8=Read_byte(register_sp);    Write_byte(register_sp  ,register_l);    register_l=temp8; temp8=Read_byte(register_sp+1);  Write_byte(register_sp+1,register_h);    register_h=temp8;    break;
       case 0xE4:   if (flag_p == 0) {     Push(register_pc+2); {temp16 = Fetch_byte();  register_pc = (Fetch_byte()<<8) | temp16;}   }  else {register_pc = register_pc + 2;}     break;
       case 0xE5:   Push(REGISTER_HL);    break;
       case 0xE6:   temp8=Fetch_byte(); register_f=register_f&0x02; if (((register_a|temp8)&0x08)!=0) register_f=register_f|0x10; register_a=(register_a & temp8);  and_opcode=1; Flags_Boolean();    break;       
       case 0xE7:   Push(register_pc); register_pc = 0x20;    break;
       case 0xE8:   if (flag_p == 1)      register_pc = Pop();    break;
       case 0xE9:   register_pc = (REGISTER_HL);    break;
       case 0xEA:   if (flag_p == 1)                           {temp16 = Fetch_byte();  register_pc = (Fetch_byte()<<8) | temp16;}  else {register_pc = register_pc + 2;}     break;
       case 0xEB:   temp8=register_d; register_d=register_h;  register_h=temp8;     temp8=register_e; register_e=register_l;  register_l=temp8;    break;
       case 0xEC:   if (flag_p == 1) {     Push(register_pc+2); {temp16 = Fetch_byte();  register_pc = (Fetch_byte()<<8) | temp16;}   }  else {register_pc = register_pc + 2;}      break;
       case 0xED:   Push(register_pc+2); {temp16 = Fetch_byte();  register_pc = (Fetch_byte()<<8) | temp16;}     break;
       case 0xEE:   register_a=(register_a ^ Fetch_byte());              Flags_Boolean();    break;
       case 0xEF:   Push(register_pc); register_pc = 0x28;    break;
       case 0xF0:   if (flag_s == 0)      register_pc = Pop();    break;
       case 0xF1:   temp16 = Pop();   register_a  =(temp16>>8); register_f  =((temp16&0xD7)|0x02);    break;
       case 0xF2:   if (flag_s == 0)                           {temp16 = Fetch_byte();  register_pc = (Fetch_byte()<<8) | temp16;}  else {register_pc = register_pc + 2;}     break;
       case 0xF3:   register_iff=0;    break;
       case 0xF4:   if (flag_s == 0) {     Push(register_pc+2); {temp16 = Fetch_byte();  register_pc = (Fetch_byte()<<8) | temp16;}   }  else {register_pc = register_pc + 2;}      break;
       case 0xF5:   Push(REGISTER_AF|0x02);    break;
       case 0xF6:   register_a=(register_a | Fetch_byte());              Flags_Boolean();    break;
       case 0xF7:   Push(register_pc); register_pc = 0x30;    break;
       case 0xF8:   if (flag_s == 1)      register_pc = Pop();    break;
       case 0xF9:   register_sp = ((register_h  <<8) | register_l  );     break;
       case 0xFA:   if (flag_s == 1)                           {temp16 = Fetch_byte();  register_pc = (Fetch_byte()<<8) | temp16;}  else {register_pc = register_pc + 2;}     break;
       case 0xFB:   register_iff=1;     break;
       case 0xFC:   if (flag_s == 1) {     Push(register_pc+2); {temp16 = Fetch_byte();  register_pc = (Fetch_byte()<<8) | temp16;}   }  else {register_pc = register_pc + 2;}     break;
       case 0xFD:   Push(register_pc+2); {temp16 = Fetch_byte();  register_pc = (Fetch_byte()<<8) | temp16;}     break;   
       case 0xFE:   SUB_Bytes(register_a , Fetch_byte() );    break;
       case 0xFF:   Push(register_pc); register_pc = 0x38;    break;
      }
}

// ** End main loop

}
    
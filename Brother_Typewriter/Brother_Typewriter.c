//
//
// File Name : Brother_Typewriter.c
// Author : Ted Fried, MicroCore Labs
// Creation : 8/27/2020
// Code Type : Synthesizable
//
// Description:
// ============
//  
// Arduino-Leonardo converter for UART to Brother Word Processor Typewriter
//
//
//------------------------------------------------------------------------

#define SHIFT_ON 0x80
#define SHIFT_OFF 0x81


unsigned int char_count=0;  
unsigned int decoded_character=0;  
unsigned int uart_character=0;  




byte decoder_array[128] = {
/*       0     1     2     3     4     5     6     7     8     9   */
/* 0 */ 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
/* 1 */ 0xb0, 0x00, 0x00, 0xb0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
/* 2 */ 0x00, 0x49, 0x4b, 0x38, 0x37, 0x39, 0x3f, 0x4c, 0x23, 0x16,
/* 3 */ 0x0c, 0x8c, 0x04, 0x8c, 0xe4, 0xcc, 0x2c, 0xac, 0xec, 0xe4,
/* 4 */ 0x9c, 0x0c, 0x1c, 0xbc, 0xe4, 0xb4, 0x74, 0xf4, 0x0c, 0x8c,
/* 5 */ 0x4c, 0xcc, 0x2c, 0xac, 0x6c, 0xec, 0x1c, 0x9c, 0xdc, 0xdc,
/* 6 */ 0x00, 0xbc, 0x59, 0xf4, 0x4c, 0x86, 0x46, 0xc6, 0x26, 0xa6,
/* 7 */ 0x66, 0xe6, 0x16, 0x96, 0x56, 0xd6, 0x36, 0xb6, 0x76, 0xf6,
/* 8 */ 0x0e, 0x8e, 0x4e, 0xce, 0x2e, 0xae, 0x6e, 0xee, 0x1e, 0x9e,
/* 9 */ 0x5e, 0xba, 0x03, 0xba, 0x5e, 0xb4, 0x53, 0x86, 0x46, 0xc6,
/* 10 */ 0x26, 0xa6, 0x66, 0xe6, 0x16, 0x96, 0x56, 0xd6, 0x36, 0xb6,
/* 11 */ 0x76, 0xf6, 0x0e, 0x8e, 0x4e, 0xce, 0x2e, 0xae, 0x6e, 0xee,
/* 12 */ 0x1e, 0x9e, 0x5e, 0xba, 0x5e, 0xba, 0x53, 0x55 };



//------------------------------------------------------------------------
//------------------------------------------------------------------------

void setup()
{
  Serial.begin(300);    // UART to the Host
  pinMode (10, INPUT) ; // hi-Z the CLK Pin
  pinMode (11, INPUT) ; // hi-Z the DATA Pin
  pinMode (12, OUTPUT) ;  
}

//------------------------------------------------------------------------
//------------------------------------------------------------------------

void pause()
{
  digitalWrite(12, LOW);
  digitalWrite(12, LOW);
  digitalWrite(12, LOW);
  digitalWrite(12, LOW);
  digitalWrite(12, LOW);
  return;
}


//------------------------------------------------------------------------
//------------------------------------------------------------------------

void send_to_typewriter(unsigned char char_out)
{

  // Shift out the converted byte to the typewriter.
  // Send as "open collector", or drive logic '0', but
  // let bus go high-impedance (turn off IO output) for logic '1'
  //
  
  if ((char_out&0x80) != 0) pinMode (11, INPUT); else pinMode (11, OUTPUT); pause(); // DATA 7
  pinMode (10, OUTPUT); pause(); // CLK = 0
  pinMode (10, INPUT); pause(); // CLK = hi-Z
 
  if ((char_out&0x40) != 0) pinMode (11, INPUT); else pinMode (11, OUTPUT); pause(); // DATA 6
  pinMode (10, OUTPUT); pause(); // CLK = 0
  pinMode (10, INPUT); pause(); // CLK = hi-Z
 
  if ((char_out&0x20) != 0) pinMode (11, INPUT); else pinMode (11, OUTPUT); pause(); // DATA 5
  pinMode (10, OUTPUT); pause(); // CLK = 0
  pinMode (10, INPUT); pause(); // CLK = hi-Z
 
  if ((char_out&0x10) != 0) pinMode (11, INPUT); else pinMode (11, OUTPUT); pause(); // DATA 4
  pinMode (10, OUTPUT); pause(); // CLK = 0
  pinMode (10, INPUT); pause(); // CLK = hi-Z
 
  if ((char_out&0x08) != 0) pinMode (11, INPUT); else pinMode (11, OUTPUT); pause(); // DATA 3
  pinMode (10, OUTPUT); pause(); // CLK = 0
  pinMode (10, INPUT); pause(); // CLK = hi-Z
 
  if ((char_out&0x04) != 0) pinMode (11, INPUT); else pinMode (11, OUTPUT); pause(); // DATA 2
  pinMode (10, OUTPUT); pause(); // CLK = 0
  pinMode (10, INPUT); pause(); // CLK = hi-Z
 
  if ((char_out&0x02) != 0) pinMode (11, INPUT); else pinMode (11, OUTPUT); pause(); // DATA 1
  pinMode (10, OUTPUT); pause(); // CLK = 0
  pinMode (10, INPUT); pause(); // CLK = hi-Z
 
  if ((char_out&0x01) != 0) pinMode (11, INPUT); else pinMode (11, OUTPUT); pause(); // DATA 0
  pinMode (10, OUTPUT); pause(); // CLK = 0
  pinMode (10, INPUT); pause(); // CLK = hi-Z

 
  pinMode (11, INPUT) ; // hi-Z the DATA Pin

  return;
}

  
//------------------------------------------------------------------------
//------------------------------------------------------------------------

void caps_on(unsigned char char_in)  
{
  // Send the SHIFT key to the typewriter if required.
  //
  if (uart_character>62 && uart_character<92) send_to_typewriter(SHIFT_ON);
  if (uart_character!=39 && uart_character>32 && uart_character<44) send_to_typewriter(SHIFT_ON);
  return;
}

//------------------------------------------------------------------------
//------------------------------------------------------------------------

void caps_off(unsigned char char_in)  
{
  // Debounce the SHIFT key to the typewriter.
  //
  if (uart_character>62 && uart_character<92) send_to_typewriter(SHIFT_OFF);
  if (uart_character!=39 && uart_character>32 && uart_character<44) send_to_typewriter(SHIFT_OFF);
  return;
}

//------------------------------------------------------------------------
//------------------------------------------------------------------------

void loop()
{

  // Poll the Host-side UART for characters to send to the typewriter.
  // Decode the ASCII characters into the sequence of commands to send to the typewriter.
  //
  if (Serial.available())
  {
  uart_character = Serial.read();
  decoded_character = decoder_array[uart_character];

  caps_on(uart_character);
  delay(1);
  send_to_typewriter(decoded_character);
  delay(1);
  caps_off(uart_character);
  delay(1);

  }
 
}
 
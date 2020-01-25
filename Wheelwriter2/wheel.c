
//
//
//  File Name   :  wheelwriter.v
//  Author      :  Ted Fried, MicroCore Labs
//  Creation    :  11/8/2019
//  Code Type   :  Synthesizable
//
//   Description:
//   ============
//   
// Arduino-Leonardo version of the Printer Option for the IBM Wheelwriter
//
// Connects Arduino Leonardo with host UART at 300 baud and to the typewriter at 188k baud.
//
// This design uses the second Arduino UART in 9-bit mode to transmit data to the typewriter.
//
// It translates ASCII characters received by the host into a sequence of commands which are sent
// to the IBM Wheelwriter typewriter over the IBM_BUS interface.
//
// Characters will print to the typeriter as they are received from the host. 
// You can cut and paste long documents into the terminal if you add a delay between characters.
//
//------------------------------------------------------------------------
//
// Version History:
// ================
//
// Revision 1 11/8/19
// Initial revision
//
//
//------------------------------------------------------------------------
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


byte array_in_pointer=0;
byte array_out_pointer=0;
byte ibm_decoded_character=0;
byte ibm_cycle_in_progress=0;
unsigned int char_count=0;   
unsigned int ibm_command_array[200];


byte ibm_decoder[128] =  
    {0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x99, 0x00, 0x00, 0x99, 0x00, 0x00,
     0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
     0x00, 0x49, 0x4b, 0x38, 0x37, 0x39, 0x3f, 0x4c, 0x23, 0x16, 0x36, 0x3b, 0x0c, 0x0e, 0x57, 0x28,
     0x30, 0x2e, 0x2f, 0x2c, 0x32, 0x31, 0x33, 0x35, 0x34, 0x2a ,0x4e, 0x50, 0x00, 0x4d, 0x00, 0x4a,
     0x3d, 0x20, 0x12, 0x1b, 0x1d, 0x1e, 0x11, 0x0f, 0x14, 0x1F, 0x21, 0x2b, 0x18, 0x24, 0x1a, 0x22,
     0x15, 0x3e, 0x17, 0x19, 0x1c, 0x10, 0x0d, 0x29, 0x2d, 0x26, 0x13, 0x41, 0x00, 0x40, 0x00, 0x4f,
     0x00, 0x01, 0x59, 0x05, 0x07, 0x60, 0x0a, 0x5a, 0x08, 0x5d, 0x56, 0x0b, 0x09, 0x04, 0x02, 0x5f,
     0x5c, 0x52, 0x03, 0x06, 0x5e, 0x5b, 0x53, 0x55, 0x51, 0x58, 0x54, 0x00, 0x00, 0x00, 0x00, 0x00 };

//------------------------------------------------------------------------
//------------------------------------------------------------------------

void setup() 
{
  Serial.begin(300);     // UART to the Host
  Serial1.begin(188679); // UART to the IBM Wheelwriter IBM_BUS
}

//------------------------------------------------------------------------
//------------------------------------------------------------------------

void loop() 
{

  // Once the transmitter has completed sending the command to the IBM_BUS, 
  //  disable the TX output pin and wait for 2 milliseconds while the typewriter asserts ACK
  //
  if (ibm_cycle_in_progress==1 && ((UCSR1A & 0x40)>0)) // Wait for transmit to complete before making the TX pin hi-Z
    {
      pinMode (1, INPUT) ; // hi-Z the TX Pin  
      delay(2);
      ibm_cycle_in_progress=0;
    }


  // When the Command FIFO array is not empty, send the data out on Serial1 to the IBM_BUS
  // Simulate open collector by enabling/disabling the serial TX pin and making it an input for hi-Z
  // Send 9 bits per transaction to the TX UART
  // Support delays inserted into the command sequence

  if (ibm_cycle_in_progress==0 && (array_in_pointer != array_out_pointer))
    {
      // Each time we send a Command word to IBM we re-initialize the 
      // TX pin as a UART output and configure for 9-bit data width.
      //
      Serial1.begin(188679);
      UCSR1B = UCSR1B | 0x04; // Or in the Z bit[2]
      UCSR1C = UCSR1C | 0x06; // Or in the Z bit[1:0]
  
      // Set the 9th bit of the transmit word
      if (ibm_command_array[array_out_pointer] > 0x00FF)
        {
         UCSR1B = UCSR1B | 0x01; // Set TX bit[8]
        }
      else
        {
         UCSR1B = UCSR1B & 0xFE; // Clear TX bit[8]
        }

      // Write the lower byte into the UART TX which begins the transmit
      //
      Serial1.write(ibm_command_array[array_out_pointer] & 0x00FF);
         

      // Disable the UART Transmiter in preparation for IBM sending an ACK on the Bus
      // This will take effect when the serial transmit has completed.
      //
      UCSR1B = UCSR1B & 0xF7;
      ibm_cycle_in_progress=1;
      array_out_pointer = array_out_pointer + 1;
      }


  // When the pointers catch up to each other, zero them both out
  //
  if (array_in_pointer==array_out_pointer)
    {
      array_in_pointer=0;
      array_out_pointer=0;
    }


  // Poll the Host-side UART for characters to send to the typewriter.
  // Decode the ASCII characters into the sequence of commands to send to the typewriter.
  //
  if (Serial.available())
    {
      ibm_decoded_character = ibm_decoder[Serial.read()];

      if (ibm_decoded_character!=0x99) 
        {
          ibm_command_array[array_in_pointer ++] = 0x0121;
          ibm_command_array[array_in_pointer ++] = 0x000B;
          ibm_command_array[array_in_pointer ++] = 0x0121;
          ibm_command_array[array_in_pointer ++] = 0x0003;
          ibm_command_array[array_in_pointer ++] = ibm_decoded_character;
          ibm_command_array[array_in_pointer ++] = 0x000A;
          char_count = char_count + 0x000A;
        }
      else
        {
          if (char_count==0) {char_count=0x8000;}
          ibm_command_array[array_in_pointer ++] = 0x0121;  // Carriage Return Command sequence
          ibm_command_array[array_in_pointer ++] = 0x000B;
          ibm_command_array[array_in_pointer ++] = 0x0121;
          ibm_command_array[array_in_pointer ++] = 0x000D;
          ibm_command_array[array_in_pointer ++] = 0x0007;
          ibm_command_array[array_in_pointer ++] = 0x0121;
          ibm_command_array[array_in_pointer ++] = 0x0006;
          ibm_command_array[array_in_pointer ++] = (char_count  >>  8   );
          ibm_command_array[array_in_pointer ++] = (char_count  & 0x00FF);
          ibm_command_array[array_in_pointer ++] = 0x0121;
          ibm_command_array[array_in_pointer ++] = 0x0005;
          ibm_command_array[array_in_pointer ++] = 0x0090;
          char_count=0;
        }   
    }
 
}
   

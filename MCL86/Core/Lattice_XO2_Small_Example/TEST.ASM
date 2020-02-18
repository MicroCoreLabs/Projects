			
			org 0000			; Force A86 to locate code at address 0x0000
			
SETUP:		mov si, HELLO_MSG	; Load pointer to the Hello Message
			mov SP,00600		; Locate the stack pointer
			mov ax,cs			; Locate the Data Segment to CS
			mov ds,ax		
			
			
; Print the Hello Message			
PRINT_MSG:	lodsb				; Load a character into AL
			cmp al,024			; Look for the $ which ends the string
			je MENU_POLL
			mov bl,al
			call PRINT_CHAR
			jmp PRINT_MSG
			
			
MENU_POLL:	in	al,001			; Load the UART Status register		
			and al,001			; Isolate the RX_BYTE_AVAILABLE bit	
			jz MENU_POLL
			in al,000			; Retrieve the byte from the UART_RX Buffer
			mov bl,al
			call PRINT_CHAR		; echo the keypress back to the host
			
			cmp bl,031			; Check for an ASCII 1
			je LEDS_ON
			cmp bl,032			; Check for an ASCII 2
			je LEDS_OFF
			cmp bl,033			; Check for an ASCII 3
			je PRT_ASCII
			cmp bl,034			; Check for an ASCII 4
			je SETUP
			
			jmp MENU_POLL		; Otherwise loop back to beginning
			
			
LEDS_ON:	mov al,000
			out 003, al			; LEDS are located at UART register 0x3
			jmp MENU_POLL

LEDS_OFF:	mov al,0FF
			out 003, al			; LEDS are located at UART register 0x3
			jmp MENU_POLL

			
			
; Print the ASCII Table
PRT_ASCII:  mov bl,021
			mov cx,05C
L1:			call PRINT_CHAR
			inc bl
			loop L1
			mov bl,13
			call PRINT_CHAR
			mov bl,10
			call PRINT_CHAR
			jmp MENU_POLL
			
; Print Character
PRINT_CHAR:	in	al,001			; Load the UART Status register
			and al,002			; Isolate the TX_BUSY bit
			jnz PRINT_CHAR
			mov al,bl
			out 002,al
			ret

			
			
HELLO_MSG: 	db 27, "[2J", 27, "[H", 13, 10
            db " __  __  _____ _      ___    __  " , 13, 10
            db "|  \/  |/ ____| |    / _ \  / /  " , 13, 10
            db "| \  / | |    | |   | (_) |/ /_  " , 13, 10
            db "| |\/| | |    | |    > _ <| '_ \ " , 13, 10
            db "| |  | | |____| |___| (_) | (_) |" , 13, 10
            db "|_|  |_|\_____|______\___/ \___/ " , 13, 10, 13, 10,13,10
			db "Hello from MicroCore Labs !!!" , 13, 10
			db "-----------------------------" , 13, 10, "   ", 13, 10
			db "This is the MCL86 core running on the Lattice XO2 Breakout Board.", 13, 10
			db "     ", 13, 10
			db "     ", 13, 10
			db " Press:", 13, 10
			db "        1) Turn on LEDs", 13, 10
			db "        2) Turn off LEDs", 13, 10
			db "        3) Print ASCII characters", 13, 10
			db "        4) Refresh screen", 13, 10
			db "        All other keys will be echoed back", 13, 10
			db "     ", 13, 10
			db "$"
			

 
/* Program to display 2-digit decimal counter on HEX1-0*/

				.text                   	// executable code follows
				.global _start     			  
_start:                             
				LDR		R0, =0xFF200000		// R0 holds LED address
				
				
INITIALIZE:		MOV		R1, #0				// R1 holds value zero
				LDR		R2, [R0, #0x5C]		// Read Edgecapture register for KEYs
				CMP		R2, #0
				BEQ		INITIALIZE			// Wait for KEY to be pressed
				MVN		R2, #0				// R2 holds #0XFFFFFFFF
				STR		R2, [R0, #0x5C]		// Reset Edgecapture register for KEYs
				B		DIVIDE		
				
				
INCREMENT:		BL		CHECK_KEY			// Keep checking for a KEY press
				BL		DO_DELAY			// For 0.25 second delay
				ADD		R1, #1				// Increment R1
				CMP		R1, #100			// Check if R1 passed 2 digit limit
				MOVEQ	R1, #0				// R1 restarts from zero if limit passed
				B		DIVIDE				// To get each decimal digit to display


DO_DELAY:		LDR		R2, =200000000		// Delay counter
SUB_LOOP:		SUBS	R2, R2, #1			// Decrement delay counter
				BNE		SUB_LOOP			// Repeat until counter reaches zero
				MOV		PC, LR				// Return to increment R1
				
				
DIVIDE:			MOV		R2,	#0				// R2 will store tens digit for number to display
				MOV		R3,	#10				// To divide counter value by 10
				PUSH	{R1}				// Keep track of counter progress
LOOP:			CMP		R1, R3
				BLT		DISPLAY				// R1 will store ones digit for number to display
				SUB		R1, R3
				ADD		R2, #1
				B		LOOP			  
				
				
DISPLAY:		BL		SEG7_CODE
				LSL		R3, R2, #8
				MOV		R2, R1
				BL		SEG7_CODE
				ADD		R3, R2				// R3 holds pattern code for 2-digit decimal
				STR		R3, [R0, #0x20]		// HEX1-0 displayS 2-digit decimal number
				POP		{R1}
				B		INCREMENT
				
				
SEG7_CODE:		PUSH	{R1}
				MOV     R1, #BIT_CODES  
				ADD     R1, R2         		// index into the BIT_CODES "array"
				LDRB    R2, [R1]       		// load the bit pattern (to be returned)
				POP		{R1}
				MOV     PC, LR         		// Return to display number on display   
				
				
CHECK_KEY:		PUSH	{R1}
				LDR		R1, [R0, #0x5C]		// Read Edgecapture register for KEYs
				CMP		R1, #0
				BEQ		RETURN				// Continue counting if no KEY pressed
				
				
RESET:			MVN		R1, #0				// R1 holds #0XFFFFFFFF
				STR		R1, [R0, #0x5C]		// Reset Edgecapture register for KEYs
				POP		{R1}
				B		INITIALIZE
				
				
RETURN:			POP		{R1}
				MOV		PC, LR
				


BIT_CODES:		.byte   0b00111111, 0b00000110, 0b01011011, 0b01001111, 0b01100110
				.byte   0b01101101, 0b01111101, 0b00000111, 0b01111111, 0b01100111		
				
				.end                            
		  
		  
		  
  
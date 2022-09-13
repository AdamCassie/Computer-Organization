/* Program to display decimal digit on HEX0*/

				.text                   	// executable code follows
				.global _start     			  
_start:                             
				LDR		R0, =0xFF200000		// R0 holds LED address
				MOV		R1, #0				// R1 holds value zero
				STR		R1, [R0, #0x20]		// Blank HEX3-0
				STR		R1, [R0, #0x30]		// Blank HEX5-4
				MOV		R4, #0				// Flag to check if Display is blank


CHECK:			LDR		R1, [R0, #0x50]		// Read KEYs
				
				CMP		R1, #0b0001			// Check if KEY0 is pressed
				BEQ		DISPLAY				// Branch to subroutine to display 0 on HEX0
				
				CMP		R1, #0b0010			// Check if KEY1 is pressed
				BEQ		INCREMENT			// Branch to subroutine to increment number on HEX0
				
				CMP		R1, #0b0100			// Check if KEY2 is pressed
				BEQ		DECREMENT			// Branch to subroutine to decrement number on HEX0
				
				CMP		R1, #0b1000			// Check if KEY3 is pressed
				BEQ		BLANK				// Branch to subroutine to blank HEX0
				
				B		CHECK				// Keep checking value on KEYs


DISPLAY:		LDR		R1, [R0, #0x50]		// Read KEYs
				CMP		R1, #0b0000			// Check if KEYs released
				BNE		DISPLAY				// Wait for KEYs to be released
				MOV		R2, #0				// R2 holds the value zero
				BL		SEG7_CODE
				STR		R2, [R0, #0x20]		// HEX0 has pattern for 0
				MOV		R4, #1				// Set flag since display in no longer blank
				MOV		R3, #0				// Store current HEX value in R3
				B		CHECK
				
				
INCREMENT:		LDR		R1, [R0, #0x50]		// Read KEYs
				CMP		R1, #0b0000			// Check if KEYs released
				BNE		INCREMENT			// Wait for KEYs to be released
				//LDRB	R2, [R0, #0x20]		// R2 holds value shown on HEX0
				CMP		R4, #0				// Check if display is blank
				BEQ		CHECK
				ADDS	R3, #1				// Increment value to be shown
				CMP		R3, #9
				MOVGT	R3, #0
				MOV		R2, R3
				BL		SEG7_CODE
				STR		R2, [R0, #0x20]		// HEX0 holds incremented value
				B		CHECK
			
			
DECREMENT:		LDR		R1, [R0, #0x50]		// Read KEYs
				CMP		R1, #0b0000			// Check if KEYs released
				BNE		DECREMENT			// Wait for KEYs to be released
				//LDRB	R2, [R0, #0x20]		// R2 holds value shown on HEX0
				CMP		R4, #0				// Check if display is blank
				BEQ		CHECK
				SUBS	R3, #1				// Increment value in R2
				MOVLT	R3, #9
				MOV		R2, R3
				BL		SEG7_CODE
				STR		R2, [R0, #0x20]		// HEX0 holds decremented value
				B		CHECK


BLANK:			LDR		R1, [R0, #0x50]		// Read KEYs
				CMP		R1, #0b0000			// Check if KEYs released
				BNE		BLANK				// Wait for KEYs to be released
				MOV		R2, #0				// R2 holds the value zero

				
LOOP:			STR		R2, [R0, #0x20]		// Blank HEX0
				LDR		R1, [R0, #0x50]		// Read KEYs
				CMP		R1, #0b0000			// Check if any KEY is pressed
				BEQ		LOOP
				
ZERO:			LDR		R1, [R0, #0x50]		// Read KEYs
				CMP		R1, #0b0000			// Check if any KEY is pressed
				BNE		ZERO
				
				MOV		R3, #0
				BL		SEG7_CODE
				STR		R2, [R0, #0x20]		// HEX0 has pattern for 0

				
WAIT:			LDR		R1, [R0, #0x50]		// Read KEYs
				CMP		R1, #0b0000			// Check if KEYs released
				BNE		WAIT				// Wait for KEYs to be released
				B		CHECK
				
				
SEG7_CODE:		MOV     R1, #BIT_CODES  
				ADD     R1, R2         // index into the BIT_CODES "array"
				LDRB    R2, [R1]       // load the bit pattern (to be returned)
				MOV     PC, LR              


BIT_CODES:		.byte   0b00111111, 0b00000110, 0b01011011, 0b01001111, 0b01100110
				.byte   0b01101101, 0b01111101, 0b00000111, 0b01111111, 0b01100111
			  
				.end                            
		  
		  
		  
  
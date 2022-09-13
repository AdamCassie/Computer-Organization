/* Program that converts a binary number to decimal */
           .text               // executable code follows
           .global _start
_start:
            MOV    R4, #N
            MOV    R5, #Digits  // R5 points to the decimal digits storage location
            LDR    R4, [R4]     // R4 holds N
            MOV    R0, R4       // parameter for DIVIDE goes in R0
			MOV	   R1, #1000	// R1 holds the value 1000
            BL     DIVIDE1
            STRB   R3, [R5, #3] // Thousands digit is now in R3
			STRB   R2, [R5, #2] // Hundreds digit is now in R2
			STRB   R1, [R5, #1] // Tens digit is now in R1
            STRB   R0, [R5]     // Ones digit is in R0
END:        B      END

/* Subroutines to perform the integer division.
 * Returns: thousands place value in R3, hundreds place value in R2,
 *			tens place value in R1, remainder in R0
*/
DIVIDE1:    MOV    R6, #0
CONT1:      CMP    R0, R1
            BLT    DIVIDE2
            SUB    R0, R1
            ADD    R6, #1
            B      CONT1
			
DIVIDE2:    MOV    R7, #0
			MOV	   R1, #100
CONT2:      CMP    R0, R1
            BLT    DIVIDE3
            SUB    R0, R1
            ADD    R7, #1
            B      CONT2
			
DIVIDE3:    MOV    R8, #0
			MOV    R1, #10
CONT3:      CMP    R0, R1
            BLT    DIV_END
            SUB    R0, R1
            ADD    R8, #1
            B      CONT3
			
DIV_END:    MOV    R1, R8     	// tens place value in R1 (remainder in R0)
			MOV    R2, R7     	// hundreds place value in R2 
			MOV    R3, R6     	// thousands place value in R1 
            MOV    PC, LR

N:          .word  9876       	// the decimal number to be converted
Digits:     .space 4          	// storage space for the decimal digits

            .end

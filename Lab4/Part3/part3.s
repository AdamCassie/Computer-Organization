/* Program that counts consecutive 1's, 0's and alternating patterns of 1's with 0's */

			  .text                   // executable code follows
			  .global _start     			  
_start:                             
			  MOV     R2, #TEST_NUM   // load the data word into R2
			  MOV 	  R8, #ALT_NUM	  // R8 points to word of alternating 1's and 0's
			  
			  MOV	  R9, #0		  // R9 will hold longest string of ones in any word
			  MOV	  R10, #0		  // R10 will hold longest string of zeros in any word
			  MOV	  R11, #0		  // R11 will hold longest string of ones alternating with zeros in any word
		  

LOOP:	  	  LDR     R1, [R2], #4    // R1 receives input word, post increment R2
			  CMP	  R1, #0		  // check if all items processed
			  BEQ	  END
			  
			  // Call to ONES here
			  MOV     R5, #0          // R5 will hold the result for ONES
			  MOV	  R4, R1		  // R4 holds input word
			  BL	  ONES			  // branch and link to ONES
			  CMP	  R5, R9		  // check for new longest string of ones
			  MOVGE	  R9, R5		  // store new longest string in R9
			  
			  // Call to ZEROS here
			  MOV     R6, #0          // R6 will hold the result for ZEROS
			  MVN	  R4, R1		  // R4 holds complement of input word
			  BL	  ZEROS			  // branch and link to ZEROS
			  CMP	  R6, R10		  // check for new longest string of zeros
			  MOVGE	  R10, R6		  // store new longest string in R10
			  
			  // Call to ALTERNATE here
			  MOV	  R7, #0		  // R7 will hold the result for ALTERNATE
			  LDR	  R4, [R8]		  // R4 holds an alternating number
			  EOR	  R4, R1 	 	  // R4 holds input word xor'ed with an alternating number
			  BL 	  ALTERNATE	      // branch and link to ZEROS
			  CMP	  R7, R11		  // check for new longest string of zeros
			  MOVGE	  R11, R7		  // store new longest string in R10
			  
			  B 	  LOOP


ONES:	 	  CMP     R4, #0          // loop until the data contains no more 1's
			  MOVEQ	  PC, LR          // return to ONES if R2 is zero 
			  LSR     R3, R4, #1      // perform SHIFT, followed by AND
			  AND     R4, R4, R3      
			  ADD     R5, #1          // count the string length so far
			  B       ONES      
    
	
ZEROS:	  	  CMP     R4, #0          // loop until the data contains no more 1's
			  MOVEQ	  PC, LR          // return to ONES if R2 is zero 
			  LSR     R3, R4, #1      // perform SHIFT, followed by AND
			  AND     R4, R4, R3      
			  ADD     R6, #1          // count the string length so far
			  B       ZEROS  


ALTERNATE:	  CMP     R4, #0          // loop until the data contains no more 1's
			  MOVEQ	  PC, LR          // return to ONES if R2 is zero 
			  LSR     R3, R4, #1      // perform SHIFT, followed by AND
			  AND     R4, R4, R3      
			  ADD     R7, #1          // count the string length so far
			  B       ALTERNATE  


END:      B       END             



ALT_NUM: .word 0x55555555


TEST_NUM: .word   0x103fe00f, 0x9a3fe20a, 0x1e36e003, 0x743f400f, 0x303f100a
		  .word   0xe45fe002, 0xb23fe052, 0x4067e0cf, 0xf0ffe00f, 0x00000000

          .end                            
		  
		  
		  
  
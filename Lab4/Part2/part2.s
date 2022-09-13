/* Program that counts consecutive 1's */

          .text                   // executable code follows
          .global _start                  
_start:                             
          MOV     R2, #TEST_NUM   // load the data word into R2
          MOV	  R5, #0		  // R5 will hold longest string of ones in any word
		  

LOOP:	  LDR     R1, [R2], #4    // R1 receives input word, post increment R2
		  CMP	  R1, #0		  // check if all items processed
		  BEQ	  END
		  MOV     R0, #0          // R0 will hold the result
		  BL	  ONES			  // branch and link to LOOP
		  CMP	  R0, R5		  // check for new longest string
		  MOVGE	  R5, R0		  // store new longest string in R5
		  B 	  LOOP
		  


ONES:	  CMP     R1, #0          // loop until the data contains no more 1's
          MOVEQ	  PC, LR          // return to LOOP if R1 is zero
          LSR     R3, R1, #1      // perform SHIFT, followed by AND
          AND     R1, R1, R3      
          ADD     R0, #1          // count the string length so far
          B       ONES      
    

END:      B       END             

TEST_NUM: .word   0x103fe00f, 0x9a3fe20a, 0x1e36e003, 0x743f400f, 0x303f100a
		  .word   0xe45fe002, 0xb23fe052, 0x4067e0cf, 0xf0ffe00f, 0x00000000

          .end                            
		  
		  
		  
  
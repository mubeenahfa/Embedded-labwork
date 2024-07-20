;*************************************************************** 
; Program_Directives.s  
; Copies the table from one location
; to another memory location.           
; Directives and Addressing modes are   
; explained with this program.   
;***************************************************************    
;*************************************************************** 
; EQU Directives
; These directives do not allocate memory
;***************************************************************
;LABEL      DIRECTIVE   VALUE       COMMENT
Numbern     EQU         0x200006F0
FIRST       EQU         0x20000680
BOUND       EQU         0x200006B0
GUESS       EQU         0x200006D0
	

;***************************************************************
; Directives - This Data Section is part of the code
; It is in the read only section  so values cannot be changed.
;***************************************************************
;LABEL      DIRECTIVE   VALUE       COMMENT
            AREA        sdata, DATA, READONLY
            THUMB
CTR1        DCB         0x0B
MSG         DCB         "Input N please..."
            DCB         0x0D
            DCB         0x04
MSGS        DCB         "I will guess now..."
            DCB         0x0D
            DCB         0x04
MSGD        DCB         "aha! I guessed it!"
            DCB         0x0D
            DCB         0x04
;***************************************************************
; Program section                         
;***************************************************************
;LABEL      DIRECTIVE   VALUE       COMMENT
            AREA        main, READONLY, CODE
            THUMB
            EXTERN      OutStr      ; Reference external subroutine 			
			EXTERN		InChar      ; Reference the external inchar subroutine
            EXPORT      __main      ; Make available


CONVRT      PROC 
	        PUSH        {LR}
start       MOV         R9,#10		;set divisor
            MOV         R8,#0   	;start counter
            LDR         R4,[R2]	;the number in question
loop        UDIV        R5,R4,R9			
            MUL         R6,R5,R9			
            SUBS        R7,R4,R6			;remainder calculation
           	BEQ         last              ;if last number
            BNE         notlast           ;if not last
notlast     PUSH        {R7}				;push to stack
            ADD         R8,R8,#1			;counter increment
            MOV         R4,R5            	
            BL          loop
last        PUSH        {R5}
            ADD         R8,R8,#1

            SUBS        R8,R8,#1
			POP         {R4}
            LDR         R2,=FIRST
prints      POP         {R4}				;pop stack
            MOV         R1,R4				;move to R1
			ADD         R1,R1,#0x30			;set to ascii value by adding 0x30
			STRB        R1,[R2]             ;store in content of R2
			ADD         R2,R2,#1			;increase R2 which originally pointed to FIRST memory location
			SUBS        R8,R8,#1			;decrement counter
			BNE         prints				;jump to prints again is looped if counter is not zero
			LDR         R1,=0x0D
			STRB        R1,[R2]
			ADD         R2,R2,#1
			LDR         R1,=0x04			;add the ending characters
			STR         R1,[R2]
            LDR         R0,=FIRST			;R0 now contains the memory location FIRST which contains printable string 
            BL          OutStr      ; Copy message
;Forever     B           start
            POP         {LR}
			BX          LR
			ENDP

__main      PROC 
	        LDR         R0,=MSG
			BL          OutStr
get         BL          InChar
	        LDR         R2,=BOUND	;BOUND stores lower bound
			MOV         R1,#1		; R1= 1
			STR         R1,[R2]		;put 1 in memory location of R2
			ADD         R2,R2,#4    ;bound +4 stores the max bound
			SUB         R0,R0,#48
loop_power  LSL         R1,R1,#1
            SUBS        R0,R0,#1
			BNE         loop_power
			
			
     		STR         R1,[R2]     ;stores R1 in bound+ 4 
			SUB         R2,R2,#4     ;set R2 to lower bound
			LDR         R3,[R2]       ;load lower bound into R3
loops		LDR         R0,=MSGS
			BL          OutStr 
			SUB         R1,R1,R3	;upper - lower stored in upper
			LSR         R1,R1,#1	;divde middle by 2
;			CMP         R5,#0x32
 ;    		BEQ         upperset
upret		LDR         R2,=GUESS    ; address for storin guess in r2
			STR         R1,[R2]			;store r1 there
            BL          CONVRT
            BL          InChar
			CMP         R0,#0x44
			BEQ         down
            CMP         R0,#0x55
			BEQ         upper
			CMP         R0,#0x43
			BEQ         done

upper       LDR         R2,=GUESS
            LDR         R3,[R2]		;load content of r2 to r
			LDR         R2,=BOUND
			ADD         R2,R2,#4
			LDR         R1,[R2]
			
			
			MOV         R5,#0x32
            B           loops

;upperset    ADD        R1,R1,R3
;            B          upret
            
down        LDR         R2,=GUESS
            LDR         R1,[R2]
            LDR         R2,=BOUND
			LDR         R3,[R2]
            B           loops

done        LDR         R0,=MSGD
            BL          OutStr
Done		B           Done

ENDP


;***************************************************************
; End of the program  section
;***************************************************************
;LABEL      DIRECTIVE       VALUE                           COMMENT
            ALIGN
            END

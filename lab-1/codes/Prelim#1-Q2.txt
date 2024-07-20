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
NUM         EQU         0x7FFFFFFF
FIRST       EQU         0x20000680
	

;***************************************************************
; Directives - This Data Section is part of the code
; It is in the read only section  so values cannot be changed.
;***************************************************************
;LABEL      DIRECTIVE   VALUE       COMMENT
            AREA        sdata, DATA, READONLY
            THUMB
CTR1        DCB         0x0B
MSG         DCB         "Copying table..."
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
            LDR         R4,=NUM	;the number in question
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
get         BL          InChar
            BL          CONVRT
            B           get

ENDP


;***************************************************************
; End of the program  section
;***************************************************************
;LABEL      DIRECTIVE       VALUE                           COMMENT
            ALIGN
            END

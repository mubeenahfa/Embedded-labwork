;********************* 
; Program_Directives.s  
; Copies the table from one location
; to another memory location.           
; Directives and Addressing modes are   
; explained with this program.   
;*********************    
;********************* 
; EQU Directives
; These directives do not allocate memory
;*********************
;LABEL      	DIRECTIVE   VALUE       COMMENT
OFFSET      	EQU         0x10
FIRST       	EQU         0x20000400
MNS_HLT			EQU			15
SWD_DMG			EQU			7
START			EQU 		0x20000400	
COUNT           EQU         0x20000600
;*********************
; Directives - This Data Section is part of the code
; It is in the read only section  so values cannot be changed.
;*********************
;LABEL      DIRECTIVE   VALUE       COMMENT
            AREA        sdata, DATA, READONLY
            THUMB
CTR1        DCB         0x10
MSG         DCB         "Copying table..."
            DCB         0x0D
            DCB         0x04
MSGH         DCB         "enter monster health"
            DCB         0x0D
            DCB         0x04
MSGD         DCB         "enter sword damage"
            DCB         0x0D
            DCB         0x04
MSGF        DCB         ", "
            DCB         0x0D
            DCB         0x04
;*********************
; Program section                         
;*********************
;LABEL      DIRECTIVE   VALUE       COMMENT
            AREA        main, READONLY, CODE
            THUMB
            EXTERN      OutStr      ; Reference external subroutine
			EXTERN      InChar		; Get MNS_HLT and SWD_DMG
            EXPORT      __main      ; Make available




CONVRT      PROC 
	        PUSH        {LR}
			MOV         R9,#10		;set divisor
            MOV         R8,#0   	;start counter
            MOV         R4,R1	;the number in question
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




__main
start		LDR    R0,=MSGH
			BL     OutStr
			MOV    R9,#3
loopino     BL      InChar
			SUB     R0,R0,#48
			PUSH    {R0}
			SUBS     R9,R9,#1
			BNE      loopino
            
			MOV    R11,#10
			MOV    R5,#0
			MOV    R9,#1
loopsso		POP    {R7}
			MUL    R7,R9
			ADD    R5,R5,R7
			MUL    R9,R9,R11
			CMP    R9,#1000
			BNE    loopsso
			
			LDR    R0,=MSGD
			BL     OutStr
			MOV    R9,#2
loopind     BL      InChar
			SUB     R0,R0,#48
			PUSH    {R0}
			SUBS     R9,R9,#1
			BNE      loopind


			MOV    R6,#0
			MOV    R9,#1
loopssd		POP    {R7}
            MUL    R7,R9
			ADD    R6,R6,R7
			MUL    R9,R9,R11
			CMP    R9,#100
			BNE    loopssd			


			LDR     R2, = FIRST
			MOV		R3,R5			; Store content of R1 to R3
			PUSH 	{R3}			; Load SP with Initial Monster Health
			LSR		R3, #1			; Divide Monster health by 2
			MOV 	R8, #1			; Stack counter
			
BATTLE      CMP 	R5, #0			;Check Monster Health to see if it is defeated
			MOV     R12,R8
			BLT 	MNS_REC			; If health < 0 then goto MNS_REC 
			BEQ 	HEALTH_OUT		; If health = 0 then goto health out
			SUB 	R5, R6			; Reduce health by data in R2
			B		BATTLE			; loop again until breaks

MNS_REC     ADD	 	R5,R5,R3		; Add half health stoerd in R3 to R1
			PUSH	{R5}			; Push new health to SP
			ADD		R8, #1			; Increment Counter to update stack
			LSR 	R6, #1			; reduce sword damage / 2
			B 		BATTLE			; do battle again
			
			
HEALTH_OUT  
			POP    {R1}
			BL     CONVRT
			LDR    R0,=MSGF
			BL     OutStr
			SUBS    R12,R12,#1
			BNE    HEALTH_OUT
			BEQ    Done

Done        B      Done
			
			
;*********************
; End of the program  section
;*********************
;LABEL      DIRECTIVE       VALUE                           COMMENT
            ALIGN
            END
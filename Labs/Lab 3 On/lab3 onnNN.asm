ORG 0

	acall	CONFIGURE_LCD
	Mov R1,#40
	mov  42,#'f'
	mov  41,#'='
	mov  37,#'H'
	mov  36,#'z'
	mov  35,#'D'
	mov  34,#'='
	mov  31,#'%'
	Mov R0,#40
	Mov R4,#0
	Mov R5,#0
	Mov R6,#0
KEYBOARD_LOOP:
	acall KEYBOARD
	;now, A has the key pressed
	Mov @R0,A
	dec R0
	cjne R0,#37,KEYBOARD_LOOP
	Mov R0,#33
D_IN:	acall KEYBOARD
	Mov @R0,A
	dec R0
	cjne R0,#31,D_IN
	ACALL DisPlayIN
	
	MOV A, 33
	ANL A, #0FH
	rl A 
	MOV 50, A
	MOV A, #20
	SUBB a, 50
	MOV R5, A

	MOV R6, 50

;	Mov R5,#2
;	Mov R6,#8
;	setb p2.7
;	Mov 62,R7
;	ANL 62,#0Fh
;	Mov A, R7
;	ANL A,#0F0h
;	swap A
;	MOV B ,#10
;	Mul AB
;	ADD A ,62
;	Mov 62 ,A 
;	
	Mov A,49
	ANL A, #0F0H
	Swap A
	MOV B, #10
	MUL AB
	MOV 62, A
	Mov A,48
	Anl A,#0Fh
	ADD A, 62
	Mov R7,A 

	
	mov DPTR,#high_Table
	Movc A,@A+DPTR
	Mov 60,A

	Mov A,R7 
	mov DPTR,#low_table
	Movc A,@A+DPTR
	Mov 61,A
	

	
	ACALL	DELAY_10

	
	sjmp KEYBOARD_LOOP


DisPlayIN:
	Mov A,39
	Mov 49,39
	Anl A,#0Fh
	Swap A
	Mov 39,A
	Mov A,38
	Mov 48,38
	Anl A,#0Fh
	Orl A,39
	Add A,#11h
	DA A
	jnc Jump
	Inc 40
Jump:	Mov R7,A
	Anl A,#0F0h
	swap A
	Orl A,#30h
	Mov 39,A
	Mov A,R7
	Anl A,#0Fh
	Orl A,#30h
	Mov 38,A
;----------------
	Mov R0,#40
Here:	Mov A,@R0
	ACALL send_data
	dec R0
	cjne R0,#35,Here2
	mov a,#0ABH		;FORCE CURSOR TO BEGINNING OF THE SECOND LINE
	acall send_command
Here2:	cjne R0,#31,Here
	ret
;==============================================

DELAY_10:
	Mov TMOD,#01h
	Mov TH0,60
	Mov TL0,61
	SETB TR0
	JNB TF0,$
	Clr TF0
	CLR TR0
	INC R4
HIGH:	JNB p2.7, LOW
	MOV B, R5
	Mov A, R4
	DIV AB
	MOV A, B
	CJNE A, #0, DELAY_10
	MOV R4, #0
	CLR p2.7
	sjmp DELAY_10
LOW:	JB p2.7, HIGH
	MOV B, R6
	Mov A, R4
	DIV AB
	MOV A,B
	CJNE A, #0, DELAY_10
	MOV R4, #0
	SETB p2.7
	sjmp DELAY_10
ret














CONFIGURE_LCD:	;THIS SUBROUTINE SENDS THE INITIALIZATION COMMANDS TO THE LCD
	mov a,#38H	;TWO LINES, 5X7 MATRIX
	acall SEND_COMMAND
	mov a,#0FH	;DISPLAY ON, CURSOR BLINKING
	acall SEND_COMMAND
	mov a,#06H	;INCREMENT CURSOR (SHIFT CURSOR TO RIGHT)
	acall SEND_COMMAND
	mov a,#01H	;CLEAR DISPLAY SCREEN
	acall SEND_COMMAND
	mov a,#80H	;FORCE CURSOR TO BEGINNING OF THE FIRST LINE
	acall SEND_COMMAND
	ret



SEND_COMMAND:
	mov p1,a		;THE COMMAND IS STORED IN A, SEND IT TO LCD
	clr p3.5		;RS=0 BEFORE SENDING COMMAND
	clr p3.6		;R/W=0 TO WRITE
	setb p3.7	;SEND A HIGH TO LOW SIGNAL TO ENABLE PIN
	acall DELAY
	clr p3.7
	ret


SEND_DATA:
	mov p1,a		;SEND THE DATA STORED IN A TO LCD
	setb p3.5	;RS=1 BEFORE SENDING DATA
	clr p3.6		;R/W=0 TO WRITE
	setb p3.7	;SEND A HIGH TO LOW SIGNAL TO ENABLE PIN
	acall DELAY
	clr p3.7
	ret


DELAY:
	push 0
	push 1
	mov r0,#50
DELAY_OUTER_LOOP:
	mov r1,#255
	djnz r1,$
	djnz r0,DELAY_OUTER_LOOP
	pop 1
	pop 0
	ret


KEYBOARD: ;takes the key pressed from the keyboard and puts it to A
	mov	P0, #0ffh	;makes P0 input
K1:
	mov	P2, #0	;ground all rows
	mov	A, P0
	anl	A, #00001111B
	cjne	A, #00001111B, K1
K2:
	acall	DELAY
	mov	A, P0
	anl	A, #00001111B
	cjne	A, #00001111B, KB_OVER
	sjmp	K2
KB_OVER:
	acall DELAY
	mov	A, P0
	anl	A, #00001111B
	cjne	A, #00001111B, KB_OVER1
	sjmp	K2
KB_OVER1:
	mov	P2, #11111110B
	mov	A, P0
	anl	A, #00001111B
	cjne	A, #00001111B, ROW_0
	mov	P2, #11111101B
	mov	A, P0
	anl	A, #00001111B
	cjne	A, #00001111B, ROW_1
	mov	P2, #11111011B
	mov	A, P0
	anl	A, #00001111B
	cjne	A, #00001111B, ROW_2
	mov	P2, #11110111B
	mov	A, P0
	anl	A, #00001111B
	cjne	A, #00001111B, ROW_3
	ljmp	K2
	
ROW_0:
	mov	DPTR, #KCODE0
	sjmp	KB_FIND
ROW_1:
	mov	DPTR, #KCODE1
	sjmp	KB_FIND
ROW_2:
	mov	DPTR, #KCODE2
	sjmp	KB_FIND
ROW_3:
	mov	DPTR, #KCODE3
KB_FIND:
	rrc	A
	jnc	KB_MATCH
	inc	DPTR
	sjmp	KB_FIND
KB_MATCH:
	clr	A
	movc	A, @A+DPTR; get ASCII code from the table 
	ret

;ASCII look-up table 
KCODE0:	DB	'1', '2', '3', 'A'
KCODE1:	DB	'4', '5', '6', 'B'
KCODE2:	DB	'7', '8', '9', 'C'
KCODE3:	DB	'*', '0', '#', 'D'






LOW_TABLE: DB 69, 255, 78, 72, 255, 127, 210, 255, 13, 255, 219, 162, 88, 255, 153, 39, 170, 36, 149, 255, 98, 191, 23, 105, 182, 255, 69, 134, 196, 255, 56, 109, 160, 209, 255, 44, 87, 127, 167, 204, 240, 19, 53, 85, 116, 146, 175, 202, 229, 255, 25, 49, 73, 95, 118, 139, 160, 180, 200, 219, 237, 255, 17, 34, 51, 67, 83, 98, 113, 127, 142, 156, 169, 182, 195, 208, 220, 232, 244, 255, 11, 22, 32, 43, 53, 63, 73, 83, 93, 102, 111, 120, 129, 137, 146, 154, 162, 170, 178, 186, 193

HIGH_TABLE: DB 223, 225, 228, 230, 231, 233, 234, 235, 237, 237, 238, 239, 240, 240, 241, 242, 242, 243, 243, 243, 244, 244, 245, 245, 245, 245, 246, 246, 246, 246, 247, 247, 247, 247, 247, 248, 248, 248, 248, 248, 248, 249, 249, 249, 249, 249, 249, 249, 249, 249, 250, 250, 250, 250, 250, 250, 250, 250, 250, 250, 250, 250, 251, 251, 251, 251, 251, 251, 251, 251, 251, 251, 251, 251, 251, 251, 251, 251, 251, 251, 252, 252, 252, 252, 252, 252, 252, 252, 252, 252, 252, 252, 252, 252, 252, 252, 252, 252, 252, 252, 252

















END


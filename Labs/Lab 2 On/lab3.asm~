ORG 0

	acall	CONFIGURE_LCD
	Mov R0,#40
	Mov 50,#1
	Mov 51,#1
	mov  38,#','
	mov  37,#' '

KEYBOARD_LOOP:
	acall KEYBOARD
	Cjne A,#'D',moveA
	ACALL configure_lcd
	
Again3:	Mov R0,#40
AGAIN:	acall KEYBOARD
	;now, A has the key pressed
	
MoveA:	Mov @R0,A
	DEC R0
	CJNE A,#'A',YEe
	acall print1
	dec 50
YEe:CJNE R0,#38,AGAIN
	
	mov a, 50
	cjne a, #1, back
	acall KEYBOARD
	CJNE A,#'A',KEYBOARD_LOOP
	acall print1
	
BACK:	MOV R0,#36
AGAIN2:	acall KEYBOARD
   	Mov @R0,A
	DEC R0
	CJNE A,#'A',NO 
	acall print2
	dec 51
No:	CJNE R0,#34,AGAIN2

	mov a, 51
	cjne a, #1, hexx
	acall KEYBOARD
	CJNE A,#'A',BACK
	acall print2
	acall KEYBOARD
hexx:	acall to_hex
 	acall divisor
 	
	sjmp KEYBOARD_LOOP



         
Print1:	
	Mov R1,#40
First:	Mov A, @R1
	CJNE A,#'A',AA
	Mov 39,40
	Mov 40,#' '
AA:	dec R1
	CJNE R1, #38,First

	Mov R1,#40
Firsts:	Mov A, @R1
	acall SEND_DATA
	dec R1
	CJNE R1, #38,Firsts
		
	ret
	
Print2:
	Mov R1,#36
Sec:	Mov A, @R1
	CJNE A,#'A',BB
	Mov 35,36
	Mov 36,#' '
BB:	dec R1
	CJNE R1, #34,Sec

	Mov R1,#38
Sec2: 	Mov A, @R1
	acall SEND_DATA
	dec R1
	CJNE R1, #34,Sec2
 
	ret 

TO_ASCII:
	mov a, r7
	anl a, #0f0h
	swap a
	orl a, #30h
	mov 34, a
	mov a, r7
	anl a, #0fh
	orl a, #30h
	mov 33, a
ret
 

TO_HEX:
	Mov A,40
	ANL A,#0Fh
	Swap A
	Mov B, A
	Mov A,39
	ANL A,#0Fh
	Orl A,B
	Mov R4,A
	Mov A,36
	ANL A,#0Fh
	Swap A
	Mov B, A
	Mov A,35
	ANL A,#0Fh
	Orl A,B
	Mov R5,A
	ret
 
divisor:
	mov a, r4
	mov b, r5
	mov r6, #1
	mov r7, #1
	Mov R3, 5
	
	cjne a, b, move
move:	jc here
	mov R4, b
	mov r5, a
	Mov R3, 5
	
here:	mov a, r4
	mov b, r6
	div ab
	mov a, b
	cjne a, #0, next
	mov a, r5
	mov b, r6
	div ab	
	mov a, b
	cjne a, #0, next
	mov 7, 6
next:	inc R6
	 
	Djnz R3, Here

	mov a,#0ABH	;FORCE CURSOR TO BEGINNING OF THE SECOND LINE
	acall send_command
	cjne r7, #1, not_coprime
	mov a, #'1'
	acall send_data
	mov a, #' '
	acall send_data
	mov a, #'C'
	acall send_data
	mov a, #'O'
	acall send_data
	mov a, #'P'
	acall send_data
	mov a, #'R'
	acall send_data
	mov a, #'I'
	acall send_data
	mov a, #'M'
	acall send_data
	mov a, #'E'
	acall send_data
	sjmp exit
not_coprime:
	acall to_ascii
	mov a, 34
	acall send_data
	mov a, 33
	acall send_data
exit:	ret

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

  
 

end

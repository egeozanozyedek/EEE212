ORG 0

Start:	acall	CONFIGURE_LCD
	Mov R0, #79h
	Mov 7Fh,#','
	Mov R7,#0
	clr 0
	Mov R6, #0

KEYBOARD_LOOP:
	acall KEYBOARD
	;now, A has the key pressed
	CJNE A,#'B',Get_Input
	Inc R6
	CJNE R6,#1,CheckB2	;Firt time B pressed
	Inc R7
	ACALL CONVERT	 	;convert to integer
	ACALL Sort		;sort numbers
	ACALL PRINT		; Print sorted numbers
CheckB2:CJNE R6,#2,CheckB3 	;second  time B pressed
	acall CONFIGURE_LCD	;reset the lcd 
	ACALL Median		;show median
	acall sum		;and sum
CheckB3:CJNE R6,#3,get_input	;Third  time B pressed
	ACAll Restart		;reset and restart

Get_Input: CJNE R6,#0,KEYBOARD_LOOP ;Do not take input After B is Pressed
	CJNE A,#'A',JUMP1
	Mov A,7Fh		;writing comma for serperation 
	Inc R7			;number of inputs
	sjmp jump		;do not store 'A' 
JUMP1:	Mov @R0,A		;Store input to location which R0 is pointing
	Dec R0			; Decrease R0 to store next value to next location
jump:	acall SEND_DATA		; sending inputs to LCD to show
	JB 0,JUMP2		; starting from second line just once
	Cjne R7,#5,JUMP2  	; when the input numbers reach 5 values are sent to next line
	setb 0			; a flag for doing this just once
	mov a,#0ABH		;FORCE CURSOR TO BEGINNING OF THE SECOND LINE
	acall send_command
JUMP2:
	
	sjmp KEYBOARD_LOOP

;-----------------------------------

Convert:
	Mov R0,#79h	;Pointer for taking ASCII values of inputs	
	Mov R1,#50h	;Pointer for storing as BCD	
	Mov 1Fh,R7	;Storing Input numbers to 1Fh
BACK:	Mov A,@R0	;taking value from where R0 is pointing
	ANL A, #0FH	;lower nible
	swap A		;swap it
	Mov @R1,A	;store it
	Dec R0		;next location
	Mov A,@R0	;next value
	ANL A, #0FH	;lower nible
	ORL A,@R1	;combine with the one comes before itself
	Mov @R1,A	;Store it to location where R1 is pointning
	Dec R0		;next loc			
	Dec R1		;next loc
	DJNZ R7,BACK	; loop with number of inputs
	Mov R7,1Fh	;write number of inputs to R7 again
	ret
	
;-----------------------------------

Sort:	
	Mov R0,#50h	;loc of first BCD		
	Mov R1,#4Fh	;loc of second BCD
	Dec R7		;Need loop number is 1 less tan input number
BACK2:	Mov 1Eh,R7	;mov R7 to 1Eh 
BACK3:	Mov A,@R0	;take the input from loc where R0 pointing and 
	Mov 30h,@R1	;take values on next locations
	CJNE A,30h,$+3	; compare them
	JC  NEXT	; if bigger than next jump to NEXT
	Mov 31h,A	; if smaller than
	Mov @R0,30h	;swap
	Mov @R1,31h	;swap
NEXT:	Dec R1		; get next valur to for comparison
	Djnz 1Eh,BACK3	; first loop that is putting smalest first loc 
	Dec R0		; next small numbers loc 
	MOV 1, 0	;
	DEC R1		; next loc to compare
	Djnz R7,BACK2	; second loop that completes the sor process
	Mov R7,1Fh	; restore R7 number of inputs
	ret

;-----------------------------------

Median:
	MOV A, R7	; move R7 to A
	MOV B, #2	
	MOV R0, #50h	
	JB ACC.0, ODD	; check number of input for odd or even
	DIV AB	
	DEC A
	MOV R3,A	; number of which input is on th emiddle
DEC_LOOP0: DEC R0	;loc of one of the values on the middle
	DJNZ R3,DEC_LOOP0;
	MOV A, @R0
	DEC R0
	ADD A, @R0 	;add these two 
 	DA A		; Fix fro BCD
 	Mov 3,C 	; store carry
 	MOV B, #02h	;
 	DIV AB		;
 	Mov R3,B	; store reminder
 	Mov R5,A	;
 	Anl A,#0Fh
	CJNE A,#05h,$+3
	Mov A,R5
 	JC label
 	SUBB A,#03h
 label:	
CARRY1:	JNB 3,Not_set
 	ADD A ,#50h
Not_Set:MOV R0, A
	acall M_PRINT
	MOV A, R3
	cjne A, #1, ZERO	;check fro '.5' or '.0'
	MOV A, #'5'
	acall send_data
	sjmp M_EXIT
ZERO:	MOV A, #'0'
	acall send_data
	sjmp M_EXIT

ODD:	DIV AB
	MOV R3,A
DEC_LOOP: DEC R0
	DJNZ R3,DEC_LOOP
	MOV 0, @R0
	acall m_print
	MOV A, #'0'
	acall send_data
M_EXIT:	ret

;-----------------------------------

M_PRINT:
	MOV A, R0
	anl a, #0f0h
	swap a
	orl a, #30h
	acall send_data
	mov a, R0
	anl a, #0fh
	orl a, #30h
	acall send_data
	MOV A, #'.'
	acall send_data
	ret

;-----------------------------------

SUM:
	mov a,#0ABH	;FORCE CURSOR TO BEGINNING OF THE SECOND LINE
	acall send_command
	MOV R0, #50h
	MOV R2, #0
	MOV R3, #0
BACK7:	MOV A, R2
	ADD A, @R0
	DA A 
	DEC R0
	JNC HERE
	INC R3
HERE:	MOV R2, A
	DJNZ R7, BACK7
	acall S_PRINT
	Mov R7,1Fh
 
	ret
;-----------------------------------
S_PRINT:
	MOV A, R3
	anl a, #0fh
	orl a, #30h
	acall send_data	 
	MOV A, R2
	anl a, #0f0h
	swap a
	orl a, #30h
	acall send_data
	MOV A, R2
	anl a, #0fh
	orl a, #30h
	acall send_data	 
	ret
 ;-----------------------------------
 
Restart:
	clr A
	Mov B,#00h
	Clr C
	Mov 7Fh,#7Fh
	Mov R0,#7Fh
BACK10: Mov @R0,#00h
	Dec R0
	DJNZ 7Fh,BACK10
	ljmp start
	ret

;-----------------------------------

TO_ASCII:
	Mov R0,#79h
	Mov R1,#50h
BACK4:	mov a, @R1
	anl a, #0f0h
	swap a
	orl a, #30h
	Mov @R0, a
	Dec R0
	mov a, @R1
	anl a, #0fh
	orl a, #30h
	Mov @R0, a
	Dec R0
	DEC R1
	DJNZ R7,BACK4
	Mov R7,1Fh
	ret
	
;-----------------------------------

PRINT:
	mov R3, #0
	acall CONFIGURE_LCD
	acall to_ascii
	Mov R0,#79h
BACK5:	Mov R1,#2
BACK6:	Mov A,@R0
	ACALL send_data
	DEC R0
	DJNZ R1,BACK6
	INC R3
	cjne r7, #1, COM
	sjmp not_com
COM:   	Mov A,#','
	ACALL send_data
NOT_COM:cjne r3, #5, exit
	mov a,#0ABH	;FORCE CURSOR TO BEGINNING OF THE SECOND LINE
	acall send_command
EXIT:	DJNZ R7,BACK5
	Mov R7,1Fh
	ret

  ;-----------------------------------


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

END


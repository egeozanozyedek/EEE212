ORG 0

	acall	CONFIGURE_LCD

DATA_LOOP:
	INTR 	BIT P2.7 
	MYDATA 	EQU P0
	MOV 	P0,#0FFH
	CLR 1
	CLR 5
	CLR 6
	CLR 7
	MOV 16, #0
	MOV 17, #0
	MOV R6, #5
BACK1:	 
	MOV 	R1,#40
	MOV 	R2,#40
BACK: 	SETB 	INTR
	CLR 	P2.6  
	SETB	P2.6
	MOV R7, #19
BHERE:  DJNZ R7, BHERE
	NOP
HERE: 	JB 	INTR , HERE 
	CLR 	P2.5
	MOV 	@R1 , MYDATA
	SETB 	P2.5
	INC 	R1
	DJNZ 	R2, BACK

	ACALL MAX
	ACALL MIN
	ACALL OFFSET
	ACALL IS_SQUARE
	ACALL SINE_RAMP
	MOV 36, #0
	MOV 35, #255
	DJNZ R6, BACK1
	
	ACALL DETERMINE
	ACALL CONFIGURE_LCD
	MOV A,#0ABH	;FORCE CURSOR TO BEGINNING OF THE FIRST LINE
	acall SEND_COMMAND
	ACALL PRINT_OFFSET
	mov a,#80H	;FORCE CURSOR TO BEGINNING OF THE FIRST LINE
	acall SEND_COMMAND
	ACALL PRINT_WAVE
	MOV R6, #5
	MOV 16, #0
	MOV 17, #0
	MOV 25, #0
	MOV 26, #0
	MOV 27, #0
	CLR 5
	CLR 6
	CLR 7
	
	ACALL DELAYEE
	SJMP 	BACK1


DET_OFFSET:
	MOV A, 17
	MOV B, #5
	DIV AB
	ADD A, 16
	MOV 16, A 
	MOV A, 16
RET

DETERMINE:
	MOV A, 25
	CJNE A, 26, $+3
	JC SR
	CJNE A, 27, $+3
	JC SR
	SETB 5
	RET
SR: 	MOV A, 26
	CJNE A, 27, $+3
	JC RSIG
	SETB 6
	RET
RSIG:	SETB 7
	RET

PRINT_WAVE:
	;SHOULD CALL SINE AND RAMP
	MOV 29, #4
	JNB 5, SOME
	MOV DPTR, #SQR
	MOV 29, #6
	SJMP LOOP
SOME:	JNB 6, SOME2
	MOV DPTR, #SINE
	SJMP LOOP
SOME2: 	JNB 7, GO
	MOV DPTR, #RAMP

LOOP:	CLR A
	MOVC A,@A+DPTR
	ACALL SEND_DATA
	INC DPTR
	DJNZ 29, LOOP
GO:
	MOV DPTR, #0
RET

OFFSET:
	CLR C
	MOV A, 36
	ADD A, 35
	MOV 0, C
	MOV B, #2
	DIV AB
	JNB 0, NOCARRY
	ADD A, #128
nocarry:

	MOV B, #5
	DIV AB

	
	ADD A, 16
	MOV 16, A

	MOV A, B

	ADD A, 17
	MOV 17, A
RET

PRINT_OFFSET:
	ACALL DET_OFFSET
	MOV DPTR ,#0
	MOV B, #4
	MUL AB
	MOV R7, A ; LOW NIBBLE
	MOV R6, B ; HIGH NIBBLE
	MOV DPTR, #VOLTAGE
	
	ADD A, DPL
	MOV DPL, A
	MOV A, R6
	ADDC A, DPH
	MOV DPH, A

	MOV R4, #4
MOVE: 	CLR A
	MOVC A, @A+DPTR
	ACALL SEND_DATA
	INC DPTR
	DJNZ R4, MOVE
RET	


MIN:	MOV R2, #40
	MOV R0, #40
	MOV R1, #41
HEREA:	MOV A, @R0
	MOV B, @R1
	CJNE A, B, $+3
	JC COME
	MOV 0,1
COME:   INC R1
	DJNZ R2, HEREA
	MOV 35, @R0 ;
RET




MAX:	MOV R2, #40
	MOV R0, #40
	MOV R1, #41
HEREB:	MOV A, @R0
	MOV B, @R1
	CJNE A, B, $+3
	JNC COME1
	MOV 0,1
COME1:  INC R1
	DJNZ R2, HEREB
	MOV 36, @R0 ;
RET

IS_SQUARE:
	MOV A, 36
	SUBB A,#10H
	MOV 37 ,A

	MOV R2, #40
	MOV R0, #0
	MOV R1, #40
CMP:	MOV A, @R1
	MOV B, 37
	CJNE A, B, $+3
	JC COMent
	INC R0
COMent:  INC R1
	DJNZ R2, CMP 

	CJNE R0, #10, $+3
	JC COMH
	INC 25
COMH:
RET


SUB:
	MOV A,36
	CJNE A,#240,$+3
	JC N230
	MOV 38, #7
	RET
N230:	CJNE A,#230,$+3
	JC N220
	MOV 38, #6
	RET
N220:	CJNE A,#220,$+3
	JC N_EXIT
	MOV 38, #5
N_EXIT: RET




SINE_RAMP:
	ACALL SUB
	MOV A, 36
	SUBB A,38
	MOV 37 ,A

	MOV R2, #40
	MOV R0, #0
	MOV R1, #40
WHEEW:	MOV A, @R1
	MOV B, 37
	CJNE A, B, $+3
	JC GOHERE
	INC R0
GOHERE:  INC R1
	DJNZ R2, WHEEW 

	CJNE R0, #3, $+3
	JNC BIG
	INC 27
	RET
BIG:	CJNE R0, #7, $+3
	JNC EX9
	INC 26
EX9:

RET


DELAYEE:
BBB:	MOV 22, #255
BBBB:	DJNZ 22, BBBB
RET

DIVI:
	MOV B,#100
	DIV AB
	MOV 30 ,A
	MOV A, B
	MOV B,#10
	DIV AB
	MOV 31,A
	MOV 32, B
	ORL 30,#30H
	ORL 31,#30H
	ORL 32,#30H
	RET



PRINT:	MOV A, 30
	ACALL SEND_DATA 
	MOV A, 31 
	ACALL SEND_DATA 
	MOV A, 32 
	ACALL SEND_DATA 
	MOV A, #' ' 
	ACALL SEND_DATA 
	RET


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


;P1.0-P1.7 ARE CONNECTED TO LCD DATA PINS D0-D7
;P3.5 IS CONNECTED TO RS
;P3.6 IS CONNECTED TO R/W
;P3.7 IS CONNECTED TO E

SEND_COMMAND:	;THIS  SUBROUTINE IS FOR SENDING THE COMMANDS TO LCD
	mov p1,a		;THE COMMAND IS STORED IN A, SEND IT TO LCD
	clr p3.5		;RS=0 BEFORE SENDING COMMAND
	clr p3.6		;R/W=0 TO WRITE
	setb p3.7	;SEND A HIGH TO LOW SIGNAL TO ENABLE PIN
	acall DELAY
	clr p3.7
	ret


SEND_DATA:	;THIS  SUBROUTINE IS FOR SENDING THE DATA TO BE DISPLAYED
	mov p1,a		;SEND THE DATA STORED IN A TO LCD
	setb p3.5	;RS=1 BEFORE SENDING DATA
	clr p3.6		;R/W=0 TO WRITE
	setb p3.7	;SEND A HIGH TO LOW SIGNAL TO ENABLE PIN
	acall DELAY
	clr p3.7
	ret


DELAY:	;A SHORT DELAY SUBROUTINE
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

MYSTRING: DB 'LCD IS OK!',0
SQR: DB 'SQUARE',0
SINE: DB 'SINE', 0
RAMP: DB 'RAMP', 0


VOLTAGE: DB '0.01', '0.03', '0.05', '0.07', '0.08', '0.10', '0.12', '0.14', '0.16', '0.18', '0.19', '0.21', '0.23', '0.25', '0.27', '0.28', '0.30', '0.32', '0.34', '0.35', '0.37', '0.39', '0.41', '0.43', '0.44', '0.46', '0.48', '0.50', '0.52', '0.53', '0.55', '0.57', '0.59', '0.61', '0.62', '0.64', '0.66', '0.68', '0.70', '0.71', '0.73', '0.75', '0.77', '0.79', '0.80', '0.82', '0.84', '0.86', '0.88', '0.89', '0.91', '0.93', '0.95', '0.97', '0.98', '1.01', '1.02', '1.04', '1.06', '1.08', '1.10', '1.11', '1.13', '1.15', '1.17', '1.19', '1.20', '1.22', '1.24', '1.26', '1.28', '1.29', '1.31', '1.33', '1.35', '1.37', '1.38', '1.40', '1.42', '1.44', '1.46', '1.47', '1.49', '1.51', '1.53', '1.55', '1.56', '1.58', '1.60', '1.62', '1.64', '1.65', '1.67', '1.69', '1.71', '1.72', '1.74', '1.76', '1.78', '1.80', '1.81', '1.83', '1.85', '1.87', '1.89', '1.90', '1.92', '1.94', '1.96', '1.98', '1.99', '2.01', '2.03', '2.05', '2.07', '2.08', '2.10', '2.12', '2.14', '2.16', '2.17', '2.19', '2.21', '2.23', '2.25', '2.26', '2.28', '2.30', '2.32', '2.34', '2.35', '2.37', '2.39', '2.41', '2.43', '2.44', '2.46', '2.48', '2.50', '2.52', '2.53', '2.55', '2.57', '2.59', '2.61', '2.62', '2.64', '2.66', '2.68', '2.70', '2.71', '2.73', '2.75', '2.77', '2.79', '2.80', '2.82', '2.84', '2.86', '2.88', '2.89', '2.91', '2.93', '2.95', '2.96', '2.98', '3.00', '3.02', '3.04'



END
;//header//////////////////////////
PROCESSOR 16F876

INDF	EQU	00H
TMR0	EQU	01H
PCL	EQU	02H
STATUS	EQU	03H
FSR	EQU	04H
PORTA	EQU	05H
PORTB	EQU	06H
PORTC	EQU	07H
PORTD	EQU	08H
PORTE	EQU	09H
PCLATH	EQU	0AH
INTCON	EQU	0BH

;/***************************/
STATUS_TEMP	EQU	21H
W_TEMP		EQU	22H

INT_CNT		EQU	23H
DISP_CNT		EQU	24H

SEC_1		EQU	25H
SEC_10		EQU	26H
MIN_1		EQU	27H
MIN_10		EQU	28H
HOUR_1		EQU	29H
HOUR_10		EQU	2AH

A_MIN_1		EQU	30H
A_MIN_10	EQU	31H
A_HOUR_1	EQU	32H
A_HOUR_10	EQU	33H

G_MIN_1		EQU	34H
G_MIN_10	EQU	35H
G_HOUR_1	EQU	36H
G_HOUR_10	EQU	37H

DISP_A		EQU	38H
PASS_C		EQU	39H

SEG		EQU	49H
DBUF1		EQU	50H
DBUF2		EQU	51H
KEY_IN		EQU	52H
DISP_B		EQU	53H
DBUF3		EQU	54H
DBUF4		EQU	55H
DBUF5		EQU   56H

;/****************************/

; BANK 1
OPTIONR	EQU	81H
TRISA	EQU	85H
TRISB	EQU	86H
TRISC	EQU	87H
TRISD	EQU	88H
TRISE	EQU	89H
ADCON1	EQU	9FH

; STATUS BITS 
IRP		EQU 7
RP1		EQU 6
RP0		EQU 5
NOT_TO	EQU 4
NOT_PD	EQU 3
ZF		EQU 2
DC		EQU 1
CF		EQU 0
;

W		EQU	B'0'
F		EQU .1



	
ORG 	0
	GOTO 	START
	
;****************************************************************************
;							INTERRUPT
;****************************************************************************	
ORG		04H

	MOVWF	W_TEMP
	SWAPF	STATUS,W
	MOVWF	STATUS_TEMP
	
	;ERROR	CORRECT
	;MOVLW		.6
	;MOVWF		TMR0			

	BCF		PORTB,7
	
	CALL		DISP
	
	SWAPF 		STATUS_TEMP,W
	MOVWF		STATUS
	SWAPF 		W_TEMP,F
	SWAPF		W_TEMP,W
	BCF 		INTCON,2
	RETFIE

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
DISP	
	INCF		DISP_CNT
	
	BTFSC		DISP_CNT,1
	GOTO		DISP_3OR4
		
	BTFSS		DISP_CNT,0
	GOTO		DISP_10M
	GOTO		DISP_1M

DISP_3OR4
	BTFSS		DISP_CNT,0
	GOTO		DISP_10H
	GOTO		DISP_1H	
	
DISP_1M
	BSF		PORTB, 1
	BSF		PORTB, 2
	BSF		PORTA, 2
	BSF		PORTA, 3
	;-----------------------
	
	BTFSS		PORTB,3
	MOVF		SEC_1,W
	BTFSC		PORTB,3
	MOVF		MIN_1, W
	CALL		SHOW
	;-----------------------
	
	
	BCF		PORTB,1

	RETURN

DISP_10M
	BSF		PORTB, 1
	BSF		PORTB, 2
	BSF		PORTA, 2
	BSF		PORTA, 3
	;-----------------------
		
	BTFSS		PORTB,3
	MOVF		SEC_10,W
	BTFSC		PORTB,3
	MOVF		MIN_10,W
	CALL		SHOW
	;-----------------------	
	
	BCF		PORTB,2
	
	INCF		INT_CNT
	
	RETURN
	
DISP_1H
	BSF		PORTB, 1
	BSF		PORTB, 2
	BSF		PORTA, 2
	BSF		PORTA, 3
	;-----------------------
		
	BTFSS		PORTB,3
	MOVF		MIN_1,W
	BTFSC		PORTB,3
	MOVF		HOUR_1,W
	CALL		SHOW

	;BLINK DG4 DOT AT 0.5 SEC	
	BTFSS		INT_CNT,6	
	BSF		PORTA, 0
	BTFSC		INT_CNT,6
	BCF		PORTA, 0
	;-----------------------	

	BCF		PORTA,2

	RETURN	

DISP_10H
	BSF		PORTB, 1
	BSF		PORTB, 2
	BSF		PORTA, 2
	BSF		PORTA, 3
	;-----------------------
		
	BTFSS		PORTB,3
	MOVF		MIN_10,W
	BTFSC		PORTB,3
	MOVF		HOUR_10,W
	CALL		SHOW
	;-----------------------	
	
	BCF		PORTA,3
	

	RETURN
	
	
	

	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	


;****************************************************************************
;			      		   MAIN PROGRAM
;****************************************************************************
;초기 설정
START
	BSF		STATUS,RP0 	;bank1

	MOVLW	B'00000111'
	MOVWF	ADCON1
	MOVLW	B'00000000'
	MOVWF	TRISA
	MOVLW	B'00111000'
	MOVWF	TRISB
	MOVLW	B'00000000'
	MOVWF	TRISC

	MOVLW	B'00000010'	;interrupt 시간설정 2.048msec
	MOVWF	OPTIONR

	BCF		STATUS,RP0	;bank0
	BSF		INTCON,5
	BSF		INTCON,7
	
;초기화	
INIT
	MOVLW	B'00011100'
	MOVWF	PORTA
	MOVLW 	B'00111110'
	MOVWF	PORTB
	MOVLW	B'00000000'
	MOVWF	PORTC
	
	MOVLW	0
	MOVWF	INT_CNT
	MOVWF	DISP_CNT
	MOVWF	PASS_C
	
	MOVWF	SEC_1
	MOVWF	SEC_10
	
	MOVLW	.9	
	MOVWF	MIN_1
	MOVLW	.5
	MOVWF	MIN_10
	MOVLW	.1
	MOVWF	HOUR_1
	MOVWF	HOUR_10
	
	MOVLW	0FFH
	MOVWF	DISP_A
	MOVWF	DISP_B
	MOVWF	KEY_IN
	
	MOVWF	A_MIN_1
	MOVWF	A_MIN_10
	MOVWF	A_HOUR_1
	MOVWF	A_HOUR_10


	;MOVLW	.6
	;MOVWF	TMR0		
	
MAIN
	CALL	ISON

	
	BTFSS	PORTB,4;스위치 2 확인 
	GOTO	GETKEY; 입력 되면 이 프로그램으로 이동 
	BTFSS	PORTB,5; 스위치 3 확인 
	GOTO	LED3; 입력 되면 이 프로그램으로 이동 

NEXT	
	MOVLW	.125
	SUBWF	INT_CNT,W
	BTFSS	STATUS,ZF
	GOTO	MAIN
	
	CLRF	INT_CNT		;;SEC
	INCF	SEC_1
	MOVLW	.10
	SUBWF	SEC_1,W
	BTFSS	STATUS,ZF
	GOTO 	MAIN
	
	CLRF	SEC_1
	INCF	SEC_10
	MOVLW	.6		
	SUBWF	SEC_10,W
	BTFSS	STATUS,ZF
	GOTO	MAIN
	
	CLRF	SEC_10		;;MIN
	INCF	MIN_1
	MOVLW	.10
	SUBWF	MIN_1,W
	BTFSS	STATUS,ZF
	GOTO 	MAIN
	
	CLRF	MIN_1
	INCF	MIN_10
	MOVLW	.6
	SUBWF	MIN_10,W
	BTFSS	STATUS,ZF
	GOTO	MAIN
	
	CLRF	MIN_10		;;HOUR
	INCF	HOUR_1
	MOVLW	.10
	SUBWF	HOUR_1,W
	BTFSS	STATUS,ZF
	GOTO 	XX2 ;GOTO MAIN 대신에 
	
	CLRF	HOUR_1
	INCF	HOUR_10
	MOVLW	.3
	SUBWF	HOUR_10,W
	BTFSC	STATUS,ZF
	CLRF	HOUR_10
	GOTO 	MAIN
	
XX2

	MOVLW	.2
	SUBWF	HOUR_10,W
	BTFSS	STATUS,ZF
	GOTO 	MAIN 
	
	MOVLW	.4
	SUBWF	HOUR_1,W
	BTFSS	STATUS,ZF
	GOTO	MAIN
	CLRF	HOUR_10
	CLRF	HOUR_1
	GOTO	MAIN

GETKEY
	BSF	PCLATH,3
	GOTO	GET_KEY

ISON ;알람시간이랑 현재시간을 비교해서 부저 울리는 부프로그램 
	MOVF	A_HOUR_10,W
	SUBWF	HOUR_10,W
	BTFSS	STATUS,ZF
	GOTO	OFF
	
	MOVF	A_HOUR_1,W
	SUBWF	HOUR_1,W
	BTFSS	STATUS,ZF
	GOTO	OFF
	
	MOVF	A_MIN_10,W
	SUBWF	MIN_10,W
	BTFSS	STATUS,ZF
	GOTO	OFF
	
	MOVF	A_MIN_1,W
	SUBWF	MIN_1,W
	BTFSS	STATUS,ZF
	GOTO	OFF
	
	GOTO	ON
	

	
ON;부저울림 
	BCF	PORTA,4
	RETURN
	
OFF; 뷰저 안울림 
	BSF	PORTA,4
	RETURN; 이까지 
	
	


LED3	; 부저 끄는 프로그램 
	BSF	INTCON,7	
	BSF	PORTA,4
	
	MOVLW	0FFH		;알람시간 입력으로 받는다 
	MOVWF	A_HOUR_10	;설정한 알람시간을 초기화 ,알람 끄기 
	
	GOTO	MAIN		
			
;****************************************************************************
;						     SUB PROGRAM
;****************************************************************************
SHOW
	CALL		CONV
	MOVWF		SEG
	MOVF		SEG,W
	ANDLW		B'11111100'
	MOVWF		PORTC
	
	BTFSC		SEG, 1
	BSF			PORTA, 1
	BTFSS		SEG, 1
	BCF			PORTA, 1
	
	BTFSC		SEG, 0
	BSF			PORTA, 0
	BTFSS		SEG, 0
	BCF			PORTA, 0
	RETURN		
CONV 
	ANDLW	0FH
	ADDWF	PCL, F
	
	RETLW	B'11111100';0
	RETLW	B'01100000';1
	RETLW	B'11011010';2
	RETLW	B'11110010';3
	RETLW	B'01100110';4
	RETLW	B'10110110';5
	RETLW	B'10111110';6
	RETLW	B'11100000';7
	RETLW	B'11111110';8
	RETLW	B'11110110';9
	RETLW	B'00011010';C
	RETLW	B'00000000';
	RETLW	B'00011010';c
	RETLW	B'00000001';.
	RETLW	B'10011110';E
	RETLW	B'10001110';F
	
DELAY
	MOVLW	.1
	MOVWF	DBUF4
DLP1
	MOVLW	.5
	MOVWF	DBUF5
DLP2	
	DECFSZ DBUF4,F
	GOTO	DLP2
	DECFSZ DBUF5,F
	GOTO	DLP1
	RETURN


;------------------------------------------------------------------------------------
;------------------------------------------------------------------------------------
;------------------------------------------------------------------------------------
;------------------------------------------------------------------------------------
;------------------------------------------------------------------------------------
ORG	800H

GET_KEY
	MOVLW		0FFH
	MOVWF		KEY_IN ; 입력으로 받는다 
	
	BCF		INTCON,7 ; 인터럽트 꺼논다 
	BCF		INTCON,5 ; 타이머 인터럽트도 

	BCF		PORTB, 1	;DG4에 표시 
	BSF		PORTB, 2
	BSF		PORTA, 2
	BSF		PORTA, 3
PUSH_LP
	BTFSC		PORTB,4; 스위치 2가 눌렸으면 GET_KEY_LP로 이동 
	GOTO		PUSH_LP ; 계속 확인 

GET_KEY_LP	
	INCF		KEY_IN
	MOVF		KEY_IN,W
	SUBLW		0AH ; 10이면 입력 안받음 
	BTFSC		STATUS,ZF
	CLRF		KEY_IN
	
	MOVF		KEY_IN,W	
	CALL		SHOW2
	CALL		DELAY2
	BTFSS		PORTB,4
	GOTO		GET_KEY_LP	;눌루면 계속 숫자 UP
	
	MOVLW		.1	
	SUBWF		KEY_IN,W
	BTFSC		STATUS,ZF
	GOTO		CLR_TIME
		
	MOVLW		.2	
	SUBWF		KEY_IN,W
	BTFSC		STATUS,ZF
	GOTO		SET_TIME
	
	MOVLW		.3
	SUBWF		KEY_IN,W
	BTFSC		STATUS,ZF
	GOTO		SET_TIME




;*******************************************************************************
CLR_TIME
	CLRF		HOUR_10
	CLRF		HOUR_1
	CLRF		MIN_10
	CLRF		MIN_1
	CLRF		SEC_10
	CLRF		SEC_1

	GOTO		NOACTION

;*******************************************************************************
SET_TIME
	MOVLW	0FFH
	MOVWF	DISP_A; 입력으로 받는다 
		
	CLRF	PASS_C
	BSF	PORTB, 1; 입력으로 		
	BSF	PORTB, 2; "
	BSF	PORTA, 2; "
	BSF	PORTA, 3; "
	
LP	BTFSC	PORTB,4
	GOTO	LP

	MOVF	PASS_C,W
	ANDLW	03H
	ADDWF	PCL,F
	GOTO	DG1
	GOTO	DG2
	GOTO	DG3
	GOTO	DG4

DG1		;com1 선택 
	BSF	PORTB, 1		
	BSF	PORTB, 2
	BSF	PORTA, 2
	BCF	PORTA, 3
	GOTO	LP2	
DG2		;com2 선택
	BSF	PORTB, 1	
	BSF	PORTB, 2
	BCF	PORTA, 2	
	BSF	PORTA, 3
	GOTO	LP2
DG3		;com3 선택
	BSF	PORTB, 1	
	BCF	PORTB, 2
	BSF	PORTA, 2
	BSF	PORTA, 3
	GOTO	LP2
DG4		;com4 선택
	BCF	PORTB, 1	
	BSF	PORTB, 2
	BSF	PORTA, 2
	BSF	PORTA, 3
	GOTO	LP2

LP2
	INCF	DISP_A
	MOVF	DISP_A,W
	SUBLW	0AH
	BTFSC	STATUS,ZF
	CLRF	DISP_A

	MOVF	DISP_A,W
	CALL	SHOW2
	CALL	DELAY2
	
	BTFSS	PORTB,4
	GOTO	LP		;눌리면 계속 숫자 UP

	MOVF	PASS_C,W
	ANDLW	03H
	ADDWF	PCL,F
	GOTO	SS_1
	GOTO	SS_2
	GOTO	SS_3
	GOTO	SS_4

SS_1	MOVF	DISP_A,W
	MOVWF	G_HOUR_10
	GOTO	LP3
SS_2	MOVF	DISP_A,W
	MOVWF	G_HOUR_1
	GOTO	LP3
SS_3	MOVF	DISP_A,W
	MOVWF	G_MIN_10
	GOTO	LP3

LP3	INCF	PASS_C
	MOVLW	0FFH
	MOVWF	DISP_A
	GOTO	LP

SS_4	
	MOVF	DISP_A,W
	MOVWF	G_MIN_1
	
	
	MOVLW	.2
	SUBWF	KEY_IN,W
	BTFSC	STATUS,ZF
	GOTO	SETTING_TIME	;KEY_IN이 2였으면 TIME  SETTING
	GOTO	SETTING_ALARM	;KEY_IN이 3였으면 ALARM SETTING

SETTING_TIME
	MOVF	G_HOUR_10,W
	MOVWF	HOUR_10
	MOVF	G_HOUR_1,W
	MOVWF	HOUR_1
	MOVF	G_MIN_10,W
	MOVWF	MIN_10
	MOVF	G_MIN_1,W
	MOVWF	MIN_1
	
	CLRF	SEC_10
	CLRF	SEC_1

	GOTO	NOACTION
	
SETTING_ALARM
	MOVF	G_HOUR_10,W
	MOVWF	A_HOUR_10
	MOVF	G_HOUR_1,W
	MOVWF	A_HOUR_1
	MOVF	G_MIN_10,W
	MOVWF	A_MIN_10
	MOVF	G_MIN_1,W
	MOVWF	A_MIN_1
	
	GOTO	NOACTION


	
	
	
		
;*********************************************************************************		
NOACTION
	BSF		INTCON,5
	BSF		INTCON,7
	
	BCF		PCLATH,3
	GOTO		MAIN
;*********************************************************************************



SHOW2
	CALL		CONV2
	MOVWF		SEG
	MOVF		SEG,W
	ANDLW		B'11111100'
	MOVWF		PORTC
	
	BTFSC		SEG, 1
	BSF			PORTA, 1
	BTFSS		SEG, 1
	BCF			PORTA, 1
	
	BTFSC		SEG, 0
	BSF			PORTA, 0
	BTFSS		SEG, 0
	BCF			PORTA, 0
	RETURN		
CONV2
	ANDLW	0FH
	ADDWF	PCL, F
	
	RETLW	B'11111100';0
	RETLW	B'01100000';1
	RETLW	B'11011010';2
	RETLW	B'11110010';3
	RETLW	B'01100110';4
	RETLW	B'10110110';5
	RETLW	B'10111110';6
	RETLW	B'11100000';7
	RETLW	B'11111110';8
	RETLW	B'11110110';9
	RETLW	B'00011010';C
	RETLW	B'00000000';
	RETLW	B'00011010';c
	RETLW	B'00000001';.
	RETLW	B'10011110';E
	RETLW	B'10001110';F
DELAY2
	MOVLW	.255
	MOVWF	DBUF1
DLP12	MOVLW	.255
	MOVWF	DBUF2
DLP22	MOVLW	.2
	MOVWF	DBUF3
DLP32	NOP
	DECFSZ	DBUF3,F
	GOTO DLP32
	DECFSZ	DBUF2,F
	GOTO	DLP22
	DECFSZ	DBUF1,F
	GOTO	DLP12
	RETURN	
	END
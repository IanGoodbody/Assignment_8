;-------------------------------------------------------------------------------
;	C2C Ian Goodbody
;	Lab 4: LCD Interfacing
;	MSP430G2553
;
;	Assembly was taken from lab 3
;
;	Draws a variety of images to a Nokia 1202 LCD screen.
;-------------------------------------------------------------------------------
	.cdecls C,LIST,"msp430.h"		; BOILERPLATE	Include device header file


LCD1202_SCLK_PIN:				.equ	20h		; P1.5
LCD1202_MOSI_PIN: 				.equ	80h		; P1.7
LCD1202_CS_PIN:					.equ	01h		; P1.0
LCD1202_BACKLIGHT_PIN:			.equ	10h
LCD1202_RESET_PIN:				.equ	01h
NOKIA_CMD:						.equ	00h
NOKIA_DATA:						.equ	01h

STE2007_RESET:					.equ	0xE2
STE2007_DISPLAYALLPOINTSOFF:	.equ	0xA4
STE2007_POWERCONTROL:			.equ	0x28
STE2007_POWERCTRL_ALL_ON:		.equ	0x07
STE2007_DISPLAYNORMAL:			.equ	0xA6
STE2007_DISPLAYON:				.equ	0xAF

 	.text								; BOILERPLATE	Assemble into program memory
	.retain								; BOILERPLATE	Override ELF conditional linking and retain current section
	.retainrefs							; BOILERPLATE	Retain any sections that have references to current section
	.global clearDisplay
	.global	drawPattern
	.global initNokia
	.global init
	.global waitNLoops

;------------------------------------------------------------------------------
;
;	Name:		waitNLoops
;	Inputs:		R12
;	Outputs:	None
;	Purpose:	Waits the number of cycles specified in R12
;
;	Registers:	R12, Number of loop iterations to wait
;------------------------------------------------------------------------------
waitNLoops:
	push		R12

waitHere:
	dec.w		R12
	jnz			waitHere

	pop R12
	ret

;------------------------------------------------------------------------------
;	Name:		drawPattern
;	Inputs:		R12, R13, R14, R15
;	Outputs:	None
;	Pourpose:	Draws the pattern described in the code header at a speciefied
;				cursor point.
;
;	Registers:	R12, the cursor y-pixel
;				R13, the cursor x-pixel
;				R14, the beginning of the pattern address
;				R15, the length of the pattern array
;------------------------------------------------------------------------------
drawPattern:
	push 	R12
	push	R13
	push	R5			; Stores the number of bytes in the pattern
	push	R6			; Stores the pattern address
	push	R14
	push	R15

	mov		R15, R5
	mov		R14, R6

writeCols:					; Writes the number of columbs specified in Pattern_ln
	tst		R5
	jz		endWriteCols
	mov.b	@R6, R14		; Move the pattern bytes
	call	#drawOffCol
	inc		R6				; Select the next pattern byte
	inc		R13				; Move to the next column
	dec		R5
	jmp		writeCols
endWriteCols:

	pop		R15
	pop		R14
	pop		R6
	pop		R5
	pop		R13
	pop		R12

	ret
;-------------------------------------------------------------------------------
;	Name:		drawOffCol
;	Inputs:		R12, R13, R14
;	Outputs:	None
;	Purpose:	Draws an offset 8 bit column over multiple pages
;
;	Registers:	R12, the row parameter [ROW_COL_MIN, ROW_MAX]
;				R13, the column parameter [ROW_COL_MIN, COL_MAX]
;				R14, the column Byte to be written to the Nokia
;------------------------------------------------------------------------------
drawOffCol:

	push	R5
	push	R6
	push	R7

	push	R13
	push	R12

	; R5 is the n page write bits
	; R6 is the n+1 page write bit
	; R7 is the bit rotation counter

	clr		R6
	mov		R12, R7
	and		#0x07, R7				; mask out upper bits
	rra		R12
	rra		R12						; get the page number from the cursor address
	rra		R12

	mov.b	R14, R5
setPgBits:
	tst		R7						; Rotates the bits from one page to the next
	jz		endSetPg				; Use the remainder from the column parameter to count the rotation
	rla.b	R5
	rlc.b	R6
	dec		R7
	jmp		setPgBits
endSetPg:

	call	#setAddress				; R12 and R13 have already been set

	push 	R12
	push	R13

	mov.w	#NOKIA_DATA, R12		; Write the n data byte to the n page
	mov.w	R5, R13
	call	#writeNokiaByte

	pop 	R13
	pop		R12
	inc		R12						; increment page address
	call	#setAddress

	mov.w	#NOKIA_DATA, R12
	mov.w	R6, R13
	call	#writeNokiaByte			; Write the n+1 data to the n+1 page

	pop 	R12
	pop		R13

	pop		R7
	pop		R6
	pop		R5

	ret
;------------------------------------------------------
;	Name:		initNokia		68(rows)x92(columns)
;	Inputs:		none
;	Outputs:	none
;	Purpose:	Reset and initialize the Nokia Display
;
;	Registers:	R12 mainly used as the command specification for writeNokiaByte
;				R13 mainly used as the 8-bit command for writeNokiaByte
;-------------------------------------------------------------------------------
initNokia:
	push	R12
	push	R13

	bis.b	#LCD1202_CS_PIN, &P1OUT

	; This loop creates a nice delay for the reset low pulse
	bic.b	#LCD1202_RESET_PIN, &P2OUT
	mov		#0FFFFh, R12
delayNokiaResetLow:
	dec		R12
	jne		delayNokiaResetLow

	; This loop creates a nice delay for the reset high pulse
	bis.b	#LCD1202_RESET_PIN, &P2OUT
	mov		#0FFFFh, R12
delayNokiaResetHigh:
	dec		R12
	jne		delayNokiaResetHigh
	bic.b	#LCD1202_CS_PIN, &P1OUT

	; First write seems to come out a bit garbled - not sure cause
	; but it can't hurt to write a reset command twice
	mov		#NOKIA_CMD, R12
	mov		#STE2007_RESET, R13
	call	#writeNokiaByte

	mov		#NOKIA_CMD, R12
	mov		#STE2007_RESET, R13
	call	#writeNokiaByte

	mov		#NOKIA_CMD, R12
	mov		#STE2007_DISPLAYALLPOINTSOFF, R13
	call	#writeNokiaByte

	mov		#NOKIA_CMD, R12
	mov		#STE2007_POWERCONTROL | STE2007_POWERCTRL_ALL_ON, R13
	call	#writeNokiaByte

	mov		#NOKIA_CMD, R12
	mov		#STE2007_DISPLAYNORMAL, R13
	call	#writeNokiaByte

	mov		#NOKIA_CMD, R12
	mov		#STE2007_DISPLAYON, R13
	call	#writeNokiaByte

	pop		R13
	pop		R12

	ret

;-------------------------------------------------------------------------------
;	Name:		init
;	Inputs:		none
;	Outputs:	none
;	Purpose:	Setup the MSP430 to operate the Nokia 1202 Display
;-------------------------------------------------------------------------------
init:
	mov.b	#CALBC1_8MHZ, &BCSCTL1				; Setup fast clock
	mov.b	#CALDCO_8MHZ, &DCOCTL

	bis.w	#TASSEL_1 | MC_2, &TACTL
	bic.w	#TAIFG, &TACTL

	mov.b	#LCD1202_CS_PIN|LCD1202_BACKLIGHT_PIN|LCD1202_SCLK_PIN|LCD1202_MOSI_PIN, &P1OUT
	mov.b	#LCD1202_CS_PIN|LCD1202_BACKLIGHT_PIN|LCD1202_SCLK_PIN|LCD1202_MOSI_PIN, &P1DIR
	mov.b	#LCD1202_RESET_PIN, &P2OUT
	mov.b	#LCD1202_RESET_PIN, &P2DIR
	bis.b	#LCD1202_SCLK_PIN|LCD1202_MOSI_PIN, &P1SEL			; Select Secondary peripheral module function
	bis.b	#LCD1202_SCLK_PIN|LCD1202_MOSI_PIN, &P1SEL2			; by setting P1SEL and P1SEL2 = 1

	bis.b	#UCCKPH|UCMSB|UCMST|UCSYNC, &UCB0CTL0				; 3-pin, 8-bit SPI master
	bis.b	#UCSSEL_2, &UCB0CTL1								; SMCLK
	mov.b	#0x01, &UCB0BR0 									; 1:1
	mov.b	#0x00, &UCB0BR1
	bic.b	#UCSWRST, &UCB0CTL1

	; Buttons on the Nokia 1202
	;	S1		P2.1		Right
	;	S2		P2.2		Left
	;	S3		P2.3		Aux
	;	S4		P2.4		Bottom
	;	S5		P2.5		Up
	;
	;	7 6 5 4 3 2 1 0
	;	0 0 1 1 1 1 1 0		0x3E
	bis.b	#0x3E, &P2REN					; Pullup/Pulldown Resistor Enabled on P2.1 - P2.5
	bis.b	#0x3E, &P2OUT					; Assert output to pull-ups pin P2.1 - P2.5
	bic.b	#0x3E, &P2DIR

	ret

;-------------------------------------------------------------------------------
;	Name:		writeNokiaByte
;	Inputs:		R12 selects between (1) Data or (0) Command string
;				R13 the data or command byte
;	Outputs:	none
;	Purpose:	Write a command or data byte to the display using 9-bit format
;-------------------------------------------------------------------------------
writeNokiaByte:

	push	R12
	push	R13

	bic.b	#LCD1202_CS_PIN, &P1OUT							; LCD1202_SELECT
	bic.b	#LCD1202_SCLK_PIN | LCD1202_MOSI_PIN, &P1SEL	; Enable I/O function by clearing
	bic.b	#LCD1202_SCLK_PIN | LCD1202_MOSI_PIN, &P1SEL2	; LCD1202_DISABLE_HARDWARE_SPI;

	bit.b	#01h, R12
	jeq		cmd

	bis.b	#LCD1202_MOSI_PIN, &P1OUT						; LCD1202_MOSI_LO
	jmp		clock

cmd:
	bic.b	#LCD1202_MOSI_PIN, &P1OUT						; LCD1202_MOSI_HIGH

clock:
	bis.b	#LCD1202_SCLK_PIN, &P1OUT						; LCD1202_CLOCK		positive edge
	nop
	bic.b	#LCD1202_SCLK_PIN, &P1OUT						;					negative edge

	bis.b	#LCD1202_SCLK_PIN | LCD1202_MOSI_PIN, &P1SEL	; LCD1202_ENABLE_HARDWARE_SPI;
	bis.b	#LCD1202_SCLK_PIN | LCD1202_MOSI_PIN, &P1SEL2	;

	mov.b	R13, UCB0TXBUF

pollSPI:
	bit.b	#UCBUSY, &UCB0STAT
	jz		pollSPI											; while (UCB0STAT & UCBUSY);

	bis.b	#LCD1202_CS_PIN, &P1OUT							; LCD1202_DESELECT

	pop		R13
	pop		R12

	ret


;-------------------------------------------------------------------------------
;	Name:		clearDisplay
;	Inputs:		none
;	Outputs:	none
;	Purpose:	Writes 0x360 blank 8-bit columns to the Nokia display
;-------------------------------------------------------------------------------
clearDisplay:
	push	R11
	push	R12
	push	R13

	mov.w	#0x00, R12			; set display address to 0,0
	mov.w	#0x00, R13
	call	#setAddress

	mov.w	#0x01, R12			; write a "clear" set of pixels
	mov.w	#0x00, R13			; to every byt on the display

	mov.w	#0x360, R11			; loop counter
clearLoop:
	call	#writeNokiaByte
	dec.w	R11
	jnz		clearLoop

	mov.w	#0x00, R12			; set display address to 0,0
	mov.w	#0x00, R13
	call	#setAddress

	pop		R13
	pop		R12
	pop		R11

	ret

;-------------------------------------------------------------------------------
;	Name:		setAddress
;	Inputs:		R12		row
;				R13		col
;	Outputs:	none
;	Purpose:	Sets the cursor address on the 9 row x 96 column display
;-------------------------------------------------------------------------------
setAddress:
	push	R12
	push	R13

	; Since there are only 9 rows on the 1202, we can select the row in 4-bits
	mov.w	R12, R13			; Write a command, setup call to
	mov.w	#NOKIA_CMD, R12
	and.w	#0x0F, R13			; mask out any weird upper nibble bits and
	bis.w	#0xB0, R13			; mask in "B0" as the prefix for a page address
	call	#writeNokiaByte

	; Since there are only 96 columns on the 1202, we need 2 sets of 4-bits
	mov.w	#NOKIA_CMD, R12
	pop		R13					; make a copy of the column address in R13 from the stack
	push	R13
	rra.w	R13					; shift right 4 bits
	rra.w	R13
	rra.w	R13
	rra.w	R13
	and.w	#0x0F, R13			; mask out upper nibble
	bis.w	#0x10, R13			; 10 is the prefix for a upper column address
	call	#writeNokiaByte

	mov.w	#0x00, R12			; Write a command, setup call to
	pop		R13					; make a copy of the top of the stack
	push	R13
	and.w	#0x0F, R13
	call	#writeNokiaByte

	pop		R13
	pop		R12

	ret


;-------------------------------------------------------------------------------
;           System Initialization
;-------------------------------------------------------------------------------
	.global __STACK_END					; BOILERPLATE
	.sect 	.stack						; BOILERPLATE
	.sect   ".reset"                	; BOILERPLATE		MSP430 RESET Vector


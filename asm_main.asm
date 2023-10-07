; Turn LED Red when pressed
			.thumb

			.text					; Following put in ROM

; Port 4 Registers
P4IN    	.word	0x40004C21		; Port 4 Input
P4OUT   	.word	0x40004C23		; Port 4 Output
P4DIR   	.word	0x40004C25		; Port 4 Direction
P4REN   	.word	0x40004C27		; Port 4 Resistor Enable
P4DS    	.word	0x40004C29		; Port 4 Drive Strength
P4SEL0  	.word	0x40004C2B		; Port 4 Select 0
P4SEL1  	.word	0x40004C2D		; Port 4 Select 1

; Port 5 Registers
P5IN    	.word	0x40004C40		; Port 5 Input
P5OUT   	.word	0x40004C42		; Port 5 Output
P5DIR   	.word	0x40004C44		; Port 5 Direction
P5REN   	.word	0x40004C46		; Port 5 Resistor Enable
P5DS    	.word	0x40004C48		; Port 5 Drive Strength
P5SEL0  	.word	0x40004C4A		; Port 5 Select 0
P5SEL1  	.word	0x40004C4C		; Port 5 Select 1



			.global asm_main
			.thumbfunc asm_main

asm_main:	.asmfunc				; Main
	BL   	GPIO_Init
	LDR  	R1, P4OUT               ; R0 = Red LED
	LDR 	R2, P5IN				; P1 Input
loop:
	BL 		DELAY_LOOP
	BL   	GPIO_Input
	CMP		R0, #0x00				; Check if SW pressed (neg logic)
	BEQ		TOGGLE
	B		TURN_ON_LED

TOGGLE:
	PUSH	{R3, LR}					; Save context

	LSL R3, #0x01
	CMP R3, #0x02
	BEQ TURN_OFF_LED
	MOV R3, #0X01
	B	TURN_ON_LED

	MOV R3, #0x10
	STRB R3, [R1]

	POP		{R3, LR}					; Restore context
	B		loop


TURN_ON_LED:
	PUSH	{R3, LR}					; Save context

	MOV		R3, #0x11				; Need to set pin 2 to 1 to keep pull up
	STRB	R3, [R1]

	POP		{R3, LR}					; Restore context
	B		loop

TURN_OFF_LED:
	PUSH	{R3, LR}					; Save context
	MOV		R3, #0x10					; Need to set pin 2 to 1 to keep pull up
	STRB	R3, [R1]

	POP		{R3, LR}					; Restore context
	B		loop
			.endasmfunc

GPIO_Init:	.asmfunc
	PUSH	{R0-R1}					; Save context

	; Init P1 init
	LDR 	R1, P4SEL0
	LDRB	R0, [R1]
	BIC		R0, R0, #0x01           ; Configure pins as GPIO
	STRB	R0, [R1]

	LDR		R1, P4SEL1
	LDRB	R0, [R1]
	BIC		R0, R0, #0x01           ; Configure pins as GPIO
	STRB 	R0, [R1]

	; Make pins output
	LDR		R1, P4DIR
	LDRB	R0, [R1]
	ORR		R0, R0, #0x01
	STRB	R0, [R1]

    LDR  	R1, P5SEL0
    LDRB 	R0, [R1]
    BIC  	R0, R0, #0x01           ; Enable pull resistor
    STRB 	R0, [R1]

    LDR  	R1, P5SEL1
    LDRB 	R0, [R1]
    BIC  	R0, R0, #0x01           ; Enable pull-up resistor
    STRB 	R0, [R1]

    POP		{R0-R1}					; Restore context

	BX   	LR
			.endasmfunc

GPIO_Input:	.asmfunc
	; Get P1 input and return via R0
	LDRB	R0, [R2]
	BIC		R0, R0, #0xFE           ; Clear upper 7 bits

	BX   	LR
			.endasmfunc

DELAY_LOOP: .asmfunc
	MOV R0, #0xF424
WAIT SUBS R0, R0, #0x01
	BNE WAIT

	BX   	LR
			.endasmfunc

	        .end

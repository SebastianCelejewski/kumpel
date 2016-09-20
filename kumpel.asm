; kumpel.asm

; Author : Sebastian Celejewski

; Port configuration
; 
; PD7, PD6, PD5, PD4 - stepper engine data output
; PD1, PD0, PC5, PC4 - stepper engine address output
; PC3 - stepper engine GND
; 
; PC2, PC1, PC3, PB5, PB4, PB3, PB2, PB1 - controller data input
; PB0 - controller Vcc
; GND - controller GND

start:

	; Setting up stack
	ldi R16, low(RAMEND)
	out SPL, R16
	ldi R16, high(RAMEND)
	out SPH, R16

	; Setting ports direction
	ldi r16, 0b11110011
	out ddrd, r16

	ldi r16, 0b00111100
	out ddrc, r16

	ldi r16, 0b00000001
	out ddrb, r16

	; setting power
	; setting port C bit 3 to 0 (GND for flip-flops)
	; setting port C bits 0..2 to 1 (pull-up for controller buttons)
	ldi r16, 0b00000111
	out portc, r16
	
	; setting port B bits 1..5 to 1 (pull-up for controller buttons)
	; setting port B bit 0 to 1 (Vcc for controller buttons)
	ldi r16, 0b00111111
	out portb, r16

loop:


	; 0x0100 -> motor 1 pointer
	; 0x0101 -> motor 2 pointer
	; 0x0102 -> motor 3 pointer

	; sending step data to stepper motor 1
	ldi zh, high(steps << 1)
	ldi zl, low(steps << 1)
	lds r17, 0x0100
	add zl, r17
	
	; sending value with clock bit set to 0	
	lpm r16, z
	out portd, r16
	rcall delay

	; sending value with clock bit set to 1
	sbr r16, 1
	out portd, r16
	rcall delay

	; checking if button 0 (turn head left) is pressed
	in r16, pinc
	sbrs r16, 0
	rjmp button_0_is_not_pressed

	; turning head left
	lds r16, 0x0100
	inc r16
	sts 0x0100, r16
	cpi r16, 4
	brne loop
	ldi r16, 0
	sts 0x0100, r16
	rjmp loop

button_0_is_not_pressed:

	sbrs r16, 1
	rjmp button_1_is_not_pressed

	; turning head right
	lds r16, 0x0100
	cpi r16, 0x00
	brne q
	ldi r16, 4
q:
	dec r16
	sts 0x0100, r16
	rjmp loop

button_1_is_not_pressed:

	rjmp loop

delay:
	ldi r17, 0x00
	ldi r18, 0x04
      
delay_loop: 
	dec	r17		
	brne delay_loop 	
	dec	r18		
	brne delay_loop 	
	ret

steps:
	.db 0b10010000, 0b11000000
	.db 0b01100000, 0b00110000
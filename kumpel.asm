; kumpel.asm

; Author : Sebastian Celejewski

start:

	; Setting up stack
	ldi R16, low(RAMEND)
	out SPL, R16
	ldi R16, high(RAMEND)
	out SPH, R16

	; Stepper engine controller configuration

	; setting all port B bits to output
	ldi r16, 0b11111111
	out ddrb, r16

	; Button controller configuration

	; setting port C bit 0 for output (GND)
	; setting port C bit 1 for output (VCC)
	; setting port C bit 2 for input (button 0 - turn head left) 
	; setting port C bit 3 for input (button 1 - turn head right)
	ldi r16, 0b00000011
	out ddrc, r16

	; setting port C bit 0 to 0 (GND)
	; setting port C bit 1 to 1 (VCC)
	; setting port C bit 2 to 1 (pull-up for button 0 - turn head left)
	; setting port C bit 3 to 1 (pull-up for button 1 - turn head right)
	ldi r16, 0b00001110
	out portc, r16

loop:

	rcall delay

	; sending step data to stepper motor
	ldi zh, high(steps << 1)
	ldi zl, low(steps << 1)
	lds r17, 0x0100
	add zl, r17
	lpm r16, z
	out portb, r16

	; checking if button 0 (turn head left) is pressed
	in r16, pinc
	sbrs r16, 2
	rjmp button_0_is_not_pressed

	; turning head left
	lds r16, 0x0100
	inc r16
	sts 0x0100, r16
	cpi r16, 8
	brne loop
	ldi r16, 0
	sts 0x0100, r16
	rjmp loop

button_0_is_not_pressed:

	sbrs r16, 3
	rjmp button_1_is_not_pressed

	; turning head right
	lds r16, 0x0100
	cpi r16, 0x00
	brne q
	ldi r16, 8
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

steps:	.db 0b00001001, 0b00011001
		.db 0b00001100, 0b00011100
		.db 0b00000110, 0b00010110
		.db 0b00000011, 0b00010011
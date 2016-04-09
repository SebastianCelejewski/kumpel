; kumpel.asm
;
; Author : Sebastian Celejewski

start:

; Setting up stack
	ldi R16, low(RAMEND)
	out SPL, R16
	ldi R16, high(RAMEND)
	out SPH, R16

	ldi r16, 0b11111111
	out ddrb, r16

loop:

	rcall delay

	; loading data from ram
	ldi zh, high(steps << 1)
	ldi zl, low(steps << 1)
	lds r17, 0x0100
	add zl, r17
	lpm r16, z

	out portb, r16

	; increasing counter at 100h
	lds r16, 0x0100
	inc r16
	sts 0x0100, r16
	cpi r16, 8
	brne loop
	ldi r16, 0
	sts 0x0100, r16
	rjmp loop

delay:
	ldi r17, 0x00
	ldi r18, 0x40
      
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
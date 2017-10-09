;
; 1602A.asm
;
; Created: 2017-10-09 21:57:24
; Author : Sebastian
;

start:

	; Setting direction for port B: bits 0..5 output
	ldi r16, 0b00011111
	out ddrb, r16

	; Setting direction for port C: bits 0..1 output
	ldi r16, 0b00000011
	out ddrc, r16

	; Setting output for port B
	; bit 0 (Vss) = 0
	; bit 1 (Vdd) = 1
	; bit 2 (Vee) = 1
	; bit 3 (RS) = 0
	; bit 4 (RW) = 0
	; bit 5 (E) = 0
    ldi r16, 0b00000110
	out portb, r16

	; Setting output for port C (backlight)
	; bit 0 (BLA) = 1
	; bit 1 (BLK) = 0
	ldi r16, 0b00000001
	out portc, r16

loop:
    rjmp loop
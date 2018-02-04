;
; 1602A.asm
;
; Created: 2017-10-09 21:57:24
; Author : Sebastian

; Pin assignment
; B0 - Vss (power 0V)
; B1 - Vdd (power 5V)
; B2 - Vo  (power LCD)
; B3 - RS (register select, 0 - instruction, 1 - data)
; B4 - RW (read/write, 0 - write, 1 - read)
; B5 - E (write enable)

; C0 - data bit 0
; C1 - data bit 1
; C2 - data bit 2
; C3 - data bit 3
; C4 - data bit 4
; C5 - data bit 5
; D0 - data bit 6
; D1 - data bit 7

; D4 - A (backlight 5V)
; D5 - K (backlight 0V)

start:

	ldi r16, low(RAMEND)
	out SPL, r16
	ldi r16, high(RAMEND)
	out SPH, r16
 
	ldi r16, 0xFF
	out DDRB, r16

	; Setting direction for port B: bits 0..5 output
	ldi r16, 0b00111111
	out ddrb, r16

	; Setting direction for port C: bits 0..5 output
	ldi r16, 0b00111111
	out ddrc, r16

	; Setting direction for port D: bits 0,1,4,5 output
	ldi r16, 0b11110011
	out ddrd, r16

	; Initial setting for power and control bits
	; bit 0 (Vss) = 0 (GND)
	; bit 1 (Vdd) = 1 (power)
	; bit 2 (Vee) = 0 (LCD power - inverted)
	; bit 3 (RS) = 0 (instruction)
	; bit 4 (RW) = 0 (write)
	; bit 5 (E) = 0 (register enable)
    ldi r16, 0b00000010
	out portb, r16

	; Initial setting for data bits and backlight
	ldi r16, 0b00000000
	out portc, r16

	// pd4 = 1 (backlight 5V)
	ldi r16, 0b00010000
	out portd, r16

	ldi r16, 0b00000001 ; clear display
	rcall send_command

	ldi r16, 0b00001111 ; display on
	rcall send_command

	ldi r16, 0b01000001  ; letter 'A'
	ldi r17, 25
loop:
	rcall send_data
	rcall delay_long
	inc r16
	dec r17
	brne loop

end:
    rjmp end

; r16 - command to be sent
send_command:
	push r16

	; Setting up sending command
	cbi portb, 3   ; Register Select = instruction
	cbi portb, 4   ; Read/Write = write
	cbi portb, 5
	rcall delay_write

	sbi portb, 5
	rcall delay_write

	; Sending command
	pop r16
	push r16
	out portc, r16
	lsr r16
	lsr r16
	lsr r16
	lsr r16
	lsr r16
	lsr r16
	sbr r16, 16
	out portd, r16
	rcall delay_write

	cbi portb, 5
	rcall delay_write

	pop r16
	ret

; r16 - data to be sent
send_data:
	push r16

	; Setting up sending command
	sbi portb, 3   ; Register Select = data
	cbi portb, 4   ; Read/Write = write
	
	; Setting data
	pop r16
	push r16

	out PortC, r16
	lsr r16
	lsr r16
	lsr r16
	lsr r16
	lsr r16
	lsr r16
	sbr r16, 16
	out portd, r16
	rcall delay_write

	cbi portb, 5    ; write
	sbi portb, 5
	rcall delay_write

	pop r16
	ret

delay_long:
	push r16
	ldi r16, 8
outer_loop:
	rcall delay_short 
	dec r16
	brne outer_loop
	pop r16
	ret

delay_short:
	push r24
	push r25
	ldi r24, low(3037)
	ldi r25, high(3037)
	delay_loop:
	adiw r24, 1
	brne delay_loop
	pop r25
	pop r24
	ret

delay_write:
	push r16
	ldi r16, 0xff
dw1:
	dec r16
	brne dw1
	pop r16
	ret

blink:
	cbi PortD, 4
	rcall delay_short
	sbi PortD, 4
	rcall delay_long
	ret

double_blink:
	cbi PortD, 4
	rcall delay_short
	sbi PortD, 4
	rcall delay_short
	cbi PortD, 4
	rcall delay_short
	sbi PortD, 4
	rcall delay_long
	ret
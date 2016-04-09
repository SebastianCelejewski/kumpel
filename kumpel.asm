; kumpel.asm
;
; Author : Sebastian Celejewski

start:

; Setting up stack
	ldi R16, low(RAMEND)
	out SPL, R16
	ldi R16, high(RAMEND)
	out SPH, R16

loop:
    inc r16
    rjmp loop

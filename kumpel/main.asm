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

    ; Setting ports direction  0 - in, 1 - out
    ldi r16, 0b00000001  ; PB0 out as Vcc, PB1..PB5 as inputs, PB6..PB7 not used
    out ddrb, r16

    ldi r16, 0b00111000  ; PC0..PC2 as inputs, PC3..PC5 as outputs, PC6..PC7 not used
    out ddrc, r16

    ldi r16, 0b11110011  ; PD0..PD1 as outputs, PD2..PD3 not used, PD4..PD7 as outputs
    out ddrd, r16

    ; setting power

    ; setting port B bit 0 to 1 (Vcc for controller buttons)
    ; setting port B bits 1..5 to 1 (pull-up for controller buttons)
    ldi r16, 0b00111111
    out portb, r16

    ; setting port C bits 0..2 to 1 (pull-up for controller buttons)
    ; setting port C bit 3 to 0 (GND for flip-flops)
    ldi r16, 0b00000111
    out portc, r16

    ; setting step for motor 1 to 0
    ldi r16, 0
    sts 0x0100, r16

    ; setting step for motor 2 to 0
    ldi r16, 0
    sts 0x0101, r16

    ; setting step for motor 3 to 0
    ldi r16, 0
    sts 0x0102, r16

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

    ; sending value with clock bit set to 1
    sbr r16, 1
    out portd, r16

    ; sending step data to stepper motor 2
    ldi zh, high(steps << 1)
    ldi zl, low(steps << 1)
    lds r17, 0x0101
    add zl, r17

    ; sending value with clock bit set to 0 
    lpm r16, z
    out portd, r16

    ; sending value with clock bit set to 1
    sbr r16, 2
    out portd, r16

    ; sending step data to stepper motor 3
    ldi zh, high(steps << 1)
    ldi zl, low(steps << 1)
    lds r17, 0x0102
    add zl, r17

    ; sending value with clock bit set to 0 
    lpm r16, z
    out portd, r16      ; sending data
    ldi r16, portc      ; clearing address line for motor 3
    cbr r16, 0b00100000
    out portc, r16

    ; sending value with clock bit set to 1
    lpm r16, z
    out portd, r16      ; sending data
    ldi r16, portc      ; setting address line for motor 3
    sbr r16, 0b00100000
    out portc, r16

    ; Delay for stepper motors
    rcall delay

    ; reading buttons status
    in r16, pinb  ; button lines D0..D4 are loaded into bits 1..5, bits 0, 6, and 7 are unknown
    ldi r18, 0b00111110 ;
    and r16, r18        ; clearing all bits that do not represent button lines
    lsr r16    ; now button lines D0..D4 are loaded into bits 0..4
    in r17, pinc  ; button lines D5..D7 are loaded into bits 0..2, bits 3..7 are unknown
    ldi r18, 0b00000111
    and r17, r17  ; clearing all bits that do not represent button lines
    lsl r17
    lsl r17
    lsl r17
    lsl r17
    lsl r17    ; button lines D5..D7 are loaded into bits 5..7
    or r16, r17   ; button lines D0..D7 are loaded into bits 0..7

    ; performing actions based on which buttons are pressed

    sbrc r16, 0
    rcall engine_1_down

    sbrc r16, 1
    rcall engine_1_up

    sbrc r16, 2
    rcall engine_2_down

    sbrc r16, 3
    rcall engine_2_up

    sbrc r16, 4
    rcall engine_3_down

    sbrc r16, 5
    rcall engine_3_up

    rjmp loop

engine_1_up:
    push r16
    lds r16, 0x0100
    inc r16
    sts 0x0100, r16
    cpi r16, 4
    brne engine_1_return
    ldi r16, 0
    sts 0x0100, r16
engine_1_return:
    pop r16
    ret

engine_1_down:
    push r16
    lds r16, 0x0100
    cpi r16, 0x00
    brne engine_1_step_reset
    ldi r16, 4
engine_1_step_reset:
    dec r16
    sts 0x0100, r16
    pop r16
    ret

engine_2_up:
    push r16
    lds r16, 0x0101
    inc r16
    sts 0x0101, r16
    cpi r16, 4
    brne engine_2_return
    ldi r16, 0
    sts 0x0101, r16
engine_2_return:
    pop r16
    ret

engine_2_down:
    push r16
    lds r16, 0x0101
    cpi r16, 0x00
    brne engine_2_step_reset
    ldi r16, 4
engine_2_step_reset:
    dec r16
    sts 0x0101, r16
    pop r16
    ret

engine_3_up:
    push r16
    lds r16, 0x0102
    inc r16
    sts 0x0102, r16
    cpi r16, 4
    brne engine_3_return
    ldi r16, 0
    sts 0x0102, r16
engine_3_return:
    pop r16
    ret

engine_3_down:
    push r16
    lds r16, 0x0102
    cpi r16, 0x00
    brne engine_3_step_reset
    ldi r16, 4
engine_3_step_reset:
    dec r16
    sts 0x0102, r16
    pop r16
    ret

delay:
    ldi r17, 0x00
    ldi r18, 0x04
delay_loop: 
    dec r17  
    brne delay_loop  
    dec r18  
    brne delay_loop  
    ret

steps:
    .db 0b10010000, 0b11000000
    .db 0b01100000, 0b00110000
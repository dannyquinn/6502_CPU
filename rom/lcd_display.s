PORTB = $6000 
PORTA = $6001 
DDRB  = $6002 
DDRA  = $6003 

E  = %10000000
RW = %01000000
RS = %00100000 



.setcpu "65C02"
.segment "ROM" 

RESET:
    lda #%11111111  ; Set Port B all pins output 
    sta DDRB 
    lda #%11100000  ; Set Port A top 3 pins output 
    sta DDRA 

    lda #%00111000  ; Set 8 bit mode, 2 line display, 5x8 font 
    sta PORTB 

    lda #0          ; Clear RS/RW/E bits 
    sta PORTA 

    lda #E          ; Set enable bit 
    sta PORTA 

    lda #0 
    sta PORTA       ; Clear

    lda #%00001110  ; Display on; cursor on; blink off 
    sta PORTB 

    lda #E          ; 
    sta PORTA 

    lda #0 
    sta PORTA

    lda #%00000110  ; Increment and shift cursor; don't shift display 
    sta PORTB 

    lda #E 
    sta PORTA 

    lda #0 
    sta PORTA 

    lda #'D'
    sta PORTB 

    lda #RS 
    sta PORTA 

    lda #(RS | E)
    sta PORTA 

    lda #RS 
    sta PORTA

    lda #'a' 
    sta PORTB 

    lda #(RS | E)
    sta PORTA 

    lda #RS 
    sta PORTA 

    lda #'n'
    sta PORTB 

    lda #(RS | E) 
    sta PORTA 

    lda #RS 
    sta PORTA 

LOOP:
    jmp LOOP



.segment "RESETVEC" 
.word $0F00 
.word RESET 
.word $0000

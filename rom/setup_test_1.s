.setcpu "65C02" 
.segment "ROM"

RESET:
  LDA #$FF
  STA $6002 

LOOP:
  LDA #$55
  STA $6000 

  LDA #$AA
  STA $6000

  JMP LOOP

.segment "RESETVEC"

.word $0F00 
.word RESET 
.word $0000

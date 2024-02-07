.segement "WOZMAN"

XAML        = $24                   ; Last opened location low 
XAMH        = $25                   ; Last opened location high 
STL         = $26                   ; Store address low 
STH         = $27                   ; Store address high 
L           = $28                   ; Hex value parsing low 
H           = $29                   ; Hex value parsing high 
YSAV        = $2A                   ; Use to see if hex value is given 
MODE        = $2B                   ; $00=XAM, $7F=STOR, $AE=BLOCK XAM 

IN          = $0200                 ; Input buffer 

ACIA_DATA   = $5000
ACIA_STATUS = $5001
ACIA_CMD    = $5002
ACIA_CTRL   = $5003 

RESET:
    LDA     #$1F                    ; 8-N-1, 19200 baud 
    STA     ACIA_CTRL               ;
    LDA     #$0B                    ; No parity, no echo, no interupts
    STA     ACIA_CMD                ;
    LDA     #$1B                    ; Begin with escape 

NOTCR:
    CMP     #$08                    ; Backspace key? 
    BEQ     BACKSPACE               ; 
    CMP     #$1B                    ; Escape?
    BEQ     ESCAPE                  ;
    INY                             ; Advanced text index 
    BPL     NEXTCHAR                ; Auto ESC if like longer than 127

ESCAPE: 
    LDA     #$5C                    ; "\"
    JSR     ECHO                    ;  

GETLINE:
    LDA     #$0D                    ; Send CR 
    JSR     ECHO                    ; 
    LDY     #$01                    ; Initialize text index 

BACKSPACE: 
    DEY                             ; Backup text index 
    BMI     GETLINE                 ; Beyond start of line, reinitialize 

NEXTCHAR:
    LDA     ACIA_STATUS             ; Check status 
    AND     #$08                    ; Key ready?
    BEQ     NEXTCHAR                ; Loop until ready 
    LDA     ACIA_DATA               ; Load character, B7 will be 0
    STA     IN, Y                   ; Add to text buffer 
    JSR     ECHO                    ; Display character 
    CMP     #$0D                    ; Carriage Return?
    BNE     NOTCR                   ; No.
    LDY     #$FF                    ; Reset the text index 
    LDA     #$00                    ; For XAM mode 
    TAX                             ; X=0

SETBLOCK:
    ASL                             ; 

SETSTOR:
    ASL                             ; Leaves $7B if setting STOR mode 
    STA     MODE                    ; $00 = XAM, $74 = STOR, $B8 = BLOCK XAM

BLSKIP:
    INY                             ; Advance index index 

NEXTITEM:
    LDA     IN, Y                   ; Get character 
    CMP     #$0D                    ; Carriage return?
    BEQ     GETLINE                 ; Yes
    CMP     #$2E                    ; "."
    BCC     BLSKIP                  ; Skip delimiter 
    BEQ     SETBLOCK                ; Set block to XAM mode 
    CMP     #$3A                    ; ":"
    BEQ     SETSTOR                 ; Yes, set STOR mode 
    CMP     #$52                    ; "R"
    BEQ     RUN                     ; Yes, run user program 
    STX     L                       ; $00 -> L 
    STX     H                       ;     -> H 
    STY     YSAV                    ; Save Y for comparison

NEXTHEX:
    LDA     IN, Y                   ; Get character for hex test 
    EOR     #$30                    ; Map digits to $0-9 
    CMP     #$0A                    ; Digit?
    BCC     DIG                     ; Yes 
    ADC     #$88                    ; Map letter "A"-"F" to $FA-FF.
    CMP     #$FA                    ; Hex letter? 
    BCC     NOTHEX                  ; No, character not hex 

DIG:                  
    ASL                             ; Hex digit to MSD of A
    ASL                             ;
    ASL                             ;
    ASL                             ;

    LDX     #$04;                   ; Shift count 

HEXSHIFT:
    ASL                             ; Hex digit left, MSB to carry 
    ROL     L                       ; Rotate into LSD 
    ROL     H                       ; Rotate into MSD's
    DEX                             ; Done 4 shifts?
    BNE     NEXSHIFT                ; No, keep going 
    INY                             ; Advance text index 
    BNE     NEXTHEX                 ; Always taken.  Check next character for hex

NOTHEX: 
    CPY     YSAV                    ; Check if L, H empty (no hex digits)
    BEQ     ESCAPE                  ; Yes generate escape sequence

    BIT     MODE                    ; Test MODE byte 
    BVC     NOTSTOR                 ; B6=0 is STOR, 1 is XAM, and Block XAM 

    LDA     L                       ; LSD's of hex data 
    STA     (STL, X)                ; Store current 'store index'
    INC     STL                     ; Increment store index 
    BNE     NEXTITEM                ; Get next item (no carry)
    INC     STH                     ; Add carry to 'store index' high order 

TONEXTITEM:
    JMP     NEXTITEM                ; Get next command line 

RUN: 
    JUMP    (XAML)                  ; Run at current XAM address 

NOTSTOR:
    BMI     XAMNEXY                 ; B7 = 0 for XAM, 1 for BLOCK XAM
    LDX     #$02                    ; Byte count 



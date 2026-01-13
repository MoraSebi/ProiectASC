.DATA
    C_WORD          DW 0 ; Variabila pentru rezultatul pe 16 biti
    MSG_C_VAL       DB 0Dh, 0Ah, '1. Cuvantul C calculat (Hex): $'
    MSG_ROT_HEX     DB 0Dh, 0Ah, '4a. Sirul dupa rotiri (Hex): $'

.CODE
; Calculează cuvântul C conform cerințelor de XOR, OR și Sumă
CALCULATE_C PROC
    ; --- Pas 3: Suma Modulo 256 (Octetul Superior al lui C) ---
    XOR AX, AX
    MOV CX, NR_OCTETI
    LEA SI, SIR_OCTETI
SUMA_LP:
    ADD AL, [SI]    ; Adunare pe 8 biți (AL asigură automat modulo 256)
    INC SI
    LOOP SUMA_LP
    MOV BYTE PTR C_WORD + 1, AL ; Salvăm suma în High Byte (AH)

    ; --- Pas 1: XOR biții 0-3 ai lui C ---
    MOV SI, OFFSET SIR_OCTETI
    MOV AL, [SI]
    SHR AL, 4       ; Izolăm nibble superior primul octet
    MOV DI, OFFSET SIR_OCTETI
    ADD DI, NR_OCTETI
    DEC DI
    MOV BL, [DI]    ; Ultimul octet
    AND BL, 0Fh     ; Izolăm nibble inferior ultimul octet
    XOR AL, BL      ; XOR conform cerinței
    AND AL, 0Fh     ; Păstrăm doar 4 biți
    MOV BYTE PTR C_WORD, AL

    ; --- Pas 2: OR biții 2-5 pentru toți octeții (Rezultatul în biții 4-7 ai lui C) ---
    XOR BL, BL      ; Registru pentru stocarea rezultatului OR
    MOV CX, NR_OCTETI
    LEA SI, SIR_OCTETI
OR_LP:
    MOV AL, [SI]
    AND AL, 00111100b ; Mască pentru biții 2,3,4,5
    SHR AL, 2       ; Aliniem biții pe pozițiile 0-3
    OR BL, AL       ; Aplicăm OR succesiv
    INC SI
    LOOP OR_LP
    SHL BL, 4       ; Mutăm rezultatul OR pe pozițiile 4-7
    OR BYTE PTR C_WORD, BL ; Combinăm cu nibble-ul XOR calculat anterior
    RET
CALCULATE_C ENDP

; Realizează rotația circulară la stânga (ROL) conform sumei ultimilor 2 biți
ROTIRE_SIR PROC
    MOV CX, NR_OCTETI
    LEA SI, SIR_OCTETI
R_L:
    MOV AL, [SI]
    MOV BL, AL
    AND BL, 03h     ; N = Suma biților 0 și 1
    JZ SKIP_ROT     ; Dacă N=0, nu este necesară nicio rotație
    PUSH CX         ; Salvăm CX pentru a nu interfera cu rotația
    MOV CL, BL      ; Numărul de poziții pentru ROL
    ROL AL, CL      ; Rotație circulară la stânga
    POP CX
    MOV [SI], AL    ; Salvăm valoarea modificată înapoi în vector
SKIP_ROT:
    INC SI
    LOOP R_L
    RET
ROTIRE_SIR ENDP
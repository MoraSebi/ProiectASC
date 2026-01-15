.MODEL SMALL
.STACK 100h

.DATA
    MSG_START       DB 'Introduceti intre 8 si 16 octeti in hex (ex: 3F 7A...): $'
    MSG_C_VAL       DB 0Dh, 0Ah, '1. Cuvantul C calculat (Hex): $'
    MSG_SORTED      DB 0Dh, 0Ah, '2. Sirul sortat descrescator: $'
    MSG_POS_BIT     DB 0Dh, 0Ah, '3. Pozitia primului octet cu >3 biti de 1: $'
    MSG_ROT_HEX     DB 0Dh, 0Ah, '4a. Sirul dupa rotiri (Hex): $'
    MSG_ROT_BIN     DB 0Dh, 0Ah, '4b. Sirul dupa rotiri (Binar): $'
    
    BUFFER          DB 100, 0, 100 DUP('$') 
    SIR_OCTETI      DB 16 DUP(0)
    NR_OCTETI       DW 0
    C_WORD          DW 0
    HEX_STR         DB '0123456789ABCDEF'

.CODE
START:
    MOV AX, @DATA
    MOV DS, AX
    MOV ES, AX

    ; --- CITIRE ---
    LEA DX, MSG_START
    MOV AH, 09h
    INT 21h

    LEA DX, BUFFER
    MOV AH, 0Ah
    INT 21h
    CALL CONVERT_INPUT

    ; --- CALCUL C ---
    CALL CALCULATE_C
    LEA DX, MSG_C_VAL
    MOV AH, 09h
    INT 21h
    MOV DX, C_WORD
    CALL PRINT_HEX_WORD

    ; --- SORTARE ---
    CALL BUBBLE_SORT
    LEA DX, MSG_SORTED
    MOV AH, 09h
    INT 21h
    CALL AFISARE_SIR_HEX
    
    ; --- CAUTARE POZITIE ---
    CALL GASIRE_OCTET_BITI

    ; --- ROTIRI ---
    CALL ROTIRE_SIR
    LEA DX, MSG_ROT_HEX
    MOV AH, 09h
    INT 21h
    CALL AFISARE_SIR_HEX
    LEA DX, MSG_ROT_BIN
    MOV AH, 09h
    INT 21h
    CALL AFISARE_SIR_BIN

    MOV AX, 4C00h
    INT 21h


CONVERT_INPUT PROC
    LEA SI, BUFFER + 2
    LEA DI, SIR_OCTETI
    XOR BX, BX          ; BX va fi contorul de octeti
    
NEXT_BYTE:
    CALL FIND_NEXT_HEX
    JC FIN_C            ; Carry setat daca nu mai sunt caractere
    MOV DH, AL          ; DH = primul nibble
    
    INC SI
    CALL FIND_NEXT_HEX
    JC SAVE_SINGLE      ; Daca s-a terminat sirul dupa un singur nibble
    
    MOV DL, AL          ; DL = al doilea nibble
    SHL DH, 4
    OR DH, DL
    MOV [DI], DH
    INC DI
    INC BX
    INC SI
    CMP BX, 16
    JE FIN_C
    JMP NEXT_BYTE

SAVE_SINGLE:
    SHL DH, 4
    MOV [DI], DH
    INC BX
FIN_C:
    MOV NR_OCTETI, BX
    RET
CONVERT_INPUT ENDP

FIND_NEXT_HEX PROC      ; Cauta primul caracter hex valid pornind de la SI
    LOD_LOOP:
        MOV AL, [SI]
        CMP AL, 0Dh
        JE END_STR
        CMP AL, ' '
        JE NEXT_CHAR
        
        ; Verificare si conversie
        CMP AL, '0'
        JB NEXT_CHAR
        CMP AL, '9'
        JBE IS_NUM
        AND AL, 0DFh    ; Upper case
        CMP AL, 'A'
        JB NEXT_CHAR
        CMP AL, 'F'
        JA NEXT_CHAR
        SUB AL, 7       ; Ajustare A-F
    IS_NUM:
        SUB AL, '0'
        AND AL, 0Fh
        CLC
        RET
    NEXT_CHAR:
        INC SI
        JMP LOD_LOOP
    END_STR:
        STC
        RET
FIND_NEXT_HEX ENDP


CALCULATE_C PROC
    ; Pas 3: Suma Modulo 256 (High Byte)
    XOR AX, AX
    MOV CX, NR_OCTETI
    LEA SI, SIR_OCTETI
SUMA_LP:
    ADD AL, [SI]
    INC SI
    LOOP SUMA_LP
    MOV BYTE PTR C_WORD + 1, AL

    ; Pas 1: XOR Nibbles
    MOV SI, OFFSET SIR_OCTETI
    MOV AL, [SI]
    SHR AL, 4           ; Nibble superior primul octet
    MOV DI, OFFSET SIR_OCTETI
    ADD DI, NR_OCTETI
    DEC DI
    MOV BL, [DI]
    AND BL, 0Fh         ; Nibble inferior ultimul octet
    XOR AL, BL
    AND AL, 0Fh
    MOV BYTE PTR C_WORD, AL

    ; Pas 2: OR biții 2-5
    XOR BL, BL
    MOV CX, NR_OCTETI
    LEA SI, SIR_OCTETI
OR_LP:
    MOV AL, [SI]
    AND AL, 00111100b
    SHR AL, 2
    OR BL, AL
    INC SI
    LOOP OR_LP
    SHL BL, 4
    OR BYTE PTR C_WORD, BL
    RET
CALCULATE_C ENDP


BUBBLE_SORT PROC
    MOV CX, NR_OCTETI
    DEC CX
    JZ FIN_S
OUT_S:
    PUSH CX
    LEA SI, SIR_OCTETI
INN_S:
    MOV AL, [SI]
    CMP AL, [SI+1]
    JAE NO_SW
    XCHG AL, [SI+1]
    MOV [SI], AL
NO_SW:
    INC SI
    LOOP INN_S
    POP CX
    LOOP OUT_S
FIN_S: RET
BUBBLE_SORT ENDP

GASIRE_OCTET_BITI PROC
    LEA DX, MSG_POS_BIT
    MOV AH, 09h
    INT 21h
    
    MOV CX, NR_OCTETI
    LEA SI, SIR_OCTETI
    MOV BL, 1           ; Indexul curent
G_LP:
    MOV AL, [SI]
    XOR DL, DL          ; DL numara bitii
    PUSH CX
    MOV CX, 8
C_LP:
    SHL AL, 1
    ADC DL, 0
    LOOP C_LP
    POP CX
    
    CMP DL, 3
    JA FND
    INC SI
    INC BL
    LOOP G_LP
    MOV DL, '-'
    MOV AH, 02h
    INT 21h
    RET
FND:
    MOV AL, BL
    XOR AH, AH
    AAM                 ; AH=zeci, AL=unitati
    ADD AX, 3030h
    MOV DX, AX
    CMP DH, '0'         ; Nu afisam zecile daca sunt 0
    JE AF_UNIT
    PUSH AX
    MOV DL, DH
    MOV AH, 02h
    INT 21h
    POP AX
AF_UNIT:
    MOV DL, AL
    MOV AH, 02h
    INT 21h
    RET
GASIRE_OCTET_BITI ENDP

ROTIRE_SIR PROC
    MOV CX, NR_OCTETI
    LEA SI, SIR_OCTETI
R_L:
    MOV AL, [SI]
    MOV BL, AL
    AND BL, 03h         ; Ultimii 2 biti
    JZ SKIP_ROT
    PUSH CX
    MOV CL, BL
    ROL AL, CL
    POP CX
    MOV [SI], AL
SKIP_ROT:
    INC SI
    LOOP R_L
    RET
ROTIRE_SIR ENDP

AFISARE_SIR_HEX PROC
    MOV CX, NR_OCTETI
    LEA SI, SIR_OCTETI
AF_H:
    MOV AL, [SI]
    CALL PRINT_AL_HEX
    MOV DL, ' '
    MOV AH, 02h
    INT 21h
    INC SI
    LOOP AF_H
    RET
AFISARE_SIR_HEX ENDP

AFISARE_SIR_BIN PROC
    MOV CX, NR_OCTETI
    LEA SI, SIR_OCTETI
A_B:
    PUSH CX
    MOV AL, [SI]
    MOV CX, 8
B_L:
    SHL AL, 1
    MOV DL, '0'
    ADC DL, 0
    PUSH AX
    MOV AH, 02h
    INT 21h
    POP AX
    LOOP B_L
    MOV DL, ' '
    MOV AH, 02h
    INT 21h
    INC SI
    POP CX
    LOOP A_B
    RET
AFISARE_SIR_BIN ENDP

PRINT_AL_HEX PROC
    PUSH BX
    MOV AH, 0
    PUSH AX
    SHR AL, 4
    LEA BX, HEX_STR
    XLAT
    MOV DL, AL
    MOV AH, 02h
    INT 21h
    POP AX
    AND AL, 0Fh
    XLAT
    MOV DL, AL
    MOV AH, 02h
    INT 21h
    POP BX
    RET
PRINT_AL_HEX ENDP

PRINT_HEX_WORD PROC
    PUSH DX
    MOV AL, DH
    CALL PRINT_AL_HEX
    POP DX
    MOV AL, DL
    CALL PRINT_AL_HEX
    RET
PRINT_HEX_WORD ENDP

END START

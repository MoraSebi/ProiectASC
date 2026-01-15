.DATA
    MSG_START       DB 'Introduceti intre 8 si 16 octeti in hex (ex: 3F 7A...): $'
    BUFFER          DB 100, 0, 100 DUP('$') ; Buffer extins pentru siguranta
    SIR_OCTETI      DB 16 DUP(0)           ; Vectorul de stocare a valorilor
    NR_OCTETI       DW 0                    ; Contor octeti procesati
    HEX_STR         DB '0123456789ABCDEF'  ; Tabela lookup pentru XLAT

.CODE
; Procedura principala de conversie a sirului citit de la tastatura
CONVERT_INPUT PROC
    LEA SI, BUFFER + 2  ; Sărim peste primii 2 octeți ai bufferului DOS
    LEA DI, SIR_OCTETI  ; Destinația valorilor binare
    XOR BX, BX          ; Resetăm contorul de octeți reali
    
NEXT_BYTE:
    CALL FIND_NEXT_HEX  ; Caută primul nibble valid
    JC FIN_C            ; Dacă Carry=1, am ajuns la capătul șirului
    MOV DH, AL          ; Salvăm primul nibble (superior)
    
    INC SI              ; Avansăm la următorul caracter
    CALL FIND_NEXT_HEX  ; Caută al doilea nibble valid
    JC SAVE_SINGLE      ; Dacă nu mai există caractere, salvăm nibble-ul singur
    
    MOV DL, AL          ; DL = al doilea nibble (inferior)
    SHL DH, 4           ; Mutăm primul nibble pe poziția 4-7
    OR DH, DL           ; Combinăm pentru a forma un octet complet
    MOV [DI], DH        ; Salvăm octetul în vector
    INC DI              ; Incrementăm pointerul de destinație
    INC BX              ; Incrementăm numărul de octeți găsiți
    INC SI              ; Trecem la caracterul următor
    CMP BX, 16          ; Verificăm limita maximă de 16 octeți
    JE FIN_C
    JMP NEXT_BYTE

SAVE_SINGLE:            ; Cazul în care avem un nibble "rătăcit" la final
    SHL DH, 4
    MOV [DI], DH        ; Îl salvăm așa cum e.
    INC BX              ; Incrementăm contorul.
FIN_C:
    MOV NR_OCTETI, BX   ; Salvăm numărul total de octeți procesați
    RET
CONVERT_INPUT ENDP

; Caută un caracter Hex valid (0-9, A-F) și îl convertește în valoare binară
FIND_NEXT_HEX PROC
    LOD_LOOP:
        MOV AL, [SI]    ; Încărcăm în AL caracterul curent indicat de SI.
        CMP AL, 0Dh     ; Verificăm terminatorul de șir (Enter)
        JE END_STR
        CMP AL, ' '     ; Ignorăm spațiile
        JE NEXT_CHAR    ; Dacă e spațiu, îl ignorăm și trecem la următorul.
        
        ; Verificăm dacă caracterul este între '0' și '9'
        CMP AL, '0'
        JB NEXT_CHAR
        CMP AL, '9'
        JBE IS_NUM    ; Mergem la conversia numerica
        
        ; Tratăm literele (A-F), forțând majuscula
        AND AL, 0DFh    ; Mică -> Mare (bitul 5 resetat)
        CMP AL, 'A'
        JB NEXT_CHAR    ; Sub A nu e valid
        CMP AL, 'F'
        JA NEXT_CHAR    ; Peste F nu e valid
        SUB AL, 7       ; Ajustăm distanța între codul ASCII al '9' și 'A'
    IS_NUM:
        SUB AL, '0'     ; Obținem valoarea numerică (0-15)
        AND AL, 0Fh     ; Mască pentru siguranță (4 biți)
        CLC             ; Succes: resetăm Carry
        RET
    NEXT_CHAR:
        INC SI          ; Trecem la următorul caracter din buffer
        JMP LOD_LOOP
    END_STR:
        STC             ; Eșec (sfârșit de șir): setăm Carry
        RET
FIND_NEXT_HEX ENDP

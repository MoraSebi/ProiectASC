.DATA
    ; Mesaje pentru interfața cu utilizatorul
    MSG_SORTED      DB 0Dh, 0Ah, '2. Sirul sortat descrescator: $'
    MSG_POS_BIT     DB 0Dh, 0Ah, '3. Pozitia primului octet cu >3 biti de 1: $'
    MSG_ROT_BIN     DB 0Dh, 0Ah, '4b. Sirul dupa rotiri (Binar): $'

.CODE

BUBBLE_SORT PROC
    MOV CX, NR_OCTETI ; CX devine contorul pentru numărul de elemente
    DEC CX            ; Avem nevoie de (N-1) treceri pentru a sorta N elemente
    JZ FIN_S        ; Dacă șirul are un singur element (sau zero), ieșim direct

OUT_S:              ; Bucla exterioară (parcurge șirul de mai multe ori)
    PUSH CX           ; Salvăm CX pe stivă pentru că îl vom folosi și în bucla internă
    LEA SI, SIR_OCTETI ; Resetăm SI la începutul șirului pentru o nouă trecere

INN_S:              ; Bucla internă (compară elemente adiacente)
    MOV AL, [SI]      ; Încărcăm elementul curent în AL
    CMP AL, [SI+1]    ; Comparăm elementul curent cu următorul
    JAE NO_SW       ; JAE = Jump if Above or Equal. Dacă AL >= următorul, nu facem nimic
    
    XCHG AL, [SI+1] ; Schimbăm AL cu valoarea de la adresa [SI+1]
    MOV [SI], AL    ; Punem noua valoare (mai mare) înapoi la adresa [SI]

NO_SW:
    INC SI            ; Trecem la următorul octet
    LOOP INN_S        ; Decrementăm CX (intern) și reluăm bucla internă dacă CX > 0
    
    POP CX            ; Restaurăm CX pentru bucla exterioară
    LOOP OUT_S        ; Decrementăm CX (extern) și reluăm bucla exterioară
FIN_S: 
    RET               ; Revenire din procedură
BUBBLE_SORT ENDP

GASIRE_OCTET_BITI PROC
    LEA DX, MSG_POS_BIT ; Afișăm titlul secțiunii
    MOV AH, 09h
    INT 21h
    
    MOV CX, NR_OCTETI ; Setăm contorul pentru numărul total de octeți de verificat
    LEA SI, SIR_OCTETI
    MOV BL, 1       ; Folosim BL pentru a ține evidența indexului uman (începe de la 1)

G_LP:               ; Bucla principală de parcurgere a octeților
    MOV AL, [SI]      ; Luăm octetul curent pentru procesare
    XOR DL, DL      ; DL va fi contorul nostru de biți. Îl resetăm la 0
    PUSH CX         ; Salvăm CX (contorul de octeți) deoarece C_LP folosește și el CX
    MOV CX, 8       ; Un octet are 8 biți, deci bucla internă rulează de 8 ori

C_LP:               ; Bucla de numărare a biților de '1' prin shiftare
    SHL AL, 1       ; Shift Left: Bitul cel mai semnificativ ajunge în Carry Flag (CF)
    ADC DL, 0       ; ADC = Add with Carry. Adunăm valoarea lui CF (0 sau 1) la DL
    LOOP C_LP       ; Repetăm pentru toți cei 8 biți
    
    POP CX          ; Restaurăm contorul de octeți
    
    CMP DL, 3       ; Comparăm densitatea găsită cu pragul de 3 biți
    JA FND          ; JA = Jump if Above. Dacă DL > 3, am găsit octetul dorit
    
    INC SI            ; Trecem la adresa următorului octet
    INC BL            ; Incrementăm indexul poziției
    LOOP G_LP       ; Reluăm căutarea pentru restul șirului
    
    MOV DL, '-'     ; Afișăm o liniuță dacă niciun octet nu îndeplinește criteriul
    MOV AH, 02h
    INT 21h
    RET             ; Ieșim din procedură

FND:                ; --- Secțiune de afișare a poziției găsite ---
    MOV AL, BL      ; Punem indexul în AL pentru conversie
    XOR AH, AH      ; Ne asigurăm că AH este zero
    AAM             ; ASCII Adjust after Multiplication: împarte AL la 10.
                    ; Rezultat: AH = cifra zecilor, AL = cifra unităților.
    ADD AX, 3030h   ; Convertim cifrele numerice în caractere ASCII ('0'-'9')
    MOV DX, AX      ; Salvăm cifrele în DX (DH = zeci, DL = unități)
    
    CMP DH, '0'     ; Verificăm dacă cifra zecilor este '0'
    JE AF_UNIT      ; Dacă da, nu afișăm zero-ul din față (ex: afișăm '5', nu '05')
    
    PUSH AX         ; Salvăm temporar cifrele
    MOV DL, DH      ; Pregătim cifra zecilor pentru afișare
    MOV AH, 02h     ; Funcția DOS pentru afișare caracter
    INT 21h
    POP AX          ; Restaurăm unitățile

AF_UNIT:
    MOV DL, AL      ; Pregătim cifra unităților pentru afișare
    MOV AH, 02h
    INT 21h
    RET
GASIRE_OCTET_BITI ENDP

AFISARE_SIR_BIN PROC
    MOV CX, NR_OCTETI
    LEA SI, SIR_OCTETI

A_B:                ; Buclă pentru fiecare octet din șir
    PUSH CX
    MOV AL, [SI]      ; Octetul curent
    MOV CX, 8       ; Resetăm CX pentru a procesa 8 biți

B_L:                ; Buclă pentru afișarea fiecărui bit în parte
    SHL AL, 1       ; Extragem bitul în Carry Flag (CF)
    MOV DL, '0'     ; Presupunem că bitul este 0
    ADC DL, 0       ; Dacă CF=1, DL devine '1'. Dacă CF=0, DL rămâne '0'
    
    PUSH AX         ; Salvăm AL (care conține restul biților)
    MOV AH, 02h     ; Afișăm caracterul '0' sau '1'
    INT 21h
    POP AX          ; Restaurăm AL pentru următoarea shiftare
    LOOP B_L        ; Repetăm până afișăm toți cei 8 biți

    MOV DL, ' '     ; După fiecare octet binar, afișăm un spațiu pentru lizibilitate
    MOV AH, 02h
    INT 21h
    
    INC SI            ; Trecem la următorul octet din SIR_OCTETI
    POP CX          ; Restaurăm contorul de șir
    LOOP A_B        ; Reluăm procesul pentru următorul octet
    RET
AFISARE_SIR_BIN ENDP
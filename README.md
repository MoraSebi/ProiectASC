Proiectarea unui Sistem de Procesare a Datelor în Limbaj de Asamblare 8086

Acest proiect implementează un utilitar de nivel scăzut pentru manipularea secvențelor de date hexadecimale, utilizând arhitectura segmentată a procesorului Intel 8086. Aplicația demonstrează concepte fundamentale de informatică, precum conversia bazelor de numerație, algoritmi de sortare, manipularea flag-urilor de procesor și operații logice la nivel de bit.

1. Descrierea Obiectivelor

Sistemul a fost conceput pentru a procesa șiruri de date cu lungime variabilă, cuprinsă între 8 și 16 octeți. Scopul principal este transformarea unui input de tip text (ASCII) într-o structură de date numerică asupra căreia se pot aplica transformări matematice complexe și algoritmi de organizare.

2. Arhitectura Sistemului și Modulele Logice
2.1 Modulul de Conversie și Validare

Prima etapă a programului este responsabilă pentru preluarea datelor brute din buffer-ul de tastatură. Spre deosebire de o citire simplă, acest modul implementează o logică avansată de filtrare și conversie:

Identifică și ignoră caracterele non-hexadecimale și spațiile suplimentare.

Grupează caracterele ASCII valide în perechi pentru a forma octeți (nibble superior și nibble inferior).

Realizează maparea caracterelor din intervalul 'A'–'F' la valorile numerice corespunzătoare (10–15).

2.2 Algoritmul de Calcul al Parametrului C

Cuvântul de control C funcționează ca o semnătură a șirului de date și este generat prin combinarea a trei procese independente:

Suma octeților
Se calculează suma aritmetică a tuturor elementelor din șir. Rezultatul este trunchiat la 8 biți și este plasat în partea superioară a cuvântului de control.

Operația XOR extremă
Se extrag biții cei mai semnificativi ai primului element și biții cei mai puțin semnificativi ai ultimului element, asupra cărora se aplică operația de excludere logică (XOR).

Agregarea la nivel de bit
Se parcurge șirul pentru a extrage biții aflați pe pozițiile 2–5 ale fiecărui octet. Acești biți sunt combinați prin operații OR succesive, pentru a identifica prezența oricărui bit activ în această zonă specifică.

2.3 Modulul de Reorganizare (Bubble Sort)

Pentru ordonarea datelor, programul utilizează algoritmul Bubble Sort, adaptat pentru lucrul direct cu registrele de index ale procesorului:

Se efectuează treceri succesive prin zona de memorie ce conține datele.

Se compară elementele adiacente utilizând instrucțiuni de comparație.

Se realizează interschimbarea valorilor prin instrucțiunea XCHG, în funcție de starea flag-urilor Carry și Zero.

Rezultatul final este un șir de date ordonat descrescător.

2.4 Analiza Densității Binare

Acest modul funcționează ca un motor intern de analiză binară și are următoarele etape:

Fiecare octet este analizat individual prin rotații succesive prin bitul de Carry.

Se numără biții setați la valoarea 1.

Se identifică primul element din șir care are o densitate de biți 1 mai mare de 37.5%, adică mai mult de 3 biți setați din 8.

2.5 Transformarea prin Rotație Dinamică

Ultima etapă aplică o transformare structurală fiecărui octet din șir:

Numărul de rotații nu este fix.

Valoarea rotației este determinată de ultimii doi biți ai fiecărui element.

Se execută instrucțiuni de shiftare sau rotație controlate direct de datele de intrare.

Acest modul demonstrează un comportament data-driven, în care datele influențează fluxul de execuție al instrucțiunilor.

3. Detalii de Implementare Tehnică

Programul este construit utilizând modelul de memorie SMALL, cu un singur segment de cod și un singur segment de date, pentru optimizarea timpului de execuție și a accesului la memorie.

3.1 Gestiunea Registrelor

Registrele SI și DI sunt utilizate pentru parcurgerea tablourilor de date.

Registrul AX este folosit pentru calcule aritmetice și operații intermediare.

Registrul CX este rezervat controlului structurilor repetitive (LOOP).

3.2 Interfața cu Sistemul de Operare

Comunicarea cu utilizatorul se realizează prin întreruperi software DOS (INT 21h).

Sunt utilizate subfuncții dedicate pentru:

Citirea buffer-ului de la tastatură

Afișarea șirurilor de caractere

Afișarea caracterelor individuale

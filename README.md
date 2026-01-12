Proiectarea unui Sistem de Procesare a Datelor în Limbaj de Asamblare 8086
Acest proiect implementează un utilitar de nivel scăzut pentru manipularea secvențelor de date hexadecimale, utilizând arhitectura segmentată a procesorului Intel 8086. Aplicația demonstrează concepte fundamentale de informatică, precum conversia bazelor de numerație, algoritmi de sortare, manipularea flag-urilor de procesor și operații logice la nivel de bit.

Descrierea Obiectivelor
Sistemul a fost conceput pentru a procesa șiruri de date cu lungime variabilă (între 8 și 16 octeți). Scopul principal este transformarea unui input de tip text (ASCII) într-o structură de date numerică pe care se pot aplica transformări matematice complexe și algoritmi de organizare.

Arhitectura Sistemului și Modulele Logice
1. Modulul de Conversie și Validare
Prima etapă a programului este responsabilă pentru preluarea datelor brute din buffer-ul de tastatură. Spre deosebire de o citire simplă, acest modul implementează o logică de filtrare:

Identifică și ignoră caracterele non-hexadecimale și spațiile suplimentare.

Grupează caracterele ASCII în perechi pentru a forma octeți (nibble superior și nibble inferior).

Realizează maparea caracterelor din intervalul 'A'-'F' la valorile numerice corespunzătoare (10-15).

2. Algoritmul de Calcul al Parametrului C
Cuvântul de control (C) funcționează ca o semnătură a șirului de date și este generat prin trei procese paralele:

Suma Octeților: Se calculează suma aritmetică a întregului șir. Rezultatul, trunchiat la 8 biți, ocupă partea superioară a cuvântului de control.

Operația XOR Extremă: Se extrag biții cei mai semnificativi ai primului element și biții cei mai puțin semnificativi ai ultimului element, aplicându-se o operație de excludere logică.

Agregarea Bit-Level: Se parcurge șirul pentru a extrage biții de pe pozițiile 2-5 ale fiecărui octet. Aceștia sunt combinați prin operații OR succesive pentru a identifica prezența biților activi în acea zonă specifică a memoriei.

3. Modulul de Reorganizare (Bubble Sort)
Pentru ordonarea datelor, programul utilizează algoritmul Bubble Sort adaptat pentru lucrul direct cu registrele de index. Procesul presupune treceri succesive prin memoria segmentului de date și interschimbarea valorilor (XCHG) în funcție de starea flag-ului de transport (Carry) și a flag-ului de zero, rezultând un șir final ordonat descrescător.

4. Analiza Densității Binare
Acest modul funcționează ca un motor de căutare intern. Acesta analizează compoziția internă a fiecărui octet prin rotații succesive prin bitul de Carry. Obiectivul este identificarea primului element din șir care prezintă o densitate de biți "1" mai mare de 37.5% (adică mai mult de 3 biți setați din 8).

5. Transformarea prin Rotație Dinamică
Ultima etapă de procesare aplică o modificare structurală fiecărui octet. Valoarea de rotație nu este fixă, ci este determinată de starea internă a fiecărui element (mai exact, valoarea ultimilor doi biți). Aceasta demonstrează capacitatea programului de a executa instrucțiuni de tip date-driven, unde datele de intrare dictează comportamentul instrucțiunilor de shiftare.

Detalii de Implementare Tehnică
Programul este construit pe modelul de memorie SMALL, utilizând un singur segment de cod și un singur segment de date, ceea ce optimizează viteza de execuție și accesul la memorie.

Gestiunea Registrelor: Se utilizează intensiv registrele SI (Source Index) și DI (Destination Index) pentru parcurgerea tablourilor de date. Registrul AX este utilizat pentru operații aritmetice intermediare, în timp ce CX este rezervat pentru controlul loop-urilor.

Interfața cu Sistemul de Operare: Comunicarea cu utilizatorul și afișarea rezultatelor se realizează prin întreruperile software de sistem (DOS Interrupt 21h), utilizând subfuncții pentru citire buffer, afișare string-uri și scriere caractere individuale.

Instrucțiuni pentru Compilare și Rulare
Asigurați-vă că aveți un mediu de emulare MS-DOS (cum ar fi DOSBox) configurat corect.

Utilizați un asamblator (TASM sau MASM) pentru a genera fișierul obiect: tasm nume_fisier.asm

Utilizați un linker pentru a crea fișierul executabil: tlink nume_fisier.obj

Rulați fișierul .exe și introduceți între 8 și 16 valori hexadecimale separate prin spațiu.

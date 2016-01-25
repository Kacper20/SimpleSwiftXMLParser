###TKOM Parser XML
#####Kacper Harasim
#####kacper.harasim@gmail.com


###Opis wykonania

Projekt został wykonany jako parser rekursywnie zstępujący. Parser zawiera zestaw funkcji tworzących drzewo dokumentu.

####Gramatyka
Zdefiniowana została podstawowa gramatyka dla XML:
-XML ::= header node*		
 -header ::= begin_token ? xml <attribute>* ? end_token		
 -name ::= ciag_znakow_bez_spacji		
 -string ::= name  | whitespaces |  name whitespaces string		
 -attribute ::= <name> <equal_sign> >attr_value>		
 -whitespace ::= //comment: couple of whitespaces in converted into just one.		
 -equal_sign ::= =		
 -attr_value ::= " <string> "		
 -begin_token -> <		
 -end_token -> >		
 -close_token -> </		
 -autoclose_token -> />		
 -open_end_tag ::=  begin_token name <attribute> <autoclose_token>		
 -| begin_token name <autoclose_token>		
 -open_tag ::= <begin_token> <name> <end_token>		
 -| <begin_token> <name> <attribute> <end_token>		
 -end_tag ::= <close_token> <name> <end_token>		
 -node ::= <open_tag> <content> <end_tag>		
 -| <open_tag> <node> <end_tag>		
 -| <open_end_tag>




####Struktura plików
Struktura plików jest następująca:


*GSearchClient.swift - klasa, która odpowiedzialna jest za synchroniczne wywołania HTTP do serwera Google Search.
*GSearchXMLAnalyzer.swift - program kliencki, który odpowiada za "wyciągnięcie" danych ze zbudowanego dokumentu XML. Chodzenie po strukturze jest wykonywane jak standardowe przejście struktury drzewiastej.
Parser.swift - klasa odpowiadająca za zbudowanie obiektu XMLDocument, który jest obiektem o strukturze drzewiastej. Znajduje się w niej sam parser rekursywnie zstępujący.
*Streams.swift - abstrakcja strumieniu danych. Definiuje interfejs jaki powinien mieć strumień, aby parser odpowiednio z nim pracował. Zdefiniowany jest również strumień w pamięci. W razie parsowania b. dużych plików możliwe jest zdefiniowane np. parsera czytającego z pliku na dysku, z sieci itp.
*TokenScanner.swift - część analyzatora leksykalnego. Zbudowana jako generator tokenów. Dostaje strumień, a z niego wyciąga kolejne tokeny, które później wędrują do analizatora składniowego.
*Token.swift - zdefiniowana jest tu struktura tokenu tj. wszystkie możliwe jego formy.
*main.swift - funkcja, która uruchamia zapytania i zajmuje się ich obsługą oraz wyświetleniem danych o które prosi użytkownik


Obsługa błędów zaimplementowana w parserze jest prosta - zwraca jego typ, bez lokalizacji.

####Opis obiektów na poziomie drzewa.
Drzewo dokumentu składa się z kilku elementów:
* XMLDocument - główny obiekt, zawiera XMLHeader, oraz listę obiektów XMLNode, które reprezentują standardowe węzły. XMLHeader jest elementem wymaganym, dokument może jednak nie mieć żadnych węzłów(tzn. jest dozwolone aby lista była pusta).
* XMLHeader - obiekt nagłówka, zawiera nazwę, oraz listę atrybutów w postaci obiektów XMLNodeAttribute
* XMLNode - obiekt węzła, zawiera nazwę, listą atrybutów, oraz zawartość. Zawartością może być: łańcuch tekstowy, bądź też lista obiektów XMLNode.
* XMLNodeAttribute - atrybut, zawiera klucz oraz wartość.

####Instrukcja uruchomienia

Na początku potrzebujemy skompilować pliki:
Wchodzimy do katalogu i uruchamiamy: swiftc GSearchClient.swift Token.swift TokenScanner.swift GSearchXMLAnalyzer.swift Parser.swift main.swift Streams.swift -o nazwa

Powstaje nam wynikowy plik wykonywalny.

Uruchamiamy go z argumentami: ./nazwa zapytanie maksymalna_ilość plik_wynikowy

Plik wynikowy to plik do którego zostanie zapisany JSON z rezultatami.

####Testy

Przeprowadzone zostały testy na outpucie z API GSearch - wszystkie zadziałały w porządku.




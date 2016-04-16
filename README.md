# ActiveJoy

Wir werden uns hier eine kleine bewusstseinserweiternde Droge zusammenkochen, in unserem *Math*-Labor und mit fielen sharphen Werkzeugen. Sobald sie in unsere Gehirnwindungen eingedrungen ist, besteht die Gefahr, dass sie süchtig macht, dort kräftig umstrukturiert und jede Menge Freude hinterlässt. Das Rezept: Wir beginnen mit purem [Joy](https://en.wikipedia.org/wiki/Joy_%28programming_language%29), strecken es mit etwas .NET und fertig ist der Straßenname *ActiveJoy*.

Schluss mit den überspannten Wortspielen, Taten warten. Ihr kennt sicherlich den Stapel, engl. [Stack](https://en.wikipedia.org/wiki/Stack_%28abstract_data_type%29), eine der fundamentalsten Datenstrukturen überhaupt. Wir können zum Beispiel Terme so aufschreiben, dass wir sie leicht mithilfe eines Stacks ausrechnen können, das ist die [umgekehrte polnische Notation](https://www.activevb.de/tutorials/tut_polnat/polnat.html). 

    1 2 + 3 *

Wir lesen von links nach rechts: Lege 1 auf den Stack, lege 2 auf den Stack. Lies die obersten zwei Elemente vom Stack, addiere sie, lege das Ergebnis wieder ab. Schreibe 3, lies und multipliziere. Am Ende finden wir das Ergebnis `(1 + 2) * 3 = 9` auf dem Stapel. 

Das ist alles in allem ein sehr banaler Ausführungsmodus für ein Program, der Stack ist die einzige Datenstruktur und wir arbeiten uns durch eine Serie von Anweisungen. Natürlich könnte man das ganze mit mehr Anweisungen aufmöbeln und schon ein paar interessante Dinge tun:

    "Hallo, Welt!" printn
    "Wie heißt du? " print
    "Hallo, " readln + printn

Das wäre so ein Stapelprogramm, das jetzt Strings und ein bisschen I/O beherrscht. Die Seitenbeschreibungssprache *PostScript* arbeitet beispielsweise so. Klar, was das Programm tut? Dann könnte man zu zu zwei fälschlichen Schlussfolgerungen gelangen: Erstens, dass Stapelprogramme sehr eingeschränkter Art sind und nur starr einen Befehlsablauf abarbeiten. Und zweitens, dass die Sprachen dazu sehr rudimentär und low-level sind, wie Assembler, und meilenweit entfernt von modernen objektorientierten oder funktionalen Programmiersprachen. Tatsächlich handelt es sich vielleicht um die einfachste Sprache, in der sich nichttriviale Dinge anstellen lassen, aber alles ist möglich. Und dafür benötigen wir nur noch eine einzige Zutat: Eckige Klammern

# Quotations und Metaprogrammierung

Ein Programm war bis jetzt einfach eine Folge von Wörtern/Atomen, ein *Satz* wie 

    1 2 "Hallo" print + 

Was neu dazukommt ist die Möglichkeit, Sätze in eckige Klammern zu schreiben. 

    [1 2 +]

Was in `[]` gesetzt wird, nennt sich *Quotation*. Der Inhalt der Quotation wird nun nicht mehr ausgeführt, sondern *so wie er ist* auf den Stack gelegt. Nach obigem Programmdurchlauf liegt nun der Satz `1 2 +` auf dem Stack! Was soll er dort? Naja, wir können mit ihm hantieren, wie wir wollen! Programme und Daten - dasselbe. Und wir können ihn natürlich vom Stack runternehmen und auführen. Das macht das Wort `i`:

    [1 2 +] i

bringt das Ergebnis `3` auf dem Stack. Erst den Satz ablegen, dann wieder nehmen und ausführen. Ich notiere das mal mit `==`, wenn zwei Sätze das gleiche Ergebnis auf dem Stack liefern

    [1 2 +] i == 1 2 + == 3

Das Wort `concat` vereinigt die beiden obersten Sätze auf dem Stack wie Listen, z.B.

    [1 2] [3] concat == [1 2 3]

Wir können damit aber genauso gut Programme vereinigen (und dann ausführen):

    ["Hallo, " print] ["wie geht's?" print] concat i == "Hallo, " print "wie geht's?" print

Sätze auf den Stack zu legen, wirkt wie eine Spielerei, aber bringt es uns tatsächlich Neues? Denken wir einmal über dieses fundamental wichtige Sätzchen nach

    [dup i] dup i 

Das Wort `i` kennen wir, `dup` nimmt das oberste Element vom Stack und legt es nocheinmal drauf, dupliziert es. Aha, also schoneinmal

    [dup i] dup == [dup i] [dup i]

Der Satz `dup i` liegt jetzt zwei mal auf dem Stack. Jetzt folgt die Ausführung von `i`, der oberste Satz wird ausgeführt. Wir landen wieder bei

    [dup i] dup i

Aber das ist doch ... eine Endlosschleife. Hallo Kontrollfluss! Die Existenz von Quotations erlaubt es uns, Programme flexibel zu gestalten und ganze Programmteile an *Kombinatoren* zu übergeben. Ausblick:

    0 [10 <] ["kleiner Zehn" print] ["nicht kleiner Zehn" print] if

Bevor wir allerdings richtig loslegen mit der Programmgestaltung, müssen wir noch ein bisschen Geläufigkeit im Umgang mit dem Stack bekommen, denn die Denkweise ist schon gewaltig anders, als man das gewohnt ist. 

# Übungen mit dem Stack

Ich mache einfach ein paar Beispiele: `dup` kennen wir, noch einfacher ist `pop`

    1 2 pop == 1

verwirft einfach das oberste Element vom Stack. `swap` tauscht die obersten beiden

    2 3 swap == 3 2

Wichtiger ist das unscheinbare Wörtchen `dip`. Bis jetzt können Wörter immer nur auf die obersten Elemente des Stacks wirken, irgendwie müssen wir aber in die Tiefe gehen können. `dip` nimmt das oberste Element `a` vorsichtig vom Stapel, führt `i` aus und legt `a` wieder hin. Das heißt, wir führen eine Quotation aus, die an zweiter Stelle steht

    2 2 [*] 5 dip == 2 2 * 5 == 4 5

Wozu könnte man das gebrauchen? Bedenken wir einmal die Kombination von `dip` mit `swap`, kurz `swip`. 

    2 5 [1 +] swip == 2 5 [1 +] swap dip == 2 [1 +] 5 dip == 2 1 + 5 == 3 5

Wir haben also mit `swip` auf das zweitoberste Element gewirkt statt nur auf das oberste. Wir können dieses Muster auch benutzen, um Elemente tiefer aus dem Stack hervorzutauchen. Sagen wir, wir haben `1 2 3` auf dem Stack, wie kommen wir wieder an die 1? Kurz nachgedacht, Antwort:

    1 2 3 [[dup] swip swap] swip swap == 1 2 3 1 

**Aufgabe 1:** Wie könnte ein Verfahren aussehen, mit dem wir den Stack beliebig permutieren können, also die obersten Elemente in eine vorgegebene Reihenfolge bringen?

Ein weiteres Beispiel: Sagen wir, es kommt eine Zahl `x` auf den Stack und wir möchten prüfen, ob gilt: `x >= 0 and x <= 10`. Wir rechnen

    dup 10 <= [0 >=] swip and


# Kontrollfluss

Um ordentliche Programme zu schreiben, brauchen wir zunächst noch eine Möglichkeit, uns nicht ständig zu wiederholen, d.h. eigene Wörter zu definieren. Schreiben wir das mal so

    define square { dup * }

und dann

    4 square == 4 dup * == 4 4 * == 16

Für Verzweigungen benutzen wir unseren ersten Kombinator: `if`. Zunächst ein Beispiel

    5 [2 % 0 =] [2 /] [3 * 1 +] if

Die Zahl `5` liegt auf dem Stack, und wir prüfen: Ist die Zahl gerade, wenn ja, halbiere sie, wenn nicht, verdreifache und addiere Eins - das ist die [Collatz-Iteration](https://de.wikipedia.org/wiki/Collatz-Problem).

    define collatz { [2 % 0 =] [2 /] [3 * 1 +] if }

    5 collatz collatz collatz collatz collatz

liefert übrigens den Endwert `1`, wie vermutet. Was tut also `if`? Wir übergeben drei Quotations wie in

    cond truePart falsePart if

holen sie vom Stapel und führen `cond` aus, was einen booleschen Wert auf den Stapel legen sollte. Wenn dieser True ist, führen wir `truePart` aus, sonst `falsePart`. Aber, jetzt kommt der Trick, wir stellen den Stack von *vor dem `cond`-Aufruf* wieder her. Sonst wäre der Wert, (hier 5) ja in der Abfrage von `cond` bereits vom Stapel verschwunden und wir müssten ihn nervig duplizieren. Kompliziert, ich weiß, aber mit `if` und `define` können wir uns unsere ersten rekursiven Methoden bauen: Die gute alte Fakultät

    define fact {
        [0 =]
        [pop 1]
        [dup 1 - fact *]
        if
    }

Und tatsächlich

    6 fact == 720

**Aufgabe 2:** Implementiert das berühmte Zahlenraten. Das Programm ermittelt eine Zufallszahl zwischen 1 und 100 und lässt uns die Zahl raten, wobei es immer angibt, ob der Versuch zu hoch oder zu niedrig war. Ich mache mal den Anfang

    1 100 rand // Die Zufallszahl bestimmen
    "Ihr Tip? " print readln int

Wie geht's weiter? `readln` liest eine Eingabezeile von der Konsole und legt sie auf den Stack. `int` parst einen String zu einer Ganzzahl. Ach ja, Kommentare im C-Style, also `//` und `/**/` sind erlaubt, das ist aber nicht Teil der offiziellen Sprach-Spezifikation. Wir wollen ja die einfachstmögliche Sprache ;)

# Kombinatoren 1 - bin

ActiveJoy wirkt irgendwie verquer, keine Variablen, seltsame Arten, zu Schleifen zu gelangen. Das Geheimnis der Sprache sind die Kombinatoren. Wir *wollen* ja gar keine Schleife schreiben, wir wollen eine Aufgabe lösen, und das heißt Teiloperationen in einer klaren Weise zusammensetzen. Spätestens jetzt ist klar, dass ActiveJoy kein Assember-Verschnitt ist, sondern wir hochgradig funktional programmieren.

Erinnern wir an das Beispiel von vorhin: Wir möchten checken, ob eine Zahl `x` vom Stack zwischen 0 und 10 liegt. Das war

    5 dup 10 <= [0 >=] swip and

Alles korrekt, aber irgendwie unintuitiv. Es wäre doch schöner, wenn wir

    5 [0 >=] [10 <=] bin and

schreiben würden. `bin` nimmt zwei Operationen und wendet sie beide auf dieselbe Eingabe an. Es ist ein einfacher Kombinator. Schreiben wir ihn uns:

An dritter Stelle auf dem Stack liegt die eigentliche Eingabe. Die müssen wir zunächst an Ort und Stelle verdoppelt, weil wir sie ja zwei mal brauchen

    [[dup] swip] swip

Dann wenden wir die erste (untere) Operation an

    dip

tauschen die Kopie der Eingabe hoch

    [swap] swip

und führen auch die zweite Operation durch

    i

Zusammen

    define bin {
        [[dup] swip] swip dip [swap] swip i
    }

    5 [0 >=] [10 <=] bin and

wunderbar.

# Kombinatoren 2 - while

Schleifen haben wir bis jetzt, wie bei unserer Fakultäts-Funktion, nur durch Rekursion bewerkstelligt bekommen. Schöner wäre doch ein Kombinator im Stil von

    10 [0 >] [
        dup printn
        1 -
    ] while

Fange bei 10 an, und solange wie die Zahl positiv ist, einmal ausgeben und verringern. Was genau soll `while` tun? Ein Aufruf wäre `[condition] [body] while` mit Sätzen `condition` und `body`. Wir können jetzt rekursiv weitermachen

    [condition] [body [condition] [body] while] [] if

Wenn `condition` noch `true` ergibt, führe den Schleifenrumpf aus und danach dieselbe Schleife rekursiv, ansonsten tue nichts. Also, `[condition]` und `[body]` liegen auf dem Stack, was tut `while`? Eigentlich müssen wir an die oberste Quotation `[body]` lediglich `[[condition] [body] while]` ranschreiben. Fertig ist

    define while {
        [dup] swip swap quote // [[condition]] nach oben holen
        [dup] swip swap quote // [[body]] nach oben holen
        [while] concat concat concat // Alles verbinden zu [body [condition] [body] while]
        []
        if
    }

# Kombinatoren 3 - Listen

Über funktionale Sprachen wird manchmal gesagt, es sei umständlich, alles als Rekursion zu formulieren, wie in 

    let rec sum = function
        | 0 -> 0
        | x::xs -> x + sum xs
    
    sum list

und der Vorteil gegenüber der imperativen Variante 

    int sum = 0;
    foreach (var i in list) 
        sum += i;

wäre marginal (zu allem Überfluss ist die naive rekursive Variante oben nichteinmal endrekursiv und liefert oft bloß einen Stackoverflow). Dieses Problem tritt nur auf, wenn man imperativen Code nachahmen will. Eine durch und durch funktionale Variante will nämlich auf gar keine Rekursion hinaus, sie will einfach nur über eine Liste eine Operation (nämlich `+`) akkumulieren und mit 0 anfangen.

    fold (+) 0 [1; 2; 3; 4]

Fertig. Das kann ActiveJoy auch, halt in umgekehrter Reihenfolge

    [1 2 3 4] [+] 0 fold

Was soll das nun bedeuten? Dass wir über Listen reden müssen: Eine Liste ist einfach genau das

    [1 2 3 4]

Eine Quotation, in der halt Zahlen stehen. Wir könnten natürlich versuchen, sie auszuführen, dann würde sie `1 2 3 4` auf den Stack schreiben. Aber sie ist uns auch schon in dieser Form nützlich, einfach als Liste. Ein paar Operationen auf Quotations kennen wir ja schon

    [1 2] [3] concat == [1 2 3]

Dann gibt es

    ["Hallo" bla 5] length == 3

Und natürlich können wir Elemente extrahieren, sagen wir das erste:

    [5 2] head == 5

Bemerkenswert ist vielleicht die Ausgabe

    [print] head

Das erste Element hier ist das nackte Wort `"print"`, unausgeführt, als Symbol. Wir können es natürlich wieder in eine Quotation hineinpacken

    [print] head [] cons == [print]

und es in dieser Form mit `i` wieder ausführen. Ach ja, `cons` hängt ein Element vor eine Liste, `quote == [] cons`, also

    1 [2 3] cons = [1 2 3], 1 quote = [1]

Was tut jetzt also `fold`? Alles zusammenkombinieren:

    [1 2 3 4] [+] 0 fold == (((0 + 1) + 2) + 3) + 4 == 0 1 + 2 + 3 + 4 +

Wir können damit auch bequem neue Listen erzeugen: Sagen wir, wir möchten die Liste `[1 2 3]` umdrehen, dann brauchen wir 

    [3 2 1] == 3 2 1 [] cons cons cons

Das sieht noch nach keinem `fold` aus, aber fast. Die Reihenfolge der Argumente von `cons` ist verkehrt, tauschen wir sie also billig um 

    swons == swap cons

Und

    [3 2 1] == [] 1 swons 2 swons 3 swons
            == [1 2 3] [swons] [] fold

Cool, wir können mit `fold` also Listen durchlaufen und umdrehen

    define rev { [swons] [] fold }

Versuchen wir einmal, aus einem Intervall alle geraden Zahlen auszuwählen. Dazu benötigen wir erstmal das Intervall

    [] 2 [10 <] [
        dup // Den Zähler beibehalten
        [swons] swip // Den Zähler an die Liste ranschreiben
        1 + // Zähler erhöhen
    ] while


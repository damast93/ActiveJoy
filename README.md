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

Um ordentliche Programme zu schreiben, brauchen wir noch eine Möglichkeit, uns nicht ständig zu wiederholen, d.h. eigene Wörter zu definieren. Schreiben wir das mal so

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
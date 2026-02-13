# Sicherheitscheck für die `db_data.rds` einer Universität

`check_db` prüft mithilfe des Paketes `pointblank` verschiedene
Struktur-, Typ- und Plausibilitätsprüfungen für `db_data.rds`. Der Check
bildet den Abschluss des Cleaningprozesses einer Universität.

## Usage

``` r
check_db(test_data)
```

## Arguments

- test_data:

  Ein Data Frame mit den zu prüfenden Daten.

## Value

Ein einzelnes `ptblank_agent`-Objekt mit den Prüfergebnissen Zusätzlich
wird ein HTML-Report im Viewer angezeigt.

## Details

Folgende Prüfungen werden durchgeführt:

1.  **Vollständigkeits-Check:** Alle erwarteten Variablen (z. B.
    `hochschule`, `jahr`, `semester`, Future-Skills-Variablen etc.) sind
    im Datensatz enthalten.

2.  **Datentypen-Check Strings:** Alle inhaltlichen Text-Variablen
    (außer den Future-Skills-Variablen und der Hilfsspalte
    `kursbeschreibung_len`) müssen vom Typ `character` sein.

3.  **Datentypen-Check Numeric:** Die Future-Skills-Variablen
    `data_analytics_ki`, `softwareentwicklung`,
    `nutzerzentriertes_design`, `it_architektur`,
    `hardware_robotikentwicklung` und `quantencomputing` müssen
    numerisch sein.

4.  **Mindestlänge Kursbeschreibung:** Die Länge der Kursbeschreibung
    (`kursbeschreibung_len`) muss mindestens 20 Zeichen betragen.
    Kürzere Beschreibungen gelten als fehlerhaft und sollten NA gesetzt
    werden.

5.  **Hochschulnamen:** Die Werte in `hochschule` müssen in der
    geladenen Referenzliste zulässiger Hochschulnamen enthalten sein
    (`inst/extdata/hochschulen_namen_kuerzel.sql`).

6.  **Hochschulkürzel:** Die Werte in `hochschule_kurz` müssen in der
    entsprechenden Referenzliste zulässiger Kürzel enthalten sein
    (`inst/extdata/hochschulen_namen_kuerzel.sql`).

7.  **Pflichtfelder Jahr/Semester:** Die Felder `jahr` und `semester`
    dürfen keine fehlenden Werte (`NA`) enthalten.

8.  **Sprach-Codierung:** Die Werte in `sprache_recoded` müssen zu der
    im Wiki definierten, erlaubten Menge gehören, z. B. `"Deutsch"`,
    `"Englisch"`, `"Deutsch/Englisch"`, weitere Sprachen, `"Sonstiges"`
    oder `NA`.

9.  **Kursformat-Codierung:** Die Werte in `kursformat_recoded` müssen
    zu der im Wiki definierten, festen Menge gehören, z. B.
    `"Vorlesung"`, `"Seminar"`, `"Übung"`, `"Austausch"`, `"Erfahrung"`,
    `"Sprachkurs"`, `"Sonstiges"` oder `NA`.

10. **Semester-Format:** Die Werte in `semester` müssen dem Muster
    `"YYYYs"` oder `"YYYYw"` entsprechen (vierstellige Jahreszahl,
    gefolgt von `s` für Sommer- bzw. `w` für Wintersemester).

# Prüft Distinct-Werte-Änderungen für alle Variablen eines Datensatzes

Diese Hilfsfunktion ruft intern für jede Nicht-Gruppierungsvariable
[`check_distinct_level_change()`](https://github.com/Stifterverband/HEXCleanR/reference/check_distinct_level_change.md)
auf und fasst die Ergebnisse zu einem gemeinsamen `tibble` zusammen.
Standardmäßig werden nur die Einträge zurückgegeben, die als auffällig
markiert (`flagged == TRUE`) sind.

## Usage

``` r
check_distinct_level_change_df(
  data,
  group_col,
  threshold_low = 0.7,
  threshold_high = 1.5,
  min_distinct = 5
)
```

## Arguments

- data:

  Ein `data.frame` oder `tibble` mit den zu prüfenden Daten.

- group_col:

  Ungequoteter Spaltenname; Gruppierungsvariable (z. B. `semester`). Die
  Funktion verwendet
  [`rlang::ensym()`](https://rlang.r-lib.org/reference/defusing-advanced.html)
  zur Auswertung.

- threshold_low:

  Numerischer unterer Schwellenwert für die Prüfung (z. B. 0.70).

- threshold_high:

  Numerischer oberer Schwellenwert für die Prüfung (z. B. 1.50).

- min_distinct:

  Ganzzahliger Minimalwert für den Median der Anzahl unterschiedlicher
  Werte, unterhalb dessen eine Variable nicht geprüft wird (Standard:
  5).

## Value

Ein `tibble` mit den markierten Abweichungen. Die Ausgabe enthält
mindestens die Spalten:

- `status`: Textueller Status (`negativ abweichend`,
  `positiv abweichend`, `NORMAL`)

- `variable`: Name der geprüften Variable

- `semester`: Wert der Gruppierungsvariable (Originalname in der Ausgabe
  `semester`)

- `unique_found`: Gefundene Anzahl eindeutiger Werte in der Gruppe

- `unique_med`: Median der eindeutigen Werte über alle Gruppen

- `faktor`: Verhältnis `unique_found / unique_med` (gerundet)

Wenn keine Auffälligkeiten gefunden werden, gibt die Funktion ein leeres
`tibble` (invisibly) zurück und schreibt eine Erfolgsmeldung.

## Details

Für jede Spalte in `data`, die nicht der `group_col` entspricht, wird
die Anzahl unterschiedlicher Werte pro Gruppe berechnet. Als Referenz
dient der Median der Anzahl unterschiedlicher Werte über alle Gruppen.
Liegt die relative Abweichung vom Median außerhalb der Intervalle
`threshold_low` .. `threshold_high`, wird dieser Fall als auffällig
markiert.

## See also

[check_distinct_level_change](https://github.com/Stifterverband/HEXCleanR/reference/check_distinct_level_change.md)

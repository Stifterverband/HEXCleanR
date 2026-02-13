# Visualisiert NA-Konzentration nach Semester

Erzeugt einen Plot mit der NA-Konzentration pro Variable und sortiert
die Semester-Faktoren nach der darin enthaltenen vierstelligen
Jahreszahl. Falls keine vierstellige Jahreszahl in der angegebenen
Spalte gefunden wird, bricht die Funktion mit einer aussagekräftigen
Fehlermeldung ab.

## Usage

``` r
check_nas(data, semester)
```

## Arguments

- data:

  Ein data.frame oder tibble mit den zu analysierenden Daten.

- semester:

  Unquoted Spaltenname mit Semester-Informationen (z.B. `WS 2019/20`
  oder `2019`).

## Value

Ein `ggplot`-Objekt mit der Visualisierung der NA-Konzentration.

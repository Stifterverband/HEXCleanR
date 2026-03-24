# Gibt Zeilenzahlen pro `source_file` aus und gibt die Daten zurueck

Fasst einen Datensatz nach `source_file` zusammen, zaehlt die Anzahl der
Zeilen pro Datei und gibt die Uebersicht direkt in der Konsole aus. Die
Funktion ist fuer Pipelines gedacht und gibt den originalen Datensatz
unveraendert zurueck.

## Usage

``` r
check_semester_n(data, print_n = Inf)
```

## Arguments

- data:

  Ein `data.frame` oder `tibble` mit einer Spalte `source_file`.

- print_n:

  Anzahl der beim [`print()`](https://rdrr.io/r/base/print.html)
  anzuzeigenden Zeilen. Standard ist `Inf`, damit alle Gruppen
  ausgegeben werden.

## Value

Der unveraenderte Eingabedatensatz.

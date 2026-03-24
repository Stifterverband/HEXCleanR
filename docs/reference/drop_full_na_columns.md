# Gibt NA-Anteile pro Variable aus und entfernt 100%-NA-Spalten

Berechnet fuer jede Variable den Anteil fehlender Werte, gibt eine
ausfuehrliche Uebersicht in der Konsole aus und entfernt anschliessend
alle Variablen, die ausschliesslich aus `NA` bestehen. Die Funktion ist
fuer Pipelines gedacht.

## Usage

``` r
drop_full_na_columns(data, print_n = Inf)
```

## Arguments

- data:

  Ein `data.frame` oder `tibble`.

- print_n:

  Anzahl der beim [`print()`](https://rdrr.io/r/base/print.html)
  anzuzeigenden Zeilen. Standard ist `Inf`, damit alle Variablen
  ausgegeben werden.

## Value

Ein Datensatz ohne Variablen mit 100% `NA`.

## Examples

``` r
if (FALSE) { # \dontrun{
final_df |>
  drop_full_na_columns()
} # }
```

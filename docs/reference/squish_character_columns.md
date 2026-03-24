# Fuehrt `str_squish()` auf allen Character-Variablen aus

Bereinigt alle Character-Spalten eines Datensatzes, indem fuehrende und
nachgestellte Leerzeichen entfernt und Mehrfach-Leerzeichen innerhalb
von Strings auf ein einzelnes Leerzeichen reduziert werden. Die Funktion
ist fuer Pipelines gedacht und gibt den bereinigten Datensatz zurueck.

## Usage

``` r
squish_character_columns(data)
```

## Arguments

- data:

  Ein `data.frame` oder `tibble`.

## Value

Ein Datensatz, in dem alle Character-Variablen mit
[`stringr::str_squish()`](https://stringr.tidyverse.org/reference/str_trim.html)
bereinigt wurden.

## Examples

``` r
if (FALSE) { # \dontrun{
final_df |>
  squish_character_columns()
} # }
```

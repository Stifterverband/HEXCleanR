# Ersetzt leere Strings durch `NA`

Bereinigt alle Zeichenketten-Spalten eines Data Frames, indem führende
und nachgestellte Leerzeichen entfernt und anschließend leere Strings
(`""`) als fehlende Werte (`NA`) gesetzt werden.

## Usage

``` r
empty_str_to_na(df)
```

## Arguments

- df:

  Ein `data.frame` oder `tibble`.

## Value

Ein Objekt mit derselben Struktur wie `df`, in dem leere oder nur aus
Leerzeichen bestehende Zeichenketten in Character-Spalten durch `NA`
ersetzt wurden.

empty_str_to_na(test_df)

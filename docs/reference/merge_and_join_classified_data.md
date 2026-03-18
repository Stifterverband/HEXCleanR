# Merge old + new classified data and join fixed classification vars to base data

Lädt bestehende Klassifizierungsdaten, kombiniert sie mit neuen
Klassifizierungen (ohne Duplikate), reduziert auf die festen
Klassifizierungsspalten und merged das Ergebnis per left_join an die
Rohdaten.

## Usage

``` r
merge_and_join_classified_data(
  raw_data,
  db_data_path,
  new_classified_data,
  key_vars = c("titel", "nummer")
)
```

## Arguments

- raw_data:

  Ein data.frame mit allen Rohdaten.

- db_data_path:

  Pfad zur bestehenden RDS-Datei mit bereits klassifizierten Daten
  (optional).

- new_classified_data:

  Ein data.frame mit neu klassifizierten Daten.

- key_vars:

  Ein Vektor mit Spaltennamen für den Join (Default:
  c("titel","nummer")).

## Value

Ein data.frame mit allen Rohdaten inkl. den Klassifizierungsspalten.

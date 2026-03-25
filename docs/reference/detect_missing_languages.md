# Ergänzt fehlende Sprachinformationen in Kursdaten

Die Funktion behandelt zwei Fälle für Zeilen mit fehlendem
`sprache_recoded`: 0. Falls `db_data_path` existiert, werden vorhandene
gültige Werte in `sprache_recoded` zunächst anhand von `titel` aus der
DB übernommen. Bereits vorhandene Werte in `raw_data` werden dabei nicht
überschrieben.

1.  Wenn nur ein `titel` vorliegt und `kursbeschreibung` fehlt, wird
    `detect_lang_with_openai()` auf diese Zeilen angewendet.

2.  Wenn `kursbeschreibung` vorhanden ist, wird die Sprache der
    Kursbeschreibung mit
    [`cld3::detect_language()`](https://docs.ropensci.org/cld3/reference/cld3.html)
    bestimmt und in `kursbeschreibung_sprach` geschrieben.

## Usage

``` r
detect_missing_languages(
  raw_data,
  db_data_path = NULL,
  export_path = "db_safety_export.rds",
  batch_size = 100,
  titel_col = "titel",
  kursbeschreibung_col = "kursbeschreibung",
  sprache_col = "sprache_recoded",
  kursbeschreibung_sprach_col = "kursbeschreibung_sprach"
)
```

## Arguments

- raw_data:

  Ein data.frame oder tibble mit den Kursdaten.

- db_data_path:

  Optionaler Pfad zur RDS-Datei mit bestehenden Sprachklassifikationen
  für `detect_lang_with_openai()`. Wenn `NULL` oder nicht vorhanden,
  wird ohne DB-Lookup gearbeitet.

- export_path:

  Pfad zum Sicherheits-Export für `detect_lang_with_openai()`. Standard
  ist `"db_safety_export.rds"`.

- batch_size:

  Batch-Größe für `detect_lang_with_openai()`. Standard ist `100`.

- titel_col:

  Name der Titelspalte. Standard ist `"titel"`.

- kursbeschreibung_col:

  Name der Spalte mit Kursbeschreibungen. Standard ist
  `"kursbeschreibung"`.

- sprache_col:

  Name der Zielspalte für die recodierte Sprache. Standard ist
  `"sprache_recoded"`.

- kursbeschreibung_sprach_col:

  Name der Spalte für die per `cld3` erkannte Sprache der
  Kursbeschreibung. Standard ist `"kursbeschreibung_sprach"`.

## Value

`raw_data` mit ergänzten Spalten `sprache_recoded` und
`kursbeschreibung_sprach`.

## Details

Bestehende Werte in `sprache_recoded` und `kursbeschreibung_sprach`
werden nicht überschrieben. Die Funktion gibt außerdem aus, wie viele
Zeilen über den normalen Weg mit
[`cld3::detect_language()`](https://docs.ropensci.org/cld3/reference/cld3.html)
und wie viele über OpenAI bearbeitet wurden. Wenn OpenAI-Fälle anstehen,
aber kein `OPENAI_API_KEY` gesetzt ist, wird eine Warnung ausgegeben und
der OpenAI-Zweig übersprungen.

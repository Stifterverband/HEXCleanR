# Detektiert die Sprache in einer Spalte eines Dataframes mittels OpenAI GPT-API

Diese Funktion nutzt die OpenAI GPT-API, um die Sprache von Texten (z.
B. Titeln) zu erkennen. Sie arbeitet hocheffizient, indem sie bereits
vorhandene Klassifikationen aus einer Datenbank sowie einem
Sicherheits-Export berücksichtigt und nur neue, einzigartige Texte an
die API sendet.

## Usage

``` r
detect_lang_with_openai(
  df,
  spalte,
  db_data_path,
  export_path = "db_safety_export.rds",
  batch_size = 100
)
```

## Arguments

- df:

  Ein Dataframe, der die zu klassifizierende Textspalte enthält.

- spalte:

  Name der Spalte (String), deren Inhalt analysiert werden soll (z. B.
  "titel").

- db_data_path:

  Pfad zur permanenten RDS-Datenbank mit historischen Klassifikationen.

- export_path:

  Pfad zum Sicherheits-Export (RDS), der den aktuellen Fortschritt
  speichert. Standard ist "db_safety_export.rds".

- batch_size:

  Anzahl der Titel pro API-Abfrage. Standard ist 50.

## Value

Der ursprüngliche Dataframe, ergänzt um die vervollständigte Spalte
`sprache_recoded`.

## Details

Ablauf der Funktion im Detail:

1.  Vorhandene Datenquellen: Falls vorhanden, werden
    Sprach-Klassifikationen aus `db_data_path` und `export_path`
    geladen. Bestehende Werte im Dataframe werden NICHT überschrieben,
    sondern nur fehlende Werte (NAs) ergänzt (Lookup-Logik).

2.  Einzigartigkeit: Es werden nur die eindeutigen (unique) Texte
    extrahiert, die noch keinen Wert in `sprache_recoded` besitzen, um
    API-Kosten zu minimieren.

3.  Batch-Verarbeitung: Die Texte werden in Batches an das Modell
    (gpt-4o-mini) gesendet.

4.  Validierung & Sicherheit: Die API-Antworten werden strikt gegen eine
    Liste erlaubter Sprachen geprüft. Halluzinationen oder Fachbegriffe
    werden als "Sonstiges" gelabelt.

5.  Persistenz: Nach jedem Batch wird der Fortschritt sofort in
    `export_path` gespeichert.

Die Funktion nutzt
[`ellmer::parallel_chat`](https://ellmer.tidyverse.org/reference/parallel_chat.html)
für hohe Geschwindigkeit und setzt die Modell-Temperatur auf 0, um die
Reproduzierbarkeit zu maximieren und "Kreativität" der KI zu
unterbinden.

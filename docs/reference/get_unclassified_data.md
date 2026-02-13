# Filtert unklassifizierte Kursdaten aus der `db_data_universitaet_<uni_name>.rds`

Diese Funktion vergleicht aktuelle Scraping-Daten mit
`db_data_universitaet_<uni_name>.rds` und gibt alle Zeilen aus den
aktuellen Scraping-Daten zurueck, die noch keiner der definierten
Kategorien zugeordnet wurden. Die Identifikation erfolgt ueber 1 bis 3
Schluesselvariablen.

## Usage

``` r
get_unclassified_data(raw_data, db_data_path, key_vars = c("titel", "nummer"))
```

## Arguments

- raw_data:

  Ein `data.frame` mit den Rohdaten, die klassifiziert werden sollen.

- db_data_path:

  Pfad zu einer RDS-Datei mit den bereits klassifizierten Daten
  (optional).

- key_vars:

  Ein Vektor mit 1 bis 3 Spaltennamen, die als Schluessel fuer den
  Abgleich dienen (Standard: `c("titel", "nummer")`).

## Value

Ein `data.frame` mit den Zeilen aus `raw_data`, die noch nicht
klassifiziert wurden. Enthaelt die Schluesselvariablen,
`kursbeschreibung` und `lernziele`.

## Details

Die Funktion prueft, ob fuer jede Zeile in `raw_data` keine
Klassifizierung in den Spalten `data_analytics_ki`,
`softwareentwicklung`, `nutzerzentriertes_design`, `it_architektur`,
`hardware_robotikentwicklung` und `quantencomputing` vorliegt. Wenn
`db_data_path` `NULL` ist oder die Datei nicht existiert, werden alle
Zeilen aus `raw_data` als unklassifiziert zurueckgegeben.

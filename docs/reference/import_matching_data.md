# Lädt gematchte Daten aus dem lokalen OneDrive und merged sie mit gescrapten Daten

Lädt das aktuellste Matching-`.rds`-File aus dem `Matching`-Ordner der
angegebenen Universität (lokal in OneDrive) und merged die relevanten
Matching-Felder mit `scraped_daten`. und merged die relevanten
Matching-Felder mit `scraped_daten`. Wenn kein passendes Matching
vorhanden ist oder die Matching-Daten nicht LUF- optimiert sind, wird
`scraped_daten` unverändert zurückgegeben.

## Usage

``` r
import_matching_data(scraped_daten, uni_ordner_name)
```

## Arguments

- scraped_daten:

  Data frame mit gescrapten Daten. Erwartet mindestens die Spalten
  `jahr`, `semester` und `organisation`.

- uni_ordner_name:

  Character. Name des Universitätsordners innerhalb der
  `single_universities`-Struktur. Hinweis: Die Funktion lädt
  Matching-Dateien aus dem lokalen OneDrive.

## Value

Data frame. `scraped_daten` mit angehängten Matching-Feldern
(`matchingart`, `lehr_und_forschungsbereich`, `studienbereich`,
`faechergruppe`, `luf_code`, `stub_code`, `fg_code`). Bei fehlendem oder
ungeeignetem Matching werden die unveränderten `scraped_daten`
zurückgegeben.

## Details

- Es wird das jüngste `.rds`-File im `Matching`-Ordner verwendet.

- Die Matching-Daten müssen die Spalte `gerit_luf` enthalten.

- Organisationseinträge mit mehreren Namen werden anhand von " ; "
  getrennt und entsprechend behandelt.

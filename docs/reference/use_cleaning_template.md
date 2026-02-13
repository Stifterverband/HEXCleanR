# Erzeugt ein Cleaning-Template im aktuellen Projekt

Diese Funktion kopiert die im Paket mitgelieferte Datei
`cleaning_template.R` in das Verzeichnis `R` des aktuellen Projekts und
benennt sie in `data_preparation_<university_name>.R` um. Existiert
unter diesem Namen bereits eine Datei, wird eine Warnung ausgegeben und
die vorhandene Datei nicht überschrieben.

## Usage

``` r
use_cleaning_template(university_name)
```

## Arguments

- university_name:

  Zeichenkette mit dem Namen der Universität, für die ein
  Cleaning-Template erstellt werden soll.

## Value

Unsichtbar der Pfad zur erstellten (oder bereits vorhandenen) Datei.

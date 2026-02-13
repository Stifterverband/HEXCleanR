# Konvertiert eine JSON-Datei in ein RDS-Format

Diese Funktion liest eine JSON-Datei ein, wandelt sie in ein Tibble um
und speichert das Ergebnis als RDS-Datei.

## Usage

``` r
json_to_rds(input_path, output_path)
```

## Arguments

- input_path:

  Pfad zur Eingabe-JSON-Datei.

- output_path:

  Pfad zur Ausgabedatei im RDS-Format.

## Value

Das eingelesene Tibble.

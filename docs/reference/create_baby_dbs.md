# Speichert semesterweise Teilmengen von `db_data` als RDS-Dateien

Diese Funktion iteriert ueber alle eindeutigen Werte in
`db_data$semester` und speichert pro Semester eine Teilmenge als
`db_data_<semester>.rds` in den passenden Unterordner unterhalb von
`path`. Gespeichert wird nur, wenn der jeweilige Ordner bereits
existiert.

## Usage

``` r
create_baby_dbs(db_data, path)
```

## Arguments

- db_data:

  Data Frame mit mindestens einer Spalte `semester`.

- path:

  Basisverzeichnis, unter dem pro Semester ein Unterordner erwartet
  wird.

## Value

Unsichtbar eine Liste mit zwei Zeichenvektoren:

- saved:

  Dateipfade erfolgreich gespeicherter RDS-Dateien.

- missing_dirs:

  Ordnerpfade, die nicht existierten.

## Examples

``` r
db_data <- tibble::tibble(
  semester = c("2025w", "2025w", "2026s"),
  titel = c("Kurs A", "Kurs B", "Kurs C")
)

base_path <- tempdir()
dir.create(file.path(base_path, "2025w"))
dir.create(file.path(base_path, "2026s"))

create_baby_dbs(db_data, base_path)
#> Gespeichert: C:\Users\mhu\AppData\Local\Temp\RtmpAR7LId/2025w/db_data_2025w.rds
#> Gespeichert: C:\Users\mhu\AppData\Local\Temp\RtmpAR7LId/2026s/db_data_2026s.rds
```

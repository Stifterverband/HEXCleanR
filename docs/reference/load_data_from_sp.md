# Laedt `course_data`-Dateien rekursiv aus einem Hochschulordner

Die Funktion ermittelt automatisch den aktuellen Windows-Benutzernamen
und konstruiert daraus den Basispfad
`C:/Users/<username>/OneDrive - Stifterverband/Dateiablage - single_universities/`.
Innerhalb des uebergebenen Hochschulordners sucht sie rekursiv nach
Dateien, deren Name mit `course_data` beginnt und je nach `file_type`
auf `.json`, `.rds` oder `.csv` endet. Ordner mit dem Namen `archiv`
werden dabei ausgeschlossen.

## Usage

``` r
load_data_from_sp(
  university_folder,
  file_type = "all",
  clean_names = TRUE,
  add_source_file = TRUE,
  coerce_to_character = TRUE
)
```

## Arguments

- university_folder:

  Zeichenkette mit dem Namen des Hochschulordners innerhalb von
  `Dateiablage - single_universities`, zum Beispiel
  `"Otto_Friedrich_Universitaet_Bamberg"`.

- file_type:

  Zeichenkette zur Auswahl des Dateityps. Erlaubt sind `"all"`
  (Standard), `"json"`, `"rds"` oder `"csv"`.

- clean_names:

  Logisch. Wenn `TRUE` (Standard), werden die Spaltennamen jeder
  eingelesenen Datei mit
  [`janitor::clean_names()`](https://sfirke.github.io/janitor/reference/clean_names.html)
  bereinigt.

- add_source_file:

  Logisch. Wenn `TRUE` (Standard), wird eine Spalte `source_file` mit
  dem Dateinamen ergaenzt.

- coerce_to_character:

  Logisch. Wenn `TRUE` (Standard), werden alle Spalten pro eingelesener
  Datei vor dem Zusammenfuehren in `character` umgewandelt, um
  Typkonflikte beim Binden zu vermeiden.

## Value

Ein `tibble` mit den zusammengefuehrten Inhalten aller gefundenen
Dateien. Wenn keine passenden Dateien gefunden werden oder der
Hochschulordner nicht existiert, gibt die Funktion `NULL` zurueck und
erzeugt eine Meldung.

## Details

Gefundene Dateien werden eingelesen, optional mit
[`janitor::clean_names()`](https://sfirke.github.io/janitor/reference/clean_names.html)
bereinigt, optional um eine Spalte `source_file` ergaenzt und bei Bedarf
vor dem Zusammenfuehren vollstaendig in `character` umgewandelt, um
Typkonflikte zwischen Dateien zu vermeiden.

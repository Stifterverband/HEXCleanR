# Klassifiziert Kursdaten mit SetFit-Modell und pflegt neue Labels ein

Diese Funktion identifiziert Future-Skills-Schlagwörter in Kursdaten
mithilfe eines vortrainierten SetFit-Modells (siehe
http://srv-data01:30080/hex/future_skill_classification), das über das
reticulate-Paket aus Python heraus aufgerufen wird. Dabei werden
zunächst noch nicht klassifizierte Kurse ermittelt, diese im Modell
bewertet und die resultierenden Future-Skills-Labels anschließend mit
bestehenden Klassifizierungsinformationen aus einem optionalen
RDS-Datensatz zusammengeführt.

## Usage

``` r
classify_fs(
  raw_data,
  db_data_path = NULL,
  model_path = "Chernoffface/fs-setfit-multilable-model",
  key_vars = c("titel", "nummer")
)
```

## Arguments

- raw_data:

  Data Frame mit Rohkursdaten; sollte mindestens die Spalten für die
  Join-Schlüssel (`key_vars`) sowie, idealerweise, `kursbeschreibung`
  und `lernziele` enthalten.

- db_data_path:

  (Optional) Pfad zu einer bestehenden RDS-Datei mit bereits
  klassifizierten Kursen. Wenn `NULL` oder nicht vorhanden, werden alle
  Zeilen in `raw_data` neu klassifiziert.

- model_path:

  HuggingFace-Modellpfad des SetFit-Modells, das zur Klassifizierung
  verwendet werden soll.

- key_vars:

  Zeichenvektor mit den Spaltennamen, die als Join-Keys verwendet werden
  (Standard: `c("titel", "nummer")`). Nur vorhandene und nicht
  vollständig fehlende Variablen werden verwendet.

## Value

Data Frame mit allen Zeilen von `raw_data` und den ergänzten bzw.
aktualisierten Future-Skills-Klassifikationsspalten.

## Details

Die Funktion setzt ein funktionierendes Python-/Conda-Environment mit
dem entsprechenden SetFit-Modell voraus und erwartet in den Rohdaten
mindestens eine sinnvolle Schlüsselvariable (z.B. "titel" oder "nummer")
sowie Spalten mit Kursbeschreibung und Lernzielen.

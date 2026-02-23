# Package index

## All functions

- [`check_db()`](https://github.com/Stifterverband/HEXCleanR/reference/check_db.md)
  :

  Sicherheitscheck für die `db_data.rds` einer Universität

- [`check_distinct_level_change()`](https://github.com/Stifterverband/HEXCleanR/reference/check_distinct_level_change.md)
  : Prüft Distinct-Werte-Änderungen für eine spezifische Variable

- [`check_distinct_level_change_df()`](https://github.com/Stifterverband/HEXCleanR/reference/check_distinct_level_change_df.md)
  : Prüft Distinct-Werte-Änderungen für alle Variablen eines Datensatzes

- [`check_nas()`](https://github.com/Stifterverband/HEXCleanR/reference/check_nas.md)
  : Visualisiert NA-Konzentration nach Semester

- [`check_organisation()`](https://github.com/Stifterverband/HEXCleanR/reference/check_organisation.md)
  : Prüft Organisations-Variable auf definierte Qualitätsregeln

- [`classify_fs()`](https://github.com/Stifterverband/HEXCleanR/reference/classify_fs.md)
  : Klassifiziert Kursdaten mit SetFit-Modell und pflegt neue Labels ein

- [`detect_lang_with_openai()`](https://github.com/Stifterverband/HEXCleanR/reference/detect_lang_with_openai.md)
  : Detektiert die Sprache in einer Spalte eines Dataframes mittels
  OpenAI GPT-API

- [`import_matching_data()`](https://github.com/Stifterverband/HEXCleanR/reference/import_matching_data.md)
  :

  Lädt das aktuellste Matching-`.rds`-File aus dem `Matching`-Ordner der
  angegebenen Universität (lokal in OneDrive) und merged die relevanten
  Matching-Felder mit `scraped_daten`. und merged die relevanten
  Matching-Felder mit `scraped_daten`. Wenn kein passendes Matching
  vorhanden ist oder die Matching-Daten nicht LUF- optimiert sind, wird
  `scraped_daten` unverändert zurückgegeben.

- [`json_to_rds()`](https://github.com/Stifterverband/HEXCleanR/reference/json_to_rds.md)
  : Konvertiert eine JSON-Datei in ein RDS-Format

- [`remove_semantic_na_values()`](https://github.com/Stifterverband/HEXCleanR/reference/remove_semantic_na_values.md)
  : Setzt Werte einer String-Variable NA, wenn diese weniger als 20
  Zeichen enthalten

- [`use_cleaning_template()`](https://github.com/Stifterverband/HEXCleanR/reference/use_cleaning_template.md)
  : Erzeugt ein Cleaning-Template im aktuellen Projekt

# Changelog

## HEXCleanR 0.5.17

- [`detect_missing_languages()`](https://github.com/Stifterverband/HEXCleanR/reference/detect_missing_languages.md)
  ergänzt fehlende Sprachinformationen in Kursdaten: vorhandene Werte
  der Variable `sprache_recoded` werden zunächst ggf. aus der DB
  übernommen, offene Fälle mit `kursbeschreibung` über `cld3`
  verarbeitet und Kurse ohne `kursbeschreibung` optional über OpenAI
  klassifiziert.

## HEXCleanR 0.5.16

- [`check_db()`](https://github.com/Stifterverband/HEXCleanR/reference/check_db.md)
  behandelt fehlende Werte in `kursbeschreibung` bei der
  Mindestlängenprüfung nun korrekt und markiert `NA` nicht mehr
  fälschlich als Beschreibungen mit weniger als 20 Zeichen.

## HEXCleanR 0.5.15

- Neue Funktion
  [`load_data_from_sp()`](https://github.com/Stifterverband/HEXCleanR/reference/load_data_from_sp.md),
  um `course_data`-Dateien rekursiv aus einem Hochschulordner in der
  Stifterverband-OneDrive-Struktur zu laden.
- Neue pipeline-taugliche Helfer
  [`drop_full_na_columns()`](https://github.com/Stifterverband/HEXCleanR/reference/drop_full_na_columns.md)
  und
  [`squish_character_columns()`](https://github.com/Stifterverband/HEXCleanR/reference/squish_character_columns.md),
  um Spalten mit 100% `NA` zu entfernen und Leerzeichen in allen
  Character-Spalten zu bereinigen, z. B.
  `load_data_from_sp(university_folder = UNIVERSITY_FOLDER) |> drop_full_na_columns() |> squish_character_columns()`.
- Neue Funktion
  [`check_semester_n()`](https://github.com/Stifterverband/HEXCleanR/reference/check_semester_n.md),
  die Zeilenzahlen pro `source_file` in der Konsole ausgibt und den
  ursprünglichen Datensatz unverändert zurückgibt, z. B. in Pipelines
  wie `raw_data |> check_semester_n()`.
- Neue Funktion
  [`plot_na_balloons()`](https://github.com/Stifterverband/HEXCleanR/reference/plot_na_balloons.md),
  um fehlende Werte nach Gruppierungsvariable als Balloon-Plot zu
  visualisieren, inklusive gedruckter NA-Tabelle, Farbverlauf in der
  Legende, sichtbaren Ballons auch bei `0 NA`, optionalen Labels und um
  45 Grad gedrehter X-Achsenbeschriftung, z. B.
  `raw_data |> plot_na_balloons(grp_var = semester_y)`.

# Changelog

## HEXCleanR 0.5.19

- [`detect_missing_languages()`](https://github.com/Stifterverband/HEXCleanR/reference/detect_missing_languages.md)
  verarbeitet nun auch Zeilen, bei denen `cld3` trotz vorhandener
  `kursbeschreibung` keine Sprache erkennen konnte (z. B. bei
  formatiertem oder sehr kurzem Text). Diese Fälle werden jetzt als
  Fallback über den `titel` an OpenAI weitergegeben, statt unbearbeitet
  liegenzubleiben.
- Bugfix: Innerhalb von
  [`detect_missing_languages()`](https://github.com/Stifterverband/HEXCleanR/reference/detect_missing_languages.md)
  wurde `sprache_recoded` nach der `cld3`-Erkennung nicht befüllt, weil
  beide Spalten in einem einzigen
  [`mutate()`](https://dplyr.tidyverse.org/reference/mutate.html)-Aufruf
  berechnet wurden und dplyr dabei noch den alten `NA`-Wert von
  `kursbeschreibung_sprach` verwendete. Die zwei Berechnungen werden nun
  in getrennten
  [`mutate()`](https://dplyr.tidyverse.org/reference/mutate.html)-Aufrufen
  ausgeführt.

## HEXCleanR 0.5.18

- Neue Funktion
  [`create_codebook_and_db_data()`](https://github.com/Stifterverband/HEXCleanR/reference/create_codebook_and_db_data.md),
  um aus `raw_data` und `raw_data_fs` ein `codebook` sowie einen
  `db_data`-Datensatz im erwarteten HEX-Format zu erzeugen. Die Funktion
  prueft nun strikt, ob alle benoetigten Spalten vorhanden sind, und
  setzt nur die fachlichen Metadatenfelder
  (`lehr_und_forschungsbereich`, `studienbereich`, `faechergruppe`,
  `luf_code`, `stub_code`, `fg_code`, `matchingart`) initial auf `NA`.
- Neue Funktion
  [`create_baby_dbs()`](https://github.com/Stifterverband/HEXCleanR/reference/create_baby_dbs.md),
  um `db_data` semesterweise in vorhandene Semesterordner als
  `db_data_<semester>.rds` zu speichern und fehlende Ordner sauber zu
  melden.

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

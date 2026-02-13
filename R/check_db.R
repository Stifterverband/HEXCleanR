#' Sicherheitscheck für die `db_data.rds` einer Universität
#'
#' `check_db` prüft mithilfe des Paketes `pointblank` verschiedene Struktur-, Typ-
#' und Plausibilitätsprüfungen für `db_data.rds`. Der Check bildet den Abschluss des Cleaningprozesses einer Universität.
#'
#' @param test_data Ein Data Frame mit den zu prüfenden Daten.
#'
#' @details
#' 
#' Folgende Prüfungen werden durchgeführt:
#' 1. **Vollständigkeits-Check:** Alle erwarteten Variablen (z. B. `hochschule`,
#'    `jahr`, `semester`, Future-Skills-Variablen etc.) sind im Datensatz enthalten.
#' 2. **Datentypen-Check Strings:** Alle inhaltlichen Text-Variablen (außer den
#'    Future-Skills-Variablen und der Hilfsspalte `kursbeschreibung_len`) müssen
#'    vom Typ `character` sein.
#' 3. **Datentypen-Check Numeric:** Die Future-Skills-Variablen `data_analytics_ki`,
#'    `softwareentwicklung`, `nutzerzentriertes_design`, `it_architektur`,
#'    `hardware_robotikentwicklung` und `quantencomputing` müssen numerisch sein.
#' 4. **Mindestlänge Kursbeschreibung:** Die Länge der
#'    Kursbeschreibung (`kursbeschreibung_len`) muss mindestens 20 Zeichen betragen.
#'    Kürzere Beschreibungen gelten als fehlerhaft und sollten NA gesetzt werden.
#' 5. **Hochschulnamen:** Die Werte in `hochschule` müssen in der geladenen
#'    Referenzliste zulässiger Hochschulnamen enthalten sein (`inst/extdata/hochschulen_namen_kuerzel.sql`).
#' 6. **Hochschulkürzel:** Die Werte in `hochschule_kurz` müssen in der entsprechenden
#'    Referenzliste zulässiger Kürzel enthalten sein (`inst/extdata/hochschulen_namen_kuerzel.sql`).
#' 7. **Pflichtfelder Jahr/Semester:** Die Felder `jahr` und `semester` dürfen
#'    keine fehlenden Werte (`NA`) enthalten.
#' 8. **Sprach-Codierung:** Die Werte in `sprache_recoded` müssen zu der im Wiki definierten, erlaubten
#'    Menge gehören, z. B. `"Deutsch"`, `"Englisch"`, `"Deutsch/Englisch"`,
#'    weitere Sprachen, `"Sonstiges"` oder `NA`.
#' 9. **Kursformat-Codierung:** Die Werte in `kursformat_recoded` müssen zu der im Wiki definierten,
#'    festen Menge gehören, z. B. `"Vorlesung"`, `"Seminar"`, `"Übung"`, `"Austausch"`,
#'    `"Erfahrung"`, `"Sprachkurs"`, `"Sonstiges"` oder `NA`.
#' 10. **Semester-Format:** Die Werte in `semester` müssen dem Muster `"YYYYs"` oder
#'     `"YYYYw"` entsprechen (vierstellige Jahreszahl, gefolgt von `s` für Sommer-
#'     bzw. `w` für Wintersemester).
#'
#' @return Ein einzelnes `ptblank_agent`-Objekt mit den Prüfergebnissen
#' Zusätzlich wird ein HTML-Report im Viewer angezeigt.
#'
#'
#' @import pointblank
#' @importFrom stringr str_match str_starts str_remove_all str_split
#' @importFrom dplyr all_of filter mutate
#' @importFrom purrr map_chr
#' @importFrom tibble tibble
#' @export
check_db <- function(test_data) {
  requireNamespace("stringr")
  requireNamespace("pointblank")

  # =========================
  # 1. Referenzdaten laden
  # =========================
  # SQL-Datei mit Hochschulnamen und -kürzeln aus dem Paketverzeichnis laden
  sql_file <- system.file("extdata", "hochschulen_namen_kuerzel.sql",
                          package = "HEXCleanR")
  sql_text <- readLines(sql_file, warn = FALSE)
  if (length(sql_text) == 0) {
    stop("Die SQL-Datei 'hochschulen_namen_kuerzel.sql' ist leer. Prüfen Sie die Datei im Verzeichnis 'extdata'.")
  }

  # Daten aus SQL extrahieren und aufbereiten
  hochschulen <- tibble(line = sql_text) %>%
    filter(stringr::str_starts(line, "\\(")) %>%             # Nur Zeilen mit Daten behalten
    mutate(splitted = str_split(line, ",\\s*")) %>% # An Kommas trennen
    mutate(
      hochschule_lang = purrr::map_chr(splitted, 2),
      hochschule_kurz = purrr::map_chr(splitted, 3)
    ) %>%
    mutate(
      hochschule_lang = stringr::str_remove_all(hochschule_lang, "^'|'$"),
      hochschule_kurz = stringr::str_remove_all(hochschule_kurz, "^'|'$")
    )

  hochschule_lang <- hochschulen$hochschule_lang
  hochschule_kurz <- hochschulen$hochschule_kurz

  # =========================
  # 2. Erwartete Spalten definieren
  # =========================
  expected_vars <- c(
    "anmerkungen", "dozierende", "ects", "fakultaet", "hochschule",
    "hochschule_kurz", "jahr", "kursbeschreibung", "kursformat_original",
    "kursformat_recoded", "lehrtyp", "lernmethode", "lernziele", "literatur",
    "module", "nummer", "organisation_orig", "organisation", "pfad",
    "pruefung", "scrape_datum", "semester", "sprache_original", "sprache_recoded",
    "studiengaenge", "sws", "teilnehmerzahl", "titel", "url",
    "voraussetzungen", "zusatzinformationen", "institut", "data_analytics_ki",
    "softwareentwicklung", "nutzerzentriertes_design", "it_architektur",
    "hardware_robotikentwicklung", "quantencomputing", "lehr_und_forschungsbereich",
    "studienbereich", "faechergruppe", "luf_code", "stub_code", "fg_code",
    "matchingart"
  )

  # =========================
  # Spalten, die numerisch sein müssen (Future Skills)
  # =========================
  numeric_cols <- c(
    "data_analytics_ki",
    "softwareentwicklung",
    "nutzerzentriertes_design",
    "it_architektur",
    "hardware_robotikentwicklung",
    "quantencomputing"
  )

  # =========================
  # 3. Zusätzliche Hilfsspalten definieren
  # =========================
  helper_cols <- "kursbeschreibung_len"
  character_cols <- setdiff(expected_vars, c(numeric_cols, helper_cols))

  # =========================
  # 4. pointblank-Agent mit allen Checks aufbauen
  # =========================
    agent <- pointblank::create_agent(
    tbl = ~ test_data %>% dplyr::mutate(kursbeschreibung_len = nchar(kursbeschreibung)),
    tbl_name = "DB-Check",
    label = "DB-Check Report",
    actions = pointblank::action_levels(
      warn_at = 1,
      stop_at = 1
    )) |>

    # ---- 4.1 Spalten-Check ----
    pointblank::col_exists(
      columns = dplyr::all_of(expected_vars),
      actions = pointblank::action_levels(stop_at = 1),
      step_id = "col_exists_check",
      label = "Prüfe, ob alle erwarteten Variablen vorhanden sind"
    ) |>

    # ---- 4.9 Datentypen-Check: alle außer Future Skills müssen character sein ----
    pointblank::col_is_character(
      columns = all_of(character_cols),
      actions = pointblank::action_levels(stop_at = 1),
      step_id = "all_columns_character_check",
      label = "Prüfe, ob alle Variablen vom Typ character sind"
    ) |>

    # ---- 4.10 Datentypen-Check: Future Skills müssen numerisch sein ----
    pointblank::col_is_numeric(
      columns = all_of(numeric_cols),
      actions = pointblank::action_levels(stop_at = 1),
      step_id = "specific_columns_numeric_check",
      label = "Prüfe, ob Future Skills numeric sind"
    ) |>

    # ---- 4.2 Mindestlänge Kursbeschreibung ----
    pointblank::col_vals_between(
      columns = vars(kursbeschreibung_len),
      left = 20,
      right = Inf,
      actions = pointblank::action_levels(stop_at = 1),
      step_id = "kursbeschreibung_min_20_zeichen",
      label = "Prüfe, ob 'kursbeschreibung' mindestens 20 Zeichen lang ist",
      na_pass = TRUE
    ) |>

    # ---- 4.3 Hochschulnamen-Check ----
    pointblank::col_vals_in_set(
      columns = pointblank::vars(hochschule),
      set = hochschule_lang,
      actions = pointblank::action_levels(stop_at = 1),
      step_id = "hochschule_in_set_check",
      label = "Prüfe, ob hochschule gültig ist"
    ) |>

    # ---- 4.4 Hochschulkürzel-Check ----
    pointblank::col_vals_in_set(
      columns = pointblank::vars(hochschule_kurz),
      set = hochschule_kurz,
      actions = pointblank::action_levels(stop_at = 1),
      step_id = "hochschule_kurz_in_set_check",
      label = "Prüfe, ob hochschule_kurz gültig ist"
    ) |>

    # ---- 4.5 Pflichtfelder: Jahr und Semester dürfen nicht NA sein ----
    pointblank::col_vals_not_null(
      columns = pointblank::vars(jahr),
      actions = pointblank::action_levels(stop_at = 1),
      step_id = "jahr_not_null_check",
      label = "Prüfe, ob 'jahr' keine NAs enthält"
    ) |>
    pointblank::col_vals_not_null(
      columns = pointblank::vars(semester),
      actions = pointblank::action_levels(stop_at = 1),
      step_id = "semester_not_null_check",
      label = "Prüfe, ob 'semester' keine NAs enthält"
    ) |>

    # ---- 4.6 Sprach-Check ----
    pointblank::col_vals_in_set(
      columns = pointblank::vars(sprache_recoded),
      set = c(
        "Englisch",
        "Deutsch",
        "Deutsch/Englisch",
        "Französisch",
        "Spanisch",
        "Italienisch",
        "Russisch",
        "Türkisch",
        "Portugiesisch",
        "Niederländisch",
        "Sonstiges",
        NA
      ),
      actions = pointblank::action_levels(stop_at = 1),
      step_id = "sprache_in_set_check",
      label = "Prüfe, ob 'sprache' nur erlaubte Werte enthält"
    ) |>

    # ---- 4.7 Kursformat-Check ----
    pointblank::col_vals_in_set(
      columns = pointblank::vars(kursformat_recoded),
      set = c(
        "Vorlesung",
        "Seminar",
        "Übung",
        "Austausch",
        "Erfahrung",
        "Sprachkurs",
        "Sonstiges",
        NA
      ),
      actions = pointblank::action_levels(stop_at = 1),
      step_id = "kursformat_recoded_in_set_check",
      label = "Prüfe, ob 'kursformat_recoded' nur erlaubte Werte enthält"
    ) |>

    # ---- 4.8 Semester-Format-Check ----
    pointblank::col_vals_regex(
      columns = pointblank::vars(semester),
      regex = "^[0-9]{4}[sw]$",
      actions = pointblank::action_levels(stop_at = 1),
      step_id = "semester_format_check",
      label = "Prüfe, ob 'semester' das Format 'YYYYs' oder 'YYYYw' hat"
    ) |>

    # ---- 4.11 Checks ausführen ----
    pointblank::interrogate()

  # =========================
  # 5. Agent zurückgeben
  # =========================
  return(agent)
}
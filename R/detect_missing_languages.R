#' Ergänzt fehlende Sprachinformationen in Kursdaten
#'
#' Die Funktion behandelt zwei Fälle für Zeilen mit fehlendem
#' `sprache_recoded`:
#' 0. Falls `db_data_path` existiert, werden vorhandene gültige Werte in
#'    `sprache_recoded` zunächst anhand von `titel` aus der DB übernommen.
#'    Bereits vorhandene Werte in `raw_data` werden dabei nicht überschrieben.
#' 1. Wenn nur ein `titel` vorliegt und `kursbeschreibung` fehlt, wird
#'    `detect_lang_with_openai()` auf diese Zeilen angewendet.
#' 2. Wenn `kursbeschreibung` vorhanden ist, wird die Sprache der
#'    Kursbeschreibung mit `cld3::detect_language()` bestimmt und in
#'    `kursbeschreibung_sprach` geschrieben.
#'
#' Bestehende Werte in `sprache_recoded` und `kursbeschreibung_sprach` werden
#' nicht überschrieben.
#'
#' @param raw_data Ein data.frame oder tibble mit den Kursdaten.
#' @param db_data_path Pfad zur RDS-Datei mit bestehenden Sprachklassifikationen
#'   für `detect_lang_with_openai()`.
#' @param export_path Pfad zum Sicherheits-Export für
#'   `detect_lang_with_openai()`. Standard ist `"db_safety_export.rds"`.
#' @param batch_size Batch-Größe für `detect_lang_with_openai()`. Standard ist
#'   `100`.
#' @param titel_col Name der Titelspalte. Standard ist `"titel"`.
#' @param kursbeschreibung_col Name der Spalte mit Kursbeschreibungen.
#'   Standard ist `"kursbeschreibung"`.
#' @param sprache_col Name der Zielspalte für die recodierte Sprache. Standard
#'   ist `"sprache_recoded"`.
#' @param kursbeschreibung_sprach_col Name der Spalte für die per `cld3`
#'   erkannte Sprache der Kursbeschreibung. Standard ist
#'   `"kursbeschreibung_sprach"`.
#'
#' @return `raw_data` mit ergänzten Spalten `sprache_recoded` und
#'   `kursbeschreibung_sprach`.
#'
#' @importFrom dplyr if_else mutate
#' @importFrom rlang .data
#' @export
detect_missing_languages <- function(raw_data,
                                    db_data_path,
                                    export_path = "db_safety_export.rds",
                                    batch_size = 100,
                                    titel_col = "titel",
                                    kursbeschreibung_col = "kursbeschreibung",
                                    sprache_col = "sprache_recoded",
                                    kursbeschreibung_sprach_col = "kursbeschreibung_sprach") {

  required_cols <- c(titel_col, kursbeschreibung_col)
  missing_cols <- setdiff(required_cols, names(raw_data))
  if (length(missing_cols) > 0) {
    stop(
      "Folgende Spalten fehlen in `raw_data`: ",
      paste(missing_cols, collapse = ", "),
      call. = FALSE
    )
  }

  if (!sprache_col %in% names(raw_data)) {
    raw_data[[sprache_col]] <- NA_character_
  }

  if (!kursbeschreibung_sprach_col %in% names(raw_data)) {
    raw_data[[kursbeschreibung_sprach_col]] <- NA_character_
  }

  if (file.exists(db_data_path) && titel_col %in% names(raw_data)) {
    db_data <- readRDS(db_data_path)

    if (all(c(titel_col, sprache_col) %in% names(db_data))) {
      db_language_lookup <- db_data %>%
        dplyr::filter(
          !is.na(.data[[titel_col]]),
          .data[[titel_col]] != "",
          !is.na(.data[[sprache_col]])
        ) %>%
        dplyr::select(dplyr::all_of(c(titel_col, sprache_col))) %>%
        dplyr::distinct(.data[[titel_col]], .keep_all = TRUE)

      raw_data <- raw_data %>%
        dplyr::left_join(
          db_language_lookup,
          by = titel_col,
          suffix = c("", ".db")
        ) %>%
        dplyr::mutate(
          !!sprache_col := dplyr::coalesce(
            .data[[sprache_col]],
            .data[[paste0(sprache_col, ".db")]]
          )
        ) %>%
        dplyr::select(-dplyr::all_of(paste0(sprache_col, ".db")))
    }
  }

  title_only_idx <- is.na(raw_data[[sprache_col]]) &
    !is.na(raw_data[[titel_col]]) &
    raw_data[[titel_col]] != "" &
    is.na(raw_data[[kursbeschreibung_col]])

  if (any(title_only_idx)) {
    title_only_data <- raw_data[title_only_idx, , drop = FALSE]
    title_only_data <- detect_lang_with_openai(
      df = title_only_data,
      spalte = titel_col,
      db_data_path = db_data_path,
      export_path = export_path,
      batch_size = batch_size
    )

    raw_data[[sprache_col]][title_only_idx] <- title_only_data[[sprache_col]]
  }

  raw_data <- raw_data %>%
    dplyr::mutate(
      !!kursbeschreibung_sprach_col := dplyr::if_else(
        is.na(.data[[sprache_col]]) &
          !is.na(.data[[kursbeschreibung_col]]) &
          is.na(.data[[kursbeschreibung_sprach_col]]),
        cld3::detect_language(.data[[kursbeschreibung_col]]),
        .data[[kursbeschreibung_sprach_col]]
      )
    )

  raw_data
}

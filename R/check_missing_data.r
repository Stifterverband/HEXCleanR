#' Fehlende Kursdaten zwischen CSV und JSON identifizieren
#'
#' @description
#' Durchsucht den Datenordner einer Universität nach Semesterunterordnern (Format: `2023w`, `2024s` etc.)
#' und vergleicht jeweils eine `base_data_*.csv` mit einer `course_data_*.json`.
#' Zurückgegeben werden alle Zeilen aus der CSV, die **keinen** passenden Eintrag im JSON haben –
#' basierend auf einem normalisierten Vergleich zweier konfigurierbarer Spalten.
#'
#' @param path_uni_ordner `character(1)`. Pfad zum Universitätsordner, der die
#'   Semesterunterordner enthält.
#' @param colname_csv `character(1)`. Name der Vergleichsspalte in der CSV.
#'   Standard ist `"titel_der_veranstaltung"`.
#' @param colname_json `character(1)`. Name der Vergleichsspalte in der JSON.
#'   Standard ist `"systemtext"`.
#'
#' @return Ein `tibble` mit allen CSV-Zeilen ohne JSON-Entsprechung. Enthält mindestens
#'   die Spalten:
#'   \describe{
#'     \item{semester}{Name des Semesterordners (z. B. `"2023w"`)}
#'     \item{csv_datei}{Vollständiger Pfad zur Quelldatei (CSV)}
#'     \item{json_datei}{Vollständiger Pfad zur Quelldatei (JSON)}
#'     \item{...}{Alle weiteren Spalten aus der CSV}
#'   }
#'   Bei komplett fehlenden oder fehlerhaften Dateien wird ein leeres `tibble` zurückgegeben.
#'
#' @details
#' **Normalisierung:** Titel werden vor dem Vergleich mit [stringr::str_squish()] und
#' [stringr::str_to_lower()] bereinigt, um Whitespace- und Groß-/Kleinschreibungs-
#' unterschiede zu ignorieren.
#'
#' **Erwartete Ordnerstruktur:**
#' ```
#' path_uni_ordner/
#' ├── 2023w/
#' │   ├── base_data_*.csv
#' │   └── course_data_*.json
#' └── 2024s/
#'     ├── base_data_*.csv
#'     └── course_data_*.json
#' ```
#'
#' **Warnungen** werden ausgegeben, wenn:
#' \itemize{
#'   \item Mehrere CSV- oder JSON-Dateien in einem Semesterordner gefunden werden (es wird jeweils die erste verwendet)
#'   \item Die per `colname_csv` oder `colname_json` angegebenen Spalten fehlen
#' }
#'
#' @examples
#' \dontrun{
#' mss <- find_missing_data("C:/Daten/Philipps-Universitaet_Marburg")
#' View(mss)
#'
#' # Anzahl fehlender Einträge pro Semester
#' mss %>% count(semester, sort = TRUE)
#' }
#'
#' @importFrom dplyr mutate select anti_join everything
#' @importFrom readr read_csv
#' @importFrom jsonlite fromJSON
#' @importFrom purrr map list_rbind
#' @importFrom tibble as_tibble tibble
#' @importFrom stringr str_squish str_to_lower
#'
#' @export
find_missing_data <- function(
  path_uni_ordner,
  colname_csv = "titel_der_veranstaltung",
  colname_json = "systemtext"
) {
  normalize_title <- function(x) {
    x %>%
      as.character() %>%
      str_squish() %>%
      str_to_lower()
  }

  if (!is.character(colname_csv) || length(colname_csv) != 1) {
    stop("`colname_csv` muss ein einzelner Spaltenname sein.", call. = FALSE)
  }
  if (!is.character(colname_json) || length(colname_json) != 1) {
    stop("`colname_json` muss ein einzelner Spaltenname sein.", call. = FALSE)
  }

  message("Starte Vergleich in: ", path_uni_ordner)

  semester_ordner <- list.dirs(path_uni_ordner, recursive = FALSE, full.names = TRUE) %>%
    .[grepl("[0-9]{4}[sw]$", basename(.))]

  message("Gefundene Semesterordner: ", length(semester_ordner))

  map(semester_ordner, function(sem_path) {
    semester <- basename(sem_path)

    message("")
    message("---- Semester: ", semester, " ----")

    csv_file <- list.files(sem_path, pattern = "^base_data_.*\\.csv$", full.names = TRUE)
    json_file <- list.files(sem_path, pattern = "^course_data_.*\\.json$", full.names = TRUE)

    if (length(csv_file) > 1) warning("Mehrere CSV-Dateien in ", sem_path, " – nehme erste.")
    if (length(json_file) > 1) warning("Mehrere JSON-Dateien in ", sem_path, " – nehme erste.")

    if (length(csv_file) == 0 || length(json_file) == 0) {
      message("Dateien fehlen. CSV gefunden: ", length(csv_file), " | JSON gefunden: ", length(json_file))
      return(tibble())
    }

    message("CSV: ", basename(csv_file[1]))
    message("JSON: ", basename(json_file[1]))

    df_csv <- tryCatch(
      read_csv(csv_file[1], show_col_types = FALSE),
      error = function(e) {
        message("CSV-Lesefehler in ", csv_file[1], ": ", e$message)
        return(NULL)
      }
    )

    df_json <- tryCatch(
      fromJSON(json_file[1], flatten = TRUE) %>% as_tibble(),
      error = function(e) {
        message("JSON-Lesefehler in ", json_file[1], ": ", e$message)
        return(NULL)
      }
    )

    if (is.null(df_csv) || is.null(df_json)) return(tibble())

    if (!colname_csv %in% names(df_csv)) {
      warning("Spalte '", colname_csv, "' fehlt in ", csv_file[1])
      return(tibble())
    }
    if (!colname_json %in% names(df_json)) {
      warning("Spalte '", colname_json, "' fehlt in ", json_file[1])
      return(tibble())
    }

    df_csv <- df_csv %>% mutate(titel_norm = normalize_title(.data[[colname_csv]]))
    df_json <- df_json %>% mutate(systemtext_norm = normalize_title(.data[[colname_json]]))

    result <- df_csv %>%
      anti_join(df_json, by = c("titel_norm" = "systemtext_norm")) %>%
      mutate(
        semester   = semester,
        csv_datei  = csv_file[1],
        json_datei = json_file[1]
      ) %>%
      select(semester, everything(), -titel_norm)

    fehlend_abs <- nrow(result)
    fehlend_rel <- if (nrow(df_csv) == 0) 0 else fehlend_abs / nrow(df_csv) * 100

    message(
      "Fehlt im JSON, ist aber in CSV vorhanden: ",
      fehlend_abs, " (", round(fehlend_rel, 2), "%)"
    )

    result
  }) %>%
    list_rbind()
}
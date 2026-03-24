#' Lädt `course_data`-Dateien rekursiv aus einem Hochschulordner
#'
#' Die Funktion ermittelt automatisch den aktuellen Windows-Benutzernamen und
#' konstruiert daraus den Basispfad
#' `C:/Users/<username>/OneDrive - Stifterverband/Dateiablage - single_universities/`.
#' Innerhalb des übergebenen Hochschulordners sucht sie rekursiv nach Dateien,
#' deren Name mit `course_data` beginnt und je nach `file_type` auf `.json`,
#' `.rds` oder `.csv` endet. Ordner mit dem Namen `archiv` werden dabei
#' ausgeschlossen.
#'
#' Gefundene Dateien werden eingelesen, optional mit `janitor::clean_names()`
#' bereinigt, optional um eine Spalte `source_file` ergänzt und bei Bedarf vor
#' dem Zusammenführen vollständig in `character` umgewandelt, um Typkonflikte
#' zwischen Dateien zu vermeiden.
#'
#' @param university_folder Zeichenkette mit dem Namen des Hochschulordners
#'   innerhalb von `Dateiablage - single_universities`, zum Beispiel
#'   `"Otto_Friedrich_Universitaet_Bamberg"`.
#' @param file_type Zeichenkette zur Auswahl des Dateityps. Erlaubt sind
#'   `"all"` (Standard), `"json"`, `"rds"` oder `"csv"`.
#' @param clean_names Logisch. Wenn `TRUE` (Standard), werden die Spaltennamen
#'   jeder eingelesenen Datei mit `janitor::clean_names()` bereinigt.
#' @param add_source_file Logisch. Wenn `TRUE` (Standard), wird eine Spalte
#'   `source_file` mit dem Dateinamen ergänzt.
#' @param coerce_to_character Logisch. Wenn `TRUE` (Standard), werden alle
#'   Spalten pro eingelesener Datei vor dem Zusammenführen in `character`
#'   umgewandelt, um Typkonflikte beim Binden zu vermeiden.
#'
#' @return Ein `tibble` mit den zusammengeführten Inhalten aller gefundenen
#'   Dateien. Wenn keine passenden Dateien gefunden werden oder der
#'   Hochschulordner nicht existiert, gibt die Funktion `NULL` zurück und
#'   erzeugt eine Warnung.
#'
#' @importFrom dplyr %>% across everything mutate
#' @importFrom janitor clean_names
#' @importFrom jsonlite fromJSON
#' @importFrom purrr map_dfr
#' @importFrom readr read_csv read_rds
#' @importFrom stringr str_extract
#' @importFrom tibble as_tibble
#' @export
load_data_from_sp <- function(
  university_folder,
  file_type = "all",
  clean_names = TRUE,
  add_source_file = TRUE,
  coerce_to_character = TRUE
) {
  file_type <- match.arg(file_type, choices = c("all", "json", "rds", "csv"))

  username   <- Sys.info()[["user"]]
  base_path  <- file.path("C:/Users", username, "OneDrive - Stifterverband",
                          "Dateiablage - single_universities")
  target_path <- file.path(base_path, university_folder)

  if (!dir.exists(target_path)) {
    warning("Hochschulordner nicht gefunden: ", target_path)
    return(NULL)
  }

  file_pattern <- switch(
    file_type,
    all  = "^course_data.*\\.(json|rds|csv)$",
    json = "^course_data.*\\.json$",
    rds  = "^course_data.*\\.rds$",
    csv  = "^course_data.*\\.csv$"
  )

  files <- list.files(target_path, pattern = file_pattern,
                      full.names = TRUE, recursive = TRUE, ignore.case = TRUE)
  files <- files[!grepl("(^|[\\/])archiv([\\/]|$)", files, ignore.case = TRUE)]

  if (length(files) == 0) {
    warning("Keine course_data-Dateien gefunden in: ", target_path)
    return(NULL)
  }

  message("📂 ", length(files), " Datei(en) gefunden – lade...")

  combined_df <- purrr::map_dfr(files, function(file_path) {
    ext  <- tolower(stringr::str_extract(file_path, "[:alnum:]+$"))

    data <- switch(ext,
      json = jsonlite::fromJSON(file_path) |> tibble::as_tibble(),
      rds  = readr::read_rds(file_path)    |> tibble::as_tibble(),
      csv  = readr::read_csv(file_path, show_col_types = FALSE),
      return(NULL)
    )

    if (isTRUE(clean_names))        data <- janitor::clean_names(data)
    if (isTRUE(add_source_file))    data <- dplyr::mutate(data, source_file = basename(file_path))
    if (isTRUE(coerce_to_character)) data <- dplyr::mutate(data, dplyr::across(dplyr::everything(), as.character))

    data
  })

  message("✅ ", nrow(combined_df), " Zeilen geladen.")

  combined_df
}
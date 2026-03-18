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

  username <- Sys.info()[["user"]]
  base_path <- file.path(
    "C:/Users",
    username,
    "OneDrive - Stifterverband",
    "Dateiablage - single_universities"
  )
  target_path <- file.path(base_path, university_folder)

  message("Suche nach course_data-Dateien in: ", target_path)
  message("Ausgewählter Dateityp: ", file_type)
  message("clean_names aktiv: ", clean_names)
  message("source_file aktiv: ", add_source_file)
  message("als character harmonisieren: ", coerce_to_character)

  if (!dir.exists(target_path)) {
    warning("Der Hochschulordner wurde nicht gefunden: ", target_path)
    return(NULL)
  }

  file_pattern <- switch(
    file_type,
    all = "^course_data.*\\.(json|rds|csv)$",
    json = "^course_data.*\\.json$",
    rds = "^course_data.*\\.rds$",
    csv = "^course_data.*\\.csv$"
  )

  # 1. Alle relevanten Dateien finden
  files <- list.files(
    path = target_path,
    pattern = file_pattern,
    full.names = TRUE,
    recursive = TRUE,
    ignore.case = TRUE
  )

  files <- files[!grepl("(^|[\\/])archiv([\\/]|$)", files, ignore.case = TRUE)]

  if (length(files) == 0) {
    message("Keine passenden course_data-Dateien gefunden.")
    warning(
      "Im Verzeichnis wurden keine Dateien gefunden, die mit 'course_data' beginnen und ",
      "zum gewählten Dateityp passen."
    )
    return(NULL)
  }

  message("Gefundene Dateien: ", length(files))

  # 2. Dateien iterativ laden und binden
  combined_df <- purrr::map_dfr(files, function(file_path) {
    message("Lade Datei: ", basename(file_path))

    ext <- stringr::str_extract(file_path, "[:alnum:]+$") |> tolower()

    if (ext == "json") {
      data <- jsonlite::fromJSON(file_path) |> tibble::as_tibble()
    } else if (ext == "rds") {
      data <- readr::read_rds(file_path) |> tibble::as_tibble()
    } else if (ext == "csv") {
      data <- readr::read_csv(file_path, show_col_types = FALSE) |> tibble::as_tibble()
    } else {
      return(NULL)
    }

    if (isTRUE(clean_names)) {
      data <- janitor::clean_names(data)
    }

    if (isTRUE(add_source_file)) {
      data <- dplyr::mutate(data, source_file = basename(file_path))
    }

    if (isTRUE(coerce_to_character)) {
      data <- dplyr::mutate(data, dplyr::across(dplyr::everything(), as.character))
    }

    data
  })

  message("Zusammenführen abgeschlossen. Zeilen gesamt: ", nrow(combined_df))

  return(combined_df)
}

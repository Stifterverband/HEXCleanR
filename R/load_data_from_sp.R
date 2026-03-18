#' Lädt JSON- und RDS-Dateien rekursiv aus einem Verzeichnis
#'
#' Diese Funktion durchsucht ein Zielverzeichnis rekursiv nach Dateien, deren
#' Name mit `course_data` beginnt und auf `.json` oder `.rds` endet, liest alle
#' gefundenen Dateien ein und führt sie zu einem gemeinsamen `tibble`
#' zusammen. Zusätzlich wird für jede geladene Datei eine Spalte `source_file`
#' mit dem Dateinamen ergänzt.
#'
#' @param target_path Zeichenkette mit dem Pfad zum Verzeichnis, das nach
#'   `course_data*.json`- und `course_data*.rds`-Dateien durchsucht werden soll.
#'
#' @return Ein `tibble` mit den zusammengeführten Inhalten aller gefundenen
#'   Dateien. Wenn keine passenden Dateien gefunden werden, gibt die Funktion
#'   `NULL` zurück und schreibt eine Meldung in die Konsole.
#'
#' @examples
#' \dontrun{
#'   combined_data <- load_data_from_sp("C:/daten/scraping_output")
#' }
#'
#' @importFrom dplyr %>% mutate
#' @importFrom jsonlite fromJSON
#' @importFrom purrr map_dfr
#' @importFrom readr read_rds
#' @importFrom stringr str_extract
#' @importFrom tibble as_tibble
#' @export
load_data_from_sp <- function(target_path) {
  message("Suche nach course_data-Dateien in: ", target_path)

  # 1. Alle relevanten Dateien finden (course_data*.json und course_data*.rds)
  files <- list.files(
    path = target_path,
    pattern = "^course_data.*\\.(json|rds)$",
    full.names = TRUE, 
    recursive = TRUE,
    ignore.case = TRUE
  )
  
  if (length(files) == 0) {
    message("Keine course_data-JSON- oder course_data-RDS-Dateien gefunden.")
    warning("Im Verzeichnis wurden keine Dateien gefunden, die mit 'course_data' beginnen und auf '.json' oder '.rds' enden.")
    return(NULL)
  }

  message("Gefundene Dateien: ", length(files))

  # 2. Dateien iterativ laden und binden
  combined_df <- purrr::map_dfr(files, function(file_path) {
      message("Lade Datei: ", basename(file_path))
      
      # Dateiendung extrahieren (tolower zur Sicherheit)
      ext <- stringr::str_extract(file_path, "[:alnum:]+$") |> tolower()
      
      # Bedingung für den Ladeprozess
      if (ext == "json") {
        data <- jsonlite::fromJSON(file_path) |> tibble::as_tibble()
      } else if (ext == "rds") {
        data <- readr::read_rds(file_path) |> tibble::as_tibble()
      } else {
        return(NULL) # Falls doch was anderes durchrutscht
      }
      
      # Optional: Dateinamen als Spalte hinzufügen, um die Quelle zu tracken
      dplyr::mutate(data, source_file = basename(file_path))
    })

  message("Zusammenführen abgeschlossen. Zeilen gesamt: ", nrow(combined_df))
  
  return(combined_df)
}

#' Erzeugt ein Cleaning-Template im aktuellen Projekt
#'
#' Diese Funktion kopiert die im Paket mitgelieferte Datei
#' `cleaning_template.R` in das Verzeichnis `R` des aktuellen Projekts und
#' benennt sie in `data_preparation_<university_name>.R` um. Existiert unter
#' diesem Namen bereits eine Datei, wird eine Warnung ausgegeben und die
#' vorhandene Datei nicht überschrieben.
#'
#' @param university_name Zeichenkette mit dem Namen der Universität, für die ein Cleaning-Template erstellt werden soll.
#' @return Unsichtbar der Pfad zur erstellten (oder bereits vorhandenen)
#'   Datei.
#' @export
use_cleaning_template <- function(university_name) {
  if (missing(university_name) || !nzchar(university_name)) {
    stop("Bitte geben Sie einen Universitätsnamen an.", call. = FALSE)
  }

  file_name <- paste0("data_preparation_", university_name, ".R")
  save_path <- file.path("R", file_name)

  if (file.exists(save_path)) {
    warning(
      stringr::str_glue(
        "Die Datei '{save_path}' existiert bereits und wird nicht überschrieben."
      ),
      call. = FALSE
    )
    return(invisible(save_path))
  }

  template_path <- system.file("templates", "cleaning_template.R", package = "HEXCleanR")

  if (!nzchar(template_path)) {
    stop(
      "Die Template-Datei 'cleaning_template.R' konnte im Paket 'HEXCleanR' nicht gefunden werden.",
      call. = FALSE
    )
  }

  dir.create(dirname(save_path), showWarnings = FALSE, recursive = TRUE)

  ok <- file.copy(template_path, save_path, overwrite = FALSE)

  if (!ok) {
    stop(
      stringr::str_glue(
        "Beim Kopieren der Template-Datei nach '{save_path}' ist ein Fehler aufgetreten. Bitte prüfen Sie Pfad und Schreibrechte."
      ),
      call. = FALSE
    )
  }

  invisible(save_path)
}

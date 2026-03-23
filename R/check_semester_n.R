#' Gibt Zeilenzahlen pro `source_file` aus und gibt die Daten zurueck
#'
#' Fasst einen Datensatz nach `source_file` zusammen, zaehlt die Anzahl der
#' Zeilen pro Datei und gibt die Uebersicht direkt in der Konsole aus. Die
#' Funktion ist fuer Pipelines gedacht und gibt den originalen Datensatz
#' unveraendert zurueck.
#'
#' @param data Ein `data.frame` oder `tibble` mit einer Spalte `source_file`.
#' @param print_n Anzahl der beim `print()` anzuzeigenden Zeilen. Standard ist
#'   `Inf`, damit alle Gruppen ausgegeben werden.
#'
#' @return Der unveraenderte Eingabedatensatz.
#'
#' @importFrom dplyr arrange desc group_by summarise n
#' @export
check_semester_n <- function(data, print_n = Inf) {
  if (!"source_file" %in% names(data)) {
    stop("Die Spalte 'source_file' ist im uebergebenen Datensatz nicht vorhanden.", call. = FALSE)
  }

  message("Pruefe Zeilenzahlen pro source_file ...")

  counts <- data |>
    dplyr::group_by(source_file) |>
    dplyr::summarise(n = dplyr::n(), .groups = "drop") |>
    dplyr::arrange(dplyr::desc(n))

  message("Anzahl unterschiedlicher source_file-Werte: ", nrow(counts))
  message("Gesamtzahl Zeilen im Datensatz: ", nrow(data))
  message("Uebersicht der Zeilenzahlen pro source_file:")
  print(counts, n = print_n)

  invisible(data)
}

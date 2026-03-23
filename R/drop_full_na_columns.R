#' Gibt NA-Anteile pro Variable aus und entfernt 100%-NA-Spalten
#'
#' Berechnet fuer jede Variable den Anteil fehlender Werte, gibt eine
#' ausfuehrliche Uebersicht in der Konsole aus und entfernt anschliessend alle
#' Variablen, die ausschliesslich aus `NA` bestehen. Die Funktion ist fuer
#' Pipelines gedacht.
#'
#' @param data Ein `data.frame` oder `tibble`.
#' @param print_n Anzahl der beim `print()` anzuzeigenden Zeilen. Standard ist
#'   `Inf`, damit alle Variablen ausgegeben werden.
#'
#' @return Ein Datensatz ohne Variablen mit 100% `NA`.
#'
#' @examples
#' \dontrun{
#' final_df |>
#'   drop_full_na_columns()
#' }
#'
#' @importFrom dplyr arrange desc
#' @importFrom tibble tibble
#' @export
drop_full_na_columns <- function(data, print_n = Inf) {
  message("Pruefe NA-Anteile pro Variable ...")

  if (ncol(data) == 0) {
    message("Der Datensatz enthaelt keine Spalten. Es wurde nichts geaendert.")
    return(data)
  }

  if (nrow(data) == 0) {
    message("Der Datensatz enthaelt keine Zeilen. Es wurde nichts gedroppt.")
    return(data)
  }

  na_count <- vapply(data, function(x) sum(is.na(x)), integer(1))
  na_share <- na_count / nrow(data)

  na_pct_display <- ifelse(
    na_count == nrow(data),
    100,
    floor(na_share * 1000) / 10
  )

  na_overview <- tibble::tibble(
    variable = names(data),
    na_count = as.integer(na_count),
    na_pct = na_pct_display
  ) |>
    dplyr::arrange(dplyr::desc(na_pct), variable)

  message("Anzahl Variablen: ", ncol(data))
  message("Anzahl Zeilen: ", nrow(data))
  message("NA-Uebersicht pro Variable in Prozent:")
  print(na_overview, n = print_n)

  full_na_vars <- na_overview$variable[na_overview$na_count == nrow(data)]

  if (length(full_na_vars) == 0) {
    message("Es wurden keine Variablen mit 100% NA gefunden. Es wurde nichts gedroppt.")
    return(data)
  }

  message("Folgende Variablen haben 100% NA und werden entfernt:")
  print(full_na_vars)

  data_clean <- data[, !(names(data) %in% full_na_vars), drop = FALSE]

  message("Anzahl entfernter Variablen: ", length(full_na_vars))
  message("Verbleibende Variablen nach dem Drop: ", ncol(data_clean))

  return(data_clean)
}

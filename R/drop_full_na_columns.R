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

  if (ncol(data) == 0 || nrow(data) == 0) {
    message("ℹ️  Leerer Datensatz – nichts entfernt.")
    return(data)
  }

  na_count     <- vapply(data, function(x) sum(is.na(x)), integer(1))
  full_na_vars <- names(na_count[na_count == nrow(data)])

  if (length(full_na_vars) == 0) {
    message("✅ Keine Spalten mit 100% NA gefunden.")
    return(data)
  }

  message("🗑️  Entferne ", length(full_na_vars), " Spalte(n) mit 100% NA: ",
          paste(full_na_vars, collapse = ", "))

  data[, !(names(data) %in% full_na_vars), drop = FALSE]
}
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
  separator <- paste(rep("=", 70), collapse = "")

  cat("\n", separator, "\n", sep = "")
  cat("🧹 NA-Check: Spalten mit 100% NA finden und entfernen\n")
  cat(separator, "\n", sep = "")

  if (ncol(data) == 0) {
    cat("ℹ️  Der Datensatz enthaelt keine Spalten. Es wurde nichts geaendert.\n")
    cat(separator, "\n", sep = "")
    return(data)
  }

  if (nrow(data) == 0) {
    cat("ℹ️  Der Datensatz enthaelt keine Zeilen. Es wurde nichts gedroppt.\n")
    cat(separator, "\n", sep = "")
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

  cat("📊 Datensatz: ", nrow(data), " Zeilen x ", ncol(data), " Variablen\n", sep = "")
  cat("🔎 NA-Uebersicht pro Variable:\n")
  print(na_overview, n = print_n)

  full_na_vars <- na_overview$variable[na_overview$na_count == nrow(data)]

  if (length(full_na_vars) == 0) {
    cat("✅ Keine Variablen mit 100% NA gefunden. Es wurde nichts entfernt.\n")
    cat(separator, "\n", sep = "")
    return(data)
  }

  cat("🗑️  Diese Variablen werden entfernt:\n")
  print(full_na_vars)

  data_clean <- data[, !(names(data) %in% full_na_vars), drop = FALSE]

  cat("✅ Entfernt: ", length(full_na_vars), " Variable(n)\n", sep = "")
  cat("📦 Verbleibend: ", ncol(data_clean), " Variable(n)\n", sep = "")
  cat(separator, "\n", sep = "")

  return(data_clean)
}

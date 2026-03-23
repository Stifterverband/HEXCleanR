#' Fuehrt `str_squish()` auf allen Character-Variablen aus
#'
#' Bereinigt alle Character-Spalten eines Datensatzes, indem fuehrende und
#' nachgestellte Leerzeichen entfernt und Mehrfach-Leerzeichen innerhalb von
#' Strings auf ein einzelnes Leerzeichen reduziert werden. Die Funktion ist fuer
#' Pipelines gedacht und gibt den bereinigten Datensatz zurueck.
#'
#' @param data Ein `data.frame` oder `tibble`.
#'
#' @return Ein Datensatz, in dem alle Character-Variablen mit
#'   `stringr::str_squish()` bereinigt wurden.
#'
#' @examples
#' \dontrun{
#' final_df |>
#'   squish_character_columns()
#' }
#'
#' @importFrom dplyr across mutate where
#' @importFrom stringr str_squish
#' @export
squish_character_columns <- function(data) {
  separator <- paste(rep("-", 70), collapse = "")

  cat("\n", separator, "\n", sep = "")
  cat("✂️ Textbereinigung: str_squish() auf Character-Variablen\n")
  cat(separator, "\n", sep = "")

  character_cols <- names(data)[vapply(data, is.character, logical(1))]

  if (length(character_cols) == 0) {
    cat("ℹ️  Keine Character-Variablen gefunden. Es wurde nichts geaendert.\n")
    cat(separator, "\n", sep = "")
    return(data)
  }

  cat("📝 str_squish() wird angewendet auf:\n")
  print(character_cols)

  data_clean <- data |>
    dplyr::mutate(
      dplyr::across(
        dplyr::where(is.character),
        stringr::str_squish
      )
    )

  cat("✅ Leerzeichenbereinigung abgeschlossen.\n")
  cat(separator, "\n", sep = "")

  return(data_clean)
}

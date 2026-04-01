#' Ersetzt leere Strings durch `NA`
#'
#' Bereinigt alle Zeichenketten-Spalten eines Data Frames, indem führende und
#' nachgestellte Leerzeichen entfernt und anschließend leere Strings (`""`) als
#' fehlende Werte (`NA`) gesetzt werden.
#'
#' @param df Ein `data.frame` oder `tibble`.
#'
#' @return Ein Objekt mit derselben Struktur wie `df`, in dem leere oder nur aus
#'   Leerzeichen bestehende Zeichenketten in Character-Spalten durch `NA`
#'   ersetzt wurden.
#'
#' empty_str_to_na(test_df)
#'
#' @importFrom dplyr mutate across na_if where
#' @export
empty_str_to_na <- function(df) {
  df %>%
    mutate(across(where(is.character), ~na_if(trimws(.), "")))
}

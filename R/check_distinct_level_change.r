#' Checkt auf auffällige Änderungen der Anzahl einzigartiger Werte einer Variablen zwischen Gruppen
#'
#' Diese Funktion dient der Qualitäts- und Plausibilitätskontrolle einer Variable, indem sie
#' prüft, ob sich die Anzahl einzigartiger Werte (z. B. Organisationen, Sprachen,
#' Studiengänge) zwischen Gruppen (typischerweise Semestern oder Jahre) auffällig
#' verändert. Ziel ist das frühzeitige Erkennen potenziell fehlerhafter Daten 
#' (z. B. unvollständiges Scraping, fehlerhafte Joins).
#'
#' @param data Ein `data.frame` oder `tibble` mit den zu prüfenden Daten.
#' @param value_col Ungequoteter Spaltenname: Spalte, deren Anzahl einzigartiger Werte
#'   geprüft werden soll (z. B. Organisation, Semestern).
#' @param group_col Ungequoteter Spaltenname: Gruppierungsvariable (z. B. Semester, Jahr).
#' @param threshold Numerischer Schwellenwert für den relativen Vergleich.
#'   Ein Wert von `0.75` entspricht einer erlaubten Abweichung von bis zu 25%.
#'
#' @details
#' Je nach Anzahl der Gruppen wird automatisch zwischen zwei Prüfmodi unterschieden:
#' - mehr als 3 Gruppen: Plausibilitätscheck auf harte Sprünge mittels relativem Vergleich
#'   zum Maximum.
#' - weniger/gleich 3 Gruppen: Stabilitätscheck mittels Vergleich zum Durchschnitt.
#'
#' Die Funktion zählt pro Gruppe die Anzahl einzigartiger Werte in `value_col`.
#' Bei nur zwei Gruppen wird geprüft, ob eine Gruppe deutlich vom Maximum abweicht
#' (harter Sprung). Bei drei oder mehr Gruppen wird geprüft, ob einzelne Gruppen
#' deutlich unter dem durchschnittlichen Niveau liegen.
#'
#' Die Funktion ist explizit als Plausibilitäts- und Fehlerdetektor konzipiert und
#' nicht als inferenzstatistisches Verfahren.
#'
#' @return Ein `tibble` mit folgenden Spalten:
#' - `grp_val`: Gruppierungswert (Werte aus `group_col`).
#' - `n_distinct`: Anzahl einzigartiger Werte in `value_col` je Gruppe.
#' - `rel_change`: Relativer Vergleichswert (zur Referenz oder zum Durchschnitt).
#' - `flagged`: Logisch, ob eine auffällige Abweichung vorliegt.
#'@examples
#' \dontrun{
#'   check_distinct_level_change(
#'     db_data_universitaet_jena,
#'     organisation,
#'     semester,
#'     threshold = 0.75
#'   )
#' }
#' @importFrom dplyr filter group_by summarise mutate n_distinct
#' @importFrom rlang ensym
#' @importFrom tibble tibble
#' @export
check_distinct_level_change <- function(data, value_col, group_col, threshold = 0.75) {
  val <- rlang::ensym(value_col)
  grp <- rlang::ensym(group_col)

  stats <- data |>
    dplyr::filter(!is.na(!!grp), !is.na(!!val)) |>
    dplyr::group_by(grp_val = !!grp) |>
    dplyr::summarise(n_distinct = dplyr::n_distinct(!!val), .groups = "drop")

  # ⛔ Abbruch bei komplett leeren Spalten
  if (nrow(stats) == 0) {
    return(
      tibble::tibble(
        grp_val = NA,
        n_distinct = 0,
        rel_change = 0,
        flagged = FALSE
      )
    )
  }

  n_groups <- nrow(stats)

  if (n_groups < 3) {
    ref <- max(stats$n_distinct, na.rm = TRUE)
    stats <- stats |>
      dplyr::mutate(
        rel_change = ifelse(ref == 0, 0, n_distinct / ref),
        flagged = rel_change < threshold & n_distinct != ref
      )
  } else {
    avg <- mean(stats$n_distinct, na.rm = TRUE)
    stats <- stats |>
      dplyr::mutate(
        rel_change = ifelse(avg == 0, 0, n_distinct / avg),
        flagged = rel_change < threshold & n_distinct != avg
      )
  }

  stats
}
#' Wendet die Plausibilitätsprüfung auf alle Spalten eines Datensatzes an.
#'
#' Diese Hilfsfunktion wendet `check_distinct_level_change()` für alle
#' Variablen eines Datensatzes an, außer für die angegebene Gruppierungsvariable.
#' So kann in einem Schritt für alle Variablen eines Datensatzes geprüft werden, ob sich die
#' Anzahl einzigartiger Werte zwischen Gruppen (z. B. Semestern) auffällig
#' verändert.
#'
#' @param data Ein `data.frame` oder `tibble` mit den zu prüfenden Daten.
#' @param group_col Ungequoteter Spaltenname: Gruppierungsvariable, die für alle
#'   Checks als Referenz verwendet wird (z. B. `semester`).
#' @param threshold Numerischer Schwellenwert für den relativen Vergleich, wird
#'   direkt an `check_distinct_level_change()` weitergegeben.
#'
#' @details Alle Spalten in `data`, die nicht `group_col` entsprechen, werden als
#' `value_col` nacheinander an `check_distinct_level_change()` übergeben.
#' Die Ergebnisse werden mit `purrr::map_dfr()` zu einem gemeinsamen Tibble
#' zusammengeführt und erhalten zusätzlich eine Spalte `variable`, die den
#' Namen der jeweils geprüften Spalte enthält.
#'
#' @return Ein `tibble`, das die gebündelten Ergebnisse von
#' `check_distinct_level_change()` für alle geprüften Variablen enthält.
#' Zurückgegeben werden nur die Kombinationen, bei denen `flagged == TRUE` ist
#' (also auffällige Abweichungen). Das Ergebnis enthält mindestens die
#' Spalten `variable`, `grp_val`, `n_distinct`, `rel_change` und `flagged`.
#' Falls keine auffälligen Abweichungen gefunden werden, wird ein leeres
#' `tibble` zurückgegeben und eine entsprechende Erfolgsmeldung ausgegeben.
#' 
#' @examples
#' \dontrun{
#'   check_distinct_level_change_df(db_data_universitaet_jena, 
#'                                  semester)
#' }
#'
#' @seealso \link{check_distinct_level_change}
#'
#' @importFrom rlang ensym as_string sym
#' @importFrom purrr map_dfr
#' @importFrom dplyr mutate filter
#' @export
check_distinct_level_change_df <- function(data, group_col, threshold = 0.75) {
  group_col_sym <- rlang::ensym(group_col)
  group_col_str <- rlang::as_string(group_col_sym)
  
  value_cols <- setdiff(names(data), group_col_str)

  res <- purrr::map_dfr(
    value_cols,
    ~ check_distinct_level_change(
        data = data,
        value_col = !!rlang::sym(.x),
        group_col = !!group_col_sym,
        threshold = threshold
      ) |> dplyr::mutate(variable = .x, .before = 1)
  )

  res_flagged <- dplyr::filter(res, flagged)

  if (nrow(res_flagged) == 0) {
    message("\033[32m////////////////////////////////////////////////////////////////////////////////\033[39m")
    message("\033[32m✅ Validierung abgeschlossen: Keine auffälligen Abweichungen bei den\033[39m")
    message("\033[32meindeutigen Werten identifiziert\033[39m")
    message("\033[32m////////////////////////////////////////////////////////////////////////////////\033[39m")
  } else {
    message("\033[31m/////////////////////////////////////////////////////////////////////////////////\033[39m")
    message("\033[31m⚠️  Hinweis: Signifikante Abweichungen bei den eindeutigen Werten identifiziert.\033[39m")
    message("\033[31mPrüfung der folgenden Variablen erforderlich:\033[39m")
    message("\033[31m/////////////////////////////////////////////////////////////////////////////////\033[39m")
    return(res_flagged)
  }
}
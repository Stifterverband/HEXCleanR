#' Prüft Distinct-Werte-Änderungen für alle Variablen eines Datensatzes
#'
#' Diese Hilfsfunktion ruft intern für jede Nicht-Gruppierungsvariable
#' `check_distinct_level_change()` auf und fasst die Ergebnisse zu einem
#' gemeinsamen `tibble` zusammen. Standardmäßig werden nur die Einträge
#' zurückgegeben, die als auffällig markiert (`flagged == TRUE`) sind.
#'
#' @param data Ein `data.frame` oder `tibble` mit den zu prüfenden Daten.
#' @param group_col Ungequoteter Spaltenname; Gruppierungsvariable (z. B. `semester`).
#'   Die Funktion verwendet `rlang::ensym()` zur Auswertung.
#' @param threshold_low Numerischer unterer Schwellenwert für die Prüfung (z. B. 0.70).
#' @param threshold_high Numerischer oberer Schwellenwert für die Prüfung (z. B. 1.50).
#' @param min_distinct Ganzzahliger Minimalwert für den Median der Anzahl unterschiedlicher
#'   Werte, unterhalb dessen eine Variable nicht geprüft wird (Standard: 5).
#'
#' @details Für jede Spalte in `data`, die nicht der `group_col` entspricht,
#' wird die Anzahl unterschiedlicher Werte pro Gruppe berechnet. Als Referenz
#' dient der Median der Anzahl unterschiedlicher Werte über alle Gruppen.
#' Liegt die relative Abweichung vom Median außerhalb der Intervalle
#' `threshold_low` .. `threshold_high`, wird dieser Fall als auffällig
#' markiert.
#'
#' @return Ein `tibble` mit den markierten Abweichungen. Die Ausgabe enthält
#' mindestens die Spalten:
#' - `status`: Textueller Status (`negativ abweichend`, `positiv abweichend`, `NORMAL`)
#' - `variable`: Name der geprüften Variable
#' - `semester`: Wert der Gruppierungsvariable (Originalname in der Ausgabe `semester`)
#' - `unique_found`: Gefundene Anzahl eindeutiger Werte in der Gruppe
#' - `unique_med`: Median der eindeutigen Werte über alle Gruppen
#' - `faktor`: Verhältnis `unique_found / unique_med` (gerundet)
#'
#' Wenn keine Auffälligkeiten gefunden werden, gibt die Funktion ein leeres
#' `tibble` (invisibly) zurück und schreibt eine Erfolgsmeldung.
#'
#' @examples
#' \dontrun{
#'   check_distinct_level_change_df(db_data_universitaet_jena, semester)
#'   check_distinct_level_change_df(my_data, semester, threshold_low = 0.6, threshold_high = 1.4)
#' }
#'
#' @seealso \link{check_distinct_level_change}
#'
#' @importFrom rlang ensym as_string sym
#' @importFrom purrr map_dfr
#' @importFrom dplyr mutate filter
#' @export
check_distinct_level_change_df <- function(data, group_col, threshold_low = 0.70, threshold_high = 1.50, min_distinct = 5) {
  
  group_col_sym <- rlang::ensym(group_col)
  group_col_str <- rlang::as_string(group_col_sym)
  value_cols <- setdiff(names(data), group_col_str)

  # 1. Analyse über alle Spalten
  res <- purrr::map_dfr(value_cols, function(col_name) {
    stats <- data |>
      dplyr::filter(!is.na(!!group_col_sym), !is.na(!!rlang::sym(col_name))) |>
      dplyr::group_by(gruppe = !!group_col_sym) |>
      dplyr::summarise(n_unique = dplyr::n_distinct(!!rlang::sym(col_name)), .groups = "drop")

    if (nrow(stats) < 2) return(NULL) 
    
    # Der Median als robuster Vergleichswert
    unique_med <- median(stats$n_unique, na.rm = TRUE)
    
    # Check, ob die Variable überhaupt genug Information enthält
    if (unique_med < min_distinct) return(NULL)

    stats |>
      dplyr::mutate(
        variable = col_name,
        unique_med = unique_med,
        abweichung_faktor = n_unique / unique_med,
        
        status = dplyr::case_when(
          abweichung_faktor < threshold_low  ~ "negativ abweichend",
          abweichung_faktor > threshold_high ~ "positiv abweichend",
          TRUE ~ "NORMAL"
        ),
        flagged = status != "NORMAL"
      )
  })

  # 2. Filter auf die Ausreißer
  res_flagged <- if (nrow(res) > 0) dplyr::filter(res, flagged) else res

  if (nrow(res_flagged) == 0) {
    message("✅ Validierung OK: Keine auffälligen Abweichungen (Basis: Median) gefunden.")
    return(invisible(res_flagged))
  }

  # 3. Finaler Output mit intuitiven Namen
  res_flagged |> 
    dplyr::select(
      status,
      variable,
      semester = gruppe,
      unique_found = n_unique,
      unique_med,
      faktor = abweichung_faktor
    ) |>
    dplyr::mutate(faktor = round(faktor, 2)) |>
    dplyr::arrange(variable, semester)
}
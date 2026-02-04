#' Prüft Distinct-Werte-Änderungen für eine spezifische Variable
#'
#' Berechnet die Anzahl eindeutiger Werte pro Gruppe und vergleicht diese mit dem Median
#' aller Gruppen, um Ausreißer zu identifizieren.
#'
#' @param data Ein `data.frame` oder `tibble`.
#' @param group_col Die Gruppierungsvariable (ungequotet, z.B. semester).
#' @param target_col Die zu prüfende Variable (ungequotet).
#' @param threshold_low Unterer Schwellenwert (Standard: 0.70).
#' @param threshold_high Oberer Schwellenwert (Standard: 1.50).
#' @param min_distinct Mindestanzahl an Distinct-Werten im Median (Standard: 5).
#'
#' @return Ein `tibble` mit den Ergebnissen, falls Abweichungen gefunden wurden.
#' @export
check_distinct_level_change <- function(data, 
                                        group_col, 
                                        target_col, 
                                        threshold_low = 0.70, 
                                        threshold_high = 1.50, 
                                        min_distinct = 5) {
  
  group_sym <- rlang::ensym(group_col)
  target_sym <- rlang::ensym(target_col)
  target_name <- rlang::as_string(target_sym)

  # 1. Berechnung der Unique-Stats pro Gruppe
  stats <- data |>
    dplyr::filter(!is.na(!!group_sym), !is.na(!!target_sym)) |>
    dplyr::group_by(gruppe = !!group_sym) |>
    dplyr::summarise(n_unique = dplyr::n_distinct(!!target_sym), .groups = "drop")

  if (nrow(stats) < 2) {
    message("Zu wenige Gruppen für einen Vergleich.")
    return(invisible(dplyr::tibble()))
  }

  # 2. Median-Referenz berechnen
  unique_med <- median(stats$n_unique, na.rm = TRUE)

  # Check auf Mindestkomplexität
  if (unique_med < min_distinct) {
    return(invisible(dplyr::tibble()))
  }

  # 3. Abweichungen identifizieren
  res <- stats |>
    dplyr::mutate(
      variable = target_name,
      unique_med = unique_med,
      faktor = round(n_unique / unique_med, 2),
      status = dplyr::case_when(
        faktor < threshold_low  ~ "negativ abweichend",
        faktor > threshold_high ~ "positiv abweichend",
        TRUE ~ "NORMAL"
      )
    ) |>
    dplyr::filter(status != "NORMAL") |>
    dplyr::select(status, variable, group_value = gruppe, unique_found = n_unique, unique_med, faktor)

  if (nrow(res) == 0) {
    message(paste0("✅ Variable '", target_name, "': Keine Auffälligkeiten."))
    return(invisible(res))
  }

  return(res)
}
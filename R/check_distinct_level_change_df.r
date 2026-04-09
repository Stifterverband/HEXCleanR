#' Prueft Veraenderungen in der Anzahl unterschiedlicher Werte
#'
#' Die Funktion betrachtet fuer jede Variable die Zahl unterschiedlicher Werte
#' pro Gruppe und vergleicht sie mit dem Median ueber alle Gruppen. So lassen
#' sich Gruppen finden, die deutlich weniger oder deutlich mehr Vielfalt
#' aufweisen als die anderen.
#'
#' @param data Ein `data.frame` oder `tibble` mit den zu pruefenden Daten.
#' @param group_col Ungequoteter Spaltenname der Gruppierungsvariable
#'   (z. B. `semester`).
#' @param threshold_low Untere Grenze fuer den Vergleich mit dem Median
#'   (Standard: 0.70).
#' @param threshold_high Obere Grenze fuer den Vergleich mit dem Median
#'   (Standard: 1.50).
#' @param min_distinct Mindestanzahl unterschiedlicher Werte im Median.
#'   Variablen mit sehr wenigen Auspraegungen werden nicht geprueft
#'   (Standard: 5).
#' @param relative Logisch. Wenn `FALSE`, wird wie bisher mit der absoluten Zahl
#'   unterschiedlicher Werte gearbeitet. Wenn `TRUE`, wird stattdessen
#'   `n_unique / Gruppengroesse` verwendet. Standard ist `FALSE`.
#'
#' @details Fuer jede Variable ausser `group_col` wird pro Gruppe eine Kennzahl
#' berechnet: entweder die absolute Anzahl unterschiedlicher Werte oder, bei
#' `relative = TRUE`, deren relativer Anteil an der Gruppengroesse. Diese Kennzahl wird
#' mit dem Median ueber alle Gruppen verglichen. Liegt der Quotient unter
#' `threshold_low` oder ueber `threshold_high`, wird die Gruppe als auffaellig
#' markiert.
#'
#' `relative = TRUE` ist besonders dann hilfreich, wenn sich die Gruppengroessen
#' stark unterscheiden. In solchen Faellen haben groessere Gruppen oft schon
#' allein wegen ihrer Hoehe mehr unterschiedliche Werte und werden im absoluten
#' Modus schneller auffaellig. Der relative Modus reduziert diese Verzerrung.
#'
#' Gleichzeitig aendert sich damit die Interpretation: Ein Flag weist dann nicht
#' mehr primaer auf eine Veraenderung der absoluten Anzahl von Auspraegungen hin,
#' sondern auf eine Veraenderung der relativen Vielfalt innerhalb einer Gruppe.
#' Wenn feste Kategorien erwartet werden und vor allem geprueft werden soll, ob
#' Kategorien hinzugekommen oder weggefallen sind, ist `relative = FALSE` oft
#' die passendere Wahl.
#'
#' `relative = TRUE` ist sinnvoll:
#' Stell dir vor, ein neues Semester hat 4.000 Kurse und ein altes nur 800.
#' Bei der Variable `titel` wird das grosse Semester fast automatisch mehr
#' unterschiedliche Werte haben, einfach weil mehr Kurse vorliegen. Wenn du
#' hier Auffaelligkeiten pruefen willst, ist die relative Vielfalt sinnvoller,
#' also etwa `n_unique / n_group`. Dann fragst du: Hat dieses Semester im
#' Verhaeltnis zu seiner Groesse ungewoehnlich viele oder wenige unterschiedliche
#' Titel?
#'
#' `relative = FALSE` ist sinnvoll:
#' Stell dir eine Variable wie `abschlussart` mit Kategorien wie `Bachelor`,
#' `Master`, `Staatsexamen`, `Promotion` vor. Hier ist oft gerade die absolute
#' Zahl vorhandener Kategorien interessant. Wenn in einem Semester ploetzlich
#' nur noch 2 statt 4 Kategorien vorkommen, willst du das direkt sehen. Die
#' relative Kennzahl hilft hier wenig, weil nicht die Gruppengroesse
#' entscheidend ist, sondern ob Kategorien fehlen oder neu auftauchen.
#'
#' @return Ein `tibble` mit den auffaelligen Abweichungen. Die Ausgabe enthaelt
#' unter anderem:
#' - `status`: Richtung der Abweichung
#' - `variable`: gepruefte Variable
#' - `semester`: Wert der Gruppierungsvariable
#' - `unique_found`: verwendete Kennzahl der Gruppe
#' - `unique_med`: Median dieser Kennzahl ueber alle Gruppen
#' - `faktor`: Verhaeltnis von `unique_found` zu `unique_med`
#'
#' Wenn keine Auffaelligkeiten gefunden werden, wird ein leeres `tibble`
#' zurueckgegeben.
#'
#' @examples
#' \dontrun{
#'   check_distinct_level_change_df(db_data_universitaet_jena, semester)
#'   check_distinct_level_change_df(my_data, semester, threshold_low = 0.6, threshold_high = 1.4)
#'   check_distinct_level_change_df(my_data, semester, relative = TRUE)
#' }
#'
#' @seealso \link{check_distinct_level_change}
#'
#' @importFrom rlang ensym as_string sym
#' @importFrom purrr map_dfr
#' @importFrom dplyr mutate filter
#' @export
check_distinct_level_change_df <- function(data, group_col, threshold_low = 0.70, threshold_high = 1.50, min_distinct = 5, relative = FALSE) {

  group_col_sym <- rlang::ensym(group_col)
  group_col_str <- rlang::as_string(group_col_sym)
  value_cols <- setdiff(names(data), group_col_str)

  # 1. Analyse ueber alle Spalten
  res <- purrr::map_dfr(value_cols, function(col_name) {
    stats <- data |>
      dplyr::filter(!is.na(!!group_col_sym), !is.na(!!rlang::sym(col_name))) |>
      dplyr::group_by(gruppe = !!group_col_sym) |>
      dplyr::summarise(
        n_group = dplyr::n(),
        n_unique = dplyr::n_distinct(!!rlang::sym(col_name)),
        metric_value = if (isTRUE(relative)) .data$n_unique / .data$n_group else .data$n_unique,
        .groups = "drop"
      )

    if (nrow(stats) < 2) return(NULL)

    unique_med <- median(stats$metric_value, na.rm = TRUE)
    median_n_unique <- median(stats$n_unique, na.rm = TRUE)

    if (median_n_unique < min_distinct) return(NULL)

    stats |>
      dplyr::mutate(
        variable = col_name,
        unique_med = unique_med,
        relative = relative,
        abweichung_faktor = .data$metric_value / unique_med,
        status = dplyr::case_when(
          abweichung_faktor < threshold_low  ~ "negativ abweichend",
          abweichung_faktor > threshold_high ~ "positiv abweichend",
          TRUE ~ "NORMAL"
        ),
        flagged = status != "NORMAL"
      )
  })

  # 2. Filter auf die Ausreisser
  res_flagged <- if (nrow(res) > 0) dplyr::filter(res, flagged) else res

  if (nrow(res_flagged) == 0) {
    message("Validierung OK: Keine auffaelligen Abweichungen (Basis: Median) gefunden.")
    return(invisible(res_flagged))
  }

  # 3. Finaler Output mit intuitiven Namen
  res_flagged |>
    dplyr::select(
      status,
      variable,
      semester = gruppe,
      unique_found = metric_value,
      unique_med,
      faktor = abweichung_faktor,
      n_unique,
      n_group,
      relative
    ) |>
    dplyr::mutate(faktor = round(faktor, 2)) |>
    dplyr::arrange(variable, semester)
}

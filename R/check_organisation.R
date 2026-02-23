#' Prüft Organisations-Variable auf definierte Qualitätsregeln
#'
#' Diese Funktion verwendet das Paket `pointblank`, um die Werte in der
#' Organisations-Variable systematisch zu validieren. Optional wird ein HTML-Report mit Badges ausgegeben.
#'
#' @param data Ein `data.frame`, das die zu prüfende Organisations-Variable enthält.
#' @param organisation_col Name der Organisations-Variable (Standard: `organisation`).
#' @param semester_col Name der Semester-Spalte (Standard: `semester`).
#'   Wird für den Check auf Schwankungen zwischen Semestern benötigt.
#' @param stop_at Schwellenwert für Fehler-Toleranz. Kann relativ (Anteil 0 bis 1)
#'   oder absolut (z. B. 1 für "Null Toleranz") angegeben werden.
#'   Standard: 1 (= Null Toleranz).
#' @param show_report Logisch; wenn `TRUE`, wird ein pointblank-Report
#'   mit Badges im Viewer ausgegeben. Standard: `TRUE`.
#'
#' @details
#' Die folgenden Prüfungen werden durchgeführt:
#' 1. Nur korrektes Semikolon " ; " oder kein Semikolon.
#' 2. Kein "|" enthalten.
#' 3. Kein ">" enthalten.
#' 4. Länge der Zeichenkette ist kleiner oder gleich 1000.
#' 5. Keine überflüssigen Leerzeichen (entspricht `stringr::str_squish()`).
#' 6. Warnung bei Abschluss-Begriffen (z. B. Bachelor, Master, Diplom).
#'
#' @return Ein `pointblank`-Agent-Objekt (invisible). Über
#'   `pointblank::get_agent_report()` kann der Report auch separat erzeugt werden.
#'
#'
#' @import pointblank
#' @importFrom rlang ensym as_string
#' @importFrom dplyr mutate group_by summarise n arrange filter left_join n_distinct row_number
#' @importFrom stringr str_squish str_split str_trim
#' @importFrom tidyr unnest
#' @export
check_organisation <- function(data, organisation_col = "organisation",
                              semester_col = "semester", stop_at = 1, show_report = TRUE) {
  stopifnot(is.data.frame(data))
  col <- rlang::ensym(organisation_col)
  semester_sym <- rlang::ensym(semester_col)

  # Standard-Action-Levels
  act_fail <- pointblank::action_levels(stop_at = stop_at)
  act_warn <- pointblank::action_levels(warn_at = stop_at)

  agent <- pointblank::create_agent(
    tbl = data,
    tbl_name = "Organisation",
    label = "Organisation-Check",
    actions = pointblank::action_levels(
      warn_at = stop_at,
      stop_at = stop_at
    )
  ) |>

    # 1) Nur korrektes Semikolon " ; " oder kein Semikolon, NAs sind erlaubt
    pointblank::col_vals_regex(
      columns = !!col,
      regex   = "^(?:[^;]*(?:\\s;\\s))*[^;]*$",
      actions = act_fail,
      step_id = "separator_check",
      label   = "separator_check",
      na_pass = TRUE
    ) |>

    # 2) Kein "|" enthalten
    pointblank::col_vals_regex(
      columns = !!col,
      regex   = "^[^|]*$",
      actions = act_fail,
      step_id = "or_check",
      label   = "or_check",
      na_pass = TRUE
    ) |>

    # 3) Kein ">" enthalten
    pointblank::col_vals_regex(
      columns = !!col,
      regex   = "^[^>]*$",
      actions = act_fail,
      step_id = "greater_check",
      label   = "greater_check",
      na_pass = TRUE
    ) |>

    # 4) Laenge <= 1000
    pointblank::col_vals_between(
      columns = .nchar_org,
      left = 0, right = 1000,
      preconditions = function(x) dplyr::mutate(x, .nchar_org = nchar(!!col)),
      actions = act_warn,
      step_id = "length_check",
      label   = "length_check",
      na_pass = TRUE
    ) |>

    # 5) Keine ueberfluessigen Leerzeichen
    pointblank::col_vals_expr(
      expr = ~ organisation == .squished,
      preconditions = function(x) {
        dplyr::mutate(x, .squished = stringr::str_squish(x[[rlang::as_string(col)]]))
      },
      actions = act_fail,
      step_id = "squished_check",
      label   = "squished_check",
      na_pass = TRUE
    ) |>

    # 6) Warnung bei Master/Bachelor-Begriffen
    pointblank::col_vals_expr(
      expr = ~ !stringr::str_detect(
        organisation,
        stringr::regex(
          "(?<!\\p{L})(Bachelor|Master|Diplom|B\\.A|M\\.A)(?!\\p{L})",
          ignore_case = TRUE
        )
      ),
      actions = act_warn,
      step_id = "non_orga_check",
      label   = "non_orga_check",
      na_pass = TRUE
    ) |>
    pointblank::interrogate()

  return(agent)
}

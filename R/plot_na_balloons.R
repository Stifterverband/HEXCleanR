#' Visualisiert relative fehlende Werte pro Variable und Gruppierung als Balloon Plot
#'
#' Die Funktion zaehlt fehlende Werte (`NA`) pro Variable und Gruppierung und
#' setzt diese ins Verhaeltnis zur Gruppengroesse. Die Kreisgroesse und -farbe
#' kodieren den Anteil fehlender Werte, optional werden die Prozentwerte als Text
#' in den Kreisen angezeigt. List-Spalten werden vor der Umformung automatisch
#' ausgeschlossen.
#'
#' @param data Ein `data.frame` oder `tibble` mit den zu analysierenden Daten.
#' @param grp_var Unquotierter Spaltenname mit der Gruppierungsvariable.
#'   Standardmaessig wird `semester` verwendet.
#' @param title Titel des Plots.
#' @param max_size Maximale Punktgroesse fuer die Groessenskalierung.
#' @param low_fill Farbe fuer niedrige NA-Anteile.
#' @param high_fill Farbe fuer hohe NA-Anteile.
#' @param show_labels Logisch; wenn `TRUE`, werden Werte groesser 0 als Prozentwert im
#'   Punkt angezeigt. Standardmaessig werden keine Zahlen eingeblendet.
#' @param print_table Logisch; wenn `TRUE`, wird die aggregierte NA-Tabelle
#'   sortiert in der Konsole ausgegeben. Standardmaessig ist dies deaktiviert
#'   und erfolgt nur auf expliziten Befehl.
#'
#' @return Ein `ggplot`-Objekt.
#' @importFrom dplyr group_by summarise filter
#' @importFrom ggplot2 aes element_line element_text geom_point geom_text guide_colourbar guide_legend guides labs scale_fill_gradient scale_size_continuous theme theme_minimal
#' @importFrom rlang enquo as_name sym quo_is_null
#' @importFrom tidyr pivot_longer
#' @export
plot_na_balloons <- function(
  data,
  grp_var = NULL,
  title = "Anteil fehlender Zeilen pro Variable und Semester",
  max_size = 18,
  low_fill = "#ffffff",
  high_fill = "#e20000",
  show_labels = FALSE,
  print_table = FALSE
) {
  stopifnot(is.data.frame(data))

  if (rlang::quo_is_null(rlang::enquo(grp_var))) {
    grp_var_quo <- rlang::sym("semester")
  } else {
    grp_var_quo <- rlang::enquo(grp_var)
  }

  grp_var_name <- rlang::as_name(grp_var_quo)

  if (!grp_var_name %in% names(data)) {
    stop("Die angegebene Gruppierungs-Spalte existiert nicht in `data`.", call. = FALSE)
  }

  plot_data <- data |>
    dplyr::select(!dplyr::where(base::is.list))

  if (!grp_var_name %in% names(plot_data)) {
    stop(
      "Die angegebene Gruppierungs-Spalte ist eine List-Spalte und kann nicht geplottet werden.",
      call. = FALSE
    )
  }

  na_long <- plot_data |>
    tidyr::pivot_longer(
      cols = -!!grp_var_quo,
      names_to = "variable",
      values_to = "wert"
    ) |>
    dplyr::group_by(!!grp_var_quo, variable) |>
    dplyr::summarise(
      n_group = dplyr::n(),
      n_na = sum(is.na(wert)),
      prop_na = .data$n_na / .data$n_group,
      .groups = "drop"
    )

  na_table <- na_long |>
    dplyr::arrange(.data[[grp_var_name]], dplyr::desc(.data$prop_na), .data$variable)

  if (isTRUE(print_table)) {
    print(na_table, n = nrow(na_table))
  }

  p <- ggplot2::ggplot(
    na_table,
    ggplot2::aes(x = !!grp_var_quo, y = .data$variable)
  ) +
    ggplot2::geom_point(
      ggplot2::aes(size = .data$prop_na, fill = .data$prop_na),
      shape = 21,
      colour = "black",
      stroke = 0.25,
      alpha = 0.75
    ) +
    ggplot2::scale_size_continuous(
      range = c(1.5, max_size),
      name = "Anteil NA",
      labels = function(x) paste0(round(x * 100, 1), "%")
    ) +
    ggplot2::scale_fill_gradient(
      low = low_fill,
      high = high_fill,
      name = "Anteil NA",
      labels = function(x) paste0(round(x * 100, 1), "%")
    ) +
    ggplot2::labs(
      title = title,
      x = grp_var_name,
      y = NULL
    ) +
    ggplot2::theme_minimal(base_size = 12) +
    ggplot2::theme(
      axis.text.x = ggplot2::element_text(angle = 45, hjust = 1),
      panel.grid.major = ggplot2::element_line(colour = "grey92"),
      plot.title = ggplot2::element_text(face = "bold"),
      legend.position = "right"
    ) +
    ggplot2::guides(
      size = ggplot2::guide_legend(override.aes = list(fill = "#ffffff")),
      fill = ggplot2::guide_colourbar()
    )

  if (isTRUE(show_labels)) {
    p <- p +
      ggplot2::geom_text(
        data = dplyr::filter(na_table, .data$prop_na > 0),
        ggplot2::aes(label = paste0(round(.data$prop_na * 100, 1), "%")),
        size = 3.5,
        colour = "white",
        fontface = "bold"
      )
  }

  p
}

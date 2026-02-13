#' Visualisiert NA-Konzentration nach Semester
#'
#' Erzeugt einen Plot mit der NA-Konzentration pro Variable und sortiert die
#' Semester-Faktoren nach der darin enthaltenen vierstelligen Jahreszahl. Falls
#' keine vierstellige Jahreszahl in der angegebenen Spalte gefunden wird,
#' bricht die Funktion mit einer aussagekräftigen Fehlermeldung ab.
#'
#' @param data Ein data.frame oder tibble mit den zu analysierenden Daten.
#' @param semester Unquoted Spaltenname mit Semester-Informationen (z.B. `WS 2019/20` oder `2019`).
#' @return Ein `ggplot`-Objekt mit der Visualisierung der NA-Konzentration.
#' @importFrom magrittr %>%
#' @importFrom dplyr mutate across where pull
#' @importFrom rlang enquo as_name
#' @importFrom stringr str_detect str_extract
#' @importFrom naniar gg_miss_fct
#' @importFrom ggplot2 scale_fill_gradient coord_flip theme_minimal labs theme element_blank element_text
#' @importFrom stats reorder
#' @export
check_nas <- function(data, semester) {

  # Validierung: mindestens ein vierstelliges Jahr in der angegebenen Spalte vorhanden?
  sem_quo <- rlang::enquo(semester)
  sem_name <- rlang::as_name(sem_quo)
  sem_vals <- data %>% dplyr::pull(!!sem_quo) %>% base::as.character()
  if (!any(stringr::str_detect(sem_vals, "\\d{4}"))) {
    stop(paste0("Spalte '", sem_name, "' enthält keine vierstellige Jahreszahl. Bitte übergebe eine Spalte mit Jahresangaben wie '2019' oder 'WS 2019/20' für die Sortierung."), call. = FALSE)
  }

  # 1. Daten-Vorbereitung: Listen ersetzen und nur nach Jahr sortieren
  data_clean <- data %>%
    dplyr::mutate(dplyr::across(dplyr::where(base::is.list), ~ base::sapply(.x, function(el) {
      if (base::length(el) == 0) return(NA_character_)
      return("Inhalt")
    }))) %>%
    dplyr::mutate(
      # Extrahiert nur die erste vierstellige Zahl (das Jahr)
      temp_jahr = base::as.numeric(stringr::str_extract({{semester}}, "\\d{4}")),
      # Wandelt das Semester in einen Factor um, basierend auf der Jahreszahl
      {{semester}} := stats::reorder({{semester}}, temp_jahr)
    )
  
  # 2. Plot erstellen
  naniar::gg_miss_fct(data_clean, fct = {{semester}}) +
    ggplot2::scale_fill_gradient(low = "#00ff6a", high = "#ff1900", name = "% NA") +
    ggplot2::coord_flip() +
    ggplot2::theme_minimal(base_size = 12) +
    ggplot2::labs(
      title = "NA-Konzentration nach Semester und Variable",
      subtitle = "Rot: 100% NA, Grün: 0% NA",
      x = "Semester",
      y = "Variablen"
    ) +
    ggplot2::theme(
      panel.grid.major = ggplot2::element_blank(),
      axis.text.y = ggplot2::element_text(size = 7)
    )
}
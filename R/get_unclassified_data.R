#' Filtert unklassifizierte Kursdaten aus der `db_data_universitaet_<uni_name>.rds`
#'
#' Diese Funktion vergleicht aktuelle Scraping-Daten mit
#' `db_data_universitaet_<uni_name>.rds` und gibt alle Zeilen aus den aktuellen
#' Scraping-Daten zurueck, die noch keiner der definierten Kategorien
#' zugeordnet wurden. Die Identifikation erfolgt ueber 1 bis 3 Schluesselvariablen.
#'
#' @param raw_data Ein `data.frame` mit den Rohdaten, die klassifiziert werden sollen.
#' @param db_data_path Pfad zu einer RDS-Datei mit den bereits klassifizierten Daten (optional).
#' @param key_vars Ein Vektor mit 1 bis 3 Spaltennamen, die als Schluessel fuer den Abgleich dienen
#'   (Standard: `c("titel", "nummer")`).
#'
#' @return Ein `data.frame` mit den Zeilen aus `raw_data`, die noch nicht klassifiziert wurden.
#'   Enthaelt die Schluesselvariablen, `kursbeschreibung` und `lernziele`.
#'
#' @details
#' Die Funktion prueft, ob fuer jede Zeile in `raw_data` keine Klassifizierung in den Spalten
#' `data_analytics_ki`, `softwareentwicklung`, `nutzerzentriertes_design`,
#' `it_architektur`, `hardware_robotikentwicklung` und `quantencomputing` vorliegt.
#' Wenn `db_data_path` `NULL` ist oder die Datei nicht existiert, werden alle Zeilen aus
#' `raw_data` als unklassifiziert zurueckgegeben.
#'
#'
#' @importFrom dplyr select all_of distinct left_join filter across
#' @keywords internal
 get_unclassified_data <- function(raw_data, db_data_path, key_vars = c("titel", "nummer")) {
  # Sicherstellen, dass 1-3 Key-Variablen angegeben sind
  if (length(key_vars) < 1 || length(key_vars) > 3) {
    stop("Es muessen mindestens 1 und hoechstens 3 Key-Variablen angegeben werden.")
  }
  
  # Wenn keine DB existiert, alle Daten als unklassifiziert zurückgeben
  if (is.null(db_data_path) || !file.exists(db_data_path)) {
    return(raw_data |>
      dplyr::select(dplyr::all_of(key_vars), kursbeschreibung, lernziele))
  }
  
  # Klassifizierte Daten laden und nur relevante Spalten nehmen
  classified_data <- readRDS(db_data_path) |>
    dplyr::select(
      dplyr::all_of(key_vars),
      data_analytics_ki,
      softwareentwicklung,
      nutzerzentriertes_design,
      it_architektur,
      hardware_robotikentwicklung,
      quantencomputing
    ) |>
    dplyr::distinct(dplyr::across(dplyr::all_of(key_vars)), .keep_all = TRUE)
  
  # Join mit den Rohdaten ueber die Key-Variablen
  raw_data_join <- raw_data |>
    dplyr::left_join(classified_data, by = key_vars)
  
  # Nur nicht klassifizierte Zeilen filtern
  raw_data_to_classify <- raw_data_join |>
    dplyr::filter(
      is.na(data_analytics_ki) &
      is.na(softwareentwicklung) &
      is.na(nutzerzentriertes_design) &
      is.na(it_architektur) &
      is.na(hardware_robotikentwicklung) &
      is.na(quantencomputing)
    ) |>
    dplyr::select(dplyr::all_of(key_vars), kursbeschreibung, lernziele)
  
  return(raw_data_to_classify)
}
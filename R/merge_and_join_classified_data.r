#' Merge old + new classified data and join fixed classification vars to base data
#'
#' Lädt bestehende Klassifizierungsdaten, kombiniert sie mit neuen Klassifizierungen
#' (ohne Duplikate), reduziert auf die festen Klassifizierungsspalten und merged
#' das Ergebnis per left_join an die Rohdaten.
#'
#' @param raw_data Ein data.frame mit allen Rohdaten.
#' @param db_data_path Pfad zur bestehenden RDS-Datei mit bereits klassifizierten Daten (optional).
#' @param new_classified_data Ein data.frame mit neu klassifizierten Daten.
#' @param key_vars Ein Vektor mit Spaltennamen für den Join (Default: c("titel","nummer")).
#'
#' @return Ein data.frame mit allen Rohdaten inkl. den Klassifizierungsspalten.
#' @keywords internal
merge_and_join_classified_data <- function(raw_data,
                                          db_data_path,
                                          new_classified_data,
                                          key_vars = c("titel", "nummer")) {
  

  # 1. Die Klassifizierungsspalten sind fest definiert
  class_vars <- c(
    "data_analytics_ki",
    "softwareentwicklung",
    "nutzerzentriertes_design",
    "it_architektur",
    "hardware_robotikentwicklung",
    "quantencomputing"
  )
  
  # 2. Alte Klassifizierungen laden (wenn vorhanden)
  if (is.null(db_data_path) || !file.exists(db_data_path)) {
    message("Keine bestehende Klassifizierungsdatei gefunden.")
    db_classified <- NULL
  } else {
    db_classified <- readRDS(db_data_path)
  }
  
  # 3. Alte + neue zusammenfuehren, doppelte Keys entfernen
  if (is.null(db_classified)) {
    combined_classified <- new_classified_data
  } else {
    combined_classified <- dplyr::bind_rows(db_classified, new_classified_data)
  }
  combined_classified <- combined_classified |>
    dplyr::distinct(dplyr::across(dplyr::all_of(key_vars)), .keep_all = TRUE)
  
  # 4. Nur Join-Keys + die Klassifizierungsspalten behalten
  combined_reduced <- combined_classified |>
    dplyr::select(dplyr::all_of(c(key_vars, class_vars)))
  
  # 5. Mit Rohdaten joinen
  result <- raw_data |>
    dplyr::left_join(combined_reduced, by = key_vars)
     
  return(result)
}
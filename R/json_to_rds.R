##' Konvertiert eine JSON-Datei in ein RDS-Format
##'
##' Diese Funktion liest eine JSON-Datei ein, wandelt sie in ein Tibble um und speichert das Ergebnis als RDS-Datei.
##'
##' @param input_path Pfad zur Eingabe-JSON-Datei.
##' @param output_path Pfad zur Ausgabedatei im RDS-Format.
##' @return Das eingelesene Tibble.
##' @importFrom jsonlite fromJSON
##' @importFrom tibble as_tibble
##' @importFrom readr write_rds
json_to_rds <- function(input_path, output_path) {
  # Validierung: Prüfen, ob die Quelldatei existiert
  if (!file.exists(input_path)) {
    stop("Die angegebene JSON-Datei wurde nicht gefunden.")
  }
  
  # Daten einlesen und umwandeln
  df_r <- jsonlite::fromJSON(input_path) %>% 
    tibble::as_tibble()

  # Als RDS speichern
  readr::write_rds(df_r, output_path)
  
  # Kurze Bestätigung in der Konsole
  message(paste("Datei erfolgreich gespeichert unter:", output_path))
  
  # Rückgabe des Tibbles (optional, für direktes Weiterarbeiten)
  return(df_r)
}

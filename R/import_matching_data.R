#' Lädt das aktuellste Matching-`.rds`-File aus dem `Matching`-Ordner der
#' angegebenen Universität (lokal in OneDrive) und merged die relevanten Matching-Felder mit `scraped_daten`.
#' und merged die relevanten Matching-Felder mit `scraped_daten`. Wenn kein
#' passendes Matching vorhanden ist oder die Matching-Daten nicht LUF-
#' optimiert sind, wird `scraped_daten` unverändert zurückgegeben.
#'
#' @param scraped_daten Data frame mit gescrapten Daten. Erwartet mindestens
#'   die Spalten `jahr`, `semester` und `organisation`.
#' @param uni_ordner_name Character. Name des Universitätsordners innerhalb der
#'   `single_universities`-Struktur.
##' Hinweis: Die Funktion lädt Matching-Dateien aus dem lokalen OneDrive.
#' @return Data frame. `scraped_daten` mit angehängten Matching-Feldern
#'   (`matchingart`, `lehr_und_forschungsbereich`, `studienbereich`,
#'   `faechergruppe`, `luf_code`, `stub_code`, `fg_code`). Bei fehlendem oder
#'   ungeeignetem Matching werden die unveränderten `scraped_daten`
#'   zurückgegeben.
#' @details
#' - Es wird das jüngste `.rds`-File im `Matching`-Ordner verwendet.
#' - Die Matching-Daten müssen die Spalte `gerit_luf` enthalten.
#' - Organisationseinträge mit mehreren Namen werden anhand von " ; "
#'   getrennt und entsprechend behandelt.
#' @export
import_matching_data <- function(scraped_daten, 
                                uni_ordner_name) {
  
  # --- 1) Pfad & Datei-Setup ---
  # Wir bauen den lokalen OneDrive-Pfad zur Matching-Ordnerstruktur zusammen.
  # Erwartet wird: OneDrive - Stifterverband/Dateiablage - single_universities/<uni>/Matching
  # -> später suchen wir in diesem Ordner nach .rds-Matching-Dateien.
  benutzer <- Sys.getenv("USERNAME")
  basis_pfad <- path("C:", "Users", benutzer, "OneDrive - Stifterverband", 
                    "Dateiablage - single_universities", uni_ordner_name, "Matching")

  # --- 2) Suche nach Matching-Dateien ---
  # Listet alle Dateien im Matching-Ordner, filtert auf .rds (unabhängig von Groß-/Kleinschreibung)
  # und sortiert absteigend nach Änderungszeit, damit wir das aktuellste File verwenden.
  df_matching_info <- dir_info(basis_pfad) %>%
    filter(type == "file", str_detect(path, "(?i)\\.rds$")) %>%
    arrange(desc(modification_time)) %>%
    mutate(name_of_matching_file = basename(path))

  # Wenn kein Matching-File gefunden wurde: Funktion abbrechen und Originaldaten zurückgeben.
  if (nrow(df_matching_info) == 0) {
    message("Es konnten keine Matching Daten gefunden werden. Dataframe wird unverändert ausgegeben.")
    return(scraped_daten)
  }

  # Nimm das jüngste Matching-File (erste Zeile nach Sortierung) und lade es.
  matching_info <- df_matching_info[1,]
  # `ref_raw` enthält die rohe Matching-Referenz; Spaltennamen in Kleinbuchstaben konvertieren
  ref_raw <- readRDS(matching_info$path) %>% rename_with(tolower)

  # Prüfen, ob die erwartete LUF-Spalte vorhanden ist. Falls nicht, ist das Matching
  # noch nicht 'LUF-optimiert' und wir brechen ab, um keine falschen Zuordnungen zu erzeugen.
  if (!"gerit_luf" %in% names(ref_raw)) {
    message("Matching-Daten sind noch nicht LUF-optimiert. Dataframe wird unverändert ausgegeben.")
    return(scraped_daten)
  }

  # --- 3) Semester-Logik ---
  # Ziel: Ermitteln, bis zu welchem Jahr/Semester die gescrapten Daten vorliegen,
  # um Informationen aus dem Matching (z.B. latest_year) gegenüberzustellen.
  df_temp <- scraped_daten
  colnames(df_temp) <- tolower(colnames(df_temp))

  # Bestimme das aktuellste Jahr in den gescrapten Daten
  most_recent_scraped_year <- max(as.numeric(df_temp$jahr), na.rm = TRUE)

  # Bestimme, ob im aktuellsten Jahr ein Wintersemester vorliegt:

  most_recent_scraped_semester <- df_temp %>%
    filter(as.numeric(jahr) == most_recent_scraped_year) %>%
    pull(semester) %>%
    unique() %>%
    str_to_lower() %>%
    str_trim() %>%
    {if (any(str_detect(., "w"))) "w" else "s"}

  # Informiere über Abdeckung der gescrapten vs. gematchten Daten
  message(paste("Die gescrapten Daten gehen bis", most_recent_scraped_semester, most_recent_scraped_year, ".",
                "Die gematcheden Daten geben bis", ref_raw$semester_in_latest_year[1], ref_raw$latest_year[1], "." ))

  # Warnung, falls das Matching noch in einer frühen Kodierungsphase ist
  if(ref_raw$this_matching_is[1] %in% c("erstkodierung", "zweitkodierung")) {
    warning("Die Daten wurden noch nicht zweitkodiert und zusammengeführt. Sicher, dass du das Matching anspielen willst?")
  }

  # --- 4) Matching-Referenz aufbereiten ---
  # Wir wählen nur die für das Merge relevanten Felder aus und bereiten eine
  # `join_id` vor. Die `organisation_names_for_matching_back` kann mehrere
  # Namen enthalten, getrennt durch ' ; ' — diese werden getrimmt und wieder
  # zusammengefügt, damit der Join konsistent funktioniert.
  df_matched_clean <- ref_raw %>%
    select(
      matchingart = match_type,
      org_name_raw = organisation_names_for_matching_back,
      lehr_und_forschungsbereich = gerit_luf,
      studienbereich = gerit_studienbereich,
      faechergruppe = gerit_faechergruppe,
      luf_code, stub_code, fg_code
    ) %>%
    # Erzeuge eine standardisierte Join-ID aus den Roh-Organisationsnamen
    mutate(join_id = map_chr(org_name_raw, ~ {
      str_split(.x, " ; ") %>% unlist() %>% str_trim() %>% str_c(collapse = " ; ")
    })) %>%
    # Duplikate nach Join-ID entfernen (erstes Vorkommen behalten)
    distinct(join_id, .keep_all = TRUE) %>%
    # Filtere Einträge, die bewusst als 'not_matchable' markiert wurden
    filter(matchingart != "not_matchable")

  # --- 5) Zusammenführen (Merge) ---
  # Ablauf:
  # 1) Entferne bereits vorhandene Matching-Spalten aus den Quelldaten, damit
  #    sie nicht verloren oder überschrieben werden.
  # 2) Erzeuge in den Quelldaten dieselbe `join_id`-Logik wie in der Referenz.
  # 3) `left_join`: alle gescrapten Zeilen behalten, Matching-Felder ergänzen,
  #    wenn ein Treffer vorliegt.
  # 4) Aufräumen: temporäre Hilfsspalten entfernen.
  df_merged <- scraped_daten %>%
    select(-any_of(c("lehr_und_forschungsbereich", "studienbereich", "faechergruppe", 
                    "luf_code", "stub_code", "fg_code", "matchingart"))) %>%
    mutate(join_id = map_chr(organisation, ~ {
      str_split(.x, " ; ") %>% unlist() %>% str_trim() %>% str_c(collapse = " ; ")
    })) %>%
    left_join(df_matched_clean, by = "join_id") %>%
    select(-join_id, -org_name_raw)

  message("Matching Daten erfolgreich angespielt.")
  return(df_merged)
}
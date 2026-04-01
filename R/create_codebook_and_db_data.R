#' Erstellt `codebook` und `db_data` aus Rohdaten
#'
#' Diese Funktion bildet einen typischen Schritt im HEX-Cleaning ab: Aus
#' `raw_data` wird ein `codebook` mit den vorhandenen Variablennamen erzeugt und
#' daraus anschliessend ein `db_data`-Datensatz im erwarteten HEX-Format
#' aufgebaut. Die benoetigten Spalten in `raw_data` und `raw_data_fs` muessen
#' vollstaendig vorhanden sein. Nur die fachlichen Metadatenfelder, die erst
#' spaeter im Prozess befuellt werden, werden mit `NA` angelegt.
#'
#' @param raw_data Data Frame mit den Rohdaten.
#' @param raw_data_fs Data Frame mit Future-Skills-Spalten.
#'
#' @return Eine Liste mit zwei Elementen:
#'   \describe{
#'     \item{codebook}{Ein Tibble mit einer Spalte `Variablen`.}
#'     \item{db_data}{Ein Tibble im erwarteten HEX-DB-Format.}
#'   }
#'
#' @examples
#' raw_data <- tibble::tibble(
#'   anmerkungen = "Hinweis",
#'   dozierende = "Prof. Beispiel",
#'   ects = "5",
#'   fakultaet = "Informatik",
#'   hochschule = "Universitaet Musterstadt",
#'   hochschule_kurz = "UMS",
#'   jahr = "2026",
#'   kursbeschreibung = "Dies ist eine ausreichend lange Kursbeschreibung.",
#'   kursformat_original = "Vorlesung",
#'   kursformat_recoded = "Vorlesung",
#'   lehrtyp = "Pflicht",
#'   lernmethode = "Praesenz",
#'   lernziele = "Lernziel",
#'   literatur = "Buch",
#'   module = "Modul A",
#'   nummer = "101",
#'   organisation_orig = "Original",
#'   organisation = "Organisation",
#'   pfad = "/tmp/pfad",
#'   pruefung = "Klausur",
#'   scrape_datum = "2026-04-01",
#'   semester = "2026s",
#'   sprache_original = "Deutsch",
#'   sprache_recoded = "Deutsch",
#'   studiengaenge = "BSc",
#'   sws = "2",
#'   teilnehmerzahl = "30",
#'   titel = "Kurs A",
#'   url = "https://example.org",
#'   voraussetzungen = "Keine",
#'   zusatzinformationen = "Info",
#'   institut = "Institut A"
#' )
#'
#' raw_data_fs <- tibble::tibble(
#'   data_analytics_ki = 1,
#'   softwareentwicklung = 0,
#'   nutzerzentriertes_design = 0,
#'   it_architektur = 1,
#'   hardware_robotikentwicklung = 0,
#'   quantencomputing = 0
#' )
#'
#' res <- create_codebook_and_db_data(raw_data, raw_data_fs)
#' res$codebook
#' res$db_data
#'
#' @importFrom tibble tibble as_tibble
#' @export
create_codebook_and_db_data <- function(raw_data, raw_data_fs = NULL) {
  if (missing(raw_data) || !is.data.frame(raw_data)) {
    stop("`raw_data` muss als Data Frame uebergeben werden.", call. = FALSE)
  }

  if (missing(raw_data_fs) || is.null(raw_data_fs) || !is.data.frame(raw_data_fs)) {
    stop("`raw_data_fs` muss als Data Frame uebergeben werden.", call. = FALSE)
  }

  raw_data <- tibble::as_tibble(raw_data)
  raw_data_fs <- tibble::as_tibble(raw_data_fs)

  if (nrow(raw_data_fs) != nrow(raw_data)) {
    stop(
      "`raw_data_fs` muss dieselbe Anzahl an Zeilen wie `raw_data` haben.",
      call. = FALSE
    )
  }

  character_cols <- c(
    "anmerkungen", "dozierende", "ects", "fakultaet", "hochschule",
    "hochschule_kurz", "jahr", "kursbeschreibung", "kursformat_original",
    "kursformat_recoded", "lehrtyp", "lernmethode", "lernziele", "literatur",
    "module", "nummer", "organisation_orig", "organisation", "pfad",
    "pruefung", "scrape_datum", "semester", "sprache_original",
    "sprache_recoded", "studiengaenge", "sws", "teilnehmerzahl", "titel",
    "url", "voraussetzungen", "zusatzinformationen", "institut"
  )

  fs_cols <- c(
    "data_analytics_ki",
    "softwareentwicklung",
    "nutzerzentriertes_design",
    "it_architektur",
    "hardware_robotikentwicklung",
    "quantencomputing"
  )

  missing_raw_cols <- setdiff(character_cols, names(raw_data))
  if (length(missing_raw_cols) > 0) {
    stop(
      paste0(
        "`raw_data` fehlen folgende benoetigte Spalten: ",
        paste(missing_raw_cols, collapse = ", ")
      ),
      call. = FALSE
    )
  }

  missing_fs_cols <- setdiff(fs_cols, names(raw_data_fs))
  if (length(missing_fs_cols) > 0) {
    stop(
      paste0(
        "`raw_data_fs` fehlen folgende benoetigte Spalten: ",
        paste(missing_fs_cols, collapse = ", ")
      ),
      call. = FALSE
    )
  }

  get_chr_col <- function(data, col_name) {
    as.character(data[[col_name]])
  }

  get_num_col <- function(data, col_name) {
    as.numeric(data[[col_name]])
  }

  codebook <- tibble::tibble(Variablen = colnames(raw_data))

  db_data <- tibble::tibble(id = seq_len(nrow(raw_data)))

  for (col_name in character_cols) {
    db_data[[col_name]] <- get_chr_col(raw_data, col_name)
  }

  db_data$kursbeschreibung <- remove_semantic_na_values(
    get_chr_col(raw_data, "kursbeschreibung")
  )

  for (col_name in fs_cols) {
    db_data[[col_name]] <- get_num_col(raw_data_fs, col_name)
  }

  metadata_cols <- c(
    "lehr_und_forschungsbereich",
    "studienbereich",
    "faechergruppe",
    "luf_code",
    "stub_code",
    "fg_code",
    "matchingart"
  )

  for (col_name in metadata_cols) {
    db_data[[col_name]] <- NA_character_
  }

  list(
    codebook = codebook,
    db_data = db_data
  )
}

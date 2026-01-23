#' Klassifiziert Kursdaten mit SetFit-Modell und pflegt neue Labels ein
#'
#' Diese Funktion identifiziert Future-Skills-Schlagwörter in Kursdaten mithilfe
#' eines vortrainierten SetFit-Modells (siehe http://srv-data01:30080/hex/future_skill_classification), das über das
#' reticulate-Paket aus Python heraus aufgerufen wird. Dabei werden zunächst
#' noch nicht klassifizierte Kurse ermittelt, diese im Modell bewertet und die
#' resultierenden Future-Skills-Labels anschließend mit bestehenden
#' Klassifizierungsinformationen aus einem optionalen RDS-Datensatz
#' zusammengeführt.
#'
#' Die Funktion setzt ein funktionierendes Python-/Conda-Environment mit dem
#' entsprechenden SetFit-Modell voraus und erwartet in den Rohdaten mindestens
#' eine sinnvolle Schlüsselvariable (z.B. "titel" oder "nummer") sowie Spalten
#' mit Kursbeschreibung und Lernzielen.
#'
#' @importFrom reticulate use_condaenv py_run_string
#' @importFrom dplyr %>% left_join mutate
#' @importFrom tibble as_tibble
#'
#' @param raw_data Data Frame mit Rohkursdaten; sollte mindestens die Spalten
#'   für die Join-Schlüssel (`key_vars`) sowie, idealerweise, `kursbeschreibung`
#'   und `lernziele` enthalten.
#' @param db_data_path (Optional) Pfad zu einer bestehenden RDS-Datei mit bereits
#'   klassifizierten Kursen. Wenn `NULL` oder nicht vorhanden, werden alle
#'   Zeilen in `raw_data` neu klassifiziert.
#' @param model_path HuggingFace-Modellpfad des SetFit-Modells, das zur
#'   Klassifizierung verwendet werden soll.
#' @param key_vars Zeichenvektor mit den Spaltennamen, die als Join-Keys
#'   verwendet werden (Standard: `c("titel", "nummer")`). Nur vorhandene und
#'   nicht vollständig fehlende Variablen werden verwendet.
#'
#' @return Data Frame mit allen Zeilen von `raw_data` und den ergänzten bzw.
#'   aktualisierten Future-Skills-Klassifikationsspalten.
#'
#' @examples
#' \dontrun{
#'   raw_data_fs <- classify_fs(
#'     raw_data   = raw_data_uni_musterstadt,
#'     db_data_path = "C:/SV/HEX/Scraping/data/single_universities/Friedrich-Schiller-Universitaet_Jena/db_data_musterstadt.RDS", # optional
#'     model_path = "Chernoffface/fs-setfit-multilable-model",
#'     key_vars   = c("titel", "nummer")
#'   )
#' }
#'
#' @export
classify_fs <- function(raw_data,
                        db_data_path = NULL,
                        model_path = "Chernoffface/fs-setfit-multilable-model",
                        key_vars = c("titel", "nummer")) {

  # ============================
  # 0. Key-Variablen validieren und anpassen
  # ============================
  # ----------------------------------------------------------
  # Pruefe, welche Key-Variablen tatsaechlich vorhanden
  # und verwendbar sind. Entferne Variablen, die nicht
  # existieren oder komplett NA sind.
  # ----------------------------------------------------------
  available_vars <- names(raw_data)
  valid_key_vars <- c()
  
  for (var in key_vars) {
    if (var %in% available_vars) {
      # Pruefe, ob die Variable nicht komplett NA ist
      if (!all(is.na(raw_data[[var]]))) {
        valid_key_vars <- c(valid_key_vars, var)
      } else {
        message(paste0("⚠️  Variable '", var, "' ist komplett NA und wird aus key_vars entfernt."))
      }
    } else {
      message(paste0("⚠️  Variable '", var, "' existiert nicht in raw_data und wird aus key_vars entfernt."))
    }
  }
  
  # Mindestens eine Key-Variable muss vorhanden sein
  if (length(valid_key_vars) == 0) {
    stop("Keine gueltigen Key-Variablen gefunden. Mindestens eine Variable muss vorhanden und nicht komplett NA sein.")
  }
  
  # Verwende die validierten Key-Variablen
  key_vars <- valid_key_vars
  message(paste0("🔑 Verwendete Key-Variablen: ", paste(key_vars, collapse = ", ")))

  # ============================
  # 1. Unklassifizierte Daten sammeln
  # ============================
  if (is.null(db_data_path) || !file.exists(db_data_path)) {
    message("🔍 Keine bestehende Klassifizierungsdatei gefunden - alle Daten werden klassifiziert.")
    unclassified_data <- raw_data |>
      dplyr::select(dplyr::all_of(key_vars), kursbeschreibung, lernziele)
  } else {
    message("🔍 Sammle noch nicht klassifizierte Daten aus DB")
    unclassified_data <- get_unclassified_data(raw_data, db_data_path, key_vars = key_vars)
  }
  message(paste0("🔢 Anzahl unklassifizierter Zeilen: ", nrow(unclassified_data)))

  # ============================
  # 2. Prüfen, ob Klassifizierung notwendig ist
  # ============================
  if (nrow(unclassified_data) == 0) {
    message("🚫 Keine unklassifizierten Daten gefunden - kombiniere bestehende Klassifizierungen mit den Rohdaten.")

    if (is.null(db_data_path) || !file.exists(db_data_path)) {
      warning("Keine bestehende Klassifizierungsdatei gefunden. Gebe Rohdaten unverändert zurück.")
      return(raw_data)
    }

    class_vars <- c(
      "data_analytics_ki",
      "softwareentwicklung",
      "nutzerzentriertes_design",
      "it_architektur",
      "hardware_robotikentwicklung",
      "quantencomputing"
    )

    existing_classified <- readRDS(db_data_path) |>
      dplyr::select(dplyr::all_of(c(key_vars, class_vars))) |>
      dplyr::distinct(dplyr::across(dplyr::all_of(key_vars)), .keep_all = TRUE)

    result <- raw_data |>
      dplyr::left_join(existing_classified, by = key_vars)

    return(result)
  }

  message("⏰ Der Klassifizierungsprozess kann je nach Anzahl der unklassifizierten Daten einen Moment dauern.")
  Sys.sleep(2)
  message("☕ Trinken Sie derweil bitte einen Kaffee!")

  # ============================
  # 3. Python-Environment für SetFit-Modell setzen
  # ============================
  message("⚙️  Definiere Environment für SetFit-Modell")
  if (Sys.getenv("RETICULATE_MINICONDA_PATH") == "") {
    Sys.setenv(
      RETICULATE_MINICONDA_PATH = file.path("C:/Users", Sys.getenv("USERNAME"), "AppData/Local/miniconda3")
    )
    message("🔧 RETICULATE_MINICONDA_PATH wurde gesetzt.")
  } else {
    message("ℹ️  RETICULATE_MINICONDA_PATH ist bereits gesetzt.")
  }

  # Environment aktivieren
  reticulate::use_condaenv("classify_fs", required = TRUE)

  # ============================
  # 4. Python-Funktion für Klassifizierung definieren
  # ============================
  message("📝 Definiere `process_and_predict`-Funktion")
  process_and_predict <- reticulate::py_run_string("
from tqdm import tqdm
import pandas as pd
from setfit import SetFitModel
import warnings

warnings.filterwarnings('ignore')

def process_and_predict(df, model_path, fs_labels):
    tqdm.pandas()

    # Index in Strings umwandeln (um FutureWarning zu vermeiden)
    df.index = df.index.astype(str)

    # 1. NAs durch leere Strings ersetzen
    for col in ['titel', 'kursbeschreibung', 'lernziele']:
        df[col] = df[col].fillna('')

    # 2. Satz erstellen
    df['sentence'] = df.apply(
        lambda row: row['titel']
            + (': ' + row['kursbeschreibung'] if row['kursbeschreibung'] else '')
            + ('. Lernziele: ' + row['lernziele'] if row['lernziele'] else ''),
        axis=1
    )

    # 3. Modell laden
    model = SetFitModel.from_pretrained(model_path)

    # 4. Praediktion durchfuehren
    def predict_course_description(description):
        if isinstance(description, str):
            preds = model(description)
            return preds
        return []

    df['Pred_Tensor'] = df['sentence'].progress_apply(predict_course_description)

    # 5. Tensor in Labels umwandeln
    def convert_tensor_to_labels(tensor):
        if isinstance(tensor, float) and pd.isna(tensor):
            return None
        if len(tensor) != len(fs_labels):
            print(f'Warnung: Unerwartete Tensorgroeße {len(tensor)}, erwartet: {len(fs_labels)}')
            return 'Fehlerhafte Vorhersage'
        selected_labels = [fs_labels[i] for i, val in enumerate(tensor) if val == 1]
        return ', '.join(selected_labels) if selected_labels else None

    # nur ein Balken beim Vorhersageschritt
    df['FS_Skill'] = df['Pred_Tensor'].apply(lambda x: convert_tensor_to_labels(x))

    # 6. Dummy-Variablen fuer FS erstellen
    for label in fs_labels:
        df[label] = df['FS_Skill'].apply(lambda x: 1 if isinstance(x, str) and label in x else 0)

    # 7. Entferne die Hilfsspalten
    df = df.drop(columns=['sentence', 'Pred_Tensor', 'FS_Skill'])

    return df
")$process_and_predict

  # ============================
  # 5. Future Skills Labels definieren
  # ============================
  message("🏷️ Definiere Future Skills Labels")
  fs_labels <- c(
    "data_analytics_ki",
    "softwareentwicklung",
    "nutzerzentriertes_design", 
    "it_architektur",
    "hardware_robotikentwicklung",
    "quantencomputing"
  )

  # ============================
  # 6. R-DataFrame in Python DataFrame umwandeln
  # ============================
  message("🐼 Wandel R-DataFrame in Python DataFrame")
  pd <- reticulate::import("pandas")
  unclassified_data_py <- pd$DataFrame(unclassified_data)

  # ============================
  # 7. Modellpfad setzen (ggf. überschreiben)
  # ============================
  message("🤗 Setze HuggingFace Modellpfad")
  model_path <- "Chernoffface/fs-setfit-multilable-model"

  # ============================
  # 8. Klassifizierung durchführen
  # ============================
  message("🤖 Klassifiziere unklassifizierte Daten")
  classified_data <- process_and_predict(unclassified_data_py, model_path, fs_labels)

  # ============================
  # 9. Ergebnisse mit Rohdaten zusammenführen
  # ============================
  message("\n🔗 Füge klassifizierte Daten zu den Rohdaten hinzu")
  result <- merge_and_join_classified_data(
    raw_data = raw_data,
    db_data_path = db_data_path,
    new_classified_data = classified_data,
    key_vars = key_vars
  )

  message("✅ Klassifizierung abgeschlossen")
  return(result)
}

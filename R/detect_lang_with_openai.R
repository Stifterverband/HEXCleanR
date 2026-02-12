##' Detektiert die Sprache in einer Spalte eines Dataframes mittels OpenAI GPT-API
##'
##' Diese Funktion nutzt die OpenAI GPT-API, um die Sprache von Texten (z. B. Titeln) zu erkennen.
##' Sie arbeitet hocheffizient, indem sie bereits vorhandene Klassifikationen aus einer 
##' Datenbank sowie einem Sicherheits-Export berücksichtigt und nur neue, einzigartige 
##' Texte an die API sendet.
##'
##' Ablauf der Funktion im Detail:
##' 1. Vorhandene Datenquellen: Falls vorhanden, werden Sprach-Klassifikationen aus `db_data_path` 
##'    und `export_path` geladen. Bestehende Werte im Dataframe werden NICHT überschrieben, 
##'    sondern nur fehlende Werte (NAs) ergänzt (Lookup-Logik).
##' 2. Einzigartigkeit: Es werden nur die eindeutigen (unique) Texte extrahiert, die noch 
##'    keinen Wert in `sprache_recoded` besitzen, um API-Kosten zu minimieren.
##' 3. Batch-Verarbeitung: Die Texte werden in Batches an das Modell (gpt-4o-mini) gesendet.
##' 4. Validierung & Sicherheit: Die API-Antworten werden strikt gegen eine Liste erlaubter 
##'    Sprachen geprüft. Halluzinationen oder Fachbegriffe werden als "Sonstiges" gelabelt.
##' 5. Persistenz: Nach jedem Batch wird der Fortschritt sofort in `export_path` gespeichert.
##'
##' @param df Ein Dataframe, der die zu klassifizierende Textspalte enthält.
##' @param spalte Name der Spalte (String), deren Inhalt analysiert werden soll (z. B. "titel").
##' @param db_data_path Pfad zur permanenten RDS-Datenbank mit historischen Klassifikationen.
##' @param export_path Pfad zum Sicherheits-Export (RDS), der den aktuellen Fortschritt speichert. 
##'   Standard ist "db_safety_export.rds".
##' @param batch_size Anzahl der Titel pro API-Abfrage. Standard ist 50.
##'
##' @return Der ursprüngliche Dataframe, ergänzt um die vervollständigte Spalte `sprache_recoded`.
##'
##' @details 
##' Die Funktion nutzt `ellmer::parallel_chat` für hohe Geschwindigkeit und setzt die 
##' Modell-Temperatur auf 0, um die Reproduzierbarkeit zu maximieren und "Kreativität" 
##' der KI zu unterbinden.
##'
##' @export
##' @importFrom ellmer chat_openai parallel_chat
##' @importFrom dplyr select all_of distinct left_join mutate coalesce filter
##' @importFrom purrr map_chr
detect_lang_with_openai <- function(df, spalte, db_data_path, export_path = "db_safety_export.rds", batch_size = 100) {
  
  target_var <- "sprache_recoded"
  
  # Deine definierten Ziel-Kategorien
  valid_langs <- c("Englisch", "Deutsch", "Französisch", "Spanisch", "Italienisch", 
                  "Russisch", "Türkisch", "Portugiesisch", "Niederländisch", "Deutsch/Englisch")
  
  if (!target_var %in% names(df)) df[[target_var]] <- NA_character_
  
  # Hilfsfunktion für sauberen Join (verhindert Zeilenvervielfachung bei Duplikaten)
  safe_join <- function(target_df, lookup_df, join_col, val_col, suffix_name) {
    if (is.null(lookup_df) || nrow(lookup_df) == 0) return(target_df)
    
    lookup_clean <- lookup_df %>%
      dplyr::filter(!is.na(.data[[val_col]])) %>%
      dplyr::distinct(.data[[join_col]], .keep_all = TRUE) %>%
      dplyr::select(dplyr::all_of(c(join_col, val_col)))
    
    target_df %>%
      dplyr::left_join(lookup_clean, by = join_col, suffix = c("", suffix_name)) %>%
      dplyr::mutate(!!val_col := dplyr::coalesce(!!rlang::sym(val_col), !!rlang::sym(paste0(val_col, suffix_name)))) %>%
      dplyr::select(-dplyr::ends_with(suffix_name))
  }

  # 1. Bestehende Datenbank (Original) laden
  if (file.exists(db_data_path)) {
    df <- safe_join(df, readRDS(db_data_path), spalte, target_var, ".db")
  }
  
  # 2. Sicherheits-Export (Fortschritt) laden
  if (file.exists(export_path)) {
    df <- safe_join(df, readRDS(export_path), spalte, target_var, ".safe")
    message("Sicherheits-Export geladen.")
  }
  
  # 3. Offene Titel identifizieren
  unique_titles <- df[[spalte]][is.na(df[[target_var]])] %>% 
    unique() %>% stats::na.omit() %>% .[. != ""]
  
  total_titles <- length(unique_titles)
  if (total_titles == 0) {
    message("Alle Titel sind bereits klassifiziert.")
    return(df)
  }
  
  message(sprintf("Starte Verarbeitung von %d neuen Titeln in %d-er Batches.", total_titles, batch_size))
  
  chat <- ellmer::chat_openai(model = "gpt-4o-mini",
    params = list(temperature = 0)
  )
  allowed_string <- paste(valid_langs, collapse = ", ")
  
  num_batches <- ceiling(total_titles / batch_size)
  
  for (i in 1:num_batches) {
    start_idx <- (i - 1) * batch_size + 1
    end_idx <- min(i * batch_size, total_titles)
    current_batch <- unique_titles[start_idx:end_idx]
    
    message(sprintf("Batch %d/%d (Titel %d-%d)...", i, num_batches, start_idx, end_idx))
    
    # STRIKTER REGEL-PROMPT
    full_prompts <- purrr::map(as.list(current_batch), ~ {
      paste0("Aufgabe: Identifiziere die Sprache des Titels.
      Regel 1: Antworte NUR mit einem Wort aus dieser Liste: [", allowed_string, ", Sonstiges].
      Regel 2: Gib NIEMALS Satzzeichen, Punkte oder Erklärungen aus.
      
      Titel: ", .x)
    })

    tryCatch({
      raw_responses <- ellmer::parallel_chat(chat = chat, prompts = full_prompts)
      
      batch_results <- purrr::map_chr(raw_responses, function(x) {
        # Ergebnis direkt übernehmen und Leerzeichen trimmen
        return(trimws(as.character(x$last_turn()@text)))
      })
      
      new_data <- data.frame(t_c = current_batch, v_c = batch_results, stringsAsFactors = FALSE)
      colnames(new_data) <- c(spalte, target_var)
      
      # 4. In Sicherheits-Export speichern
      if (file.exists(export_path)) {
        current_safe_db <- readRDS(export_path)
        updated_safe_db <- dplyr::bind_rows(current_safe_db, new_data) %>% 
          dplyr::distinct(!!rlang::sym(spalte), .keep_all = TRUE)
        saveRDS(updated_safe_db, export_path)
      } else {
        saveRDS(new_data, export_path)
      }
      
      # Im RAM aktualisieren
      df <- safe_join(df, new_data, spalte, target_var, ".new")
      
      # Kurze Pause für die API
      Sys.sleep(0.5)
      
    }, error = function(e) {
      message(sprintf("Fehler in Batch %d: %s", i, e$message))
    })
  }
  
  message("Klassifizierung abgeschlossen.")
  return(df)
}
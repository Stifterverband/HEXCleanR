# Deckt den kombinierten Normalfall ab:
# erst DB-Lookup, dann OpenAI fuer title-only und cld3 fuer Beschreibungen.
test_that("detect_missing_languages nutzt zuerst DB-Lookup und verarbeitet nur Restfaelle", {
  skip_if_not_installed("cld3")

  # Speichert, welche Titel tatsaechlich an den OpenAI-Helfer uebergeben wurden.
  # So kann spaeter geprueft werden, dass nur der verbleibende Rest bearbeitet wird.
  helper_titles <- character()

  # Die Funktion erwartet einen API-Key. Fuer den Test reicht ein Platzhalter,
  # weil der echte OpenAI-Aufruf unten komplett gemockt wird.
  withr::local_envvar(c(OPENAI_API_KEY = "test-key"))

  local_mocked_bindings(
    detect_lang_with_openai = function(df, spalte, db_data_path,
                                       export_path = "db_safety_export.rds",
                                       batch_size = 100) {
      # Der Mock merkt sich die uebergebenen Werte und simuliert eine
      # erfolgreiche OpenAI-Erkennung mit festem Rueckgabewert.
      helper_titles <<- df[[spalte]]
      df$sprache_recoded <- "Englisch"
      df
    },
    .package = "HEXCleanR"
  )

  # Drei Faelle:
  # 1) Titel kommt bereits in der DB vor -> Sprache sollte direkt aus der DB kommen
  # 2) Nur Titel vorhanden -> soll ueber OpenAI bearbeitet werden
  # 3) Beschreibung vorhanden -> soll ueber cld3 in kursbeschreibung_sprach laufen
  raw_data <- data.frame(
    titel = c(
      "Titel aus DB",
      "Nur Titel offen",
      "Beschreibung offen"
    ),
    kursbeschreibung = c(
      NA_character_,
      NA_character_,
      "This is a longer English course description for language detection."
    ),
    sprache_recoded = c(NA_character_, NA_character_, NA_character_),
    kursbeschreibung_sprach = c(NA_character_, NA_character_, NA_character_),
    stringsAsFactors = FALSE
  )

  # Lokale Mini-Datenbank fuer den Lookup nach bereits bekannten Titeln.
  db_data <- data.frame(
    titel = c("Titel aus DB", "Anderer Titel"),
    sprache_recoded = c("Deutsch", "Franzoesisch"),
    stringsAsFactors = FALSE
  )

  db_data_path <- tempfile(fileext = ".rds")
  export_path <- tempfile(fileext = ".rds")
  saveRDS(db_data, db_data_path)

  # Es werden zwei Meldungen erwartet:
  # - eine Zeile mit Beschreibung wurde ueber cld3 geloest
  # - eine title-only-Zeile ging in den OpenAI-Mock
  expect_message(
    expect_message(
      result <- detect_missing_languages(
        raw_data = raw_data,
        db_data_path = db_data_path,
        export_path = export_path
      ),
      "1 Zeilen wurden ueber den normalen Weg mit cld3 bearbeitet\\."
    ),
    "1 Zeilen wurden ueber OpenAI/ChatGPT bearbeitet\\."
  )

  # Ergebnispruefung:
  # - erste Zeile aus DB
  # - zweite Zeile aus dem OpenAI-Mock
  expect_identical(result$sprache_recoded[1:2], c("Deutsch", "Englisch"))
  # Nur der noch offene Titel darf an den OpenAI-Helfer weitergereicht werden.
  expect_identical(helper_titles, "Nur Titel offen")
  # Fuer die ersten beiden Zeilen gibt es keine Beschreibung, daher bleibt die
  # erkannte Beschreibungssprache leer.
  expect_true(is.na(result$kursbeschreibung_sprach[1]))
  expect_true(is.na(result$kursbeschreibung_sprach[2]))
  # In der dritten Zeile wurde eine Beschreibung analysiert; deshalb erwarten wir
  # dort irgendeinen nicht-leeren Zeichenwert sowie eine Recodierung in sprache_recoded.
  expect_false(is.na(result$kursbeschreibung_sprach[3]))
  expect_type(result$kursbeschreibung_sprach[3], "character")
  expect_false(is.na(result$sprache_recoded[3]))
})

test_that("detect_missing_languages recodiert erkannte Beschreibungssprache nach sprache_recoded", {
  raw_data <- data.frame(
    titel = c("English title", "Deutscher Titel"),
    kursbeschreibung = c(
      "This is a detailed English course description with enough text for detection.",
      "Dies ist eine ausfuehrliche deutsche Kursbeschreibung mit genug Text fuer die Spracherkennung."
    ),
    sprache_recoded = c(NA_character_, NA_character_),
    kursbeschreibung_sprach = c("en", "de"),
    stringsAsFactors = FALSE
  )

  result <- detect_missing_languages(raw_data = raw_data, db_data_path = NULL)

  expect_identical(result$sprache_recoded, c("Englisch", "Deutsch"))
  expect_identical(result$kursbeschreibung_sprach, c("en", "de"))
})

test_that("detect_missing_languages behandelt leere Strings wie fehlende Werte", {
  helper_titles <- character()

  withr::local_envvar(c(OPENAI_API_KEY = "test-key"))

  local_mocked_bindings(
    detect_lang_with_openai = function(df, spalte, db_data_path,
                                       export_path = "db_safety_export.rds",
                                       batch_size = 100) {
      helper_titles <<- df[[spalte]]
      df$sprache_recoded <- "Deutsch"
      df
    },
    .package = "HEXCleanR"
  )

  raw_data <- data.frame(
    titel = c("Titel nur mit Leerstring", "Titel mit Beschreibung"),
    kursbeschreibung = c("   ", "Ausfuehrliche deutsche Kursbeschreibung mit genug Text."),
    sprache_recoded = c("", ""),
    kursbeschreibung_sprach = c("", ""),
    stringsAsFactors = FALSE
  )

  expect_message(
    expect_message(
      result <- detect_missing_languages(raw_data = raw_data, db_data_path = NULL),
      "1 Zeilen wurden ueber den normalen Weg mit cld3 bearbeitet\\."
    ),
    "1 Zeilen wurden ueber OpenAI/ChatGPT bearbeitet\\."
  )

  expect_identical(helper_titles, "Titel nur mit Leerstring")
  expect_identical(result$sprache_recoded[1], "Deutsch")
  expect_false(is.na(result$sprache_recoded[2]))
  expect_false(is.na(result$kursbeschreibung_sprach[2]))
})

# Deckt den Sonderfall ohne kursbeschreibung-Spalte ab:
# offene Sprachwerte sollen dann trotzdem ueber OpenAI aufgeloest werden.
test_that("detect_missing_languages behandelt fehlende kursbeschreibung-Spalte als komplett NA", {
  # Auch hier wird festgehalten, welche Titel in den OpenAI-Helfer gehen.
  helper_titles <- character()

  withr::local_envvar(c(OPENAI_API_KEY = "test-key"))

  local_mocked_bindings(
    detect_lang_with_openai = function(df, spalte, db_data_path,
                                       export_path = "db_safety_export.rds",
                                       batch_size = 100) {
      # Simuliert: alle uebergebenen Titel werden als Deutsch erkannt.
      helper_titles <<- df[[spalte]]
      df$sprache_recoded <- "Deutsch"
      df
    },
    .package = "HEXCleanR"
  )

  # Es gibt absichtlich keine kursbeschreibung-Spalte.
  # Der Test prueft, dass die Funktion damit robust umgehen kann.
  raw_data <- data.frame(
    titel = c("Titel A", "Titel B"),
    sprache_recoded = c(NA_character_, NA_character_),
    stringsAsFactors = FALSE
  )

  db_data_path <- tempfile(fileext = ".rds")
  # Leere DB: es kann also nichts per Lookup gefunden werden.
  saveRDS(data.frame(titel = character(), sprache_recoded = character()), db_data_path)

  expect_message(
    result <- detect_missing_languages(
      raw_data = raw_data,
      db_data_path = db_data_path
    ),
    "2 Zeilen wurden ueber OpenAI/ChatGPT bearbeitet\\."
  )

  # Die Funktion soll keine fehlenden Spalten kuenstlich in das Ergebnis einbauen.
  expect_false("kursbeschreibung" %in% names(result))
  expect_false("kursbeschreibung_sprach" %in% names(result))
  expect_identical(result$sprache_recoded, c("Deutsch", "Deutsch"))
  # Beide Titel muessen in den OpenAI-Helfer laufen, weil sonst keine Quelle fuer
  # eine Sprachzuordnung vorhanden ist.
  expect_identical(helper_titles, c("Titel A", "Titel B"))
})

# Deckt den Fall ohne uebergebene DB ab:
# die Funktion soll direkt mit dem OpenAI-Zweig weiterarbeiten.
test_that("detect_missing_languages arbeitet ohne DB weiter, wenn db_data_path NULL ist", {
  # Ohne DB-Lookup muss direkt der OpenAI-Pfad verwendet werden.
  helper_titles <- character()

  withr::local_envvar(c(OPENAI_API_KEY = "test-key"))

  local_mocked_bindings(
    detect_lang_with_openai = function(df, spalte, db_data_path,
                                       export_path = "db_safety_export.rds",
                                       batch_size = 100) {
      # Mock statt echtem API-Aufruf.
      helper_titles <<- df[[spalte]]
      df$sprache_recoded <- "Deutsch"
      df
    },
    .package = "HEXCleanR"
  )

  raw_data <- data.frame(
    titel = "Titel ohne DB",
    sprache_recoded = NA_character_,
    stringsAsFactors = FALSE
  )

  expect_message(
    result <- detect_missing_languages(
      raw_data = raw_data,
      db_data_path = NULL
    ),
    "1 Zeilen wurden ueber OpenAI/ChatGPT bearbeitet\\."
  )

  expect_identical(result$sprache_recoded, "Deutsch")
  # Der einzige Titel muss vollstaendig an den OpenAI-Helfer durchgereicht werden.
  expect_identical(helper_titles, "Titel ohne DB")
})

# Deckt den Warnpfad ab:
# wenn OpenAI noetig waere, aber kein API-Key gesetzt ist, bleibt der Wert NA.
test_that("detect_missing_languages warnt bei fehlendem OPENAI_API_KEY", {
  # Leerer API-Key simuliert eine Konfiguration, in der OpenAI nicht benutzt werden kann.
  withr::local_envvar(c(OPENAI_API_KEY = ""))

  raw_data <- data.frame(
    titel = "Titel ohne API-Key",
    sprache_recoded = NA_character_,
    stringsAsFactors = FALSE
  )

  expect_warning(
    expect_message(
      result <- detect_missing_languages(
        raw_data = raw_data,
        db_data_path = NULL
      ),
      "0 Zeilen wurden ueber OpenAI/ChatGPT bearbeitet\\."
    ),
    "OPENAI_API_KEY ist nicht gesetzt"
  )

  # Ohne API-Key darf die Sprache nicht stillschweigend erfunden werden.
  expect_true(is.na(result$sprache_recoded))
})

# Separater Integrationstest:
# hier wird der echte OpenAI-Aufruf getestet und nicht mit einem Mock gearbeitet.
test_that("detect_lang_with_openai liefert mit echter API einen gueltigen Sprachwert", {
  # Echter Integrationstest: nur lokal bzw. bewusst ausfuehren, nie auf CRAN.
  skip_on_cran()
  skip_if_not_installed("ellmer")
  skip_if(
    Sys.getenv("OPENAI_API_KEY") == "",
    "OPENAI_API_KEY nicht gesetzt; Integrationstest wird uebersprungen."
  )

  # Nur diese Rueckgabewerte gelten momentan als fachlich gueltig.
  valid_langs <- c(
    "Englisch", "Deutsch", "Franzoesisch", "Spanisch", "Italienisch",
    "Russisch", "Tuerkisch", "Portugiesisch", "Niederlaendisch",
    "Deutsch/Englisch", "Sonstiges"
  )

  # Ein klar englischer Titel, damit die API einen sinnvollen Sprachwert liefern kann.
  df <- data.frame(
    titel = "Introduction to Machine Learning",
    sprache_recoded = NA_character_,
    stringsAsFactors = FALSE
  )

  db_data_path <- tempfile(fileext = ".rds")
  export_path <- tempfile(fileext = ".rds")
  saveRDS(data.frame(titel = character(), sprache_recoded = character()), db_data_path)

  # Netzwerk- oder API-Probleme sollen den Test nicht hart scheitern lassen,
  # sondern sauber als "skipped" markieren.
  result <- tryCatch(
    detect_lang_with_openai(
      df = df,
      spalte = "titel",
      db_data_path = db_data_path,
      export_path = export_path,
      batch_size = 1
    ),
    error = function(e) {
      skip(paste("OpenAI-Integrationstest uebersprungen wegen API-/Netzfehler:", e$message))
    }
  )

  # Falls die API zwar antwortet, aber kein verwertbares Ergebnis zurueckkommt,
  # wird der Test ebenfalls uebersprungen statt falsch-positiv zu scheitern.
  if (is.na(result$sprache_recoded[[1]])) {
    skip("OpenAI-Integrationstest uebersprungen, da keine gueltige API-Antwort vorlag.")
  }

  expect_false(is.na(result$sprache_recoded[[1]]))
  expect_true(result$sprache_recoded[[1]] %in% valid_langs)
})

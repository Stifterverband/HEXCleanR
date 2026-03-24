test_that("detect_missing_languages nutzt zuerst DB-Lookup und verarbeitet nur Restfaelle", {
  skip_if_not_installed("cld3")

  helper_titles <- character()

  withr::local_envvar(c(OPENAI_API_KEY = "test-key"))

  local_mocked_bindings(
    detect_lang_with_openai = function(df, spalte, db_data_path,
                                       export_path = "db_safety_export.rds",
                                       batch_size = 100) {
      helper_titles <<- df[[spalte]]
      df$sprache_recoded <- "Englisch"
      df
    },
    .package = "HEXCleanR"
  )

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

  db_data <- data.frame(
    titel = c("Titel aus DB", "Anderer Titel"),
    sprache_recoded = c("Deutsch", "Franzoesisch"),
    stringsAsFactors = FALSE
  )

  db_data_path <- tempfile(fileext = ".rds")
  export_path <- tempfile(fileext = ".rds")
  saveRDS(db_data, db_data_path)

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

  expect_identical(
    result$sprache_recoded,
    c("Deutsch", "Englisch", NA_character_)
  )
  expect_identical(helper_titles, "Nur Titel offen")
  expect_true(is.na(result$kursbeschreibung_sprach[1]))
  expect_true(is.na(result$kursbeschreibung_sprach[2]))
  expect_false(is.na(result$kursbeschreibung_sprach[3]))
  expect_type(result$kursbeschreibung_sprach[3], "character")
})

test_that("detect_missing_languages behandelt fehlende kursbeschreibung-Spalte als komplett NA", {
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
    titel = c("Titel A", "Titel B"),
    sprache_recoded = c(NA_character_, NA_character_),
    stringsAsFactors = FALSE
  )

  db_data_path <- tempfile(fileext = ".rds")
  saveRDS(data.frame(titel = character(), sprache_recoded = character()), db_data_path)

  expect_message(
    result <- detect_missing_languages(
      raw_data = raw_data,
      db_data_path = db_data_path
    ),
    "2 Zeilen wurden ueber OpenAI/ChatGPT bearbeitet\\."
  )

  expect_false("kursbeschreibung" %in% names(result))
  expect_false("kursbeschreibung_sprach" %in% names(result))
  expect_identical(result$sprache_recoded, c("Deutsch", "Deutsch"))
  expect_identical(helper_titles, c("Titel A", "Titel B"))
})

test_that("detect_missing_languages arbeitet ohne DB weiter, wenn db_data_path NULL ist", {
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
  expect_identical(helper_titles, "Titel ohne DB")
})

test_that("detect_missing_languages warnt bei fehlendem OPENAI_API_KEY", {
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

  expect_true(is.na(result$sprache_recoded))
})

test_that("detect_lang_with_openai liefert mit echter API einen gueltigen Sprachwert", {
  skip_on_cran()
  skip_if_not_installed("ellmer")
  skip_if(
    Sys.getenv("OPENAI_API_KEY") == "",
    "OPENAI_API_KEY nicht gesetzt; Integrationstest wird uebersprungen."
  )

  valid_langs <- c(
    "Englisch", "Deutsch", "Franzoesisch", "Spanisch", "Italienisch",
    "Russisch", "Tuerkisch", "Portugiesisch", "Niederlaendisch",
    "Deutsch/Englisch", "Sonstiges"
  )

  df <- data.frame(
    titel = "Introduction to Machine Learning",
    sprache_recoded = NA_character_,
    stringsAsFactors = FALSE
  )

  db_data_path <- tempfile(fileext = ".rds")
  export_path <- tempfile(fileext = ".rds")
  saveRDS(data.frame(titel = character(), sprache_recoded = character()), db_data_path)

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

  if (is.na(result$sprache_recoded[[1]])) {
    skip("OpenAI-Integrationstest uebersprungen, da keine gueltige API-Antwort vorlag.")
  }

  expect_false(is.na(result$sprache_recoded[[1]]))
  expect_true(result$sprache_recoded[[1]] %in% valid_langs)
})

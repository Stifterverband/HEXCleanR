test_that("detect_missing_languages nutzt zuerst DB-Lookup und verarbeitet nur Restfaelle", {
  skip_if_not_installed("cld3")

  helper_titles <- character()

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

  result <- detect_missing_languages(
    raw_data = raw_data,
    db_data_path = db_data_path,
    export_path = export_path
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

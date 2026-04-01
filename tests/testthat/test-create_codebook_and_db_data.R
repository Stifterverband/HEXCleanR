test_that("create_codebook_and_db_data erstellt codebook und db_data im erwarteten Format", {
  raw_data <- data.frame(
    anmerkungen = c("Hinweis", "Hinweis"),
    dozierende = c("Prof. Beispiel", "Prof. Beispiel"),
    ects = c("5", "5"),
    fakultaet = c("Informatik", "Informatik"),
    hochschule = c("Universitaet Musterstadt", "Universitaet Musterstadt"),
    hochschule_kurz = c("UMS", "UMS"),
    jahr = c("2026", "2026"),
    kursbeschreibung = c("Kurz", "Dies ist eine ausreichend lange Kursbeschreibung."),
    kursformat_original = c("Vorlesung", "Vorlesung"),
    kursformat_recoded = c("Vorlesung", "Vorlesung"),
    lehrtyp = c("Pflicht", "Pflicht"),
    lernmethode = c("Praesenz", "Praesenz"),
    lernziele = c("Lernziel", "Lernziel"),
    literatur = c("Buch", "Buch"),
    module = c("Modul A", "Modul A"),
    nummer = c("101", "102"),
    organisation_orig = c("Original", "Original"),
    organisation = c("Organisation", "Organisation"),
    pfad = c("/tmp/pfad", "/tmp/pfad"),
    pruefung = c("Klausur", "Klausur"),
    scrape_datum = c("2026-04-01", "2026-04-01"),
    semester = c("2026s", "2026s"),
    sprache_original = c("Deutsch", "Deutsch"),
    sprache_recoded = c("Deutsch", "Deutsch"),
    studiengaenge = c("BSc", "BSc"),
    sws = c("2", "2"),
    teilnehmerzahl = c("30", "30"),
    titel = c("Kurs 1", "Kurs 2"),
    url = c("https://example.org", "https://example.org"),
    voraussetzungen = c("Keine", "Keine"),
    zusatzinformationen = c("Info", "Info"),
    institut = c("Institut A", "Institut A"),
    stringsAsFactors = FALSE
  )

  raw_data_fs <- data.frame(
    data_analytics_ki = c(1, 0),
    softwareentwicklung = c(0, 1),
    nutzerzentriertes_design = c(0, 0),
    it_architektur = c(1, 1),
    hardware_robotikentwicklung = c(0, 0),
    quantencomputing = c(0, 1)
  )

  result <- create_codebook_and_db_data(raw_data, raw_data_fs)

  expect_named(result, c("codebook", "db_data"))
  expect_identical(result$codebook$Variablen, colnames(raw_data))
  expect_identical(result$db_data$id, 1:2)
  expect_true(is.na(result$db_data$kursbeschreibung[1]))
  expect_identical(
    result$db_data$kursbeschreibung[2],
    "Dies ist eine ausreichend lange Kursbeschreibung."
  )
  expect_identical(result$db_data$data_analytics_ki, c(1, 0))
  expect_true(all(is.na(result$db_data$matchingart)))
})

test_that("create_codebook_and_db_data bricht bei fehlenden raw_data-Spalten ab", {
  raw_data <- data.frame(
    titel = "Kurs 1",
    stringsAsFactors = FALSE
  )

  raw_data_fs <- data.frame(
    data_analytics_ki = 1,
    softwareentwicklung = 0,
    nutzerzentriertes_design = 0,
    it_architektur = 1,
    hardware_robotikentwicklung = 0,
    quantencomputing = 0
  )

  expect_error(
    create_codebook_and_db_data(raw_data, raw_data_fs),
    "`raw_data` fehlen folgende benoetigte Spalten:"
  )
})

test_that("create_codebook_and_db_data bricht bei fehlenden raw_data_fs-Spalten ab", {
  raw_data <- data.frame(
    anmerkungen = "Hinweis",
    dozierende = "Prof. Beispiel",
    ects = "5",
    fakultaet = "Informatik",
    hochschule = "Universitaet Musterstadt",
    hochschule_kurz = "UMS",
    jahr = "2026",
    kursbeschreibung = "Dies ist eine ausreichend lange Kursbeschreibung.",
    kursformat_original = "Vorlesung",
    kursformat_recoded = "Vorlesung",
    lehrtyp = "Pflicht",
    lernmethode = "Praesenz",
    lernziele = "Lernziel",
    literatur = "Buch",
    module = "Modul A",
    nummer = "101",
    organisation_orig = "Original",
    organisation = "Organisation",
    pfad = "/tmp/pfad",
    pruefung = "Klausur",
    scrape_datum = "2026-04-01",
    semester = "2026s",
    sprache_original = "Deutsch",
    sprache_recoded = "Deutsch",
    studiengaenge = "BSc",
    sws = "2",
    teilnehmerzahl = "30",
    titel = "Kurs 1",
    url = "https://example.org",
    voraussetzungen = "Keine",
    zusatzinformationen = "Info",
    institut = "Institut A",
    stringsAsFactors = FALSE
  )

  raw_data_fs <- data.frame(
    data_analytics_ki = 1,
    softwareentwicklung = 0,
    nutzerzentriertes_design = 0,
    it_architektur = 1,
    hardware_robotikentwicklung = 0
  )

  expect_error(
    create_codebook_and_db_data(raw_data, raw_data_fs),
    "`raw_data_fs` fehlen folgende benoetigte Spalten:"
  )
})

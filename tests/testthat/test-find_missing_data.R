test_that("find_missing_data nutzt konfigurierbare Vergleichsspalten", {
  base_path <- tempfile("missing-data-")
  sem_path <- file.path(base_path, "2025w")

  dir.create(base_path)
  dir.create(sem_path)

  readr::write_csv(
    tibble::tibble(
      veranstaltungstitel = c("Kurs A", "Kurs B")
    ),
    file.path(sem_path, "base_data_test.csv")
  )

  writeLines(
    '[{"kursname":"Kurs A"}]',
    file.path(sem_path, "course_data_test.json")
  )

  expect_message(
    result <- find_missing_data(
      path_uni_ordner = base_path,
      colname_csv = "veranstaltungstitel",
      colname_json = "kursname"
    ),
    "Starte Vergleich in:"
  )

  expect_equal(nrow(result), 1)
  expect_identical(result$veranstaltungstitel, "Kurs B")
  expect_identical(result$semester, "2025w")
})
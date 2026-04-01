test_that("create_baby_dbs speichert pro vorhandenem Semesterordner eine RDS-Datei", {
  base_path <- tempfile("baby-dbs-")
  dir.create(base_path)
  dir.create(file.path(base_path, "2025w"))
  dir.create(file.path(base_path, "2026s"))

  db_data <- data.frame(
    semester = c("2025w", "2025w", "2026s"),
    titel = c("Kurs A", "Kurs B", "Kurs C"),
    stringsAsFactors = FALSE
  )

  expect_message(
    result <- create_baby_dbs(db_data, base_path),
    "Gespeichert:"
  )

  expect_true(file.exists(file.path(base_path, "2025w", "db_data_2025w.rds")))
  expect_true(file.exists(file.path(base_path, "2026s", "db_data_2026s.rds")))
  expect_length(result$saved, 2)
  expect_length(result$missing_dirs, 0)

  saved_2025w <- readRDS(file.path(base_path, "2025w", "db_data_2025w.rds"))
  expect_identical(saved_2025w$semester, c("2025w", "2025w"))
  expect_identical(saved_2025w$titel, c("Kurs A", "Kurs B"))
})

test_that("create_baby_dbs meldet fehlende Semesterordner", {
  base_path <- tempfile("baby-dbs-")
  dir.create(base_path)
  dir.create(file.path(base_path, "2025w"))

  db_data <- data.frame(
    semester = c("2025w", "2026s"),
    titel = c("Kurs A", "Kurs B"),
    stringsAsFactors = FALSE
  )

  expect_message(
    expect_message(
      result <- create_baby_dbs(db_data, base_path),
      "Gespeichert:"
    ),
    "Ordner fehlt:"
  )

  expect_true(file.exists(file.path(base_path, "2025w", "db_data_2025w.rds")))
  expect_false(file.exists(file.path(base_path, "2026s", "db_data_2026s.rds")))
  expect_length(result$saved, 1)
  expect_identical(result$missing_dirs, file.path(base_path, "2026s"))
})

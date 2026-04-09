test_that("plot_na_balloons verwendet standardmaessig semester als Gruppierung", {
  test_data <- data.frame(
    semester = c("2025w", "2025w", "2026s", "2026s"),
    var_a = c(NA, "x", NA, NA),
    var_b = c("a", "b", "c", NA),
    stringsAsFactors = FALSE
  )

  p <- HEXCleanR::plot_na_balloons(test_data)

  expect_s3_class(p, "ggplot")
  expect_true("semester" %in% names(p$data))
  expect_false("grp_var" %in% names(p$data))
})

test_that("plot_na_balloons berechnet relative NA-Anteile pro Gruppe", {
  test_data <- data.frame(
    semester = c("2025w", "2025w", "2025w", "2026s"),
    var_a = c(NA, "x", NA, NA),
    var_b = c("a", NA, "c", "d"),
    stringsAsFactors = FALSE
  )

  p <- HEXCleanR::plot_na_balloons(test_data)
  plot_data <- p$data

  var_a_2025w <- plot_data[plot_data$semester == "2025w" & plot_data$variable == "var_a", ]
  var_b_2025w <- plot_data[plot_data$semester == "2025w" & plot_data$variable == "var_b", ]
  var_a_2026s <- plot_data[plot_data$semester == "2026s" & plot_data$variable == "var_a", ]

  expect_equal(var_a_2025w$n_group, 3)
  expect_equal(var_a_2025w$n_na, 2)
  expect_equal(var_a_2025w$prop_na, 2 / 3)

  expect_equal(var_b_2025w$n_group, 3)
  expect_equal(var_b_2025w$n_na, 1)
  expect_equal(var_b_2025w$prop_na, 1 / 3)

  expect_equal(var_a_2026s$n_group, 1)
  expect_equal(var_a_2026s$n_na, 1)
  expect_equal(var_a_2026s$prop_na, 1)
})

test_that("plot_na_balloons akzeptiert weiterhin explizite Gruppierungsvariablen", {
  test_data <- data.frame(
    semester = c("2025w", "2025w", "2026s", "2026s"),
    fach = c("A", "A", "B", "B"),
    var_a = c(NA, "x", "y", NA),
    stringsAsFactors = FALSE
  )

  p <- HEXCleanR::plot_na_balloons(test_data, grp_var = fach)

  expect_s3_class(p, "ggplot")
  expect_true("fach" %in% names(p$data))
})

test_that("plot_na_balloons wirft einen Fehler bei fehlender Gruppierungsvariable", {
  test_data <- data.frame(
    semester = c("2025w", "2026s"),
    var_a = c(NA, "x"),
    stringsAsFactors = FALSE
  )

  expect_error(
    HEXCleanR::plot_na_balloons(test_data, grp_var = fach),
    "Die angegebene Gruppierungs-Spalte existiert nicht in `data`.",
    fixed = TRUE
  )
})

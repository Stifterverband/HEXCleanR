test_that("check_distinct_level_change_df kann absolute und relative Vielfalt unterschiedlich bewerten", {
  test_data <- data.frame(
    semester = c(
      rep("A", 100),
      rep("B", 50),
      rep("C", 100)
    ),
    dozent = c(
      rep(paste0("a", 1:10), each = 10),
      rep(paste0("b", 1:5), each = 10),
      rep(paste0("c", 1:10), each = 10)
    ),
    stringsAsFactors = FALSE
  )

  res_abs <- check_distinct_level_change_df(
    test_data,
    group_col = semester,
    threshold_low = 0.7,
    threshold_high = 1.3,
    min_distinct = 5,
    relative = FALSE
  )

  res_rel <- suppressMessages(
    check_distinct_level_change_df(
      test_data,
      group_col = semester,
      threshold_low = 0.7,
      threshold_high = 1.3,
      min_distinct = 5,
      relative = TRUE
    )
  )

  expect_s3_class(res_abs, "tbl_df")
  expect_equal(nrow(res_abs), 1)
  expect_equal(res_abs$variable, "dozent")
  expect_equal(res_abs$semester, "B")
  expect_equal(res_abs$unique_found, 5)
  expect_equal(res_abs$n_unique, 5)
  expect_equal(res_abs$n_group, 50)
  expect_false(res_abs$relative)

  expect_s3_class(res_rel, "tbl_df")
  expect_equal(nrow(res_rel), 0)
})

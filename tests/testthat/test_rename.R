context("Testing renaming labels using clean_labels")

test_that("clean_labels outputs as expected", {
  skip_on_cran()

  input_1 <- "-_-This is; A    WeÏrD**./sêntënce..."
  input_2 <- c("Peter and stëven", "peter-and.stëven", "pëtêr and stëven  _-")
  
  expect_equal_to_reference(clean_labels(input_1),
                            file = "rds/clean_labels_ref_1.rds")

  expect_equal_to_reference(clean_labels(input_2),
                            file = "rds/clean_labels_ref_2.rds")

  expect_equal_to_reference(clean_labels(input_1, sep = " // "),
                            file = "rds/clean_labels_ref_3.rds")

  expect_equal(length(clean_labels(NULL)), 0L)

  expect_true(is.na(clean_labels(NA)))

  expect_identical(clean_labels("fooBaR "), clean_labels("foobar"))

  expect_identical(clean_labels("Pétèr and Stévën"),
                   clean_labels("peter   and.steven"))

  expect_identical(clean_labels("Pïôtr--and--ÿgòr  "),
                   clean_labels("  píotr_and_YGÓR"))

  expect_identical(clean_labels("ますだ, よしひこ"),
                   "masuda_yoshihiko")

  expect_identical(clean_labels("äääß"),
                   "aeaeaess")
})


context("Testing renaming labels using rename")

test_that("rename outputs as expected", {
  skip_on_cran()

  input_1 <- "-_-This is; A    WeÏrD**./sêntënce..."
  input_2 <- c("Peter and stëven", "peter-and.stëven", "pëtêr and stëven  _-")
  
  expect_equal_to_reference(rename(input_1),
                            file = "rds/rename_ref_1.rds")

  expect_equal_to_reference(rename(input_2),
                            file = "rds/rename_ref_2.rds")

  expect_equal_to_reference(rename(input_1, sep = " // "),
                            file = "rds/rename_ref_3.rds")

  expect_equal(length(rename(NULL)), 0L)

  expect_true(is.na(rename(NA)))

  expect_identical(rename("fooBaR "), rename("foobar"))

  expect_identical(rename("Pétèr and Stévën"),
                   rename("peter   and.steven"))

  expect_identical(rename("Pïôtr--and--ÿgòr  "),
                   rename("  píotr_and_YGÓR"))
})


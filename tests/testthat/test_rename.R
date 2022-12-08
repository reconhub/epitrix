context("Testing renaming labels using clean_labels")

input_1 <- "-_-This is; A    WeÏrD**./sêntënce..."
input_2 <- c("Peter and stëven", "peter-and.stëven", "pëtêr and stëven  _-")

test_that("clean_labels outputs as expected", {
  skip_on_cran()
  correct_1 <- "this_is_a_weird_sentence"
  correct_2 <- c("peter_and_steven", "peter_and_steven", "peter_and_steven")
  correct_3 <- "this // is // a // weird // sentence"
  expect_identical(clean_labels(input_1), correct_1)
  expect_identical(clean_labels(input_2), correct_2)
  expect_identical(clean_labels(input_1, sep = " // "), correct_3)
  expect_equal(length(clean_labels(NULL)), 0L)
  expect_true(is.na(clean_labels(NA)))
  expect_identical(clean_labels("fooBaR "), clean_labels("foobar"))
  expect_identical(clean_labels("Pétèr and Stévën"),
                   clean_labels("peter   and.steven"))
  expect_identical(clean_labels("Pïôtr--and--ÿgòr  "),
                   clean_labels("  píotr_and_YGÓR"))
  expect_identical(clean_labels("ますだ, よしひこ"),
                   "masuda_yoshihiko")
})

test_that("characters can be protected", {
  
  expect_identical(clean_labels(c("x > 10", "x < 10"), protect = "<>"), 
                   c("x_>_10", "x_<_10"))
  expect_identical(clean_labels(c("x > 10", "x < 10"), protect = ""), 
                   c("x_10", "x_10"))
  expect_identical(clean_labels(input_1, protect = "-_-"),
                   "-_-this_is_a_weird_sentence")

})

test_that("special characters can be used as separators", {
  expect_identical(clean_labels("You.and.me", sep = "."), "you.and.me")
  expect_identical(clean_labels("You*and*me", sep = "*"), "you*and*me")
  expect_identical(clean_labels("You?and?me", sep = "?"), "you?and?me")

})


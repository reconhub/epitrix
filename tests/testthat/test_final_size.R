context("Testing relationship between R0 and final size")

test_that("AR2R0 works as expected", {
  expect_error(AR2R0(-1), "AR should contain numeric values between 0 and 1")
  expect_error(AR2R0(2), "AR should contain numeric values between 0 and 1")
  expect_error(AR2R0(c(1, -1)), 
               "AR should contain numeric values between 0 and 1")
  expect_error(AR2R0(c(1, 2)), 
               "AR should contain numeric values between 0 and 1")
  expect_equal(AR2R0(0), 0)
  expect_equal(AR2R0(1), Inf)
  expect_equal(AR2R0(0.5), - log(1 - 0.5) / 0.5)
})
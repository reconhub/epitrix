
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


test_that("R02AR works as expected", {
  expect_error(R02AR(-1), "R0 should contain numeric values >= 0")
  expect_error(R02AR(c(1, -1)), 
               "R0 should contain numeric values >= 0")
  expect_error(R02AR(1, tol = c(0.01, 0.1)), 
               "tol must be a single numeric value")
  expect_error(R02AR(1, tol = 0), 
               "tol must be > 0.")
  expect_equal(R02AR(0), 0)
  expect_equal(R02AR(Inf), 1)
  expect_equal(R02AR(- log(1 - 0.5) / 0.5), 0.5)
})


test_that("R02herd_immunity_threshold works as expected", {
  expect_error(R02herd_immunity_threshold(-1), "R0 should contain numeric values >= 0")
  expect_error(R02herd_immunity_threshold(c(1, -1)), 
               "R0 should contain numeric values >= 0")
  expect_equal(R02herd_immunity_threshold(0), 0)
  expect_equal(R02herd_immunity_threshold(1), 0)
  expect_equal(R02herd_immunity_threshold(Inf), 1)
  expect_equal(R02herd_immunity_threshold(2), 0.5)
})

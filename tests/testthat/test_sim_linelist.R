
test_that("sim_linelist generates appropriate errors", {
  msg <- "n cannot be negative"
  expect_error(sim_linelist(-2), msg)

  msg <- "onset_span cannot be less than 1"
  expect_error(sim_linelist(1, onset_span = 0), msg)

  msg <- "report_delay cannot be negative"
  expect_error(sim_linelist(1, report_delay = -Inf), msg)

  msg <- "cfr cannot be negative"
  expect_error(sim_linelist(1, cfr = -.2), msg)

  msg <- "cfr cannot be greater than 1"
  expect_error(sim_linelist(1, cfr = 1.2), msg)

})



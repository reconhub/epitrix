
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



test_that("sim_linelist generates appropriate outputs", {
  x <- sim_linelist()
  expected_names <- c("id", "date_of_onset", "date_of_report", "gender", "outcome")
  expect_equal(nrow(x), 1L)

  x <- sim_linelist(99, cfr = 0.5)
  expect_equal(nrow(x), 99L)
  
  expect_equal(names(x), expected_names)
  expect_s3_class(x, "data.frame")
  expect_s3_class(x$date_of_onset, "Date")
  expect_s3_class(x$date_of_report, "Date")
  expect_true(all(x$gender %in% c("female", "male")))
  expect_true(all(x$outcome %in% c("recovery", "death")))

})

context("Testing incubation period estimation")

set.seed(1)
ll <- linelist::clean_data(linelist::messy_data())
# Creating a list column of exposures
x <- 0:15
y <- distcrete::distcrete("gamma", 1, shape = 12, rate = 3, w = 0)$d(x)
mkexposures <- function(foo) foo - base::sample(x, size = sample.int(5, size = 1), prob = y)
exposures <- sapply(ll$date_of_onset, mkexposures)
ll$exposure <- exposures
ll$constant_exposure <- ll$date_of_onset - 1
# Adding negative data
ll$bogo_exposure <- exposures
ll$bogo_exposure[[5]] <- ll$bogo_exposure[[5]] + 100
# Creating a column for start and end periods
start_exposure    <- round(rgamma(nrow(ll), shape = 12, rate = 3))
end_exposure      <- round(rgamma(nrow(ll), shape = 12, rate = 7))
ll$exposure_end   <- ll$date_of_onset - end_exposure
ll$exposure_start <- ll$exposure_end - start_exposure
# Creating a list of sequential dates, in random order
exposures_two <- vector(mode = "list", length = nrow(ll))
for (i in seq_along(exposures)) {
  exposures_two[[i]] <- sample(seq(ll$exposure_start[i], ll$exposure_end[i], by = "1 day"))
}
ll$boogaloo <- exposures_two

#creating a simple line list with known incubation period dist:
ll2 <- data.frame(
  patient_id = 1:4,
  onset = lubridate::as_date(c("2018-1-15", "2018-1-20", "2018-1-23", "2018-1-24")
))

ll2$exposure <- list(
  lubridate::as_date(c("2018-1-12", "2018-1-10")),
  lubridate::as_date(c("2018-1-12", "2018-1-14", "2018-1-17", "2018-1-19")),
  lubridate::as_date(c("2018-1-15", "2018-1-20")),
  lubridate::as_date(c("2018-1-23"))
)

ref_inc_period <- data.frame(
  incubation_period = 1:8,
  relative_frequency = c(5/16, 0, 5/16, 0, 1/8, 1/16, 0, 3/16)
)


test_that("an error is thrown if a data frame is not presented", {
  expect_error(empirical_incubation_dist(exposures), "x is not a data.frame")
})


test_that("an error is thrown if the data frame has no columns", {
  expect_error(empirical_incubation_dist(data.frame()), "x has no columns")
})


test_that("an error is thown if date_of_onset is not a Date", {
  expect_error(empirical_incubation_dist(ll, exposure, date_of_onset),
              "date_of_onset must be a column of Dates. I found a column of class list")
})


test_that("an error is thrown if columns don't exist in the data frame", {
  # NOTE: do not edit the spacing on this.
  expect_error(empirical_incubation_dist(ll, what, the, heck),
  "what is not a column in ll
  the is not a column in ll
  heck is not a column in ll")
})


test_that("an error is thrown if exposure is not a Date column when exposure_end is specified", {
  expect_error(empirical_incubation_dist(ll, date_of_onset, exposure, exposure_end),
               "if exposure_end is specified, then exposure must be a vector of Dates")
})


test_that("a warning is thrown if there are negative incubation periods", {
   expect_warning(empirical_incubation_dist(ll, date_of_onset, bogo_exposure),
                  "negative incubation periods in data!")
})


test_that("empirical incubation period distribution can be calculated from start and end", {
  dl <- empirical_incubation_dist(ll, date_of_onset, exposure_start, exposure_end)
  dr <- empirical_incubation_dist(ll, date_of_onset, boogaloo)
  expect_identical(dr, dl)
})

test_that("empirical incubation period distribution matches reference", {
  skip_on_cran()
  incubation_period_dist <- empirical_incubation_dist(ll, date_of_onset, exposure)
  expect_equal_to_reference(incubation_period_dist, file = "rds/disc_empirical_ref.rds")
})


test_that("empirical incubation period distribution matches dist reference computed by hand", {
  skip_on_cran()
  incubation_period_dist <- empirical_incubation_dist(ll2, onset, exposure)

  expect_equal_to_reference(incubation_period_dist, ref_inc_period)
})


test_that("fitted gamma incubation period distribution matches reference", {
  skip_on_cran()
  fit <- fit_gamma_incubation_dist(ll, date_of_onset, exposure)
  expect_equal_to_reference(fit, file = "rds/incubation_disc_gamma_ref.rds")
})


test_that("fit_gamma_incubation_dist() rejects constant incubation periods", {
  expect_error(fit_gamma_incubation_dist(ll, date_of_onset, constant_exposure),
               "incubation period is constant")
})

context("Testing incubation period estimation")

test_that("test that empirical incubation period distribution matches reference", {
    skip_on_cran()

    set.seed(1)
    ll <- messy_data() %>% clean_data()
    x <- 0:15
    y <- distcrete("gamma", 1, shape = 12, rate = 3, w = 0)$d(x)
    mkexposures <- function(foo) foo - base::sample(x, size = sample.int(5, size = 1), prob = y)
    exposures <- sapply(ll$date_of_onset, mkexposures)
    ll$dates_exposure <- exposures

    incubation_period_dist <- empirical_incubation_dist(ll, dates_exposure, date_of_onset)

    expect_equal_to_reference(incubation_period_dist, file = "rds/disc_empirical_ref.rds")

})

test_that("test that fitted gamma incubation period distribution matches reference", {
    skip_on_cran()

    set.seed(1)
    ll <- messy_data() %>% clean_data()
    x <- 0:15
    y <- distcrete("gamma", 1, shape = 12, rate = 3, w = 0)$d(x)
    mkexposures <- function(foo) foo - base::sample(x, size = sample.int(5, size = 1), prob = y)
    exposures <- sapply(ll$date_of_onset, mkexposures)
    ll$dates_exposure <- exposures

    fit <- fit_gamma_incubation_dist(ll, dates_exposure, date_of_onset)

    expect_equal_to_reference(fit, file = "rds/incubation_disc_gamma_ref.rds")

})

context("Testing gamma fitting")

test_that("Switch between alternative parametrisation", {
    skip_on_cran()

    set.seed(1)
    x <- rexp(100, 0.1)
    res <- fit_disc_gamma(x)

    expect_equal_to_reference(res, file = "rds/disc_gamma_ref.rds")

})

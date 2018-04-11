context("Testing gamma fitting")

test_that("Switch between alternative parametrisation", {
    skip_on_cran()

    set.seed(1)
    x <- rexp(100, 0.1)
    res <- fit_disc_gamma(x)

    expect_equal_to_reference(res, file = "rds/disc_gamma_ref.rds")

})




test_that("Test NA removal", {
    skip_on_cran()

    a <- c(NA, 1, 2, 1, NA, 10, 3, NA, 4, 5)
    b <- na.omit(a)
    suppressWarnings(expect_equal(fit_disc_gamma(a), fit_disc_gamma(b)))
    expect_warning(fit_disc_gamma(a), "3 NAs were removed from the data before fitting.")    
    
})




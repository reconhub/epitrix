
test_that("Switch between alternative parametrisation", {
    skip_on_cran()

    set.seed(1)
    x <- rexp(100, 0.1)
    res <- fit_disc_gamma(x)
    expect_snapshot(res)

})


test_that("Test NA removal", {
    skip_on_cran()

    a <- c(NA, 1, 2, 1, NA, 10, 3, NA, 4, 5)
    b <- na.omit(a)
    suppressWarnings(expect_equal(fit_disc_gamma(a), fit_disc_gamma(b)))
    expect_warning(fit_disc_gamma(a), "3 NAs were removed from the data before fitting.")    
    
})


test_that("Test error when data contains values <= 0", {
  skip_on_cran()
  
  x <- c(rexp(100, 0.1), -5)
  expect_error(fit_disc_gamma(x), "Data contains values < 0. Discretised gamma distribution cannot be fitted.")    
  
})

test_that("Test error when data mean is not finite", {
  skip_on_cran()
  
  x <- c(rexp(100, 0.1), Inf)
  expect_error(fit_disc_gamma(x), "Mean of the data not finite. Remove instances of Inf.")    
  
})

test_that("Test error when data mean is 0", {
  skip_on_cran()
  
  x <- rep(0, 100)
  expect_warning(fit_disc_gamma(x), "Mean of data is 0. Defaulting to 1 for starting values of mu_ini and cv_ini.")    
  
})




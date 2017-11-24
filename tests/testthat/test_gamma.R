context("Testing gamma tools")

test_that("Switch between alternative parametrisation", {
    skip_on_cran()

    x <- gamma_mucv2shapescale(10, 4)
    y  <-  gamma_shapescale2mucv(x$shape, x$scale)

    expect_equal(y$mu, 10)
    expect_equal(y$cv, 4)

})



test_that("Gamma log-likelihood gives expected results", {
  skip_on_cran()

  expect_equal(gamma_log_likelihood(-1, 1, 2), NA_real_)

  expect_equal(gamma_log_likelihood(1, 1, 2),
               -2.27488763887772)

  expect_equal(gamma_log_likelihood(1, 1, 2, discrete = FALSE),
               -1.88459611497805)

  params <- gamma_mucv2shapescale(1, 2)

  gamma_ref <- dgamma(1, shape = params$shape, scale = params$scale,
                      log = TRUE)

  expect_equal(gamma_log_likelihood(1, 1, 2, discrete = FALSE),
               gamma_ref)

})

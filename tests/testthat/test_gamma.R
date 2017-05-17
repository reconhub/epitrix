context("Testing gamma tools")

test_that("Switch between alternative parametrisation", {
    skip_on_cran()

    x <- gamma_mucv2shapescale(10, 4)
    y  <-  gamma_shapescale2mucv(x$shape, x$scale)

    expect_equal(y$mu, 10)
    expect_equal(y$cv, 4)

})

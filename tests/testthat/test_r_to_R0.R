
test_that("r to R0 gives expected results", {
  skip_on_cran()

  mu <- 15.3
  sigma <- 9.3
  param <- gamma_mucv2shapescale(mu, sigma / mu)

  w <- distcrete::distcrete("gamma", interval = 1,
                            shape = param$shape,
                            scale = param$scale, w = 0)

  res <- r2R0(c(-1, -0.001, 0, 0.001, 1), w)
  expect_snapshot(res)

  w <- c(0, 1)
  x <- 1:20
  y <- log(x^2.213)
  lm1 <- lm(y ~ x)

  set.seed(1)
  R0 <- lm2R0_sample(lm1, w)
  expect_snapshot(R0)

  w <- distcrete::distcrete("exp", rate = 0.1, interval = 1)
  R0 <- lm2R0_sample(lm1, w)
  expect_snapshot(R0)

})


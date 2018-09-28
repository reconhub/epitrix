context("Testing name hashing")

test_that("Hashing outputs as expected", {
    skip_on_cran()

    expect_equal_to_reference(hash_names(c("sweet", "baby", "jesus")),
                              file = "rds/hashref_1.rds")

    expect_equal_to_reference(hash_names(NA),
                              file = "rds/hashref_na.rds")

    expect_equal(nrow(hash_names(NULL)), 0L)

    expect_identical(hash_names("foo BaR "), hash_names("foobar"))

    expect_identical(hash_names("Pétèr and Stévën"),
                     hash_names("peter and steven"))

    expect_identical(hash_names("Pïôtr and ÿgòr"),
                     hash_names("píotr and YGÓR"))

    expect_is(hash_names("klsdfsdndsnjs"), "data.frame")
    expect_is(hash_names("klsdfsdndsnjs", full = FALSE), "character")
    expect_equal(
      nchar(hash_names("klsdfsdndsnjs", size = 6, full = FALSE)),
      6L)
    expect_equal(
      nchar(hash_names("klsdfsdndsnjs", size = 10, full = FALSE)),
      10L)

})




test_that("Hashing works with data.frame", {
    skip_on_cran()

    x <- data.frame(first = c("baba", "yaga"),
                    last = c("john", "wick"))

    expect_identical(hash_names(x$first, x$last),
                     hash_names(x[, 1, drop = FALSE],
                                x[, 2, drop = FALSE])
                     )
    expect_identical(hash_names(x$first),
                     hash_names(x[, 1, drop = FALSE])
                     )

})




test_that("Hashing with salting", {
    skip_on_cran()

    expect_true(!identical(hash_names(1), hash_names(1, salt = 1)))
    expect_true(!identical(hash_names(1, salt = 1), hash_names(1, salt = "2")))
    expect_equal_to_reference(hash_names("toto", salt = 123456),
                              file = "rds/hashref_salt.rds")

})

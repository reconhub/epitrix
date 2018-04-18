# epitrix 0.2.0

- added function `rename` which can be used to standardise labels in variables,
  removing non-ascii characters, standardising separators, and more; now used in
  `hash_names`
  


# epitrix 0.1.2

- added salting algorithm to `hash_names` (issue 1)

- fixed bug happening when using `tibble` inputs in `hash_names` (issue 2)



# epitrix 0.1.1

- `fit_disc_gamma` now also returns the fitted discretised gamma distribution as
  a `distcrete` object



# epitrix 0.1.0

First release of the package! This includes the following features:

- `fit_disc_gamma`: fit discretised gamma distribution

- `gamma_log_likelihood`: compute gamma log likelihood

- `gamma_mucv2shapescale`/`gamma_shapescale2mucv`: convert between different
  parametrisation of gamma distributions.

- `hash_names`: generate hashed ('anonymised') labels from individual data.

- `r2R0`: compute R0 from r

- `lm2R0_sample`: genrate samples of R0 from a log-linear regression





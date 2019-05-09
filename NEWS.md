# epitrix 0.3.0

## New Functions

 - `emperical_incubation_dist()` will estimate the empirical incubation
   distribution if given a data frame with dates of onset and a range of
   exposure dates (@ffinger, #13)
 - `fit_gamma_incubation_dist()` wraps `empirical_incubation_dist()` and 
   `fit_disc_gamma()` to fit a discretized gamma distribution to the empirical
   incubation distribution results (@ffinger, #13).

## New Vignettes

 - "Estimating Incubation Period" shows the use of empirical incubation dist.

## New Imports

 - functions from `dplyr`, `purrr`, `rlang`, and `tidyr` are now imported.

## Bug Fix

 - `clean_labels()` can now handle non-latin characters and gains the `trans_id`
   argument, which allows the user to customise the transformations 
   (see https://github.com/reconhub/epitrix/issues/19 for details).
 - `clean_labels()` gains the `protect` argument to protect meaningful symbols
   in the data.

# epitrix 0.2.2

 - Replace `digest` with `sodium` in Imports
 - Use `sodium::scrypt()` as a more cryptographically secure hashing algorithm
   for `hash_names()`. Thanks to @dirkschumacher for this addition. For details,
   see https://github.com/reconhub/epitrix/pull/7.
 - Fix LICENSE file to show who the copyright holder is.

# epitrix 0.2.1

- update documentation for compatibility with incidence 1.4.1

# epitrix 0.2.0

- added function `clean_labels` which can be used to standardise labels in variables,
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

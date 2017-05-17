
[![Build status](https://ci.appveyor.com/api/projects/status/0gb7evy0k4juox2b/branch/master?svg=true)](https://ci.appveyor.com/project/thibautjombart/epitrix/branch/master) [![Build Status](https://travis-ci.org/reconhub/epitrix.svg?branch=master)](https://travis-ci.org/reconhub/epitrix) [![CRAN\_Status\_Badge](http://www.r-pkg.org/badges/version/epitrix)](https://cran.r-project.org/package=epitrix)

Welcome to the *epitrix* package!
=================================

This package implements small helper functions usefull in infectious disease modelling and epidemics analysis.

Installing the package
----------------------

To install the current stable, CRAN version of the package, type:

``` r
install.packages("epitrix")
```

To benefit from the latest features and bug fixes, install the development, *github* version of the package using:

``` r
devtools::install_github("reconhub/epitrix")
```

Note that this requires the package *devtools* installed.

What does it do?
================

The main features of the package include:

-   **`gamma_shapescale2mucv`**: convert shape and scale of a Gamma distribution to mean and CV

-   **`gamma_mucv2shapescale`**: convert mean and CV of a Gamma distribution to shape and scale

-   **`gamma_log_likelihood`**: Gamma log-likelihood using mean and CV

-   **`r2R0`**: convert growth rate into a reproduction number

-   **`lm2R0_sample`**: generates a distribution of R0 from a log-incidence linear model

Resources
=========

Vignettes
---------

An overview and examples of *epitrix* are provided in the vignettes:

...

Websites
--------

The following websites are available:

...

Getting help online
-------------------

Bug reports and feature requests should be posted on *github* using the [*issue*](http://github.com/reconhub/epitrix/issues) system. All other questions should be posted on the **RECON forum**: <br> <http://www.repidemicsconsortium.org/forum/>

Contributions are welcome via **pull requests**.

Please note that this project is released with a [Contributor Code of Conduct](CONDUCT.md). By participating in this project you agree to abide by its terms.

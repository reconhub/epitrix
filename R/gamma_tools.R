#' Reparameterise Gamma distributions
#'
#' These functions permit to use alternate parametrisations for Gamma
#' distributions, from 'shape and scale' to 'mean (mu) and coefficient of
#' variation (cv), and back. \code{gamma_shapescale2mucv} does the first
#' conversion, while \code{gamma_mucv2shapescale} does the second. The function
#' \code{gamma_log_likelihood} is a shortcut for computing Gamma log-likelihood
#' with the alternative parametrisation (mean, cv). See 'details' for a guide of
#' which parametrisation to use.
#'
#' @details The gamma distribution is described in \code{?dgamma} is
#' parametrised using shape and scale (or rate). However, these parameters are
#' naturally correlated, which make them poor choices whenever trying to fit
#' data to a Gamma distribution. Their interpretation is also less clear than
#' the traditional mean and variance. When fitting the data, or reporting
#' results, it is best to use the alternative parametrisation using the mean
#' (\code{mu}) and the coefficient of variation (\code{cv}), i.e. the standard
#' deviation divided by the mean.
#'
#' @author Code by Anne Cori \email{a.cori@@imperial.ac.uk}, packaging by
#' Thibaut Jombart \email{thibautjombart@@gmail.com}
#'
#' @rdname gamma_tools
#'
#' @aliases gamma_shapescale2mucv
#' 
#' @return A named vector containing 'shape' and 'scale', or mean ('mean') and
#' coefficient of variation ('cv').
#'
#' @examples
#'
#' ## set up some parameters
#' 
#' mu <- 10
#' cv <- 1
#'
#' 
#' ## transoform into shape scale

#' #' tmp <- gamma_mucv2shapescale (mu, cv)
#' shape <- tmp$shape
#' scale <- tmp$scale
#'
#' 
#' ## do we recover the original parameters when applying the revert function?
#'
#' #' gamma_shapescale2mucv(shape, scale) # compare with mu, cv
#' 
#'
#' ## and do we get the correct mean / cv of a sample if we use rgamma with
#' ## shape and scale computed from mu and cv?
#' 
#' gamma_sample <- rgamma(n = 10000, shape = shape, scale = scale)
#' mean(gamma_sample) # compare to mu
#' sd(gamma_sample) / mean(gamma_sample) # compare to cv
#' 






#' @export
#' @rdname gamma_tools 
#' @param shape The shape parameter of the Gamma distribution.
#' @param scale The scale parameter of the Gamma distribution.

gamma_shapescale2mucv <- function(shape, scale) {
    mu <- shape * scale
    cv <- 1 / sqrt(shape)
    return(c(mu = mu, cv = cv))
}






#' @export
#' @rdname gamma_tools 
#' @param mu The mean of the Gamma distribution.
#' @param cv The coefficient of variation of the Gamma distribution, i.e. the
#' standard deviation divided by the mean.

gamma_mucv2shapescale <- function(mu, cv) {
    shape <- 1 / (cv^2)
    scale <- mu * cv^2
    return(c(shape = shape, scale = scale))
}




###############################################################################
# Log-likelihood function
###############################################################################

## 
## mu and cv are the parameters of the Gamma distribution to be estimated
#' @export
#' @rdname gamma_tools
#' 
#' @param x A vector of data treated as observations drawn from a Gamma
#' distribution, for which the likelihood is to be computed.
#'
log_likelihood_gamma <- function(x, mu, cv) {
    tmp <- gamma_mucv2shapescale (mu, cv)
    return( sum(  dgamma(x, shape=tmp$shape, scale = scale, log = TRUE) ) )
}

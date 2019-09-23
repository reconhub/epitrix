#' Fit discretised distributions using ML
#'
#' These functions performs maximum-likelihood (ML) fitting of a discretised
#' distribution. This is typically useful for describing delays between
#' epidemiological events, such as incubation period (infection to onset) or
#' serial intervals (primary to secondary onsets). The function
#' \code{\link{optim}} is used internally for fitting.
#'
#' @author Thibaut Jombart \email{thibautjombart@@gmail.com}
#' @author Charlie Whittaker \email{charles.whittaker16@@imperial.com}
#'
#' @export
#'
#' @aliases fit_discrete
#'
#' @seealso The \code{distcrete} package for discretising distributions, and
#' \code{\link{optim}} for details on available optimisation procedures.
#'
#'
#' @param x A vector of numeric data to fit; NAs will be removed with a warning.
#'
#' @param mu_ini The initial value for the mean 'mu', defaulting to the empirically
#'   calculated value. 
#'
#' @param cv_ini The initial value for the coefficient of variation 'cv',
#' defaulting to the empirically calculated value.
#'
#' @param interval The interval used for discretisation; see \code{\link{distcrete}}.
#'
#' @param w The centering of the interval used for discretisation; see
#' \code{\link{distcrete}}.
#'
#' @param ... Further arguments passed to \code{\link{optim}}.
#'
#' @return The function returns a list with human-readable parametrisation of
#'   the discretised Gamma distibution (mean, sd, cv), convergence indicators,
#'   and the discretised Gamma distribution itself as a \code{distcrete} object
#'   (from the \code{distcrete} package).
#'
#' @examples
#'
#' ## generate data
#'
#' mu <- 15.3 # days
#' sigma <- 9.3 # days
#' cv <- mu / sigma
#' cv
#' param <- gamma_mucv2shapescale(mu, cv)
#'
#' if (require(distcrete)) {
#' w <- distcrete("gamma", interval = 1,
#'                shape = param$shape,
#'                scale = param$scale, w = 0)
#'
#' x <- w$r(100)
#' x
#'
#' fit_disc_gamma(x)
#' }
#'

fit_disc_gamma <- function(x, mu_ini = NULL, cv_ini = NULL, interval = 1,
                           w = 0, ...) {

  ## Default policy: if 'x' includes NAs, we remove them and issue a warning.

  if (any(is.na(x))) {
    n_na <- sum(is.na(x))
    x <- stats::na.omit(x)
    warning(n_na, " NAs were removed from the data before fitting.")
  }
  
  ## Default policy: if 'x' includes negative values, throw error
  
  if (any(x < 0)) {
    stop("Data contains values < 0. Discretised gamma distribution cannot be fitted.")
  }
  
  ## Default policy: if mean of 'x' is not finite, throw error
  
  if (!is.finite(mean(x, na.rm = TRUE))) {
    stop("Mean of the data not finite. Remove instances of Inf.")
  }
  
  ## Default policy: if 'mu_ini' and 'cv_ini' are not specified, calculate
  ## the empirical values for the mean and coefficient of variation. If mean
  ## is 0, throw an error highlighting that the gamma distribution is 
  ## inappropriate here.
  
  if (is.null(mu_ini)) {
    mu_ini <- mean(x, na.rm = TRUE)
  }
  if (is.null(cv_ini)) {
    if (mu_ini == 0) {
      warning("Mean of data is 0. Gamma distribution is not appropriate.")
      mu_ini <- 1
      cv_ini <- 1
    } else {
      cv_ini <- sd(x, na.rm = TRUE) / mu_ini
    }
  }
  
  ## Fitting is achieved by minimizing the deviance. We return a series of
  ## outputs including human-readable parametrisation of the discretised gamma
  ## distribution, the final log-likelihood, and the distcrete object itself,
  ## which effectively is the fitted distribution.

  ll <- function(param) {
    gamma_log_likelihood(x, param[1], param[2],
                         discrete = TRUE, interval = interval, w = w)
  }
  deviance <- function(param) {
    -2 * ll(param)
  }

  optim_res <- stats::optim(c(mu_ini, cv_ini), deviance, ...)

  gamma_params <- gamma_mucv2shapescale(mu = optim_res$par[1],
                                        cv = optim_res$par[2])


  distribution <- distcrete::distcrete("gamma", interval = interval,
                                       shape = gamma_params$shape,
                                       scale = gamma_params$scale,
                                       w = w)
  out <- list(mu = optim_res$par[1],
              cv = optim_res$par[2],
              sd = optim_res$par[2] * optim_res$par[1],
              ll = - 0.5 * optim_res$value,
              converged = (optim_res$convergence == 0),
              distribution = distribution)

  return(out)
}


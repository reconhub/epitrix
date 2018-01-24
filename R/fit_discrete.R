#' Fit discretised distributions using ML
#'
#' These functions performs maximum-likelihood (ML) fitting of a discretised
#' distribution. This is typically useful for describing delays between
#' epidemiological events, such as incubation period (infection to onset) or
#' serial intervals (primary to secondary onsets). The function
#' \code{\link{optim}} is used internally for fitting.
#'
#' @author Thibaut Jombart \email{thibautjombart@@gmail.com}
#'
#' @export
#'
#' @aliases fit_discrete
#'
#' @seealso The \code{distcrete} package for discretising distributions, and
#' \code{\link{optim}} for details on available optimisation procedures.
#'
#'
#' @param x A vector of numeric data to fit.
#'
#' @param mu_ini The initial value for the mean 'mu', defaulting to 1.
#'
#' @param cv_ini The initial value for the coefficient of variation 'cv',
#' defaulting to 1.
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

fit_disc_gamma <- function(x, mu_ini = 1, cv_ini = 1, interval = 1,
                           w = 0, ...) {

  ## Fitting is achieved by minimizing the deviance. We return the a series of
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


#' Extract empirical incubation period distribution from linelist data
#'
#' This function takes in a linelist data frame and extracts the empirical
#' incubation period distribution and can take into account uncertain dates of
#' exposure. 
#'
#' @param x the linelist data (data.frame or linelist object) containing at
#'   least a column containing the exposure dates and one containing the onset
#'   dates. For exposure dates, each element can be a vector containing several
#'   possible exposure dates. Note that if the same exposure date appears twice
#'   in the list it is given twice as much weight.
#' @param dates_exposure the name of the column containing the exposure dates
#'   (bare variable name or in quotes)
#' @param date_of_onset the name of the column containing the onset dates (bare
#'   variable name or in quotes)
#' @return a data frame containing a column with the different incubation
#'   periods and a column containing their relative frequency
#' @author Flavio Finger, \email{flavio.finger@@lshtm.ac.uk}, Zhian N. Kamvar
#' @export
#' @importFrom dplyr pull
#' @importFrom rlang "!!" enquo
#' @examples
#' x <- linelist::clean_data(linelist::messy_data())
#'
#' mkexposures <- function(x) x - round(rgamma(sample.int(5, size = 1), shape = 12, rate = 3))
#' exposures <- sapply(x$date_of_onset, mkexposures)
#' x$dates_exposure <- exposures
#'
#' incubation_period_dist <- empirical_incubation_dist(x, dates_exposure, date_of_onset)
#'
empirical_incubation_dist  <- function(x, dates_exposure, date_of_onset) {
  #error checking
  if (!is.data.frame(x)) {
    stop("x is not a data.frame")
  }

  if (ncol(x) == 0L) {
    stop("x has no columns")
  }

  dates_exposure <- rlang::enquo(dates_exposure)
  date_of_onset <- rlang::enquo(date_of_onset)

  y <- compute_incubation(dplyr::pull(x, !!dates_exposure), dplyr::pull(x, !!date_of_onset))

  #check if incubation period is below 0
  if (any(y$incubation_period < 0)) {
    warning("negative incubation periods in data!")
  }

  return(y)
}

#' Compute the empirical incubation dist.
#' Can take into account uncertain dates of exposure.
#'
#' @param dates_exposure list containing the exposure dates. each element can
#' be a vector of several possible exposure dates.
#' @param date_onset list containing the exposure dates. each element can be a
#' vector of several dates.
#' @return a data frame containing a column with the different incubation
#' periods and a column containing their relative frequency
#' @author Flavio Finger, \email{flavio.finger@@lshtm.ac.uk}, Zhian N. Kamvar
#' @noRd
#' @importFrom dplyr mutate select pull
#' @importFrom rlang "!!"
#' @importFrom purrr map
#' @importFrom tidyr unnest complete full_seq
compute_incubation <- function(dates_exposure, date_onset){
  z <- data.frame(date_onset = date_onset,
                  weight = 1/lengths(dates_exposure)
                 )
  z$dates_exposure <- dates_exposure

  incubation_period <- quote(incubation_period) #to avoid note by R CMD check
  weight <- quote(weight) #to avoid note by R CMD check

  # In case the dates_exposure is a list column, we should expand this to
  # be able to effectively calculate the incubation period
  z <- tidyr::unnest(z, dates_exposure, .drop  = FALSE)
  z$incubation_period <- as.integer(z$date_onset - z$dates_exposure)

  # Calculating relative frequency of incubation period ------------------------
  res  <- z[c("incubation_period", "weight")] # only columns we need
  res  <- res[order(res$incubation_period), ] # arranging the incubation periods

  res  <- dplyr::group_by(res, incubation_period)
  sres <- dplyr::summarise(res, relative_frequency = sum(!!weight))
  sres <- dplyr::ungroup(sres)
  sres$relative_frequency <- sres$relative_frequency/sum(sres$relative_frequency)
  
  # ensuring that all incubation period ranges are displayed.
  sres <- tidyr::complete(sres, 
    incubation_period = tidyr::full_seq(!!incubation_period, 1),
    fill = list(relative_frequency = 0)
  )

  return(sres)
}

#' Fit discrite gamma distribution to incubation periods
#'
#' A wrapper around fit_disc_gamma to fit a discrete gamma distribution to
#' incubation periods derived from exposure and onset dates. Can take into
#' account uncertain dates of exposure.
#'
#' @inheritParams empirical_incubation_dist
#' @param nsamples The number of samples to draw from the empirical
#'    distribution to fit on (dafaults to 1000)
#' @param ... passed to fit_disc_gamma
#' @return see [fit_disc_gamma()]
#' @author Flavio Finger, \email{flavio.finger@@lshtm.ac.uk}
#' @export
#' @importFrom rlang "!!" enquo
#' @examples
#' x <- linelist::clean_data(linelist::messy_data())
#'
#' mkexposures <- function(x) x - round(rgamma(sample.int(5, size = 1), shape = 12, rate = 3))
#' exposures <- sapply(x$date_of_onset, mkexposures)
#' x$dates_exposure <- exposures
#'
#' fit <- fit_gamma_incubation_dist(x, dates_exposure, date_of_onset)
fit_gamma_incubation_dist <- function(x, dates_exposure, date_of_onset, nsamples = 1000, ...) {
  
  incubation_period_dist <- empirical_incubation_dist(x, !!rlang::enquo(dates_exposure), !!rlang::enquo(date_of_onset))

  if (nrow(incubation_period_dist) > 1) {
    s <- base::sample(
        incubation_period_dist$incubation_period,
        size = nsamples,
        replace = TRUE,
        prob = incubation_period_dist$relative_frequency
      )
  } else if (nrow(incubation_period_dist) == 1) {
    stop("incubation period is constant")
  }

  return(epitrix::fit_disc_gamma(s, ...))
}

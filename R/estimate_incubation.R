#' Function to extract the empirical incubation period distribution from line list data.
#' Can take into account uncertain dates of exposure.
#'
#' @param x the linelist data (data.frame or linelist object) containing at least a column containing the exposure dates and one containing the onset dates. For exposure dates, each element can be a list containing several possible exposure dates.
#' @param dates_exposure the name of the column containing the exposure dates.
#' @param dates_exposure the name of the column containing the onset dates
#' @return a data frame containing a column with the different incubation periods and a column containing their relative frequency
#' @author Flavio Finger, \email{flavio.finger@lshtm.ac.uk}
#' @export
empirical_incubation_dist  <- function(x, dates_exposure, date_of_onset) {
  #error checking
  if (!is.data.frame(x)) {
    stop("x is not a data.frame")
  }

  if (ncol(x)==0L) {
    stop("x has no columns")
  }

  dates_exposure <- rlang::enquo(dates_exposure)
  date_of_onset <- rlang::enquo(date_of_onset)

  y <- x %>%
    dplyr::select(!!dates_exposure, !!date_of_onset) %>%
    dplyr::mutate(weight = purrr::map(!!dates_exposure, function(foo) 1/length(foo))) %>%
    tidyr::unnest(!!dates_exposure, .drop  = FALSE) %>%
    dplyr::mutate(
      incubation_period = as.numeric(!!date_of_onset - !!dates_exposure),
      weight = as.numeric(weight)
    ) %>%
    dplyr::select(incubation_period, weight) %>%
    dplyr::ungroup() %>%
    dplyr::arrange(incubation_period) %>%
    dplyr::group_by(incubation_period) %>%
    dplyr::summarise(relative_frequency = sum(weight)) %>%
    dplyr::ungroup() %>%
    dplyr::mutate(relative_frequency = relative_frequency/sum(relative_frequency))


  #check if incubation period is below 0
  if (any(y$incubation_period < 0)){
    warning("negative incubation periods in data!")
  }

  return(y)
}


#' A wrapper around fit_disc_gamma to fit to fit a discrete gamma distribution to incubation periods derived from exposure and onset dates. Can take into account uncertain dates of exposure.
#' @inheritParams empirical_incubation_dist
#' @param nsamples The number of samples to draw from the empirical distribution to fit on (dafaults to 1000)
#' @param ... passed to fit_disc_gamma
#' @return see fit_disc_gamma
#' @author Flavio Finger, \email{flavio.finger@lshtm.ac.uk}
#' @export
fit_gamma_incubation_dist <- function(x, dates_exposure, date_of_onset, nsamples = 1000, ...) {
  incubation_period_dist <- empirical_incubation_dist(x, exposures, date_of_onset)

  s <- base::sample(
      incubation_period_dist$incubation_period,
      size = nsamples,
      replace = TRUE,
      prob = incubation_period_dist$relative_frequency
    )

  return(epitrix::fit_disc_gamma(s, ...))
}

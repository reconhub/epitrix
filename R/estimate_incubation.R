#' Extract empirical incubation period distribution from linelist data
#'
#' This function takes in a linelist data frame and extracts the empirical
#' incubation period distribution and can take into account uncertainty in the
#' dates of exposure.
#'
#' @param x the linelist data (data.frame or linelist object) containing at
#'   least a column containing the exposure dates and one containing the onset
#'   dates.
#' @param date_of_onset the name of the column containing the onset dates (bare
#'   variable name or in quotes)
#' @param exposure the name of the column containing the exposure dates
#'   (bare variable name or in quotes)
#' @param exposure_end the name of a column containing dates representing the
#'   end of the exposure period. This is `NULL` by default, indicating
#'   all exposures are known and in the `exposure` column.
#' @return a data frame containing a column with the different incubation
#'   periods and a column containing their relative frequency
#' @note For exposure dates, each element can be a vector containing several
#'   possible exposure dates. Note that if the same exposure date appears twice
#'   in the list it is given twice as much weight.
#' @author Flavio Finger, \email{flavio.finger@@lshtm.ac.uk}, Zhian N. Kamvar
#' @export
#' @importFrom dplyr pull
#' @importFrom rlang "!!" enquo get_expr
#' @examples
#' if (require(tibble)) {
#' random_dates <- as.Date("2020-01-01") + sample(0:30, 50, replace = TRUE)
#' x <- tibble(date_of_onset = random_dates)
#'
#' # Linelist with a list column of potential exposure dates ------------------
#' mkexposures <- function(x) x - round(rgamma(sample.int(5, size = 1), shape = 12, rate = 3))
#' exposures <- sapply(x$date_of_onset, mkexposures)
#' x$date_exposure <- exposures
#'
#' incubation_period_dist <- empirical_incubation_dist(x, date_of_onset, date_exposure)
#' incubation_period_dist
#'
#' # Linelist with exposure range ---------------------------------------------
#' start_exposure   <- round(rgamma(nrow(x), shape = 12, rate = 3))
#' end_exposure     <- round(rgamma(nrow(x), shape = 12, rate = 7))
#' x$exposure_end   <- x$date_of_onset - end_exposure
#' x$exposure_start <- x$exposure_end - start_exposure
#' incubation_period_dist <- empirical_incubation_dist(x, date_of_onset, exposure_start, exposure_end)
#' incubation_period_dist
#' plot(incubation_period_dist,
#'      type = "h", lwd = 10, lend = 2, col = "#49D193",
#'      xlab = "Days since exposure",
#'      ylab = "Probability",
#'      main = "Incubation time distribution")
#' }
empirical_incubation_dist  <- function(x, date_of_onset, exposure, exposure_end = NULL) {
  #error checking
  if (!is.data.frame(x)) {
    stop("x is not a data.frame")
  }

  if (ncol(x) == 0L) {
    stop("x has no columns")
  }

  # prepare column names for transfer
  exposure      <- rlang::enquo(exposure)
  date_of_onset <- rlang::enquo(date_of_onset)
  exposure_end  <- rlang::enquo(exposure_end)
  end_is_here   <- !is.null(rlang::get_expr(exposure_end))

  # Make sure that all the columns actually exist
  cols <- c(rlang::quo_text(date_of_onset),
            rlang::quo_text(exposure),
            rlang::quo_text(exposure_end))
  cols <- cols[cols != "NULL"]
  if (!all(cols %in% names(x))) {
    msg  <- "%s is not a column in %s"
    cols <- cols[!cols %in% names(x)]
    msg  <- sprintf(msg, cols, deparse(substitute(x)))
    stop(paste(msg, collapse = "\n  "))
  }

  # Grab the values from the columns
  doo   <- dplyr::pull(x, !! date_of_onset)
  expos <- dplyr::pull(x, !! exposure)

  if (!inherits(doo, "Date")) {
    msg <- "date_of_onset must be a column of Dates. I found a column of class %s"
    stop(sprintf(msg, paste(class(doo), collapse = ", ")))
  }

  if (end_is_here) {
    # We need to create the list for each date
    if (is.list(expos) || !inherits(expos, "Date")) {
      stop("if exposure_end is specified, then exposure must be a vector of Dates")
    }
    e     <- expos
    ee    <- dplyr::pull(x, !! exposure_end)
    expos <- vector(mode = "list", length = length(e))
    for (i in seq(expos)) {
      expos[[i]] <- seq(from = e[i], to = ee[i], by = "1 day")
    }
  }

  y <- compute_incubation(doo, expos)

  # check if incubation period is below 0
  if (any(y$incubation_period < 0)) {
    warning("negative incubation periods in data!")
  }

  return(y)
}





#' Compute the empirical incubation dist.
#' Can take into account uncertain dates of exposure.
#'
#' @param exposure list containing the exposure dates. each element can
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
compute_incubation <- function(date_onset, exposure){
  z <- data.frame(date_onset = date_onset,
                  weight = 1/lengths(exposure)
                 )
  z$exposure <- exposure

  incubation_period <- quote(incubation_period) #to avoid note by R CMD check
  weight <- quote(weight) #to avoid note by R CMD check

  # In case the exposure is a list column, we should expand this to
  # be able to effectively calculate the incubation period
  z <- tidyr::unnest(z, exposure)
  z$incubation_period <- as.integer(z$date_onset - z$exposure)

  # Calculating relative frequency of incubation period ------------------------
  res  <- z[c("incubation_period", "weight")] # only columns we need
  res  <- res[order(res$incubation_period), ] # arranging the incubation periods

  res  <- dplyr::group_by(res, !! incubation_period)
  sres <- dplyr::summarise(res, relative_frequency = sum(!! weight))
  sres <- dplyr::ungroup(sres)
  sres$relative_frequency <- sres$relative_frequency/sum(sres$relative_frequency)

  # ensuring that all incubation period ranges are displayed.
  sres <- tidyr::complete(sres,
    incubation_period = tidyr::full_seq(c(0, !! incubation_period), 1),
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
#'
#' random_dates <- as.Date("2020-01-01") + sample(0:30, 50, replace = TRUE)
#' x <- data.frame(date_of_onset = random_dates)
#'
#' mkexposures <- function(x) x - round(rgamma(sample.int(5, size = 1), shape = 12, rate = 3))
#' exposures <- sapply(x$date_of_onset, mkexposures)
#' x$date_exposure <- exposures
#'
#' fit <- fit_gamma_incubation_dist(x, date_of_onset, date_exposure)
#' plot(0:20, fit$distribution$d(0:20),
#'      type = "h", lwd = 10, lend = 2, col = "#49D193",
#'      xlab = "Days since exposure",
#'      ylab = "Probability",
#'      main = "Incubation time distribution")
#' 
fit_gamma_incubation_dist <- function(x, date_of_onset, exposure, exposure_end = NULL, nsamples = 1000, ...) {

  incubation_period_dist <- empirical_incubation_dist(
    x,
    !!rlang::enquo(date_of_onset),
    !!rlang::enquo(exposure),
    !!rlang::enquo(exposure_end))

  if (sum(incubation_period_dist$relative_frequency > 0) > 1) {
    s <- base::sample(
        incubation_period_dist$incubation_period,
        size = nsamples,
        replace = TRUE,
        prob = incubation_period_dist$relative_frequency
      )
  } else {
    stop("incubation period is constant")
  }

  return(epitrix::fit_disc_gamma(s, ...))
}

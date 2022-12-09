#' Simulate simple linelist data
#'
#' This function simulates a simple linelist data including dates of
#' epidemiological events and basic patient information. No underlying
#' epidemiological model is used.
#'
#' @export
#'
#' @author Thibaut Jombart \email{thibautjombart@@gmail.com}
#'
#' @param n Number of entries to simulate.
#'
#' @param onset_from The earliest date of symptom onset which can be generated.
#'
#' @param onset_span The time span over which to generate dates of onset.
#'
#' @param report_delay The mean delay between onset and reporting, using a
#'   Poisson distribution.
#'
#' @param cfr The case fatality ratio, i.e. the proportion of patient dying from
#'   the infection (used to generate the 'outcome' variable).
#'
#' @examples
#' sim_linelist(10)


sim_linelist <- function(n = 1,
                         onset_from = as.Date("2020-01-01"),
                         onset_span = 60,
                         report_delay = 7,
                         cfr = 0.1) {
  if (n < 0) stop("n cannot be negative")
  if (onset_span < 1) stop("onset_span cannot be less than 1")
  if (report_delay < 0) stop("report_delay cannot be negative")
  if (cfr < 0) stop("cfr cannot be negative") 
  if (cfr > 1) stop("cfr cannot be greater than 1")
   
  out <- data.frame(id = seq_len(n))

  ## dates of onset
  pool_onset <- seq(from = onset_from, by = 1L, length.out = onset_span)
  out$date_of_onset <- sample(pool_onset, n, replace = TRUE)

  ## dates of reporting
  out$date_of_report <- out$date_of_onset + stats::rpois(n, report_delay)
  
  ## gender
  pool_gender <- c("male", "female")
  out$gender <- sample(pool_gender, n, replace = TRUE)

  ## outcome
  pool_outcome <- c("recovery", "death")
  prob_outcome <- c(1 - cfr, cfr)
  out$outcome <- sample(pool_outcome, n, replace = TRUE, prob = prob_outcome)

  out
}

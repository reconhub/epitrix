#' Title Calculate basic reproduction number from attack rate
#'
#' @param AR the attack rate; a value or vector of values between 0 and 1
#'
#' @return R0, the basic reproduction number, calculated as -log(1-AR)/AR
#' @export
#'
#' @examples
#' 
#' ## Calculate R0 for an attack rate of 50%
#' AR2R0(0.5)
#' 
#' ## plot the relationship between R0 and attack rate
#' x <- seq(0.01, 1, 0.01)
#' plot(AR2R0(x), x, type = "l", xlab = "R0", ylab = "Attack rate")
#' 
AR2R0 <- function(AR) {
    if (any(AR < 0 | AR > 1)) {
      stop("AR should contain numeric values between 0 and 1")
    }
    R0 <- rep(NA, length(AR))
    R0[AR == 0] <- 0
    R0[AR == 1] <- Inf
    non_0_1 <- AR > 0 & AR < 1
    R0[non_0_1] <- - log(1 - AR[non_0_1]) / AR[non_0_1]
    return(R0)
}

#' Title Calculate attack rate from basic reproduction number
#'
#' @param R0 a value or vector of values representing the basic reproduction 
#' number, must be >=0
#' @param tol a single >=0 value giving the tolerance for the calculated attack 
#' rate
#'
#' @return AR, the attack rate, calculated using the relationship: 
#' R0 = -log(1-AR)/AR
#' @export
#'
#' @examples
#' 
#' ## Calculate the attack rate for a specific value of the reproduction number
#' R02AR(2) # returns the AR for an R0 of 2
#' 
#' ## plot the relationship between R0 and attack rate
#' x <- seq(1.01, 5, 0.01)
#' plot(x, R02AR(x), type = "l", xlab = "R0", ylab = "Attack rate")
#' 
R02AR <- function(R0, tol = 0.01) {
  if (any(R0 < 0)) {
    stop("R0 should contain numeric values >= 0")
  }
  if(length(tol) > 1) stop("tol must be a single numeric value")
  if(tol <= 0) stop("tol must be > 0.")
  AR_grid <- seq(0, 1, tol)
  R0_grid <- AR2R0(AR_grid)
  AR_idx <- vapply(R0, function(e) which.min(abs(R0_grid - e)), 1)
  AR <- AR_grid[AR_idx]
  AR[R0 == 0] <- 0
  AR[R0 == Inf] <- 1
  return(AR)
}

#' Title Calculate herd immunity threshold from basic reproduction number
#'
#' @param R0 a value or vector of values representing the basic reproduction 
#' number, must be >=0
#'
#' @return The herd immunity threshold, calculated as 1 - 1 / R0
#' @export
#'
#' @examples
#' 
#' ## Calculate the herd immunity threshold for a specific value of the 
#' ## reproduction number (here 2)
#' R02herd_immunity_threshold(2) 
#' 
#' ## plot the relationship between R0 and herd immunity threshold
#' x <- seq(1.01, 15, 0.01)
#' plot(x, R02herd_immunity_threshold(x), type = "l", 
#'   xlab = "R0", ylab = "Herd immunity threshold")
#' 
R02herd_immunity_threshold <- function(R0) {
  if (any(R0 < 0)) {
    stop("R0 should contain numeric values >= 0")
  }
  out <- rep(NA, length(R0))
  out[R0 <= 1] <- 0
  out[R0 == Inf] <- 1
  all_other_values <- R0 > 1 & R0 < Inf
  out[all_other_values] <- 1 - 1 / R0[all_other_values]
  return(out)
}

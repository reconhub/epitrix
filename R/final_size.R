#' Title Calculate basic reproduction number from attack rate
#'
#' @param AR the attack rate; a value or vector of values between 0 and 1
#'
#' @return R0, the basic reproduction number, calculated as -log(1-AR)/AR
#' @export
#'
#' @examples
#' 
#' ## Calculate R0 for a specific value of the attack rate
#' AR2R0(0.5) # returns the basic reproduction number which would yield an 
#' attack rate of 50%
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

## TODO: add the reverse function R0 to AR with a grid search
## TODO: add a similar function with herd immunity threshold
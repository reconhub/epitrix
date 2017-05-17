
#' Transform a growth rate into a reproduction number
#'
#' The function \code{r2R0} can be used to transform a growth rate into a
#' reproduction number estimate, given an serial interval distribution. The
#' function \code{lm2R0_sample} generates a sample of R0 values from a
#' log-linear regression of incidence data stored in a \code{lm} object.
#'
#' @details It is assumed that the growth rate ('r') is measured in the same
#' time unit as the serial interval ('w' is the SI distribution, starting at
#' time 0).
#'
#' 
#' @author Code by Anne Cori \email{a.cori@@imperial.ac.uk}, packaging by
#' Thibaut Jombart \email{thibautjombart@@gmail.com}
#'
#'
#' @examples
#' 
#' ## Ebola estimates of the SI distribution from the first 9 months of
#' ## West-African Ebola oubtreak
#' 
#' mu <- 15.3 # days
#' sigma <- 9.3 # days
#' param <- gamma_mucv2shapescale(mu, sigma/mu)
#' 
#' if (require(distcrete)) {
#'   w <- distcrete("gamma", interval = 1,
#'                  shape = param$shape,
#'                  scale = param$scale, w = 0)
#' 
#'   r2R0(c(-1, -0.001, 0, 0.001, 1), w)
#'
#' 
#' ## Use simulated Ebola outbreak and 'incidence' to get a log-linear
#' ## model of daily incidence.
#' 
#'   if (require(outbreaks) && require(incidence)) {
#'     i <- incidence(ebola_sim$linelist$date_of_onset)
#'     plot(i)
#'     f <- fit(i[1:100])
#'     f
#'     plot(i[1:150], fit = f)
#'
#'     R0 <- lm2R0_sample(f$lm, w)
#'     hist(R0, col = "grey", border = "white", main = "Distribution of R0")
#'     summary(R0)   
#'   }
#' }
#'



#' @rdname r2R0
#' @export
#' @aliases r2R0
#' 
#' @param r A vector of growth rate values.
#'
#' @param w The serial interval distribution, either provided as a
#' \code{distcrete} object, or as a \code{numeric} vector containing
#' probabilities of the mass functions.
#'
#' @param trunc The number of time units (most often, days), used for truncating
#' \code{w}, whenever a \code{distcrete} object is provided. Defaults to 1000.

r2R0 <- function(r, w, trunc = 1000) {

    if (inherits(w, "distcrete")) {
        w <- w$d(0:trunc)
    }
    w <- w / sum(w)
    
    out <- r
    near_0 <- 1e-14
    r_is_0 <- abs(r) < near_0
    
    out[r_is_0] <- 1

    
    ## Wallinga and Lipsitch formula
    
    get_R0_from_r <- function(r) {
        ## t: the time steps corresponding to the serial interval distribution
        
        t <- c(0, seq(0.5, length(w) - 0.5, 1)) 
        if (exp(-r*t[length(t)]) == Inf) {
            R0 <- 0
        } else {
            denom <- - ( w * diff(exp(-r*t)) / diff(t) )
            R0 <- r / sum(denom)
        }
        return(R0)
    }
    
    out[!r_is_0] <- vapply(r[!r_is_0], get_R0_from_r, NA_real_)
    
    return(out)
}





#' @rdname r2R0
#' @export
#' @aliases r2R0_sample
#' 
#' @param x A \code{lm} object storing a a linear regression of log-incidence over time.
#'
#' @param n The number of draws of R0 values, defaulting to 1000.

lm2R0_sample <- function(x, w, n = 1000) {

    ## The strategy here is simple:
    ##
    ## 'r' estimates follow a Student t distribution, so that we can draw values
    ## of 'r' from it, and then convert them to R0 using r2R0.
    
    df <- nrow(x$model) - 2 # degrees of freedom of t distribution
    r <- x$coefficients[2]
    std_r <- stats::coef(summary(x))[, "Std. Error"][2]
  
    r_sample <- r + std_r * stats::rt(n, df)

    out <- r2R0(r_sample, w) 
    return(out) 
}


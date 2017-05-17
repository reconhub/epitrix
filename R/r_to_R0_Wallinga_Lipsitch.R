###############################################################################
# Author: annecori
###############################################################################

#######################################################################################################################
### function to transform a growth rate into a reproduction number estimate, given a serial interval distribution
#######################################################################################################################
r2R0_point_estimates <- function(r, w) # assumes the growth rate r is measured in the same time unit as the serial interval (w is the SI distribution, starting at time 0)
{
  if(sum(w) != 1)
  {
    warning("rescaling the serial interval distribution to sum to 1")
    w <- w / sum(w)
  }
  
  R0 <- r

  R0[r %in% 0] <- 1
  
  # Wallinga and Lipsitch formula
  get_R0_from_r <- function(r) 
  {
    t <- c(0, seq(0.5, length(w) - 0.5, 1)) # the time steps corresponding to the serial interval distribution
    if(exp(-r*t[length(t)]) == Inf)
    {
      R0 <- 0
    }else
    {
      denom <- - ( w * diff(exp(-r*t)) / diff(t) )
      R0 <- r / sum(denom)
    }
  }
  
  R0[!(r %in% 0)] <- sapply(r[!(r %in% 0)], get_R0_from_r)
  
  return (R0)
}

### examples
## Ebola estimates of the SI distribution from our first NEJM paper # note later estimates are a bit different
# mu <- 15.3 # days
# sigma <- 9.3 # days
# w <- sapply(0:50, function(k) EpiEstim::DiscrSI(k, mu, sigma) ) # the serial interval distribution, in days, starting on day 0

# R0_point_estimate <- r2R0_point_estimates(c(-1, -0.001, 0, 0.001, 1), w)

#######################################################################################################################
### function to transform the output of the linear regression in a sample of R0 from which median but also CI can be derived, given a serial interval distribution
#######################################################################################################################
r2R0_sample <- function(lm_res, w, n = 1000) # assumes lm_res is the output of the linear model used to estimate the growth rate r, measured in the same time unit as the serial interval (w is the SI distribution, starting at time 0)
{
  # n is used for numerical sampling from the t distribution of the estimated slope of the linear regression
  df <- nrow(lm.res$model) - 2 # degrees of freedom of t distribution
  
  # central estimate of r and estimate of std of r
  r <- lm_res$coefficients[2]
  std_r <- coef(summary(lm_res))[, "Std. Error"][2]
  
  r_sample <- r + std_r*rt(n, df)
  
  return(r2R0_point_estimates(r_sample, w)) 
}

### examples

## mock incidence data
# I <- c(3,4,6,12,20,20,25,35,34,30,20,15,14,2)

## linear regression on the log scale at the maximum slope
# delta <- diff(log(I))
# idx <- which.max(delta)
# tmp_dat <- data.frame(t = 1:3, logI = log(I[(idx-1):(idx+1)]))
# lm_res <- lm(logI~t,data=tmp_dat)

## use result of linear regression to derive not only central estimate but also 95%CI
# R0_point_estimate <- r2R0_point_estimates(r = lm_res$coefficients[2], w)
# R0_sample <- r2R0_sample(lm_res, w, n = 1000)
# median(R0_sample) # compare with R0_point_estimate
# quantile(R0_sample, c(0.025, 0.975))


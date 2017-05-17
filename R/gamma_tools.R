###############################################################################
# Author: annecori
###############################################################################

###############################################################################
# Reparameterise the Gamma
###############################################################################

gamma_shapescale2muCV <- function(shape, scale)
{
    mu <- shape * scale
    CV <- 1 / sqrt(shape)
    return(data.frame(mu = mu, CV = CV))
}

gamma_muCV2shapescale <- function(mu, CV)
{
    shape <- 1 / (CV^2)
    scale <- mu * CV^2
    return(data.frame(shape = shape, scale = scale))
}

### checks:

## set up some parameters
# mu <- 10
# CV <- 1

## transoform into shape scale
# tmp <- gamma_muCV2shapescale (mu, CV)
# shape <- tmp$shape
# scale <- tmp$scale

## do we recover the original parameters when applying the revert function?
# gamma_shapescale2muCV(shape, scale) # compare with mu, CV

## and do we get the correct mean / CV of a sample if we use rgamma with shape and scale computed from mu and CV?
# gamma_sample <- rgamma(n = 10000, shape = shape, scale = scale)
# mean(gamma_sample) # compare to mu
# sd(gamma_sample) / mean(gamma_sample) # compare to CV

###############################################################################
# Log-likelihood function
###############################################################################

## dat is a vector of observations assumed drawn from a Gamma distribution
## mu and CV are the parameters of the Gamma distribution to be estimated
log_likelihood_gamma <- function(dat, mu, CV)
{
    tmp <- gamma_muCV2shapescale (mu, CV)
	return( sum(  dgamma(dat, shape=tmp$shape, scale = scale, log = TRUE) ) )
}

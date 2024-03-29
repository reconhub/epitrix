% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/final_size.R
\name{AR2R0}
\alias{AR2R0}
\title{Title Calculate basic reproduction number from attack rate}
\usage{
AR2R0(AR)
}
\arguments{
\item{AR}{the attack rate; a value or vector of values between 0 and 1}
}
\value{
R0, the basic reproduction number, calculated as -log(1-AR)/AR
}
\description{
Title Calculate basic reproduction number from attack rate
}
\examples{

## Calculate R0 for an attack rate of 50\%
AR2R0(0.5)

## plot the relationship between R0 and attack rate
x <- seq(0.01, 1, 0.01)
plot(AR2R0(x), x, type = "l", xlab = "R0", ylab = "Attack rate")

}

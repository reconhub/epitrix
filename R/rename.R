#' Standardise labels
#'
#' This function standardises labels e.g. used as variable names or character
#' string values, removing non-ascii characters, replacing diacritics (e.g. é,
#' ô) with their closest ascii equivalents, and standardises separating
#' characters. See details for more information on label transformation.\cr
#'
#' @details
#'
#' The following changes are performed:
#'
#' \itemize{
#'
#' \item all non-ascii characters are removed
#'
#' \item all diacritics are replaced with their non-accentuated equivalents,
#' e.g. 'é', 'ê' and 'è' become 'e', 'ö' becomes 'o', etc.
#'
#' \item all characters are set to lower case
#'
#' \item separators are standardised to the use of a single character provided
#' in \code{sep} (defaults to '_'); heading and trailing separators are removed.
#'
#' }
#'
#
#' @author Thibaut Jombart \email{thibautjombart@@gmail.com}
#'
#' @export
#'
#' @param x A vector of labels, normally provided as characters.
#'
#' @param sep A character string used as separator, defaulting to '_'.
#'
#' @examples
#'
#' rename("-_-This is; A    WeÏrD**./sêntënce...")
#' rename("-_-This is; A    WeÏrD**./sêntënce...", sep = ".")
#' input <- c("Peter and stëven", "peter-and.stëven", "pëtêr and stëven  _-")
#' input
#' rename(input)
#'

rename <- function(x, sep = "_") {
  x <- as.character(x)
  
  ## On the processing of the input:

  ## - coercion to lower case
  ## - replace accentuated characters by closest matches
  ## - replace non-alphanumeric characters by 'sep'
  ## - remove starting / trailing seps

  out <- tolower(x)
  out <- stringi::stri_trans_general(out, "latin-ASCII")
  out <- gsub("[^a-z0-9]+", sep, out)
  out <- sub("^[^a-z0-9]+", "", out)
  out <- sub("[^a-z0-9]+$", "", out)
  out
}

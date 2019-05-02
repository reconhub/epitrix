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
#' e.g. 'é', 'ê' and 'è' become 'e', 'ö' becomes 'oe', etc.
#'
#' \item all characters are set to lower case
#'
#' \item separators are standardised to the use of a single character provided
#' in \code{sep} (defaults to '_'); heading and trailing separators are removed.
#'
#' }
#'
#
#' @author Thibaut Jombart \email{thibautjombart@@gmail.com}, Zhian N. Kamvar
#'
#' @export
#'
#' @param x A vector of labels, normally provided as characters.
#'
#' @param sep A character string used as separator, defaulting to '_'.
#' 
#' @param trans_id a string to be passed on to [stringi::stri_trans_general()]
#'   for conversion. Default is "Any-Latin; de-ASCII; Latin-ASCII", which will
#'   convert any non-latin characters to latin, then convert any German accents
#'   to their proper equivalents, and then converts all accented characters to
#'   ASCII characters. See [stringi::stri_trans_list()] for a full list of 
#'   options.
#'
#' @md
#'
#' @examples
#'
#' clean_labels("-_-This is; A    WeÏrD**./sêntënce...")
#' clean_labels("-_-This is; A    WeÏrD**./sêntënce...", sep = ".")
#' input <- c("ますだ, よしひこ", "Peter and stëven", "peter-and.stëven", "pëtêr and stëven  _-")
#' input
#' clean_labels(input)
#'
clean_labels <- function(x, sep = "_", trans_id = "Any-Latin; de-ASCII; Latin-ASCII") {
  x <- as.character(x)
  
  ## On the processing of the input:

  ## - coercion to lower case
  ## - replace accentuated characters by closest matches
  ## - replace non-alphanumeric characters by 'sep'
  ## - remove starting / trailing seps

  out <- tolower(x)
  out <- stringi::stri_trans_general(out, id = trans_id)
  out <- gsub("[^a-z0-9]+", sep, out)
  out <- sub("^[^a-z0-9]+", "", out)
  out <- sub("[^a-z0-9]+$", "", out)
  out
}

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
#'
#'  - all non-ascii characters are removed
#'  - all diacritics are replaced with their non-accentuated equivalents,
#'    e.g. 'é', 'ê' and 'è' become 'e'.
#'  - all characters are set to lower case
#'  - separators are standardised to the use of a single character provided
#'    in `sep` (defaults to '_'); heading and trailing separators are removed.
#'
#'  
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
#'   for conversion. Default is "Any-Latin; Latin-ASCII", which will convert
#'   any non-latin characters to latin and then converts all accented
#'   characters to ASCII characters. See [stringi::stri_trans_list()] for a
#'   full list of options.
#'
#' @md
#' @note Because of differences between the underlying transliteration engine
#'   (ICU), the default transformations will not transilierate German umlaute
#'   correctly. You can add them by specifying "de-ASCII" in the `trans_id` 
#'   string after "Any-Latin".
#'
#' @examples
#'
#' clean_labels("-_-This is; A    WeÏrD**./sêntënce...")
#' clean_labels("-_-This is; A    WeÏrD**./sêntënce...", sep = ".")
#' input <- c("ますだ, よしひこ", "Peter and stëven", "peter-and.stëven", "pëtêr and stëven  _-")
#' input
#' clean_labels(input)
#' if (stringi::stri_info()$ICU.system) {
#'   # This will only be true if you have the correct version of ICU installed
#'
#'   clean_labels("'é', 'ê' and 'è' become 'e', 'ö' becomes 'oe', etc.", 
#'                trans_id = "Any-Latin; de-ASCII; Latin-ASCII")
#' }
#'
clean_labels <- function(x, sep = "_", trans_id = "Any-Latin; Latin-ASCII") {
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

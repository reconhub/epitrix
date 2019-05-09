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
#'  - all non-ascii characters are removed
#'  - all diacritics are replaced with their non-accentuated equivalents,
#'    e.g. 'é', 'ê' and 'è' become 'e'.
#'  - all characters are set to lower case
#'  - separators are standardised to the use of a single character provided
#'    in `sep` (defaults to '_'); heading and trailing separators are removed.
#'
#' @author Thibaut Jombart \email{thibautjombart@@gmail.com}, Zhian N. Kamvar
#'
#' @export
#'
#' @param x A vector of labels, normally provided as characters.
#'
#' @param sep A character string used as separator, defaulting to '_'.
#' 
#' @param transformation a string to be passed on to [stringi::stri_trans_general()]
#'   for conversion. Default is "Any-Latin; Latin-ASCII", which will convert
#'   any non-latin characters to latin and then converts all accented
#'   characters to ASCII characters. See [stringi::stri_trans_list()] for a
#'   full list of options.
#' @param protect a character string defining the punctuation that should be
#'   protected. This helps prevent meaninful symbols like > and < from being
#'   removed.
#'
#' @md
#' @note Because of differences between the underlying transliteration engine
#'   (ICU), the default transformations will not transilierate German umlaute
#'   correctly. You can add them by specifying "de-ASCII" in the `transformation` 
#'   string after "Any-Latin".
#'
#' @examples
#'
#' clean_labels("-_-This is; A    WeÏrD**./sêntënce...")
#' clean_labels("-_-This is; A    WeÏrD**./sêntënce...", sep = ".")
#' input <- c("ますだ, よしひこ", "Peter and stëven", "peter-and.stëven", "pëtêr and stëven  _-")
#' input
#' clean_labels(input)
#' 
#' # Don't transliterate non-latin words
#' clean_labels(input, transformation = "Latin-ASCII")
#'
#' # protect useful symbols
#' clean_labels(c("energy > 9000", "energy < 9000"), protect = "><")
#'
#' # if you only want to clean accents, transform to lower, and transliterate,
#' # you can specify "[:punct:][:space:]" for protect:
#' clean_labels(input, protect = "[:punct:][:space:]")
#' 
#' # appropriately transliterate Germanic umlaute
#' if (stringi::stri_info()$ICU.system) {
#'   # This will only be true if you have the correct version of ICU installed
#'
#'   clean_labels("'é', 'ê' and 'è' become 'e', 'ö' becomes 'oe', etc.", 
#'                transformation = "Any-Latin; de-ASCII; Latin-ASCII")
#' }
#'
clean_labels <- function(x, sep = "_", transformation = "Any-Latin; Latin-ASCII",
                         protect = "") {
  x <- as.character(x)
  
  ## On the processing of the input:

  ## - coercion to lower case
  ## - replace accentuated characters by closest matches
  ## - replace punctuation and spaces not in the protected list with sep, cautiously
  ## - remove starting / trailing seps
  sep <- gsub("([.*?])", "\\\\\\1", sep)

  out <- tolower(x)
  out <- stringi::stri_trans_general(out, id = transformation)
  # Negative lookahead for alphanumeric and any protected symbols
  to_protect <- sprintf("(?![a-z0-9%s])", paste(protect, collapse = ""))
  # If the negative lookahead doesn't find what it's looking for, then do the
  # replacement. 
  to_replace <- sprintf("%s[[:punct:][:space:]]+?", to_protect)
  
  # workhorse
  out <- gsub(to_replace, sep, out, perl = TRUE)
  out <- gsub(paste0("(", sep, ")+"), sep, out, perl = TRUE)
  out <- sub(paste0("^", sep), "", out, perl = TRUE)
  out <- sub(paste0(sep, "$"), "", out, perl = TRUE)
  out
}

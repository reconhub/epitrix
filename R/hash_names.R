#' Anonymise data using SHA1
#'
#' This function uses SHA1 algorithm to anonymise data, based on pre-specified
#' data fields. Data fields are concatenated first, then each entry is
#' hashed. The function can either return a full detailed output, or short
#' anonymous labels. \cr
#'
#' Once concatenated (using "_" as a separator), the labels are modified as
#' follows:
#'
#' \itemize{
#'  \item all spaces and non-alphanumeric characters are removed
#'  \item all non-ascii characters are removed
#'  \item all characters are set to lower case
#' }
#'
#'
#' @author Thibaut Jombart \email{thibautjombart@@gmail.com}
#'
#' @export
#'
#' @param ... Data fields to be hashed.
#'
#' @param size The number of characters retained in the hash.
#'
#' @param full A logical indicating if the a full output should be returned as a
#'   \code{data.frame}, including original labels, shortened hash, and full
#'   hash.
#'
#' @examples
#'
#' first_name <- c("Jane", "Joe", "Raoul")
#' last_name <- c("Doe", "Smith", "Dupont")
#' age <- c(25, 69, 36)
#'
#' hash_names(first_name, last_name, age)
#'
#' hash_names(first_name, last_name, age,
#'            size = 8, full = FALSE)
#'

hash_names <- function(..., size = 6, full = TRUE) {
  x <- list(...)

  ## On the processing of the input:

  ## - we remove blanks and special characters
  ## - coercion to lower case

  paste_ <- function(...) paste(..., sep = "_")
  lab <- do.call(paste_, x)
  lab <- tolower(lab)
  lab <- gsub("[^a-z0-9]", "", lab)

  hash <- vapply(lab, digest::sha1, NA_character_)
  hash_short <- substr(hash, 1, size)

  if (full) {
    out <- data.frame(label = lab,
                      hash_short = hash_short,
                      hash = hash)
    row.names(out) <- NULL
  } else {
    out <- unname(hash_short)
  }

  return(out)
}

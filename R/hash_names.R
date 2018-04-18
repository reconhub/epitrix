#' Anonymise data using SHA1
#'
#' This function uses SHA1 algorithm to anonymise data, based on user-indicated
#' data fields. Data fields are concatenated first, then each entry is
#' hashed. The function can either return a full detailed output, or short
#' labels ready to use for 'anonymised data'. Before concatenation (using "_" as
#' a separator) to form labels, inputs are modified using \code{\link{rename}}.
#'
#' The argument \code{salt} can be used for salting the algorithm, i.e. adding
#' an extra input to the input fields (the 'salt') to change the resulting hash
#' and prevent identification of individuals via pre-computed hash
#' tables. Objects provided as \code{salt} will themselves be hashed using SHA1
#' algorithm, and the full hash is appended to the labels.
#'
#' @seealso  \code{\link{rename}}, used to clean labels prior to hashing.
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
#' @param salt An optional object to be used to 'salt' the hashing algorithm
#'   (see details). Ignored if \code{NULL} (default).
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
#'
#' ## salting the hashing (more secure!)
#' hash_names(first_name, last_name) # unsalted - less secure
#' hash_names(first_name, last_name, salt = 123) # salted with an integer
#' hash_names(first_name, last_name, salt = "foobar") # salted with an character

hash_names <- function(..., size = 6, full = TRUE, salt = NULL) {
  x <- list(...)
  x <- lapply(x, function(e) paste(unlist(e)))

  x <- lapply(x, rename, sep = "")
  paste_ <- function(...) paste(..., sep = "_")
  lab <- do.call(paste_, x)


  ## hash it all
  if (is.null(salt)) {
      input <- lab
  } else {
      input <- paste_(lab, digest::sha1(salt))
  }
  hash <- vapply(input, digest::sha1, NA_character_)
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

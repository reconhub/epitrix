#' Anonymise data using scrypt
#'
#' This function uses the scrypt algorithm from libsodium to anonymise data,
#' based on user-indicated data fields. Data fields are concatenated first,
#' then each entry is hashed. The function can either return a full detailed
#' output, or short labels ready to use for 'anonymised data'.
#' Before concatenation (using "_" as a separator) to form labels,
#' inputs are modified using [clean_labels()]
#'
#' The argument `salt` should be used for salting the algorithm, i.e. adding
#' an extra input to the input fields (the 'salt') to change the resulting hash
#' and prevent identification of individuals via pre-computed hash
#' tables.
#'
#' It is highly recommend to choose a secret, random salt in order make it harder
#' for an attacker to decode the hash.
#'
#' @seealso [clean_labels()], used to clean labels prior to hashing\cr
#'  [sodium::hash()] for available hashing functions.
#'
#' @author Thibaut Jombart \email{thibautjombart@@gmail.com},
#'   Dirk Shchumacher \email{mail@@dirk-schumacher.net},
#'   Zhian N. Kamvar \email{zkamvar@@gmail.com}
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
#' @param hashfun a hashing function that takes and returns a [raw][base::raw] vector of
#'   bytes that can be converted to character with [rawToChar()]. Defaults to
#'   [sodium::scrypt()], which is very secure, but computer intensive. For EDA
#'   that lives in one place, an algorithm like [sodium::sha256()] will
#'   suffice, but is less secure.
#'
#' @param salt An optional object that can be coerced to a character
#'   to be used to 'salt' the hashing algorithm (see details).
#'   Ignored if `NULL`.
#'
#' @param clean_labels A logical indicating if labels of variables should be
#'   standardized; defaults to `TRUE`
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
#'
#' ## using a different hash algorithm if you want things to run faster
#' 
#' hash_names(first_name, last_name, hashfun = sodium::sha256) # use sha256 algorithm

hash_names <- function(..., size = 6, full = TRUE, hashfun = sodium::scrypt, salt = NULL, clean_labels = TRUE) {
  x <- list(...)
  x <- lapply(x, function(e) paste(unlist(e)))

  if (clean_labels) {
    x <- lapply(x, clean_labels, sep = "")
  }
  paste_ <- function(...) paste(..., sep = "_")
  lab <- do.call(paste_, x)


  ## create the hashing function that returns a character string
  hashfun <- hash(salt, f = hashfun)
  ## hash it all
  hash <- vapply(lab, hashfun, NA_character_)
  ## trim the results
  hash_short <- substr(hash, 1, size)

  if (full) {
    out <- data.frame(label = lab,
                      hash_short = hash_short,
                      hash = hash,
                      stringsAsFactors = FALSE)
    row.names(out) <- NULL
  } else {
    out <- unname(hash_short)
  }

  return(out)
}

hash <- function(salt = NULL, f = sodium::scrypt) {
  # First check if the hashing function has "salt" in the arguments
  if (any(names(formals(f)) == "salt")) {
    # if it does, create a salt
    stopifnot(is.null(salt) || length(salt) == 1L)
    salt <- if (is.null(salt)) {
      raw(32L)
    } else {
      sodium::hash(charToRaw(as.character(salt)))
    }
    function(x) {
      stopifnot(is.character(x))
      sodium::bin2hex(f(charToRaw(x), salt = salt))
    }
  } else {
    # if it does not, append the salt (if applicable)
    function(x, s = salt) {
      x <- if (is.null(s)) x else paste(x, s, sep = "_")
      stopifnot(is.character(x))
      sodium::bin2hex(f(charToRaw(x)))
    }
  }
}

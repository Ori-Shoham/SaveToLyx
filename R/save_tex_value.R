#' Save values to a tex file
#'
#' \code{save_tex_value} saves pairs of values and names of commands to be
#' associated with them to a special formatted '.tex' file.
#'
#' @param values Numeric, character or logical vector of values to be saved.
#'   Logical values will be saved as character.
#' @param names Character vector of names. Each name must be unique and can
#'   consist of letters only.
#' @param file_name File name to create on disk. \code{file_name} should have
#'   either a \code{.tex} extension or no extension at all.
#' @param path Path to the directory to save the file to. \code{path} and
#'   \code{file_name} are combined to create fully qualified file name. If
#'   \code{Null} and \code{file_name} does not specify a full file name defaults
#'   to working directory.
#' @param translate Logical indicating whether to save values in LaTeX format.
#'   See \code{\link[Hmisc]{latexTranslate}}.
#' @param digits The desired number of digits after the decimal point for
#'   numeric non-percent values. Defaults to 2 digits after the decimal point.
#' @param percent Logical scalar or vector. If \code{values} is a numeric vector
#'   \code{percent} indicates whether to save values as percents or as is. If
#'   you want only a subset of values to be saved as percents \code{percent}
#'   should be a logical vector indicating the positions of these values.
#' @param accuracy A number to round percent values to. Use (e.g.) 0.01 to show
#'   2 decimal places of precision. Defaults to 1 i.e round to the nearest
#'   integer.
#' @param override Logical indicating whether to override values if a value with
#'   the same name already exits in the file.
#'
#' @export
#' @import data.table
#'
#' @examples \dontrun{
#' file <- tempfile()
#' save_tex_value(values = 1:3, names = c("a","b","c"), file_name = file)
#'
#' # Save percent values to the same file
#' save_tex_value(values = 0.5, names = "halfPer", file_name = file, percent = TRUE)
#'
#' # override "a" with a different value
#' a <- rnorm(1)
#' save_tex_value(values = a, names = "a", file_name = file, digits = 4)
#'
#' # delete file with base::unlink()
#' unlink(paste0(file,".tex"))
#'
#' }
save_tex_value <- function(values, names, file_name, path = NULL, translate = TRUE,
                        digits = 2, percent = FALSE, accuracy = 1, override = TRUE) {
  # Test for valid inputs
  if (any(grepl("[^A-Za-z]", names))) {
    stop("Names must consist of letters only")
  }
  if (any(duplicated(names))) {
    stop("Names must be unique")
  }
  if (length(values) != length(names)) {
    stop("Names and Values must be of compatible lengths")
  }
  if (length(percent) > 1 & length(percent) != length(names)) {
    stop("percent must be of length 1 or of the same length as values and names")
  }

  # Technical solution to notes
  name <- value <- NULL

  # Format values
  values <- format_values(values, percent, accuracy, digits, translate)

  # Test and format file name
  file_name <- handle_file_name(file_name, path)

  # Get current values
  if (file.exists(file_name) & file.size(file_name) > 10) {
    DATA <- data.table::fread(
      file_name,
      sep = " ", header = FALSE, col.names = c("name", "value")
    )
    n_exist <- DATA[gsub("\\\\newcommand\\\\", "", name) %in% names, .N]
    if (!override & n_exist > 0) {
      stop("override is set to FALSE and some of the names appear in your tex file")
    }
    DATA <- DATA[!gsub("\\\\newcommand\\\\", "", name) %in% names]
  } else {
    DATA <- data.table::data.table()
    n_exist <- 0
  }
  DATA <- rbind(DATA, list(
    name = paste0("\\newcommand\\", names),
    value = paste0("{", values, "}")
  ))

  DATA <- unique(DATA)
  DATA <- DATA[order(name)]
  data.table::setkey(DATA, "name")

  # Write values to file
  first <- 1 # iterateName=DATA$name[1]
  for (iterateName in DATA$name) {
    myAppend <- ifelse(first == 0, TRUE, FALSE)
    iterateValue <- DATA[name == iterateName, value]
    write(paste0(iterateName, " ", iterateValue), file = file_name, append = myAppend)
    first <- 0
  }

  # Warn about overrides
  if (n_exist > 1) message(paste0(n_exist, " values overriden"))
  if (n_exist == 1) message("One value overriden")
}

#' Formats values for lyx
#'
#' @inheritParams save_tex_value
#'
#' @return A formatted character vector.
#' @keywords internal

format_values <- function(values, percent, accuracy, digits, translate) {
  if (is.numeric(values)) {
    n <- length(values)
    valuesTemp <- vector("character", length = n)
    for (i in 1:n) {
      if ((percent + rep(0, n))[i]) {
        valuesTemp[i] <- scales::percent(
          values[i],
          accuracy = accuracy, big.mark = ","
        )
      } else {
        valuesTemp[i] <- formatC(
          values[i],
          format = "f", digits = digits, big.mark = ","
        )
      }
    }
    values <- valuesTemp
  } else values <- as.character(values)
  if (translate) {
    values <- Hmisc::latexTranslate(values)
  }
  return(values)
}


#' Constructs fully qualified file name
#'
#' \code{hanle_file_name} checks the extension of \code{file_name}, breaks if it
#' is not a '.tex' extension and adds '.tex' extension if no extension exists.
#' If \code{path} is not \code{NULL} combines \code{path} and \code{file_name}.
#'
#' @inheritParams save_tex_value
#'
#' @return a complete file name (with path and extension)
#'
#' @keywords internal
handle_file_name <- function(file_name, path = NULL){
  if (!tools::file_ext(file_name) %in% c("","tex")){
    stop("The file should be a .tex file")
  }

  # Construct file name
  if (tools::file_ext(file_name) == "") file_name <- paste0(file_name, ".tex")
  if (!is.null(path)) file_name <- file.path(path, file_name)
  return(file_name)

}


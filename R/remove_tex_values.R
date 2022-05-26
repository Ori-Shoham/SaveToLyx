#' Remove certain values from a values-tex file
#'
#' @param file_name File name containing values to be removed. file_name should
#'   have either a .tex extension or no extension at all.
#' @param names Character vector of names specifying which values are to be
#'   removed.
#' @inheritParams save_tex_value
#'
#' @export
#' @examples \dontrun{
#' file <- tempfile()
#' save_tex_value(values = 1:3, names = c("a","b","c"), file_name = file)
#'
#' # remove "a" and "b" from file
#' remove_tex_value(file_name = paste0(file, ".tex"), names = c("a", "b"))
#'
#' # delete file with base::unlink()
#' unlink(paste0(file,".tex"))
#'
#' }
remove_tex_value <- function(file_name, path = NULL, names) {

  # Test and format file name
  file_name <- handle_file_name(file_name, path)
  if (!file.exists(file_name)) stop("File does not exist")

  # technical solution to notes
  name <- value <- NULL

  # Read file
  DATA <- data.table::fread(file_name, sep = " ", header = FALSE, col.names = c("name", "value"))

  # Warn if any of the variable names is not in the file
  names_not_found <- NULL
  for (iterateName in names) {
    if (!iterateName %in% gsub("\\\\newcommand\\\\", "", DATA$name)) {
      names_not_found <- c(names_not_found, iterateName)
    }
  }
  n <- length(names_not_found)
  if (!is.null(names_not_found)) {
    if (n > 1) {
      names_not_found <- paste0(
        '"', paste(names_not_found[1:(n - 1)], collapse = '", "'),
        '& "', names_not_found[n], '"'
      )
      warning(paste0(names_not_found, " were not found in the file"))
    } else {
      warning(paste0(names_not_found, " was not found in the file"))
    }
  }
  # Remove values from data
  DATA <- DATA[!gsub("\\\\newcommand\\\\", "", name) %in% names]
  # Write remaining values to file if there are any, else - remove file
  if (nrow(DATA) > 0) {
    first <- 1 # iterateName=DATA$name[1]
    for (iterateName in DATA$name) {
      myAppend <- ifelse(first == 0, TRUE, FALSE)
      iterateValue <- DATA[name == iterateName, value]
      write(paste0(iterateName, " ", iterateValue), file = file_name, append = myAppend)
      first <- 0
    }
  } else {
    write("", file = file_name, append = FALSE)
    message(paste0("All values were removed."))
  }
}

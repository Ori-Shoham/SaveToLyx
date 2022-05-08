#' Title
#'
#' @inheritParams save_tex_value
#'
#'
#' @export
#' @examples a
#'
remove_tex_value <- function(names, file_name, path = NULL) {

  if (!tools::file_ext(file_name) %in% c("","tex")){
    stop("file_name should be a .tex file")
  }

  # Construct file name
  if (tools::file_ext(file_name) == "") file_name <- paste0(file_name, ".tex")
  if (!is.null(path)) {
    file_name <- file.path(path, file_name)
  }

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

#' Title
#'
#' @inheritParams save_to_lyx
#'
#'
#' @export
#' @examples a
#'
remove_from_lyx <- function(currentName, latexFile, path = NULL) {

  if (!tools::file_ext(latexFile) %in% c("","tex")){
    stop("latexFile should be a .tex file")
  }

  # Construct file name
  if (tools::file_ext(latexFile) == "") latexFile <- paste0(latexFile, ".tex")
  if (!is.null(path)) {
    latexFile <- file.path(path, latexFile)
  }

  if (!file.exists(latexFile)) stop("File does not exist")

  # technical solution to notes
  name <- value <- NULL

  # Read file
  DATA <- data.table::fread(latexFile, sep = " ", header = FALSE, col.names = c("name", "value"))

  # Warn if any of the variable names is not in the file
  names_not_found <- NULL
  for (iterateName in currentName) {
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
  DATA <- DATA[!gsub("\\\\newcommand\\\\", "", name) %in% currentName]
  # Write remaining values to file if there are any, else - remove file
  if (nrow(DATA) > 0) {
    first <- 1 # iterateName=DATA$name[1]
    for (iterateName in DATA$name) {
      myAppend <- ifelse(first == 0, TRUE, FALSE)
      iterateValue <- DATA[name == iterateName, value]
      write(paste0(iterateName, " ", iterateValue), file = latexFile, append = myAppend)
      first <- 0
    }
  } else {
    unlink(latexFile)
    warning(paste0("All values were removed. ", latexFile, " was deleted."))
  }
}

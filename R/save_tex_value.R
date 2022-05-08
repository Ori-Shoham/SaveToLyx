#' Title
#'
#' @param values a
#' @param names a
#' @param latexFile a
#' @param path a
#' @param translate a
#' @param digits a
#' @param percent a
#' @param accuracy a
#' @param override a
#'
#' @export
#' @import data.table
#'
#' @examples a
save_tex_value <- function(values, names, latexFile, path = NULL, translate = TRUE,
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
  if (!tools::file_ext(latexFile) %in% c("","tex")){
    stop("latexFile should be a .tex file")
  }
  # Technical solution to notes
  name <- value <- NULL

  # Format values
  values <- format_values(values, percent, accuracy, digits, translate)

  # Construct file name
  if (tools::file_ext(latexFile) == "") latexFile <- paste0(latexFile, ".tex")
  if (!is.null(path)) {
    latexFile <- file.path(path, latexFile)
  }

  # Get current values
  if (file.exists(latexFile) & file.size(latexFile) > 10) {
    DATA <- data.table::fread(
      latexFile,
      sep = " ", header = FALSE, col.names = c("name", "value")
    )
    n_exist <- DATA[gsub("\\\\newcommand\\\\", "", name) %in% names, .N]
    if (!override & n_exist > 0) {
      stop("names contains existing names")
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
    write(paste0(iterateName, " ", iterateValue), file = latexFile, append = myAppend)
    first <- 0
  }

  # Warn about overrides
  if (n_exist > 1) message(paste0(n_exist, " values overriden"))
  if (n_exist == 1) message("One value overriden")
}

#' Formats values for lyx
#'
#' @inheritParams save_to_lyx
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
  }
  if (translate) {
    values <- Hmisc::latexTranslate(values)
  }
  return(values)
}



#' Title
#'
#' @param currentValue a
#' @param currentName a
#' @param latexFile a
#' @param translate a
#' @param digits a
#' @param percent a
#' @param accuracy a
#' @param replace a
#'
#' @export
#' @import data.table
#'
#'
save_to_lyx <- function(currentValue, currentName, latexFile = dataLyxOutput, translate = TRUE,
                        digits = 2, percent = FALSE, accuracy = 1, replace = TRUE) {
  # Test for valid inputs
  if (any(grepl("[^A-Za-z]", currentName))) {
    stop("Names must consist of letters only")
  }
  if (any(duplicated(currentName))) {
    stop("Names must be unique")
  }
  if (length(currentValue) != length(currentName)) {
    stop("Names and Values must be of compatible lengths")
  }
  if (length(percent) > 1 & length(percent) != length(currentName)) {
    stop("percent must be of length 1 or of the same length as values and names")
  }

  # Format values
  currentValue <- format_values(currentValue, percent, accuracy, digits , translate)


  # Get current values
  if (file.exists(latexFile) & file.size(latexFile) > 10) {
    DATA <- data.table::fread(latexFile, sep = " ", header = FALSE, col.names = c("name", "value"))
    n_exist <- DATA[gsub("\\\\newcommand\\\\", "", name) %in% currentName, .N]
    if (!replace & n_exist > 0) {
      stop("currentName contains existing names")
    }
    DATA <- DATA[!gsub("\\\\newcommand\\\\", "", name) %in% currentName]
  } else {
    DATA <- data.table::data.table()
    n_exist <- 0
  }
  DATA <- rbind(DATA, list(name = paste0("\\newcommand\\", currentName), value = paste0("{", currentValue, "}")))

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

  # Warn about replacements
  if (n_exist > 1) message(paste0(n_exist, " values replaced"))
  if (n_exist == 1) message("One value replaced")
}

#' Formats values for lyx
#'
#' @inheritParams save_to_lyx
#'
#' @return A formatted character vector.
#' @keywords internal

format_values <- function(currentValue, percent,  accuracy, digits, translate) {
  if (is.numeric(currentValue)) {
    n <- length(currentValue)
    currentValueTemp <- vector("character", length = n)
    for (i in 1:n) {
      if ((percent + rep(0, n))[i]) {
        currentValueTemp[i] <- scales::percent(currentValue[i], accuracy = accuracy, big.mark = ",")
      } else {
        currentValueTemp[i] <- formatC(currentValue[i], format = "f", digits = digits, big.mark = ",")
      }
    }
    currentValue <- currentValueTemp
  }
  if (translate) {
    currentValue <- Hmisc::latexTranslate(currentValue)
  }
  return(currentValue)
}





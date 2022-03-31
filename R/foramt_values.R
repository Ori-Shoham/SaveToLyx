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

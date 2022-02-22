#' Title
#'
#' @param currentValue a
#' @param currentName a
#' @param latexFile a
#' @param translate a
#' @param digits a
#' @param percent a
#' @param accuracy a
#' @param dataFile a
#'
#'
#' @export
#' @import data.table
#'
#'
save_to_lyx <- function(currentValue, currentName, latexFile = dataLyxOutput, translate=TRUE,
                      digits = 2, percent=FALSE, accuracy=1, dataFile = NULL) {
  if(any(grepl("[0-9]", currentName))) {
    stop("Can't include digits in name")
  }

  if (is.numeric(currentValue)) {
    if (percent) {
      currentValue = scales::percent(currentValue, accuracy=accuracy, big.mark = ",")
    } else {
      currentValue = formatC(currentValue, format = "f", digits = digits,  big.mark = ",")
    }

  }

  if (translate==TRUE) {
    currentValue = Hmisc::latexTranslate(currentValue)
  }

  # Get current values
  if (!is.null(dataFile)) {
    if (file.exists(dataFile)) {
      DATA <- readRDS(dataFile)
      DATA = DATA[name!=currentName]
    } else {
      DATA = data.table::data.table()
      DATA = rbind(DATA, list(name=currentName, value=currentValue, lastUpdated = Sys.time()))
    }
  } else {
    if (file.exists(latexFile) & file.size(latexFile)>10) {
      DATA <- data.table::fread(latexFile, sep=" ", header = FALSE, col.names = c("name", "value"))
      #DATA[, name:=gsub("\\\\newcommand\\\\", "", name)]
      #DATA[, value:=gsub("^\\{", "", gsub("}$", "", value))]
      DATA = DATA[gsub("\\\\newcommand\\\\", "", name)!=currentName]
    } else {
      DATA = data.table::data.table()
    }
    DATA = rbind(DATA, list(name=paste0("\\newcommand\\", currentName), value=paste0("{", currentValue ,"}")))
  }

  DATA = unique(DATA)
  DATA = DATA[order(name)]
  data.table::setkey(DATA, "name")

  if (!is.null(dataFile)) {
    saveRDS(DATA, file = dataFile)
  }

  first = 1; # iterateName=DATA$name[1]
  for(iterateName in DATA$name) {
    myAppend = FALSE
    if (first==0) {
      myAppend = TRUE
    }

    iterateValue = DATA[name==iterateName, value]
    write(file=latexFile, paste0(iterateName, " ", iterateValue), append=myAppend)
    first = 0
  }
}

#' Title
#'
#' @param currentValue a
#' @param currentName a
#' @param latexFile a
#' @param translate a
#' @param digits a
#' @param percent a
#' @param accuracy a
#'
#' @export
#' @import data.table
#'
#'
save_to_lyx <- function(currentValue, currentName, latexFile = dataLyxOutput, translate=TRUE,
                      digits = 2, percent=FALSE, accuracy=1) {
  # Test for valid inputs
  if(any(grepl("[^A-Za-z]", currentName))) {
    stop("Names must consist of letters only")
  }
  if(any(duplicated(currentName))){
    stop("Names must be unique")
  }
  if(length(currentValue)!=length(currentName)){
    stop("Names and Values must be of compatible lengths")
  }
  if(length(percent) > 1 & length(percent)!=length(currentName)){
    stop("percent must be of length 1 or of the same length as values and names")
  }
  n <- length(currentValue)
  # Format values
  for (i in 1:n) {
    if (is.numeric(currentValue[i])) {
      if ((percent+rep(0,n))[i]) {
        currentValue[i] = scales::percent(currentValue[i], accuracy=accuracy, big.mark = ",")
      } else {
        currentValue[i] = formatC(currentValue[i], format = "f", digits = digits,  big.mark = ",")
      }
    }
  }

  if (translate==TRUE) {
    currentValue = Hmisc::latexTranslate(currentValue)
  }

  # Get current values
  if (file.exists(latexFile) & file.size(latexFile)>10) {
      DATA <- data.table::fread(latexFile, sep=" ", header = FALSE, col.names = c("name", "value"))
      #DATA[, name:=gsub("\\\\newcommand\\\\", "", name)]
      #DATA[, value:=gsub("^\\{", "", gsub("}$", "", value))]
      DATA = DATA[!gsub("\\\\newcommand\\\\", "", name)%in% currentName]
  } else {
      DATA = data.table::data.table()
    }
  DATA = rbind(DATA, list(name=paste0("\\newcommand\\", currentName), value=paste0("{", currentValue ,"}")))

  DATA = unique(DATA)
  DATA = DATA[order(name)]
  data.table::setkey(DATA, "name")


  first = 1; # iterateName=DATA$name[1]
  for(iterateName in DATA$name) {
    myAppend <-  ifelse(first==0, TRUE, FALSE)
    iterateValue = DATA[name==iterateName, value]
    write(paste0(iterateName, " ", iterateValue), file=latexFile, append=myAppend)
    first = 0
  }
}



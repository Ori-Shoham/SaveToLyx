#' Title
#'
#' @param names ab
#' @param nrows ab
#' @inheritParams save_to_lyx
#'
#' @return
#' @export
#'
#' @examples a
print_tex_value <- function(latexFile, path = NULL, names = NULL, nrows = NULL) {

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
  DATA[, ":="(name = gsub("\\newcommand\\","",name, fixed = TRUE), value = gsub("[\\{\\}\\\\]","",value))]
  if (!is.null(names)) DATA <- DATA[name %in% names]
  if(is.null(nrows))  print(DATA)
  else print(DATA, nrows = nrows)
}

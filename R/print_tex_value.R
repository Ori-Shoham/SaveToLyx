#' Title
#'
#' @param names ab
#' @inheritParams save_tex_value
#'
#' @return
#' @export
#'
#' @examples a
print_tex_value <- function(file_name, path = NULL, names = NULL) {

  # Test and format file name
  file_name <- handle_file_name(file_name, path)
  if (!file.exists(file_name)) stop("File does not exist")

  # technical solution to notes
  name <- value <- NULL

  # Read file
  DATA <- data.table::fread(file_name, sep = " ", header = FALSE, col.names = c("name", "value"))
  DATA[, ":="(name = gsub("\\newcommand\\","",name, fixed = TRUE), value = gsub("[\\{\\}\\\\]","",value))]
  if (!is.null(names)) DATA <- DATA[name %in% names]
  print(DATA)
}

#' Print values out of a values-tex file
#'
#' @param file_name File name to read from disk. file_name should have either a
#'   .tex extension or no extension at all.
#' @param names Character vector of names for printing.
#' @inheritParams save_tex_value
#'
#' @export
#'
#' @examples \dontrun{
#' file <- tempfile()
#' save_tex_value(values = 1:3, names = c("a","b","c"), file_name = file)
#'
#' # Print "a" and "b" out of file
#' print_tex_value(file_name = files, names = c("a", "b"))
#'
#' # delete file with base::unlink()
#' unlink(paste0(file,".tex"))
#'
#' }
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

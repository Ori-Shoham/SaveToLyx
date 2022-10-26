#' savetexvalue: A package for creation and management of value-tex files
#'
#' savetexvalue helps saving and managing values calculated in R for integration in
#' projects written in LaTeX in an automatic and reproducible way. savetexvalue
#' uses special formatted '.tex' files containing pairs of values and command
#' names to be used in LaTeX.

#'
#' @section savetexvalue functions: The savetexvalue package contains three
#'   functions: \itemize{ \item \code{save_tex_value} for saving values to file.
#'   \item \code{remove_tex_value} for removing values from file. \item
#'   \code{print_tex_value} for displaying the contents of a value-tex file in
#'   your R session. }
#' @author Ro'ee Levy, Ori Shoham \cr Maintainer: Ori Shoham
#'   \email{ori.shoham1@@gmail.com}
#' @docType package
#' @examples \dontrun{
#' file <- tempfile()
#' #save "a", "b", and "c"
#' save_tex_value(values = 1:3, names = c("a","b","c"), file_name = file)
#'
#' # Save percent values to the same file
#' save_tex_value(values = 0.5, names = "halfPer", file_name = file, percent = TRUE)
#'
#' # override "a" with a different value
#' a <- rnorm(1)
#' save_tex_value(values = a, names = "a", file_name = file, digits = 4)
#'
#' # print "a" and "halfPer"
#' print_tex_value(file, names = c("a", "halfPer"))
#'
#' # remove "b" and "c" from file
#'
#'
#' # delete file with base::unlink()
#' unlink(paste0(file,".tex"))
#'
#' }
#' @name savetexvalue
NULL

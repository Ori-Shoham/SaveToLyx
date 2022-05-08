test_file_1 <- paste0(tempfile(), ".tex")
test_file_2 <- paste0(tempfile(), ".tex")
withr::local_file(save_to_lyx(currentValue = 1:26, currentName = letters, latexFile = test_file_1))

test_that("save_to_lyx does not accept invalid input", {
  expect_error(
    save_to_lyx(currentValue = 1, currentName = "a_b", latexFile = "a.tex"),
    "Names must consist of letters only"
  )
  expect_error(
    save_to_lyx(currentValue = 1:2, currentName = c("a", "a"), latexFile = "a.tex"),
    "Names must be unique"
  )
  expect_error(
    save_to_lyx(currentValue = 1:2, currentName = "a", latexFile = "a.tex"),
    "Names and Values must be of compatible lengths"
  )
  expect_error(
    save_to_lyx(currentValue = 1:3, currentName = letters[1:3], latexFile = "a.tex", percent = c(T, F)),
    "percent must be of length 1 or of the same length as values and names"
  )
})

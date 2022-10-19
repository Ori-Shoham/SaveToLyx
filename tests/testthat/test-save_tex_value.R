test_file_1 <- paste0(tempfile(), ".tex")
test_file_2 <- paste0(tempfile(), ".tex")
withr::local_file(save_tex_value(values = 1:26, names = letters, file_name = test_file_1))

test_that("save_tex_value does not accept invalid input", {
  expect_error(
    save_tex_value(values = 1, names = "a_b", file_name = "a.tex"),
    "Names must consist of letters only"
  )
  expect_error(
    save_tex_value(values = 1:2, names = c("a", "a"), file_name = "a.tex"),
    "Names must be unique"
  )
  expect_error(
    save_tex_value(values = 1:2, names = "a", file_name = "a.tex"),
    "Names and Values must be of compatible lengths"
  )
  expect_error(
    save_tex_value(values = 1:3, names = letters[1:3], file_name = "a.tex", percent = c(T, F)),
    "percent must be of length 1 or of the same length as values and names"
  )
})

test_that("handle_file_name accepts only .tex or no extension",{
  expect_error(handle_file_name("ab.png"), "The file should be a .tex file")
  expect_equal(handle_file_name("ab"), "ab.tex")
  expect_equal(handle_file_name("ab.tex"), "ab.tex")
})

test_that("handle_file_name is able to construct complete path",{
  expect_equal(handle_file_name("ab", getwd()), paste0(getwd(), "/ab.tex"))
})

test_that("save_tex_value manages to save both percents and non-percents in the same vector",{
  file <- paste0(tempfile(),".tex")
  withr::local_file(save_tex_value(values = c(10,20,0.3), names = c("ten", "twenty", "thirtyPer"),
                 file_name = file, percent = c(F,F,T)))
  ref <- data.table(name = c("\\newcommand\\ten", "\\newcommand\\twenty", "\\newcommand\\thirtyPer"),
                    value = c("{10.00}", "{20.00}", "{30\\%}"))[order(name)]
  expect_equal(fread(file, sep = " ", header = FALSE, col.names = c("name", "value")), ref)
})

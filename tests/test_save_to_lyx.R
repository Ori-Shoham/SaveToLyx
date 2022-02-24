test_file_1 <- paste0(tempfile(),".tex")
test_file_2 <- paste0(tempfile(),".tex")
local_file(save_to_lyx(currentValue = 1:26, currentName = letters, latexFile = test_file_1))

test_that("save_to_lyx does not accept invalid input",{
  expect_warning(save_to_lyx())
})


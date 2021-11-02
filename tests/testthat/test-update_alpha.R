test_that("update_alpha() correctly updates alpha codes", {
  a = c("LTDU", "OLDS", "MALL", "NOSH")
  b = c("LTDU", "LTDU", "MALL", "NSHO")
  expect_identical(update_alpha(a), b)
})

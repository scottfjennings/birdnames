test_that("bird_namse_from_text", {

  expect_identical(bird_names_from_text(c("Bald Eagle and White-tailed Kite and WREN are birds.", "The Great Blue Heron is taller than the Snowy Egret")),
                   c("bald eagle_white-tailed kite_ wren_ bird", "great blue heron_than_snowy egret"))


})

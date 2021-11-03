test_that("bird_taxa_filter works for Anseriformes", {

  sample_bird_data <- data.frame(alpha.code = c("MALL", "GRSC", "BUFF", "RTHA", "SCAUP",
  "GREG", "HOGR"))

  expect_identical(bird_taxa_filter(sample_bird_data, c("alpha.code", "alpha.code"), "Anseriformes"),
                   data.frame(alpha.code = c("MALL", "GRSC", "BUFF", "SCAUP"),
                              common.name = c("Mallard", "Greater Scaup", "Bufflehead", "Scaup"),
                              species = c("Anas platyrhynchos", "Aythya marila", "Bucephala albeola", "Aythya spp.")))

})

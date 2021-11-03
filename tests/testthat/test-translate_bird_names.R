test_that("translate_bird_names alpha.code to common name and species", {
  bird_data <- data.frame(alpha.code = c("LTDU", "MALL", "GRSC")) %>%
    dplyr::mutate(common.name = translate_bird_names(alpha.code, "alpha.code", "common.name"),
           species = translate_bird_names(alpha.code, "alpha.code", "species"))

    expect_identical(bird_data, data.frame(alpha.code = c("LTDU", "MALL", "GRSC"),
                                           common.name = c("Long-tailed Duck", "Mallard", "Greater Scaup"),
                                           species = c("Clangula hyemalis", "Anas platyrhynchos", "Aythya marila")))

    })

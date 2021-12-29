## code to prepare `bird_list` dataset goes here

library(tidyverse)

read_from = "C:/Users/scott.jennings/Documents/Projects/birdnames_support/data/"

custom_bird_list <- readRDS(paste(read_from, "custom_bird_list"))

# data have been downloaded using functions in utilities, read them in.
birdpop_df <- utils::read.csv(paste(read_from, "IBP-AOS-LIST21.csv", sep = "")) %>%
  dplyr::select(alpha.code = .data$SPEC, common.name = .data$COMMONNAME, species = .data$SCINAME) %>%
  dplyr::mutate(species = gsub("Selaphorus", "Selasphorus", species))

aou <- utils::read.csv(paste(read_from, "NACC_list_species.csv", sep = "")) %>%
  dplyr::select(common.name = .data$common_name, .data$order, .data$family, .data$subfamily, .data$genus, .data$species, .data$annotation)

# currently not using bbl_list because birdpop and aou are in taxonomic order; old species number seems to be deprecated.
#bbl_list <- readRDS(paste(read_from, "BBL_list", sep = "")) %>%
#  dplyr::select(.data$alpha.code, .data$common.name, .data$species.number)


# both birdpop_df and aou are in taxonomic order,
# so once they are joined and any higher level taxonomy is filled in for all records in birdpop_df,
# the rows can simply be numbered to create a numeric field for easy taxonomic sorting

bird_list <- birdpop_df %>%
  extract_genus()  %>%
  left_join(aou %>% distinct(genus, subfamily, family, order)) %>%
  separate_species() %>%
  fill_taxonomy()  %>%
  mutate(taxonomic.order = row_number())



usethis::use_data(bird_list, overwrite = TRUE)
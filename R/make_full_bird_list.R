library(tidyverse)

read_from = "C:/Users/scott.jennings/Documents/Projects/birdnames_support/data/"


birdpop_df <- utils::read.csv(paste(read_from, "IBP-AOS-LIST21.csv", sep = "")) %>%
  dplyr::select(alpha.code = .data$SPEC, common.name = .data$COMMONNAME, species = .data$SCINAME) %>%
  dplyr::mutate(species = gsub("Selaphorus", "Selasphorus", species))

aou <- utils::read.csv(paste(read_from, "NACC_list_species.csv", sep = "")) %>%
  dplyr::select(common.name = .data$common_name, .data$order, .data$family, .data$subfamily, .data$genus, .data$species, .data$annotation)

#bbl_list <- readRDS(paste(read_from, "BBL_list", sep = "")) %>%
#  dplyr::select(.data$alpha.code, .data$common.name, .data$species.number)


# both birdpop_df and aou are in taxonomic order,
# so once they are joined and any higher level taxonomy is filled in for all records in birdpop_df,
# the rows can simply be numbered to create a numeric field for easy taxonomic sorting

birds_out <- birdpop_df %>%
  extract_genus()  %>%
  left_join(aou %>% distinct(genus, subfamily, family, order)) %>%
  separate_species() %>%
  fill_taxonomy()  %>%
  mutate(taxonomic.order = row_number())

# if you have a custom list of bird groupies,
# you can add them and add_taxon_order will put them in the right place
# and assign an appropriate taxonomic number
birds_out_custom <- birds_out %>%
  bind_rows(., utils::read.csv(paste(read_from, "custom_species.csv", sep = ""))) %>%
  add_taxon_order()


saveRDS(birds_out_custom, paste(read_from, "custom_bird_list"))



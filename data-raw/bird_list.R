## code to prepare `bird_list` dataset goes here

# there are several species/subspecies in birdpop_df which do not have matches in aou,
# but which have congeners in aou.
# so the logic here is to extract the genera from birdpop_df$species,
# and peel just the genus and higher fields from aou,
# then join on genus only


library(tidyverse)

read_from = "C:/Users/scott.jennings/Documents/Projects/my_R_general/birdnames_support/data/"

custom_bird_list <- readRDS(paste(read_from, "custom_bird_list", sep = ""))

# download aou list ----
#utils::read.csv("http://checklist.aou.org/taxa.csv?type=charset%3Dutf-8%3Bsubspecies%3Dno%3B") %>% write.csv(paste(read_from, "NACC_list_species.csv", sep = ""))



# data have been downloaded using functions in utilities or line above, read them in.
birdpop_df <- utils::read.csv(paste(read_from, "IBP-AOS-LIST22.csv", sep = "")) %>%
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

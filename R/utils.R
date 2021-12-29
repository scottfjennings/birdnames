




#' Download species list from birdpop.org
#'
#' The birdpop.org list has alphabetical codes (banding codes) for species, subspecies and some higher taxonomic groups
#'
#' @return a .csv
#' @export
#'
#' @examples
download_birdpop <- function() {

birdpop <- tabulizer::extract_tables("https://www.birdpop.org/docs/misc/Alpha_codes_tax.pdf")
birdpop2 <- do.call(rbind, birdpop[-length(birdpop)])
birdpop_df <- birdpop2 %>%
  data.frame() %>%
  dplyr::rename(common.name = 2, alpha.code = 3, species = 4) %>%
  dplyr::select(.data$common.name, .data$alpha.code, .data$species) %>%
  dplyr::mutate(alpha.code = gsub("\\*", "", .data$alpha.code))

}

download_aou <- function() {

# from here: http://checklist.aou.org/taxa
# AOU list has higher taxa classifications
aou <- utils::read.csv("http://checklist.aou.org/taxa.csv?type=charset%3Dutf-8%3Bsubspecies%3Dno%3B") %>%
  dplyr::select(common.name = .data$common_name, .data$order, .data$family, .data$subfamily, .data$genus, .data$species, .data$annotation)

}

download_bbl <- function() {
# bbl list has taxonomic numbers
# taxonomic numbers appear to be deprecated
# current version of birdnames does taxonomic ordering based on the AOU list
# bbl list probably not needed

url <- "https://www.pwrc.usgs.gov/bbl/manual/speclist.cfm"
bbl <- url %>%
  xml2::read_html() %>%
  rvest::html_nodes(xpath='//*[@id="spectbl"]') %>%
  rvest::html_table()
bbl_list <- bbl[1] %>%
  data.frame() %>%
  dplyr::rename_all(tolower) %>%
  dplyr::select(.data$alpha.code, .data$common.name, .data$species.number)

}
# there are several species/subspecies in birdpop_df which do not have matches in aou,
# but which have congeners in aou.
# so the logic here is to extract the genera from birdpop_df$species,
# and peel just the genus and higher fields from aou,
# then join on genus only

extract_genus <- function(df) {
  df <- df %>%
  separate(species, into = "genus", extra = "drop", remove = FALSE)
}


separate_species <- function(df) {
  df <- df %>%
  separate(species, c("genus2", "specific.name", "subspecific.name"), remove = FALSE, extra = "merge") %>%
  select(-genus2) %>%
  mutate(specific.name = ifelse(grepl("sp)|sp.)", species), NA, specific.name),
         subspecific.name = ifelse(grepl("sp)|sp.)", species), NA, subspecific.name),
         subfamily = ifelse(str_sub(genus, start= -3) == "nae", genus, subfamily),
         genus = ifelse(str_sub(genus, start= -3) == "nae", NA, genus),
         family = ifelse(str_sub(genus, start= -3) == "dae", genus, family),
         genus = ifelse(str_sub(genus, start= -3) == "dae", NA, genus))
}

# birdpop_df includes some records for birds ID to higher level than genus, but separate_species()
fill_taxonomy <- function(df) {
 df <- df  %>%
  left_join(., distinct(df, subfamily, family) %>% filter(!is.na(subfamily), subfamily != "", !is.na(family)), by = c("subfamily")) %>%
  rename(family = family.x) %>%
  mutate(family = ifelse(is.na(family), family.y, family)) %>%
  left_join(., distinct(df, family, order) %>% filter(!is.na(family), !is.na(order)), by = c("family")) %>%
  rename(order = order.x) %>%
  mutate(order = ifelse(is.na(order), order.y, order)) %>%
  select(-contains(".y"))
}


# want to generate a helper numeric field for taxonomic sorting, based on the order of the current aou list
# but need to fill in the right numbers for taxa not in aou

add_taxon_order <- function(df){
  df1 <- df %>%
    # add number for each distinct aou$species; this assigns same species-level number to any subspecies
  left_join(., df %>%
              select(species) %>%
              mutate(species.num = row_number()) %>% separate(species, c("genus", "specific.name"), extra = "drop")) %>%
    # add genus number for any taxa only IDed to genus
  full_join(., df %>%
              distinct(genus) %>%
              filter(!is.na(genus), genus != "") %>%
              mutate(genus.num = row_number())) %>%
    # add subfamily number for any taxa only IDed to subfamily
  full_join(., df %>%
              distinct(subfamily) %>%
              filter(!is.na(subfamily), subfamily != "") %>%
              mutate(subfamily.num = row_number())) %>%
    # add family number for any taxa only IDed to family
  full_join(., df %>%
              distinct(family) %>%
              filter(!is.na(family), family != "") %>%
              mutate(family.num = row_number())) %>%
    # add order number for any taxa only IDed to order
  full_join(., df %>%
              distinct(order) %>%
              filter(!is.na(order), order != "") %>%
              mutate(order.num = row_number()))

    df2 <- df1 %>%
    arrange(order.num, family.num, subfamily.num, genus.num, species.num, !is.na(subspecific.name), subspecific.name) %>%
      mutate(taxonomic.order = row_number()) %>%
      select(-contains("num"))

}







#' Title
#'
#' @return
#' @export
#'
#' @examples
make_combined_bird_list <- function() {

  utils::data(full_bird_list)
  utils::data(custom_bird_list)

  zzz <- dplyr::full_join(full_bird_list, custom_bird_list %>% mutate(species.number = as.numeric(species.number)))

  zzz <- zzz %>%
    group_by(common.name) %>%
    mutate(num.rec = n()) %>%
    arrange(-num.rec, common.name)

  bbl_bad_alpha <- zzz %>%
    filter(num.rec == 2, !common.name %in% c("Antillean Euphonia", "Bewick's Swan", "Black Brant", "Blue-gray Gnatcatcher", "")) %>%
    mutate(good.bad = ifelse(is.na(species.number), "good", "bad"))

  formers <- filter(aou, grepl("ormerly placed", annotation)) %>%
    arrange(common.name) %>%
    mutate(former.genus = str_extract(annotation, "(?<=genus\\s)\\w+"),
           former.taxa = str_extract(annotation, "(?<=in\\s)\\w+"),
           former.taxa = ifelse(former.taxa == "the", NA, former.taxa))


xxx <- formers %>%
  select(common.name, former.genus, former.taxa) %>%
  left_join(aou) %>%
  group_by(common.name) %>%
  mutate(num.rows = n(),
           drop.row = former.genus == genus) %>%
  ungroup() %>%
  filter(num.rows > 1)


new_alphas <- zzz %>%
  filter(num.rec > 1) %>%
  select(alpha.code, species, species.number) %>%
  mutate(new.alpha = ifelse())


}


#' Title
#'
#' @return
#' @export
#'
#' @examples
#' bbl_list <- scrape_bbl_species_list()
#' saveRDS(bbl_list, "C:/Users/scott.jennings/Documents/Projects/birdnames_support/data/bbl_list")

scrape_bbl_species_list <- function() {
  url <- "https://www.pwrc.usgs.gov/bbl/manual/speclist.cfm"
bbl <- url %>%
  xml2::read_html() %>%
  rvest::html_nodes(xpath='//*[@id="spectbl"]') %>%
  rvest::html_table()
bbl_list <- bbl[1] %>%
  data.frame() %>%
  dplyr::rename_all(tolower) %>%
  dplyr::select(.data$alpha.code, .data$common.name, .data$species.number)
}


# download the aou list from here: http://checklist.americanornithology.org/
# and download the IBP list from here: https://www.birdpop.org/pages/birdSpeciesCodes.php
# and save both to C:/Users/scott.jennings/Documents/Projects/birdnames_support/data/

# bbl_list <- readRDS("C:/Users/scott.jennings/Documents/Projects/birdnames_support/data/bbl_list")
# aou <- read.csv("C:/Users/scott.jennings/Documents/Projects/birdnames_support/data/NACC_list_species.csv")
# birdpop_df <- read.csv("C:/Users/scott.jennings/Documents/Projects/birdnames_support/data/IBP-AOS-LIST21.csv")


# usethis::use_data(bbl_list, aou, birdpop_df, internal = TRUE)

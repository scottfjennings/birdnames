




#' Download species list from birdpop.org
#'
#' The birdpop.org list has alphabetical codes (banding codes) for species, subspecies and some higher taxonomic groups
#'
#' @return a .csv
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

#' Download AOU species list
#'
#' @return
#'
#' @examples
download_aou <- function() {

# from here: http://checklist.aou.org/taxa
# AOU list has higher taxa classifications
aou <- utils::read.csv("http://checklist.aou.org/taxa.csv?type=charset%3Dutf-8%3Bsubspecies%3Dno%3B") %>%
  dplyr::select(common.name = .data$common_name, .data$order, .data$family, .data$subfamily, .data$genus, .data$species, .data$annotation)

}

#' Download BBL species list
#'
#' @return
#'
#' @examples
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

#' Extract genus from a scientific name
#'
#' Helper function for merging birdpop and aou lists; not exported.
#'
#' @param df
#'
#' @return
#'
#' @examples
extract_genus <- function(df) {
  df <- df %>%
  dplyr::separate(.data$species, into = "genus", extra = "drop", remove = FALSE)
}


#' separate species field
#'
#' Separate species field into genus (dropped), specific epithet ("species.name") and subspecies name, if applicable.
#'
#' @param df
#'
#' @return
#'
#' @examples
separate_species <- function(df) {
  df <- df %>%
  dplyr::separate(.data$species, c("genus2", "specific.name", "subspecific.name"), remove = FALSE, extra = "merge") %>%
  dplyr::select(-.data$genus2) %>%
  dplyr::mutate(.data$specific.name = ifelse(grepl("sp)|sp.)", .data$species), NA, .data$specific.name),
         .data$subspecific.name = ifelse(grepl("sp)|sp.)", .data$species), NA, .data$subspecific.name),
         .data$subfamily = ifelse(str_sub(.data$genus, start= -3) == "nae", .data$genus, .data$subfamily),
         .data$genus = ifelse(str_sub(.data$genus, start= -3) == "nae", NA, .data$genus),
         .data$family = ifelse(str_sub(.data$genus, start= -3) == "dae", .data$genus, .data$family),
         .data$genus = ifelse(str_sub(.data$genus, start= -3) == "dae", NA, .data$genus))
}


#' Fill in higher taxonomic information
#' birdpop_df includes some records for birds ID to higher level than genus, but separate_species()
#'
#' @param df data frame output from separate_species()
#'
#' @return
#'
#' @examples
fill_taxonomy <- function(df) {
 df <- df  %>%
  dplyr::left_join(., distinct(df, .data$subfamily, .data$family) %>% filter(!is.na(.data$subfamily), .data$subfamily != "", !is.na(.data$family)), by = c("subfamily")) %>%
  dplyr::rename(family = .data$family.x) %>%
  dplyr::mutate(.data$family = ifelse(is.na(.data$family), .data$family.y, .data$family)) %>%
  dplyr::left_join(., distinct(df, .data$family, .data$order) %>% filter(!is.na(.data$family), !is.na(.data$order)), by = c("family")) %>%
  dplyr::rename(order = .data$order.x) %>%
  dplyr::mutate(.data$order = ifelse(is.na(.data$order), .data$order.y, .data$order)) %>%
  dplyr::select(-contains(".y"))
}


# want to generate a helper numeric field for taxonomic sorting, based on the order of the current aou list
# but need to fill in the right numbers for taxa not in aou

#' Add taxonomic ordering number for user's custom_species
#'
#' Places user's custom_species in the correct location in bird_list and renumbers the entire list.
#'
#' @param df
#'
#' @return
#' @export
#'
#' @examples
add_taxon_order <- function(df){
  df1 <- df %>%
    # add number for each distinct aou$species; this assigns same species-level number to any subspecies
  dplyr::left_join(., df %>%
              dplyr::select(.data$species) %>%
              dplyr::mutate(species.num = row_number()) %>% separate(.data$species, c("genus", "specific.name"), extra = "drop")) %>%
    # add genus number for any taxa only IDed to genus
  dplyr::full_join(., df %>%
              dplyr::distinct(.data$genus) %>%
              dplyr::filter(!is.na(.data$genus), .data$genus != "") %>%
              dplyr::mutate(genus.num = row_number())) %>%
    # add subfamily number for any taxa only IDed to subfamily
  dplyr::full_join(., df %>%
              dplyr::distinct(.data$subfamily) %>%
              dplyr::filter(!is.na(.data$subfamily), .data$subfamily != "") %>%
              dplyr::mutate(subfamily.num = row_number())) %>%
    # add family number for any taxa only IDed to family
  dplyr::full_join(., df %>%
              dplyr::distinct(.data$family) %>%
              dplyr::filter(!is.na(.data$family), .data$family != "") %>%
              dplyr::mutate(family.num = row_number())) %>%
    # add order number for any taxa only IDed to order
  dplyr::full_join(., df %>%
              dplyr::distinct(.data$order) %>%
              dplyr::filter(!is.na(.data$order), .data$order != "") %>%
              dplyr::mutate(order.num = row_number()))

    df2 <- df1 %>%
    dplyr::arrange(.data$order.num, .data$family.num, .data$subfamily.num, .data$genus.num, .data$species.num, !is.na(.data$subspecific.name), .data$subspecific.name) %>%
      dplyr::mutate(taxonomic.order = row_number()) %>%
      dplyr::select(-contains("num"))

}







#' Title
#'
#' @return
#'
#' @examples
make_combined_bird_list <- function() {

  utils::data(full_bird_list)
  utils::data(custom_bird_list)

  zzz <- dplyr::full_join(full_bird_list, custom_bird_list %>% mutate(species.number = as.numeric(species.number)))

  zzz <- zzz %>%
    dplyr::group_by(.data$common.name) %>%
    dplyr::mutate(num.rec = n()) %>%
    dplyr::arrange(-.data$num.rec, .data$common.name)

  bbl_bad_alpha <- zzz %>%
    dplyr::filter(.data$num.rec == 2, !.data$common.name %in% c("Antillean Euphonia", "Bewick's Swan", "Black Brant", "Blue-gray Gnatcatcher", "")) %>%
    dplyr::mutate(good.bad = ifelse(is.na(.data$species.number), "good", "bad"))

  formers <- filter(aou, grepl("ormerly placed", .data$annotation)) %>%
    dplyr::arrange(.data$common.name) %>%
    dplyr::mutate(former.genus = str_extract(.data$annotation, "(?<=genus\\s)\\w+"),
           former.taxa = str_extract(.data$annotation, "(?<=in\\s)\\w+"),
           former.taxa = ifelse(.data$former.taxa == "the", NA, .data$former.taxa))


xxx <- formers %>%
  dplyr::select(.data$common.name, .data$former.genus, .data$former.taxa) %>%
  dplyr::left_join(aou) %>%
  dplyr::group_by(.data$common.name) %>%
  dplyr::mutate(num.rows = n(),
           drop.row = .data$former.genus == .data$genus) %>%
  dplyr::ungroup() %>%
  dplyr::filter(.data$num.rows > 1)


new_alphas <- zzz %>%
  dplyr::filter(.data$num.rec > 1) %>%
  dplyr::select(.data$alpha.code, .data$species, .data$species.number)


}


#' Title
#'
#' @return
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

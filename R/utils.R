




#' Download species list from birdpop.org
#'
#' The birdpop.org list has alphabetical codes (banding codes) for species, subspecies and some higher taxonomic groups
#'
#' @return a data frame
#' @export
#'
#' @examples
#' # downloads take a while so commented out for package checking
#' # download_birdpop()
download_birdpop <- function() {

birdpop <- tabulizer::extract_tables("https://www.birdpop.org/docs/misc/Alpha_codes_tax.pdf")
birdpop2 <- do.call(rbind, birdpop[-length(birdpop)])
birdpop_df <- birdpop2 %>%
  data.frame() %>%
  dplyr::rename(common.name = 2, alpha.code = 3, species = 4) %>%
  dplyr::select(.data$common.name, .data$alpha.code, .data$species) %>%
  dplyr::mutate(alpha.code = gsub("\\*", "", .data$alpha.code))

}




#' Download BBL species list
#' bbl list has taxonomic numbers, which AOU discontinued in the 7th checklist update.
#' current version of birdnames does taxonomic ordering based on the AOU list.
#' bbl list probably not needed but retaining this function for possible future use of bbl list
#' (e.g. band size or T&E status)
#'
#' @return data frame
#' @export
#'
#' @examples
#' # downloads take a while so commented out for package checking
#' # download_bbl
download_bbl <- function() {

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


#' Extract genus from a scientific name
#'
#' Helper function for merging birdpop and aou lists; not exported.
#'
#' @param df Data frame with species field. Will most likely be birdpop_df.
#'
#' @return Data frame
#'
#' @examples
#' # Will generally be piped together to create bird_list
#'
extract_genus <- function(df) {
  df <- df %>%
  tidyr::separate(.data$species, into = "genus", extra = "drop", remove = FALSE)
}


#' separate species field
#'
#' Separate species field into genus (dropped), specific epithet ("species.name") and subspecies name, if applicable.
#'
#' @param df Data frame with species field. Will most likely be output from extract_genus() %>%
#' left_join(aou %>% dplyr::distinct(genus, subfamily, family, order))
#'
#' @return Data frame
#'
#' @examples
#' # Will generally be piped together to create bird_list
#'
separate_species <- function(df) {
  df <- df %>%
  tidyr::separate(.data$species, c("genus2", "specific.name", "subspecific.name"), remove = FALSE, extra = "merge") %>%
  dplyr::select(-.data$genus2) %>%
  dplyr::mutate(specific.name = ifelse(grepl("sp)|sp.)", .data$species), NA, .data$specific.name),
         subspecific.name = ifelse(grepl("sp)|sp.)", .data$species), NA, .data$subspecific.name),
         subfamily = ifelse(stringr::str_sub(.data$genus, start= -3) == "nae", .data$genus, .data$subfamily),
         genus = ifelse(stringr::str_sub(.data$genus, start= -3) == "nae", NA, .data$genus),
         family = ifelse(stringr::str_sub(.data$genus, start= -3) == "dae", .data$genus, .data$family),
         genus = ifelse(stringr::str_sub(.data$genus, start= -3) == "dae", NA, .data$genus))
}


#' Fill in higher taxonomic information
#' birdpop_df includes some records for birds ID to higher level than genus, but separate_species()
#'
#' @param df data frame output from separate_species()
#'
#' @return Data frame
#'
#' @examples
#' # Will generally be piped together to create bird_list
#'
fill_taxonomy <- function(df) {
 df <- df  %>%
  dplyr::left_join(dplyr::distinct(df, .data$subfamily, .data$family) %>%
                     dplyr::filter(!is.na(.data$subfamily), .data$subfamily != "", !is.na(.data$family)), by = c("subfamily")) %>%
  dplyr::rename(family = .data$family.x) %>%
  dplyr::mutate(family = ifelse(is.na(.data$family), .data$family.y, .data$family)) %>%
  dplyr::left_join(dplyr::distinct(df, .data$family, .data$order) %>%
                     dplyr::filter(!is.na(.data$family), !is.na(.data$order)), by = c("family")) %>%
  dplyr::rename(order = .data$order.x) %>%
  dplyr::mutate(order = ifelse(is.na(.data$order), .data$order.y, .data$order)) %>%
  dplyr::select(-dplyr::contains(".y"))
}


# want to generate a helper numeric field for taxonomic sorting, based on the order of the current aou list
# but need to fill in the right numbers for taxa not in aou

#' Add taxonomic ordering number for user's custom_species
#'
#' Places user's custom_species in the correct location in bird_list and renumbers the entire list.
#' Operation consists of a series of joins with columns holding order numbers for different taxonomic levels.
#' First join adds number for each distinct aou$species; this assigns same species-level number to any subspecies.
#' Second join adds genus number for any taxa only IDed to genus.
#' Third join adds subfamily number for any taxa only IDed to subfamily.
#' Fourth join adds family number for any taxa only IDed to family.
#' Final join adds add order number for any taxa only IDed to order.
#' Then the data frame is sorted by these taxa numbers in descending taxonomical level (order, family, ...),
#' and taxonomic.order field is regenerated as a sequential numeric field for the resulting sorted data frame.
#'
#'
#' @param df Data frame. most likely the result from bind_row(bird_list, custom_species)
#'
#' @return Data frame
#' @export
#'
#' @examples
#' custom_bird_list <- bird_list %>%
#' dplyr::bind_rows(., custom_species) %>%
#' add_taxon_order()
add_taxon_order <- function(df){
  df1 <- df %>%
  dplyr::left_join(df  %>%
                tidyr::separate(.data$species, c("genus", "specific.name"), extra = "drop") %>%
              dplyr::distinct(.data$genus, .data$specific.name) %>%
              dplyr::mutate(species.num = dplyr::row_number())) %>%
  dplyr::full_join(df %>%
              dplyr::distinct(.data$genus) %>%
              dplyr::filter(!is.na(.data$genus), .data$genus != "") %>%
              dplyr::mutate(genus.num = dplyr::row_number())) %>%
  dplyr::full_join(df %>%
              dplyr::distinct(.data$subfamily) %>%
              dplyr::filter(!is.na(.data$subfamily), .data$subfamily != "") %>%
              dplyr::mutate(subfamily.num = dplyr::row_number())) %>%
  dplyr::full_join(df %>%
              dplyr::distinct(.data$family) %>%
              dplyr::filter(!is.na(.data$family), .data$family != "") %>%
              dplyr::mutate(family.num = dplyr::row_number())) %>%
  dplyr::full_join(df %>%
              dplyr::distinct(.data$order) %>%
              dplyr::filter(!is.na(.data$order), .data$order != "") %>%
              dplyr::mutate(order.num = dplyr::row_number()))

    df2 <- df1 %>%
    dplyr::arrange(.data$order.num, .data$family.num, .data$subfamily.num, .data$genus.num, .data$species.num, !is.na(.data$subspecific.name), .data$subspecific.name) %>%
      dplyr::mutate(taxonomic.order = dplyr::row_number()) %>%
      dplyr::select(-dplyr::contains("num"))

}





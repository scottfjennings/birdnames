
# make_bird_list #####################################################

#' Make full bird species list
#'
#' Make a list of North American bird species, combining:
#'  4-letter (banding) codes from https://www.birdpop.org/docs/misc/Alpha_codes_tax.pdf
#' higher taxonomic classifications from http://checklist.aou.org/taxa
#' numeric species codes from https://www.pwrc.usgs.gov/bbl/manual/speclist.cfm
#'
#' @param from use "web" to read tables direct from websites,
#' use "disk" to read from location saved to disk
#' @param read_from if from = "disk", specify location where csv's are saved,  as birdpop_list and aou_list
#'
#' @return data frame with columns: common.name, alpha.code, species, order, family, subfamily, genus
#' @importFrom tabulizer extract_tables
#' @importFrom rvest html_table
#' @importFrom rvest html_nodes
#' @importFrom utils read.csv
#'
#' @examples
#' # full_bird_list <- make_full_bird_list(from = "web")
#'
make_full_bird_list <- function(from = c("web"), read_from = NA) {
# this is mostly a support function for bird_taxa_filter



if(from == "web") {
birdpop <- tabulizer::extract_tables("https://www.birdpop.org/docs/misc/Alpha_codes_tax.pdf")
birdpop2 <- do.call(rbind, birdpop[-length(birdpop)])
birdpop_df <- birdpop2 %>%
  data.frame() %>%
  dplyr::rename(common.name = 2, alpha.code = 3, species = 4) %>%
  dplyr::select(.data$common.name, .data$alpha.code, .data$species) %>%
  dplyr::mutate(alpha.code = gsub("\\*", "", .data$alpha.code))
}
if(from == "disk") {
birdpop_df <- utils::read.csv(paste(read_from, "birdpop_list.csv", sep = "")) %>%
  dplyr::select(alpha.code = .data$SPEC, common.name = .data$COMMONNAME)
}

#--
# from here: http://checklist.aou.org/taxa
# AOU list has higher taxa classifications
if(from == "web") {
aou <- utils::read.csv("http://checklist.aou.org/taxa.csv?type=charset%3Dutf-8%3Bsubspecies%3Dno%3B") %>%
  dplyr::select(common.name = .data$common_name, .data$order, .data$family, .data$subfamily, .data$genus, .data$species)
}
 if(from == "disk") {
aou <- utils::read.csv(paste(read_from, "NACC_list_species.csv", sep = "")) %>%
  dplyr::select(common.name = .data$common_name, .data$order, .data$family, .data$subfamily, .data$genus, .data$species)
}

# bbl list has taxonomic numbers
if(from == "web") {
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
  if(from == "disk") {
  bbl <- utils::read.csv(paste(read_from, "BBL_list_species.csv", sep = "")) %>%
  dplyr::select(.data$alpha.code, .data$common.name, .data$species.number)
  }

bird_list <- dplyr::full_join(birdpop_df, aou) %>%
  dplyr::full_join(bbl_list) %>%
  dplyr::mutate(species.number = ifelse(.data$alpha.code == "NOFL", 4125, .data$species.number),
                species.number = ifelse(.data$alpha.code == "DEJU", 5677, .data$species.number),
                species = ifelse(.data$alpha.code == "TURN", "Arenaria spp.", .data$species))


  return(bird_list)

}

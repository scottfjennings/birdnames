

#' Compile custom bird list
#'
#' Helper function to combine bird group dataset and user-filled dataset.
#'
#' @return data frame matching structure of full_bird_list
#' @importFrom utils read.csv
#' @export
#'
#' @examples
#' custom_bird_list <- make_custom_bird_list()

make_custom_bird_list <- function(){
      #full_bird_list1 <- read.csv("C:/Users/scott.jennings/Documents/Projects/R_general/utility_functions/utility_function_data/bird_taxa_list.csv") %>% dplyr::select(-taxonomic.order)
bird_lumpies <- utils::read.csv("C:/Users/scott.jennings/Documents/Projects/R_general/utility_functions/utility_function_data/bird_lumpies.csv")

manual_species <- utils::read.csv("C:/Users/scott.jennings/Documents/Projects/R_general/utility_functions/utility_function_data/manual_species.csv") %>%
  dplyr::mutate(group.spp = NA)

custom_bird_list <- rbind(bird_lumpies, manual_species) %>%
  dplyr::mutate_if(is.factor, as.character) %>%
  dplyr::filter(!is.na(.data$species)) %>%
  dplyr::distinct() %>%
  dplyr::mutate(species = ifelse(.data$alpha.code == "TURN", "Arenaria spp.", .data$species))
return(custom_bird_list)
}

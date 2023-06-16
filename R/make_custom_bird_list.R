

#' Compile custom bird list
#'
#' Helper function to combine bird group dataset and user-filled dataset.
#'
#' @param manual_spp_path file path to your .csv of manual species. should have some/all of these columns: "alpha.code" "common.name" "species" "specific.name" "subspecific.name" "genus" "order" "family" "subfamily" "taxonomic.order" "group.spp"
#'
#' @return data frame matching structure of full_bird_list
#' @importFrom utils read.csv
#'
#' @examples
#' custom_bird_list <- make_custom_bird_list("C:/Users/scott.jennings/OneDrive - Audubon Canyon Ranch/Projects/my_R_general/birdnames_support/data/custom_species.csv")
#' saveRDS(custom_bird_list, "C:/Users/scott.jennings/OneDrive - Audubon Canyon Ranch/Projects/my_R_general/birdnames_support/data/custom_bird_list")

make_custom_bird_list <- function(manual_spp_path){

data("bird_list")
manual_species <- utils::read.csv(manual_spp_path)

custom_bird_list <- dplyr::bind_rows(bird_list, manual_species)
custom_bird_list <- dplyr::mutate_if(custom_bird_list, is.factor, as.character)
custom_bird_list <- dplyr::distinct(custom_bird_list)
custom_bird_list <- dplyr::mutate(custom_bird_list, species = ifelse(.data$alpha.code == "TURN", "Arenaria spp.", .data$species))

return(custom_bird_list)
}


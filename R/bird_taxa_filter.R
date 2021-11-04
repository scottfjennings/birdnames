





#' bird taxa filter
#'
#' Filter a list of bird species by taxonomic relationships.
#'
#' @param data_file your bird data with at least a column containing an allowable species
#'  identifier, either AOU Alpha Code ("alpha.code"), Numeric Code ("species.number"),
#'  Common Name ("common.name"), or Scientific Name ("species")
#' @param keep_taxa names of the taxa to want to filter to; can be names of different taxonomic
#' levels, e.g. c("Charadriiformes", "Falconidae"); can also leave this blank to keep all species
#'  in data_file but add common names, sci names, other taxonomic info
#' @param drop_cols which columns from combined_bird_list do you want to remove; default keeps only
#'  alpha.code, common.name and species
#'
#' @details Currently uses as reference a list of species that contains both those species/
#' taxonomies available in the sources for full_bird_list and some customized species/
#' taxonomies that are useful for ACR's long term monitoring projects (dataset "combined_bird_list")
#' and maybe other projects on waterbirds or shorebirds.
#'
#'   Future versions will allow the user to choose to use full_bird_list, combined_bird_list, or
#'   supply their own customized list. (I tried implementing this but there is some aspect of
#'   scoping that I don't understand and I can't get it to work.)
#'
#' @return data frame with all columns in data_file and all columns in full_bird_list except
#' those specified in drop_cols
#' @importFrom utils data
#' @export
#'
#' @examples
#'
#'  sample_bird_data <- data.frame(alpha.code = c("MALL", "GRSC", "BUFF", "RTHA", "SCAUP",
#'  "GREG", "HOGR"))
#'
#'  # using publicly available and custom bird names (dataset provided with package)
#'
#'  bird_taxa_filter(sample_bird_data, c("Anseriformes", "Podicipediformes"))
#'
#'
bird_taxa_filter <- function(data_file,
                             keep_taxa,
                             drop_cols = c("order", "family", "subfamily", "genus", "species.number")) {

 utils::data("combined_bird_list")
keep_taxa_list <- combined_bird_list %>%
  dplyr::filter(dplyr::if_any(dplyr::everything(), ~ .x %in% keep_taxa)) %>%
droplevels()

out_bird_list <- dplyr::inner_join(data_file, keep_taxa_list)

foo <- dplyr::select(out_bird_list, -tidyselect::any_of(drop_cols))

return(foo)
}









#' bird taxa filter
#'
#' Filter a list of bird species by taxonomic relationships.
#'
#' @param data_file your bird data with at least a column containing an allowable species
#'  identifier, either AOU Alpha Code ("alpha.code"), Numeric Code ("species.number"),
#'  Common Name ("common.name"), or Scientific Name ("species")
#' @param join_taxa 2 character string, first character indicates which species identifier is
#' common between data file and full_bird_list, second character indicates name of this field
#' in data_file
#' @param keep_taxa names of the taxa to want to filter to; can be names of different taxonomic
#' levels, e.g. c("Charadriiformes", "Falconidae"); can also leave this blank to keep all species
#'  in data_file but add common names, sci names, other taxonomic info
#' @param drop_cols which columns from full_bird_list do you want to remove; default keeps only
#'  alpha.code, common.name and species
#' @param use_custom_bird_list optional. If NULL (default), no custom bird names are used. If "yes",
#'  custom_bird_list provided in package is used. User can also specify a local file path for their
#'  own custom bird list (must match format of the provided custom_bird_list)
#'
#' @details User can supply their own custom bird list for additional filtering beyond the
#'  information contained in full_bird_list. So far I have encountered two scenarios where
#'  this is needed:
#'
#'  1. project specific species groups (e.g. Dunlin, Least Sandpiper, Western Sandpiper and
#'  Sanderling not identified to species are recorded as PEEP.
#'  2. Subspecies, races, etc for which there are established banding codes and common names
#'  provided in the IBP and BBL species list but no corresponding taxonomic information in
#'  the AOU species list. In this case the user may want to manually fill in taxonomic information.
#'
#'  The supplied file must have field names matching full_bird_list, but for species groups
#'  alpha.code should contain the species group code ("PEEP" from the above example). The file can
#'  optionally also have the field group.spp, which contains the alpha codes of the species in
#'  that group, separated by commas (DUNL, LESA, WESA, SAND).
#'
#'  The supplied file can contain rows corresponding to both scenarios above, but rows
#'  corresponding to scenario 2 should have alpha.code filled for that subspecies/race
#'  and group.spp set to NA. See the attached custom_bird_list for an example.
#'
#' @return data frame with all columns in data_file and all columns in full_bird_list except
#' those specified in drop_cols
#' @importFrom rlang :=
#' @export
#'
#' @examples
#'  sample_bird_data <- data.frame(alpha.code = c("MALL", "GRSC", "BUFF", "RTHA", "SCAUP",
#'  "GREG", "HOGR"))
#'
#'  bird_taxa_filter(sample_bird_data, c("alpha.code", "alpha.code"),
#'  c("Anseriformes", "Podicipediformes"), use_custom_bird_list = "yes")
#'
#'  bird_taxa_filter(sample_bird_data, c("alpha.code", "alpha.code"),
#'  c("Anseriformes", "Podicipediformes"), use_custom_bird_list = "no")


bird_taxa_filter <- function(data_file,
                             join_taxa = c("alpha.code", "alpha.code"),
                             keep_taxa,
                             drop_cols = c("order", "family", "subfamily", "genus", "species.number"),
                             use_custom_bird_list) {
data("full_bird_list")
data("custom_bird_list")


burd_list_join = join_taxa[1]
data_join = join_taxa[2]

zdata_file <- dplyr::rename(data_file, !!burd_list_join := tidyselect::all_of(data_join))

  if(use_custom_bird_list == "yes") {
    use_bird_list <- full_bird_list %>%
      dplyr::mutate(group.spp = NA) %>%
      rbind(., custom_bird_list)
  }

  if(use_custom_bird_list == "no") {
    use_bird_list <- full_bird_list
  }

  if(use_custom_bird_list != "no" & use_custom_bird_list != "yes") {
    use_bird_list <- full_bird_list %>%
      dplyr::mutate(group.spp = NA) %>%
      rbind(utils::read.csv(custom_bird_list))
        }

keep_taxa_list <- use_bird_list %>%
  dplyr::filter(dplyr::if_any(dplyr::everything(), ~ .x %in% keep_taxa)) %>%
droplevels()

out_bird_list <- dplyr::inner_join(zdata_file, keep_taxa_list)


#out_bird_list <- dplyr::left_join(zdata_file, use_bird_list)



#out_bird_list <- out_bird_list %>%
#  dplyr::filter(dplyr::if_any(dplyr::everything(), ~ .x %in% keep_taxa)) %>%
#droplevels()


foo <- dplyr::select(out_bird_list, -tidyselect::any_of(drop_cols))

return(foo)
}



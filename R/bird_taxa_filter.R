





#' bird taxa filter
#'
#' Filter a list of bird species by taxonomic relationships.
#'
#' @param data_file your bird data with at least a column containing an allowable species identifier, either AOU Alpha Code ("alpha.code"), Numeric Code ("species.number"), Common Name ("common.name"), or Scientific Name ("species")
#' @param join_taxa 2 character string, first character indicates which species identifier is common between data file and full_bird_list, second character indicates name of this field in data_file
#' @param keep_taxa names of the taxa to want to filter to; can be names of different taxonomic levels, e.g. c("Charadriiformes", "Falconidae"); can also leave this blank to keep all species in data_file but add common names, sci names, other taxonomic info
#' @param drop_cols which columns from full_bird_list do you want to remove; default keeps only alpha.code, common.name and species
#'
#' @return data frame with all columns in data_file and all columns in full_bird_list except those specified in drop_cols
#' @export
#'
#' @examples
#'  sample_bird_data <- data.frame(alpha.code = c("MALL", "GRSC", "BUFF", "RTHA", "SCAUP", "GREG", "HOGR"))
#'
#'  bird_taxa_filter(sample_bird_data, c("alpha.code", "alpha.code"), c("Anseriformes", "Podicipediformes"))


bird_taxa_filter <- function(data_file,
                             join_taxa = c("alpha.code", "species"),
                             keep_taxa,
                             drop_cols = c("order", "family", "subfamily", "genus", "species.number")) {

burd_list_join = join_taxa[1]
data_join = join_taxa[2]

zdata_file <- dplyr::rename(data_file, !!burd_list_join := all_of(data_join))

foo <- dplyr::left_join(zdata_file, full_bird_list)


if(missing(keep_taxa)){
  foo <- foo
} else {
foo <- dplyr::filter_all(foo, dplyr::any_vars(. %in% keep_taxa))%>%
  droplevels()
}

foo <- dplyr::select(foo, -tidyselect::any_of(drop_cols))

return(foo)
}



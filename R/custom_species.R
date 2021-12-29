#' Custom bird name list.
#'
#' A dataset containing the names and taxonomic information for bird species, subspecies or
#' species groups that do not exist or do not have complete information in full_bird_list,
#' and which are useful for Audubon Canyon Ranch's long term bird monitoring projects.
#' The bird names and taxonomy in this dataset may not be recognised by any official group.
#' The user can add to or modify this dataset to suit their project, and save the file
#' locally for use in bird_taxa_filter, translate_bird_names, etc.
#'
#' @format A data frame with 42 rows and 9 variables:
#' \describe{
#'   \item{alpha.code}{bird species 4-letter alphabetical code (bird banding code) or
#'   species group code}
#'   \item{common.name}{bird species common name in English}
#'   \item{order}{The order that the bird species belongs to}
#'   \item{family}{The family that the bird species belongs to}
#'   \item{subfamily}{The subfamily that the bird species belongs to}
#'   \item{genus}{The genus that the bird species belongs to}
#'   \item{species}{The full scientific name (Genus and specific epithet) for the bird species}
#'   \item{group.spp}{if alpha.code is a species group code, then contains member species
#'   alpha.codes, otherwise NA}
#' }
#' @source created by hand
"custom_species"

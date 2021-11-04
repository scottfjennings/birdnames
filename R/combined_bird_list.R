#' Combined bird name list.
#'
#' This dataset is simply full_bird_list and custom_bird_list row bound together.
#' The bird names and taxonomy in this dataset may not be recognised by any official group.
#' The user can add to or modify this dataset to suit their project, and save the file
#' locally for use in bird_taxa_filter, translate_bird_names, etc.
#'
#' @format A data frame with 2615 rows and 9 variables:
#' \describe{
#'   \item{alpha.code}{bird species 4-letter alphabetical code (bird banding code) or
#'   species group code}
#'   \item{common.name}{bird species common name in English}
#'   \item{order}{The order that the bird species belongs to}
#'   \item{family}{The family that the bird species belongs to}
#'   \item{subfamily}{The subfamily that the bird species belongs to}
#'   \item{genus}{The genus that the bird species belongs to}
#'   \item{species}{The full scientific name (Genus and specific epithet) for the bird species}
#'   \item{species.number}{The taxonomic number for the bird species (this currenly has many NA)}
#'   \item{group.spp}{if alpha.code is a species group code, then contains member species
#'   alpha.codes, otherwise NA}
#' }
#' @source make_custom_bird_list.R, make_full_bird_list.R
"combined_bird_list"

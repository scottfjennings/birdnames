#' Taxonomic list of North American bird species.
#'
#' A dataset containing the names and taxonomic information for 2191 species and subspecies of birds found in North America. The dataset contains information from three datasets available online:
#' https://www.birdpop.org/docs/misc/Alpha_codes_tax.pdf has 4-letter (banding) codes
#' http://checklist.aou.org/taxa has higher taxonomic classifications
#' These datasets are combined using the workflow in data-raw/bird_list.R
#'
#' @format A data frame with 2191 rows and 8 variables:
#' \describe{
#'   \item{alpha.code}{bird species 4-letter alphabetical code (bird banding code)}
#'   \item{common.name}{bird species common name in English}
#'   \item{order}{The order that the bird species belongs to}
#'   \item{family}{The family that the bird species belongs to}
#'   \item{subfamily}{The subfamily that the bird species belongs to}
#'   \item{genus}{The genus that the bird species belongs to}
#'   \item{species}{The full scientific name (Genus and specific epithet) for the bird species}
#'   \item{specific.name}{specific epithet (name) for the bird species}
#'   \item{subspecific.name}{subspecies name for the bird species}
#'   \item{taxonomic.order}{Numeric helper for sorting species by taxonomic order}
#'   ...
#' }
#' @source \url{https://www.birdpop.org/docs/misc/Alpha_codes_tax.pdf},
#'         \url{http://checklist.aou.org/taxa}
"bird_list"

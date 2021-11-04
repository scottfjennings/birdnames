

#' Translating bird names
#'
#' Translate bird names between common name, alpha code, sci name, etc. Can be used to convert
#'  a dataframe column or add a new one.
#'
#'
#' @param x Character of the bird name you want to change
#' @param from.name The bird name format of x. Can be one of c("alpha.code", "common.name",
#' "order", "family", "subfamily", "genus", "species", "species.number")
#' @param to.name The desired output bird name format. Can be one of c("alpha.code",
#' "common.name", "order", "family", "subfamily", "genus", "species", "species.number")
#'
#' @return character
#' @export
#' @details from.name must be the format of x. E.g., if the x object contains alpha codes,
#' then from.name should be "alpha.code".
#' @examples
#'
#' bird_data <- data.frame(alpha.code = c("LTDU", "MALL", "GRSC"))
#'
#' bird_data <- bird_data %>%
#' dplyr::mutate(common.name = translate_bird_names(alpha.code, "alpha.code", "common.name"),
#' scientific.name = translate_bird_names(alpha.code, "alpha.code", "species"))
#'
#' bird_data
translate_bird_names <- function(x, from.name, to.name) {

 utils::data("combined_bird_list")
from_names <- tolower(combined_bird_list[,from.name])
to_names <- combined_bird_list[,to.name]

plyr::mapvalues(tolower(x), from_names, to_names, warn_missing = FALSE)

}

# translate_bird_names("WREN", "alpha.code", "species")



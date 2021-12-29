

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
#' @return character. If there are no matches for x in bird_list$from.name (or custom_bird_list, if specified),
#' then returns tolower(x)
#' @export
#' @details from.name must be the format of x. E.g., if the x object contains alpha codes,
#' then from.name should be "alpha.code".
#'
#' A custom bird list can be specified as "custom_bird_list" to include user-defined "species" that aren't present in the included "bird_list" dataset. If "custom_bird_list" is not specified, then the included "bird_list" dataset is used as name reference.
#'
#'
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

  if(exists("custom_bird_list")) {
    bird_list = custom_bird_list
  } else {
 utils::data("bird_list")
}

    from_names <- tolower(bird_list[,from.name])
to_names <- bird_list[,to.name]

plyr::mapvalues(tolower(x), from_names, to_names, warn_missing = FALSE)

}

# translate_bird_names("WREN", "alpha.code", "species")



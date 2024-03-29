
# old name fix_4letter_codes

#' Update old alpha codes
#'
#' Update old alpha codes to reflect bird name changes.
#'
#'
#' @param alpha.code character
#'
#' @return character
#' @export
#'
#' @examples
#' update_alpha("OLDS")
#' update_alpha(c("OLDS", "MALL", "BRAN"))
#'
update_alpha <- function(alpha.code) {
alpha.code = as.character(alpha.code)
alpha.code = dplyr::case_when(alpha.code == "REHE" ~ "REDH",
                             alpha.code == "BRCO" ~ "BRAC",
                             alpha.code == "OLDS" ~ "LTDU",
                             alpha.code == "NOSH" ~ "NSHO",
                             alpha.code == "TEAL" ~ "UNTE",
                             alpha.code == "COMO" ~ "COGA",
                             alpha.code == "COSN" ~ "WISN",
                             alpha.code == "CAGO" ~ "CANG",
                             alpha.code == "WESJ" ~ "CASJ",
                             alpha.code == "MEGU" ~ "SBIG",
                             alpha.code == "HARD" ~ "HADU",
                             alpha.code == "BAOW" ~ "BANO",
                             TRUE ~ alpha.code)
    return(alpha.code)
}


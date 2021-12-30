
#' bird names from text
#'
#' Extract bird species names from text.
#'
#' @param x one or more character strings, e.g. a database notes field. Will recognize alpha codes and common names.
#'
#' @return A character vector of same length as x. If multiple bird species names exist in
#'  each element of x, they will be separated by an underscore in the output vector.
#' @importFrom stringr str_extract_all
#' @importFrom rlang .data
#' @export
#'
#' @examples
#' test_text <- c("Bald Eagle and White-tailed Kite and WREN are birds.",
#' "The Great Blue Heron is taller than the Snowy Egret")
#'
#' bird_names_from_text(test_text)
bird_names_from_text <- function(x) {


  if(exists("custom_bird_list")) {
    bird_list = custom_bird_list
  } else {
 utils::data("bird_list")
}


bird_names <- rbind(bird_list %>%
                      dplyr::select(code.name = .data$common.name),
                    bird_list %>%
                      dplyr::select(code.name = .data$alpha.code),
                    bird_list %>%
                      dplyr::filter(grepl("nidentified", .data$common.name)) %>%
                      dplyr::mutate(common.name = gsub("Unidentified", "", common.name)) %>%
                      dplyr::distinct(common.name) %>%
                      dplyr::rename(code.name = .data$common.name)) %>%
  dplyr::mutate(code.name = tolower(.data$code.name)) %>%
  dplyr::summarise(paste(.data$code.name, collapse = "|"))

out_names <- paste(stringr::str_extract_all(tolower(x), bird_names[[1]]))
out_names <- gsub("c[()]", "", out_names)
out_names <- gsub("[()]", "", out_names)
out_names <- gsub(paste(c("character0", '"'), collapse = "|"), "", out_names)
out_names <- gsub(", ", "_", out_names)
#return(out_names)
}


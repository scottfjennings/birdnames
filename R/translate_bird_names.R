
# translate bird names between common name, alpha code, sci name, etc.
# from.name and to.name can be any of c("alpha.code", "common.name", "order", "family", "subfamily", "genus", "species", "species.number")
translate_bird_names <- function(x, from.name, to.name) {

#full_bird_list <- readRDS("C:/Users/scott.jennings/Documents/Projects/R_general/utility_functions/utility_function_data/full_bird_list")

from_names <- tolower(full_bird_list[,from.name])
to_names <- full_bird_list[,to.name]

#names(to_names) <- from_names

#str_replace_all(tolower(x), to_names)
plyr::mapvalues(tolower(x), from_names, to_names, warn_missing = FALSE)

}

# translate_bird_names("WREN", "alpha.code", "species")




# old name fix_4letter_codes
update_alpha <- function(alpha.code) {
alpha.code = as.character(alpha.code)
alpha.code = case_when(alpha.code == "REHE" ~ "REDH",
                             alpha.code == "BRCO" ~ "BRAC",
                             alpha.code == "BRAN" ~ "BLBR",
                             alpha.code == "GWTE" ~ "AGWT",
                             alpha.code == "OLDS" ~ "LTDU",
                             alpha.code == "NOSH" ~ "NSHO",
                             alpha.code == "TEAL" ~ "UNTE",
                             alpha.code == "HADU" ~ "HARD",
                             alpha.code == "COMO" ~ "COGA",
                             alpha.code == "COSN" ~ "WISN",
                             alpha.code == "CAGO" ~ "CANG",
                             alpha.code == "WESJ" ~ "CASJ",
                             TRUE ~ alpha.code)
    return(alpha.code)
}


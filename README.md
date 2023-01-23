
<!-- README.md is generated from README.Rmd. Please edit that file -->

# birdnames

<!-- badges: start -->
<!-- badges: end -->

The goal of birdnames is to help with data management for multi-species
bird datasets, especially long-term monitoring datasets. All functions
in this package operate on bird species names, and provide functionality
to move between the different names that might be used for birds.
Particularly, this package helps move from raw data with 4-letter
alpha-code (banding code) to analyses, reports, etc. with common and
scientific names. It also allows filtering by multiple taxonomic levels.

## Installation

You can install the development version of birdnames from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
# devtools::install_github("scottfjennings/birdnames")
```

## Setup

If your dataset contains “species” that don’t exist in bird_list, you
can insert your custom species int bird_list in the taxonomically
correct location and save the resulting custom_bird_list in some logical
local place. Currently your custom_species file should have the same
structure as bird_list and have as much of the higher taxonomic
information filled in. If your “species” are species groups
(e.g. alpha.code = “CORM” or common.name = “Cormorant” for unidentified
cormorants), then custom_species can additionally have a field called
“group.spp” which contains the constituent species alpha.codes as
appropriate for your study, separated by commas (e.g. group.spp = “DCCO,
BRAC”). See the included sample “custom_species” dataset for formatting
help.

TODO: future versions will allow user to supply custom_species with just
three fields, alpha.code, common.name and group.spp, and the higher
taxonomic info will be filled automatically.

``` r
library(birdnames)
library(tidyverse)

data("bird_list")

custom_bird_list <- bird_list %>%
  bind_rows(., utils::read.csv("C:/Users/scott.jennings/Documents/Projects/my_R_general/birdnames_support/data/custom_species.csv")) %>%
  add_taxon_order()


saveRDS(custom_bird_list, "C:/Users/scott.jennings/Documents/Projects/my_R_general/birdnames_support/data/custom_bird_list")
```

## Example workflow using birdnames

Suppose you have a long term monitoring dataset for waterbirds and
raptors at a wetland, with the species identity stored as the 4-letter
(banding) alpha code. There may be some alpha codes from early in the
study that do not reflect changes in bird names (e.g. “OLDS”). There may
also be data representing counts of individuals that were identified to
group rather than species (e.g. “SCAUP” for Greater and Lesser Scaup).
The functions in birdnames can be piped together using magrittr::%\>%;
in this example we’ll build up a workflow one function at a time.

If you have created a locally-stored custom_bird_list, it should be read
in early in your workflow.

``` r
library(birdnames)
library(tidyverse)
#> Warning: package 'tidyr' was built under R version 4.0.5
#> Warning: package 'readr' was built under R version 4.0.5
#> Warning: package 'forcats' was built under R version 4.0.5

custom_bird_list <- readRDS("C:/Users/scott.jennings/Documents/Projects/my_R_general/birdnames_support/data/custom_bird_list")

## Generate basic example dataset
waterbird_data <- data.frame(alpha.code = c("OLDS", "LTDU", "MALL", "WTKI", "GRSC", "SCAUP", "GWTE", "COLO", "WEGR"))
waterbird_data
#>   alpha.code
#> 1       OLDS
#> 2       LTDU
#> 3       MALL
#> 4       WTKI
#> 5       GRSC
#> 6      SCAUP
#> 7       GWTE
#> 8       COLO
#> 9       WEGR
```

A first step in using this dataset might be to replace outdated species
codes with current ones. Note update_alpha() operates on the alpha.code
field directly, not on the entire dataframe, so it must be used inside
dplyr::mutate().

``` r
waterbird_data %>% 
  mutate(alpha.code = update_alpha(alpha.code))
#>   alpha.code
#> 1       LTDU
#> 2       LTDU
#> 3       MALL
#> 4       WTKI
#> 5       GRSC
#> 6      SCAUP
#> 7       GWTE
#> 8       COLO
#> 9       WEGR
```

Next you may want to filter to just the waterbird species (remove
White-tailed Kite). bird_taxa_filter combines the tasks of joining the
user’s dataset to a table with full taxonomic information then filtering
based on those taxonomies. The function relies on a reference list of
species composed of both the available bird taxonomy compiled in
bird_list, plus those species, subspecies and species groups that do not
exist or do not have complete information in bird_list (these additional
“custom” species are contained in custom_bird_list). Using
combined_bird_list allows proper handling of species groups like
“SCAUP”.

Note: Future versions will hopefully allow the user to choose to use
bird_list, combined_bird_list, or supply their own customized list. I
have tried implementing this but there is some aspect of scoping that I
don’t understand and I can’t get it to work.

``` r
waterbird_data %>% 
  mutate(alpha.code = update_alpha(alpha.code)) %>% 
  bird_taxa_filter(keep_taxa = c("Anseriformes", "Gaviiformes", "Podicepiformes"))
#> Joining, by = "alpha.code"
#>   alpha.code
#> 1       LTDU
#> 2       LTDU
#> 3       MALL
#> 4       GRSC
#> 5      SCAUP
#> 6       GWTE
#> 7       COLO
```

At this point, the user can proceed with analysis, summary tasks, etc.
When it is time to present results, summary tables, etc., species’
common names, scientific names, or other taxonomic information can be
added with translate_bird_names:

``` r
waterbird_data %>% 
  mutate(alpha.code = update_alpha(alpha.code)) %>% 
  bird_taxa_filter(keep_taxa = c("Anseriformes", "Gaviiformes", "Podicepiformes")) %>% 
  mutate(common.name = translate_bird_names(alpha.code, "alpha.code", "common.name"),
         scientific.name = translate_bird_names(alpha.code, "alpha.code", "species"))
#> Joining, by = "alpha.code"
#>   alpha.code       common.name    scientific.name
#> 1       LTDU  Long-tailed Duck  Clangula hyemalis
#> 2       LTDU  Long-tailed Duck  Clangula hyemalis
#> 3       MALL           Mallard Anas platyrhynchos
#> 4       GRSC     Greater Scaup      Aythya marila
#> 5      SCAUP             Scaup        Aythya spp.
#> 6       GWTE Green-winged Teal        Anas crecca
#> 7       COLO       Common Loon        Gavia immer
```

The provided dataset bird_list can be passed to bird_taxa_filter to
generate a list of all species meeting a particular taxonomic criteria
(i.e. not just those species in the user’s own dataset). The user may
also want to include species taxonomic order (“taxonomic.order”) to
allow taxonomic sorting of their bird list.

``` r
data("bird_list")
ducks <- bird_list %>% 
  select(alpha.code) %>% 
  bird_taxa_filter(keep_taxa = "Anseriformes") %>% 
  mutate(common.name = translate_bird_names(alpha.code, "alpha.code", "common.name"),
         scientific.name = translate_bird_names(alpha.code, "alpha.code", "species"),
         taxonomic.order = translate_bird_names(alpha.code, "alpha.code", "taxonomic.order")) %>% 
  arrange(taxonomic.order)
#> Joining, by = "alpha.code"
head(ducks)
#>   alpha.code            common.name     scientific.name taxonomic.order
#> 1       FUWD Fulvous Whistling-Duck Dendrocygna bicolor              10
#> 2       COSC          Common Scoter     Melanitta nigra             100
#> 3       BLSC           Black Scoter Melanitta americana             101
#> 4       LTDU       Long-tailed Duck   Clangula hyemalis             103
#> 5       BUFF             Bufflehead   Bucephala albeola             104
#> 6       COGO       Common Goldeneye  Bucephala clangula             105
```

bird_taxa_filer also allows filtering at multiple taxonomic levels. For
example, you might wish to isolate data for all waterbirds in the orders
Anseriformes, Gaviiformes and Podicepiformes, and also the raptor
species in the genera Falco and Accipiter.

``` r
waterbirds_faclons_accipiters <- bird_list %>% 
  select(alpha.code) %>% 
  bird_taxa_filter(keep_taxa = c("Anseriformes", "Gaviiformes", "Podicepiformes", "Falco", "Accipiter")) %>% 
  mutate(common.name = translate_bird_names(alpha.code, "alpha.code", "common.name"),
         scientific.name = translate_bird_names(alpha.code, "alpha.code", "species"),
         order = translate_bird_names(alpha.code, "alpha.code", "order"),
         family = translate_bird_names(alpha.code, "alpha.code", "family"),
         genus = translate_bird_names(alpha.code, "alpha.code", "genus"),
         taxonomic.order = translate_bird_names(alpha.code, "alpha.code", "taxonomic.order")) %>% view()
#> Joining, by = "alpha.code"
```

Finally, many datasets also have a notes field. bird_names_from_text is
a helper to find records where bird species are mentioned in the notes
field. Note that some 4-letter alpha codes are whole or partial English
words, so some non-bird names may slip through this function (e.g. below
Chapman’s Swift 4-letter code is CHAS so part of chased is retained in
bird.notes).

``` r
data_with_notes <- data.frame(date = c(rep(Sys.Date()-30, 3), rep(Sys.Date()-60, 3), rep(Sys.Date()-90, 3)),
                              alpha.code = rep(c("COLO", "PBGR", "MALL"), 3),
                              notes = c("cheese and crackers for lunch today",
                                        NA,
                                        "also AMWI and teal",
                                        NA,
                                        "chased by peregrine falcon",
                                        NA,
                                        "rain",
                                        NA,
                                        NA))


data_with_notes <- data_with_notes %>% 
  dplyr::mutate(bird.notes = bird_names_from_text(notes))

data_with_notes
#>         date alpha.code                               notes
#> 1 2022-12-24       COLO cheese and crackers for lunch today
#> 2 2022-12-24       PBGR                                <NA>
#> 3 2022-12-24       MALL                  also AMWI and teal
#> 4 2022-11-24       COLO                                <NA>
#> 5 2022-11-24       PBGR          chased by peregrine falcon
#> 6 2022-11-24       MALL                                <NA>
#> 7 2022-10-25       COLO                                rain
#> 8 2022-10-25       PBGR                                <NA>
#> 9 2022-10-25       MALL                                <NA>
#>              bird.notes
#> 1                      
#> 2                    NA
#> 3            amwi_ teal
#> 4                    NA
#> 5 chas_peregrine falcon
#> 6                    NA
#> 7                      
#> 8                    NA
#> 9                    NA
```

## Updates

29 Dec 2021. Implemented two changes to how the package works:  
1. Taxonomic ordering is now down based on the order of the most recent
AOU list. The taxonomic numbers were discontinued with 7th AOU checklist
update. Using taxonomic order of AOU list is more future-proof.  
2. updated translate_bird_names and bird_taxa_filter to use a locally
saved custom_bird_list (if such a file has been loaded into the Global
Env). The custom_bird_list with ACR grouped taxa is no longer an
included dataset, but the small table with these grouped taxa only is
included as a formatting example.

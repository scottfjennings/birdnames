
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

If your dataset contains “species” that don’t exist in bird\_list, you
can insert your custom species int bird\_list in the taxonomically
correct location and save the resulting custom\_bird\_list in some
logical local place. Currently your custom\_species file should have the
same structure as bird\_list and have as much of the higher taxonomic
information filled in. If your “species” are species groups
(e.g. alpha.code = “CORM” or common.name = “Cormorant” for unidentified
cormorants), then custom\_species can additionally have a field called
“group.spp” which contains the constituent species alpha.codes as
appropriate for your study, separated by commas (e.g. group.spp = “DCCO,
BRAC”). See the included sample “custom\_species” dataset for formatting
help.

TODO: future versions will allow user to supply custom\_species with
just three fields, alpha.code, common.name and group.spp, and the higher
taxonomic info will be filled automatically.

``` r
library(birdnames)
library(tidyverse)

data("bird_list")

custom_bird_list <- bird_list %>%
  bind_rows(., utils::read.csv("C:/Users/scott.jennings/Documents/Projects/birdnames_support/data/custom_species.csv")) %>%
  add_taxon_order()


saveRDS(custom_bird_list, "C:/Users/scott.jennings/Documents/Projects/birdnames_support/data/custom_bird_list")
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

If you have created a locally-stored custom\_bird\_list, it should be
read in early in your workflow.

``` r
library(birdnames)
library(tidyverse)
#> Warning: package 'ggplot2' was built under R version 4.0.5
#> Warning: package 'tibble' was built under R version 4.0.5
#> Warning: package 'dplyr' was built under R version 4.0.5

custom_bird_list <- readRDS("C:/Users/scott.jennings/Documents/Projects/birdnames_support/data/custom_bird_list")

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
codes with current ones. Note update\_alpha() operates on the alpha.code
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
#> 7       AGWT
#> 8       COLO
#> 9       WEGR
```

Next you may want to filter to just the waterbird species (remove
White-tailed Kite). bird\_taxa\_filter combines the tasks of joining the
user’s dataset to a table with full taxonomic information then filtering
based on those taxonomies. The function relies on a reference list of
species composed of both the available bird taxonomy compiled in
full\_bird\_list, plus those species, subspecies and species groups that
do not exist or do not have complete information in full\_bird\_list
(these additional “custom” species are contained in custom\_bird\_list).
Using combined\_bird\_list allows proper handling of species groups like
“SCAUP”.

Note: Future versions will hopefully allow the user to choose to use
full\_bird\_list, combined\_bird\_list, or supply their own customized
list. I have tried implementing this but there is some aspect of scoping
that I don’t understand and I can’t get it to work.

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
#> 6       COLO
```

At this point, the user can proceed with analysis, summary tasks, etc.
When it is time to present results, summary tables, etc., species’
common names, scientific names, or other taxonomic information can be
added with translate\_bird\_names:

``` r
waterbird_data %>% 
  mutate(alpha.code = update_alpha(alpha.code)) %>% 
  bird_taxa_filter(keep_taxa = c("Anseriformes", "Gaviiformes", "Podicepiformes")) %>% 
  mutate(common.name = translate_bird_names(alpha.code, "alpha.code", "common.name"),
         scientific.name = translate_bird_names(alpha.code, "alpha.code", "species"))
#> Joining, by = "alpha.code"
#>   alpha.code      common.name    scientific.name
#> 1       LTDU Long-tailed Duck  Clangula hyemalis
#> 2       LTDU Long-tailed Duck  Clangula hyemalis
#> 3       MALL          Mallard Anas platyrhynchos
#> 4       GRSC    Greater Scaup      Aythya marila
#> 5      SCAUP            Scaup        Aythya spp.
#> 6       COLO      Common Loon        Gavia immer
```

The provided dataset full\_bird\_list can be passed to
bird\_taxa\_filter to generate a list of all species meeting a
particular taxonomic criteria (i.e. not just those species in the user’s
own dataset). The user may also want to include species taxonomic number
(“species.number”) to allow taxonomic sorting of their bird list.

``` r
data("full_bird_list")
ducks <- full_bird_list %>% 
  select(alpha.code) %>% 
  bird_taxa_filter(keep_taxa = "Anseriformes") %>% 
  mutate(common.name = translate_bird_names(alpha.code, "alpha.code", "common.name"),
         scientific.name = translate_bird_names(alpha.code, "alpha.code", "species"),
         species.number = translate_bird_names(alpha.code, "alpha.code", "species.number")) %>% 
  arrange(species.number)
#> Joining, by = "alpha.code"
head(ducks)
#>   alpha.code            common.name       scientific.name species.number
#> 1       COME       Common Merganser      Mergus merganser           1290
#> 2       RBME Red-breasted Merganser       Mergus serrator           1300
#> 3       HOME       Hooded Merganser Lophodytes cucullatus           1310
#> 4       MALL                Mallard    Anas platyrhynchos           1320
#> 5       HAWD          Hawaiian Duck       Anas wyvilliana           1321
#> 6       ABDU    American Black Duck         Anas rubripes           1330
```

bird\_taxa\_filer also allows filtering at multiple taxonomic levels.
For example, you might wish to isolate data for all waterbirds in the
orders Anseriformes, Gaviiformes and Podicepiformes, and also the raptor
species in the genera Falco and Accipiter.

``` r
waterbirds_faclons_accipiters <- full_bird_list %>% 
  select(alpha.code) %>% 
  bird_taxa_filter(keep_taxa = c("Anseriformes", "Gaviiformes", "Podicepiformes", "Falco", "Accipiter")) %>% 
  mutate(common.name = translate_bird_names(alpha.code, "alpha.code", "common.name"),
         scientific.name = translate_bird_names(alpha.code, "alpha.code", "species"),
         order = translate_bird_names(alpha.code, "alpha.code", "order"),
         family = translate_bird_names(alpha.code, "alpha.code", "family"),
         genus = translate_bird_names(alpha.code, "alpha.code", "genus"),
         species.number = translate_bird_names(alpha.code, "alpha.code", "species.number")) %>% view()
#> Joining, by = "alpha.code"
```

Finally, many datasets also have a notes field. bird\_names\_from\_text
is a helper to find records where bird species are mentioned in the
notes field. Note that some 4-letter alpha codes are whole or partial
English words, so some non-bird names may slip through this function
(e.g. below Chapman’s Swift 4-letter code is CHAS so part of chased is
retained in bird.notes).

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
#> 1 2021-11-29       COLO cheese and crackers for lunch today
#> 2 2021-11-29       PBGR                                <NA>
#> 3 2021-11-29       MALL                  also AMWI and teal
#> 4 2021-10-30       COLO                                <NA>
#> 5 2021-10-30       PBGR          chased by peregrine falcon
#> 6 2021-10-30       MALL                                <NA>
#> 7 2021-09-30       COLO                                rain
#> 8 2021-09-30       PBGR                                <NA>
#> 9 2021-09-30       MALL                                <NA>
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
1\. Taxonomic ordering is now down based on the order of the most recent
AOU list. The taxonomic numbers were discontinued with 7th AOU checklist
update. Using taxonomic order of AOU list is more future-proof.  
2\. updated translate\_bird\_names and bird\_taxa\_filter to use a
locally saved custom\_bird\_list (if such a file has been loaded into
the Global Env). The custom\_bird\_list with ACR grouped taxa is no
longer an included dataset, but the small table with these grouped taxa
only is included as a formatting example.

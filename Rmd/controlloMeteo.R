rm(list=objects())
library("tidyverse")
library("vroom")
library("furrr")
library("skimr")
library("seplyr")

cols(.default = col_double(),
     station_eu_code=col_character(),
     date=col_date(format="%Y-%m-%d"))->TIPI

vroom("meteo.csv",delim=";",
      col_names = TRUE,
      col_types = TIPI) %>%
  filter(!is.na(station_eu_code))->dati

read_delim("anaMeteo.csv",delim=";",col_names = TRUE)->ana

names(dati)->nomi
nomi[! grepl("^[sdca]",nomi)]->variabiliMeteo

purrr::walk(variabiliMeteo,.f=function(nomeVar){ 
  
  rmarkdown::render(input="controlloMeteo.Rmd",
                    output_format = "html_document",
                    output_file = glue::glue("{nomeVar}.html"),
                    params = list(variabileMeteo=nomeVar))
  
  })


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

sink("index.Rmd",append=FALSE)
cat("---\n")
cat("title: Analisi variabili meteo\n")
cat("author: ISPRA\n")
cat("date: \"`r lubridate::today()`\" \n")
cat("---\n")


purrr::walk(variabiliMeteo,.f=function(nomeVar){ 
  
  stringa<-glue::glue("[Variabile {nomeVar}](./{nomeVar}.html)")
  cat(paste0(stringa,"\n"))
  cat("\n")
  
  })
sink()

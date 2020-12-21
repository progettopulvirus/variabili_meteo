rm(list=objects())
library("tidyverse")
library("vroom")
library("furrr")
library("skimr")
library("seplyr")
library("read.so")
library("multicolor")
library("cowsay")
library("multicolor")

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

read_md(file="tabellaVariabiliMeteo.md")->tabellaMeteo


sink("index.Rmd",append=FALSE)
cat("---\n")
cat("title: Analisi variabili meteo\n")
cat("author: ISPRA\n")
cat("date: \"`r lubridate::today()`\" \n")
cat("---\n")

paste0("\n\n","Sintesi descrittiva delle variabili meteoclimatiche estratte da ERA5.","\n\n")->stringa

cat(paste0("\n","```{r,include=TRUE,echo=FALSE,warning=FALSE,message=FALSE}","\n"))
cat(paste0(glue::glue("\n","cowsay::say(what = '{stringa}')"),"\n"))
cat(paste0("\n","```","\n"))
purrr::walk(variabiliMeteo,.f=function(nomeVar){ 
  
  
  myEmojy<-""
  
  if(grepl("2m",nomeVar)){
    myEmojy<-"thermometer"
  }else if(grepl("tp",nomeVar)){
    myEmojy<-"umbrella"
  }else if(grepl("rh",nomeVar)){
    myEmojy<-"sweat_drops"
  }else if(grepl("(10m|w)",nomeVar)){
    myEmojy<-"wind_face"
  }else if(grepl("nirradiance",nomeVar)){
    myEmojy<-"sunny"
  }else if(grepl("pbl",nomeVar)){
    myEmojy<-"straight_ruler"
  }
  
  grep(paste0("^ *",nomeVar," *$"),tabellaMeteo$Codice,ignore.case = TRUE)->riga
  if(length(riga)!=1) browser()
  
  stringa<-glue::glue("[{tabellaMeteo$Codice[riga]}](./{nomeVar}.html) {emo::ji(myEmojy)}")
  cat(paste0(glue::glue("\n\n### {tabellaMeteo$Nome[riga]}"),"\n"))
  cat("\n")
  cat(paste0(stringa,"\n\n"))
  cat("---\n\n")
  
  })
sink()

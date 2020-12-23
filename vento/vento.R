#I parametri wdir e wspeed calcolati da ERA5 da Walter per pulvirus sembrano non
#essere corretti. Li ricalcoliamo
rm(list=objects())
library("tidyverse")
library("rWind")
library("kehra")
library("Rsenal")
library("furrr")

plan(multicore,workers=30)

read_delim(file="../meteo.csv",delim=";",col_names = TRUE)->dati
nrow(dati)->numeroRighe

unique(dati$station_eu_code)->codiciStazioni

furrr::future_map(codiciStazioni,.f=function(codice){
  
  dati %>%
    filter(station_eu_code==codice)->subDati
  
  nrow(subDati)->numeroRighe
  
  if(!numeroRighe) return()

  purrr::map_dfr(1:numeroRighe,.f=function(r){
      
    print(r)
    subDati[r,]$u10m->U
    subDati[r,]$v10m->V
      
        
      #non sembra essere corretta rWind::uv2ds(U,V)->newWind
      #kehra::windDirection(U,V)->wDir
      #kehra::windSpeed(U,V)->wSpeed  
      #c(wDir,wSpeed)->newWind2
      #names(newWind2)<-c("dir","speed")
      Rsenal::uv2wdws(U,V)->newWind3
      #compare::compareIgnoreAttrs(newWind2,newWind3)->ris
      #if(!ris$result) stop("Non identici")
    
      data.frame(station_eu_code=subDati[r,]$station_eu_code,
             date=subDati[r,]$date,
             wdir=as.numeric(newWind3[1]), 
             wspeed=as.numeric(newWind3[2]),stringsAsFactors = FALSE,check.names = FALSE)
      
    })->listaOut
  
  if(!nrow(listaOut)) return()
  
  listaOut
  
})->finale

purrr::compact(finale)->finale

if(!length(finale)) stop()

purrr::reduce(finale,.f=bind_rows)->dfVento
browser()

furrr::future_map(codiciStazioni,.f=function(codice){
  
  print(codice)
  
  dfVento %>%
    filter(station_eu_code==codice)->subDati

  subDati %>%
    mutate(ndate=date+1,pwspeed=wspeed) %>%
    dplyr::select(station_eu_code,ndate,pwspeed) %>%
    rename(date=ndate)->subDati2
  
  left_join(subDati,subDati2)
  
  
})->listaOut

purrr::reduce(listaOut,.f=bind_rows)->dfVento2


write_delim(dfVento2,"datiVengoGuido.csv",delim=";",col_names = TRUE)

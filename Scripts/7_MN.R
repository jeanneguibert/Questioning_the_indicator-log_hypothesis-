##########################################################################################
#### epipelagic ####
##########################################################################################

rm(list=ls())

resolution <- 2

#--Libraries
library(ncdf4) # package for netcdf manipulation
library(chron) 
library(lattice) 
library(readr) 
library(ggplot2)
library(plyr)
library(lubridate)

#set path and filename
PATH_DATA<-"D:/Stage_Jeanne/Data/Netcdf/Micronecton/epi/"
file_list<-list.files(PATH_DATA)

df_meantot<-data.frame(matrix(nrow=0,ncol=6))
colnames(df_meantot)=c("lat_grid", "lon_grid","year", "month",
                       "micronec_epimean", "micronec_episd")

for (ifile in file_list){
  nc_file <- ifile
  nc_name <- paste(PATH_DATA, nc_file, sep = "")
  nc_name
  
  #open the NetCDF file
  nc <- nc_open(nc_name)
  print(nc)
  
  lon <- ncvar_get(nc, "longitude")
  lat <- ncvar_get(nc, "latitude")
  time <- ncvar_get(nc, "time")
  
  nlon <- dim(lon)
  nlat <- dim(lat)
  ntime<- dim(time)
  t_units <- ncatt_get(nc, "time", "units")
  
  # convert time -- split the time units string into fields
  t_ustr <- strsplit(t_units$value, " ")
  t_dstr <- strsplit(unlist(t_ustr)[3], "-")
  t_month <- as.integer(unlist(t_dstr)[2])
  t_day <- as.integer(unlist(t_dstr)[3])
  t_year <- as.integer(unlist(t_dstr)[1])
  chron(floor(time/86400),origin=c(t_day, t_month, t_year),format = "d/m/y")
  
  #Pour avoir l'annee, le mois ou le jour :
  mydate<-chron(floor(time/86400),origin=c(t_day, t_month, t_year),format = "d/m/y")
  
  mydate<-as.Date(mydate,'%Y/%m/%d')
  myyear<-year(mydate)
  mymonth<-month(mydate)
  myday<-day(mydate)
  
  #extract micronecton
  var_epi <- "mnkc_epi" 
  T_array <- ncvar_get(nc, var_epi)
  invisible(gc())
  
  #variable's attributes
  long_name <- ncatt_get(nc, var_epi, "long_name")   #long name
  T_units <- ncatt_get(nc, var_epi, "units")         #measure unit
  fillvalue <- ncatt_get(nc, var_epi, "_FillValue")  #(optional)  
  
  ## put NA values for missing values in the NetCDF file
  T_array[T_array == fillvalue$value] <- NA
  invisible(gc())
  
  #estimate mean for each year, month and 2° cell
  
  grid <- expand.grid(lon=lon, lat=lat)  #create a set of lonlat pairs of values, one for each element in the tem_array
  iyear<-unique(myyear)
  for (imonth in c(1:12)){
    datesel<-(mymonth ==imonth)
    T_slice<-T_array[,,datesel]
    ndays<-sum(datesel)
    grid_1day <- expand.grid(lon=lon, lat=lat)  #create a set of lonlat pairs of values, one for each element in the tem_array
    grid <- as.data.frame(cbind(lon = rep(grid_1day$lon, ndays),
                                lat = rep(grid_1day$lat, ndays)))
    
    grid$micronec_epi<-as.vector(T_slice)
    df<-subset(grid,!is.na(micronec_epi))
    df$lat_grid<-resolution*floor(df$lat/resolution) 
    df$lon_grid<-resolution*floor(df$lon/resolution) 
    df_mean<-ddply(df,.(lat_grid,lon_grid),summarize,micronec_epi=mean(micronec_epi),micronec_episd=sd(micronec_epi))#moyenne
    df_mean$year<-iyear
    df_mean$month<-imonth
    df_meantot<-rbind(df_meantot,df_mean)
    
    rm(grid, df, df_mean, T_slice)
    invisible(gc())
  }
  rm(T_array)
  invisible(gc())
}

write.csv(df_meantot,file="MN_epi_mean.csv",row.names = F,col.names = T)

##########################################################################################
#### upper mesopelagic ####
##########################################################################################

rm(list=ls())

resolution <- 2

#--Libraries
library(ncdf4) # package for netcdf manipulation
library(chron) 
library(lattice) 
library(readr) 
library(ggplot2)
library(plyr)
library(lubridate)

#set path and filename
PATH_DATA<-"D:/Stage_Jeanne/Data/Netcdf/Micronecton/u/"
file_list<-list.files(PATH_DATA)

df_meantot<-data.frame(matrix(nrow=0,ncol=6))
colnames(df_meantot)=c("lat_grid", "lon_grid","year", "month",
                       "micronec_umean", "micronec_usd")

for (ifile in file_list){
  nc_file <- ifile
  nc_name <- paste(PATH_DATA, nc_file, sep = "")
  nc_name
  
  #open the NetCDF file
  nc <- nc_open(nc_name)
  print(nc)
  
  lon <- ncvar_get(nc, "longitude")
  lat <- ncvar_get(nc, "latitude")
  time <- ncvar_get(nc, "time")
  
  nlon <- dim(lon)
  nlat <- dim(lat)
  ntime<- dim(time)
  t_units <- ncatt_get(nc, "time", "units")
  
  # convert time -- split the time units string into fields
  t_ustr <- strsplit(t_units$value, " ")
  t_dstr <- strsplit(unlist(t_ustr)[3], "-")
  t_month <- as.integer(unlist(t_dstr)[2])
  t_day <- as.integer(unlist(t_dstr)[3])
  t_year <- as.integer(unlist(t_dstr)[1])
  chron(floor(time/86400),origin=c(t_day, t_month, t_year),format = "d/m/y")
  
  #Pour avoir l'annee, le mois ou le jour :
  mydate<-chron(floor(time/86400),origin=c(t_day, t_month, t_year),format = "d/m/y")
  
  mydate<-as.Date(mydate,'%Y/%m/%d')
  myyear<-year(mydate)
  mymonth<-month(mydate)
  myday<-day(mydate)
  
  #extract micronecton
  var_u <- "mnkc_umeso" 
  T_array <- ncvar_get(nc, var_u)
  invisible(gc())
  
  #variable's attributes
  long_name <- ncatt_get(nc, var_u, "long_name")   #long name
  T_units <- ncatt_get(nc, var_u, "units")         #measure unit
  fillvalue <- ncatt_get(nc, var_u, "_FillValue")  #(optional)  
  
  ## put NA values for missing values in the NetCDF file
  T_array[T_array == fillvalue$value] <- NA
  invisible(gc())
  
  #estimate mean for each year, month and 2° cell
  
  grid <- expand.grid(lon=lon, lat=lat)  #create a set of lonlat pairs of values, one for each element in the tem_array
  iyear<-unique(myyear)
  for (imonth in c(1:12)){
    datesel<-(mymonth ==imonth)
    T_slice<-T_array[,,datesel]
    ndays<-sum(datesel)
    grid_1day <- expand.grid(lon=lon, lat=lat)  #create a set of lonlat pairs of values, one for each element in the tem_array
    grid <- as.data.frame(cbind(lon = rep(grid_1day$lon, ndays),
                                lat = rep(grid_1day$lat, ndays)))
    
    grid$micronec_u<-as.vector(T_slice)
    df<-subset(grid,!is.na(micronec_u))
    df$lat_grid<-resolution*floor(df$lat/resolution) 
    df$lon_grid<-resolution*floor(df$lon/resolution) 
    df_mean<-ddply(df,.(lat_grid,lon_grid),summarize,micronec_u=mean(micronec_u),micronec_usd=sd(micronec_u))#moyenne
    df_mean$year<-iyear
    df_mean$month<-imonth
    df_meantot<-rbind(df_meantot,df_mean)
    
    rm(grid, df, df_mean, T_slice)
    invisible(gc())
  }
  rm(T_array)
  invisible(gc())
}

write.csv(df_meantot,file="MN_u_mean.csv",row.names = F,col.names = T)

##########################################################################################
#### migrant upper mesopelagic ####
##########################################################################################

rm(list=ls())

resolution <- 2

#--Libraries
library(ncdf4) # package for netcdf manipulation
library(chron) 
library(lattice) 
library(readr) 
library(ggplot2)
library(plyr)
library(lubridate)

#set path and filename
PATH_DATA<-"D:/Stage_Jeanne/Data/Netcdf/Micronecton/mu/"
file_list<-list.files(PATH_DATA)

df_meantot<-data.frame(matrix(nrow=0,ncol=6))
colnames(df_meantot)=c("lat_grid", "lon_grid","year", "month",
                       "micronec_mumean", "micronec_musd")

for (ifile in file_list){
  nc_file <- ifile
  nc_name <- paste(PATH_DATA, nc_file, sep = "")
  nc_name
  
  #open the NetCDF file
  nc <- nc_open(nc_name)
  print(nc)
  
  lon <- ncvar_get(nc, "longitude")
  lat <- ncvar_get(nc, "latitude")
  time <- ncvar_get(nc, "time")
  
  nlon <- dim(lon)
  nlat <- dim(lat)
  ntime<- dim(time)
  t_units <- ncatt_get(nc, "time", "units")
  
  # convert time -- split the time units string into fields
  t_ustr <- strsplit(t_units$value, " ")
  t_dstr <- strsplit(unlist(t_ustr)[3], "-")
  t_month <- as.integer(unlist(t_dstr)[2])
  t_day <- as.integer(unlist(t_dstr)[3])
  t_year <- as.integer(unlist(t_dstr)[1])
  chron(floor(time/86400),origin=c(t_day, t_month, t_year),format = "d/m/y")
  
  #Pour avoir l'annee, le mois ou le jour :
  mydate<-chron(floor(time/86400),origin=c(t_day, t_month, t_year),format = "d/m/y")
  
  mydate<-as.Date(mydate,'%Y/%m/%d')
  myyear<-year(mydate)
  mymonth<-month(mydate)
  myday<-day(mydate)
  
  #extract micronecton
  var_mu <- "mnkc_mumeso" 
  T_array <- ncvar_get(nc, var_mu)
  invisible(gc())
  
  #variable's attributes
  long_name <- ncatt_get(nc, var_mu, "long_name")   #long name
  T_units <- ncatt_get(nc, var_mu, "units")         #measure unit
  fillvalue <- ncatt_get(nc, var_mu, "_FillValue")  #(optional)  
  
  ## put NA values for missing values in the NetCDF file
  T_array[T_array == fillvalue$value] <- NA
  invisible(gc())
  
  #estimate mean for each year, month and 2° cell
  
  grid <- expand.grid(lon=lon, lat=lat)  #create a set of lonlat pairs of values, one for each element in the tem_array
  iyear<-unique(myyear)
  for (imonth in c(1:12)){
    datesel<-(mymonth ==imonth)
    T_slice<-T_array[,,datesel]
    ndays<-sum(datesel)
    grid_1day <- expand.grid(lon=lon, lat=lat)  #create a set of lonlat pairs of values, one for each element in the tem_array
    grid <- as.data.frame(cbind(lon = rep(grid_1day$lon, ndays),
                                lat = rep(grid_1day$lat, ndays)))
    
    grid$micronec_mu<-as.vector(T_slice)
    df<-subset(grid,!is.na(micronec_mu))
    df$lat_grid<-resolution*floor(df$lat/resolution) 
    df$lon_grid<-resolution*floor(df$lon/resolution) 
    df_mean<-ddply(df,.(lat_grid,lon_grid),summarize,micronec_mu=mean(micronec_mu),micronec_musd=sd(micronec_mu))#moyenne
    df_mean$year<-iyear
    df_mean$month<-imonth
    df_meantot<-rbind(df_meantot,df_mean)
    
    rm(grid, df, df_mean, T_slice)
    invisible(gc())
  }
  rm(T_array)
  invisible(gc())
}

write.csv(df_meantot,file="MN_mu_mean.csv",row.names = F,col.names = T)

##########################################################################################
#### migrant lower mesopelagic ####
##########################################################################################

rm(list=ls())

resolution <- 2

#--Libraries
library(ncdf4) # package for netcdf manipulation
library(chron) 
library(lattice) 
library(readr) 
library(ggplot2)
library(plyr)
library(lubridate)

#set path and filename
PATH_DATA<-"D:/Stage_Jeanne/Data/Netcdf/Micronecton/ml/"
file_list<-list.files(PATH_DATA)

df_meantot<-data.frame(matrix(nrow=0,ncol=6))
colnames(df_meantot)=c("lat_grid", "lon_grid","year", "month",
                       "micronec_mlmean", "micronec_mlsd")

for (ifile in file_list){
  nc_file <- ifile
  nc_name <- paste(PATH_DATA, nc_file, sep = "")
  nc_name
  
  #open the NetCDF file
  nc <- nc_open(nc_name)
  print(nc)
  
  lon <- ncvar_get(nc, "longitude")
  lat <- ncvar_get(nc, "latitude")
  time <- ncvar_get(nc, "time")
  
  nlon <- dim(lon)
  nlat <- dim(lat)
  ntime<- dim(time)
  t_units <- ncatt_get(nc, "time", "units")
  
  # convert time -- split the time units string into fields
  t_ustr <- strsplit(t_units$value, " ")
  t_dstr <- strsplit(unlist(t_ustr)[3], "-")
  t_month <- as.integer(unlist(t_dstr)[2])
  t_day <- as.integer(unlist(t_dstr)[3])
  t_year <- as.integer(unlist(t_dstr)[1])
  chron(floor(time/86400),origin=c(t_day, t_month, t_year),format = "d/m/y")
  
  #Pour avoir l'annee, le mois ou le jour :
  mydate<-chron(floor(time/86400),origin=c(t_day, t_month, t_year),format = "d/m/y")
  
  mydate<-as.Date(mydate,'%Y/%m/%d')
  myyear<-year(mydate)
  mymonth<-month(mydate)
  myday<-day(mydate)
  
  #extract micronecton
  var_ml <- "mnkc_mlmeso" 
  T_array <- ncvar_get(nc, var_ml)
  invisible(gc())
  
  #variable's attributes
  long_name <- ncatt_get(nc, var_ml, "long_name")   #long name
  T_units <- ncatt_get(nc, var_ml, "units")         #measure unit
  fillvalue <- ncatt_get(nc, var_ml, "_FillValue")  #(optional)  
  
  ## put NA values for missing values in the NetCDF file
  T_array[T_array == fillvalue$value] <- NA
  invisible(gc())
  
  #estimate mean for each year, month and 2° cell
  
  grid <- expand.grid(lon=lon, lat=lat)  #create a set of lonlat pairs of values, one for each element in the tem_array
  iyear<-unique(myyear)
  for (imonth in c(1:12)){
    datesel<-(mymonth ==imonth)
    T_slice<-T_array[,,datesel]
    ndays<-sum(datesel)
    grid_1day <- expand.grid(lon=lon, lat=lat)  #create a set of lonlat pairs of values, one for each element in the tem_array
    grid <- as.data.frame(cbind(lon = rep(grid_1day$lon, ndays),
                                lat = rep(grid_1day$lat, ndays)))
    
    grid$micronec_ml<-as.vector(T_slice)
    df<-subset(grid,!is.na(micronec_ml))
    df$lat_grid<-resolution*floor(df$lat/resolution) 
    df$lon_grid<-resolution*floor(df$lon/resolution) 
    df_mean<-ddply(df,.(lat_grid,lon_grid),summarize,micronec_ml=mean(micronec_ml),micronec_mlsd=sd(micronec_ml))#moyenne
    df_mean$year<-iyear
    df_mean$month<-imonth
    df_meantot<-rbind(df_meantot,df_mean)
    
    rm(grid, df, df_mean, T_slice)
    invisible(gc())
  }
  rm(T_array)
  invisible(gc())
}

write.csv(df_meantot,file="MN_ml_mean.csv",row.names = F,col.names = T)

##########################################################################################
#### highly migrant lower mesopelagic ####
##########################################################################################

rm(list=ls())

resolution <- 2

#--Libraries
library(ncdf4) # package for netcdf manipulation
library(chron) 
library(lattice) 
library(readr) 
library(ggplot2)
library(plyr)
library(lubridate)

#set path and filename
PATH_DATA<-"D:/Stage_Jeanne/Data/Netcdf/Micronecton/hml/"
file_list<-list.files(PATH_DATA)

df_meantot<-data.frame(matrix(nrow=0,ncol=6))
colnames(df_meantot)=c("lat_grid", "lon_grid","year", "month",
                       "micronec_hmlmean", "micronec_hmlsd")

for (ifile in file_list){
  nc_file <- ifile
  nc_name <- paste(PATH_DATA, nc_file, sep = "")
  nc_name
  
  #open the NetCDF file
  nc <- nc_open(nc_name)
  print(nc)
  
  lon <- ncvar_get(nc, "longitude")
  lat <- ncvar_get(nc, "latitude")
  time <- ncvar_get(nc, "time")
  
  nlon <- dim(lon)
  nlat <- dim(lat)
  ntime<- dim(time)
  t_units <- ncatt_get(nc, "time", "units")
  
  # convert time -- split the time units string into fields
  t_ustr <- strsplit(t_units$value, " ")
  t_dstr <- strsplit(unlist(t_ustr)[3], "-")
  t_month <- as.integer(unlist(t_dstr)[2])
  t_day <- as.integer(unlist(t_dstr)[3])
  t_year <- as.integer(unlist(t_dstr)[1])
  chron(floor(time/86400),origin=c(t_day, t_month, t_year),format = "d/m/y")
  
  #Pour avoir l'annee, le mois ou le jour :
  mydate<-chron(floor(time/86400),origin=c(t_day, t_month, t_year),format = "d/m/y")
  
  mydate<-as.Date(mydate,'%Y/%m/%d')
  myyear<-year(mydate)
  mymonth<-month(mydate)
  myday<-day(mydate)
  
  #extract micronecton
  var_hml <- "mnkc_hmlmeso" 
  T_array <- ncvar_get(nc, var_hml)
  invisible(gc())
  
  #variable's attributes
  long_name <- ncatt_get(nc, var_hml, "long_name")   #long name
  T_units <- ncatt_get(nc, var_hml, "units")         #measure unit
  fillvalue <- ncatt_get(nc, var_hml, "_FillValue")  #(optional)  
  
  ## put NA values for missing values in the NetCDF file
  T_array[T_array == fillvalue$value] <- NA
  invisible(gc())
  
  #estimate mean for each year, month and 2° cell
  
  grid <- expand.grid(lon=lon, lat=lat)  #create a set of lonlat pairs of values, one for each element in the tem_array
  iyear<-unique(myyear)
  for (imonth in c(1:12)){
    datesel<-(mymonth ==imonth)
    T_slice<-T_array[,,datesel]
    ndays<-sum(datesel)
    grid_1day <- expand.grid(lon=lon, lat=lat)  #create a set of lonlat pairs of values, one for each element in the tem_array
    grid <- as.data.frame(cbind(lon = rep(grid_1day$lon, ndays),
                                lat = rep(grid_1day$lat, ndays)))
    
    grid$micronec_hml<-as.vector(T_slice)
    df<-subset(grid,!is.na(micronec_hml))
    df$lat_grid<-resolution*floor(df$lat/resolution) 
    df$lon_grid<-resolution*floor(df$lon/resolution) 
    df_mean<-ddply(df,.(lat_grid,lon_grid),summarize,micronec_hml=mean(micronec_hml),micronec_hmlsd=sd(micronec_hml))#moyenne
    df_mean$year<-iyear
    df_mean$month<-imonth
    df_meantot<-rbind(df_meantot,df_mean)
    
    rm(grid, df, df_mean, T_slice)
    invisible(gc())
  }
  rm(T_array)
  invisible(gc())
}

write.csv(df_meantot,file="MN_hml_mean.csv",row.names = F,col.names = T)


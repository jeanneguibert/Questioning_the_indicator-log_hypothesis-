#--Libraries
library(ncdf4) # package for netcdf manipulation
library(chron) 
library(lattice) 
library(readr) 
library(ggplot2)
library(plyr)
library(lubridate)

for (i in 1:length(CHLA_FILE)){
  #set path and filename
  nc_name <- file.path(PATH_DATA, "Netcdf/Chla", CHLA_FILE[i])
  
  #open the NetCDF file
  nc <- nc_open(nc_name)
  #print(nc)
  
  lon <- ncvar_get(nc,
                   grep("lon", names(nc$dim),
                        value = T))
  lat <- ncvar_get(nc,
                   grep("lat", names(nc$dim),
                        value = T))
  time<-ncvar_get(nc, "time")
  
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
  date_origin <- as.Date(paste(t_year,t_month,t_day, sep="-"))
  time_unit <- unlist(t_ustr)[1]
  if (time_unit == "seconds"){time_unit <- "secs"}
  
  mydate <- date_origin + as.difftime(time, units = time_unit)
  myyear<-year(mydate)
  mymonth<-month(mydate)
  myday<-day(mydate)
  
  #extract chla
  varchla <- "CHL" 
  T_array <- ncvar_get(nc, varchla)
  
  #variable's attributes
  long_name <- ncatt_get(nc, varchla, "long_name")   #long name
  T_units <- ncatt_get(nc, varchla, "units")         #measure unit
  fillvalue <- ncatt_get(nc, varchla, "_FillValue")  #(optional)  
  
  ## put NA values for missing values in the NetCDF file
  T_array[T_array == fillvalue$value] <- NA
  
  #estimate mean for each year, month and 2° cell
  grid <- expand.grid(lon=lon, lat=lat)  #create a set of lonlat pairs of values, one for each element in the tem_array
  if (i == 1){
    df_meantot<-data.frame(matrix(nrow=0,ncol=6))
    colnames(df_meantot)=c("lat_grid", "lon_grid","chlamean", "chlasd", "year", "month")
  }
  for (date in mydate){
    iyear = lubridate::year(date)
    imonth = lubridate::month(date)
    datesel<-myyear==iyear & mymonth==imonth
    T_slice<-T_array[,,datesel]
    grid$chla<-as.vector(T_slice)
    df<-subset(grid,!is.na(chla))
    df$lat_grid<-resolution*floor(df$lat/resolution) 
    df$lon_grid<-resolution*floor(df$lon/resolution) 
    df_mean<-ddply(df,.(lat_grid,lon_grid),summarize,chlamean=mean(chla),chlasd=sd(chla))#moyenne
    df_mean$year<-iyear
    df_mean$month<-imonth
    df_meantot<-rbind(df_meantot,df_mean)
  }
}

write.csv(df_meantot,file=file.path(PATH_OUTPUT,"Chla_mean.csv"),row.names = F)

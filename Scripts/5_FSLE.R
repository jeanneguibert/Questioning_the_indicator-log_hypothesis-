rm(list=ls())

resolution <- 2

#--Libraries
library(ncdf4) # package for netcdf manipulation
library(chron) 
library(lattice) 
library(readr) 
library(ggplot2)

#set path and filename
PATH_DATA<-"D:/Stage_Jeanne/Data/Netcdf/FSLE/"
file_list<-list.files(PATH_DATA)

df_meantot<-data.frame(matrix(nrow=0,ncol=6))
colnames(df_meantot)=c("lat_grid", "lon_grid","FSLEmean", "FSLEsd", "year", "month")

for (ifile in file_list){
  nc_file <- ifile
  nc_name <- paste(PATH_DATA, nc_file, sep = "")
  nc_name

  #open the NetCDF file
  nc <- nc_open(nc_name)
  print(nc)

  lon <- ncvar_get(nc, "lon")
  lat <- ncvar_get(nc, "lat")
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
  chron(time,origin=c(t_month, t_day, t_year))

#Pour avoir l'annee, le mois ou le jour :
mydate<-chron(time,origin=c(t_month, t_day, t_year))
library("lubridate")
mydate<-as.Date(mydate,'%m/%d/%Y')
myyear<-year(mydate)
mymonth<-month(mydate)
myday<-day(mydate)

#extract lya
varlya <- "fsle_max" 
T_array <- ncvar_get(nc, varlya)
invisible(gc())

#variable's attributes
long_name <- ncatt_get(nc, varlya, "long_name")   #long name
T_units <- ncatt_get(nc, varlya, "units")         #measure unit
fillvalue <- ncatt_get(nc, varlya, "_FillValue")  #(optional)  

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
    
    grid$FSLE<-as.vector(T_slice)
    df<-subset(grid,!is.na(FSLE))
    df$lat_grid<-resolution*floor(df$lat/resolution) 
    df$lon_grid<-resolution*floor(df$lon/resolution) 
    df_mean<-ddply(df,.(lat_grid,lon_grid),summarize,FSLEmean=mean(FSLE),FSLEsd=sd(FSLE))#moyenne
    df_mean$year<-iyear
    df_mean$month<-imonth
    df_meantot<-rbind(df_meantot,df_mean)
    
    rm(grid, df, df_mean, T_slice)
    invisible(gc())
  }
   rm(T_array)
   invisible(gc())
}

write.csv(df_meantot,file="FSLE_mean.csv",row.names = F,col.names = T)

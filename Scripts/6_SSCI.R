rm(list=ls())

### parameters
resolution<-2

#--Libraries
library(ncdf4) # package for netcdf manipulation
library(chron) 
library(lattice) 
library(readr) 
library(ggplot2)
library(plyr)
library(lubridate)

#set path and filename
PATH_DATA<-"D:/Stage_Jeanne/Data/Netcdf/SSCI/"
setwd("D:/Stage_Jeanne/Data/Netcdf/SSCI")
nc_file <- "dataset-armor-3d-rep-monthly_1649425349783.nc"
nc_name <- paste(PATH_DATA, nc_file, sep = "")

#open the NetCDF file
nc <- nc_open(nc_name)
print(nc)

lon <- ncvar_get(nc, "longitude")
lat <- ncvar_get(nc, "latitude")
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
chron(round(time/24),origin=c(t_month, t_day, t_year),format = "m/d/y")
mydate<-chron(round(time/24),origin=c(t_month, t_day, t_year),format = "m/d/y")

mydate<-as.Date(mydate,'%m/%d/%Y')
myyear<-year(mydate)
mymonth<-month(mydate)
myday<-day(mydate)

#extract SSCI
varSSCIu <- "ugo" 
varSSCIv <- "vgo"
T_arrayu <- ncvar_get(nc, varSSCIu)
T_arrayv <- ncvar_get(nc, varSSCIv)

#variable's attributes
long_name_u <- ncatt_get(nc, varSSCIu, "long_name")   #long name
T_units_u <- ncatt_get(nc, varSSCIu, "units")         #measure unit
fillvalue_u <- ncatt_get(nc, varSSCIu, "_FillValue")  #(optional)  
long_name_v <- ncatt_get(nc, varSSCIv, "long_name")   #long name
T_units_v <- ncatt_get(nc, varSSCIv, "units")         #measure unit
fillvalue_v <- ncatt_get(nc, varSSCIv, "_FillValue")  #(optional)  

## put NA values for missing values in the NetCDF file
T_arrayu[T_arrayu == fillvalue_u$value] <- NA
T_arrayv[T_arrayv == fillvalue_v$value] <- NA

r <- sqrt(T_arrayv^2 + T_arrayu^2)

#estimate mean for each year, month and 2° cell
grid <- expand.grid(lon=lon, lat=lat)  #create a set of lonlat pairs of values, one for each element in the tem_array
df_meantot<-data.frame(matrix(nrow=0,ncol=6))
colnames(df_meantot)=c("lat_grid", "lon_grid","SSCImean", "SSCIsd", "year", "month")
for(iyear in c(2014:2019)){
  for (imonth in c(1:12)){
    datesel<-myyear==iyear & mymonth==imonth
    T_slice<-r[,,datesel]
    grid$SSCI<-as.vector(T_slice)
    df<-subset(grid,!is.na(SSCI))
    df$lat_grid<-resolution*floor(df$lat/resolution) 
    df$lon_grid<-resolution*floor(df$lon/resolution) 
    df_mean<-ddply(df,.(lat_grid,lon_grid),summarize,SSCImean=mean(SSCI),SSCIsd=sd(SSCI))#moyenne
    df_mean$year<-iyear
    df_mean$month<-imonth
    df_meantot<-rbind(df_meantot,df_mean)
  }
}

write.csv(df_meantot,file="SSCI_mean.csv",row.names = F,col.names = T)
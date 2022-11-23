#--Libraries
library(ncdf4) # package for netcdf manipulation
library(chron) 
library(lattice) 
library(readr) 
library(ggplot2)
library(plyr)

#set path and filename
nc_name <- file.path(PATH_DATA, "Netcdf/SST", SST_FILE)

#open the NetCDF file
nc <- nc_open(nc_name)
print(nc)

lon <- ncvar_get(nc, "longitude")
lat <- ncvar_get(nc, "latitude")
time <- ncvar_get(nc, "time")
depth <- ncvar_get(nc, "depth")

nlon <- dim(lon)
nlat <- dim(lat)
ntime<- dim(time)
ndepth <- dim(depth)
t_units <- ncatt_get(nc, "time", "units")

# convert time -- split the time units string into fields
t_ustr <- strsplit(t_units$value, " ")
t_dstr <- strsplit(unlist(t_ustr)[3], "-")
t_month <- as.integer(unlist(t_dstr)[2])
t_day <- as.integer(unlist(t_dstr)[3])
t_year <- as.integer(unlist(t_dstr)[1])

chron(round(time/24),origin=c(t_month, t_day, t_year),format = "m/d/y")
mydate<-chron(round(time/24),origin=c(t_month, t_day, t_year))

library("lubridate")
mydate<-as.Date(mydate,'%m/%d/%Y')
myyear<-year(mydate)
mymonth<-month(mydate)
myday<-day(mydate)

#extract SST
varsst <- "to" 
T_array <- ncvar_get(nc, varsst)

#variable's attributes
long_name <- ncatt_get(nc, varsst, "long_name")   #long name
T_units <- ncatt_get(nc, varsst, "units")         #measure unit
fillvalue <- ncatt_get(nc, varsst, "_FillValue")  #(optional)  

## put NA values for missing values in the NetCDF file
T_array[T_array == fillvalue$value] <- NA

#estimate mean for each year, month and 2° cell

grid <- expand.grid(lon=lon, lat=lat)  #create a set of lonlat pairs of values, one for each element in the tem_array
df_meantot<-data.frame(matrix(nrow=0,ncol=6))
colnames(df_meantot)=c("lat_grid", "lon_grid","sstmean", "sstsd", "year", "month")
for(iyear in c(2014:2019)){
  for (imonth in c(1:12)){
   datesel<-(year(mydate)==iyear & month(mydate) ==imonth)
   T_slice<-T_array[,,datesel]
   grid$sst<-as.vector(T_slice)
   df<-subset(grid,!is.na(sst))
   df$lat_grid<-resolution*floor(df$lat/resolution) 
   df$lon_grid<-resolution*floor(df$lon/resolution) 
   df_mean<-ddply(df,.(lat_grid,lon_grid),summarize,sstmean=mean(sst),sstsd=sd(sst))#moyenne
   df_mean$year<-iyear
   df_mean$month<-imonth
   df_meantot<-rbind(df_meantot,df_mean)
  }
}

write.csv(df_meantot,file=file.path(PATH_OUTPUT, "SST_mean.csv"),row.names = F)

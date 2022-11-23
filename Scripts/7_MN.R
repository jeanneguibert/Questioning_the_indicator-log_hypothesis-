##########################################################################################
#### Micronecton ####
##########################################################################################

#--Libraries
library(ncdf4) # package for netcdf manipulation
library(chron) 
library(lattice) 
library(readr) 
library(ggplot2)
library(plyr)
library(lubridate)

#set path and filename
subdir_list<-list.dirs(file.path(PATH_DATA, "Netcdf/Micronecton"),
                       recursive = F, full.names = F)

for (idir in subdir_list){
  file_list <- list.files(file.path(PATH_DATA, "Netcdf/Micronecton", idir),
                          full.names = T)
  
  df_meantot<-data.frame(matrix(nrow=0,ncol=6))
  colnames(df_meantot)=c("lat_grid", "lon_grid","year", "month",
                         paste0("micronec_",idir,"mean"),
                         paste0("micronec_",idir,"sd"))
  
  for (ifile in file_list){
    #open the NetCDF file
    nc <- nc_open(ifile)
    # print(nc)
    
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
    var <- paste0("mnkc_",idir) 
    T_array <- ncvar_get(nc, var)
    invisible(gc())
    
    #variable's attributes
    long_name <- ncatt_get(nc, var, "long_name")   #long name
    T_units <- ncatt_get(nc, var, "units")         #measure unit
    fillvalue <- ncatt_get(nc, var, "_FillValue")  #(optional)  
    
    ## put NA values for missing values in the NetCDF file
    T_array[T_array == fillvalue$value] <- NA
    invisible(gc())
    
    #estimate mean for each year, month and 2? cell
    
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
  
  write.csv(df_meantot,file=file.path(PATH_OUTPUT, paste0("MN_",idir,"_mean.csv")),row.names = F)
  
}
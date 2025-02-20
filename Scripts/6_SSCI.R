#--Libraries
library(ncdf4) # package for netcdf manipulation
library(chron) 
library(lattice) 
library(readr) 
library(ggplot2)
library(plyr)
library(lubridate)

df_meantot<-data.frame(matrix(nrow=0,ncol=6))
colnames(df_meantot)=c("lat_grid", "lon_grid","SSCImean", "SSCIsd", "year", "month")

for (i in 1:length(SSCI_FILE)){
  #set path and filename
  nc_name <- file.path(PATH_DATA, 'Netcdf/SSCI', SSCI_FILE[i])
  
  #open the NetCDF file
  nc <- nc_open(nc_name)
  # print(nc)
  
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
  date_origin <- as.Date(paste(t_year,t_month,t_day, sep="-"))
  time_unit <- unlist(t_ustr)[1]
  if (time_unit == "seconds"){time_unit <- "secs"}
  
  mydate <- date_origin + as.difftime(time, units = time_unit)
  
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
  
  T_array <- sqrt(T_arrayv^2 + T_arrayu^2)
  dimnames(T_array)[[1]] <- lon
  dimnames(T_array)[[2]] <- lat
  dimnames(T_array)[[3]] <- as.character(mydate)
  
  # Average over time and spatial resolution
  averaged_results <- average_blocks_fast(array = T_array,
                                          lon_res = resolution, lat_res = resolution,
                                          timeresolution = timeresolution)
  
  averaged_means <- averaged_results$means
  averaged_sds <- averaged_results$sds
  unique_time_groups <- averaged_results$time_groups
  
  # Convert the results to a data frame
  df_mean <- as.data.frame(
    expand.grid(
      lon_grid = averaged_results$lon_grid,
      lat_grid = averaged_results$lat_grid,
      time = unique_time_groups
    )
  )
  df_mean$SSCImean <- as.vector(averaged_means)
  df_mean$SSCIsd <- as.vector(averaged_sds)
  
  if (i == 1){
    df_meantot<-data.frame(matrix(nrow=0,ncol=5))
    colnames(df_meantot)=c("lon_grid", "lat_grid", "time", "SSCImean", "SSCIsd")
  }
  
  df_meantot<-rbind(df_meantot,df_mean)
  
}

write.csv(df_meantot,file=file.path(PATH_OUTPUT,"SSCI_mean.csv"),row.names = F)

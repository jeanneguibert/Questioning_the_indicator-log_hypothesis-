#--Libraries
library(ncdf4) # package for netcdf manipulation
library(chron) 
library(lattice) 
library(readr) 
library(ggplot2)
library(plyr)
library(lubridate)

set.seed(12345678) #####

NLOG_SIM_FILE <- list.files(NLOG_SIM_DIR, full.names = T)

for (i in 1:length(NLOG_SIM_FILE)){
  #set path and filename
  nc_name <- NLOG_SIM_FILE[i]
  
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
  # myyear<-year(mydate)
  # mymonth<-month(mydate)
  # myweek <- lubridate::week(mydate)
  # myday<-day(mydate)
  
  #extract chla
  varnlog <- "NLOG" 
  T_array <- ncvar_get(nc, varnlog)
  
  #variable's attributes
  long_name <- ncatt_get(nc, varnlog, "long_name")   #long name
  T_units <- ncatt_get(nc, varnlog, "units")         #measure unit
  fillvalue <- ncatt_get(nc, varnlog, "_FillValue")  #(optional)  
  
  ## put NA values for missing values in the NetCDF file
  T_array[T_array == fillvalue$value] <- NA
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
  df_mean$nlogmean <- as.vector(averaged_means)
  df_mean$nlogsd <- as.vector(averaged_sds)
  
  if (i == 1){
    df_meantot<-data.frame(matrix(nrow=0,ncol=5))
    colnames(df_meantot)=c("lon_grid", "lat_grid", "time", "nlogmean", "nlogsd")
  }
  
  df_meantot<-rbind(df_meantot,df_mean)
  
}

###Save file ###############################################################
write.csv(df_meantot, file=file.path(PATH_OUTPUT, "NLOG_density.csv"), row.names = F)


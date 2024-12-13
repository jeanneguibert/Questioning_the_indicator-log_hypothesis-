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
  
  df_meantot<-data.frame(matrix(nrow=0,ncol=5))
  colnames(df_meantot)=c("lat_grid", "lon_grid","time",
                         'micronec_mean', 'micronec_sd')
  
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
    df_mean$micronec_mean <- as.vector(averaged_means)
    df_mean$micronec_sd <- as.vector(averaged_sds)
    
    df_meantot<-rbind(df_meantot,df_mean)
    
  }
  
  names(df_meantot) <- c("lat_grid", "lon_grid","time",
                         paste0('micronec_',idir,'_mean'),
                         paste0('micronec_',idir,'_sd'))
  
  write.csv(df_meantot,file=file.path(PATH_OUTPUT, paste0("MN_",idir,"_mean.csv")),row.names = F)
  
}


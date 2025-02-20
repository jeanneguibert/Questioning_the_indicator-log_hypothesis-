#'#
#' Function to average an array over space and time
#'
#'# Arguments:
#' @array: 3D array, the array to average, with the following dimensions: lon,lat,time
#' @lon_res: num, the resolution (in degrees) at which to average the longitude
#' @lat_res: num, the resolution (in degrees) at which to average the latitude
#' @timeresolution: chr, the resolution at which to average over time, either 'week' or 'month'

# Optimized function to average over blocks (with week/month support)
average_blocks_fast <- function(array, lon_res, lat_res, timeresolution) {
  # Calculate new latitude and longitude values
  lon_group <- floor(as.numeric(dimnames(array)[[1]]) / lon_res)*lon_res
  lat_group <- floor(as.numeric(dimnames(array)[[2]]) / lat_res)*lat_res
  unique_lon_group <- unique(lon_group)
  unique_lat_group <- unique(lat_group)
  # Calculate new spatial dimensions
  new_lon <- length(unique_lon_group)
  new_lat <- length(unique_lat_group)
  
  # Extract time dimension as Date
  time_dim <- as.Date(dimnames(array)[[3]])
  
  # Determine temporal grouping
  if (timeresolution == "week") {
    time_groups <- paste(year(time_dim), week(time_dim), sep = '-')
  } else if (timeresolution == "month") {
    time_groups <- paste(year(time_dim), month(time_dim), sep = '-')
  } else {
    stop("Invalid timeresolution. Use 'week' or 'month'.")
  }
  
  # Group time indices by unique time groups
  unique_time_groups <- unique(time_groups)
  new_time <- length(unique_time_groups)
  
  # Create results arrays
  averaged_means <- array(NA, dim = c(new_lon, new_lat, new_time))
  averaged_sds <- array(NA, dim = c(new_lon, new_lat, new_time))
  
  # Loop over unique time groups to compute average and standard deviation
  for (time.i in seq_along(unique_time_groups)){
    time_mask <- which(time_groups == unique_time_groups[time.i])
    temporal_subset <- array[,,time_mask, drop = F]
    for (lon.i in seq_along(unique_lon_group)){
      for (lat.i in seq_along(unique_lat_group)){
        block <- temporal_subset[lon_group == unique_lon_group[lon.i],
                                 lat_group == unique_lat_group[lat.i],, drop = F]
        averaged_means[lon.i, lat.i, time.i] <- mean(block, na.rm = T)
        averaged_sds[lon.i, lat.i, time.i] <- sd(block, na.rm = T)
      }
    }
  }
  
  # Return results as a list
  return(list(means = averaged_means, sds = averaged_sds,
              time_groups = unique_time_groups,
              lon_grid = unique_lon_group,
              lat_grid = unique_lat_group))
}


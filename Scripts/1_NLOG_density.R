set.seed(12345678) #####

##Process NLOG data###################################
source(file.path(PATH_FUNC, "Prep_obs.R"))
# source(file.path(PATH_FUNC, "Maps/Maps_VJ.R"))
# source(file.path(PATH_FUNC,"Maps/1.1.subfunctions_maps_obs.R"))
operation <- read.csv(file.path(PATH_DATA,OBS_FILE), header = TRUE, sep = ",",
                      dec = ".", fill = TRUE, stringsAsFactors = T)
Ob7 <- prep.obs(operation)


data_fob<-data.frame(as.Date(Ob7$observation_date),Ob7$latitude,Ob7$longitude,Ob7$obj_conv)
names(data_fob)<-c("observation_date","latitude","longitude","fob_type")
data_fob$month <- lubridate::month(data_fob$observation_date)
data_fob$year <- lubridate::year(data_fob$observation_date)
data_fob$lat_grid<-floor(data_fob$latitude/resolution)*resolution
data_fob$lon_grid<-floor(data_fob$longitude/resolution)*resolution

#focus only on NLOGs
data_NLOG<-subset(data_fob,fob_type=="NLOG")

##Process ACTIVITY DATA ####################################
ttob7 <- read.csv(file = file.path(PATH_DATA, VESSEL_ACTIVITY_FILE))
data_obs <- data.frame(ttob7$vessel_name,ttob7$observation_date,ttob7$latitude,ttob7$longitude,ttob7$vessel_activity)
names(data_obs) <- c("vessel","observation_date","latitude","longitude","activity")
data_obs$day <- lubridate::day(data_obs$observation_date)
data_obs$month <- lubridate::month(data_obs$observation_date)
data_obs$year <- lubridate::year(data_obs$observation_date)
data_obs$lat_grid<-floor(data_obs$latitude/resolution)*resolution
data_obs$lon_grid<-floor(data_obs$longitude/resolution)*resolution
#account for one observation day per vessel per grid cell
data_obs$id<-paste0(data_obs$vessel,"_",data_obs$day,"_",data_obs$month,"_",data_obs$year,"_",data_obs$lat_grid,"_",data_obs$lon_grid) ## Check other method with 1st position per vessel per day
data_obs <- data_obs[sample.int(nrow(data_obs)),] #####
data_obs_unique<-data_obs[!duplicated(data_obs$id),]

###### Count the number of NLOG and days of observation for each grid cell #############################################

NLOG<-ddply(data_NLOG, c("month","year","lat_grid","lon_grid"),.fun=nrow)
colnames(NLOG)<-c("month" ,   "year"  ,   "lat_grid" ,"lon_grid","NumNLOG")

NOBS<-ddply(data_obs_unique,.(month,year,lat_grid,lon_grid),.fun=nrow)
colnames(NOBS)<-c("month" ,   "year"  ,   "lat_grid" ,"lon_grid","NumOBS")

###### Merge the two dataframes ##########################################
df<-merge(NLOG,NOBS,by=c("month" ,   "year"  ,   "lat_grid" ,"lon_grid"),all.y=T)
df$NumNLOG<-ifelse(is.na(df$NumNLOG),0,df$NumNLOG)

## filter to keep only data in the study area
df <- df[df$lat_grid >= -20,]

#### Set time limits ##########################################################
df_NLOGdensity <- df[df$year>=min(YEARS) & df$year<=max(YEARS),]

#### Create colum with nb NLOG / nb Obs ##########################################################
df_NLOGdensity$NLOG_stand <- df_NLOGdensity$NumNLOG / df_NLOGdensity$NumOBS
summary(df_NLOGdensity)

###Save file without effort threshold ###############################################################
write.csv(df_NLOGdensity, file=file.path(PATH_OUTPUT, "NLOG_density_tot_effort.csv"), row.names = F)

######Take a threshold (ndayobs_min) for the minimum number of days of observation to consider the cell ####################
ndayobs_min<-NDAYS_OBS_MIN
df_NLOGdensity<-subset(df_NLOGdensity,NumOBS>=ndayobs_min)

###Save file ###############################################################
write.csv(df_NLOGdensity, file=file.path(PATH_OUTPUT, "NLOG_density.csv"), row.names = F)


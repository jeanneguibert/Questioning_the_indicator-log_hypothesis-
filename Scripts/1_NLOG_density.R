rm(list=ls())
library("lubridate")
library("plyr")
library("dplyr")

##################### Set the path of observers data ###################
WD <- "D:/Stage_Jeanne/Data/Basic_data"
PATH_DATA <- file.path(WD, "Data")
PATH_FUNC <- file.path(WD, "Functions")
setwd(WD)


set.seed(12345678) #####

##Process NLOG data###################################
source(file.path(PATH_FUNC, "Prep_obs.R"))
source(file.path(PATH_FUNC, "Maps/Maps_VJ.R"))
source(file.path(PATH_FUNC,"Maps/1.1.subfunctions_maps_obs.R"))
operation <- read.csv(paste0(PATH_DATA,"/all_operations_on_fobs_observe_fr_indian.csv"), header = TRUE, sep = ",",
                      dec = ".", fill = TRUE, stringsAsFactors = T)
Ob7 <- prep.obs(operation)


data_fob<-data.frame(Ob7$observation_date,Ob7$latitude,Ob7$longitude,Ob7$obj_conv)
names(data_fob)<-c("observation_date","latitude","longitude","fob_type")
data_fob$month <- lubridate::month(data_fob$observation_date)
data_fob$year <- lubridate::year(data_fob$observation_date)
data_fob$lat_grid<-floor(data_fob$latitude/2)*2
data_fob$lon_grid<-floor(data_fob$longitude/2)*2

#focus only on NLOGs
data_NLOG<-subset(data_fob,fob_type=="NLOG")

##Process ACTIVITY DATA ####################################
ttob7 <- read.csv(file = file.path(PATH_DATA, "all_vessel_activities_observe_fr_indian.csv"))
data_obs <- data.frame(ttob7$vessel_name,ttob7$observation_date,ttob7$latitude,ttob7$longitude,ttob7$vessel_activity)
names(data_obs) <- c("vessel","observation_date","latitude","longitude","activity")
data_obs$day <- lubridate::day(data_obs$observation_date)
data_obs$month <- lubridate::month(data_obs$observation_date)
data_obs$year <- lubridate::year(data_obs$observation_date)
data_obs$lat_grid<-floor(data_obs$latitude/2)*2
data_obs$lon_grid<-floor(data_obs$longitude/2)*2
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

######Take a threshold (ndayobs_min) for the minimum number of days of observation to consider the cell ####################
ndayobs_min<-6
df_NLOGdensity<-subset(df,NumOBS>=ndayobs_min)

#### Set time limits ##########################################################
df_NLOGdensity <- df_NLOGdensity[df_NLOGdensity$year>2013 & df_NLOGdensity$year<2020,]

#### Create colum with nb NLOG / nb Obs ##########################################################
df_NLOGdensity$NLOG_stand <- df_NLOGdensity$NumNLOG / df_NLOGdensity$NumOBS
summary(df_NLOGdensity)

###Save file ###############################################################
write.csv(df_NLOGdensity, file="NLOG_density.csv", row.names = F)

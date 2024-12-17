rm(list=ls()[!ls() %in% toKeep])

library("plyr")


##################### Open files ###################
dfNLOG<-read.csv(file.path(PATH_OUTPUT, "NLOG_density.csv"), header = T)
dfChla<-read.csv(file.path(PATH_OUTPUT, "Chla_mean.csv"), header = T)
dfSST<-read.csv(file.path(PATH_OUTPUT, "SST_mean.csv"), header = T)
dfSLA<-read.csv(file.path(PATH_OUTPUT, "SLA_mean.csv"), header = T)
dfFSLE<-read.csv(file.path(PATH_OUTPUT, "FSLE_mean.csv"), header = T)
dfSSCI<-read.csv(file.path(PATH_OUTPUT, "SSCI_mean.csv"), header = T)
dfMN<-read.csv(file.path(PATH_OUTPUT, "MN_epi_mean.csv"), header = T)

colnames(dfMN)[which(colnames(dfMN) == "micronec_epi_mean")] <- "MNmean"
colnames(dfMN)[which(colnames(dfMN) == "micronec_epi_sd")] <- "MNsd"

###############Merge 
df_list<-list(dfNLOG,dfChla,dfSST,dfSLA,dfFSLE,dfSSCI,dfMN)
if (NLOG_DATA_SOURCE == 'sim'){
  merging_cols <- c("lat_grid", "lon_grid","time")
} else if (NLOG_DATA_SOURCE == 'obs'){
  merging_cols <- c("lat_grid", "lon_grid","year", "month")
}
dftot<-Reduce(function(x, y) merge(x, y, by=merging_cols), df_list)  
summary(dftot)

#filter to keep only years of interest
#' and only area of interest (area_limits = c(xmin = 39, xmax = 90,
#'                                            ymin = -20, ymax = 20))
dftot %>%
  dplyr::mutate(year = as.numeric(gsub('-.*', '', time))) %>%
  dplyr::filter(year %in% YEARS,
                lon_grid >= AREA_LIMITS['xmin'] & lon_grid <= AREA_LIMITS['xmax'],
                lat_grid >= AREA_LIMITS['ymin'] & lat_grid <= AREA_LIMITS['ymax']) %>%
  tidyr::drop_na() -> dftot

#ajout Zone
dftot$Zone <- as.factor(ifelse(dftot$lat_grid<(-10) & dftot$lon_grid<=(50),"MOZ","WIO"))
dftot$Zone <- as.factor(ifelse(dftot$lon_grid<=50 & dftot$lon_grid>47 & dftot$lat_grid<(-15),
                               'WIO', as.character(dftot$Zone)))

#ajout Season
if (timeresolution == 'month'){
  dftot$month <-as.numeric(gsub(".*-", "", dftot$time))
} else if (timeresolution == 'week'){
  dftot$weekday <- as.Date(paste(gsub("-.*", "", dftot$time),
                                 '01-01',
                                 sep = '-')) +
    as.difftime((as.numeric(gsub(".*-", "", dftot$time))-1)*7,
                units = 'days')
  dftot$month <- as.numeric(lubridate::month(dftot$weekday))
  dftot %>% dplyr::select(-weekday) -> dftot
}

dftot$Season <-  NA
dftot$Season <- ifelse(dftot$month%in%c(12,1,2,3),"DJFM",dftot$Season)
dftot$Season <- ifelse(dftot$month%in%c(4,5),"AM",dftot$Season)
dftot$Season <- ifelse(dftot$month%in%c(6,7,8,9),"JJAS",dftot$Season)
dftot$Season <- ifelse(dftot$month%in%c(10,11),"ON",dftot$Season)

dftot$Season <-  as.factor(dftot$Season)
#summary(dftot)

write.csv(dftot, file.path(PATH_OUTPUT,"NLOG_VE.csv"), row.names = F)

#### Pr?sence NLOG ####

NLOG_VE<-read.csv(file.path(PATH_OUTPUT,"NLOG_VE.csv"), header = T)

if(NLOG_DATA_SOURCE == 'obs'){
  
  NLOG_VE_sup_zero <- NLOG_VE[NLOG_VE$NumNLOG>0,]
  #Moz <10S
  NLOG_VE_sup_zero_Moz <- NLOG_VE_sup_zero[NLOG_VE_sup_zero$Zone=="MOZ",]
  #North >10?S
  NLOG_VE_sup_zero_WIO <- NLOG_VE_sup_zero[NLOG_VE_sup_zero$Zone=="WIO",]
  
  write.csv(NLOG_VE_sup_zero, file.path(PATH_OUTPUT,"NLOG_VE_sup_zero.csv"), row.names = F)
  write.csv(NLOG_VE_sup_zero_Moz, file.path(PATH_OUTPUT,"NLOG_VE_sup_zero_Moz.csv"), row.names = F)
  write.csv(NLOG_VE_sup_zero_WIO, file.path(PATH_OUTPUT,"NLOG_VE_sup_zero_North.csv"), row.names = F)
  
  #### Absence NLOG
  
  NLOG_VE_zero <- NLOG_VE[NLOG_VE$NumNLOG==0,]
  #Moz <10S
  NLOG_VE_zero_Moz <- NLOG_VE_zero[NLOG_VE_zero$Zone=="MOZ",]
  #North >10?S
  NLOG_VE_zero_North <- NLOG_VE_zero[NLOG_VE_zero$Zone=="WIO",]
  
  write.csv(NLOG_VE_zero, file.path(PATH_OUTPUT,"NLOG_VE_zero.csv"), row.names = F)
  write.csv(NLOG_VE_zero_Moz, file.path(PATH_OUTPUT,"NLOG_VE_zero_Moz.csv"), row.names = F)
  write.csv(NLOG_VE_zero_North, file.path(PATH_OUTPUT,"NLOG_VE_zero_North.csv"), row.names = F)
}



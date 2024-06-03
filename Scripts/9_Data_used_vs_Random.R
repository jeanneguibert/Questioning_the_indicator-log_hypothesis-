rm(list=ls()[!ls() %in% toKeep])

library(ggplot2)
set.seed(12345)

##################### Open files ###################
dfChla<-read.csv(file.path(PATH_OUTPUT, "Chla_mean.csv"), header = T)
dfSST<-read.csv(file.path(PATH_OUTPUT, "SST_mean.csv"), header = T)
dfSLA<-read.csv(file.path(PATH_OUTPUT, "SLA_mean.csv"), header = T)
dfFSLE<-read.csv(file.path(PATH_OUTPUT, "FSLE_mean.csv"), header = T)
dfSSCI<-read.csv(file.path(PATH_OUTPUT, "SSCI_mean.csv"), header = T)
dfMN_epi<-read.csv(file.path(PATH_OUTPUT, "MN_epi_mean.csv"), header = T)

NLOG_VE_tot_effort <- read.csv(file.path(PATH_OUTPUT,"NLOG_density_tot_effort.csv"), header = T)
NLOG_VE_tot_effort$threshold <- as.factor(ifelse(NLOG_VE_tot_effort$NumOBS<NDAYS_OBS_MIN,"Random","Fisheries"))
# table(NLOG_VE_tot_effort$threshold)

#### Coordinates study area ####
NLOG_VE_tot_effort$id <- paste(NLOG_VE_tot_effort$lat_grid,"_",NLOG_VE_tot_effort$lon_grid)
NLOG_VE_coord <- NLOG_VE_tot_effort[!duplicated(NLOG_VE_tot_effort$id),]
NLOG_VE_coord <- NLOG_VE_coord[,c("month","year", "lat_grid", "lon_grid", "NumOBS", "threshold", "id")]
NLOG_VE_VF <- NLOG_VE_tot_effort[,c("month","year", "lat_grid", "lon_grid", "NumOBS", "threshold", "id")]

#VE
df_list <- list(dfChla,dfSST,dfSLA,dfFSLE,dfSSCI,dfMN_epi)
df <- Reduce(function(x, y) merge(x, y, by=c("lat_grid", "lon_grid", "year", "month")), df_list)  
summary(df)

#keep only lat lon of interest = study area
df$id <- paste(df$lat_grid,"_",df$lon_grid)
df <- subset(df,df$id %in% NLOG_VE_coord$id)

#effort
df_eff <- merge(df, NLOG_VE_VF, by = c("lat_grid","lon_grid","year","month","id"),all = T)
df_eff$NumOBS <- ifelse(is.na(df_eff$NumOBS),0,df_eff$NumOBS)
df_eff$threshold <- as.factor(ifelse(df_eff$NumOBS<NDAYS_OBS_MIN,"Random","Fisheries"))

#### Creation of zones ####
df_eff$Zone <- as.factor(ifelse(df_eff$lat_grid<(-10) & df_eff$lon_grid<=(50),"MOZ","WIO"))

#### Random sampling ####
for (sample_size in c(50,100,150)){
  
  df_eff_new <- data.frame(matrix(nrow=0,ncol = 20))
  colnames(df_eff_new) <- colnames(df_eff)
  for (iyear in YEARS){
    for (imonth in c(1:12)){
      df_random <- subset(df_eff,df_eff$threshold=="Random" & df_eff$month == imonth & 
                            df_eff$year == iyear)
      df_random <- df_random[sample(nrow(df_random), sample_size, replace = FALSE),]
      #replace = False pour tirage sans remise
      df_eff_new <- rbind(df_eff_new,df_random)
    }
  }
  
  write.csv(df_eff_new,file=file.path(PATH_OUTPUT,paste0("df_eff_new_",sample_size,".csv")),row.names = F)
}

write.csv(df_eff,file=file.path(PATH_OUTPUT,"df_eff.csv"),row.names = F)

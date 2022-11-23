rm(list=ls())

library(ggplot2)
set.seed(12345)

##################### Open files ###################
dfChla<-read.csv("Chla_mean.csv", header = T)
dfSST<-read.csv("SST_mean.csv", header = T)
dfSLA<-read.csv("SLA_mean.csv", header = T)
dfFSLE<-read.csv("FSLE_mean.csv", header = T)
dfSSCI<-read.csv("SSCI_mean.csv", header = T)
dfMN_epi<-read.csv("MN_epi_mean.csv", header = T)

NLOG_VE_tot_effort <- read.csv("NLOG_VE_tot_effort.csv", head = T)
NLOG_VE_tot_effort$threshold <- as.factor(ifelse(NLOG_VE_tot_effort$NumOBS<6,"Random","Fisheries"))
table(NLOG_VE_tot_effort$threshold)

#### Coordinates study area ####
NLOG_VE_tot_effort$id <- paste(NLOG_VE_tot_effort$lat_grid,"_",NLOG_VE_tot_effort$lon_grid)
NLOG_VE_coord <- NLOG_VE_tot_effort[!duplicated(NLOG_VE_tot_effort$id),]
NLOG_VE_coord <- NLOG_VE_coord[,c(1,2,3,4,6,20)]
NLOG_VE_VF <- NLOG_VE_tot_effort[,c(1,2,3,4,6)]

#VE
df_list <- list(dfChla,dfSST,dfSLA,dfFSLE,dfSSCI,dfMN_epi)
df <- Reduce(function(x, y) merge(x, y, by=c("lat_grid", "lon_grid", "year", "month")), df_list)  
summary(df)

#keep only lat lon of interest = study area
df$id <- paste(df$lat_grid,"_",df$lon_grid)
df <- subset(df,df$id%in%NLOG_VE_coord$id)

#effort
df_eff <- merge(df,NLOG_VE_VF, by = c("lat_grid","lon_grid","year","month"),all = T)
df_eff$NumOBS <- ifelse(is.na(df_eff$NumOBS),0,df_eff$NumOBS)
df_eff$threshold <- as.factor(ifelse(df_eff$NumOBS<6,"Random","Fisheries"))

#### Random sampling ####

df_eff_new <- data.frame(matrix(nrow=0,ncol = 19))
colnames(df_eff_new) <- colnames(df_eff)
for (iyear in c(2014:2019)){
  for (imonth in c(1:12)){
    df_random <- subset(df_eff,df_eff$threshold=="Random" & df_eff$month == imonth & 
                        df_eff$year == iyear)
    df_random <- df_random[sample(nrow(df_random), 100, replace = FALSE),]
    #replace = False pour tirage sans remise
    df_eff_new <- rbind(df_eff_new,df_random)
  }
}

#### Creation of zones ####
df_eff$Zone <- as.factor(ifelse(df_eff$lat_grid<(-10),"Moz","Above_10S"))
df_eff_new$Zone <- as.factor(ifelse(df_eff_new$lat_grid<(-10),"Moz","Above_10S"))

write.csv(df_eff,file="df_eff.csv",row.names = F,col.names = T)
write.csv(df_eff_new,file="df_eff_new.csv",row.names = F,col.names = T)

#When changing the sampled size in the loop
write.csv(df_eff_new,file="df_eff_new_50.csv",row.names = F,col.names = T)
write.csv(df_eff_new,file="df_eff_new_150.csv",row.names = F,col.names = T)


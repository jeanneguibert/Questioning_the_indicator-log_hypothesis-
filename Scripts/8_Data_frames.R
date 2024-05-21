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

colnames(dfMN)[3] <- "MNmean"
colnames(dfMN)[4] <- "MNsd"

###############Merge 
df_list<-list(dfNLOG,dfChla,dfSST,dfSLA,dfFSLE,dfSSCI,dfMN)  
dftot<-Reduce(function(x, y) merge(x, y, by=c("lat_grid", "lon_grid","year", "month")), df_list)  
summary(dftot)

#filter to keep only years of interest
dftot %>%
  dplyr::filter(year %in% YEARS) -> dftot

#ajout Zone
dftot$Zone <- as.factor(ifelse(dftot$lat_grid<(-10),"Moz","Above_10S"))

#ajout Season
dftot$month <-as.numeric(dftot$month)

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

NLOG_VE_sup_zero <- NLOG_VE[NLOG_VE$NumNLOG>0,]
#Moz <10S
NLOG_VE_sup_zero_Moz <- NLOG_VE_sup_zero[NLOG_VE_sup_zero$Zone=="Moz",]
#North >10?S
NLOG_VE_sup_zero_North <- NLOG_VE_sup_zero[NLOG_VE_sup_zero$Zone=="Above_10S",]

write.csv(NLOG_VE_sup_zero, file.path(PATH_OUTPUT,"NLOG_VE_sup_zero.csv"), row.names = F)
write.csv(NLOG_VE_sup_zero_Moz, file.path(PATH_OUTPUT,"NLOG_VE_sup_zero_Moz.csv"), row.names = F)
write.csv(NLOG_VE_sup_zero_North, file.path(PATH_OUTPUT,"NLOG_VE_sup_zero_North.csv"), row.names = F)

#### Absence NLOG

NLOG_VE_zero <- NLOG_VE[NLOG_VE$NumNLOG==0,]
#Moz <10S
NLOG_VE_zero_Moz <- NLOG_VE_zero[NLOG_VE_zero$Zone=="Moz",]
#North >10?S
NLOG_VE_zero_North <- NLOG_VE_zero[NLOG_VE_zero$Zone=="Above_10S",]

write.csv(NLOG_VE_zero, file.path(PATH_OUTPUT,"NLOG_VE_zero.csv"), row.names = F)
write.csv(NLOG_VE_zero_Moz, file.path(PATH_OUTPUT,"NLOG_VE_zero_Moz.csv"), row.names = F)
write.csv(NLOG_VE_zero_North, file.path(PATH_OUTPUT,"NLOG_VE_zero_North.csv"), row.names = F)


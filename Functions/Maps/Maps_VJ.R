#########################################################################################
                              #   MAPS FUNCTIONS  #
#########################################################################################
#                             FUNCTIONS                                                 #
#=======================================================================================#
# map_occurence(Ob7, year, obj.type, gsize) : carte du nb d'occurrence d'objet       #
#

#WD <- "C:/Users/jguibert/Desktop/R_Stage_M2"
  
  ###CHEMINS NECESSAIRES
#DATA_PATH <- file.path(WD, "Data")
#FUNC_PATH <- file.path(WD, "Functions")

# @Ob7: observers data, containing all the operations on objects

###FONCTIONS NECESSAIRES
#source(file.path(FUNC_PATH,'Prep_obs.R'))
#source(file.path(FUNC_PATH, 'Maps_VJ.R'))
#source(file.path(FUNC_PATH, '1.1.subfunctions_maps_obs.R'))

###BESOIN PACKAGES SUIVANTS
library(ggplot2)
library(plyr)
library("sf")## objet de type sf pour les
library("ggspatial")#superposer les cartes et legende
library("rnaturalearth")
library("rnaturalearthdata")# carte du monde
# library("rgeos")
library(raster)
library(rworldmap)
library(shape)
library(dplyr)

#======================================================================================#
#                         CARTE DU NOMBRE D'OCCURENCES DE FOB                      342 #
#======================================================================================#
#  ARGUMENTS:                                                                          #
# Ob7 (data.frame) : donnees observateur BRUT                                          #
# DATA_PATH (chr) : path to data directory                                             #
# year (num) : annee dont on veut la carte. 0 pour un pool des annees                  #
# obj.type (chr) : choix entre "ALOG", "NLOG", "FAD" et "all" pour pool                #
# gsize (num) : choix entre 1, 2 et 5, pour des cellules de 1dx1d, 2dx2d ou 5dx5d      #
# month (vector num) : pour representer seulement certains mois trimestre. Si c(), pas #
#                   de mois choisi                                                     #
# n (logi) : si n = TRUE, retourne le nombre total d'objet observe sur la periode      #
#             selectionnee. Ne plot pas la carte.                                      #
# eff (chr) : si "T", pond?re le nombre d'observations par le nb de jour dans la zone, #
#             si "F", ne prend pas en compte l'effort                                  #
#             si "plot", fait une carte avec le nombre de jour passe par case          #
# fixed.scale.max (num) default 0, the fill scale is not fixed. If different from 0    #
#                       specify the maximum value of the desired scale                 #
# linear.scale (log) if T, colour of the filling scale are evenly spaced               #
#                    if F, they bring up contrast between smaller values               #
# del.low.eff (log): if T, the cells with a low observation effort are replaced by NAs #
#                    if F, all the cells are kept                                      #
#                                                                                      #
# return: ggplot                                                                       #
#--------------------------------------------------------------------------------------#
### PROBLEME AVEC L EFFORT D OBSERVATION, PAS TRES PRECIS. JE PRENDS UNE OBSERVATION
### PAR JOUR, CE QUI EST UNE GROSSE APPROXIMATION DU TEMPS PASSE PAR ZONE

map_occurence <- function(Ob7, DATA_PATH, year = 0, obj.type = "all", gsize = 2, month = c(),
                          return_raster = F, data_preped = FALSE, eff = "T", linear.scale=T, fixed.scale.max=0,
                          delete.low.effort = T){
                            
  ### 1. PREPARATION DES DONNEES ----
  #------------------------------------------------------------------------------  
  if (data_preped == FALSE){
    Ob7 <- prep.obs(Ob7)
  }
  
  # @ttob7 <- "all_vessel_activities_observe_fr_indian.rds"
  ttob7 <- read.csv(file = file.path(DATA_PATH, "all_vessel_activities_observe_fr_indian.csv"))
  
  ### 2. SELECTION DONNEES D'INTERET ----
  #------------------------------------------------------------------------------   
  ## A. SELECTION COLONNES
  data<-data.frame(Ob7$year,Ob7$latitude,Ob7$longitude,Ob7$obj_conv,Ob7$observation_date)
  names(data)<-c("year","latitude","longitude","fob_type","observation_date")
  
  ttob7 <- data.frame(ttob7$year,ttob7$vessel_name,ttob7$observation_date,
                      ttob7$latitude,ttob7$longitude)
  names(ttob7) <- c("year","vessel_name","observation_date","latitude","longitude")
  
  ## B. EXTRACTION DES DONNEES DE L'ANNEE ----
  if (any(year!=0)){
    data<-data[data$year %in% year,]
    ttob7 <- ttob7[ttob7$year %in% year,]
  }
  
  ## C. SELECTION DU TYPE D'OBJET CHOISI SI obj.type DIFFERENT DE "all" ----
  ##    SI obj.type == "all", NETTOIE LES DONNEES
  if(obj.type!="all"){
    data<-subset(data, data$fob_type == obj.type)
  }else{
    data<-data[data$fob_type!="NULL",]
    data<-data[data$fob_type!="FOB",]
    data<-data[data$fob_type!="LOG",]
  }
  
  ## D. SUPPRIME LES LIGNES CONTENANT des COORDONNEES NULLES ----
  data<-data[data$latitude!=0 | data$longitude!=0,]
  ttob7<-ttob7[ttob7$latitude!=0 | ttob7$longitude!=0,]
  
  ## E. SELECTION DES DONNEES DU TRIMESTRE ----
  if (!is.null(month)){
    
    data <- subset.month(data, month)
    ttob7 <- subset.month(ttob7, month)
    
  }
  
  ## F. TRI POUR GARDER UNE OBS PAR J DANS TTES OBS ----
  ttob7$id_unique <- paste(ttob7$vessel_name,ttob7$observation_date)
  ttob7 <- ttob7[!duplicated(ttob7$id_unique),]
  
  ## G. NOMBRE TOTAL D'OBJETS ----
  nb<-dim(data)[1]
  if (eff=="plot"){
    nb <-dim(ttob7)[1]
  }
  
  ### 3. CREATION DES RASTER A TRACER ----
  #------------------------------------------------------------------------------
  ## A. creation des rasters ----
  ## avec les bonnes coordonnees, et dont la grille contient des 0
  r <- create.raster(gsize)
  eff_obs <- create.raster(gsize)
  
  ## B. COMPTE DES OCCURENCES ET DE L EFFORT PAR CELLULE ----
  r <- fill.raster(data, r)
  eff_obs <- fill.raster(ttob7, eff_obs)
  
  
  ## C. CALCUL DU RATIO OCC/EFF ----
  if (eff == "T"){
    r[]<-r[]/eff_obs[]
  }else if (eff == "plot"){
    r[]<-eff_obs[]
  }
  names(r)<-"occ_over_eff"
  
  ## D. REMPLACE LES VALEURS DES CELLULES AVEC MOINS DE 10 JOURS D OBSERVATION PAR DES NA ----
  if (delete.low.effort){
    r <- del.low.eff(r, eff_obs, gsize)
  }
  
  if (return_raster == T){
    return(r)
  }
  
  ### 4. CREATION DU GGPLOT ----
  #-----------------------------------------------------------------------
  world <- map_data("world")
  df<-as.data.frame(r, xy=TRUE)
 
  ## A. TITRE ----
  
  title <- generate.title.occ(obj.type, eff, month, year)
  
    ## B. SCALE ----
  if (linear.scale==FALSE){ # SCALE WITH CHANGE OF COLOUR CONCENTRATED IN THE LOWER VALUES
    
    if(fixed.scale.max!=0){ # FIX THE MAX OF THE SCALE
      max=fixed.scale.max
    }else {
      max=max(df$occ[is.na(df$occ)==FALSE & is.infinite(df$occ)==FALSE])
    }
    
    mid1=max/3
    mid2=2*max/3
    
    if (eff=="F"){
      labs <- c(0,round(2*max/10),
                round(mid1),round(mid2),
                round(max))
      brks <- c(0,round(2*max/10),round(mid1),round(mid2),round(max))
    } else {
      labs <- c(0,round(2*max/10,2),
                round(mid1,2),round(mid2,2),
                round(max,2))
      brks <- c(0,2*max/10,mid1,mid2,max)
    }
    vals <- c(0,0.1,0.2,1)
    lims <- c(0,max)
    
  } else { # SCALE WITH THE CHANGE OF COLOUR UNIFORM OVER THE WHOLE SCALE
    if(fixed.scale.max!=0){ # FIX THE MAX OF THE SCALE
      max=fixed.scale.max
    }else {
      max=max(df$occ[is.na(df$occ)==FALSE & is.infinite(df$occ)==FALSE])
    }
    
    vals = c(0,1/3,2/3,1)
    brks = waiver()
    labs = waiver()
    lims = c(0,max)
  }
  
   ## C. GGPLOT ----
  ##Attention : coordonn?es modifi?es
  p<- ggplot() +
    geom_sf() +
    coord_sf(xlim = c(20, 100), ylim = c(-40, 40), expand = FALSE, crs = st_crs(4326))+
    geom_raster(data=df, aes(x, y, fill=occ_over_eff)) +
    scale_fill_gradientn(colors=c("gray80","blue","yellow","red"),
                         breaks = brks,
                         values = vals,
                         labels=labs,
                         limits=lims)+
    geom_polygon(data=world, aes(x=long, y=lat, group=group)) +
    labs(title = title$titre,
         subtitle = paste("n = ",nb),
         fill=title$echelle)
  
  p <- mise.en.forme.ggplot(p)
  
  return(p)
}


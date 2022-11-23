rm(list=ls())
library("lubridate")
library("plyr")
library("dplyr")

##################### Set the path to the main folder ###################
WD <- "path_to/Testing_indicator_log"
PATH_DATA <- file.path(WD, "Data")
PATH_FUNC <- file.path(WD, "Functions")
setwd(WD)

# source the main file
source(file.path(WD, "main.R"))

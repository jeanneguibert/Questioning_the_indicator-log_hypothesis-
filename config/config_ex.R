rm(list=ls())
library("lubridate")
library("plyr")
library("dplyr")

##################### Set the path to the main folder ###################
WD <- "path_to/Testing_indicator_log"
PATH_DATA <- file.path(WD, "Data")
PATH_FUNC <- file.path(WD, "Functions")
PATH_OUTPUT <- file.path(WD, "Outputs")
setwd(WD)

### parameters
# resolution used to degrade the necdf files resolution
resolution<-2

#if T, read all the raw data files
# if F, run the scripts starting at script 8 and read the outputs generated in scripts 1 to 7
READ_DATA <- F

#if T, compare the obtained results with the ones sampled among non-observed cells (see Figure B1 and Tables B1 & B2)
# if F, do not run the supplementary analysis
COMPARE_WITH_RANDOM <- T

# Names of the data files
# Observers data, obtained from the Observatoire des Ecosystemes Pelagiques Tropicaux Exploites
OBS_FILE = "all_operations_on_fobs_observe_fr_indian.csv"

# Chlorophyll a data, obtained from
CHLA_FILE = "dataset-oc-glo-bio-multi-l4-chl_4km_monthly-rep_1647279209469.nc"

# Sea Surface Temperature data, obtained from
SST_FILE = "dataset-armor-3d-rep-monthly_1647784901742.nc"

# Sea Level Anomaly data, obtained from
SLA_FILE = "cmems_obs-sl_glo_phy-ssh_my_allsat-l4-duacs-0.25deg_P1M-m_1648036488919.nc"

# Finite Size Lyapunov Exponent (FSLE) data: the script will list the files contained in "PATH_DATA/Netcdf/FSLE"
#                                            one file per year
# obtained from

# Sea Surface Current data, to calculate the Sea Surface Current Intensity data
# obtained from 
SSCI_FILE = "dataset-armor-3d-rep-monthly_1649425349783.nc"

toKeep <- c(ls(), "toKeep")

# source the main file
source(file.path(WD, "main.R"))

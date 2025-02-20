rm(list=ls())
library("lubridate")
library("plyr")
library("dplyr")

##################### Set the path to the main folder ###################
WD <- "path_to/Testing_indicator_log"
PATH_DATA <- file.path(WD, "Data")
PATH_FUNC <- file.path(WD, "Functions")
PATH_OUTPUT <- file.path(WD, "Outputs_sim")
setwd(WD)


### parameters
# years to perform the study on
YEARS <- 2014:2022

# Minimum number of days of observations to consider a cell in the analysis (see T in the article)
NDAYS_OBS_MIN <- 6

# resolution used to degrade the necdf files resolution
resolution<-1

# temporal resolution used to degrade the netcdf files resolution
# either 'week' or 'month'
timeresolution <- 'week'

# Limits of the area considered for the study
AREA_LIMITS <- c(xmin = 39, xmax = 70,
                 ymin = -12, ymax = 10)

#if T, read all the raw data files
# if F, run the scripts starting at script 8 and read the outputs generated in scripts 1 to 7
READ_DATA <- T

#if T, compare the obtained results with the ones sampled among non-observed cells (see Figure B1 and Tables B1 & B2)
# if F, do not run the supplementary analysis
COMPARE_WITH_RANDOM <- T

# Which NLOG density to consider
# either 'sim', then the densities are taken from the RCp scenario in Dupaix et a. (2024) doi.org/10.1016/j.gloenvcha.2024.102917
# or 'obs', then the densities are taken from observers data
NLOG_DATA_SOURCE = 'sim'

# Names of the data files
# Observers data, obtained from the Observatoire des Ecosystemes Pelagiques Tropicaux Exploites
OBS_FILE = "all_operations_on_fobs_observe_v9_fr_2005-2023.csv"
VESSEL_ACTIVITY_FILE = "all_vessel_activities_observe_v9_fr_indian_2005-2023.csv"

# Path to the Ichthyop simulation outputs from doi.org/10.1016/j.gloenvcha.2024.102917
NLOG_SIM_DIR <- file.path(PATH_DATA, 'Netcdf', 'NLOG_sim')

# Chlorophyll a data,
# obtained from https://data.marine.copernicus.eu/product/GLOBAL_MULTIYEAR_BGC_001_029/download
CHLA_FILE = c("cmems_mod_glo_bgc_my_0.25deg_P1D-m_1734000491281_2014.nc",
              "cmems_mod_glo_bgc_my_0.25deg_P1D-m_1734000664591_2015.nc",
              "cmems_mod_glo_bgc_my_0.25deg_P1D-m_1734000709677_2016.nc",
              "cmems_mod_glo_bgc_my_0.25deg_P1D-m_1734000784590_2017.nc",
              "cmems_mod_glo_bgc_my_0.25deg_P1D-m_1734000841656_2018.nc",
              "cmems_mod_glo_bgc_my_0.25deg_P1D-m_1734000890905_2019.nc")

# Sea Surface Temperature data,
# obtained from https://resources.marine.copernicus.eu/product-detail/MULTIOBS_GLO_PHY_TSUV_3D_MYNRT_015_012/INFORMATION
SST_FILE = c("dataset-armor-3d-rep-weekly_1733999065705_2014.nc",
             "dataset-armor-3d-rep-weekly_1733999164212_2015.nc",
             "dataset-armor-3d-rep-weekly_1733999177823_2016.nc",
             "dataset-armor-3d-rep-weekly_1733999197117_2017.nc",
             "dataset-armor-3d-rep-weekly_1733999265056_2018.nc",
             "dataset-armor-3d-rep-weekly_1733999299288_2019.nc")

# Sea Level Anomaly data, obtained from https://resources.marine.copernicus.eu/product-detail/SEALEVEL_GLO_PHY_L4_MY_008_047/INFORMATION
SLA_FILE = c("cmems_obs-sl_glo_phy-ssh_my_allsat-l4-duacs-0.125deg_P1D_1733999743658_2014.nc",
             "cmems_obs-sl_glo_phy-ssh_my_allsat-l4-duacs-0.125deg_P1D_1733999814620_2015.nc",
             "cmems_obs-sl_glo_phy-ssh_my_allsat-l4-duacs-0.125deg_P1D_1733999869204_2016.nc",
             "cmems_obs-sl_glo_phy-ssh_my_allsat-l4-duacs-0.125deg_P1D_1733999976282_2017.nc",
             "cmems_obs-sl_glo_phy-ssh_my_allsat-l4-duacs-0.125deg_P1D_1734000018147_2018.nc",
             "cmems_obs-sl_glo_phy-ssh_my_allsat-l4-duacs-0.125deg_P1D_1734000133678_2019.nc")

# Finite Size Lyapunov Exponent (FSLE) data: the script will list the files contained in "PATH_DATA/Netcdf/FSLE"
#                                            one file per year
# obtained from https://www.aviso.altimetry.fr/es/data/products/value-added-products/fsle-finite-size-lyapunov-exponents

# Sea Surface Current data, to calculate the Sea Surface Current Intensity data
# obtained from https://resources.marine.copernicus.eu/product-detail/MULTIOBS_GLO_PHY_TSUV_3D_MYNRT_015_012/DATA-ACCESS
SSCI_FILE = c("dataset-armor-3d-rep-weekly_1733999420839_2014.nc",
              "dataset-armor-3d-rep-weekly_1733999444847_2015.nc",
              "dataset-armor-3d-rep-weekly_1733999482802_2016.nc",
              "dataset-armor-3d-rep-weekly_1733999514751_2017.nc",
              "dataset-armor-3d-rep-weekly_1733999541292_2018.nc",
              "dataset-armor-3d-rep-weekly_1733999373841_2019.nc")

toKeep <- c(ls(), "toKeep")

# source the main file
source(file.path(WD, "main.R"))

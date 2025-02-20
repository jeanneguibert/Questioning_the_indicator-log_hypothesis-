##################### Main script to test the indicator-log hypothesis ###################

#create output directory
dir.create(PATH_OUTPUT, showWarnings = F)

source(file = file.path(PATH_FUNC, "average_arrays.R"))

if(READ_DATA){
  cat("Reading raw datasets\n==================\n\n")
  # source the script calculating the NLOG densities from observers data
  if(NLOG_DATA_SOURCE == 'obs'){
    cat("    Processing observers data\n")
    source(file.path(WD, "Scripts", "1_NLOG_density.R"))
  } else if (NLOG_DATA_SOURCE == 'sim'){
    cat("    Processing NLOG simulation data\n")
    source(file.path(WD, "Scripts", "1_NLOG_density_sim.R"))
  }
  
  cat("    Processing Chlorophyll a data\n")
  source(file.path(WD, "Scripts", "2_Chla.R"))
  
  cat("    Processing SST data\n")
  source(file.path(WD, "Scripts", "3_SST.R"))
  
  cat("    Processing SLA data\n") 
  source(file.path(WD, "Scripts", "4_SLA.R"))
  
  cat("    Processing FSLE data\n")
  source(file.path(WD, "Scripts", "5_FSLE.R"))
  
  cat("    Processing SSCI data\n")
  source(file.path(WD, "Scripts", "6_SSCI.R"))
  
  cat("    Processing MN data\n")
  source(file.path(WD, "Scripts", "7_MN.R"))
} else {
  cat("Reading processed datasets\n==================\n")
}

cat("\nMerging NLOG abundance with environmental variables\n==================\n\n")
source(file.path(WD, "Scripts", "8_Data_frames.R"))

if (COMPARE_WITH_RANDOM & NLOG_DATA_SOURCE == 'obs'){
  cat("Performing supplementary analysis\n==================\n\n")
  source(file.path(WD, "Scripts", "9_Data_used_vs_Random.R"))
}


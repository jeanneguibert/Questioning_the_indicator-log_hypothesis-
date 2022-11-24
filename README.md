# Questioning the validity of the indicator-log hypothesis for tropical tuna

<!-- [![License](https://img.shields.io/github/license/jeanneguibert/Testing_indicator_log)](https://github.com/jeanneguibert/Testing_indicator_log/blob/master/LICENSE)
[![DOI](https://zenodo.org/badge/416344484.svg)](https://zenodo.org/badge/latestdoi/416344484)
[![Latest Release](https://img.shields.io/github/release/jeanneguibert/Testing_indicator_log)](https://github.com/adupaix/jeanneguibert/Testing_indicator_log) -->

These are the scripts which were used to generate the results presented in the following study, submitted in:

Guibert J., Dupaix A., Lengaigne M. & Capello M. (in press) Questioning the validity of the indicator-log hypothesis for tropical tuna.

Figures and statistical analyses of the study are available in the `Figure_and_stats` folder.

## To launch the scripts

Prepare a config file using the template provided in `config/config_ex.R` :

  - if the raw datasets are not available, set `READ_DATA = F`. The scripts will then only run from the aggregated datasets provided.
  - if the raw datasets are available, they should be stored in a `Data` folder, with the subfolder structure presented bellow.
  
Launch the new config file

## Data organization
  
  ![data_organisation](Figures_and_stats/data_organisation.png)
  

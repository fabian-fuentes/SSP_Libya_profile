#################################################
# Post processing process
#################################################

# load packages
library(data.table)
library(reshape2)
library(mFilter)
library(ggplot2)

rm(list=ls())


#ouputfile
dir.output  <- "ssp_modeling/ssp_run_output/sisepuede_run_2025-08-19T22;16;18.205749/"
output.file <- paste0(basename(sub("/$", "", dir.output)), ".csv")

region <- "libya" 
iso_code3 <- "LBY"

source('ssp_modeling/output_postprocessing/scr/run_script_baseline_run_new.r')

source('ssp_modeling/output_postprocessing/scr/data_prep_new_mapping_libya.r')

source('ssp_modeling/output_postprocessing/scr/data_prep_drivers.r')
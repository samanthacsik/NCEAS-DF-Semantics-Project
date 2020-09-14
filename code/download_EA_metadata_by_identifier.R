##########################################################################################
# Summary
##########################################################################################

##############################
# Load packages
##############################

library(dataone)
library(eatocsv)
library(tidyverse)

##############################
# set nodes & get token
##############################

# token reminder
options(dataone_test_token = "...")

# nodes
cn <- CNode("PROD")
adc_mn <- getMNode(cn, 'urn:node:ARCTIC')

##############################
# query all ADC holdings (only the most recent published version) for identifiers (needed for use in eatocsv), titles, keywords, and abstracts
  # NOTE: rerun periodically and re-save using the write.csv() below to ensure we are working with the most up-to-date data
##############################

my_query <- query(adc_mn, 
                  list(q = "documents:* AND obsolete:(*:* NOT obsoletedBy:*)",
                       rows = "7000", 
                       fl = "identifier, title, keywords, abstract"),
                  as = "data.frame")

# write.csv(my_query, file = here::here("data", "identifiers", "fullQuery2020-09-13", paste("fullQuery", Sys.Date(),".csv", sep = "")), row.names = FALSE) 
# write.csv(my_query, file = here::here("data", "queries", paste("fullQuery", Sys.Date(),".csv", sep = "")), row.names = FALSE) 

##############################
# obtain entity-attribute metadata from multiple data packages in the Arctic Data Center
  # input: A .csv file containing a column of package identifiers (column header = "identifier")
##############################

# read in the .csv file containing the package identifiers
identifiers_file <- list.files(path = here::here("data", "identifiers", "fullQuery2020-09-13"), full.names = TRUE, pattern = "*.csv")
identifiers_df <- read.csv(here::here("data", "identifiers", "fullQuery2020-09-13", "fullQuery2020-09-13.csv"), stringsAsFactors = FALSE)

# download .xml files for each data package 
for (identifier in identifiers_df$identifier){
  cn <- CNode("PROD")
  print(identifier)
  download_objects(node = cn, 
                   pids = identifier,
                   path = here::here("data", "identifiers", "fullQuery2020-09-13", "xml"))
}

# extract attribute-level metadata from all downloaded .xml files in the working directory
document_paths <- list.files(setwd(here::here("data", "identifiers", "PRACTICEquery2020-09-13", "xml")), full.names = TRUE, pattern = "*.xml")
attributes <- extract_ea(document_paths) 

# make the output CSV file prefix based on the input CSV file name
file_prefix <- basename(identifiers_file)
file_prefix <- gsub(".csv","", file_prefix)

# create the CSV file containing the entity-attribute metadata
# write.csv(attributes, file = here::here("data", "extracted_attributes", paste0(file_prefix, "_attributes.csv")), row.names = FALSE)
print(paste0(file_prefix, "_attributes.csv created"))

# test <- read_csv(here::here("data", "extracted_attributes", "query2020-09-13_attributes.csv"))

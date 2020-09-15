##########################################################################################
# Summary
##########################################################################################


##############################
# Load packages
##############################

library(dataone)
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

titleKeywordsAbract_query <- query(adc_mn, 
                                   list(q = "documents:* AND obsolete:(*:* NOT obsoletedBy:*)",
                                        fl = "identifier, title, keywords, abstract"),
                                   as = "data.frame")

# write.csv(my_query, file = here::here("data", "queries", paste("fullQuery_titleKeywordsAbstract", Sys.Date(),".csv", sep = "")), row.names = FALSE) 

attributes_query <- query(adc_mn,
                          list(q = "documents:* AND obsolete:(*:* NOT obsoletedBy:*)",
                               rows = "7000", 
                               fl = "identifier, attribute, attributeLabel, attributeUnit"),
                          as = "data.frame")

# write.csv(my_query, file = here::here("data", "queries", paste("fullQuery_attributes", Sys.Date(),".csv", sep = "")), row.names = FALSE) 

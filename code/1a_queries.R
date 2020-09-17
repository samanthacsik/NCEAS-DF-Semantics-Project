##########################################################################################
# Summary
##########################################################################################

# 1) solr query for titles, keywords, abstracts across all ADC holdings
# 2) solr query for attribute information across all ADC holdings

##########################################################################################
# General Setup
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

##########################################################################################
# query all ADC holdings (only the most recent published version) for identifiers, titles, keywords, abstracts, and attribute info
# NOTE: rerun periodically and re-save using the write.csv() below to ensure we are working with the most up-to-date data
##########################################################################################

# 1) title, keywords, abstracts
titleKeywordsAbract_query <- query(adc_mn, 
                                   list(q = "documents:* AND obsolete:(*:* NOT obsoletedBy:*)",
                                        fl = "identifier, title, keywords, abstract"),
                                   as = "data.frame")

# write.csv(titleKeywordsAbract_query, file = here::here("data", "queries", paste("fullQuery_titleKeywordsAbstract", Sys.Date(),".csv", sep = "")), row.names = FALSE) 

# 2) attribute information
attributes_query <- query(adc_mn,
                          list(q = "documents:* AND obsolete:(*:* NOT obsoletedBy:*)",
                               rows = "7000", 
                               fl = "identifier, attribute, attributeLabel, attributeUnit"),
                          as = "data.frame")

# write.csv(attributes_query, file = here::here("data", "queries", paste("fullQuery_attributes", Sys.Date(),".csv", sep = "")), row.names = FALSE) 
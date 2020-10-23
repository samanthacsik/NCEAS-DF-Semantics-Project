# title: Current ADC Semantic Annotations Review
# author: "Sam Csik"
# date created: "2020-09-21"
# date edited: "2020-09-21"
# packages updated: __
# R version: __
# input: "NA"
# output: "data/queries/*"

##########################################################################################
# Summary
##########################################################################################

##########################################################################################
# General Setup
##########################################################################################

##############################
# Load packages
##############################

library(dataone)
library(tidyverse)
library(eatocsv)

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
##########################################################################################

# 1) title, keywords, abstracts
semAnnotations_query <- query(adc_mn, 
                              list(q = "documents:* AND obsolete:(*:* NOT obsoletedBy:*)",
                                   fl = "identifier, title, keywords, abstract, attribute, sem_annotates, sem_annotation, sem_annotated_by, sem_comment",
                                   rows = "7000"),
                                   as = "data.frame")

write.csv(titleKeywordsAbract_query, file = here::here("data", "ADC_semantic_annotations_review", paste("fullQuery_semAnnotations", Sys.Date(),".csv", sep = "")), row.names = FALSE) 

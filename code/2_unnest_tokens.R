# title: Unnest Tokens
# author: "Sam Csik"
# date created: "2020-09-14"
# date edited: "2020-09-21"
# packages updated: __
# R version: __
# input: "data/queries/fullQuery_titleKeywordsAbstract2020-09-15.csv" & "data/attributes_query_eatocsv/extracted_attributes/fullQuery2020-09-13_attributes.csv" 
# output: "data/text_mining/unnested_tokens/*"

##########################################################################################
# Summary
##########################################################################################

# This script uses the tidytext package to unnest (i.e. separate into individual columns) tokens (i.e. words) into various ngrams (where n = 1, 2, or 3)
# Specifically, we unnest titles, keywords, abstracts, entityNames, attributeNames, attributeLabels, attributeDescriptions
# These unnested tokens are saved as .csv files for use in later scripts

##########################################################################################
# General Setup
##########################################################################################

##############################
# Load packages
##############################

library(tidyverse)
library(tidytext)

##############################
# Upload data - solr query results from script 1a & EA data from script 1b
##############################

my_query <- read_csv(here::here("data", "queries", "fullQuery_titleKeywordsAbstract2020-09-15.csv"))
attributes <- read_csv(here::here("data", "attributes_query_eatocsv", "extracted_attributes", "fullQuery2020-09-13_attributes.csv"))

##############################
# data processing functions
##############################

# function that unnests individual tokens and separates ngrams into multiple columns
tidyTokens_unnest <- function(my_data, my_input, split) {
  my_data %>%
    select(identifier, my_input) %>%
    unnest_tokens(output = ngram, input = !!my_input, token = "ngrams", n = split) %>% 
    separate(ngram, into = c("word1", "word2", "word3"), sep = " ")
}

# function that applies the tidyTokens_unnest() to all specified items within a df, and saves as data objects
process_df <- function(df, item) {
  
  print("Processing DF")
  print(item)
  
  # unnest tokens
  print("processing word_table")
  word_table <- tidyTokens_unnest(df, item, 1)
  bigram_table <- tidyTokens_unnest(df, item, 2)
  trigram_table <- tidyTokens_unnest(df, item, 3)

  # create object names
  word_table_name <- paste("unnested_", item, "IndivTokens", Sys.Date(), sep = "")
  bigram_table_name <- paste("unnested_", item, "BigramTokens", Sys.Date(), sep = "")
  trigram_table_name <- paste("unnested_", item, "TrigramTokens", Sys.Date(), sep = "")
  
  # print as dfs
  assign(word_table_name, word_table, envir = .GlobalEnv)
  assign(bigram_table_name, bigram_table, envir = .GlobalEnv)
  assign(trigram_table_name, trigram_table, envir = .GlobalEnv)
}

##########################################################################################
# Process TITLES, KEYWORDS, ABSTRACTS
# 1) unnest tokens (for individual words, bigrams, trigrams)
##########################################################################################

##############################
# 1) unnest tokens (for individual words, bigrams, trigrams)
##############################

# individual tokens
kta_metadata <- tribble(
  ~my_input,  
  "keywords",    
  "title",     
  "abstract", 
)

# process dfs
for (row in 1:nrow(kta_metadata)) {
  item <- as.character(kta_metadata[row,][,1][,1])
  print(item)
  process_df(my_query, item)
}

##########################################################################################
# Process ENTITY & ATTRIBUTE INFORMATION
# 1) isolate extracted attributeNames & attriuteLabels -- these are already unnested and don't need further processing
# 2) unnest entityNames 
# 3) unnest attributeDefinitions
##########################################################################################

##############################
# 1) isolate unnested attributesNames & attributeLabels -- make sure format is similar to other unnested tokens above
##############################

# attributeNames
`unnested_attributeNamesIndivTokens2020-09-13` <- read_csv(here::here("data", "attributes_query_eatocsv", "extracted_attributes", "fullQuery2020-09-13_attributes.csv")) %>% 
  select(identifier, attributeName) %>% 
  rename(word1 = attributeName) %>% 
  mutate(word2 = rep(""), word3 = rep(""))

# attributeLabels
`unnested_attributeLabelsIndivTokens2020-09-13` <- read_csv(here::here("data", "attributes_query_eatocsv", "extracted_attributes", "fullQuery2020-09-13_attributes.csv")) %>% 
  select(identifier, attributeLabel) %>% 
  rename(word1 = attributeLabel) %>% 
  mutate(word2 = rep(""), word3 = rep(""))

##############################
# 2) unnest entityNames
##############################

# separate entity names at "_"
attributes$entityName <- gsub("_", " ", attributes$entityName)

# simplify df
entityNames <- attributes %>% 
  select(identifier, entityName)

# process dfs
process_df(entityNames, "entityName")

##############################
# 2) unnest attributeDefinitions
##############################

# simplify df
attributeDefinitions <- attributes %>% 
  select(identifier, attributeDefinition)

# process dfs
process_df(attributeDefinitions, "attributeDefinition")

##########################################################################################
# print all unnested dfs as .csv files
##########################################################################################

# get list of new dfs
df_list <- mget(ls(pattern = "unnested_"))

# function to write as .csv files
output_csv <- function(data, names){
  write_csv(data, here::here("data", "text_mining", "unnested_tokens", paste0(names, ".csv")))
}

# write each df as .csv file
list(data = df_list, names = names(df_list)) %>%
     purrr::pmap(output_csv)

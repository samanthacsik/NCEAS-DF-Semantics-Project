# title: Filter Out 'stop_words' from Unnested Token dfs
# author: "Sam Csik"
# date created: "2020-09-16"
# date edited: "2020-09-17"
# packages updated: __
# R version: __
# input: "data/text_mining/unnested_tokens/*"
# output: "data/text_mining/filtered_token_counts/*"

##########################################################################################
# Summary
##########################################################################################

# This script uses the tidytext package to filter out "stop_words" (i.e. extremely common words) from unnested token files AND count occurrences
# These unnested, filtered, and counted tokens are saved as .csv files
# Filtering and counting takes unnested token files as inputs

##########################################################################################
# General Setup
##########################################################################################

##############################
# Load packages
##############################

library(tidyverse)
library(tidytext)

##############################
# import stop_words (built in lexicons)
##############################

# read in stop_words
data(stop_words)

##########################################################################################
# Filter/count INDIVIDUAL TOKENS
##########################################################################################

# isolate individual token files (do not include attributes -- they are in a different format)
all_unnested_indiv_files <- list.files(path = here::here("data", "text_mining", "unnested_tokens"), pattern = glob2rx("unnested_*Indiv*"))
all_unnested_indiv_files <- all_unnested_indiv_files[-2]
all_unnested_indiv_files

# remove excess columns, filter out stop_words, remove NAs, calculate counts
for(i in 1:length(all_unnested_indiv_files)){
  
  # create object name
  object_name <- basename(all_unnested_indiv_files[i])
  object_name <- gsub(".csv", "", object_name)
  object_name <- gsub("unnested_", "filteredCounts_", object_name)
  print(object_name)
  
  # wrangle data
  my_file <- read_csv(here::here("data", "text_mining", "unnested_tokens", all_unnested_indiv_files[i])) %>% 
    rename(token = word1) %>% # comes in handy in script 4
    select(identifier, token) %>% 
    filter(!token %in% stop_words$word, token != "NA") %>% 
    count(token, sort = TRUE)
  
  # save as object_name
  assign(object_name, my_file)
}

##########################################################################################
# Filter/count BIGRAMS 
##########################################################################################

# isolate bigram token files
all_unnested_bigram_files <- list.files(path = here::here("data", "text_mining", "unnested_tokens"), pattern = glob2rx("unnested_*Bigram*"))

# remove excess columns, filter out stop_words, remove NAs, calculate counts
for(i in 1:length(all_unnested_bigram_files)){
  
  # create object name
  object_name <- basename(all_unnested_bigram_files[i])
  object_name <- gsub(".csv", "", object_name)
  object_name <- gsub("unnested_", "filteredCounts_", object_name)
  print(object_name)
  
  # wrangle data
  my_file <- read_csv(here::here("data", "text_mining", "unnested_tokens", all_unnested_bigram_files[i])) %>% 
    select(identifier, word1, word2) %>% 
    filter(!word1 %in% stop_words$word, !word2 %in% stop_words$word) %>% 
    filter(word1 != "NA", word2 != "NA") %>% 
    count(word1, word2, sort = TRUE)
  
  # save as object_name
  assign(object_name, my_file)
}

##########################################################################################
# Filter/count TRIGRAMS
##########################################################################################

# isolate trigram token files
all_unnested_trigram_files <- list.files(path = here::here("data", "text_mining", "unnested_tokens"), pattern = glob2rx("unnested_*Trigram*"))

# remove excess columns, filter out stop_words, remove NAs, calculate counts
for(i in 1:length(all_unnested_trigram_files)){
  
  # create object name
  object_name <- basename(all_unnested_trigram_files[i])
  object_name <- gsub(".csv", "", object_name)
  object_name <- gsub("unnested_", "filteredCounts_", object_name)
  print(object_name)
  
  # wrangle data
  my_file <- read_csv(here::here("data", "text_mining", "unnested_tokens", all_unnested_trigram_files[i])) %>% 
    select(identifier, word1, word2, word3) %>% 
    filter(!word1 %in% stop_words$word, !word2 %in% stop_words$word, !word3 %in% stop_words$word) %>% 
    filter(word1 != "NA", word2 != "NA", word3 != "NA") %>% 
    count(word1, word2, word3, sort = TRUE)
  
  # save as object_name
  assign(object_name, my_file)
}

##########################################################################################
# save as .csv files
##########################################################################################

# get list of new dfs
df_list <- mget(ls(pattern = "filteredCounts_"))

# function to write as .csv files to appropriate subdirectory
output_csv <- function(data, names){
  write_csv(data, here::here("data", "text_mining", "filtered_token_counts", paste0(names, ".csv")))
}

# write each df as .csv file
list(data = df_list, names = names(df_list)) %>%
  purrr::pmap(output_csv) 

##########################################################################################
# Count attributes -- these data were generated using script 1b; NAs have already been removed; no other filtering (e.g. for stop_words) has been done
##########################################################################################

attributes_tokens <- read_csv(here::here("data", "text_mining", "unnested_tokens", "unnested_attributesIndivTokens2020-09-13.csv")) %>% # 1446 unique IDs vs 1422 unique IDs for solr query returns (one remvoed NAs)
  select(identifier, attributeName) %>% 
  count(attributeName, sort = TRUE) %>% 
  rename(token = attributeName)

# write_csv(attributes_tokens, here::here("data", "text_mining", "filtered_token_counts", "filteredCounts_attributeNameIndivTokens2020-09-13.csv"))

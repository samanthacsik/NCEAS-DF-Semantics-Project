# title: Filter Out 'stop_words' from Unnested Token dfs
# author: "Sam Csik"
# date created: "2020-09-16"
# date edited: "2020-09-21
# packages updated: __
# R version: __
# input: "data/text_mining/unnested_tokens/*"
# output: "data/text_mining/filtered_token_counts/*"

##########################################################################################
# Summary
##########################################################################################

# This script uses the tidytext package to filter out "stop_words" (i.e. extremely common words) from unnested token files AND count occurrences
# These unnested, filtered, and counted tokens are saved as .csv files
# For loops to filter and count tokens takes unnested token files as inputs

##########################################################################################
# General Setup
##########################################################################################

##############################
# Load packages
##############################

library(tidyverse)
library(tidytext)

##############################
# get stop_words (built in lexicons)
##############################

# read in stop_words
data(stop_words)

##############################
# functions to filter out stop_words and NAs from unnested tokens and count frequency of occurrences for each term
##############################

filterCount_indivTokens <- function(file_name) {
  
  # create object name
  object_name <- basename(file_name)
  object_name <- gsub(".csv", "", object_name)
  object_name <- gsub("unnested_", "filteredCounts_", object_name)
  print(object_name)
  
  # wrangle data
  my_file <- read_csv(here::here("data", "text_mining", "unnested_tokens", file_name)) %>% 
    rename(token = word1) %>% # comes in handy in script 4
    select(identifier, token) %>% 
    filter(!token %in% stop_words$word, token != "NA") %>% 
    count(token, sort = TRUE)
  
  # save as object_name
  assign(object_name, my_file, envir = .GlobalEnv)
}

filterCount_bigramTokens <- function(file_name) {
  
  # create object name
  object_name <- basename(file_name)
  object_name <- gsub(".csv", "", object_name)
  object_name <- gsub("unnested_", "filteredCounts_", object_name)
  print(object_name)
  
  # wrangle data
  my_file <- read_csv(here::here("data", "text_mining", "unnested_tokens", file_name)) %>% 
    select(identifier, word1, word2) %>% 
    filter(!word1 %in% stop_words$word, !word2 %in% stop_words$word) %>% 
    filter(word1 != "NA", word2 != "NA") %>% 
    count(word1, word2, sort = TRUE)
  
  # save as object_name
  assign(object_name, my_file, envir = .GlobalEnv)
}

filterCount_trigramTokens <- function(file_name) {
  
  # create object name
  object_name <- basename(file_name)
  object_name <- gsub(".csv", "", object_name)
  object_name <- gsub("unnested_", "filteredCounts_", object_name)
  print(object_name)
  
  # wrangle data
  my_file <- read_csv(here::here("data", "text_mining", "unnested_tokens", file_name)) %>% 
    select(identifier, word1, word2, word3) %>% 
    filter(!word1 %in% stop_words$word, !word2 %in% stop_words$word, !word3 %in% stop_words$word) %>% 
    filter(word1 != "NA", word2 != "NA", word3 != "NA") %>% 
    count(word1, word2, word3, sort = TRUE)
  
  # save as object_name
  assign(object_name, my_file, envir = .GlobalEnv)
}

##########################################################################################
# Filter/count INDIVIDUAL TOKENS
##########################################################################################

# isolate individual token files #####(do not include attributes -- they are in a different format)
all_unnested_indiv_files <- list.files(path = here::here("data", "text_mining", "unnested_tokens"), pattern = glob2rx("unnested_*Indiv*"))

# remove excess columns, filter out stop_words, remove NAs, calculate counts
for(i in 1:length(all_unnested_indiv_files)){
  file_name <- all_unnested_indiv_files[i]
  filterCount_indivTokens(file_name)
}

##########################################################################################
# Filter/count BIGRAMS 
##########################################################################################

# isolate bigram token files
all_unnested_bigram_files <- list.files(path = here::here("data", "text_mining", "unnested_tokens"), pattern = glob2rx("unnested_*Bigram*"))

# remove excess columns, filter out stop_words, remove NAs, calculate counts
for(i in 1:length(all_unnested_bigram_files)){
  file_name <- all_unnested_bigram_files[i]
  filterCount_bigramTokens(file_name)
}

##########################################################################################
# Filter/count TRIGRAMS
##########################################################################################

# isolate trigram token files
all_unnested_trigram_files <- list.files(path = here::here("data", "text_mining", "unnested_tokens"), pattern = glob2rx("unnested_*Trigram*"))

# remove excess columns, filter out stop_words, remove NAs, calculate counts
for(i in 1:length(all_unnested_trigram_files)){
  file_name <- all_unnested_trigram_files[i]
  filterCount_trigramTokens(file_name)
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
# title: Filter Out 'stop_words' from Unnested Token dfs
# author: "Sam Csik"
# date created: "2020-09-16"
# date edited: "2020-09-28
# packages updated: __
# R version: __
# input: "data/text_mining/unnested_tokens/*"
# output: "data/text_mining/filtered_token_counts/*"

##########################################################################################
# Summary
##########################################################################################

# This script uses the tidytext package to filter out "stop_words" (i.e. extremely common words) from unnested token files, count number of occurrences for each term (token), and count the number of unique identifiers associated with each unique term
# These data frames are saved then as .csv files

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
# source data processing functions
##############################

source("code/0_functions.R")

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

##########################################################################################
# TEST TO MAKE SURE CODE WORKS AS EXPECTED
##########################################################################################

# # load data
# my_query <- read_csv(here::here("data", "queries", "fullQuery_titleKeywordsAbstractAuthors2020-09-28.csv"))

# # filter for token == "glacier" to return number of unique identifiers associated with individual keyword "glacier"; this should match "unique_id" for token = "glacier" when running filterCount_indiv_tokens()
# test_example <- my_query %>%
#   select(identifier, author, keywords) %>%
#   unnest_tokens(output = word, input = "keywords", token = "ngrams", n = 1) %>%
#   group_by(word) %>%
#   filter(word == "glacier") %>%
#   distinct(author) %>% # either "author" or "identifier" here
#   count()

# trigram "airglow imgage data" - Kim Neilsen
# airglow_image_data_example <- my_query %>%
#   select(identifier, author, title) %>%
#   unnest_tokens(output = word, input = "title", token = "ngrams", n = 3) %>%
#   group_by(word) %>%
#   filter(word == "airglow image data") 
#   # distinct(identifier) %>%
#   # count()

# bigram "data alaska" - Kim Neilsen
# data_alaska_example <- my_query %>%
#   select(identifier, author, title) %>%
#   unnest_tokens(output = word, input = "title", token = "ngrams", n = 2) %>%
#   group_by(word) %>%
#   filter(word == "data alaska")
  # distinct(identifier) %>%
  # count()

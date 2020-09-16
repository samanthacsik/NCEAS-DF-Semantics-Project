##########################################################################################
# Summary
##########################################################################################

# This script uses the tidytext package to filter out "stop_words" (i.e. extremely common words) from unnested token files AND count occurrances
# These unnested, filtered, and counted tokens are saved as .csv files
# Filtering and counting takes unnested token files as inputs

# !!!!!!!!!!!MAY WANT TO TRY tf-idf!!!!!!!!!!!

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

# isolate individual token files
all_unnested_indiv_files <- list.files(path = here::here("data", "text_mining", "unnested_tokens"), pattern = glob2rx("unnested_*Indiv*"))

# remove excess columns, filter out stop_words, remove NAs, calculate counts
for(i in 1:length(all_unnested_indiv_files)){
  
  # create object name
  object_name <- basename(all_unnested_indiv_files[i])
  object_name <- gsub(".csv", "", object_name)
  object_name <- gsub("unnested_", "filteredCounts_", object_name)
  print(object_name)
  
  # wrangle data
  my_file <- read_csv(here::here("data", "text_mining", "unnested_tokens", all_unnested_indiv_files[i])) %>% 
    select(identifier, word1) %>% 
    filter(!word1 %in% stop_words$word, word1 != "NA") %>% 
    count(word1, sort = TRUE)
  
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

# isolate bigram token files
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

# function to write as .csv files
output_csv <- function(data, names){
  write_csv(data, here::here("data", "text_mining", "filtered_token_counts", paste0(names, ".csv")))
}

# write each df as .csv file
list(data = df_list, names = names(df_list)) %>%
  purrr::pmap(output_csv) 

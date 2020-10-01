# title: Calculating a single score to determine "most important semantic terms"
# author: "Sam Csik"
# date created: "2020-09-29"
# date edited: "2020-10-01"
# R version: 3.6.3
# input: "data/text_mining/filtered_token_counts/*"
# output: "figures/token_frequencies/*"

#########################################################################################
# Summary
##########################################################################################

# Our goal is to determine semantically-important terms across ADC holdings
  # These are terms that occur often and across many different data packages (i.e. unique identifiers) that are truly "different" (e.g. not nested datasets that have the same content but from different years)
# To do so, I generate an "importance score" which takes into account term frequency, the number of unique identifiers that term occurs in, and the number of unqiue first authors that use that term
  # score = (n/unique_author) + (unique_id/unique_author)
  # low scores signify "important" terms that are likely the "low hanging fruit" that we'll want to start with
    # NOTE: terms that occur, for example, 1 time in 1 data package with 1 unique author will have a very low score despite not being very helpful...we'll want to filter out these terms

##########################################################################################
# General Setup
##########################################################################################

##############################
# Load packages
##############################

source(here::here("code", "0_libraries.R"))

##############################
# source custom functions
##############################

source(here::here("code", "0_functions.R"))

##############################
# Read in data
##############################

# isolate filtered_token_counts
all_files <- list.files(path = here::here("data", "text_mining", "filtered_token_counts"), pattern = glob2rx("*.csv"))

# remove excess columns, filter out stop_words, remove NAs, calculate counts
for(i in 1:length(all_files)){
  file_name <- all_files[i]
  import_filteredTermCounts(file_name)
}

##########################################################################################
# Get data into appropriate format for plotting
# 1) combine bigrams into single column for plotting
# 2) combine trigrams into single column for plotting
##########################################################################################

##############################
# 1) combine bigrams
##############################

# get lists of bigram dfs
bigram_list <- mget(ls(pattern = "BigramTokens"))

# combine words in bigram dfs
for(i in 1:length(bigram_list)){
  obj <- bigram_list[i]
  object <- obj[[1]]
  name <- names(obj)
  combine_bigrams(object = object, object_name = name)
}

##############################
# 2) combine trigrams
##############################

# get list of trigram dfs
trigram_list <- mget(ls(pattern = "TrigramTokens"))

# combine words in trigram dfs
for(i in 1:length(trigram_list)){
  obj <- trigram_list[i]
  object <- obj[[1]]
  name <- names(obj)
  combine_trigrams(object = object, object_name = name)
}

##########################################################################################
# Calculate "semantic importance" score t
# low scores = more important terms (but need to filter out terms that are used only a few times...)
##########################################################################################

# get lists of Tokens dfs
df_list <- mget(ls(pattern = "Tokens"))

# calculate weighted scores
for(i in 1:length(df_list)){
  obj <- df_list[i]
  object <- obj[[1]]
  name <- names(obj)
  print(name)
  calculate_weighted_score(df = object)
}

# score^n

##########################################################################################
# print all weighted scroe dfs as .csv files
##########################################################################################

# get list of new dfs
df_list <- mget(ls(pattern = "Tokens"))

# function to write as .csv files
output_csv <- function(data, names){
  write_csv(data, here::here("data", "text_mining", "weighted_scores", paste0(names, ".csv")))
}

# write each df as .csv file
list(data = df_list, names = names(df_list)) %>%
  purrr::pmap(output_csv)

##########################################################################################
# Summary
##########################################################################################

# This script uses the tidytext package to unnest (i.e. separate into individual columns) tokens (i.e. words) into various ngrams (where n = 1, 2, or 3)
# These unnested tokens are saved as .csv files for use in later scripts
# Unnesting takes a solr query (saved as a .csv file) as an input

##########################################################################################
# General Setup
##########################################################################################

##############################
# Load packages
##############################

library(tidyverse)
library(tidytext)

##############################
# Upload data - solr query results saved as .csv
##############################

my_query <- read_csv(here::here("data", "queries", "fullQuery_titleKeywordsAbstract2020-09-15.csv"))

##############################
# tidying functions 
##############################

# used to unnest individual tokens and separate ngrams into multiple columns
tidyTokens_unnest <- function(my_input, split) {
  my_query %>%
    select(identifier, my_input) %>%
    unnest_tokens(output = ngram, input = !!my_input, token = "ngrams", n = split) %>% 
    separate(ngram, into = c("word1", "word2", "word3"), sep = " ")
}

##############################
# metadata to pass into for loops
##############################

# individual tokens
forloop_metadata <- tribble(
  ~my_input,  
  "keywords",    
  "title",     
  "abstract", 
)

##########################################################################################
# 1) unnest tokens (for individual words, bigrams, trigrams)
# 2) print unnested tokens as .csvs
##########################################################################################

##############################
# 1) unnest tokens (for individual words, bigrams, trigrams)
##############################

for (row in 1:nrow(forloop_metadata)) {
  
  # keywords, title, or abstract
  item <- as.character(forloop_metadata[row,][,1][,1])
  print(item)
  
  # unnest tokens
  word_table <- tidyTokens_unnest(item, 1)
  bigram_table <- tidyTokens_unnest(item, 2)
  trigram_table <- tidyTokens_unnest(item, 3)
  
  # create object names
  word_table_name <- paste("unnested_", item, "IndivTokens", Sys.Date(), sep = "")
  bigram_table_name <- paste("unnested_", item, "BigramTokens", Sys.Date(), sep = "")
  trigram_table_name <- paste("unnested_", item, "TrigramTokens", Sys.Date(), sep = "")

  # print as dfs
  assign(word_table_name, word_table)
  assign(bigram_table_name, bigram_table)
  assign(trigram_table_name, trigram_table)
}

##############################
# 2) print as .csv files
##############################

# get list of new dfs
df_list <- mget(ls(pattern = "unnested_"))

# function to write as .csv files
output_csv <- function(data, names){
  write_csv(data, here::here("data", "text_mining", "unnested_tokens", paste0(names, ".csv")))
}

# write each df as .csv file
list(data = df_list, names = names(df_list)) %>%
     purrr::pmap(output_csv) 

##############################
# 3) save extracted attributes (from script 1b) to same directory as other unnested tokens
##############################

unnested_attributes <- read_csv(here::here("data", "attributes_query_eatocsv", "extracted_attributes", "fullQuery2020-09-13_attributes.csv"))

write_csv(unnested_attributes, here::here("data", "text_mining", "unnested_tokens", "unnested_attributesIndivTokens2020-09-13.csv"))

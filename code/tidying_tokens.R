##########################################################################################
# Summary
##########################################################################################

# unnest, clean, and count individual keyword, title, abstract tokens
# * Using this awesome resource: https://www.tidytextmining.com/

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

# unnest individual tokens
tidyTokens_unnest <- function(my_input, split) {
  my_query %>%
    select(identifier, my_input) %>%
    unnest_tokens(output = ngram, input = !!my_input, token = "ngrams", n = split) %>% 
    separate(ngram, into = c("word1", "word2", "word3"), sep = " ")
}

# unnest individual tokens, filter out stop words, and calculate counts for individual tokens
# tidyTokens_unnestCleanCounts <- function(my_input, split) {
#   my_query %>% 
#     select(identifier, my_input) %>% 
#     unnest_tokens(output = ngram, input = !!my_input, token = "ngrams", n = split) %>% 
#     anti_join(stop_words) %>%
#     group_by(identifier) %>%
#     distinct(word, .keep_all = TRUE) %>%
#     ungroup() %>% 
#     count(word, sort = TRUE)
# }

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
# 3) unnest, clean, and count tokens (for individual words, bigrams, trigrams)
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
# 2) print as csvs
##############################

# get list of new dfs
df_list <- mget(ls(pattern = "unnested_"))

# function to write as .csv files
output_csv <- function(data, names){
  #folder_path <- here::here("data", "text_mining", "unnested_tokens")
  write_csv(data, here::here("data", "text_mining", "unnested_tokens", paste0(names, ".csv")))
}

# write each df as .csv file
list(data = df_list, names = names(df_list)) %>%
     purrr::pmap(output_csv) 

##############################
# 3) unnest, clean, and count tokens (for individual words, bigrams, trigrams)
##############################

for (row in 1:nrow(forloop_metadata)) {
  data_row <- forloop_metadata[row,]
  print(data_row)
  item <- data_row[,1]
  print(item)
  save_name <- paste(item, "IndividualTokens_CleanCounts", Sys.Date(), sep = "")
  print(save_name)
  table <- tidyTokens_unnestCleanCounts(as.character(item)) 
  assign(save_name, table)
}


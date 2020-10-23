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

source(here::here("code", "0_libraries.R"))

##############################
# Upload data - solr query results from script 1a & EA data from script 1b
##############################

# import data
my_query <- read_csv(here::here("data", "queries", "fullQuery_titleKeywordsAbstractAuthors2020-09-28.csv"))
attributes <- read_csv(here::here("data", "attributes_query_eatocsv", "extracted_attributes", "fullQuery2020-09-13_attributes.csv"))

# isolate authors and ids from my_query to join with attributes df (eatocsv package does not include `authors` when processing queried data)
authors_ids <- my_query %>% select(identifier, author)

# join (original attributes = 136643 rows; joined attributes below = 135588 rows; still not sure what the difference of 1065 rows is from)
attributes <- inner_join(attributes, authors_ids)

##############################
# source data processing functions
##############################

source(here::here("code", "0_functions.R"))

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
# 1) isolate extracted attributeNames -- these are already unnested and don't need further processing
# 2) unnest entityNames 
# 3) unnest attributeLabels & attributeDefinitions
# 4) unnest attributeDefinitions
##########################################################################################

##############################
# 1) isolate unnested attributesNames -- these are already unneseted; make sure format is similar to other unnested tokens above
##############################

# attributeNames
`unnested_attributeNamesIndivTokens2020-09-13` <- attributes %>% 
  select(identifier, author, attributeName) %>% 
  rename(word1 = attributeName) %>% 
  mutate(word2 = rep(""), word3 = rep(""))

##############################
# 2) unnest entityNames
##############################

# separate entity names at "_"
attributes$entityName <- gsub("_", " ", attributes$entityName)

# simplify df
entityNames <- attributes %>% 
  select(identifier, author, entityName) %>% 
  distinct(identifier, author, entityName) # since there is an entityName for every attribute in said entity

# process dfs
process_df(entityNames, "entityName")

##############################
# 3) unnest attributeLabels & attributeDefinitions
##############################

# individual tokens
aLaD_metadata <- tribble(
  ~my_input,  
  "attributeLabel",    
  "attributeDefinition"
)

# process dfs
for (row in 1:nrow(aLaD_metadata)) {
  item <- as.character(aLaD_metadata[row,][,1][,1])
  print(item)
  process_df(attributes, item)
}

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
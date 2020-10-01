# title: Visualizing ngram Networds 
# author: "Sam Csik"
# date created: "2020-09-16"
# date edited: "2020-09-17"
# packages updated: __
# R version: __
# input: "data/text_mining/filtered_token_counts/*"
# output: "figures/word_associations*"

##########################################################################################
# Summary
##########################################################################################

# word associations

##########################################################################################
# General Setup
##########################################################################################

##############################
# Load packages
##############################

library(tidytext)
library(tidyverse)
library(igraph)
library(ggraph)
# library(widyr)

##############################
# Import filtered/counted bigrams
##############################

# isolate bigram token files
all_filteredCounts_bigram_files <- list.files(path = here::here("data", "text_mining", "filtered_token_counts"), pattern = glob2rx("filteredCounts_*Bigram*"))

# remove excess columns, filter out stop_words, remove NAs, calculate counts
for(i in 1:length(all_filteredCounts_bigram_files)){
  
  # create object name
  object_name <- basename(all_filteredCounts_bigram_files[i])
  object_name <- gsub("Tokens2020-09-15.csv", "", object_name)
  object_name <- gsub("filteredCounts_", "", object_name)
  print(object_name)
  
  # wrangle data
  my_file <- read_csv(here::here("data", "text_mining", "filtered_token_counts", all_filteredCounts_bigram_files[i]))  
  
  # save as object_name
  assign(object_name, my_file)
}

##########################################################################################
# 
##########################################################################################

##############################
# create bigram graph
##############################

# create igraph object
abstractBigram_igraphObject <- abstractBigram %>% 
  filter(n > 250) %>% 
  graph_from_data_frame()

# use ggraph to convert igraph object into a ggraph (needs 3 layers: node, edges, text)
set.seed(2100)

a <- grid::arrow(type = "closed", length = unit(.15, "inches"))

# png("figures/word_associations/abstractBigram_network.png")
abstractBigram_network <- ggraph(abstractBigram_igraphObject, layout = "fr") +
  geom_edge_link(aes(edge_alpha = n), show.legend = FALSE,
                 arrow = a, end_cap = circle(.07, 'inches')) +
  geom_node_point(color = "lightblue", size = 5) +
  geom_node_text(aes(label = name), vjust = 1, hjust = 1) +
  theme_void()
# png(abstractBigram_network)

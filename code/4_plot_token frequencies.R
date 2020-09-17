# title: Plotting Token/ngram Frequencies
# author: "Sam Csik"
# date created: "2020-09-16"
# date edited: "2020-09-17"
# packages updated: __
# R version: __
# input: "data/text_mining/filtered_token_counts/*"
# output: "figures/token_frequencies/*"

#########################################################################################
# Summary
##########################################################################################

# plot token frequencies

##########################################################################################
# General Setup
##########################################################################################

##############################
# Load packages
##############################

library(tidyverse)
library(tidytext)
library(patchwork)

##############################
# Read in data
##############################

# isolate filtered_token_counts
all_files <- list.files(path = here::here("data", "text_mining", "filtered_token_counts"), pattern = glob2rx("*.csv"))

# remove excess columns, filter out stop_words, remove NAs, calculate counts
for(i in 1:length(all_files)){
  
  # create object name
  object_name <- basename(all_files[i])
  object_name <- gsub("2020-09-15.csv", "", object_name)
  object_name <- gsub("filteredCounts_", "", object_name)
  print(object_name)
  
  # read in data
  my_file <- read_csv(here::here("data", "text_mining", "filtered_token_counts", all_files[i])) 
  
  # save as object_name
  assign(object_name, my_file)
}

# update object name for attributes since date is different
attributesIndivTokens <- `attributeIndivTokens2020-09-13.csv`

##########################################################################################
# Wrangle data as needed - combine multiple words into single column for plotting
##########################################################################################

##############################
# bigrams
##############################

# get lists of bigram dfs
bigram_list <- mget(ls(pattern = "BigramTokens"))

# combine words in bigram dfs
for(i in 1:length(bigram_list)){
  
  # unite separate token cols
  new_table <- bigram_list[[i]] %>% 
    unite(col = token, word1, word2, sep = " ")
  
  # updated exisiting objects
  assign(names(bigram_list)[[i]], new_table)
}

##############################
# trigrams
##############################

# get list of trigram dfs
trigram_list <- mget(ls(pattern = "TrigramTokens"))

# combine words in trigram dfs
for(i in 1:length(trigram_list)){
  
  # unite separate token cols
  new_table <- trigram_list[[i]] %>% 
    unite(col = token, word1, word2, word3, sep = " ")
  
  # updated exisiting objects
  assign(names(trigram_list)[[i]], new_table)
}

##########################################################################################
# Create token frequency plots 
##########################################################################################

##############################
# create plots & save to global environment
##############################

# get updated list of all dfs
my_list <- mget(ls(pattern = glob2rx("*Tokens")))

# plot
for(i in 1:length(my_list)){
  
  plot_title_name <- names(my_list[i])
  print(plot_title_name)
  plot_name <- gsub("Tokens", "_plot", plot_title_name)
  print(plot_name)
    
  freq_plot <- my_list[[i]] %>% 
    head(20) %>% 
    mutate(token = reorder(token, n)) %>% 
    rename(Counts = n) %>% 
    ggplot(aes(token, Counts)) +
    geom_col() + 
    ggtitle(plot_title_name) +
    xlab(NULL) +
    scale_y_continuous(expand = c(0,0)) +
    coord_flip() +
    theme_linedraw() 
  
  plot(freq_plot)
  
  assign(plot_name, freq_plot, envir = .GlobalEnv)
  
}

##############################
# combine figure panels and save
##############################

individualToken_plot <- titleIndiv_plot + keywordsIndiv_plot + abstractIndiv_plot
bigramToken_plot <- titleBigram_plot + keywordsBigram_plot + abstractBigram_plot
trigramToken_plot <- titleTrigram_plot + keywordsTrigram_plot + abstractTrigram_plot
allTokens_plot <- (titleIndiv_plot + keywordsIndiv_plot + abstractIndiv_plot) / (titleBigram_plot + keywordsBigram_plot + abstractBigram_plot) / (titleTrigram_plot + keywordsTrigram_plot + abstractTrigram_plot)
  
# ggsave(filename = here::here("figures", "TokenCounts_plot.png"), plot = allTokens_plot, height = 12, width = 15)

# title: Plotting Token/ngram Frequencies
# author: "Sam Csik"
# date created: "2020-09-16"
# date edited: "2020-09-22"
# packages updated: __
# R version: __
# input: "data/text_mining/filtered_token_counts/*"
# output: "figures/token_frequencies/*"

#########################################################################################
# Summary
##########################################################################################

# this script: 
  # (a) wrangles data to prepare for plotting (i.e. combines tokens into single col) 
  # (b) plots term frequencies arranged by Counts 
  # (c) plots term frequencies arranged alphabetically
# there are A LOT of pdfs generated, and not all are readable (i.e. pdf dimensions need to be expanded for some) -- use the functions below to regenerate and re-save any particular plots as needed

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
  import_filteredTokenCounts(file_name)
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
# Create token frequency plots (arranged by Counts)
# 1) create separate plots
# 2) combine plots into single, multi-panel plot using the patchwork package
##########################################################################################

##############################
# create plots & save to global environment
##############################

# get updated list of all dfs
wrangledTokens_list <- mget(ls(pattern = glob2rx("*Tokens")))

# plot
for(i in 1:length(wrangledTokens_list)){
  obj <- wrangledTokens_list[i]
  df <- obj[[1]]
  name <- names(obj)
  print(name)
  create_frequencyByCount_plot(tokens_df = df, df_name = name)
  
}

##############################
# combine figure panels and save
##############################

# title, keywords, abstract plots
tka_indivToken_plot <- titleIndiv_plot | keywordsIndiv_plot | abstractIndiv_plot
tka_bigramToken_plot <- titleBigram_plot | keywordsBigram_plot | abstractBigram_plot
tka_trigramToken_plot <- titleTrigram_plot + keywordsTrigram_plot + abstractTrigram_plot
tka_allTokens_plot <- (tka_indivToken_plot) / (tka_bigramToken_plot) / (tka_trigramToken_plot)

# entity & attribute plots
ea_indivToken_plot <- entityNameIndiv_plot | attributeNamesIndiv_plot | attributeLabelsIndiv_plot | attributeDefinitionIndiv_plot
ea_bigramToken_plot <- entityNameBigram_plot | plot_spacer() | attributeLabelBigram_plot | attributeDefinitionBigram_plot
ea_trigramToken_plot <- entityNameTrigram_plot | plot_spacer() | attributeLabelTrigram_plot | attributeDefinitionTrigram_plot
ea_allTokens_plot <- (ea_indivToken_plot) / (ea_bigramToken_plot) / (ea_trigramToken_plot)

ggsave(filename = here::here("figures", "token_frequencies", "titleKeywordsAbstractTokenCounts_top50_plot.png"), plot = tka_allTokens_plot, height = 25, width = 20)
# ggsave(filename = here::here("figures", "token_frequencies", "entityAttributeTokenCounts_top50_plot.png"), plot = ea_allTokens_plot, height = 25, width = 25)

##########################################################################################
# Create token frequency plots (arranged alphabetically)
##########################################################################################

# get list of wrangled token dfs
wrangledTokens_list <- mget(ls(pattern = glob2rx("*Tokens")))

# generate pdfs
for(i in 1:length(wrangledTokens_list)){
  obj <- wrangledTokens_list[i]
  df <- obj[[1]]
  name <- names(obj)
  print(name)
  processAll_frequencyByLetter_plots(df = df, df_name = name)
}

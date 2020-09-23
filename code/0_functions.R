# title: Custom Functions for Data Wrangling & Plotting
# author: "Sam Csik"
# date created: "2020-09-22"
# date edited: "2020-09-22"
# packages updated: __
# R version: __
# input: NA
# output: NA

#-----------------------------
# used in script: "4_plot_token_frequencies.R"
# function to import filtered token count dfs generated in script 3 
  # takes arguments:
    # file_name: name of .csv file located at "data/text_mining/filtered_token_counts/*"
#-----------------------------

import_filteredTokenCounts <- function(file_name) {
  
  # create object name
  object_name <- basename(all_files[i])
  object_name <- gsub("2020-09-21.csv", "", object_name)
  object_name <- gsub("2020-09-13.csv", "", object_name) # for attributeNames & Definitions (have different date than rest)
  object_name <- gsub("filteredCounts_", "", object_name)
  print(object_name)
  
  # read in data
  my_file <- read_csv(here::here("data", "text_mining", "filtered_token_counts", file_name)) 
  
  # save as object_name
  assign(object_name, my_file, envir = .GlobalEnv)
}

#-----------------------------
# used in script: "4_plot_token_frequencies.R"
# function to combine separate term columns for bigram dfs into single "token" column
  # takes arguments:
    # object: *Tokens object in global environment, with class df
    # object_name: *Tokens object name from global environment, as character_string
#-----------------------------

combine_bigrams <- function(object, object_name){
  
  # unite separate token cols
  new_table <- object %>%
    unite(col = token, word1, word2, sep = " ")
  
  # updated existing objects
  assign(object_name, new_table, envir = .GlobalEnv) 
}

#-----------------------------
# used in script: "4_plot_token_frequencies.R"
# function to combine separate term columns for trigram dfs into single "token" column
  # takes arguments:
    # object: *Tokens object in global environment, with class df
    # object_name: *Tokens object name from global environment, as character_string
#-----------------------------

combine_trigrams <- function(object, object_name){
  
  # unite separate token cols
  new_table <- object %>%
    unite(col = token, word1, word2, word3, sep = " ")
  
  # updated existing objects
  assign(object_name, new_table, envir = .GlobalEnv) 
}

#-----------------------------
# used in script: "4_plot_token_frequencies.R"
# function to create frequency plots, where terms are arranged by Counts
  # takes arguments:
    # tokens_df:
    # df_name: 
#-----------------------------

create_frequencyByCount_plot <- function(tokens_df, df_name) {
  
  # generate plot object name
  plotObjectName <- gsub("Tokens", "_plot", df_name)
  print(plotObjectName)
  
  # create plot that displays 50 most frequent terms
  freq_plot <- tokens_df %>%
    head(50) %>%
    mutate(token = reorder(token, n)) %>%
    rename(Counts = n) %>%
    ggplot(aes(token, Counts)) +
    geom_col() +
    ggtitle(df_name) +
    xlab(NULL) +
    scale_y_continuous(expand = c(0,0)) +
    coord_flip() +
    theme_linedraw()
  
  plot(freq_plot)
  
  # assign to object name in global environment
  assign(plotObjectName, freq_plot, envir = .GlobalEnv)
}

#-----------------------------
# used in script: "4_plot_token_frequencies.R"
# function to create frequency plots, where terms are arranged alphabetically
  # takes arguments:
    # tokens_df:
    # letter_lowercase: 
    # df_name:
#-----------------------------

create_frequencyByLetter_plot <- function(tokens_df, letter_lowercase, df_name){ 
  
  # generate plot title & object name
  plotObjectName <- gsub("Tokens", "Alphabet_plot", df_name)
  print(plotObjectName)
  
  # create plot that displays 50 most frequent terms
  freqByLetter_plot <- tokens_df %>% 
    arrange(token) %>% 
    rename(Counts = n) %>% 
    filter(str_detect(token, paste("^", letter_lowercase, sep = ""))) %>% 
    ggplot(aes(token, Counts)) +
    geom_col() + 
    ggtitle(df_name) + 
    xlab(NULL) +
    scale_y_continuous(expand = c(0,0)) +
    coord_flip() +
    theme_linedraw()
  
  plot(freqByLetter_plot)
}

#-----------------------------
# used in script: "4_plot_token_frequencies.R"
# function that applies `create_frequencyByLetter_plot()` to df for all 26 letters of the alphabet
  # takes arguments:  
    # df:
    # df_name:
#-----------------------------

processAll_frequencyByLetter_plots <- function(df, df_name){
  
  print("----------------")
  print("Starting new PDF")
  print(df_name)
  
  pdf(here::here("figures", "token_frequencies", "alphabetized", paste(df_name, Sys.Date(), "ALPHABETIZED.pdf")), onefile = TRUE, width = 20, height = 35) 
  for(i in 1:length(letters)){
    my_letter <- letters[[i]]
    print(my_letter)
    create_frequencyByLetter_plot(df, my_letter, name)
  }
  dev.off() 
}


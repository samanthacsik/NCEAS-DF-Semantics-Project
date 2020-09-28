# used to unnest individual tokens, filter out stop words & NAs, recombine columns, and calculate token counts 
tidyTokens_unnestCleanCounts <- function(my_input, split) {
  my_query %>%
    select(identifier, my_input) %>%
    unnest_tokens(output = ngram, input = !!my_input, token = "ngrams", n = split) %>%
    separate(ngram, into = c("word1", "word2", "word3"), sep = " ") %>% 
    filter(!word1 %in% stop_words$word, !word2 %in% stop_words$word, !word3 %in% stop_words$word) %>% 
    filter(word1 != "NA", word2 != "NA", word3 != "NA") %>% 
    # group_by(identifier) %>%
    # distinct(word, .keep_all = TRUE) %>%
    # ungroup() %>%
    count(word1, word2, word3, sort = TRUE) %>% 
    unite(col = ngram, word1, word2, word3, sep = " ")
}

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


# functions

# indiv
filterCount_indivTokens <- function(file_name) {
  
  # create object name
  object_name <- basename(file_name)
  object_name <- gsub(".csv", "", object_name)
  object_name <- gsub("unnested_", "filteredCounts_", object_name)
  print(object_name)
  
  # wrangle data
  my_file <- read_csv(here::here("data", "text_mining", "unnested_tokens", file_name)) %>% 
    rename(token = word1) %>% # comes in handy in script 4
    select(identifier, token) %>% 
    filter(!token %in% stop_words$word, token != "NA") %>% 
    count(token, sort = TRUE)
  
  # save as object_name
  assign(object_name, my_file, envir = .GlobalEnv)
}

# bigrams
filterCount_bigramTokens <- function(file_name) {
  
  # create object name
  object_name <- basename(file_name)
  object_name <- gsub(".csv", "", object_name)
  object_name <- gsub("unnested_", "filteredCounts_", object_name)
  print(object_name)
  
  # wrangle data
  my_file <- read_csv(here::here("data", "text_mining", "unnested_tokens", file_name)) %>% 
    select(identifier, word1, word2) %>% 
    filter(!word1 %in% stop_words$word, !word2 %in% stop_words$word) %>% 
    filter(word1 != "NA", word2 != "NA") %>% 
    count(word1, word2, sort = TRUE)
  
  # save as object_name
  assign(object_name, my_file, envir = .GlobalEnv)
}

# trigrams
filterCount_trigramTokens <- function(file_name) {
  
  # create object name
  object_name <- basename(file_name)
  object_name <- gsub(".csv", "", object_name)
  object_name <- gsub("unnested_", "filteredCounts_", object_name)
  print(object_name)
  
  # wrangle data
  my_file <- read_csv(here::here("data", "text_mining", "unnested_tokens", file_name)) %>% 
    select(identifier, word1, word2, word3) %>% 
    filter(!word1 %in% stop_words$word, !word2 %in% stop_words$word, !word3 %in% stop_words$word) %>% 
    filter(word1 != "NA", word2 != "NA", word3 != "NA") %>% 
    count(word1, word2, word3, sort = TRUE)
  
  # save as object_name
  assign(object_name, my_file, envir = .GlobalEnv)
}
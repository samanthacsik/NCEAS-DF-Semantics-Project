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

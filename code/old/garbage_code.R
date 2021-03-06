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

##########################################################################################
# Create 3D plots of term counts, unique_id, unique_author values 
##########################################################################################

scatter3D(x = abstractBigramTokens$unique_ids, 
          y = abstractBigramTokens$unique_authors, 
          z = abstractBigramTokens$n,
          bty = "g",
          phi = 0,
          ticktype = "detailed",
          main = "ADC Abstract Bigrams",
          xlab = "# of unique identifiers", 
          ylab = "# of unique authors",
          zlab = "Bigram Counts",
          clab = "Bigram Counts")


# scatter3D(x = abstractIndivTokens$unique_ids, 
#           y = abstractIndivTokens$unique_authors, 
#           z = abstractIndivTokens$n,
#           bty = "g",
#           phi = 0,
#           main = "ADC Abstract Individual Tokens",
#           xlab = "# of unique identifiers", 
#           ylab = "# of unique authors",
#           zlab = "Individual Token Counts",
#           clab = "Individual Token Counts")

text3D(x = abstractIndivTokens$unique_ids, 
       y = abstractIndivTokens$unique_authors, 
       z = abstractIndivTokens$n,
       colvar = abstractIndivTokens$n,
       labels = abstractIndivTokens$token,
       cex = 0.7,
       bty = "g",
       phi = 0,
       main = "ADC Abstract Individual Tokens",
       xlab = "# of unique identifiers", 
       ylab = "# of unique authors",
       zlab = "Individual Token Counts",
       clab = c("Individual", "Token Counts"))

# display axis ranges
getplist()[c("xlim","ylim","zlim")] 

# zoom in 
plotdev(xlim = c(500, 2000), ylim = c(200, 839), 
        zlim = c(1, 5000))




##########################################################################################
# Create bubble plots of term counts, unique_id, unique_author values 
##########################################################################################

# first rendition bubble plot
# plot_name <- ggplot(abstractIndivTokens, aes(x = n, y = unique_ids, size = unique_authors, label = token)) +
#   geom_text_repel(data = subset(abstractIndivTokens, unique_authors > 300),
#                   nudge_y = 2500, nudge_x = 5000, segment.size = 0.2, segment.color = "grey50", direction = "x") +
#   geom_point(color = ifelse(abstractIndivTokens$unique_authors > 300, "red", "black"), alpha = 0.4, shape = 21) +
#   scale_size(range = c(0.01, 10), name = "# of Unique First Authors") +
#   labs(x = "Individual Token Counts",
#        y = "# of Unique Identifiers",
#        title = "Abstract Terms (Individual Tokens)",
#        caption = "Red points signify terms that are used by more than 300 unique first authors.") +
#   theme_light() +
#   theme(legend.position = "bottom",
#         plot.caption = element_text(size = 10, hjust = 1, color = "darkgray", face = "italic"))
# plot_name

#-------------------------------------------------------

# TEST_PLOT <- ggplot(TEST, aes(x = weighted_n, y = weighted_ids, label = token)) +
#   geom_point() +
#   coord_cartesian(xlim=c(0,50), ylim = c(0, 35)) +
#   geom_text_repel(data = TEST, size = 3,
#                   nudge_y = 10, nudge_x = 10, segment.size = 0.1, segment.color = "grey50", direction = "y") 
# 
# TEST_PLOT
#-------------------------------------------------------

# individual keywords
# create_termCounts_byAuthorAndID_plot(keywordsIndivTokens, "Keywords", "Individual", 100, 0, 200)
# FILTERED_create_termCounts_byAuthorAndID_plot(keywordsIndivTokens, "Keywords", "Individual", 100, 0, 1000)


# filtered n > 100
FILTERED_create_termCounts_byAuthorAndID_plot <- function(df, field_name, ngram, AuthorGreaterThanValue, nudgeX, nudgeY){ 
  
  # generate plot object name
  plotObjectName <- gsub("Tokens", "_BubblePlot", df)
  print(plotObjectName)
  
  # discard any terms with n <= 10
  df_filtered <- df %>% 
    filter(n > 100)
  
  # create plot
  termCounts_byAuthorAndID_plot <- ggplot(df_filtered, aes(x = n, y = unique_ids, size = unique_authors, label = token)) +
    geom_text_repel(data = subset(df_filtered, unique_authors > AuthorGreaterThanValue),
                    nudge_x = nudgeX, nudge_y = nudgeY, segment.size = 0.2, segment.color = "grey50", direction = "x") +
    geom_point(color = ifelse(df_filtered$unique_authors > AuthorGreaterThanValue, "red", "black"), alpha = 0.4, shape = 21) +
    scale_size(range = c(0.01, 10), name = "# of Unique First Authors") +
    labs(x = "Term Counts",
         y = "# of Unique Identifiers",
         title = paste(field_name, "Terms -", ngram, "Tokens"), 
         caption = paste("Red points signify terms that are used by more than", AuthorGreaterThanValue, "unique first authors")) +
    theme_light() +
    theme(legend.position = "bottom",
          plot.caption = element_text(size = 10, hjust = 1, color = "darkgray", face = "italic"))
  
  plot(termCounts_byAuthorAndID_plot)
}
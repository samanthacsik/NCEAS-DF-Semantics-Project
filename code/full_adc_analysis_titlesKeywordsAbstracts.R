##############################
# Load packages
##############################

library(tidyverse)
library(tidytext)
library(widyr)
library(igraph)
library(ggraph)

##############################
# Load data
##############################

my_query <- read_csv(here::here("data", "queries", "fullQuery_titleKeywordsAbstract2020-09-15.csv"))

##############################
# Get separate dfs for titles, keywords, abstracts; unnest and remove stop words
##############################

adc_titles <- my_query %>% 
  select(identifier, title) %>% 
  unnest_tokens(word, title) %>% 
  anti_join(stop_words)

adc_keywords <- my_query %>% 
  select(identifier, keywords) %>% 
  unnest_tokens(word, keywords) %>% 
  anti_join(stop_words) %>% 
  anti_join(my_stopwords) %>% 
  anti_join(my_stopwords)

adc_abstracts <- my_query %>% 
  select(identifier, abstract) %>% 
  unnest_tokens(word, abstract) %>% 
  anti_join(stop_words) %>% 
  anti_join(my_stopwords)


##############################
# Initial exploration - counts per word?
##############################

adc_title_counts <- adc_titles %>% 
  count(word, sort = TRUE)

adc_keyword_counts <- adc_keywords %>% 
  count(word, sort = TRUE)

adc_abstract_counts <- adc_abstracts %>% 
  count(word, sort = TRUE)

##############################
# Make list of custom stop words to remove
##############################

my_stopwords <- tibble(word = c(as.character(1:10)))

##############################
# Remove custom stop words (also go back and remove these from original dfs)
##############################

adc_title_counts <- adc_title_counts %>% 
  anti_join(my_stopwords)

adc_keyword_counts <- adc_keyword_counts %>% 
  anti_join(my_stopwords)

adc_abstract_counts <- adc_abstract_counts %>% 
  anti_join(my_stopwords)

##############################
# Word co-occurrences and correlations
# find pairs of words that occur most frequently together in title, keyword, or abstract fields
##############################

title_word_pairs <- adc_titles %>% 
  pairwise_count(word, identifier, sort = TRUE, upper = FALSE)

keyword_word_pairs <- adc_keywords %>% 
  pairwise_count(word, identifier, sort = TRUE, upper = FALSE)

abstract_word_pairs <- adc_abstracts %>% 
  pairwise_count(word, identifier, sort = TRUE, upper = FALSE)

##############################
# Plot networks of co-occurring words
# Asks question: Which keyword pairs occur most often
##############################

# titles
set.seed(2000)
title_word_pairs %>% 
  filter(n >= 150) %>% 
  graph_from_data_frame() %>% 
  ggraph(layout = "fr") +
  geom_edge_link(aes(edge_alpha = n, edge_width = n), edge_color = "cyan4") +
  geom_node_point(size = 5) +
  geom_node_text(aes(label = name), repel = TRUE, point.padding = unit(0.2, "lines")) +
  theme_void()

# keywords
set.seed(2000)
keyword_word_pairs %>% 
  filter(n >= 300) %>% 
  graph_from_data_frame() %>% 
  ggraph(layout = "fr") +
  geom_edge_link(aes(edge_alpha = n, edge_width = n), edge_color = "darkorchid4") +
  geom_node_point(size = 5) +
  geom_node_text(aes(label = name), repel = TRUE, point.padding = unit(0.2, "lines")) +
  theme_void()

# abstracts
set.seed(2000)
abstract_word_pairs %>% 
  filter(n >= 400) %>% 
  graph_from_data_frame() %>% 
  ggraph(layout = "fr") +
  geom_edge_link(aes(edge_alpha = n, edge_width = n), edge_color = "darkred") +
  geom_node_point(size = 5) +
  geom_node_text(aes(label = name), repel = TRUE, point.padding = unit(0.2, "lines")) +
  theme_void()

##############################
# Find correlation among co-occurring words (e.g. keywords that are more likely to occur together than with other keywords for a dataset)
# Asks question: Which keywords occur most often together than with other keywords
##############################

# calculate 
keyword_cors <- adc_keywords %>% 
  group_by(word) %>% 
  filter(n() >= 50) %>% 
  pairwise_cor(word, identifier, sort = TRUE, upper = FALSE)

# visualize network of correlations
set.seed(2000)
keyword_cors %>% 
  filter(correlation > 0.6) %>% 
  graph_from_data_frame() %>% 
  ggraph(layout = "fr") + 
  geom_edge_link(aes(edge_alpha = correlation, edge_width = correlation, edge_color = "darkorchid4")) +
  geom_node_point(size = 5) +
  geom_node_text(aes(label = name), repel = TRUE, point.padding = unit(0.2, "lines")) +
  theme_void()

##############################
# Calcualte tf-idf for abstracts (i.e. identify words that are especially important to a document within a collection of documents)
# here, consider each abstract field a document and the whole set of abstract fields as the collection/corpus of documents
##############################

# most important words in the abstract fields as measured by tf-idf, meaning they are common, but not too common
abstract_tf_idf <- adc_abstracts %>% 
  count(identifier, word, sort = TRUE) %>% 
  ungroup() %>% 
  bind_tf_idf(word, identifier, n) %>% 
  arrange(-tf_idf)

# NOTE: if `n` and `tf` both = 1 then these were abstracts that only had a single word in them (makign the tf-idf algorithm think that it is a very important word); might want to throw these out later



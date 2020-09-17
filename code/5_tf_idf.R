##########################################################################################
# Summary
##########################################################################################

# This script uses the tidytext package analyze term frequency in abstracts using the tf-idf method
# tf-idf is a numerical statistic that is intended to reflect how important a word is to a document in a collection or corpus
# The tf–idf value increases proportionally to the number of times a word appears in the document and is offset by the number of documents in the corpus that contain the word, which helps to adjust for the fact that some words appear more frequently in general
# Calculating tf_idf attempts to find the words that are important (i.e. common) in a text, but not too commmon
# I'm only applying this method to abstracts, as they occur in sentence format (unlike keywords)

##########################################################################################
# General Setup
##########################################################################################

##############################
# Load packages
##############################

library(tidytext)
library(tidyverse)

##########################################################################################
# exploring abstract data using tf_idf
##########################################################################################

# abstract individual token frequency 
abstract_id_words <- read_csv(here::here("data", "text_mining", "unnested_tokens", "unnested_abstractIndivTokens2020-09-15.csv")) %>% 
  select(identifier, word1) %>% 
  count(identifier, word1, sort = TRUE)

# summarize total number of words across abstracts
total_abstract_words <- abstract_id_words %>% 
  group_by(identifier) %>% 
  summarize(total = sum(n))

# join dfs 
abstract_words <- left_join(abstract_id_words, total_abstract_words)

# plot frequency distribution -- this distribution is very typical in language (Zipf's law: the frequency that a word appears is inversely proportional to its rank)
# subset random identifier to demonstrate (too many to plot!)
# subset <- abstract_words %>% filter(identifier == "doi:10.18739/A2W950P06")

# ugh whatever can't get to work???
# ggplot(subset, aes(n/total)) +
#   geom_histogram(show.legend = FALSE) +
#   xlim(NA, 0.001075)

# calculate term frequency by rank
abstract_freq_by_rank <- abstract_words %>% 
  group_by(identifier) %>% 
  mutate(rank = row_number(), 
         `term frequency` = n/total)

# plot frequency by rank on log scale (common for visualizing Zipf's law) for each identifier
# ggplot(abstract_freq_by_rank, aes(rank, `term frequency`, color = identifier)) + 
#   geom_line(size = 1.1, alpha = 0.8, show.legend = FALSE) + 
#   scale_x_log10() +
#   scale_y_log10()

# negative slope, but not constant; view instead as broken power law
# subset middle section
rank_subset <- abstract_freq_by_rank %>% 
  filter(rank < 500,
         rank > 10)

# # exponent of middle section
# lm(log10(`term frequency`) ~ log10(rank), data = rank_subset)
# 
# # plot fitted power law with data
# ggplot(data = abstract_freq_by_rank, aes(rank, `term frequency`, color = identifier)) + 
#   geom_line(size = 1, alpha = 0.4, show.legend = FALSE) + 
#   geom_abline(intercept = -0.8379, slope = -0.7834, color = "black", linetype = 2, size = 1.1) +
#   scale_x_log10() +
#   scale_y_log10()

# use bind_tf_idf to find important words 
# NOTE: 0s represent words found in ALL documents (i.e. identifiers)
abstract_words <- abstract_words %>% 
  filter(word1 != "na") %>% 
  bind_tf_idf(term = word1, document = identifier, n = n)

inverse_abstract_words <- abstract_words %>%
  select(-total) %>%
  arrange(desc(tf_idf))


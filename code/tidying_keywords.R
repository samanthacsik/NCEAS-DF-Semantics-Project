##########################################################################################
# Summary
##########################################################################################

# 1) tidy & plot individual tokens from keywords
# 2) tidy & plot bigram tokens from keywords
# 3) tidy & plot trigram tokens from keywords
# * save all as .csvs for use in other scripts
# Using this awesome resource: https://www.tidytextmining.com/

##############################
# Load packages
##############################

library(tidyverse)
library(tidytext)

##############################
# Upload data
##############################

my_query <- read_csv(here::here("data", "queries", "fullQuery_titleKeywordsAbstract2020-09-15.csv"))

##############################
# Wrangle & plot INDIVIDUAL keywords data 
  # unnest INDIVIDUAL tokens, remove stop_words, filter out repeated keywords by identifier, get counts, plot
############################## 

# extremely common words to be removed 
data(stop_words)

# tidy data
tidyToken_individuals <- my_query %>% 
  select(identifier, keywords) %>% 
  unnest_tokens(output = word, input = keywords) %>% 
  anti_join(stop_words) %>% 
  group_by(identifier) %>% 
  distinct(word, .keep_all = TRUE) %>% 
  ungroup()

# count word frequencies
individualToken_counts <- tidyToken_individuals %>% 
  count(word, sort = TRUE)

# write.csv(individualToken_counts, here::here("data", "text_mining", "keywords", "filtered_counts", paste("individualToken_counts", Sys.Date(), ".csv", sep = "")), row.names = FALSE)

# plot
individualToken_plot <- individualToken_counts %>% 
  filter(n > 300) %>% 
  filter(word != "NA") %>% 
  mutate(word = reorder(word, n)) %>% 
  rename(Counts = n) %>% 
  ggplot(aes(word, Counts)) +
  geom_col() + 
  xlab(NULL) +
  scale_y_continuous(expand = c(0,0)) +
  coord_flip() +
  theme_linedraw()

individualToken_plot

##############################
# Wrangle & plot BIGRAM keywords data
  # unnest BIGRAM tokens, remove stop_words, get counts, plot
############################## 

# tidy data
tidyBigrams <- my_query %>% 
  select(identifier, keywords) %>% 
  unnest_tokens(output = bigram, input = keywords, token = "ngrams", n = 2)

# separate bigrams into 2 cols
bigramToken_separated <- tidyBigrams %>% 
  separate(bigram, c("word1", 'word2'), sep = " ") 

# filter out stop words
bigramToken_filtered <- bigramToken_separated %>%   
  filter(!word1 %in% stop_words$word) %>% 
  filter(!word2 %in% stop_words$word) %>% 
  filter(word1 != "NA",
         word2 != "NA")

# count bigram frequencies
bigramToken_counts <- bigramToken_filtered %>% 
  count(word1, word2, sort = TRUE)

# write.csv(bigramToken_counts, here::here("data", "text_mining", "keywords", "filtered_counts", paste("bigramToken_counts", Sys.Date(), ".csv", sep = "")), row.names = FALSE)

# recombine bigrams into single col for plotting
bigramToken_united_counts <- bigramToken_counts  %>% 
  unite(col = bigram, word1, word2, sep = " ")

# plot
bigramToken_plot <- bigramToken_united_counts %>% 
  filter(n > 400) %>% 
  mutate(bigram = reorder(bigram, n)) %>% 
  rename(Counts = n) %>% 
  ggplot(aes(bigram, Counts)) +
  geom_col() + 
  xlab(NULL) +
  scale_y_continuous(expand = c(0,0)) +
  coord_flip() +
  theme_linedraw()

bigramToken_plot

##############################
# Wrangle & plot TRIGRAM keywords data
  # unnest TRIGRAM tokens, remove stop_words, get counts, plot
############################## 

# tidy data, unnest trigrams, remove stop words, get counts
tidyTrigrams <- my_query %>% 
  select(identifier, keywords) %>% 
  unnest_tokens(output = trigram, input = keywords, token = "ngrams", n = 3) %>% 
  separate(trigram, c("word1", "word2", "word3"), sep = " ") %>% 
  filter(!word1 %in% stop_words$word,
         !word2 %in% stop_words$word,
         !word3 %in% stop_words$word) %>% 
  count(word1, word2, word3, sort = TRUE) %>% 
  filter(word1 != "NA", word2 != "NA", word3 != "NA")

# write.csv(tidyTrigrams, here::here("data", "text_mining", "keywords", "filtered_counts", paste("trigramToken_counts", Sys.Date(), ".csv", sep = "")), row.names = FALSE)

# recombine trigrams into single col for plotting
trigramToken_united_counts <- tidyTrigrams  %>% 
  unite(col = trigram, word1, word2, word3, sep = " ")

# plot
trigramToken_plot <- trigramToken_united_counts %>% 
  filter(n > 350) %>% 
  mutate(trigram = reorder(trigram, n)) %>% 
  rename(Counts = n) %>% 
  ggplot(aes(trigram, Counts)) +
  geom_col() + 
  xlab(NULL) +
  scale_y_continuous(expand = c(0,0)) +
  coord_flip() +
  theme_linedraw()

trigramToken_plot

############################## 
# save unfiltered data (i.e. no stop_word or repeated string removal) as .csv for future analyses; these keep ngrams separated into individual cols
############################## 

# individual tokens
individualTokens <- my_query %>%
  select(identifier, keywords) %>%
  unnest_tokens(output = word, input = keywords)

# write.csv(individualTokens, here::here("data", "text_mining", "keywords", "separated_tokens", paste("individualTokens", Sys.Date(), ".csv", sep = "")), row.names = FALSE)

# bigrams (already wrangled above as "bigramToken_separated" df)
# write.csv(bigramToken_separated, here::here("data", "text_mining", "keywords", "separated_tokens", paste("bigramTokens", Sys.Date(), ".csv", sep = "")), row.names = FALSE)

# trigrams
trigramTokens <- my_query %>%
  select(identifier, keywords) %>%
  unnest_tokens(output = trigram, input = keywords, token = "ngrams", n = 3) %>%
  separate(trigram, c("word1", "word2", "word3"), sep = " ")

# write.csv(trigramTokens, here::here("data", "text_mining", "keywords", "separated_tokens", paste("trigramTokens", Sys.Date(), ".csv", sep = "")), row.names = FALSE)


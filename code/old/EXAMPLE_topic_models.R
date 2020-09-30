# title: EXAMPLE - Topic Modeling using Latent Dirichlet allocation
# author: "Sam Csik"
# date created: "2020-09-23"
# date edited: "2020-09-23"
# packages updated: __
# R version: __
# input: 
# output: 

##########################################################################################
# Summary
##########################################################################################

# topic modeling using Latent Dirichlet allocation following example in Text Mining with R, Ch. 6
# one advantage of this method over "hard clustering" methods is that is allows for word overlap among topics (as is common in natural language)

##########################################################################################
# General Setup
##########################################################################################

##############################
# Load packages
##############################

library(topicmodels)
library(tidytext)
library(tidyverse)

##############################
# Load data
##############################

data("AssociatedPress")

##########################################################################################
# Ch 5.1.1
##########################################################################################


data("AssociatedPress", package = "topicmodels")
AssociatedPress

ap_td <- tidy(AssociatedPress) # cols: document, term, count

##########################################################################################
# Ch 6.1
##########################################################################################

# create two-topic LDA model
ap_lda <- LDA(AssociatedPress, k = 2, control = list(seed = 1234))
ap_lda

# use tidy() to extract per-topic-per-word probabilities (beta) from the model
ap_topics <- tidy(ap_lda, matrix = "beta")
ap_topics

# find top 10 terms that are most common within each topic
ap_top_terms <- ap_topics %>% 
  group_by(topic) %>% 
  top_n(10, beta) %>% 
  ungroup() %>% 
  arrange(topic, -beta)

# plot suggests topic 1 is likely about financial news; topic 2 is likely about political news
ap_top_terms %>% 
  mutate(term = reorder_within(term, beta, topic)) %>% 
  ggplot(aes(term, beta, fill = factor(topic))) +
  geom_col(show.legend = FALSE) +
  facet_wrap(~topic, scales = "free") +
  coord_flip() + 
  scale_x_reordered()

# alternatively, consider terms hat had the greatest difference in beta between topics
beta_spread <- ap_topics %>% 
  mutate(topic = paste0("topic", topic)) %>% 
  spread(topic, beta) %>% 
  filter(topic1 > 0.001 | topic2 > 0.001) %>% 
  mutate(log_ratio = log2(topic2/topic1))

beta_spread

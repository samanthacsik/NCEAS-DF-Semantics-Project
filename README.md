# NCEAS-DF-Semantics-Project

### Repository Structure

```
NCEAS-DF-Semantics-Project
  |_code
    |_old
  |_data
    |_attributes_query_eatocsv
      |_extracted_attributes
        |_fullQuery2020-09-13
          |_xml
      |_identifiers
    |_queries
    |_text_mining
      |_filtered_token_counts
      |_unnested_tokens
```

### Software

These analyses were performed in R (version ?) on the datateam server (NCEAS)

### Code

* `1a_queries.R`: uses solr query to extract package identifiers, titles, keywords, abstracts from ADC data holdings
* `1b_download_EA_metadata_by_identifier.R` : uses package identifiers to extract attribute-level information from ADC data holdings and returns data in tidy format (one attribute per row)
* `2_unnest_tokens.R`: uses the [tidytext](https://www.tidytextmining.com/) [package](https://www.rdocumentation.org/packages/tidytext/versions/0.2.5) to separate titles, keywords, and abstracts into individual tokens, bigrams, and trigrams
* `3_filterStopWords_count_tokens.R`: removes stop_words (commonly used words from established lexicons) and missing rows of information (NAs); calculates frequency counts of title, keyword, abstract, and attributeName tokens
* `4_plot_token_frequencies.R` : visualizes token/ngram frequencies (top 20)
* `5_ngram_word_associations.R`: visualizes word associations using igraph package (currently just abstract bigrams)

### Data
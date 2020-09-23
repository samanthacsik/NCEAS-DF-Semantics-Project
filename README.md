# NCEAS-DF-Semantics-Project

* **Contributors:** Samantha Csik
* **Contact:** scsik@nceas.ucsb.edu

### Overview

In order to improve data discoverablity within the Arctic Data Center, we are beginning to incorporate semantic annotations into the data curation process. A current need is to evaluate metadata across the ADC's data holdings for commonly used (and perhaps "semantically important") terms, which may provide useful for constructing and/or expanding upon currently referenced ontologies.

This repository provides code for:

  * querying Arctic Data Center datapackage metadata (titles, keywords, abstracts, and entity- & attribute-level information)
  * text mining and data wrangling necessary for extracting commonly used (and perhaps "semantically important") terms across various metadata fields
  * visualizing term frequencies

### Getting Started

Scripts are numbered in the order they are to be run.

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
   |_figures
```

### Software

These analyses were performed in R (version ?) on the datateam.nceas.ucsb.edu server.

### Code

* `0_functions.R`: custom functions for data wrangling & plotting; information regarding function purpose and arguments is included in the script 
* `1a_queries.R`: uses solr query to extract package identifiers, titles, keywords, abstracts from ADC data holdings
* `1b_download_EA_metadata_by_identifier.R` : uses package identifiers to extract attribute-level information from ADC data holdings and returns data in tidy format (one attribute per row)
* `2_unnest_tokens.R`: uses the [tidytext](https://www.tidytextmining.com/) [package](https://www.rdocumentation.org/packages/tidytext/versions/0.2.5) to separate titles, keywords, and abstracts into individual tokens, bigrams, and trigrams
* `3_filterStopWords_count_tokens.R`: removes stop_words (commonly used words from established lexicons) and missing rows of information (NAs); calculates term (individual word, bigram, trigram) frequency counts
* `4_plot_token_frequencies.R` : visualizes term frequencies (top 20)
* `5_ngram_word_associations.R`: visualizes word associations using igraph package (currently just abstract bigrams)

### Data

### Acknowledgements

Work on this project was supported by: ...

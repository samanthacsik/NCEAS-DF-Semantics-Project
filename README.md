# NCEAS-DF-Semantics-Project

* **Contributors:** Samantha Csik
* **Contact:** scsik@nceas.ucsb.edu

### Overview

In order to improve data discoverablity within the Arctic Data Center, we are beginning to incorporate semantic annotations into the data curation process. A current need is to evaluate metadata across the ADC's data holdings for commonly used (and perhaps "semantically important") terms, which may provide useful for constructing and/or expanding upon currently referenced ontologies.

This repository provides code for:

  * querying Arctic Data Center datapackage metadata (titles, keywords, abstracts, and entity- & attribute-level information)
  * text mining and data wrangling necessary for extracting commonly used terms across various metadata fields
  * visualizing term frequencies

### Getting Started

Scripts are numbered in the order they are to be run.

### Repository Structure

```
NCEAS-DF-Semantics-Project
  |_code
    |_old
    |_reports
  |_data
   |_ADC_semantic_annotations_review
    |_attributes_query_eatocsv
      |_extracted_attributes
        |_fullQuery2020-09-13
          |_xml
      |_identifiers
    |_queries
     |_old
    |_text_mining
      |_filtered_token_counts
      |_unnested_tokens
      |_weighted_scores
   |_figures
```

### Code

* `0_libraries.R`: packages required in subsequent scripts
* `0_functions.R`: custom functions for data wrangling & plotting; information regarding function purpose and arguments is included in the script 
* `1a_queries.R`: uses solr query to extract package identifiers, titles, keywords, abstracts, authors from ADC data holdings
* `1b_download_EA_metadata_by_identifier.R` : uses package identifiers to extract attribute-level information from ADC data holdings and returns data in tidy format (one attribute per row)
* `2_unnest_tokens.R`: uses the [tidytext](https://www.tidytextmining.com/) [package](https://www.rdocumentation.org/packages/tidytext/versions/0.2.5) to separate titles, keywords, and abstracts into individual tokens, bigrams, and trigrams
* `3_filterStopWords_count_tokens.R`: removes stop_words (commonly used words from established lexicons) and missing rows of information (NAs); calculates term (individual word, bigram, trigram) frequency counts, the number of unique identifiers those terms are found in, and the number of unique authors that use those terms
* `4_plot_token_frequencies.R` : visualizes term frequencies, arranged by count and alphabetically
* `5_calculate_weighted_scores.R`: calculates a single score to represent the "importance" of each term, taking into accout term frequency, prevalence across data packages, and number of unqiue authors using that term

### Data

#### * `data/queries/fullQuery_titleKeywordsAbstractAuthors2020-09-28.csv`:
#### * `data/attributes_query_eatocsv/extracted_attributes/fullQuery2020-09-13_attributes.csv`: 
#### * `data/text_mining/unnested_tokens`: 
#### * `data/text_mining/filtered_token_counts`:
#### * `data/text_mining/weighted_scores`: 

### Software

These analyses were performed in R (version 3.6.3) on the datateam.nceas.ucsb.edu server.

### Acknowledgements

Work on this project was supported by: ...

library(readxl)
library(readr)
library(dplyr)

#Find new samples not reported yet
metadata_epi_new <- read_csv("12.29.21 lineage and clade results.csv")

reported <-
  read_csv("new.Terra.samples.12.29.21.csv",
             col_names = T)

list = anti_join(reported, metadata_epi_new, by = "entity:sample_id")

write.csv(list, "missing_samples.csv")
library(readxl)
library(readr)
library(dplyr)
library(data.table)
library(data.table)
library(readr)



Terra <- fread("sample - 2023-06-11T173241.399.tsv")
lims <- fread("lims_metadata.ALL.csv")

lims_filtered = lims %>% filter(grepl('Nemours|AIDH|AID|AIDUPONT|AIDUP', Description, ignore.case = T))

merged = merge(
  lims_filtered,
  Terra,
  by.y = c("entity:sample_id"),
  by.x = c("Label Id")
)
title_tsv = paste("merged_nemours", Sys.Date(), "tsv", sep = ".")

Terra1 <- Filter(function(x)!all(is.na(x)), as.data.frame(merged)) 
Terra2=Terra1[!grepl("gs://|quay", Terra1)]
View(Terra2)

write_tsv(Terra2, title_tsv)


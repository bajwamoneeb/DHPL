library(readxl)
library(readr)
library(dplyr)
library(data.table)
library(data.table)
library(readr)
library(writexl)


Terra <- read_tsv("sample - 2023-09-12T114655.130.tsv")
#Save as excel file and read in
lims_metadata_ALL <- read_excel("lims_metadata.ALL.xlsx")
lims_filtered = lims_metadata_ALL %>% filter(grepl('Nemours|AIDH|AID|AIDUPONT|AIDUP', Description, ignore.case = T))

merged = merge(
  lims_filtered,
  Terra,
  by.y = c("entity:sample_id"),
  by.x = c("Label Id")
)
title_xlsx = paste("merged_nemours", Sys.Date(), "xlsx", sep = ".")

Terra1 <- Filter(function(x)!all(is.na(x)), as.data.frame(merged)) 
Terra2=Terra1[!grepl("gs://|quay", Terra1)]
View(Terra2)

write_xlsx(Terra2, title_xlsx)


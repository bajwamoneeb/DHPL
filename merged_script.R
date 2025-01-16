library(readxl)
library(readr)
library(dplyr)
library(data.table)
library(writexl)

# Read the Terra data
Terra <- read_tsv("sample(9).tsv")
Terra1 <- Filter(function(x)!all(is.na(x)), Terra) 
Terra2 <- Terra1[!grepl("gs://|quay|docker", Terra1)]

# Read the metadata file
metadata <- fread("HAI_LIMS_ALL.csv")

# Merge with new column name "Terra_id"
merged <- merge(metadata, Terra2, by.x = "Label Id", by.y = "entity:sample_id")

# Reorder columns
merged <- merged %>% select(Terra_id, everything())

# Save the result as an Excel file
write_xlsx(merged, "HAI_merged_LIMS.xlsx")

View(merged)

library(readxl)
library(readr)
library(dplyr)
library(data.table)
library(writexl)

# Read the Terra data
Terra <- read_tsv("sample(74).tsv")
Terra1 <- Filter(function(x)!all(is.na(x)), Terra)
Terra2 <- Terra1[!grepl("gs://|quay|docker", Terra1)]

# Clean the entity:sample_id column to remove non-numerical values after the first 'B'
Terra2$barcodes_clean <- sub("(B[0-9]+).*", "\\1", Terra2$`entity:sample_id`)

# Read the metadata file
metadata <- fread("HAI_LIMS_ALL.csv")

# Perform a left join to keep all rows from Terra2
merged <- left_join(Terra2, metadata, by = c("barcodes_clean" = "Label Id"))

# Remove rows where NCBI_submission_id is NA
merged <- merged %>% filter(!is.na(submission_id))

# Rename columns if necessary
colnames(merged)[which(names(merged) == "submission_id")] <- "NCBI_submission_id"

# Reorder columns and place entity:sample_id as the second column
merged <- merged %>% select(NCBI_submission_id, `entity:sample_id`, upload_date, everything())

# Save the result as an Excel file
write_xlsx(merged, "HAI_NCBI_Terra_LIMS_merged.xlsx")

View(merged)

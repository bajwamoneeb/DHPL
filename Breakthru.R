library(readxl)
library(readr)
library(dplyr)

#part1
names <- read_csv("combined_names_breakthru_12.21.txt")

lims_metadata <- read_csv("lims_metadata.ALL.csv")
lims_metadata.2 = unique(lims_metadata)
lims_metadata.3 = rename(lims_metadata.2, `entity:sample_id` = `Label Id`)
metadata2 <- merge(lims_metadata.3, names, by = "combined_name")

write_tsv(metadata2, "name_with_barcode.tsv")

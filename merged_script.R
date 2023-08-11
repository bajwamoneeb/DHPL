library(readxl)
library(readr)
library(dplyr)
library(data.table)

master <- fread("MPXV (7).tsv")

metadata <- fread("mpxv_metadata.csv")

merged=merge(metadata, master, by.x = "Label Id", by.y = "entity:MPXV_id")

View(merged)

write_tsv(merged, "mpxv_samples_lims.tsv")


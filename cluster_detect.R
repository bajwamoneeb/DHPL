library(readxl)
library(readr)
library(dplyr)

#part1
names <- read_excel("cluster_requests_ALL.xlsx")

lims_metadata <- read_csv("lims_metadataALL.csv")
lims_metadata.2 = unique(lims_metadata)
lims_metadata.3 = rename(lims_metadata.2, `entity:sample_id` = `Label Id`)
metadata2 <- merge(lims_metadata.3, names, by = "combined_name", )

Terra <- read_delim("Terra.tsv",
                    "\t",
                    escape_double = FALSE,
                    trim_ws = TRUE)

write.csv(merge(unique(mutate_all(metadata2, .funs = toupper)), 
                Terra_data, by = "entity:sample_id"),"clusters_dec.csv")

#part2
metadata_epi_new <- read.csv("clusters_dec.csv")

metadata_epi_old <-
  read.csv("clusters_ALL.csv")

list = anti_join(metadata_epi_new, metadata_epi_old, by = "combined_name")

write_csv(list, "clusters_resultsNEW_12.11.21.csv")

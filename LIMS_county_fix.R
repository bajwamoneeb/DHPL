library(readxl)
library(readr)
library(dplyr)

counties_cities <- read_excel("counties list.xlsx", col_names = T, trim_ws = T)
counties_cities$Address1.City = toupper(counties_cities$Address1.City)

metadata <- read_csv("lims_metadata.ALL.csv", strip.white = T)
DE_metadata =metadata %>% filter(Address1.State=="DE")
DE_metadata$Address1.City = toupper(DE_metadata$Address1.City)

merged=merge(DE_metadata, counties_cities, by = "Address1.City")
antimerged=anti_join(DE_metadata, counties_cities, by = "Address1.City")

x =merged %>% filter(County_Number != Address1.County)

write_tsv(x, "lims_anticorrected.tsv")
write_tsv(counties_cities, "counties.tsv")

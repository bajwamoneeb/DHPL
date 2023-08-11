library(readxl)
library(readr)
library(dplyr)

barcodes <- read_csv("barcodes.txt")
Terra_data <- read.delim("Terra.tsv", check.names = F)
merged=merge(Terra_data, barcodes, by = "entity:sample_id")
write.csv(merged, "barcodes_found.csv")

xy=anti_join(barcodes,Terra_data, by = "entity:sample_id")
print("# of barcodes found: ", quote=F) 
print(length(unique(merged$`entity:sample_id`)))

print("Duplicates: ", quote=F)
xy=merged$`entity:sample_id`
print(xy[duplicated(xy)], quote = F)
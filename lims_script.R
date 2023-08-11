library(readxl)
library(readr)
library(dplyr)

barcodes <- read_excel("barcodes.xlsx", col_names = T)

lims_metadata <- read.csv("lims_metadata.ALL.csv", fileEncoding="UTF-8-BOM")
lims_metadata.2 = unique(lims_metadata)

x = merge(lims_metadata.2, barcodes, by = "Label.Id")
not_found = anti_join(barcodes, lims_metadata.2, by = "Label.Id")
print("# of barcodes found: ", quote = F)
print(length(unique(x$Label.Id)))
write(unique(not_found$Label.Id), "barcodes_notfound.txt")

xy = x$Label.Id
print("# of barcodes NOT found: ", quote = F)
print(length(unique(not_found$Label.Id)))
print("Duplicates: ", quote = F)
print(xy[duplicated(xy)], quote = F)

write_csv(x, "metadata.csv")
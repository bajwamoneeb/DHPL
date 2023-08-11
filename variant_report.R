library(readxl)
library(readr)
library(dplyr)

#Find new samples not reported yet
metadata_epi_new <-  read_delim("Terra.tsv", "\t", 
                    col_types = cols(.default = "c"), 
                    trim_ws = TRUE)

reported <-
  read_excel("reported barcodes.xlsx",
             col_names = T)

Terra_data_to_report = anti_join(metadata_epi_new, reported, by = "entity:sample_id")

#LIMS part
barcodes=data.frame(Terra_data_to_report$`entity:sample_id`, Terra_data_to_report$Run)
colnames(barcodes)= c("Label.Id", "Run")
lims_metadata <- read.csv("lims_metadata.ALL.csv")
lims_metadata.2 = unique(lims_metadata)

x = merge(lims_metadata.2, barcodes, by = "Label.Id")
not_found = anti_join(barcodes, lims_metadata.2, by = "Label.Id")
View(not_found)
write_tsv(not_found, "barcodes_missing_LIMS.tsv", col_names = T)

print("# of barcodes found: ", quote = F)
print(length(unique(x$Label.Id)))

xy = x$Label.Id
print("Duplicates: ", quote = F)
print(xy[duplicated(xy)], quote = F)

#Variant report
lims_metadata.3 = rename(x, `entity:sample_id` = Label.Id)

y = merge(Terra_data_to_report,
          lims_metadata.3, by = "entity:sample_id")

write_tsv(y, "5.4.22 lineage and clade results.tsv")

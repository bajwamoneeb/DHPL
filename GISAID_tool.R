#PART 1

library(readr)
library(stringr)

merged = read_file("merged.FASTA")

headers = str_extract_all(merged, pattern = "\\w.*RUN20")
headers1 = str_extract_all(merged, pattern = "\\w.*to.*12\\.2")

write.table(
  headers,
  "headers.csv",
  quote = F,
  col.names = F,
  row.names = F
)
write.table(
  headers1,
  "headers.csv",
  quote = F,
  col.names = F,
  row.names = F,
  append = T
)


#########################################
#PART 2

headers <- read_csv("headers.csv", col_names = FALSE)
library(phylotools)
rename.fasta("merged.FASTA", ref_table = headers, outfile = "mergedRenamedGISAID.fa")

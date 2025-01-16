library(readr)
library(stringr)
library(lubridate)

FastqFileNames1 <- read_csv("FastqFileNames.txt", col_names = FALSE)

# Extract R1 and R2 filenames
R1_list = str_extract(as.matrix(FastqFileNames1), pattern = "\\w.*_R1_001.fastq.gz")
R2_list = str_extract(as.matrix(FastqFileNames1), pattern = "\\w.*_R2_001.fastq.gz")
# Write R1_list to file
write(na.exclude(R1_list), "R1_list.txt")

# Parse barcodes
FastqFileNames2 <- read_delim(
  "R1_list.txt",
  "_",
  escape_double = FALSE,
  trim_ws = TRUE,
  col_names = FALSE
)

barcodes <- toupper(FastqFileNames2$X1)

# Assemble data frame
a <- data.frame(
  "entity:sample_id" = barcodes,
  "read1" = na.exclude(R1_list),
  "read2" = na.exclude(R2_list)
)

# Write to TSV file
write_tsv(a,
          "upload_sheet.tsv",
          eol = "\n")

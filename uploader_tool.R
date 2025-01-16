library(readr)
library(stringr)
library(readxl)

# Grab FASTQ file names
Path_to_files <- readline(prompt = "Enter path to FASTQ files: ")
write(list.files(path = Path_to_files), "FastqFileNames.txt")

FastqFileNames1 <- read_csv("FastqFileNames.txt", col_names = FALSE)

# Extract R1 and R2 file names
R1_list <- str_extract(as.matrix(FastqFileNames1), pattern = "\\w.*L001_R1_001.fastq.gz")
R2_list <- str_extract(as.matrix(FastqFileNames1), pattern = "\\w.*L001_R2_001.fastq.gz")

# Remove rows with "Undetermined" in the filename
R1_list <- na.exclude(R1_list)
R2_list <- na.exclude(R2_list)
R1_list <- R1_list[!grepl("Undetermined", R1_list)]
R2_list <- R2_list[!grepl("Undetermined", R2_list)]

write(R1_list, "R1_list.txt")

# Grab barcodes
FastqFileNames2 <- read_delim(
  "R1_list.txt",
  "-",
  escape_double = FALSE,
  trim_ws = TRUE,
  col_names = FALSE
)

instrument_model <- "Illumina Miseq"
seq_platform <- "ILLUMINA"

number_samples <- length(R1_list)
barcodes <- toupper(head(FastqFileNames2$X1, number_samples))

col1 <- " "
col2 <- " "

a <- cbind(
  barcodes,
  head(R1_list, number_samples),
  head(R2_list, number_samples),
  instrument_model,
  seq_platform,
  col2
)

colnames(a) <- c("entity:sample_id", "read1", "read2", "instrument_model", "seq_platform", "Date_of_run")
View(a)
write_tsv(as.data.frame(a), "uploader_sheet.tsv")
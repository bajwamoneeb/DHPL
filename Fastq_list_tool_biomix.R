library(readr)
library(stringr)

FastqFileNames1 <- read_csv("FastqFileNames.txt", col_names = FALSE)

R1_list = str_extract(as.matrix(FastqFileNames1), pattern = "\\w.*_R1.fastq.gz")
R2_list = str_extract(as.matrix(FastqFileNames1), pattern = "\\w.*_R2.fastq.gz")
write(na.exclude(R1_list), "R1_list.txt")

#Grab barcodes
FastqFileNames2 <-
  read_delim(
    "R1_list.txt",
    "-",
    escape_double = FALSE,
    trim_ws = TRUE,
    col_names = F
  )

barcodes = toupper(FastqFileNames2$X1)

Run = readline(prompt = "Enter Run # in format RUNXX: ")
rundate = readline(prompt = "Enter date of run in format YYYY-MM-DD: ")
instrument_model = "NextSeq 550"
seq_platform = "ILLUMINA"

a = cbind(
  barcodes,
  na.exclude(R1_list),
  na.exclude(R2_list),
  rundate,
  Run,
  instrument_model,
  seq_platform
)

colnames(a) = c(
  "entity:sample_id",
  "read1",
  "read2",
  "Date_of_run",
  "Run",
  "instrument_model",
  "seq_platform"
)

write_tsv(as.data.frame(a),
          "upload_sheet.tsv",
          quote_escape = F,
          eol = "\n")

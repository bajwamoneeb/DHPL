library(readr)
library(stringr)

#Grab FASTQ file names
Path_to_files = readline(prompt = "Enter path to FASTQ files: ")
write(list.files(path =
                   Path_to_files),
      "FastqFileNames.txt")

FastqFileNames1 <- read_csv("FastqFileNames.txt", col_names = FALSE)

R1_list = str_extract(as.matrix(FastqFileNames1), pattern = "\\w.*L001_R1_001.fastq.gz")
R2_list = str_extract(as.matrix(FastqFileNames1), pattern = "\\w.*L001_R2_001.fastq.gz")
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

number_samples = length(na.exclude(R1_list))
barcodes = toupper(head(FastqFileNames2$X1, number_samples - 1))

rundate = readline(prompt = "Insert date of run in format YYYY-MM-DD: ")
a = cbind(
  barcodes,
  head(na.exclude(R1_list), number_samples - 1),
  head(na.exclude(R2_list), number_samples - 1),
  rundate
)

colnames(a) = c("entity:sample_id", "read1", "read2", "Date_of_run")
a[number_samples - 2, 1] = "NTCA"
a[number_samples - 1, 1] = "NTCB"

write_tsv(as.data.frame(a), "upload_sheet.tsv", quote_escape = F, eol = "\n")

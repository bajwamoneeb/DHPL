library(readr)
library(stringr)
library(readxl)

#Grab FASTQ file names
Path_to_files = readline(prompt = "Enter path to FASTQ files: ")
write(list.files(path = Path_to_files),"FastqFileNames.txt")

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

instrument_model =	"Illumina Miseq"
seq_platform = "ILLUMINA"

number_samples = length(na.exclude(R1_list))
barcodes = toupper(head(FastqFileNames2$X1, number_samples - 1))

col1 = " "
col2 = " "

a = cbind(
  barcodes,
  head(na.exclude(R1_list), number_samples - 1),
  head(na.exclude(R2_list), number_samples - 1),
  instrument_model,	
  seq_platform,
  col1,
  col2
)

colnames(a) = c("entity:sample_id", "read1", "read2", "instrument_model", "seq_platform", "Notes", "Date_of_run")

write_tsv(as.data.frame(a), "uploader_sheet.tsv")


##########################

#Old Code

'library(readr)
library(stringr)

FastqFileNames1 <-
  read_delim(
    "FastqFileNames.txt",
    "-",
    escape_double = FALSE,
    trim_ws = TRUE,
    col_names = F
  )

FastqFileNames1$X1=toupper(FastqFileNames1$X1)

barcodes <- read_table2("barcodes_1.txt", col_names = FALSE)

merged = merge(FastqFileNames1, barcodes, by = "X1")
merged.1 = paste(merged$X1,
                 merged$X2,
                 merged$X3,
                 merged$X4,
                 merged$X5,
                 merged$X6,
                 merged$X7,
                 sep = "-")

R1_list = str_extract(merged.1, pattern = "\\w. * L001_R1_001.fastq.gz")
R2_list = str_extract(merged.1, pattern = "\\w. * L001_R2_001.fastq.gz")

write(na.exclude(R1_list), "R1_list.txt")
write(na.exclude(R2_list), "R2_list.txt")'

#Extra lane samples

'FastqFileNames2 <-
  read_delim(
    "FastqFileNames.txt",
    "_",
    escape_double = FALSE,
    trim_ws = TRUE,
    col_names = F
  )
FastqFileNames2$X1=toupper(FastqFileNames2$X1)

merged = merge(FastqFileNames2, barcodes, by = "X1")
merged.2 = paste(merged$X1,
                 merged$X2,
                 merged$X3,
                 merged$X4,
                 merged$X5,
                 merged$X6,
                 sep = "_") '

' R1_list_lane1 = str_extract(merged.2, pattern = "\\w.*L001_R1_001.fastq.gz")
  R1_list_lane2 = str_extract(merged.2, pattern = "\\w.*L002_R1_001.fastq.gz")
  R1_list_lane3 = str_extract(merged.2, pattern = "\\w.*L003_R1_001.fastq.gz")
  R1_list_lane4 = str_extract(merged.2, pattern = "\\w.*L004_R1_001.fastq.gz")

  R2_list_lane1 = str_extract(merged.2, pattern = "\\w.*L001_R2_001.fastq.gz")
  R2_list_lane2 = str_extract(merged.2, pattern = "\\w.*L002_R2_001.fastq.gz")
  R2_list_lane3 = str_extract(merged.2, pattern = "\\w.*L003_R2_001.fastq.gz")
  R2_list_lane4 = str_extract(merged.2, pattern = "\\w.*L004_R2_001.fastq.gz")

  write(na.exclude(R1_list), "R1_list")
  write(na.exclude(R2_list), "R2_list")

  #Extra lanes (if any)
  write(na.exclude(R1_list_lane1), "R1_list", append = T)
  write(na.exclude(R2_list_lane1), "R2_list", append = T)

  write(na.exclude(R1_list_lane2), "R1_list_lane2")
  write(na.exclude(R2_list_lane2), "R2_list_lane2")

  write(na.exclude(R1_list_lane3), "R1_list_lane3")
  write(na.exclude(R2_list_lane3), "R2_list_lane3")

  write(na.exclude(R1_list_lane4), "R1_list_lane4")
  write(na.exclude(R2_list_lane4), "R2_list_lane4")'
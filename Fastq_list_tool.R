library(readr)
library(stringr)

#Grab FASTQ file names
Path_to_files=readline(prompt = "Enter path to FASTQ files: ")
write(
  list.files(
    path =
      Path_to_files
  ),
  "FastqFileNames.txt"
)

FastqFileNames1 <- read_csv("FastqFileNames.txt",col_names = FALSE)

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

barcodes=toupper(head(FastqFileNames2$X1,48))

a_size=length(a[,1])

a=cbind(barcodes, head(na.exclude(R1_list),a_size),head(na.exclude(R2_list),a_size))
colnames(a)=c("entity:sample_id","read1","read2")
a[a_size-1,1]="NTCA"
a[a_size,1]="NTCB"
write.csv(a, "upload_sheet.csv", row.names = F)

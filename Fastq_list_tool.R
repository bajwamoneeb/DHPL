library(readr)
library(stringr)
library(lubridate)

FastqFileNames1 <- read_csv("FastqFileNames.txt", col_names = FALSE)

R1_list = str_extract(as.matrix(FastqFileNames1), pattern = "\\w.*_R1_001.fastq.gz")
R2_list = str_extract(as.matrix(FastqFileNames1), pattern = "\\w.*_R2_001.fastq.gz")
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

experiment_name = str_split_fixed(FastqFileNames1$X1, pattern = "_", n = 2)
x = experiment_name[1]
experiment_name_split = as.data.frame(str_split_fixed(x, pattern = "-", n = Inf))
date=paste(experiment_name_split$V6,experiment_name_split$V5,experiment_name_split$V4,sep = "-")


Run = experiment_name_split$V7
rundate = ydm(date)
instrument_model= " "
seq_platform="ILLUMINA"

# if(experiment_name_split$V3== "NB552483"){
#   instrument_model="NextSeq 550"
# } else{
#   instrument_model="Illumina MiSeq"
# }

a = cbind(
  barcodes,
  na.exclude(R1_list),
  na.exclude(R2_list),
  as.character(rundate),
  instrument_model,
  seq_platform
)

colnames(a) = c(
  "entity:sample_id",
  "read1",
  "read2",
  "Date_of_run",
  "instrument_model",
  "seq_platform"
)

write_tsv(as.data.frame(a),
          "upload_sheet.tsv",
          eol = "\n")

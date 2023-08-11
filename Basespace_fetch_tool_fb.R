library(readr)
library(stringr)
library(lubridate)

#Grab barcodes
Samplesheet <-
  read_delim(
    "Sample_sheet.txt",
    "-",
    escape_double = FALSE,
    trim_ws = TRUE,
    col_names = F
  )

barcodes = toupper(Samplesheet$X1)
experiment_name = paste(Samplesheet$X2, Samplesheet$X3, Samplesheet$X4, sep="-")
samplesheet_id <-
  read_delim(
    "Sample_sheet.txt",
    "/n",
    escape_double = FALSE,
    trim_ws = TRUE,
    col_names = F
  )
write(experiment_name, "experiment_name.txt")
x = read_delim("experiment_name.txt", "_", col_names = F)
colnames(x) = c("1", "2", "Date", "Run")

Notes = "Foodborne"
rundate = mdy(x$Date)
instrument_model= " "
seq_platform="ILLUMINA"

if(x$`2`[1]== "NB552483"){
  instrument_model="NextSeq 550"
} else{
  instrument_model="Illumina MiSeq"
}

a = data.frame(barcodes,
               rundate,
               Notes,
               experiment_name,
               samplesheet_id,
               instrument_model,
               seq_platform)

colnames(a) = c("entity:sample_id",
                "Date_of_run",
                "Notes",
                "experiment_name",
                "samplesheet_id",
                "instrument_model",
                "seq_platform")

write_tsv(as.data.frame(a),
          "upload_sheet_bsf-fb.tsv",
          eol = "\n")
View(a)

library(readr)
library(dplyr)
library(lubridate)

Terra <- read_tsv("sample - 2023-08-17T093653.757.tsv")

Terra_filtered = Terra %>% filter(Date_of_run < "2023-06-01") 
                               #    & !is.na(Submitted_to_Gisaid))

#Terra_filtered.1 = Terra_filtered %>% filter(Date_of_run > "2022-11-01")

Terra_filtered1 = as.data.frame(Terra_filtered)
all_columns = data.frame(
  Terra_filtered1$read1_dehosted,
  Terra_filtered1$read2_dehosted,
  Terra_filtered1$read1_aligned,
  Terra_filtered1$read2_aligned,
  # Terra_filtered1$read1_submission,
  # Terra_filtered1$read2_submission,
  Terra_filtered1$read1_clean,
  Terra_filtered1$read2_clean,
  # Terra_filtered1$sra_read1,
  # Terra_filtered1$sra_read2,
  Terra_filtered1$aligned_bam,
  Terra_filtered1$auspice_json
  # Terra_filtered1$sorted_bam,
  # Terra_filtered1$trim_sorted_bam
  
)

write_tsv(as.data.frame(na.exclude(unlist(all_columns))), "gcp_removal.tsv")
a=as.data.frame(na.exclude(unlist(all_columns)))
View(a)

#*Last run on COVID-19 workspace up to 2023-06-01.
#*Last run on WW workspace up to 2023-06-01.
#*Run the following on Biomix after transferring the gcp_removal.tsv file over:
#*"while read line; do gsutil rm $line; done < gcp_removal.tsv 1>gcp_rm.log 2>gcp_rm.err &"

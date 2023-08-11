library(readr)
library(dplyr)
library(lubridate)

Terra <- read_tsv("sample - 2023-02-02T144037.337.tsv")

Terra_filtered = Terra %>% filter(Date_of_run < "2022-12-01" &
                                    !is.na(Submitted_to_Gisaid))

Terra_filtered1 = as.data.frame(Terra_filtered)
all_columns = data.frame(
  Terra_filtered1$read1_dehosted,
  Terra_filtered1$read2_dehosted,
  Terra_filtered1$read1_submission,
  Terra_filtered1$read2_submission,
  Terra_filtered1$read1_clean,
  Terra_filtered1$read2_clean,
  Terra_filtered1$sra_read1,
  Terra_filtered1$sra_read2,
  Terra_filtered1$aligned_bam,
  Terra_filtered1$clearlabs_fastq_gz
)

write_tsv(as.data.frame(na.exclude(unlist(all_columns))), "gcp_removal.tsv")

#**Last run Feb 7, 2023**
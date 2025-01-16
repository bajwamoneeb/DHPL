library(data.table)
library(readr)
library(writexl)
Terra <- read_tsv("sample(72).tsv")
Terra1 <- Filter(function(x)!all(is.na(x)), Terra) 
Terra2=Terra1[!grepl("gs://|quay|docker", Terra1)]
View(Terra2)
write_xlsx(Terra2, "clearlabs-01-04.xlsx")


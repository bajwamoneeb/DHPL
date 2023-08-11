library(data.table)
library(readr)
Terra <- read_tsv("flu (6).tsv")
Terra1 <- Filter(function(x)!all(is.na(x)), Terra) 
Terra2=Terra1[!grepl("gs://|quay", Terra1)]
View(Terra2)
write_tsv(Terra2, "flu(6)clean.tsv")


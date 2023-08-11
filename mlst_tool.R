library(readxl)
library(readr)
library(dplyr)

b70 <-
  read.csv("B1107178ALL_loci.csv")

b76 <-
  read.csv("B1107184ALL_loci.csv")

list = anti_join(b70, b76, by = "Allele1")

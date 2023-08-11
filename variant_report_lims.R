library(readxl)
library(readr)
library(stringr)
library(dplyr)
library(data.table)

report<-fread("variant_report_raw_new.csv")
coverage=report %>% filter(Name=="Percent Reference Coverage")
nextclade=report %>% filter(Name=="Nextclade")
pango=report %>% filter(Name=="Pango Lineage")

coverage1=data.frame(coverage$`Formatted Entry`, coverage$`Label Id`)
pango1=data.frame(pango$`Formatted Entry`, pango$`Label Id`)
colnames(pango1)= c("Pango Lineage", "Label Id")
colnames(coverage1)= c("Percent Reference Coverage", "Label Id")

x=merge(coverage1, nextclade, by= "Label Id")
y=merge(x, pango1, by= "Label Id")
z = rename(y, `Nextclade clade`=`Formatted Entry`)
z$Name=NULL
z$`Released On`=NULL
z$Status=NULL

#Move columns around
z1 <- z %>% relocate(`Nextclade clade`, .after = `Percent Reference Coverage`)
z2 <- z1 %>% relocate(`Pango Lineage`, .after = `Nextclade clade`)
z3=z2[order(as.numeric(z2$`Percent Reference Coverage`), decreasing = T), ]
#date=z3$`Date Completed`
#date1=sort(date)[1]

old_report=read_tsv("Variant_report.2023-07-13.tsv", col_names = colnames(z3))
#appended=rbind(old_report, z3)
#appended1=unique(appended)
#appended2=appended1 %>% filter(`Date Completed`>= as.Date(date1))
new_report = anti_join(z3, old_report, by = "Label Id")
CCMC_report = new_report %>% filter(Customer == "CCMC")

report_title=paste("Variant_report", Sys.Date(),"tsv", sep = ".")
CCMCreport_title=paste("CCMC_report", Sys.Date(),"tsv", sep = ".")

write_tsv(new_report, report_title)
write_tsv(CCMC_report, CCMCreport_title)
View(CCMC_report)
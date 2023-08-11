library(readxl)
library(readr)
library(dplyr)
library(data.table)
library(lubridate)

#ILLUMINA PORTION

#Filter for samples not yet submitted to GISAID
Terra <-
  read_tsv("sample - 2023-07-18T191753.177.tsv", col_names = T)

Terra_filtered = Terra %>% filter(
  seq_platform == "ILLUMINA" &
    !is.na(assembly_fasta) &
    is.na(Submitted_to_Gisaid) &
    !is.na(read1_dehosted) &
    !grepl('skipped', vadr_num_alerts)
)

barcodes_filtered = data.frame(Terra_filtered$`entity:sample_id`,
                               Terra_filtered$purpose_of_sequencing)
colnames(barcodes_filtered) = c("entity:sample_id", "purpose_of_sequencing")

#LIMS_script
lims_metadata <- fread("lims_metadata.ALL.csv")
lims_metadata$`Sample Number` = NULL
lims_metadata$Patient = NULL
lims_metadata$`Last Name` = NULL
lims_metadata$`First Name` = NULL
lims_metadata$`Date Completed` = NULL
lims_metadata$`Birth Date` = NULL
lims_metadata$`Address1 Line 1` = NULL
lims_metadata$`Address1 Zip` = NULL
lims_metadata$`Address1 City` = NULL

lims_metadata.2 = unique(lims_metadata)
colnames(lims_metadata.2) = c(
  "entity:sample_id",
  "collection_date",
  "customer",
  "iso_gender",
  "iso_age",
  "iso_county",
  "iso_state",
  "depscription"
)

#Age of 5 year range
age=as.data.frame(str_split_fixed(lims_metadata.2$iso_age, ' ', 2))
lims_metadata.2$iso_age=paste(age$V1, "-", as.numeric(age$V1)+5, "years")
age=as.data.table(age)
age[V2 %in% "months", V1 := "0"]
age[V2 %in% "days", V1 := "0"]
age[V2 %in% "weeks", V1 := "0"]

lims_metadata.2 = as.data.table(lims_metadata.2)
lims_metadata.2[iso_state %in% c("nil", ""), iso_state := "Un"]
submission_id = paste(lims_metadata.2$iso_state,
                      "DHSS",
                      lims_metadata.2$`entity:sample_id`,
                      sep = "-")

bioproject_accession = "PRJNA673096"
gisaid_submitter = "mbajwa"
Authors = "Holly Miller, Moneeb Bajwa"
isolation_source = "Clinical"
library_selection = "cDNA"
library_source = "Genomic"
library_strategy = "Amplicon"
iso_continent = "North America"
iso_country = "USA"
originating_lab = "N/A"
submitting_lab = "Delaware Public Health Lab"
origLab_address = "N/A"
subLab_address = "30 Sunnyside Road, Smyrna, Delaware 19977"
host_disease = "COVID-19"
library_id = submission_id
organism = "SARS-CoV-2"
prep_upload_date = paste(Sys.Date(), "mercury_prep", sep = "_")

lims_metadata.2.1 = cbind(
  lims_metadata.2,
  submission_id,
  bioproject_accession,
  gisaid_submitter,
  Authors,
  isolation_source,
  library_selection,
  library_source,
  library_strategy,
  iso_continent,
  iso_country,
  originating_lab,
  submitting_lab,
  subLab_address,
  origLab_address,
  host_disease,
  library_id,
  organism,
  prep_upload_date
)

`%!in%` <- Negate(`%in%`)
lims_metadata.2.1 = as.data.table(lims_metadata.2.1)
lims_metadata.2.1[customer %in% "CCMC", originating_lab := "CCMC"]
lims_metadata.2.1[customer %!in% "CCMC", originating_lab := "N/A"]
lims_metadata.2.1[customer %in% "CCMC", origLab_address := "4755 Ogletown Stanton Rd, Newark, DE 19718"]

for (i in 1:nrow(lims_metadata.2.1)) {
  if (grepl('Nemours', lims_metadata.2.1$depscription[i], ignore.case = T) ==
      T) {
    lims_metadata.2.1$customer[i] = "Nemours"
  }
}

lims_metadata.2.1[customer %in% "Nemours", origLab_address := "1600 Rockland Road, Wilmington, DE 19803"]
lims_metadata.2.1[customer %in% "Nemours", originating_lab := "Nemours"]


#Merge LIMS data with filtered samples from Terra
metadata = merge(lims_metadata.2.1, barcodes_filtered, by = "entity:sample_id")
not_found = anti_join(barcodes_filtered, lims_metadata.2.1, by = "entity:sample_id")
print("# of barcodes found: ", quote = F)
print(length(unique(metadata$`entity:sample_id`)))
write(unique(not_found$`entity:sample_id`),
      "barcodes_notfound.txt")
xy = metadata$Label.Id
print("# of barcodes NOT found: ", quote = F)
print(length(unique(not_found$Label.Id)))
print("Duplicates: ", quote = F)
print(xy[duplicated(xy)], quote = F)
metadata[purpose_of_sequencing %in% NA, purpose_of_sequencing := "Baseline surveillance"]
metadata[customer %in% "Nemours", purpose_of_sequencing := "Targeted surveillance"]

#Reformat column values
metadata$collection_date <-
  strftime(mdy_hms(metadata$collection_date), "%Y-%m-%d")
metadata = as.data.table(metadata)
metadata[iso_gender %!in% c("M", "F"), iso_gender := "unknown"]

#County name
metadata[iso_county %!in% c("001", "003", "005"), iso_county := "Unknown"]
metadata[iso_county %in% c("001"), iso_county := "Kent"]
metadata[iso_county %in% c("003"), iso_county := "New Castle"]
metadata[iso_county %in% c("005"), iso_county := "Sussex"]

metadata$depscription = NULL
metadata$customer = NULL

metadata.illumina = metadata

###############################################################################

#Clearlabs Portion

Terra_filtered = Terra %>% filter(
  seq_platform == "OXFORD_NANOPORE" &
    !is.na(clearlabs_fasta) &
    is.na(Submitted_to_Gisaid) &
    !grepl('skipped', vadr_num_alerts)
)

barcodes_filtered = data.frame(Terra_filtered$`entity:sample_id`,
                               Terra_filtered$purpose_of_sequencing)
colnames(barcodes_filtered) = c("entity:sample_id", "purpose_of_sequencing")

#LIMS_script
lims_metadata <- fread("lims_metadata.ALL.csv")
lims_metadata$`Sample Number` = NULL
lims_metadata$Patient = NULL
lims_metadata$`Last Name` = NULL
lims_metadata$`First Name` = NULL
lims_metadata$`Date Completed` = NULL
lims_metadata$`Birth Date` = NULL
lims_metadata$`Address1 Line 1` = NULL
lims_metadata$`Address1 Zip` = NULL
lims_metadata$`Address1 City` = NULL

lims_metadata.2 = unique(lims_metadata)
colnames(lims_metadata.2) = c(
  "entity:sample_id",
  "collection_date",
  "customer",
  "iso_gender",
  "iso_age",
  "iso_county",
  "iso_state",
  "depscription"
)

#Age of 5 year range
age=as.data.frame(str_split_fixed(lims_metadata.2$iso_age, ' ', 2))
lims_metadata.2$iso_age=paste(age$V1, "-", as.numeric(age$V1)+5, "years")
age=as.data.table(age)
age[V2 %in% "months", V1 := "0"]
age[V2 %in% "days", V1 := "0"]
age[V2 %in% "weeks", V1 := "0"]

lims_metadata.2 = as.data.table(lims_metadata.2)
lims_metadata.2[iso_state %in% c("nil", ""), iso_state := "Un"]
submission_id = paste(lims_metadata.2$iso_state,
                      "DHSS",
                      lims_metadata.2$`entity:sample_id`,
                      sep = "-")

library_id = submission_id
prep_upload_date = paste(Sys.Date(), "mercury_cl_prep", sep = "_")

lims_metadata.2.1 = cbind(
  lims_metadata.2,
  submission_id,
  bioproject_accession,
  gisaid_submitter,
  Authors,
  isolation_source,
  library_selection,
  library_source,
  library_strategy,
  iso_continent,
  iso_country,
  originating_lab,
  submitting_lab,
  subLab_address,
  origLab_address,
  host_disease,
  library_id,
  organism,
  prep_upload_date
)

`%!in%` <- Negate(`%in%`)
lims_metadata.2.1 = as.data.table(lims_metadata.2.1)
lims_metadata.2.1[customer %in% "CCMC", originating_lab := "CCMC"]
lims_metadata.2.1[customer %!in% "CCMC", originating_lab := "N/A"]
lims_metadata.2.1[customer %in% "CCMC", origLab_address := "4755 Ogletown Stanton Rd, Newark, DE 19718"]

for (i in 1:nrow(lims_metadata.2.1)) {
  if (grepl('Nemours', lims_metadata.2.1$depscription[i], ignore.case = T) ==
      T) {
    lims_metadata.2.1$customer[i] = "Nemours"
  }
}

lims_metadata.2.1[customer %in% "Nemours", origLab_address := "1600 Rockland Road, Wilmington, DE 19803"]
lims_metadata.2.1[customer %in% "Nemours", originating_lab := "Nemours"]


#Merge LIMS data with filtered samples from Terra
metadata = merge(lims_metadata.2.1, barcodes_filtered, by = "entity:sample_id")
not_found = anti_join(barcodes_filtered, lims_metadata.2.1, by = "entity:sample_id")
print("# of barcodes found: ", quote = F)
print(length(unique(metadata$`entity:sample_id`)))
write(unique(not_found$`entity:sample_id`),
      "barcodes_notfound.txt")
xy = metadata$Label.Id
print("# of barcodes NOT found: ", quote = F)
print(length(unique(not_found$Label.Id)))
print("Duplicates: ", quote = F)
print(xy[duplicated(xy)], quote = F)
metadata[purpose_of_sequencing %in% NA, purpose_of_sequencing := "Baseline surveillance"]
metadata[customer %in% "Nemours", purpose_of_sequencing := "Targeted surveillance"]

#Reformat column values
metadata$collection_date <-
  strftime(mdy_hms(metadata$collection_date), "%Y-%m-%d")
metadata = as.data.table(metadata)
metadata[iso_gender %!in% c("M", "F"), iso_gender := "unknown"]

#County name
metadata[iso_county %!in% c("001", "003", "005"), iso_county := "Unknown"]
metadata[iso_county %in% c("001"), iso_county := "Kent"]
metadata[iso_county %in% c("003"), iso_county := "New Castle"]
metadata[iso_county %in% c("005"), iso_county := "Sussex"]

metadata$depscription = NULL
metadata$customer = NULL

metadata_cl = metadata
combined_metadata = rbind(metadata.illumina, metadata_cl)
View(combined_metadata)

write_tsv(combined_metadata, "public_subm_metadata.tsv")
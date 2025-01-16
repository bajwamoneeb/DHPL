library(readxl)
library(readr)
library(dplyr)
library(data.table)
library(lubridate)
library(stringr)

# Define %!in% operator
`%!in%` <- Negate(`%in%`)

# File to store the last running number
running_number_file <- "last_running_number.txt"

# Function to read the last running number from a file
read_last_running_number <- function(file_path) {
  if (file.exists(file_path)) {
    last_number <- as.numeric(readLines(file_path))
    if (!is.na(last_number)) {
      return(last_number)
    }
  }
  return(0)  # Default to 0 if file doesn't exist or is invalid
}

# Function to save the last running number to a file
save_last_running_number <- function(file_path, last_number) {
  writeLines(as.character(last_number), file_path)
}

# Read the last running number from the file
last_running_number <- read_last_running_number(running_number_file)

# Load data
Terra <- read_tsv("sample(75).tsv", col_names = TRUE)

# Filter and prepare Illumina data
Terra_filtered <- Terra %>%
  filter(
    seq_platform == "ILLUMINA" &
      percent_reference_coverage >= 85 &
      !is.na(assembly_fasta) &
      is.na(upload_tag) &   # Check if upload_tag is NA for inclusion
      !is.na(read1_dehosted) &
      !grepl('skipped', vadr_num_alerts)
  ) %>%
  mutate(
    barcodes_clean = gsub("re|RE|X2", "", `entity:sample_id`),
    library_id = paste(`entity:sample_id`, "DHSS", sep = "-"),
    upload_tag = paste(Sys.Date(), "mercury_prep", sep = "_"),
    library_layout = "Paired",
    seq_platform = "ILLUMINA"
  )

# Prepare barcodes_filtered DataFrame for Illumina
barcodes_filtered <- Terra_filtered %>%
  select(`entity:sample_id`, purpose_of_sequencing, instrument_model, Run, assembly_method, seq_platform, library_id, upload_tag, library_layout, barcodes_clean)

# Filter and prepare Clearlabs data
Terra_filtered_cl <- Terra %>%
  filter(
    !is.na(clearlabs_fasta) &
      percent_reference_coverage >= 85 &
      is.na(upload_tag) &   # Ensure upload_tag is NA for ClearLabs samples as well
      !grepl('skipped', vadr_num_alerts)
  ) %>%
  mutate(
    barcodes_clean = gsub("re|RE|X2", "", `entity:sample_id`),
    library_id = paste(`entity:sample_id`, "DHSS", sep = "-"),
    upload_tag = paste(Sys.Date(), "mercury_cl_prep", sep = "_"),
    library_layout = "Single",
    seq_platform = "OXFORD_NANOPORE",
    instrument_model = "MinION",
    assembly_method = "Clearlabs"
  )

# Prepare barcodes_filtered DataFrame for Clearlabs
barcodes_filtered_cl <- Terra_filtered_cl %>%
  select(`entity:sample_id`, purpose_of_sequencing, instrument_model, Run, assembly_method, seq_platform, library_id, upload_tag, library_layout, barcodes_clean) %>%
  mutate(
    Run = ifelse(is.na(Run), "Not Applicable", Run)
  )

# Combine Illumina and Clearlabs data
combined_data <- rbind(barcodes_filtered, barcodes_filtered_cl)

# LIMS_script
lims_metadata <- read_excel("lims_metadata.ALL.xlsx")
lims_metadata$`Sample Number` <- NULL
lims_metadata$Patient <- NULL
lims_metadata$`Last Name` <- NULL
lims_metadata$`First Name` <- NULL
lims_metadata$`Date Completed` <- NULL
lims_metadata$`Birth Date` <- NULL
lims_metadata$`Address1 Line 1` <- NULL
lims_metadata$`Address1 Zip` <- NULL
lims_metadata$`Address1 City` <- NULL

lims_metadata.2 <- unique(lims_metadata)
colnames(lims_metadata.2) <- c(
  "barcodes_clean",
  "collection_date",
  "customer",
  "patient_gender",
  "patient_age",
  "county",
  "state",
  "depscription"
)

# Age of 5-year range
age <- as.data.frame(str_split_fixed(lims_metadata.2$patient_age, ' ', 2))
lims_metadata.2$patient_age <- paste(age$V1, "-", as.numeric(age$V1) + 5, "years")
age <- as.data.table(age)
age[V2 %in% "months", V1 := "0"]
age[V2 %in% "days", V1 := "0"]
age[V2 %in% "weeks", V1 := "0"]

lims_metadata.2 <- as.data.table(lims_metadata.2)
lims_metadata.2[state %in% c("nil", ""), state := "Un"]

# Add the last running number and create submission_id
lims_metadata.2 <- lims_metadata.2 %>%
  mutate(
    running_number = row_number() + last_running_number, 
    submission_id = paste(state, "DHSS", running_number, sep = "-")
  )

# Constant variables for the cbind operation
bioproject_accession <- "PRJNA673096"
gisaid_submitter <- "mbajwa"
Authors <- "Holly Miller, Moneeb Bajwa, Neel Greer, Nyjil Hayward, Kyle Morrill, Daniel Toy, Karla Pagan-Morales, Annaya Osinuga, Morgan Scully"
isolation_source <- "Clinical"
library_selection <- "cDNA"
library_source <- "Genomic"
library_strategy <- "Amplicon"
library_layout <- "Paired"
continent <- "North America"
country <- "USA"
collecting_lab <- "DPHL"
submitting_lab <- "Delaware Public Health Lab"
collecting_lab_address <- "30 Sunnyside Road, Smyrna, Delaware 19977"
submitting_lab_address <- "30 Sunnyside Road, Smyrna, Delaware 19977"
host_disease <- "COVID-19"
organism <- "Severe acute respiratory syndrome coronavirus 2"
upload_tag <- paste(Sys.Date(), "mercury_prep", sep = "_")

# Combine LIMS metadata with constant variables
lims_metadata.2.1 <- cbind(
  lims_metadata.2,
  bioproject_accession,
  gisaid_submitter,
  Authors,
  isolation_source,
  library_selection,
  library_source,
  library_strategy,
  continent,
  country,
  collecting_lab,
  submitting_lab,
  submitting_lab_address,
  collecting_lab_address,
  host_disease,
  library_layout,
  organism,
  upload_tag
)

# Process customer-based values
lims_metadata.2.1 <- as.data.table(lims_metadata.2.1)
lims_metadata.2.1[customer %in% "CCMC", collecting_lab := "CCMC"]
lims_metadata.2.1[customer %in% "CCMC", collecting_lab_address := "4755 Ogletown Stanton Rd, Newark, DE 19718"]

for (i in 1:nrow(lims_metadata.2.1)) {
  if (grepl('Nemours', lims_metadata.2.1$depscription[i], ignore.case = TRUE)) {
    lims_metadata.2.1$customer[i] <- "Nemours"
  }
}

lims_metadata.2.1[customer %in% "Nemours", collecting_lab_address := "1600 Rockland Road, Wilmington, DE 19803"]
lims_metadata.2.1[customer %in% "Nemours", collecting_lab := "Nemours"]

# Merge LIMS data with filtered samples from Terra
metadata <- merge(lims_metadata.2.1, combined_data, by = "barcodes_clean")
not_found <- anti_join(combined_data, lims_metadata.2.1, by = "barcodes_clean")
print("# of barcodes found: ", quote = FALSE)
print(length(unique(metadata$`barcodes_clean`)))
write(unique(not_found$`barcodes_clean`), "barcodes_notfound.txt")

# Handle duplicates and missing values
xy <- metadata$Label.Id
print("# of barcodes NOT found: ", quote = FALSE)
print(length(unique(not_found$Label.Id)))
print("Duplicates: ", quote = FALSE)
print(xy[duplicated(xy)], quote = FALSE)
metadata[purpose_of_sequencing %in% NA, purpose_of_sequencing := "Baseline surveillance"]
metadata[customer %in% "Nemours", purpose_of_sequencing := "Targeted surveillance"]

# Add running number to row numbers
metadata <- metadata %>%
  mutate(running_number = row_number() + last_running_number)

metadata$submission_id <- paste(metadata$state, "DHSS", metadata$running_number, sep = "-")
metadata$library_id <- metadata$submission_id

# Save the last running number to the file
save_last_running_number(running_number_file, max(metadata$running_number))

# Reformat column values
metadata$collection_date <- strftime(ymd_hms(metadata$collection_date), "%Y-%m-%d")
metadata <- as.data.table(metadata)
metadata[patient_gender %!in% c("M", "F"), patient_gender := "unknown"]
metadata[patient_gender %in% c("M"), patient_gender := "Male"]
metadata[patient_gender %in% c("F"), patient_gender := "Female"]

# Process county values
metadata[county %!in% c("1", "3", "5"), county := "Unknown"]
metadata[county %in% c("1"), county := "Kent"]
metadata[county %in% c("3"), county := "New Castle"]
metadata[county %in% c("5"), county := "Sussex"]

metadata$depscription <- NULL
metadata$customer <- NULL

metadata <- metadata %>%
  filter(collection_date > "2024-02-28") %>%
  relocate(`entity:sample_id`) %>%
  select(-`upload_tag.x`) %>%
  select(-`library_layout.x`) %>%
  rename(upload_tag = `upload_tag.y`) %>%
  rename(library_layout = `library_layout.y`)

# View and save the final output
View(metadata)
write_tsv(metadata, "public_subm_metadata1.tsv")

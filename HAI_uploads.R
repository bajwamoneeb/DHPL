# Load necessary libraries
library(readxl)
library(readr)
library(dplyr)
library(data.table)

# Function to generate the new library_ID with proper formatting: YYYYCG-00019
generate_new_library_id <- function(year, running_number) {
  sprintf("%sCG-%05d", year, running_number)  # %05d ensures leading zeros for the running number
}

# Load the running number from the file, or throw an error if the file doesn't exist
running_number_file <- "next_running_number.txt"
if (file.exists(running_number_file)) {
  running_number <- as.numeric(readLines(running_number_file))
} else {
  stop("Error: Running number file 'next_running_number.txt' not found.")
}

# Dynamically set the year to the current year
current_year <- format(Sys.Date(), "%Y")

# Read the existing datasets
master <- fread("sample(73).tsv")  # Updated input TSV file
metadata <- fread("HAI_LIMS_ALL.csv")

# Rename columns in 'metadata' to align with expected output, except "Label Id"
renamed_metadata <- metadata %>%
  rename(
    collection_date = `Sampled Date`,  # Rename sample date to collection_date
    geo_loc_name = `Address1 State`,   # State column renamed to geo_loc_name
    isolation_source = `T Specimen Source`  # Rename isolation_type to isolation_source
  )

# Format collection_date to only include the year (YYYY format)
renamed_metadata$collection_date <- format(as.Date(renamed_metadata$collection_date, format="%m/%d/%Y"), "%Y")

# Format geo_loc_name to follow the format "USA:State"
renamed_metadata <- renamed_metadata %>%
  mutate(
    geo_loc_name = paste("USA:", geo_loc_name, sep = "")
  )

# Generate library_ID and submission_id based on the running number and current year
renamed_metadata <- renamed_metadata %>%
  mutate(
    library_ID = paste0(generate_new_library_id(current_year, running_number), "-001"),
    submission_id = generate_new_library_id(current_year, running_number),
    bioproject = "PRJNA288601",  # Constant value for all rows
    isolate = "human"  # Constant value for all rows
  )

# Perform an inner join to retain only rows with matching 'Label Id' in metadata and 'barcodes_clean' in master
merged <- renamed_metadata %>%
  inner_join(select(master, `entity:sample_id`, barcodes_clean, ts_mlst_predicted_st, gambit_predicted_taxon, run_id), 
             by = c("Label Id" = "barcodes_clean")) %>%
  rename(mlst = ts_mlst_predicted_st, organism = gambit_predicted_taxon)  # Rename joined columns to match the final output

# Now that organism is defined, set design_description with the organism value
merged <- merged %>%
  mutate(design_description = paste("Illumina whole-genome sequencing of", organism))

# Remove unwanted columns if they exist in the metadata, based on user preferences
columns_to_remove <- c("Sample Number", "Address1 Zip", "Date Completed", "Analysis")
existing_columns <- columns_to_remove[columns_to_remove %in% names(merged)]
merged <- merged %>%
  select(-all_of(existing_columns))

# Generate a running number column starting from the loaded running number and create library_ID and submission_id
merged <- merged %>%
  mutate(
    running_number = running_number:(running_number + nrow(merged) - 1),  # Sequential running number
    library_ID = paste0(current_year, "CG-", sprintf("%05d", running_number), "-001"),
    submission_id = paste0(current_year, "CG-", sprintf("%05d", running_number))
  )

# Save the final running number (the last one used) back to the file for future use
final_running_number <- max(merged$running_number)
writeLines(as.character(final_running_number), "next_running_number.txt")

# Remove the running number column after generating library_ID and submission_id
merged <- merged %>%
  select(-running_number)

# Set values
merged <- merged %>%
  mutate(
    title = "Illumina whole-genome sequencing",  # Constant value
    library_strategy = "WGS",  # Constant value
    library_source = "GENOMIC",  # Constant value
    isolation_type = "clinical",  # Constant value
    library_selection = "RANDOM",  # Constant value
    library_layout = "paired",  # Constant value
    platform = "ILLUMINA",  # Constant value
    # Instrument model is conditional based on run_id
    instrument_model = ifelse(is.na(run_id) | run_id == "", "Illumina MiSeq", "Illumina iSeq 100"),
    collected_by = "DPHL",  # Constant value
    host = "homo sapiens",  # Constant value
    lat_lon = "unknown",  # Default value
    host_disease = organism,  # Set host_disease to organism
    filetype = "fastq"  # Constant value
  )

# Select the columns to keep in the final output, ensuring the order is correct and `entity:sample_id` is first
columns_to_keep <- c(
  "entity:sample_id", "library_ID", "title", "library_strategy", "library_source",
  "library_selection", "library_layout", "platform", "instrument_model", 
  "design_description", "filetype", "submission_id", "bioproject", "organism", 
  "collected_by", "collection_date", "geo_loc_name", "host", "host_disease", 
  "isolation_source", "lat_lon", "isolation_type", "isolate", "mlst"
)

# Select the specified columns and create the final data
final_data <- merged %>%
  select(all_of(columns_to_keep))

# Save the final cleaned and selected data to a file
write_tsv(final_data, "HAI_merged.tsv")

# View the final data
View(final_data)

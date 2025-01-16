# Load necessary libraries
library(data.table)
library(dplyr)

# Read in the first and second datasets
metadata <- fread("ww_ALL.csv")  # First file
second_file <- fread("sample(80).tsv")  # Second file

# Merge the files using an inner join to keep only rows with matching `Label Id` and `entity:sample_id`
merged_data <- merge(metadata, second_file, by.x = "Label Id", by.y = "barcodes_clean", all = FALSE)

# Get the current month and day for the upload_tag
current_date <- Sys.Date()
current_month <- format(current_date, "%B")  # Gets the full month name
current_day <- format(current_date, "%d")    # Gets the day of the month with leading zero

upload_tag_value <- paste0("upload_", current_month, "_", current_day)

# Perform the necessary data manipulations
final_data <- merged_data %>%
  # First, create or map the County column based on T County
  mutate(County = case_when(
    `T County` == "1" ~ "Kent",
    `T County` == "3" ~ "New Castle",
    `T County` == "5" ~ "Sussex",
    TRUE ~ "Unknown"
  )) %>%
  # Format the Sampled Date to yyyy/mm/dd (removing time) and use it as collection_date
  mutate(collection_date = format(as.Date(`Sampled Date`, format = "%m/%d/%Y"), "%Y/%m/%d")) %>%
  # Now use the newly created County column to create geo_loc_name and other transformations
  mutate(library_ID = paste0(`Label Id`, "-001"),
         submission_id = `Label Id`,
         geo_loc_name = paste0("USA:Delaware, ", County, " County"),
         ww_sample_type = `Collection Method`,
         upload_tag = upload_tag_value,  # Dynamically generated upload tag
         title = "COVID-19 wastewater WGS",
         library_strategy = "WGS",
         library_source = "VIRAL RNA",
         library_selection = "PCR",
         library_layout = "paired",
         platform = "ILLUMINA",
         instrument_model = "Illumina MiSeq",
         design_description = "Qiagen kit",
         filetype = "fastq",
         bioproject = "PRJNA1090845",
         isolation_source = "unknown",
         ww_population = "unknown",
         ww_sample_duration = "unknown",
         ww_sample_matrix = "raw wastewater",
         ww_surv_target_1 = "SARS-CoV-2",
         ww_surv_target_1_known_present = "yes",
         organism = "wastewater metagenome") %>%
  # Now select the final columns you need
  select(`entity:sample_id`, 
         library_ID, 
         title, 
         library_strategy, 
         library_source, 
         library_selection, 
         library_layout, 
         platform, 
         instrument_model, 
         design_description, 
         filetype, 
         submission_id, 
         bioproject, 
         collection_date,  # Now in yyyy/mm/dd format
         geo_loc_name, 
         isolation_source, 
         ww_population, 
         ww_sample_duration, 
         ww_sample_matrix, 
         ww_sample_type, 
         ww_surv_target_1, 
         ww_surv_target_1_known_present, 
         upload_tag, 
         organism 
         ) %>%
  distinct()  # Remove duplicate rows

# Write the final merged file to a CSV
fwrite(final_data, "merged_output_ww.tsv", sep = "\t")
View(final_data)

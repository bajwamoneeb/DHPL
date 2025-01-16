library(readxl)
library(readr)
library(dplyr)
library(ggplot2)
library(data.table)
library(scales)
library(tidyverse)
library(lubridate)

for_graph_data <- read_excel("variants biweekly.xlsx")

x = for_graph_data %>%
  group_by(month = floor_date(Date_of_run, 'month'), pango_lineage) %>%
  summarise(rec_count = n()) %>%
  mutate(freq = round(rec_count / sum(rec_count), 3))

y = x %>%
  group_by(month) %>%
  mutate(countT = sum(rec_count)) %>%
  group_by(pango_lineage, add = TRUE) %>%
  mutate(per = round(100 * rec_count / countT, 4))  # Keep 'per' numeric

write_tsv(y, "graph1.tsv")

graph_data1 <- fread("graph1.tsv")
graph_data = graph_data1 %>% filter(month > "2024-8-1")

# Ensure pango_lineage is character type
graph_data[, pango_lineage := as.character(pango_lineage)]

# Replace any blank, NA, or whitespace-only pango_lineage with "Other"
graph_data[, pango_lineage := trimws(pango_lineage)]
graph_data[, pango_lineage := ifelse(is.na(pango_lineage) | pango_lineage == "", "Other", pango_lineage)]

# Replace low-percentage lineages with "Other"
graph_data[, pango_lineage := ifelse(per < 0.93, "Other", pango_lineage)]

# Aggregate "Other" entries
graph_data = graph_data %>%
  group_by(month, pango_lineage) %>%
  summarise(
    rec_count = sum(rec_count),
    per = sum(per),
    countT = unique(countT),
    freq = sum(freq)
  ) %>%
  ungroup()

# Plot the graph
z = ggplot(graph_data, aes(as.Date(month), per, fill = pango_lineage, label = pango_lineage)) +
  geom_bar(stat = 'identity') +
  geom_text(size = 3.9, position = position_stack(vjust = 0.5)) +
  xlab("Date of Sequencing") +
  ylab("Percent (%) Share of Total Lineages") +
  theme(legend.key.size = unit(3, 'mm')) +
  scale_x_date(date_breaks = "1 month", date_labels = "%b %Y") +
  guides(fill = guide_legend(title = "Variant (Pango Lineage)")) +
  labs(title = "COVID-19 Variants Over Time (DPHL WGS Data)") +
  theme(
    plot.title = element_text(size = 20, hjust = .5),
    axis.title.x = element_text(size = 17, margin = unit(c(3, 0, 0, 0), "mm")),
    axis.title.y = element_text(size = 17),
    axis.text = element_text(size = 14),
    legend.title = element_text(size = 10),
    legend.text = element_text(size = 9),
    panel.background = element_rect(fill = 'white'),
    panel.grid.major = element_blank()
  )
z

library(readxl)
library(readr)
library(dplyr)
library(ggplot2)
library(tidyverse)

for_graph_data <- read_excel("for_graph_data.xlsx")
for_graph_data$month=format(as.Date(for_graph_data$collection_date), "%Y-%m")
x = for_graph_data %>%
  group_by(nextclade_clade, month) %>%
  summarise(rec_count = n()) %>%
  mutate(freq = round(rec_count / sum(rec_count), 3))
arrange(desc(month), desc(freq))

y = x %>%
  group_by(month) %>%
  mutate(countT = sum(rec_count)) %>%
  group_by(nextclade_clade, add = TRUE) %>%
  mutate(per = paste0(round(100 * rec_count / countT, 2), '%'))
write_tsv(y, "graph1.tsv")

graph_data <- read_tsv("graph1.tsv")

x =ggplot(graph_data, aes(month, per, fill = 
  nextclade_clade)) + geom_bar(stat='identity') +
  xlab("Collection Date") +
  ylab("Percent") +
  guides(fill = guide_legend(title = "Variant (Nextclade clade)")) +
  labs(title="COVID-19 Variants Over Time in Delaware") + 
  theme(plot.title = element_text(size=20,hjust = .5), axis.title.x = 
  element_text(size=15, margin = unit(c(3, 0, 0, 0), "mm")), 
  axis.title.y = element_text(size=15), 
  axis.text = element_text(size=12), legend.title = element_text(size=14), 
  legend.text = element_text(size=12),panel.background = element_rect(fill = 'white'),
  panel.grid.major = element_blank())
x

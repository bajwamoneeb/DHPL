library(readxl)
library(readr)
library(dplyr)
library(ggplot2)
library(data.table)
library(scales)
library(tidyverse)

for_graph_data <- read_excel("variants biweekly.xlsx")

x = for_graph_data %>%
  group_by (month= floor_date(Date_of_run, 'month'), pango_lineage) %>%
  summarise(rec_count = n()) %>%
  mutate(freq = round(rec_count / sum(rec_count), 3))

y = x %>%
  group_by(month) %>%
  mutate(countT = sum(rec_count)) %>%
  group_by(pango_lineage, add = TRUE) %>%
  mutate(per = paste0(round(100*rec_count / countT, 4)))
write_tsv(y, "graph1.tsv")

graph_data1 <- fread("graph1.tsv")
graph_data = graph_data1 %>% filter(month > "2022-12-15")

z =ggplot(graph_data, aes(as.Date(month), per, fill = 
                            pango_lineage, label = pango_lineage)) + geom_bar(stat='identity') +
  geom_text(size = 3.2, position = position_stack(vjust = 0.5)) +
  xlab("Date of Sequencing") +
  ylab("Percent (%) Share of Total Lineages") +
  theme(legend.key.size = unit(3, 'mm')) +
  scale_x_date(date_breaks = "1 month", date_labels =  "%b %Y")+
  guides(fill = guide_legend(title = "Variant (Pango Lineage)")) +
  labs(title="COVID-19 Variants Over Time (DPHL WGS Data)") + 
  theme(plot.title = element_text(size=23,hjust = .5), axis.title.x = 
          element_text(size=18, margin = unit(c(3, 0, 0, 0), "mm")), 
        axis.title.y = element_text(size=18), 
        axis.text = element_text(size=15), legend.title = element_text(size=14),
        legend.text = element_text(size=13),panel.background = element_rect(fill = 'white'),
        panel.grid.major = element_blank())
z

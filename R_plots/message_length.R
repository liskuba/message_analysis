
library(readr)
library(ggplot2)
library(dplyr)

# sciezka do katalogu z csv przygotowanymi w pythonie
path <- "../data_preparation/data"

messages <- read_csv(paste(path,"/Bartek_Sawicki_1.csv",sep = ''))
messages <- rbind(messages, read_csv(paste(path,"/Kuba_Lis_1.csv",sep = '')))

summary(messages)

messages %>%
  filter(length <=150)%>%
  ggplot()+
  geom_histogram(aes(x = length),bins = 30)+
  xlab("message length") + 
  ylab("number of messages")


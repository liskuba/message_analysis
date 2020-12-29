
library(readr)
library(ggplot2)
library(dplyr)

# sciezka do katalogu z csv przygotowanymi w pythonie
path <- "../data_preparation/data"

messages <- read_csv(paste(path,"/messages_Bartek_Sawicki.csv",sep = ''))
#messages <- rbind(messages, read_csv(paste(path,"/messages_Kuba_Lis.csv",sep = '')))
#messages <- rbind(messages, read_csv(paste(path,"/messages_Kuba_Koziel.csv",sep = '')))

notifications <- read_csv(paste(path,'/notifications_Bartek_Sawicki.csv',sep = ''))

notifications %>%
  ggplot()+
  geom_bar(aes(x = floored_hour),stat = "count")+
  xlab("notification hour") + 
  ylab("number of notifications")


summary(messages)

messages %>%
  ggplot()+
  geom_bar(aes(x = floored_hour),stat = "count")+
  xlab("message hour") + 
  ylab("number of messages") -> plot

plot

plot + facet_wrap(~day_of_the_week)


messages %>%
  ggplot()+
  geom_point(aes(x = length, y = floored_hour))
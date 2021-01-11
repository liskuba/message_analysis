library(readr)
library(dplyr)
library(stringr)

path <- "data_preparation/data"

messages_Kuba_Lis <- read_csv(paste(path,"/messages_Kuba_Lis.csv",sep = ''))
messages_Bartek_Sawicki <- read_csv(paste(path,"/messages_Bartek_Sawicki.csv",sep = '')) 
messages_Jakub_Koziel <- read_csv(paste(path,"/messages_Jakub_Kozieł.csv",sep = '')) 


messages_Kuba_Lis_emoji <- messages_Kuba_Lis %>%
  filter(!is.na(emojis))
messages_Bartek_Sawicki_emoji <- messages_Bartek_Sawicki %>%
  filter(!is.na(emojis))
messages_Jakub_Koziel_emoji <- messages_Jakub_Koziel %>%
  filter(!is.na(emojis))

all_messages <- rbind(cbind(messages_Kuba_Lis,person = "Kuba L."), rbind(cbind(messages_Bartek_Sawicki,person = "Bartek S."),cbind(messages_Jakub_Koziel,person = "Kuba K.")))

messages <- rbind(
  rbind(messages_Kuba_Lis_emoji, messages_Bartek_Sawicki_emoji),
  messages_Jakub_Koziel_emoji
)

all_emojis <- read_csv(paste0(path, "/all_emoji.csv"))
names(all_emojis) <- c("emoji", "url", "label")
counter <- data.frame("emoji" = NULL, "usage" = NULL,
                      "url" = NULL, "label" = NULL)

for(i in 1:nrow(all_emojis)) {
  emoji <- all_emojis[[i,"emoji"]]
  counter[i, "emoji"] <- emoji
  counter[i, "usage"] <- sum(str_count(messages$emojis, emoji))
  counter[i, "url"] <- all_emojis[i,"url"]
  counter[i, "label"] <- all_emojis[i,"label"]
}

all_emojis <- counter %>%
  filter(usage >= 6)

plot_emoji <- function(start, end, ppl) {
  
  emojis <- data.frame(
    "emoji" = NULL,
    "url" = NULL,
    "label" = NULL
  )
  
  messK <- messages_Jakub_Koziel_emoji %>%
    filter(timestamp > 1000 * as.numeric(as.POSIXct(
      as.character(start), format="%Y-%m-%d"
    ))) %>%
    filter(timestamp < 1000 * as.numeric(as.POSIXct(
      as.character(end), format="%Y-%m-%d"
    )))
  
  messL <- messages_Kuba_Lis_emoji %>%
    filter(timestamp > 1000 * as.numeric(as.POSIXct(
      as.character(start), format="%Y-%m-%d"
    ))) %>%
    filter(timestamp < 1000 * as.numeric(as.POSIXct(
      as.character(end), format="%Y-%m-%d"
    )))
  
  messS <- messages_Bartek_Sawicki_emoji %>%
    filter(timestamp > 1000 * as.numeric(as.POSIXct(
      as.character(start), format="%Y-%m-%d"
    ))) %>%
    filter(timestamp < 1000 * as.numeric(as.POSIXct(
      as.character(end), format="%Y-%m-%d"
    )))
  
  
  for (mess in paste0(rep("mess", length(ppl)),
                      str_sub(ppl, -2, -2))) {
    mess <- get(mess)
    counter <- data.frame("emoji" = all_emojis[,1],
                          "usage" = rep(0, length(all_emojis[,1])),
                          "url" = all_emojis[,"url"],
                          "label" = all_emojis[,"label"])
    
    for(i in 1:nrow(all_emojis)) {
      counter[i, "usage"] <- sum(
        str_count(mess$emojis, counter[i,"emoji"])
      )
    }
    n <- nrow(emojis)
    p <- (length(ppl)**2-9*length(ppl)+24)/2
    emojis <- rbind(emojis, arrange(counter, desc(usage)) %>%
                      slice(1:p) %>%
                      filter(usage > 0) %>%
                      select(emoji, url, label))
  }
  
  # najczesciej uzywane emojis
  emojis <- emojis %>% distinct(emoji, .keep_all = TRUE)
  
  df <- data.frame(
    "person" = rep(ppl, each = nrow(emojis)),
    "emoji" = rep(emojis$emoji, times = length(ppl)),
    "label" = rep(emojis$label, times = length(ppl)),
    "numberOfUses" = rep(0, length(ppl)*nrow(emojis))
  )
  
  
  for(i in 1:nrow(df)) {
    df[i, "numberOfUses"] <- sum(
      str_count(
        get(paste0('mess', str_sub(df[[i, "person"]],-2,-2)))$emojis,
        df[i,"emoji"]
      )
    )
  }

  
  
  df %>%
    ggplot(aes(fct_reorder(label, numberOfUses, .desc = TRUE), numberOfUses,
               fill = person)) +
    geom_col(position = position_dodge()) +
    theme_minimal() +
    labs(x = NULL) +
    scale_fill_manual(values=c("Kuba L." = '#5741A6',
                               "Kuba K." = '#F2133C',
                               "Bartek S." = '#F2BD1D')) +
    scale_y_continuous(expand = c(0, 0))+
    theme_solarized() +
    theme(axis.text.x = element_markdown())
}

# tab 3 functionality
plot_activity_time <- function(start, end, ppl, weekday){
  if(weekday != "all"){
    tmp_df <- all_messages %>%
      filter(day_of_the_week == weekday)
  }else{
    tmp_df <- all_messages
  }
  tmp_df %>% filter(person %in% ppl) %>%
    filter(date>start)%>%
    filter(date<end)%>%
    ggplot()+
    geom_bar(aes(x = floored_hour, group = person, fill = person),stat = "count", position = position_dodge(preserve = 'single'))+
    xlab("message hour") + 
    ylab("number of messages")+
    scale_y_continuous(expand = c(0, 0))+
    scale_fill_manual(values=c("Kuba L." = '#5741A6',
                               "Kuba K." = '#F2133C',
                               "Bartek S." = '#F2BD1D'))+
    theme_solarized()
}

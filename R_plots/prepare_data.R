library(readr)
library(dplyr)
library(stringr)

path <- "data_preparation/data"

messages_Kuba_Lis_emoji <- read_csv(paste(path,"/messages_Kuba_Lis.csv",sep = '')) %>%
  filter(!is.na(emojis))
messages_Bartek_Sawicki_emoji <- read_csv(paste(path,"/messages_Bartek_Sawicki.csv",sep = '')) %>%
  filter(!is.na(emojis))
messages_Jakub_Koziel_emoji <- read_csv(paste(path,"/messages_Jakub_Kozieł.csv",sep = '')) %>%
  filter(!is.na(emojis))

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
  
  messK <- messages_Jakub_Koziel_emoji %>%
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
    scale_fill_manual(values=c('#F2133C','#5741A6', '#F2BD1D')) +
    theme_solarized() +
    theme(axis.text.x = element_markdown())
}

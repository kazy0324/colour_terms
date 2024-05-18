rm(list=ls(all.names=TRUE))
library(tidyverse)
library(ggplot2)
library(reshape2)
library(forcats)

result_path <- "/Users/kazy/Library/CloudStorage/Dropbox/Script/_Ruby/__colour_terms/ruby/nucc_colour_terms.csv"

result <- read_csv(result_path)
subsetted_result <- subset(result, subset = freq >0)

nrow(subsetted_result)/nrow(result)
ggplot(subsetted_result, aes(y = term, x = freq), group = hex_code, colour = hex_code) +
  geom_bar(stat = "identity") +
  theme_gray(base_family = "HiraKakuPro-W3") + 
  labs(x = "Frequency in Corpus", y = "Japanese colour terms")


ggplot(subsetted_result, aes(x = freq, y = hex_code), group = hex_code, colour = hex_code) +
  geom_bar(stat = "identity") +
  theme_gray(base_family = "HiraKakuPro-W3") + 
  labs(x = "Frequency in Corpus", y = "Japanese colour terms")
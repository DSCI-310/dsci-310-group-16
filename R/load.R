library(tidyverse)

atp_data_frame <- read_csv("https://drive.google.com/uc?export=download&id=1fOQ8sy_qMkQiQEAO6uFdRX4tLI8EpSTn")

write.csv(atp_data_frame,'data/atp2017-2019-1.csv')


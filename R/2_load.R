#load file
atp_data_frame <- read.csv(
  "https://drive.google.com/uc?export=download&id=1fOQ8sy_qMkQiQEAO6uFdRX4tLI8EpSTn"
  )

atp_data_frame <- atp_data_frame[, -1]

write.csv(atp_data_frame,'data/atp2017-2019-1.csv', row.names = FALSE)


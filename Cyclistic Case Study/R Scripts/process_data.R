# Cyclistic Case study
# Data Processing
# Process the data aquired from the preparation step
# Dataset: final_dataset.csv

# set the default CRAN mirror 
options(repos = c(R = "https://cran.r-project.org"))

#install packages
install.packages('tidyverse')
install.packages("stringr")

# load the packages
library(tidyverse)
library(stringr)

# file path constants
x <- str_locate_all(getwd(), "/")[[1]]
x <- x[nrow(x), 'end'][[1]]

# out path
PROCESS_DATA_OUT_PATH <- '../output/process/'
latest_file <- '../output/prepare/data/output/final_dataset_prepare.csv' 

# read the dataset file
print('read the dataset file')
df <- read_csv(latest_file)
print('data file read sucessfully')

# remove duplicates
print('removing duplicates...')
new_df <- distinct(df)

# cleaning data
print('cleaning the data....')
# filter out df where ride length is less than zero
new_df <- new_df %>% filter(difftime(ended_at,started_at) > 0)

print(nrow(new_df))

print('generating final dataset....')

# export the csv file
dir.create(PROCESS_DATA_OUT_PATH, recursive=TRUE)
file_path <- paste0(PROCESS_DATA_OUT_PATH, 'processed_dataset.csv')
write_csv(new_df, file=file_path ,append=FALSE)

print(paste('final dataset generated successfully at location:', file_path, sep=" "))

# Data Preparation (Cyclistic Case study)
# Preparing the data into a single dataset
# Dataset year: 2023
# Dataset quarter: 3rd

# set the default CRAN mirror 
options(repos = c(R = "https://cran.r-project.org"))

# Install the required packages
install.packages('tidyverse')
install.packages("sets")

# load the packages
library(tidyverse)
library(sets)

# path constants
BASE_PATH <- 'https://divvy-tripdata.s3.amazonaws.com/'
DATA_FILES <- c('202301-divvy-tripdata.zip', '202302-divvy-tripdata.zip', '202303-divvy-tripdata.zip',
                '202304-divvy-tripdata.zip', '202305-divvy-tripdata.zip', '202306-divvy-tripdata.zip',
                '202307-divvy-tripdata.zip', '202308-divvy-tripdata.zip', '202309-divvy-tripdata.zip',
                '202310-divvy-tripdata.zip')

SAVE_PATH_ZIP <- '../output/prepare/data/zip/'
SAVE_PATH_CSV <- '../output/prepare/data/csv/'
SAVE_PATH_OUT <- '../output/prepare/data/output/'

print("data preparation started....")

# delete existing data to avoid errors
unlink('../output/prepare/data/csv/', recursive = TRUE)

# create the base dir for files
print("creating the necessary paths...")
dir.create(SAVE_PATH_ZIP, recursive = TRUE)
dir.create(SAVE_PATH_CSV, recursive = TRUE)
dir.create(SAVE_PATH_OUT, recursive=TRUE)

# download the data files
print("Downloading the datasets...")
for (file in DATA_FILES){
  url <- paste0(BASE_PATH, file)
  download.file(url, paste0(SAVE_PATH_ZIP, file), mode="wb")
}
print("Datasets downloaded successfully...")

# unzip the data files
print("unzipping the data files...")
for (file in DATA_FILES){
  source_path <- paste0(SAVE_PATH_ZIP, file)
  unzip(source_path, exdir = SAVE_PATH_CSV)
}
print("data files unzipped successfully...")

print("deleting the zip files...")
unlink('../output/prepare/data/zip/', recursive = TRUE)
print("zip files deleted successfully...")

# read the csv files
files_csv <- list()
print("reading the data files...")
for (file in DATA_FILES){
  file_name <- paste0(substr(file, 0, nchar(file) -3) , "csv")
  file_csv <- read_csv(paste0(SAVE_PATH_CSV, file_name))
  files_csv <- append(files_csv, list(file_csv))
}
print("data files read successfully...")

# check if all files have same columns
set_1 <- set(colnames(files_csv[[1]]))
flag <- 0

for(i in 2 : length(files_csv)){
  set_2 <- set(colnames(files_csv[[i]]))
  if (length(setdiff(set_1, set_2)) != 0){
    flag <- 1
    print("cannot merge the datasets, mismatching columns!!")
    break
  }
}

if(flag == 0){
  print('Datasets can be merged, columns match!!!')

  # merge the datasets
  final_dataset <- do.call(rbind, files_csv)
  print("datasets merged!!!")
  
  # data validation (match the column and rows count)
  sum_rows <- do.call(sum, lapply(files_csv, nrow))

  if(sum_rows == nrow(final_dataset) && length(setdiff(set(colnames(final_dataset)), 
                                                       set(colnames(files_csv[[1]])))) == 0){
    print("validation successful after merge!!")
    
    # export the final dataset
    output_file_path <- paste0(SAVE_PATH_OUT, 'final_dataset_prepare.csv')
    write_csv(final_dataset, file=output_file_path, append=FALSE)
    print(paste0("prepared dataset file generated at location: ", output_file_path))
    
  }else{
    print('validation failed')
  }
}



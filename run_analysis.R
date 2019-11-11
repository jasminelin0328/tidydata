#**********************************************************
# Initial setup
#**********************************************************

# Set working directy, change this filepath to suit
setwd("D:\\Coursera\\datascience\\Module 3 - Data Wranling\\Assignment")

# Packages
library(dplyr)
#**********************************************************
# Task 1 merge training and test sets
#**********************************************************

# Step 1 Download zip file
url = "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
file = "dataset.zip"
download.file(url,file,method="curl")
date.downloaded = date()

# Step 2 Unzip data files
unzip(file, junkpaths = TRUE) #junkpaths to remove having to folder dive
rm(file) # free up workspace memory

# Step 3 read files into data frames

test.set = read.table("X_test.txt") 
train.set = read.table("X_train.txt")

# Step 4 merge together into single data frame (append one beneath the other)
full.set = rbind.fill(train.set,test.set) # big boi data set (go huge)

#**********************************************************
# Task 2 extracting only mean and s.d measurements
#**********************************************************

# features_info.txt shows all mean should have string "mean()"
# and std() for mean and standard deviation

# Step 1 read in the variable (column) names from file
features = read.table("features.txt",col.names = c("rowid","feature"))

# Step 1 create regular expression to find "mean" or "std" in strings
regex = "[Mm][Ee][Aa][Nn]|[Ss][Tt](\\.)?[Dd]" # mean or std variations as chars

# Step 2 search for "mean" or "std" in the variable names
subsetcols = grepl(regex,features$feature) # true if that col name is a match

# Step 3 extract only the columns that were a match into a new data frame
full.subset = full.set[,subsetcols] # extract only columns that matched

#**********************************************************
# Task 3 change activity names from numbers to descriptions
#**********************************************************
# Step 1 open file mapping activity to ID number
activities = read.table("activity_labels.txt",col.names = c("id","activity"))

# Step 2 open activity data sets
test.labels = read.table("y_test.txt") 
train.labels = read.table("y_train.txt")

# Step 3 convert activity numbers to factors with descriptions
test.labelsf = factor(test.labels$V1,
                      levels = activities$id, labels =activities$activity)

train.labelsf = factor(train.labels$V1,
                      levels = activities$id, labels =activities$activity)
# Confirm it works
table(test.labelsf)
table(train.labelsf)
# Yat it works!


#**********************************************************
# Task 4 apply labels to variables (columns)
#**********************************************************

# Step 1 exctract only the variable names (not the row ID)
variables = as.character(features$feature)

# Step 2 clean this into tidy data variable names
variables.clean = tolower(variables) # make all lower case

# Step 3 apply these as column names to data set
colnames(full.set) = variables.clean

#**********************************************************
# Task 5 means for each activity and each subject
#**********************************************************

# Step 1 add new column "activity" to each data set
test.set$activity = test.labelsf
train.set$activity = train.labelsf

# Step 2 add new column with subject info
# 2a read in subject info
test.subject = read.table('subject_test.txt', col.names = "subject")
train.subject = read.table('subject_train.txt', col.names = "subject")

# 2b add new column to each data set
test.set$subject = test.subject$subject
train.set$subject = train.subject$subject

# Step 3 merge new sets into single data set using task 1 method
full.set = bind_rows(train.set,test.set)

# Step 4 apply column names
colnames(full.set) = c(variables.clean,"activity","subject") # variables + activity column

# Step 5 subset using task 2 method
full.subset = full.set[,subsetcols] # extract only columns that matched (now with activity)

# Step 6 create a "row" for each combination of activity and subject

dfnew <- full.subset %>%
        group_by(subject,activity) %>%
        summarise_all(mean)
head(dfnew)
# nicely done dplyr!#


# Set working directy, change this filepath to suit
setwd("E:\\Coursera\\Datascience\\Module 3\\Assignment")

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

# Step 3 read in files

# 3a list of variables (column names)
features = read.table("features.txt",col.names = c("rowid","feature"))
variable.names = as.character(features$feature)

# 3b data sets (training and test)
test.set = read.table("X_test.txt",col.names = variable.names) 
train.set = read.table("X_train.txt", col.names = variable.names)

# 3c data activity labels (gives the factor level only, no level)
test.labels = read.table("y_test.txt") 
train.labels = read.table("y_train.txt")

# 3d mapping of activity id to activity
activities = read.table("activity_labels.txt",col.names = c("id","activity"))

# Step 4 convert activities to factor with string labels
test.labels = factor(test.labels,
                     levels = activities$id, labels =activities$activity)
train.labels = factor(train.labels,
                      levels = activities$id, labels =activities$activity)

# Step 5 append the activity to each data set as a new column called "activity"
test.set$activity = test.labels
train.set$activity = train.labels

# Step 6 create new data frame with training and test sets merged
library(plyr)
bbd = rbind.fill(train.set,test.set) # big boi data set (go huge)

# Step 6a check I haven't cooked it
ncol(bbd) == ncol(train.set)
ncol(bbd) == ncol(test.set)
nrow(bbd) == (nrow(train.set) + nrow(test.set))

#**********************************************************
# Task 2 extracting only mean and s.d measurements
#**********************************************************

# features_info.txt shows all mean should have string "mean()"
# and std() for mean and standard deviation

# Step 1 create regular expression to find "mean" or "std" in strings
regex = "[Mm][Ee][Aa][Nn]|[Ss][Tt](\\.)?[Dd]" # mean or std variations as chars

# Step 2 search for "mean" or "std" in the variable names
subsetcols = grepl(regex,names(bbd)) # true if that col name is a match

# Step 3 extract only the columns that were a match into a new data frame
bbd.subset = bbd[,subsetcols] # extract only columns


#**********************************************************
# Task 3 name activities in the data set descriptvely
#**********************************************************
# Already completed in step 4 of Task 1 by converting activities from numbers
# into labelled factors (e.g. "WALKING", "RUNNING" etc)
table(bbd$activity)
head(bbd$activity)
levels(bbd$activity)
labels(bbd$activity)

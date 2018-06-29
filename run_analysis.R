library(dplyr)

fName <- "data.zip"
fURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
fPath <- "UCI HAR Dataset"

if (!file.exists(fName)) {
  download.file(fURL, fName, method="curl")
}
if (!file.exists(fPath)){
  unzip(fName)
}

#activity labels
actLabels <- read.table("UCI HAR Dataset/activity_labels.txt")
#raw features data
feat <- read.table("UCI HAR Dataset/features.txt")
#columns we needed (std and mean values)
features <- grep(".*mean.*|.*std.*", feat[,2])
#format column names
colsName <- gsub('[-()]', '', gsub('-std', 'Std', gsub('-mean','Mean',as.vector(as.character(feat[features,2])))))

#read train dataset
trFeatures <- tbl_df(read.table("UCI HAR Dataset/train/X_train.txt")[features])
trSubjects <- tbl_df(read.table("UCI HAR Dataset/train/subject_train.txt"))
trActivities <- tbl_df(read.table("UCI HAR Dataset/train/Y_train.txt"))

#read test dataset
tsFeatures <- tbl_df(read.table("UCI HAR Dataset/test/X_test.txt")[features])
tsSubjects <- tbl_df(read.table("UCI HAR Dataset/test/subject_test.txt"))
tsActivities <- tbl_df(read.table("UCI HAR Dataset/test/Y_test.txt"))

#merge train, test data and remove other tables
mergedData <- bind_rows(bind_cols(trSubjects, trActivities, trFeatures), bind_cols(tsSubjects, tsActivities, tsFeatures))
names(mergedData) <- c("Subject", "Activity", colsName)
rm(trFeatures,trSubjects,trActivities,tsFeatures,tsSubjects, tsActivities)

#Name factor levels of Activities
mergedData <- mutate(mergedData, Activity = factor(Activity, actLabels[,1], actLabels[,2]))

#Create a second, independent tidy set with the average of each variable for each activity and each subject
mergedDataMeans <- mergedData %>% group_by(Subject, Activity) %>% summarize_all(mean)

#write output file
write.table(mergedDataMeans, "tidy_data.txt", row.names = FALSE, quote = FALSE)

#####################################################################################
# Getting and Cleaning Data Course Project - Analyze smartphone data
#####################################################################################

library(data.table)
library(tidyr)
library(plyr)
library(dplyr)

# 1. Define url and local path for smartphone data

  dataUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
  
  dataPath <- "rawdata.zip"

# 2. Download and Unzip data, and set working directory to the new download

  download.file(dataUrl,dataPath)
  
  unzip("rawdata.zip")

# 3. Read data tables into local workspace, including both "test" and "train" datasets

  # a. Read activity label key and feature labels into script
    actLabels <- read.table("UCI HAR Dataset/activity_labels.txt")
    features <- read.table("UCI HAR Dataset/features.txt")

  # b. Read "y" data, which contains the activity number. 
    yTest <- read.table("UCI HAR Dataset/test/Y_test.txt")
    yTrain <- read.table("UCI HAR Dataset/train/Y_train.txt")
    
    # i. Combine and merge with actLabels to gain descriptive activity names
      yAll <- merge(rbind(yTest,yTrain),actLabels,by="V1")[c(2)]
      names(yAll) <- c("activity")
    
  # c. Read "subj" data, which contains the subject number
    subjTest <- read.table("UCI HAR Dataset/test/subject_test.txt")
    subjTrain <- read.table("UCI HAR Dataset/train/subject_train.txt")
    
    # i. Combine and name
      subjAll <- rbind(subjTest,subjTrain)
      names(subjAll) <- "subject"
      
  # d. Read "X" data, which contains all variables
    xTest <- read.table("UCI HAR Dataset/test/X_test.txt")
    xTrain <- read.table("UCI HAR Dataset/train/X_train.txt")
    
    # i. Combine and apply variable names from features. Remove "BodyBody" (apparent) error in variable names.
      xAll <- rbind(xTest,xTrain)
      names(xAll) <- gsub("BodyBody","Body",features[,2])
      
    # ii. Keep only mean and stdev variables.
      xAll <- xAll[,grep("mean\\(\\)|std\\(\\)",names(xAll))]
      
  # e. Combine activity names, subjects, and variables into one data frame
    dataAll <- cbind(subjAll,yAll,xAll)


# 4. Make data tidy
  
  # a. Turn the columns-as-variables into variables-as-columns, separating three components by "-"
    dataAllTidy <- gather(dataAll,feature,value,3:ncol(dataAll)) %>%
                        separate(feature, into = c("signal","calculation","direction"), sep = "-" )
  
  # b. Put periods into the signal column to allow for further splitting.
    dataAllTidy$signal <- gsub("([a-z])([A-Z])","\\1\\.\\2",dataAllTidy$signal)
    
  
  # c. Use periods to split signal column into specifics
    dataAllTidy <- separate(dataAllTidy, signal, into = c("domain","acceleration","source","firstDerivation","secondDerivation"))
    
  # e. Improve variable columns to be more descriptive
    
    # i. Remove "()" from calculation column.
      dataAllTidy$calculation <- gsub("\\(\\)","",dataAllTidy$calculation)
      
    # ii. Describe "domain"
      dataAllTidy$domain <- gsub("t","time",dataAllTidy$domain)
      dataAllTidy$domain <- gsub("f","frequency",dataAllTidy$domain)
    
    # iii. Describe "source"
      dataAllTidy$source <- gsub("Acc","accelerometer",dataAllTidy$source)  
      dataAllTidy$source <- gsub("Gyro","gyroscope",dataAllTidy$source)
    
    # iv. Describe derived outputs
      dataAllTidy$firstDerivation <- gsub("Mag","magnitude",dataAllTidy$firstDerivation)  
      dataAllTidy$secondDerivation <- gsub("Mag","magnitude",dataAllTidy$secondDerivation)  
      
    # v. remove capitals from other columns
      dataAllTidy <- cbind(mutate_each(dataAllTidy[-length(names(dataAllTidy))],funs(tolower)),dataAllTidy[length(names(dataAllTidy))])
      
  # f. Add units
    dataAllTidy$unit <- NA
    
    dataAllTidy$unit[which(dataAllTidy$source=="accelerometer")] <- "g"
    dataAllTidy$unit[which(dataAllTidy$source=="gyroscope")] <- "rad/seg"
      
# 5. Calculate averages of each variable by subject and activity
    
  dataAllTidyAverages <- ddply(dataAllTidy, names(dataAllTidy)[-length(names(dataAllTidy))], summarize, meanValue = mean(value))
  
  write.table(dataAllTidyAverages,file="tidyAverages.txt",row.names=FALSE)


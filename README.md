Getting and Cleaning Data - Course Project
===========
Jon Martindill
-----------
This README file describes the process of downloading, cleaning, and analyzing Samsung smartphone data. This process was created as a project for the Coursera course Getting and Cleaning Data. 

This repository contains 4 files:

1. README.txt
2. run_analysis.R
3. tidyAverages_codebook.txt
4. tidyAverages.txt

The original dataset on which this analysis is based, including its own readme and codebook, can be found here: https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip

The R script (run_analysis.R) uses the raw data and accomplishes the following 5 goals:

1. Merges the training and the test sets to create one data set.
2. Extracts only the measurements on the mean and standard deviation for each measurement.
3. Uses descriptive activity names to name the activities in the data set
4. Appropriately labels the data set with descriptive variable names.
5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

### Step by step guide to run_analysis.R

1. Define the url and download path for the smartphone data
2. Download the dataset and unzip the file to working directory
3. Import the label key, variable names, and raw data into the workspace. 
    * Use "cbind" and "rbind" functions to combine all parts of the data into one complete dataset(goal 1)
    * Merge the "label" component of the data with the "activity_labels" key table to replace numeric activity codes with descriptive activity strings (goal 3)
    * Use the names() function along with the vector of variable names from the "features" file to replace the column names with descriptive variables (goal 4)
    * Use grep to identify all of the variable colums that contain the strings "mean()" or "std()". Then, subset the dataset to remove all other variables (goal 2)
4. Make the dataset tidy by using separate() to move the variables stored as columns into variables within columns.
    * The variables use hyphens to split the source from the calculation applied (mean or std) from the direction (x,y,z, or na). So, first we can use gather to move column names into a "feature" column, and then separate with sep="-" to split into those three columns.
    * The "source" can be split further by using the lowerCamelCase format of that variable. In order to use split, a separating character must be first inserted between each word. So, we can use gsub to identify where a lowercase and uppercase meet, then replace that two-character string with a new string that is identical except for a new separating period. e.g. "aA" would be replaced by "a.A"
    * Now that the words are split properly, we can use separate on sep="." to split the source variable into 5 different columns.
    * Finally, we can add units based on the fact that when source = "Gyroscope", the units must be "rad/sig", and that when source = "accelerometer", the units must be "g".
5. Calculating an average value based on each subject/activity/variable combination is now an easy applicaiton of ddply.

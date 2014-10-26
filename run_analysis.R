# The UCI HAR Dataset was downloaded from 
# https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip 
# October 10, 2014 on or about 10pm CDT
# with the following goals in mind
# 1. Merge the training and the test sets to create one data set.
# 2. Extract only the measurements on the mean and standard deviation for each measurement. 
# 3. Use descriptive activity names to name the activities in the data set
# 4. Appropriately label the data set with descriptive activity names. 
# 5. Creates a second, independent tidy data set with the average of each variable for each activity and each subject. 

# Part 1. Merge the training and the test sets to create one data set.
# The unzipped UCI HAR Dataset is in a local directory
setwd('/Users/daviddisko/datasciencecoursera/UCI HAR Dataset')

# Read in the data from the following text files
# main directory features.txt, activity_labels
# train directory subject_train, x_train, y_train
features     = read.table('./features.txt',header=FALSE)
activityType = read.table('./activity_labels.txt',header=FALSE)
subjectTrain = read.table('./train/subject_train.txt',header=FALSE)
xTrain       = read.table('./train/x_train.txt',header=FALSE)
yTrain       = read.table('./train/y_train.txt',header=FALSE)

# After the data is read in label column names
colnames(activityType)  = c('activityId','activityType')
colnames(subjectTrain)  = "subjectId"
colnames(xTrain)        = features[,2] 
colnames(yTrain)        = "activityId"

# Using cbind create a training dataset by merging yTrain, subjectTrain, and xTrain
trainingData = cbind(yTrain,subjectTrain,xTrain)

# Similar to the train data above load in the test data files
# files loaded subject_test, x_test, y_test
subjectTest = read.table('./test/subject_test.txt',header=FALSE)
xTest       = read.table('./test/x_test.txt',header=FALSE)
yTest       = read.table('./test/y_test.txt',header=FALSE) 

# After the data is read in label column names
colnames(subjectTest) = "subjectId"
colnames(xTest)       = features[,2] 
colnames(yTest)       = "activityId"

# Using cbind create a test dataset by merging yTest, subjectTest, and xTest
testData = cbind(yTest,subjectTest,xTest)

# Use rbind to combine training and test data to create a final data set
finalData = rbind(trainingData,testData)

# Using the abvoe created data set make a vector for the column names from finalData
colNames  = colnames(finalData)

# Part 2. Extract only the measurements on the mean and standard deviation for each measurement. 

# Using grep create a vector of logical values for ID, mean() & stddev() columns
logicalVector = (grepl("activity..",colNames) | 
                         grepl("subject..",colNames) | 
                         grepl("-mean..",colNames) & 
                         !grepl("-meanFreq..",colNames) & 
                         !grepl("mean..-",colNames) | 
                         grepl("-std..",colNames) & 
                         !grepl("-std()..-",colNames))

# Take the finalData table and reduce it using the above logicalVector
finalData = finalData[logicalVector==TRUE]

# Part 3. Use descriptive activity names to name the activities in the data set

# Merge finalData with acitivityType and update column names
finalData = merge(finalData,activityType,by='activityId',all.x=TRUE)
colNames  = colnames(finalData)

# Part 4. Appropriately label the data set with descriptive activity names. 

# Create a list of descriptive variable names and use this for new column names
for (i in 1:length(colNames)) 
{
        colNames[i] = gsub("\\()","",colNames[i])
        colNames[i] = gsub("-std$","StdDev",colNames[i])
        colNames[i] = gsub("-mean","Mean",colNames[i])
        colNames[i] = gsub("^(t)","time",colNames[i])
        colNames[i] = gsub("^(f)","freq",colNames[i])
        colNames[i] = gsub("([Gg]ravity)","Gravity",colNames[i])
        colNames[i] = gsub("([Bb]ody[Bb]ody|[Bb]ody)","Body",colNames[i])
        colNames[i] = gsub("[Gg]yro","Gyro",colNames[i])
        colNames[i] = gsub("AccMag","AccMagnitude",colNames[i])
        colNames[i] = gsub("([Bb]odyaccjerkmag)","BodyAccJerkMagnitude",colNames[i])
        colNames[i] = gsub("JerkMag","JerkMagnitude",colNames[i])
        colNames[i] = gsub("GyroMag","GyroMagnitude",colNames[i])
}
colnames(finalData) = colNames

# Part 5. Create a second, independent tidy data set with the average of each variable for each activity and each subject. 

# Set up a table of finalDataNoActivityType with no activityType column
finalDataNoActivityType  = finalData[,names(finalData) != 'activityType']

# Create a nearly final table using aggregate on finalDataNoActivityType
tidyData = aggregate(finalDataNoActivityType[,names(finalDataNoActivityType) != c('activityId','subjectId')],by=list(activityId=finalDataNoActivityType$activityId,subjectId = finalDataNoActivityType$subjectId),mean)

# Merge tidyData with activityType
tidyData = merge(tidyData,activityType,by='activityId',all.x=TRUE)

# Export tidyData
write.table(tidyData, './tidyData.txt',row.names=FALSE,sep='\t')
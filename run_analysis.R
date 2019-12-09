# To begin we downlaod the data from the source link

files <- "getdata_projectfiles_UCI Har Dataset.zip"

# We will then check if the files already exist in working directory.

if(!file.exists(files)) {
  filessource <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
  download.file(filessource, files, method = "curl")
}

# Then we check if the folder already exists in the working directory.

if (!file.exists("UCI Har Dataset")) {
  unzip(files)
}

# We then read the required tables into R and providing suitable column headings.

features <- read.table("UCI Har Dataset/features.txt", col.names = c("n", "functions"))
activities <- read.table("UCI Har Dataset/activity_labels.txt", col.names = c("code", "activity"))
subjecttrain <- read.table("UCI Har Dataset/train/subject_train.txt", col.names = "subject")
xtrain <- read.table("UCI Har Dataset/train/X_train.txt", col.names = features$functions)
ytrain <- read.table("UCI Har Dataset/train/y_train.txt", col.names = "code")
subjecttest <- read.table("UCI Har Dataset/test/subject_test.txt", col.names = "subject")
xtest <- read.table("UCI Har Dataset/test/X_test.txt", col.names = features$functions)
ytest <- read.table("UCI Har Dataset/test/y_test.txt", col.names = "code")

# Now that the data has been read into R, it is time to merge the training & test data to create a single data set.

X <- rbind(xtrain, xtest)
Y <- rbind(ytrain, ytest)
Subjects <- rbind(subjecttrain, subjecttest)
MergedDataSet <- cbind(Subjects, Y, X)

# Now that the training and testing data is in one data set, it is time to extract only the measurements for the mean and
# standard deviation for each measurement.

ExtractedData <- MergedDataSet %>% select(subject, code, contains("mean"), contains("std"))

# Now that the data has been extracted, it is time to provide descriptive names to the activities.

ExtractedData$code <- activities[ExtractedData$code, 2]

# Now that the activities have descriptive names, it is time to provide the data set with descriptive variable names

names(ExtractedData) [2] = "activity"
names(ExtractedData) <- gsub("Acc", "Accelerometer", names(ExtractedData))
names(ExtractedData) <- gsub("angle", "Angle", names(ExtractedData))
names(ExtractedData) <- gsub("BodyBody", "Body", names(ExtractedData))
names(ExtractedData) <- gsub("^f", "Frequency", names(ExtractedData))
names(ExtractedData) <- gsub("-freq", "Frequency", names(ExtractedData))
names(ExtractedData) <- gsub("gravity", "Gravity", names(ExtractedData))
names(ExtractedData) <- gsub("Gyro", "Gyroscope", names(ExtractedData))
names(ExtractedData) <- gsub("Mag", "Magnitude", names(ExtractedData))
names(ExtractedData) <- gsub("-mean", "Mean", names(ExtractedData))
names(ExtractedData) <- gsub("-std", "STD", names(ExtractedData))
names(ExtractedData) <- gsub("^time", "Time", names(ExtractedData))
names(ExtractedData) <- gsub("tBody", "TimeBody", names(ExtractedData))

#With the data set we have created during the above steps, we will not create a second, independent data set. THis data set will contain
# the average of each variable for each activity and each subject.

IndependentDataSet <- ExtractedData %>%
  group_by(subject, activity) %>%
  summarise_all(list(mean = mean))
write.table(IndependentDataSet, "IndependentDataSet.txt", row.name = TRUE)

#To read the data into R use the following

variablename <- read.table("IndependentDataSet.txt")
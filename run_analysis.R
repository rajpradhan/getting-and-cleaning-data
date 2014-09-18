if (!require("data.table")) {
  install.packages("data.table")
}

if (!require("reshape2")) {
  install.packages("reshape2")
}

require("data.table")
require("reshape2")
parentDirectory <- "./UCI HAR Dataset"
trainDirectory <- "train"
testDirectory <- "test"

# 1. Merge the training and the test sets to create one data set.
# a. Get training data
X_train <- read.table(paste(parentDirectory, trainDirectory, "X_train.txt", sep = "/"))
y_train <- read.table(paste(parentDirectory, trainDirectory, "y_train.txt", sep = "/"))
subject_train <- read.table(paste(parentDirectory, trainDirectory, "subject_train.txt", sep = "/"))

# b. Get test data
X_test <- read.table(paste(parentDirectory, testDirectory, "X_test.txt", sep = "/"))
y_test <- read.table(paste(parentDirectory, testDirectory, "y_test.txt", sep = "/"))
subject_test <- read.table(paste(parentDirectory, testDirectory, "subject_test.txt", sep = "/"))

# c. Get features, activities 
features <- read.table(paste(parentDirectory, "features.txt", sep ="/"))[,2]
activities <- read.table(paste(parentDirectory, "activity_labels.txt", sep ="/"))[,2]



# Merge training and test datasets
merged_X <- rbind(X_train, X_test)
merged_y <- rbind(y_train, y_test)
merged_subject <- rbind(subject_train, subject_test)

# Extract mean and std features
mean_std_features <- grep("mean|std", features)
merged_X <- merged_X[, mean_std_features]

# Use descriptive activity names to name the activities in the data set
merged_y[,2] = activities[merged_y[,1]]

#Appropriately labels the data set with descriptive variable names. 
names(merged_X) <- features[mean_std_features]
names(merged_y) <- c("Activity_ID", "Activity_Label")
names(merged_subject) <- "Subject"

# Merge X, y and subject
merged_data = cbind(merged_subject, merged_y, merged_X)

# 5. creates a second, independent tidy data set with the average of each variable 
# for each activity and each subject.

# a. Melt Data
ids   = c("Subject", "Activity_ID", "Activity_Label")
datas = setdiff(colnames(merged_data), ids)
melted_data      = melt(merged_data, id = ids, measure.vars = datas)

# b. Dcast with mean
tidied_data   = dcast(melted_data, Subject + Activity_Label ~ variable, mean)

write.table(tidied_data, file = "./tidied.txt", row.name = FALSE)
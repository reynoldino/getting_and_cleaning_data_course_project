library(plyr)


# Get data
pathfile<-file.path(getwd(),"UCI HAR Dataset")

xtest<-read.table(paste0(pathfile, "/test/X_test.txt"))
ytest<-read.table(paste0(pathfile,"/test/Y_test.txt"))
subjecttest<-read.table(paste0(pathfile,"/test/subject_test.txt"))

xtrain<-read.table(paste0(pathfile,"/train/X_train.txt"))
ytrain<-read.table(paste0(pathfile,"/train/Y_train.txt"))
subjecttrain<-read.table(pste0(pathfile,"/train/subject_train.txt"))

# Get activity labels 
activitylabels<-read.table( file.path(pathfile, "activity_labels.txt")
                          , col.names = c("Id", "Activity")
                          )

# Get features labels
featurelabels<-read.table( file.path(pathfile, "features.txt")
                         , colClasses = c("character")
                         )

#1.Merge the training and the test sets to create one data set.
traindata <- cbind(cbind(xtrain, subjecttrain), ytrain)
testdata <- cbind(cbind(xtest, subjecttest), ytest)
sensordata <- rbind(traindata, testdata)

sensorlabels <- rbind(rbind(featurelabels, c(562, "Subject")), c(563, "Id"))[,2]
names(sensordata) <- sensorlabels

#2. Extract only the measurements on the mean and standard deviation for each measurement.
sensordatameanstd <- sensordata[,grepl("mean\\(\\)|std\\(\\)|Subject|Id", names(sensordata))]

#3. Descriptive activity names to name the activities in the data set
sensordatameanstd <- join(sensordatameanstd, activitylabels, by = "Id", match = "first")
sensordatameanstd <- sensordatameanstd[,-1]

#4. Appropriate labels the data set with descriptive names.
names(sensordatameanstd) <- gsub("([()])","",names(sensordatameanstd))
names(sensordatameanstd) <- make.names(names(sensordatameanstd))

#5. Creates a tidy data set with the average of each variable for each activity and each subject 
finaldata<-ddply(sensordatameanstd, c("Subject","Activity"), numcolwise(mean))
# Set column names
finaldataheaders<-names(finaldata)
finaldataheaders<-sapply(finaldataheaders, addSuffix, ".mean")
names(finaldata)<-finaldataheaders

write.table(finaldata, file = "sensordata_avg_by_subject.txt", row.name=FALSE)

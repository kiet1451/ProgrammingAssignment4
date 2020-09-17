#Get the data project from UCI database and unzip to the local folder
if (!file.exists("./UCI Data")) {dir.create("./UCI Data")}
myURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"

download.file(myURL,destfile= "./UCI Data/UCI.zip", method = "curl")
unzip(zipfile= "./UCI Data/UCI.zip", exdir = "./UCI Data")

#Read and save targeted files of Activity, feature, test, train.
UCIactivity <- read.table("./UCI Data/UCI HAR Dataset/activity_labels.txt", sep=" ")
UCIfeature  <- read.table("./UCI Data/UCI HAR Dataset/features.txt", sep= " ", header=F)
UCItestX    <- read.table("./UCI Data/UCI HAR Dataset/test/X_test.txt", header=F)
UCItestY    <- read.table("./UCI Data/UCI HAR Dataset/test/Y_test.txt", header=F)
UCItrainX   <- read.table("./UCI Data/UCI HAR Dataset/train/X_train.txt", header=F)
UCItrainY   <- read.table("./UCI Data/UCI HAR Dataset/train/Y_train.txt", header=F)
UCItestS    <- read.table("./UCI Data/UCI HAR Dataset/test/subject_test.txt", header=F)
UCItrainS   <- read.table("./UCI Data/UCI HAR Dataset/train/subject_train.txt", header=F)

#Merges traning and test sets to create one data set
Features <- rbind(UCItrainX ,UCItestX)
Activities <- rbind(UCItrainY ,UCItestY)
Subjects <- rbind(UCItrainS ,UCItestS)

#Name column of Subject and ACtivity table
names(Subjects) <- "Subject"
names(Activities) <- "Activity"
names(Features) <- UCIfeature$V2

#Extract only measurements on the mean and standard deviation for each measurement
getUCIfeature <- UCIfeature$V2[grep(".*mean\\(.*|.*std\\(.*",UCIfeature$V2)]
UCI_combine <- cbind(Subjects,Activities,Features)
select_name <- c(as.character(getUCIfeature),"Subject",'Activity')
select_data <- subset(UCI_combine, select = select_name)

#Use Descriptive ativity names to name the activities in the data set
select_data$Activity <- factor(select_data$Activity,levels=UCIactivity$V1,labels=UCIactivity$V2)

#Appriately label the data set with discriptive variable names
names(select_data)<-gsub("^t", "time", names(select_data))
names(select_data)<-gsub("^Acc", "Accelerometer", names(select_data))
names(select_data)<-gsub("^Gyro", "Gyroscope", names(select_data))
names(select_data)<-gsub("^f", "frequency", names(select_data))
names(select_data)<-gsub("^Mag", "Magnitude", names(select_data))
names(select_data)<-gsub("^BodyBody", "Body", names(select_data))

#Create a tidy data set
library(plyr)
select_data2<-aggregate(. ~Subject + Activity, select_data, mean)
select_data2<-select_data2[order(select_data2$Subject,select_data2$Activity),]
write.table(select_data2, file = "mytidy.txt",row.name=FALSE)



setwd("~/coursera/PracticalMachineLearning/week4/peer-assignment")

# library
library(gbm)
library(caret)
library(doMC)
# library(randomForest)
# registerDoMC(cores = 8)

# load data
data_training = read.csv("pml-training.csv")
data_testing= read.csv("pml-testing.csv")

# data preperation
data_training$X = NULL
data_testing$X = NULL

inTrain = createDataPartition(data_training$classe, p=0.60, list=FALSE)
training =data_training[inTrain,]
validating = data_training[-inTrain,]


# apply our definition of remove columns that most doesn't have data, before its apply to the model.

Keep <- c((colSums(!is.na(training[,-ncol(training)])) >= 0.6*nrow(training)))
training   <-  training[,Keep]
validating <- validating[,Keep]

# number of rows and columns of data in the final training set

dim(training)

# number of rows and columns of data in the final validating set

dim(validating)

bootControl <- trainControl(number = 1)

mod_gbm <- train(classe ~ ., data = training, 
                 method = "gbm", trControl = bootControl, verbose = T)
# mod_rf <- train(classe ~ ., data = training, method = "rf")












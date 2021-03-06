---
title: "Practical Machine Learning"
output: html_document
---

```{r setup, include=FALSE}
knitr::opts_chunk$set(echo = TRUE)
```

# Peer-graded Assignment
## Summury

This report shows the analysis results of the Weight Lifting Exercises Dataset.
The aim is to predict human activity from sensor data.
The Weight Lifting Exercises Dataset contains 5 class human activity.
In this report, I used random forest and recursive feature elimination.

## Data
task:Human Activity Recognition

data:multi sensor time series data

label(class):exactly according to the specification (Class A), throwing the elbows to the front (Class B), lifting the dumbbell only halfway (Class C), lowering the dumbbell only halfway (Class D) and throwing the hips to the front (Class E).(in detail: http://groupware.les.inf.puc-rio.br/har#ixzz4LvubzXo2)

site ulr:http://groupware.les.inf.puc-rio.br/har

## Analysis

### Laod packages

```{r laod packages, message=FALSE, warning=FALSE}
library(caret)
library(randomForest)
library(mlbench)
```

```{r, message=FALSE, warning=FALSE, include=FALSE}
library(doMC)
registerDoMC(cores = 8)
set.seed(12345)
# set.seed(1234)
```

### Load data

```{r}
training = read.csv("../peer-assignment/pml-training.csv")
testing= read.csv("../peer-assignment/pml-testing.csv")
```

### Data cleaning 

#### Create training and testing dataset 
I used 70% data for model training and 30% data for validation.
```{r, data cleaning, echo=TRUE}
inTrain  <- createDataPartition(training$classe, p=0.7, list=FALSE)
TrainSet <- training[inTrain, ]
TestSet  <- training[-inTrain, ]
dim(TrainSet)
dim(TestSet)
```

#### Remove feature which variance is neer 0.
```{r, echo=TRUE}
remove_idx <- nearZeroVar(TrainSet)
TrainSet <- TrainSet[, -remove_idx]
TestSet  <- TestSet[, -remove_idx]
dim(TrainSet)
dim(TestSet)
```

#### Remove feature which contains too many NA.
```{r, echo=TRUE}
remove_idx <- sapply(TrainSet, function(x) mean(is.na(x))) > 0.95
TrainSet <- TrainSet[, remove_idx==FALSE]
TestSet <- TestSet[, remove_idx==FALSE]
dim(TrainSet)
dim(TestSet)
```

#### Remove feature which are inccorect to use for prediction.
```{r, echo=TRUE}
TrainSet <- TrainSet[, -(1:5)]
TestSet  <- TestSet[, -(1:5)]

data_dim <- dim(TrainSet)

dim(TrainSet)
dim(TestSet)
```

```{r, warning=FALSE, include=FALSE}
# decrease sample of training data to faster.
trainidx = seq(1, data_dim[1], by = 10)
train_bak <- TrainSet
TrainSet <- TrainSet[trainidx, ]
```

### Feature selection
```{r}
set.seed(12345)
# define the control using a random forest selection function
control <- rfeControl(functions=rfFuncs, method="cv", number=3)
# run the RFE algorithm
results <- rfe(TrainSet[,1:data_dim[2]-1], TrainSet[,data_dim[2]], sizes=c(1:data_dim[2]-1), rfeControl=control)
```

#### summarize the results
```{r, echo=TRUE}
print(results)
```

#### list the chosen features
```{r, echo=TRUE}
predictors(results)
```

#### plot the result
```{r, echo=TRUE}
plot(results, type=c("g", "o"))
```

The result shows that add several feature to train, accuracy improve rappidly.
In the peak of accuracy, the number of feature is around 10, and too many features led to poor performance.

```{r, include=FALSE}
TrainSet <- train_bak
```

### model fitting by random forest
```{r, echo=TRUE}
set.seed(12345)
control_rf <- trainControl(method="cv", number=3, verboseIter=T)
mod_rf <- train(classe ~ ., data=TrainSet, method="rf", trControl=control_rf)
mod_rf$finalModel
```

#### prediction on Test dataset and performance evaluation
```{r, echo=TRUE}
pred_rf <- predict(mod_rf, newdata=TestSet)
confmat_rf <- confusionMatrix(pred_rf, TestSet$classe)
confmat_rf
```

### model fitting by random forest for feature selected data
```{r, echo=TRUE}
set.seed(12345)

data_rfe <- TrainSet[results$optVariables]
data_rfe$classe <- TrainSet$classe

mod_rf_rfe <- train(classe ~ ., data=data_rfe, method="rf", trControl=control_rf)
mod_rf_rfe$finalModel
```

#### prediction on Test dataset and performance evaluation
```{r, echo=TRUE}
pred_rf_rfe <- predict(mod_rf_rfe, newdata=TestSet)
confmat_rf_rfe <- confusionMatrix(pred_rf_rfe, TestSet$classe)
confmat_rf_rfe
```

Accuracy of feature selected by recursive feature elimination are higher than no feature selected.

## Prediction of test data
```{r, echo=TRUE}
pred_rf_rfe_test <- predict(mod_rf_rfe, newdata=testing)
pred_rf_rfe_test
```

## Conclusion
I tried to fit random forest model to the Weight Lifting Exercises Dataset to predict human activity.
I used feature selection to increase accuracy and robustness of learned model.
I predicted test data by learned model(with feature selection). 

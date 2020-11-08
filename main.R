main <- function() {
    # Load all scripts from the Scripts folder
    sapply(list.files("./Scripts", full.names = T), source)
    
    # Load packages
    init()
    
    # NOT RUN, USED FOR INITIAL DOWNLOAD
    # data <- dldata(write_to_file = !file.exists("./Data/data.csv"))
    
    # Reading in data from file
    # if "data" does not exist in the global environment
    if (!exists("data_traintest_ohe")) {
        data <- as_tibble(read.csv("./Data/data.csv",
                                   na.strings = c("NA", "null")))
        data <- preprocess(data)
        
        hitter_tendency <- generate_tendency(data, min.total = 150)
        data_traintest <- generate_traintest(data, hitter_tendency)
        data_traintest_ohe <- generate_ohe(data_traintest)
        
    }
    
    if(!exists("test.stw")) {
        set.seed(1)
        train_ind <- createDataPartition(data_traintest_ohe$swingtakewhiff,
                                         p = 0.8, list = FALSE)
        data_normal <- scale(
            data_traintest_ohe[,!names(data_traintest_ohe) %in% 'swingtakewhiff']
        )
        trainset <<- data_normal[train_ind,]
        testset <<- data_normal[-train_ind,]
        train.stw <<- data_traintest_ohe$swingtakewhiff[train_ind]
        test.stw <<- data_traintest_ohe$swingtakewhiff[-train_ind]
        
        trainset_full <<- cbind(as_tibble(trainset), as.character(train.stw))
        testset_full <<- cbind(as_tibble(testset), as.character(test.stw))
        
        names(trainset_full)[ncol(trainset_full)] <- "swingtakewhiff"
        names(testset_full)[ncol(testset_full)] <- "swingtakewhiff"
    }
    
    

    
    cl <- makePSOCKcluster(4)
    registerDoParallel(cl)

    ## All subsequent models are then run in parallel
    # initmodel <- train(swingtakewhiff ~ ., data = data_traintest[1:1000,3:41],
    #                    method = "rf")
    
    ctrl <- trainControl(method = "cv", number = 5)
    initmodel <- train(swingtakewhiff ~ ., data = trainset_full[1:1000,],
                       trControl = ctrl,
                       method = "rf")

    ## When you are done:
    stopCluster(cl)
    
    
    
}

main()
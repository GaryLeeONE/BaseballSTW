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
        message("Reading data from local CSV file")
        data <- as_tibble(read.csv("./Data/data.csv",
                                   na.strings = c("NA", "null")))
        data <- preprocess(data)
        
        message("Start one-hot encoding")
        hitter_tendency <<- generate_tendency(data, min.total = 1000)
        data_traintest <<- generate_traintest(data, hitter_tendency)
        data_traintest_ohe <<- generate_ohe(data_traintest)
        
        message("Finished one-hot encoding")
        
    }
    
    if(!exists("test.stw")) {
        
        generate_split(data_traintest_ohe)
        
        set.seed(1)
        trainset_dsample <<- downSample(trainset_scaled, train.stw)
        
    }
    
    # set.seed(1)
    # sample_idx <- sample(1:nrow(trainset_dsample), 10000)
    # 
    # trainset_dsample_small <- trainset_dsample %>%
    #     select(stand.R, p_throws.R, release_speed, release_pos_x, release_pos_y,
    #            release_pos_z, release_spin_rate, pfx_x, pfx_z, plate_x, plate_z, Class)
    # 
    # 
    # cl <- makePSOCKcluster(4)
    # registerDoParallel(cl)
    # 
    # ## All subsequent models are then run in parallel
    # ctrl <- trainControl(method = "cv", number = 5,
    #                      classProbs = TRUE,
    #                      summaryFunction = multiClassSummary,
    #                      verboseIter = TRUE)
    # 
    # m_knn <- train(Class ~ ., data = trainset_dsample_small,
    #                     trControl = ctrl,
    #                     metric="logLoss",
    #                     method = "knn")
    # 
    # ## When you are done:
    # stopCluster(cl)
    
    use_1va = F
    
    if (use_1va) {
        trainset_1va <- trainset %>%
            mutate(swing_int = if_else(swingtakewhiff == "swing", "Yes", "No"),
                   take_int = if_else(swingtakewhiff == "swing", "Yes", "No"),
                   whiff_int = if_else(swingtakewhiff == "swing", "Yes", "No")) %>%
            select(-swingtakewhiff)
        
        testset_1va <- testset %>%
            mutate(swing_int = if_else(swingtakewhiff == "swing", "Yes", "No"),
                   take_int = if_else(swingtakewhiff == "swing", "Yes", "No"),
                   whiff_int = if_else(swingtakewhiff == "swing", "Yes", "No")) %>%
            select(-swingtakewhiff, -stw_int, -stw_int_pred, -stw_correct)
        
        trainset_1va_swing <- trainset_1va %>% select(-take_int, -whiff_int)
        testset_1va_swing <- testset_1va %>% select(-take_int, -whiff_int)
        
        # svm_train <- scale(trainset_1va_swing[,-ncol(trainset_1va_swing)])
        # 
        # df_mean <- attr(svm_train, "scaled:center")
        # df_sd <- attr(svm_train, "scaled:scale")
        # 
        # svm_train <- as_tibble(svm_train) %>% mutate(Class = trainset_1va_swing$swing_int)
        # svm_test <- as_tibble(scale(testset_1va_swing[,-ncol(testset_1va_swing)],
        #                             center = df_mean,
        #                             scale = df_sd)) %>%
        #     mutate(Class = testset_1va_swing$swing_int)
        
        svmGrid <-  expand.grid(sigma = c(1e-7, 1e-6),
                                C = c(30, 40))
        
        nperclass = 4000
        
        dsample <- downSample(trainset[,-ncol(trainset)],
                              trainset$swingtakewhiff)[c(1:nperclass, 
                                                         54463:(54462+nperclass), 
                                                         108927:(108926+nperclass)),]
        
        
        cl <- makePSOCKcluster(4)
        registerDoParallel(cl)

        ## All subsequent models are then run in parallel
        ctrl <- trainControl(method = "cv", number = 5,
                             summaryFunction = multiClassSummary)
        

        m_svm <- train(Class ~ ., data = dsample,
                       trControl = ctrl,
                       # tuneLength = 3,
                       tuneGrid = svmGrid,
                       method = "svmRadial")

        ## When you are done:
        stopCluster(cl)
        
        
    }
    
    
    use_xgb = F
    
    if (use_xgb) {
        
        trainset["swingtakewhiff"] <- train.stw
        testset["swingtakewhiff"] <- test.stw
        
        trainXSMatrix <- sparse.model.matrix( swingtakewhiff~.-1, data = trainset )
        testXSMatrix <- sparse.model.matrix( swingtakewhiff~.-1, data = testset )
        
        trainYvec <- as.integer(train.stw) - 1    # extract response from training set; class label starts from 0
        testYvec  <- as.integer(test.stw) - 1     # extract response from test set; class label starts from 0
        numberOfClasses <- max(trainYvec) + 1
        
        eta <- 0.1
        nround <- 10000 # max number of rounds/trees
        
        searchGrid <- expand.grid(subsample = c(0.8),          # Already set
                                  colsample_bytree = c(0.65),  # Already set
                                  gamma = c(0.9),   # Already set
                                  max_depth = c(5), #    Already set
                                  min_child_weight = c(3),   # Already set
                                  lambda = 10) # Already set
        
        param <- list("objective" = "multi:softmax",
                      "eval_metric" = "mlogloss",
                      "num_class" = numberOfClasses,
                      "eta" = eta,
                      "gamma" = 0.9,
                      "max_depth" = 5,
                      "min_child_weight" = 3,
                      "subsample" = 0.8,
                      "colsample_bytree" = 0.65,
                      "lambda" = 10,
                      "tree_method" = 'gpu_hist')
        
        ptm <- proc.time()
        
        xgbcv <- xgb.cv( params = param, data = trainXSMatrix, label = trainYvec,
                         nrounds = nround, nfold = 5, showsd = TRUE,
                         early_stopping_rounds = 50L, 
                         stratified = TRUE, print_every_n = 25L )
        
        xvalidationScores <- as.data.frame(xgbcv$evaluation_log)
        best_ntree <- xgbcv$best_iteration
        
        print(proc.time() - ptm)
        
        ptm <- proc.time()

        xgbstree <- xgboost(params = param,
                            data = trainXSMatrix,
                            label = trainYvec,
                            nrounds = best_ntree, # same number of trees as before
                            print_every_n = 50L)

        print(proc.time() - ptm)
        
        xgbstree.pred <- predict(xgbstree, testXSMatrix)   # this is a long vector
        print(xgbstree.acc <- mean(xgbstree.pred == testYvec))
        
        imp_mat <- xgb.importance(model = xgbstree)
        xgb.plot.importance(importance_matrix = imp_mat[1:10,])
        
        
        
        
    }
    
    
    
}

main()
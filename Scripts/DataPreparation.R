# This R script includes functions that load packages,
# download and process data from BaseballSavant,
# and perform initial processing

init <- function() {
    require(dplyr)
    require(ggplot2)
    require(caret)
    require(xgboost)
    require(baseballr)
    require(lubridate)
    require(data.table)
    require(rlist)
    require(tidyr)
    require(doParallel)
    require(e1071)
    require(nnet)
    
}

dldata <- function(write_to_file = FALSE) {
    
    listofdates <- c(seq.Date(from = ymd("2017-03-15"),
                              to = ymd("2017-11-01"),
                              by = 5),
                     seq.Date(from = ymd("2018-03-15"),
                              to = ymd("2018-11-01"),
                              by = 5),
                     seq.Date(from = ymd("2019-03-15"),
                              to = ymd("2019-11-01"),
                              by = 5))
    
    # listofdates <- c(seq.Date(from = ymd("2017-03-15"),
    #                           to = ymd("2017-05-01"),
    #                           by = 5))
    
    data_raw <- mapply(scrape_statcast_savant_batter_all,
                       start_date = listofdates,
                       end_date = listofdates + 4,
                       SIMPLIFY = FALSE)
    
    notempty <- list.mapv(data_raw, nrow(.)) > 0
    data_raw <- data_raw[notempty]
    data <- rbindlist(data_raw)
    
    if (write_to_file) {
        write.csv(data, "./Data/data.csv", row.names = FALSE)
    }
    
    return(data)
}

preprocess <- function(df) {
    
    temp <- df
    
    # temp[ temp == "null" ] <- NA
    
    temp <- temp %>% select(-spin_dir, -spin_rate_deprecated,
                            -break_angle_deprecated,
                            -break_length_deprecated,
                            -des, -tfs_deprecated, -tfs_zulu_deprecated,
                            -umpire) %>%
        mutate( game_date = ymd(game_date) ) %>%
        mutate_if( is.character, as.factor ) %>%
        mutate_if( is.integer, as.double ) %>%
        mutate( player_name = as.character(player_name) ,
                hc_xnew = 2.33 * ( hc_x - 126 ) ,
                hc_ynew = 2.33 * ( 204.5 - hc_y ) ,
                spray_angle = 180 / pi * atan( hc_xnew / hc_ynew ) ,
                zone = as.factor(zone) ) %>%
        mutate(
            swingtakewhiff = case_when(
                description %in% c("hit_into_play_score",
                                   "foul",
                                   "hit_into_play",
                                   "hit_into_play_no_out",
                                   "foul_bunt",
                                   "foul_pitchout") ~ "swing",
                description %in% c("ball",
                                   "called_strike",
                                   "blocked_ball",
                                   "hit_by_pitch",
                                   "pitchout") ~ "take",
                TRUE ~ "whiff"
            )
        )
    
    return(temp)
}


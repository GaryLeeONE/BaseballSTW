# Predicting Baseball Hitter Swing/Take/Whiff - Midterm Report
ORIE 4741 Course Project for FA20

Gary (Hancheng) Li

## Project Overview
The goal of this project is to predict whether a hitter in Major League Baseball will swing (and make contact), take, or whiff (swing and miss) at a certain pitch, based on the hitter's hitting tendencies, the pitch characteristics, as well as the game situation (number of outs in an inning, number of runners on base). Ideally, I hope to build a model that can suggest to the pitcher what types of pitches to use against a certain hitter, as well as finding out the most important factors that influence swing/take/miss which can help with prospect scouting and development.

This project primarily uses R v4.0.3 as the coding language.

## Dataset Preparation
The original dataset is obtained from the [Baseball Savant](https://baseballsavant.mlb.com/) website using its powerful Statcast search feature. This dataset is maintained by Major League Baseball R&D Department, and contains detailed play-by-play information from the 2017 to 2019 MLB Seasons (Regular Season and Postseason). Each row corresponds to a single pitch thrown, while the columns contain information such as player IDs, player handedness, pitch type, pitch location, pitch velocity, spin rate, batted ball type, and other numeric, nominal or descriptive variables. The full list of variables are listed [here](https://baseballsavant.mlb.com/csv-docs). The original dataset is loaded into the R environment using the `baseballr` package developed by Bill Petti ([link](http://billpetti.github.io/baseballr/)), and contains 86 columns and 2,207,255 rows.

The dataset is well maintained with very few data quality issues. For the data cleaning process, I removed several deprecated columns including `spin_dir`, `break_angle_deprecated`, etc., corresponding to metrics that are no longer tracked and used. I also removed columns that I believe are irrelevant to the prediction, including `des` (which is the literal description of each play, such as "Mike Trout homers (1) on a fly ball to center field"), and `umpire` (which is supposed to be the home plate umpire but the entire columns is empty). Apart from this, the only issue I found with the dataset is that there are some pitches that were thrown with 3 outs already recorded in the inning, which is impossible to happen based on the rules of the game (if 3 outs have already been recorded then the inning immediately stops, any pitch can only be thrown with 0, 1, or 2 outs recorded). I removed these rows from the dataset.

Next, the 

Because the dataset contains information of every single pitch thrown, I first processed the dataset to find the tendency of each hitter, including the percentage of pitches he swung at/took/whiffed at. I will also select the columns that are helpful towards the prediction, and code them into appropriate forms for different algorithms.

I will be using different classification methods to produce multiple models, including Nearest-Neighbors and tree-based methods such as random forest and XGBoost. I also plan to build different models using different subsets of the predictors, and compare the accuracy between them.

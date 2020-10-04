# Predicting Baseball Hitter Swing/Take/Whiff
ORIE 4741 Course Project for FA20

Gary (Hancheng) Li

### Project Goal
The goal of this project is to predict whether a baseball hitter will swing (and make contact), take, or whiff (swing and miss) at a certain pitch, based on the hitter's hitting tendencies, the pitch characteristics, as well as the game situation (number of outs in an inning, number of runners on base). Using this model, we can answer a number of questions, such as:

* For the pitcher, what are the most efficient pitches to use against the hitter in a specific game situation
* For the hitter, what are the weaknesses in his approach, are there particular types of pitch (or pitcher) that he is vulnerable against

### Dataset and Analysis Method
The original dataset is obtained from the [Baseball Savant](https://baseballsavant.mlb.com/) website using its powerful Statcast search feature. It contains 90 columns and 743,570 rows. Each row corresponds to a single pitch thrown during the 2019 MLB Regular Season, while the columns contain information such as pitch type, pitch location, pitch velocity, spin rate, batted ball type, and other miscellaneous statistics. The full list of variables are listed [here](https://baseballsavant.mlb.com/csv-docs).

Because the dataset contains information of every single pitch thrown, I plan to first process the dataset to find the tendency of each hitter, including the percentage of pitches he swung at/took/whiffed at. I will also select the columns that are helpful towards the prediction, and code them into appropriate forms for different algorithms.

I will be using different classification methods to produce multiple models, including Nearest-Neighbors and tree-based methods such as random forest and XGBoost. I also plan to build different models using different subsets of the predictors, and compare the accuracy between them.

### Project Value
This prediction model can potentially help the teams make gametime decisions. Combined with pre-game scouting to learn the opposing team/player's tendencies, pitchers are able to know which pitch to throw to increase the chance of a swing-and-miss, while hitters can use this information to wait for a certain type of pitch to hit and make contact. 

The model could also benefit player development and scouting for prospects. From the model we can rank the predictors by importance, so we are able to learn what the crucial factors are in deciding the outcome. Recent analyses have often arrived at the conclusion that a high spin rate, which causes the pitch to move/curve in different directions, are very effective in causing swings-and-misses. This led to many teams chasing pitchers who throw pitches with very high spin rates.

### Very quick explanation for non-baseball fans
In baseball, the pitcher is on the defensive side. He throws the baseball to the hitter (this motion is called a "pitch"). The hitter (also called "batter") is on the offensive side and tries to hit the pitch. The pitcher will use many different types of pitches with different velocity and curve to trick the hitter, because swing-and-miss (also called "whiff") will benefit the defense. The hitter tries to hit a pitch into the playing field to create scoring opportunities, which benefits the offense.

The hitter taking a pitch means that he does not swing at the pitch. However, he can only take a limited number of pitches each time he comes up to hit. Hitters taking pitches can be beneficial to either the offense or the defense depending on the location of the pitches thrown.

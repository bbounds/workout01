# ================================================================
# Title: Make Teams Table
# Description:  
#     This script performs cleaning tasks and transformations on 
#     various columns of the raw nba2018-players.csv data file.
# Input(s): data file 'nba2018-players.csv'
# Output(s): 
#     text file 'efficiency-summary.txt'
#     text file 'teams-summary.txt'
#     data file 'nba2018-teams.csv
# Author: Bailey Bounds
# Date: 10-3-2018
# ================================================================

library(readr)
library(dplyr)

dat <- read_csv('../data/nba2018.csv')

#Setting rookie experience to 0 and setting experience to integer data type
dat$experience <- as.character(dat$experience)
dat$experience[dat$experience == "R"] = 0
dat$experience <- as.integer(dat$experience)

#Making salary into millions of dollars
dat$salary <- dat$salary/1000000

#relabeling position factor with more descriptive levels
dat$position <- as.factor(dat$position)
position <- c("center", "power_fwd", "point_guard", "small_fwd", "shoot_guard")
dat$position <- position[dat$position]

#Adding new variables
dat <- mutate(dat, missed_fg = field_goals_atts - field_goals)
dat <- mutate(dat, missed_ft = points1_atts - points1)
dat <- mutate(dat, rebounds = off_rebounds + def_rebounds)
dat <- mutate(dat, efficiency = (points + rebounds + assists + steals + blocks - missed_fg - missed_ft - turnovers)/games)

sink(file = '../output/efficiency-summary.txt')
summary(dat$efficiency)
sink()

#Creating nba2018-teams.csv

teams1 <- summarise(
            group_by(dat, team),
            experience = sum(experience),
            salary = sum(salary),
            points3 = sum(points3),
            points2 = sum(points2),
            points1 = sum(points1),
            points = sum(points),
            off_rebounds = sum(off_rebounds),
            def_rebounds = sum(def_rebounds),
            assists = sum(assists),
            steals = sum(steals),
            blocks = sum(blocks),
            turnovers = sum(turnovers),
            fouls = sum(fouls),
            efficiency = sum(efficiency),
            minutes = sum(minutes)
)

teams <- as.data.frame(teams1)

sink(file = "../output/teams-summary.txt")
summary(teams)
sink()

write.csv(teams, file = "../data/nba2018-teams.csv", row.names = FALSE)

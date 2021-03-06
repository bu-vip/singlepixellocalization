# Doug Roeper
# BU UROP
# 
# Converts sensor data file(s) and optitrack file(s) into SVM ready data points

rm(list = ls())

setwd("~/Development/UROP_SinglePixelLocalization/r/")

library(jsonlite)
library(ggplot2)
library(reshape2)
library(grid)
library(gridExtra)

source("sync.R")
source("features.R")

# dataPath <- "/home/doug/Desktop/UROP/track2/data/"
# sensorFiles <- c("take1.txt", "take2.txt", "take3.txt", "take4.txt", "take5.txt", "take6.txt", "take7.txt", "take8.txt")
# optiFiles <- c("take1_opti.json", "take2_opti.json", "take3_opti.json", "take4_opti.json", "take5_opti.json", "take6_opti.json", "take7_opti.json", "take8_opti.json")
# outputPrefixes <- c("take1-res-", "take2-res-", "take3-res-", "take4-res-", "take5-res-", "take6-res-", "take7-res-", "take8-res-")
# outputFolder <- "/home/doug/Desktop/UROP/track2/r_out/"
# sensorStartTimes <- c(1456450336081,1456450519513,1456450754459,1456450931828,1456452135556,1456452392004,1456452517247,1456452624509)
# sensorEndTimes <- c(1456450385980,1456450581633,1456450823245,1456451051018,1456452244232,1456452462100,1456452586229,1456452676624)
# optiStartTimes <- c(1690,1417,1689,1598,1546,1629,1482,1127)
# optiEndTimes <- c(6674,7627,8551,13500,12417,8644,8381,6328)
# trimStart <- c(20,20,20,20,20,20,20,20)
# trimEnd <- c(50,50,50,50,50,75,50,50)
# backgroundFile <- "background.txt"

# dataPath <- "/home/doug/Desktop/UROP/track3/data/"
# outputFolder <- "/home/doug/Desktop/UROP/track3/r_out/"
# sensorFiles <- c("take1.txt", "take2.txt", "take3.txt", "take4.txt", "take5.txt", "take6.txt", "take7.txt", "take8.txt")
# optiFiles <- c("take1.json", "take2.json", "take3.json", "take4.json", "take5.json", "take6.json", "take7.json", "take8.json")
# outputPrefixes <- c("take1-res-", "take2-res-", "take3-res-", "take4-res-", "take5-res-", "take6-res-", "take7-res-", "take8-res-")
# sensorStartTimes <- c(1457099620695,1457099804113,1457099959354,1457100155300,1457100282360,1457100437905,1457100816664,1457101166428)
# sensorEndTimes <- c(1457099702808,1457099895722,1457100107828,1457100228728,1457100389928,1457100716470,1457100985237,1457101233996)
# optiStartTimes <- c(1483,1364,1286,1470,1404,1563,1692,1235)
# optiEndTimes <- c(9702,10532,16128,8815,12159,29418,18545,7999)
# trimStart <- c(20,20,20,20,20,20,20,20)
# trimEnd <- c(50,50,50,50,50,50,75,50)
# backgroundFile <- "background.txt"

# dataPath <- "/home/doug/Desktop/UROP/track4/data/"
# outputFolder <- "/home/doug/Desktop/UROP/track4/r_out/"
# sensorFiles <- c("brian2.txt","brian3.txt","brian4.txt","brian5.txt","doug1.txt","doug2.txt","doug3.txt","doug4.txt","doug5.txt","jiawei2.txt","jiawei3.txt","jiawei4.txt","jiawei5.txt")
# optiFiles <- c("brian2.json","brian3.json","brian4.json","brian5.json","doug1.json","doug2.json","doug3.json","doug4.json","doug5.json","jiawei2.json","jiawei3.json","jiawei4.json","jiawei5.json")
# outputPrefixes <- c("out-brian2-","out-brian3-","out-brian4-","out-brian5-","out-doug1-","out-doug2-","out-doug3-","out-doug4-","out-doug5-","out-jiawei2-","out-jiawei3-","out-jiawei4-","out-jiawei5-")
# sensorStartTimes <- c(1459446598730,1459446826201,1459447018623,1459447131752,1459443995543,1459444147157,1459444268873,1459444444628,1459444605333,1459442956574,1459443075359,1459443217277,1459443359294)
# sensorEndTimes <- c(1459446726608,1459446998016,1459447112863,1459447281345,1459444072511,1459444242308,1459444379881,1459444575838,1459444734119,1459443058087,1459443202630,1459443343436,1459443517171)
# optiStartTimes <- c(1056,401,983,1293,1646,1444,1067,1048,1341,589,666,889,879)
# optiEndTimes <- c(13836,17575,10406,16252,9332,10961,12163,14162,14218,10731,13382,13493,16661)
# trimStart <- c(20,20,20,20,20,20,20,20,20,20,100,20,20)
# trimEnd <- c(50,50,200,50,50,50,50,50,50,50,100,90,50)
# backgroundFile <- "background.txt"

dataPath <- "/home/doug/Desktop/track5/data/"
outputFolder <- "/home/doug/Desktop/track5/r_out/"
sensorFiles <- c("dan1.txt","dan2.txt","dan3.txt","dan4.txt","dan6.txt","doug1.txt","doug2.txt","doug3.txt","doug4.txt","doug5.txt","pablo1.txt","pablo2.txt","pablo3.txt","pablo4.txt","pablo5.txt","jiawei1.txt","jiawei2.txt","jiawei3.txt","jiawei4.txt","jiawei5.txt")
optiFiles <- c("dan1-opti.json","dan2-opti.json","dan3-opti.json","dan4-opti.json","dan6-opti.json","doug1-opti.json","doug2-opti.json","doug3-opti.json","doug4-opti.json","doug5-opti.json","pablo1-opti.json","pablo2-opti.json","pablo3-opti.json","pablo4-opti.json","pablo5-opti.json","jiawei1-opti.json","jiawei2-opti.json","jiawei3-opti.json","jiawei4-opti.json","jiawei5-opti.json")
outputPrefixes <- c("dan1-","dan2-","dan3-","dan4-","dan6-","doug1-","doug2-","doug3-","doug4-","doug5-","pablo1-","pablo2-","pablo3-","pablo4-","pablo5-","jiawei1-","jiawei2-","jiawei3-","jiawei4-","jiawei5-")
optiStartTimes <- c(1080,638,2018,1689,441,1656,1060,1104,1286,1067,1109,1809,1402,1252,11370,931,1046,804,847,892)
optiEndTimes<- c(12887,12600,14752,15522,12520,13620,13805,16438,15305,13150,11616,12509,12260,14647,23682,11512,11554,11476,11463,11470)
sensorStartTimes <- c(1459713852421,1459713993940,1459714152994,1459714313387,1459714634062,1459714981191,1459715123497,1459715480233,1459715657992,1459715828080,1459712899002,1459713033335,1459713167769,1459713300587,1459713562183,1459801796925,1459801924390,1459802049227,1459802173465,1459802294868)
sensorEndTimes <- c(1459713970503,1459714113613,1459714280357,1459714451951,1459714754868,1459715100873,1459715250863,1459715633651,1459715798082,1459715948881,1459713004145,1459713140297,1459713276347,1459713434515,1459713685765,1459801902775,1459802029532,1459802155890,1459802279516,1459802400718)
trimStart <- c(20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20)
trimEnd <- c(50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50)


# Config options
feature_derivative <- "deriv"
shouldGraph <- 1
graphWidthInch <- 8
graphHeightInch <- 6
graphWidthPx <- 1200
graphHeightPx <-900

# Constants
# backgroundFileName <- paste(dataPath, backgroundFile, sep="")



# find the max and min of the optitrack data across all samples
# optMinX <- 999999
# optMaxX <- -999999
# optMinZ <- 999999
# optMaxZ <- -999999
# for (i in 1:length(sensorFiles))
# {
#   optiFileName <- paste(dataPath, optiFiles[i], sep="")
#   optiDataStartTime <- optiStartTimes[i]
#   optiDataEndTime <- optiEndTimes[i]
#   
#   optiData <- fromJSON(readChar(optiFileName, file.info(optiFileName)$size))
#   optiData <- optiData[optiData$frameIndex >= optiDataStartTime & optiData$frameIndex <= optiDataEndTime, ]
#   
#   optMinX <- pmin(min(optiData$x), optMinX)
#   optMaxX <- pmax(max(optiData$x), optMaxX)
#   optMinZ <- pmin(min(optiData$z), optMinZ)
#   optMaxZ <- pmax(max(optiData$z), optMaxZ)
# }


# calculate background sensor readings
# backgroundData <- fromJSON(readChar(backgroundFileName, file.info(backgroundFileName)$size))
# backgroundData$luminance <- features_calc_luminance(backgroundData$red, backgroundData$green, backgroundData$blue)
# backgroundMean <- mean(backgroundData$luminance)

# process all takes
for (i in 1:length(sensorFiles))
{
  # get properties
  sensorFileName <- paste(dataPath, sensorFiles[i], sep="")
  optiFileName <- paste(dataPath, optiFiles[i], sep="")
  optiDataStartTime <- optiStartTimes[i]
  optiDataEndTime <- optiEndTimes[i]
  sensorDataStartTime <- sensorStartTimes[i]
  sensorDataEndTime <- sensorEndTimes[i]
  numberSamplesToRemoveStart <- trimStart[i]
  numberSamplesToRemoveEnd <- trimEnd[i]
  outputName <- paste(outputFolder, outputPrefixes[i], sep="")
  
  ### LOAD DATA ###
  # load data
  sensData <- fromJSON(readChar(sensorFileName, file.info(sensorFileName)$size))
  optiData <- fromJSON(readChar(optiFileName, file.info(optiFileName)$size))
  
  ### UNIQUE SENSORS ###
  # Create a key to address each sensor individually
  # key = groupId + sensorId
  sensData$groupSensorId <- paste(sensData$groupId, "-", sensData$sensorId, sep="")
  uniqueSensors <- sort(unique(sensData$groupSensorId))
  
  ### LUMINANCE ###
  # calculate luminance
  sensData$luminance <- features_calc_luminance(sensData$red, sensData$green, sensData$blue)
  # background subtraction
  # TODO sensor wise background subtraction
  # sensData$luminance <- (sensData$luminance - backgroundMean)
  
  ### CLASSES ###
  # calculate class for optitrack data
  #quantizeLevels <- 3
  #optLevelSizeX <- (optMaxX - optMinX) / quantizeLevels
  #optLevelSizeZ <- (optMaxZ - optMinZ) / quantizeLevels
  # ensure inside class boundaries
  #optiData$class <- pmin(floor((optiData$x - optMinX) / optLevelSizeX), quantizeLevels - 1)
  #optiData$class <- optiData$class + pmin(floor((optiData$z - optMinZ) / optLevelSizeZ), quantizeLevels - 1) * quantizeLevels
  
  ### SYNC ###
  # Sync optitrack and sensor data
  syncedData <- sync_sensor_optitrack(sensData, sensorDataStartTime, sensorDataEndTime, optiData, optiDataStartTime, optiDataEndTime)
  
  ### TRANSFORMATIONS ###
  # Calculate additional features
  # smmoth data
  #syncedData <- features_apply_sensorwise_arg2(syncedData, uniqueSensors, features_lowpass_filter, "", "", 2, 0.8)
  # calc derivative
  #syncedData <- features_apply_sensorwise(syncedData, uniqueSensors, features_calc_derivative, "", feature_derivative)
  
  # trim data
  syncedData <- syncedData[-seq(0, numberSamplesToRemoveStart, by=1), ]
  syncedData <- syncedData[-seq(nrow(syncedData) - numberSamplesToRemoveEnd + 1, nrow(syncedData) + 1, by=1), ]
  
  ### GRAPHING ###
  if (shouldGraph == 1)
  {
    # plot original data
    ggplot(sensData, aes(received, luminance)) + geom_line() + facet_grid(sensorId ~ .)
    ggsave(paste(outputName, "sensor_orig.png", sep=""), width = graphWidthInch, height = graphHeightInch)
    optiMelt <- melt(optiData[, c("frameIndex", "x", "y", "z")], id=c("frameIndex"))
    ggplot(data=optiMelt, aes(x=frameIndex, y=value, color=variable)) + geom_line()
    ggsave(paste(outputName, "opti_orig.png", sep=""), width = graphWidthInch, height = graphHeightInch)
    
    # Plot synced data
    
    # create sensor data plot
    meltedSensor <- melt(syncedData[, c(uniqueSensors, "t")], id=c("t"))
    #meltedSensor <- melt(syncedData[, c("0-5", "t")], id=c("t"))
    sensorPlot <- ggplot(data=meltedSensor, aes(x=t, y=value, color=variable)) + geom_line()
    # create sensor data plot
    #meltedSensorDeriv <- melt(syncedData[, c(paste(uniqueSensors, feature_derivative, sep=""), "t")], id=c("t"))
    #meltedSensorDeriv <- melt(syncedData[, c(paste("0-5", feature_derivative, sep=""), "t")], id=c("t"))
    #sensorDerivPlot <- ggplot(data=meltedSensorDeriv, aes(x=t, y=value, color=variable)) + geom_line()
    # create class plot
    meltedClass <- melt(syncedData[, c("x", "z", "t")], id=c("t"))
    classPlot <- ggplot(data=meltedClass, aes(x=t, y=value, color=variable)) + geom_line()
    # save to png
    png(paste(outputName, "synced.png", sep=""), width=graphWidthPx, height=graphHeightPx)
    grid.arrange(sensorPlot, classPlot, ncol=1)
    #grid.arrange(sensorPlot, sensorDerivPlot, classPlot, ncol=1)
    dev.off()
  }
  
  ### OUTPUT ###
  # write data to json file
  #jsonFile <- file(paste(outputName, "synced.json", sep=""))
  #writeLines(toJSON(syncedData, pretty=FALSE), jsonFile)
  #close(jsonFile)
  # write to csv
  write.csv(syncedData[, !(names(syncedData) %in% c("t"))], file=paste(outputName, "synced.csv", sep=""), row.names=FALSE)
}
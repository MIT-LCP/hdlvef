## LIBRARIES INSTALL 
install.packages('Hmisc')
install.packages('ROCR')
install.packages('epicalc')
install.packages('survival')

## LIBRARIES 
library(Hmisc)
library(ROCR)
library(epicalc)
library(survival)

## CLEAR WORKSPACE
rm(list=ls())

## INPUT DATA
filename = c("data/icustay_echos.csv")
path = c("/Users/tpb/Dropbox/Research/Projects/Hyperdynamic")
DATA = read.csv(paste(path,filename,sep="/"))

names(DATA)
attach(DATA)

hist(ECHO_DT)
plot(ECHO_DT,LVEF)

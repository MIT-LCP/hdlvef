## LIBRARIES INSTALL 
#install.packages('Hmisc')
#install.packages('ROCR')
#install.packages('epicalc')
#install.packages('survival')

## LIBRARIES 
library(Hmisc)
library(ROCR)
library(epicalc)
library(survival)

## CLEAR WORKSPACE
rm(list=ls())

# P-values to table 1

## INPUT DATA
filename = c("data/echo_final.csv")
path = c("/Users/tpb/Research/hdlvef")
DATA = read.csv(paste(path,filename,sep="/"))

names(DATA)
## Transform Categorical Variables
DATA = transform(DATA,
                  GENDER = factor(GENDER,c("F","M")),
                  CAREUNIT = factor(CAREUNIT,c("MICU","SICU")),
                  LVEF_GROUP = factor(LVEF_GROUP,c("1","2","3","4")),
                  HDLVEF = factor(HDLVEF,c("0","1")),
                  SEPSIS = factor(SEPSIS,c("0","1")),
                  CM_CHF = factor(CM_CHF,c("0","1")),
                  CM_VALVULAR_DISEASE = factor(CM_VALVULAR_DISEASE,c("0","1")),
                  CM_CHRONIC_PULMONARY = factor(CM_CHRONIC_PULMONARY,c("0","1")),
                  CM_PSYCHOSIS = factor(CM_PSYCHOSIS,c("0","1")),
                  CM_ALCOHOL_ABUSE = factor(CM_ALCOHOL_ABUSE,c("0","1")),
                  CM_HYPERTENSION = factor(CM_HYPERTENSION,c("0","1")),
                  CM_DEPRESSION = factor(CM_DEPRESSION,c("0","1")),
                  CM_DIABETES = factor(CM_DIABETES,c("0","1")),
                  CM_ARRHYTHMIAS = factor(CM_ARRHYTHMIAS,c("0","1")),
                  CM_RENAL_FAILURE = factor(CM_RENAL_FAILURE,c("0","1")),
                  CM_CANCER = factor(CM_CANCER,c("0","1")),
                  VASOPRESSOR = factor(VASOPRESSOR,c("0","1")),
                  VENTILATED = factor(VENTILATED,c("0","1")),
                  RRT = factor(RRT,c("0","1")),
                  ICUSTAY_MORTALITY = factor(ICUSTAY_MORTALITY,c("0","1")),
                  HOSPITAL_MORTALITY = factor(HOSPITAL_MORTALITY,c("0","1")))


#-------------------------------------------------------------------------
# variables

vars_cnt = c("AGE","SAPSI")
vars_prop = c("GENDER","CAREUNIT")
vars_labs = c("MAX_WBC","MAX_LACTATE","MAX_CREATININE")
vars_elix_pts = c("ELIX_28D_PT","ELIX_1YR_PT","ELIX_2YR_PT")
vars_elix_cm = c("CM_DIABETES","CM_ALCOHOL_ABUSE","CM_ARRHYTHMIAS",
              "CM_VALVULAR_DISEASE","CM_HYPERTENSION","CM_RENAL_FAILURE",
              "CM_CHRONIC_PULMONARY","CM_LIVER_DISEASE","CM_CANCER","CM_PSYCHOSIS",   
              "CM_DEPRESSION","CM_CHF")
vars_treat = c("VASOPRESSOR","RRT","VENTILATED")
vars_regres = c("AGE","GENDER","ELIX_28D_PT","SOFA","VENTILATED","ADJUSTED_VASOPRESSORDOSE","HDLVEF")
vars_vitals = c("HR_HIGHEST","MAP_LOWEST","TEMP_HIGHEST")
vars_vasopressors = c("VASOPRESSOR_DT","NO_VASOPRESSORS","MAX_VASOPRESSOR_ADJUSTEDDOSE","AUC_VASOPRESSOR_DOSE")
lvef_labels = c("LVEF $<$ 35\\%","35\\% $<$ LVEF $<$ 55\\%","NLVEF ($>$55\\%)","HDLVEF ($>$75\\%)")

#-------------------------------------------------------------------------
# SOURCE FUNCTIONS
source(paste(path,'R/analysis.R',sep='/'))

#-------------------------------------------------------------------------
# COHORTS
COHORT = subset(DATA,(DATA$LVEF_GROUP==3 | DATA$LVEF_GROUP==4))
SURVIVORS = subset(COHORT,MORTALITY_28D==0)
VASOPRESSORS = subset(COHORT,VASOPRESSOR==1)

#-------------------------------------------------------------------------
# TABLE 1.A - NORMAL VS. HYPERDYNAMIC
source(paste(path,'R/table1.R',sep='/'))

#-------------------------------------------------------------------------
# TABLE 2: HYPERDYNAMIC - LOGISTIC REGRESSION MODEL
source(paste(path,'R/mregr_hdlvef.R',sep='/'))
source(paste(path,'R/mregr_hdlvef_vasopressor.R',sep='/'))
source(paste(path,'R/mregr_hdlvef_auc_vasopressor.R',sep='/'))
source(paste(path,'R/mregr_hdlvef_no_vasopressor.R',sep='/'))

#-------------------------------------------------------------------------
# TABLE 3: HYPERDYNAMIC & SEPSIS - LOGISTIC REGRESSION MODEL
source(paste(path,'R/mregr_sepsis.R',sep='/'))

#-------------------------------------------------------------------------
# TABLE 4: HYPERDYNAMIC COX REGRESSION MODEL of ONE-YEAR MORTALITY
source(paste(path,'R/hazard_survivors.R',sep='/'))

#-------------------------------------------------------------------------
# TABLE 5: VASOPRESSORS
source(paste(path,'R/vasopressor.R',sep='/'))


## LIBRARIES 
library(Hmisc)
library(ROCR)
library(epicalc)
library(survival)

## INPUT DATA
DATA$TTE = 0

## INPUT CONTROL DATA
filename = c("data/export-20150608.csv")
path = c("/Users/tpb/Work/hdlvef")
CONTROL = read.csv(paste(path,filename,sep="/"))
CONTROL$TTE = 1
CONTROL$HDLVEF = 0
CONTROL$LVEF_GROUP = -1
CONTROL$ECHO_DT = 0

## UNION CONTROL & DATA
MERGED = rbind(DATA,CONTROL)
names(MERGED)

## TRANSFORM DATA
MERGED = transform(MERGED,
                 GENDER = factor(GENDER,c("F","M")),
                 CAREUNIT = factor(CAREUNIT,c("MICU","SICU")),
                 LVEF_GROUP = factor(LVEF_GROUP,c("-1","1","2","3","4")),
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
COHORT = subset(MERGED,(MERGED$LVEF_GROUP==3 | MERGED$LVEF_GROUP==4 | MERGED$LVEF_GROUP == -1))

attach(COHORT)
dep = "TTE"
y = eval(parse(text=dep))

filename = sprintf("%s/report/table1_tte.tex",path); 
ff = file(filename,open="wt")

line = sprintf(" & \\textbf{TTE} (N=%d) & \\textbf{No TTE} (N=%d) & $P$-value \\\\",sum(y==0),sum(y==1))
writeLines(line,ff)
writeLines(' & \\multicolumn{2}{c}{N (\\%) or median [IQR]} & \\\\ \\hline',ff)

# AGE
cnt_analysis_p("AGE",dep,ff,"Age")

# GENDER
prop_analysis_p("GENDER",dep,ff,'Gender (Male)')

# CAREUNIT
tn = table(CAREUNIT,y)
p = prop.table(tn,2)
ll = levels(CAREUNIT)
fs = fisher.test(tn)
line = sprintf("Care Unit");
if (fs$p.value<0.01) {
  line = sprintf('%s&~&~&\\textbf{$<$ 0.01}\\\\',line,fs$p.value)
} else if (fs$p.value<0.05) {
  line = sprintf('%s& ~ & ~ &\\textbf{%.2f}\\\\',line,fs$p.value)
} else {
  line = sprintf('%s& ~ & ~ & %.1f\\\\',line,fs$p.value)
}
writeLines(line,ff)
for ( j in seq(1,length(ll)) ) {
  line = sprintf('~~%s&%d (%.0f \\%s)&%d (%.0f \\%s)&\\\\',ll[j],
                 tn[j,1],100*p[j,1],'%',tn[j,2],100*p[j,2],'%')
  writeLines(line,ff)  
}

# Time from ICU intime to ECHO report
#cnt_analysis_p("ECHO_DT",dep,ff,"Time to echo (days)")
cnt_analysis_p("VASOPRESSOR_DT",dep,ff,"Time to vasopressors (days)")

# Elixhauser co-morbidities
# fix proportions
writeLines("\\multicolumn{3}{l}{Co-morbidities by ICD9 \\& DRG Codes}\\\\",ff);
lapply(vars_elix_cm,elix_analysis_p,dep,ff)

# SOFA
writeLines("Illness & ~ & ~ &\\\\",ff);
cnt_analysis_p("SOFA",dep,ff,"~~SOFA")
prop_analysis_p("SEPSIS",dep,ff,"~~Septic")

# Vital Signs
writeLines(sprintf("Vital Signs & ~ & ~ &\\\\"), ff)
lapply(vars_vitals,vitals_analysis_p,dep,ff)

# Labs
writeLines(sprintf("Lab Results & ~ & ~ &\\\\"), ff)
lapply(vars_labs,labs_analysis_p,dep,ff)

# Treatments - fix proportions/numbers
writeLines(sprintf("Treatments & ~ & ~ &\\\\"), ff)
lapply(vars_treat,treatment_analysis_p,dep,ff)

# Fluids
cnt_analysis_p("FI_1D_ML",dep,ff,"~~IVF first 24hr (ml)")
cnt_analysis_p("FI_3D_ML",dep,ff,"~~IVF first 72hr (ml)")

# Mortality
writeLines("Mortality & ~ & ~ &\\\\",ff);
prop_analysis_p("ICUSTAY_MORTALITY",dep,ff,"~~ICU Stay")
prop_analysis_p("HOSPITAL_MORTALITY",dep,ff,"~~Hospital Stay")
prop_analysis_p("MORTALITY_28D",dep,ff,"~~28-days")
prop_analysis_p("ONE_YEAR_MORTALITY",dep,ff,"~~1-year")

close(ff)

detach(COHORT)


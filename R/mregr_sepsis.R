SEPSIS = subset(COHORT,COHORT$SEPSIS==1)

ff = file(sprintf("%s/report/table3_sepsis_regression.tex",path),open="wt")
writeLines("~ & Odds-ratio (95\\% Confidence Interval) & \\textbf{P-value}\\\\ \\hline",ff)

# LOGISTIC REGRESSION
regres_labels = c("Age","Gender (Male)","Elixhauser Score","SOFA","Ventilated",
                  "Max Adjusted Vasopressor Dose","HDLVEF")
mylogit = glm(MORTALITY_28D ~ AGE + GENDER + ELIX_28D_PT + SOFA + 
              VENTILATED + MAX_VASOPRESSOR_ADJUSTEDDOSE + HDLVEF,
              data=SEPSIS,family="binomial")
# Coefficients of Logistic Regression
cfs = summary(mylogit)$coefficients
# Odds Ration and Confidence Intervals
or = exp(cbind(OR = coef(mylogit),confint(mylogit)))
for ( j in seq(2,nrow(or)) ) {
  line = sprintf('%s&%.3f (%.3f,%.3f)',regres_labels[j-1],
                 or[j,1],or[j,2],or[j,3])
  if (cfs[j,4]<0.001) {
    line = sprintf('%s&\\textbf{$<$0.001}\\\\',line)
  } else if (cfs[j,4]<0.01) {
    line = sprintf('%s&\\textbf{%.3f}\\\\',line,cfs[j,4])
  } else if (cfs[j,4]<0.05) {
    line = sprintf('%s&\\textbf{%.2f}\\\\',line,cfs[j,4])
  } else {
    line = sprintf('%s&%.1f\\\\',line,cfs[j,4])
  }
  writeLines(line,ff)
}
close(ff)

# Plot ROC
# pdf(sprintf('%s/report/figure/fig-auc-sepsis.pdf',path))
# auc = lroc(mylogit,title=FALSE,auc.coords = c(.2,.1))
# dev.off()

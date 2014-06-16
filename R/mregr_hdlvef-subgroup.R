dep = "HDLVEF"
y = eval(parse(text=dep))

SUBGROUP = subset(COHORT,(COHORT$CM_CHF==0 | COHORT$CM_HYPERTENSION==0))

ff = file(sprintf("%s/report/tex/table2_woCHF_regression-%s.tex",path,tolower(dep)),open="wt")
writeLines("~ & Odds-ratio (95\\% Confidence Interval) & \\textbf{P-value}\\\\ \\hline",ff)

# LOGISTIC REGRESSION
mylogit = glm(MORTALITY_28D ~ AGE + GENDER + ELIX_28D_PT + SAPSI + VASOPRESSOR + HDLVEF,data=SUBGROUP,family="binomial")
# Coefficients of Logistic Regression
cfs = summary(mylogit)$coefficients
# Odds Ration and Confidence Intervals
or = exp(cbind(OR = coef(mylogit),confint(mylogit)))
for ( j in seq(2,nrow(or)) ) {
  line = sprintf('%s&%.4f (%.4f,%.4f)',regres_labels[j-1],
                 or[j,1],or[j,2],or[j,3])
  if (cfs[j,4]<0.001) {
    line = sprintf('%s&\\textbf{$<$0.001*}\\\\',line)
  } else if (cfs[j,4]<0.01) {
    line = sprintf('%s&\\textbf{%.3f*}\\\\',line)
  } else if (cfs[j,4]<0.05) {
    line = sprintf('%s&\\textbf{%.2f*}\\\\',line,cfs[j,4])
  } else {
    line = sprintf('%s&%.1f\\\\',line,cfs[j,4])
  }
  writeLines(line,ff)
}
close(ff)


# Plot ROC
pdf(paste(path,'report/figure/fig-auc-hyerdynamic.pdf',sep='/'))
auc = lroc(mylogit,title=FALSE,auc.coords = c(.2,.1))
dev.off()

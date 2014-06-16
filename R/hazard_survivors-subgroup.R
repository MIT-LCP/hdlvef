
SURVIVORS = subset(COHORT,(COHORT$MORTALITY_28D==0 & (COHORT$CM_CHF==0 | COHORT$CM_HYPERTENSION==0)))

ff = file(sprintf("%s/report/tex/table4_coxmodel_woCM_survivors-1yr.tex",path),open="wt")
writeLines("~ & Hazard ratio (95\\% Confidence Interval) & \\textbf{P-value}\\\\ \\hline",ff)

# COX REGRESSION - w/o time dependency
#cox.model = coxph(Surv(ONE_YEAR_MORTALITY) ~ AGE + GENDER + SAPSI + VASOPRESSOR + HDLVEF + ELIX_1YR_PT,data=subgroup)
#temp = cox.zph(cox.model)
#print(temp)
#plot(SURVIVAL_DAYS,ELIX_1YR_PT)
#abline(lm(ELIX_1YR_PT~SURVIVAL_DAYS),col="red")

# COX REGRESSION - with time dependency
cox.model = coxph(Surv(ONE_YEAR_MORTALITY) ~ AGE + GENDER + SAPSI + VASOPRESSOR + HDLVEF + tt(ELIX_1YR_PT),data=SURVIVORS,tt=function(x,t,...) x-lm(x~t)$coeff[2]*t)
temp = cox.zph(cox.model)
print(temp)

s = summary(cox.model)
cfs = s$coefficients;
for ( j in seq(1,nrow(s$conf.int)) ) {
  line = sprintf('%s&%.4f (%.4f,%.4f)',regres_labels[j],
                 s$conf.int[j,2],s$conf.int[j,3],s$conf.int[j,4])
  if (cfs[j,4]<0.001) {
    line = sprintf('%s&\\textbf{$<$0.001}\\\\',line)
  } else if (cfs[j,4]<0.01) {
    line = sprintf('%s&\\textbf{%.3f}\\\\',line)
  } else if (cfs[j,4]<0.05) {
    line = sprintf('%s&\\textbf{%.2f}\\\\',line,cfs[j,4])
  } else {
    line = sprintf('%s&%.1f\\\\',line,cfs[j,4])
  }
  writeLines(line,ff)
}
close(ff)

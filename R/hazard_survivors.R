attach(SURVIVORS)

ff = file(sprintf("%s/report/table4_coxmodel_survivors-1yr.tex",path),open="wt")
writeLines("~ & Hazard ratio (95\\% Confidence Interval) & \\textbf{P-value}\\\\ \\hline",ff)

# COX REGRESSION - w/o time dependency
#cox.model = coxph(Surv(ONE_YEAR_MORTALITY) ~ AGE + GENDER + SAPSI + VASOPRESSOR + HDLVEF + ELIX_1YR_PT,data=SURVIVORS)
#temp = cox.zph(cox.model)
#print(temp)
#summary(cox.model)
#plot(SURVIVORS$SURVIVAL_DAYS,SURVIVORS$ELIX_1YR_PT,
#     xlab="Survival (Days)",
#     ylab="Elixhauser 1-year Mortality Points")
#abline(lm(SURVIVORS$ELIX_1YR_PT~SURVIVORS$SURVIVAL_DAYS),col="red")

# COX REGRESSION - with time dependency correction for elixhauser points
regres_labels = c("Age","Gender (Male)","Elixhauser Score","SOFA","Ventilated",
                  "Max Adjusted Vasopressor Dose","HDLVEF")
cox.model = coxph(Surv(ONE_YEAR_MORTALITY) ~ AGE + GENDER + tt(ELIX_1YR_PT) + SOFA + 
                    VENTILATED + MAX_VASOPRESSOR_ADJUSTEDDOSE + HDLVEF,
                  data=SURVIVORS,tt=function(x,t,...) x-lm(x~t)$coeff[2]*t)
s = summary(cox.model)
cfs = s$coefficients;
for ( j in seq(1,nrow(s$conf.int)) ) {
  line = sprintf('%s&%.4f (%.4f,%.4f)',regres_labels[j],
                 s$conf.int[j,2],exp(-log(s$conf.int[j,4])),exp(-log(s$conf.int[j,3])))
  if (cfs[j,5]<0.001) {
    line = sprintf('%s&\\textbf{$<$0.001}\\\\',line)
  } else if (cfs[j,5]<0.01) {
    line = sprintf('%s&\\textbf{%.3f}\\\\',line, cfs[j,5])
  } else if (cfs[j,5]<0.05) {
    line = sprintf('%s&\\textbf{%.2f}\\\\',line,cfs[j,5])
  } else {
    line = sprintf('%s&%.1f\\\\',line,cfs[j,5])
  }
  writeLines(line,ff)
}

close(ff)

detach(SURVIVORS)
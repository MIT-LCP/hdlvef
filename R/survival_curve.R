#-------------------------------------------------------------------------
# FIGURE 1 - HOSPITAL SURVIVAL CURVES: ACUTE_HYPERDYNAMIC VS. NORMAL
# Adjusted survival curves for co-variates

#survivors = subset(DATA,DATA$SURVIVORS==1)
survivors = subset(DATA,DATA$MORTALITY_28D==0)

attach(SURVIVORS)
plot.new()
pdf(paste(path,'report/figure/fig-survival_curve.pdf',sep='/'))
surv = survfit(Surv(SURVIVAL_DAYS,ONE_YEAR_MORTALITY==1) ~ HPEF)
lr = survdiff(Surv(SURVIVAL_DAYS,ONE_YEAR_MORTALITY==1) ~ HPEF)
pl = plot(surv,col=c("blue","red"),
          xlim=range(0,360),
          xlab="Days",
          ylab="Cummulative Survival (%)")
legend("bottomleft",inset=.05,c('NORMAL EF','HYPERDYNAMIC EF (ALL)'),fill=c("blue","red"))
dev.off()
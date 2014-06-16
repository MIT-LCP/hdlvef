attach(COHORT)

dep = "HDLVEF"
y = eval(parse(text=dep))


filename = sprintf("%s/report/tex/table1_normal-%s.tex",path,tolower(dep)); 
ff = file(filename,open="wt")

line = sprintf(" & \\textbf{NLVEF} (N=%d) & \\textbf{HDLVEF} (N=%d) & $P$-value\\\\",sum(y==0),sum(y==1))
writeLines(line,ff)
writeLines(' & \\multicolumn{2}{c}{N (\\%) or median (IQR)} & \\\\ \\hline',ff)

# AGE
cnt_analysis_p("AGE",dep,ff,"Age")

# GENDER
prop_analysis_p("GENDER",dep,ff,'Gender (Male)')
# tn = table(GENDER,y)
# ll = levels(GENDER)
# fs = fisher.test(tn)
# p = prop.table(tn,2)
# line = sprintf('Gender (Male)&%d (%.2f)&%d (%.2f)',
#                tn[2,1],100*p[2,1],tn[2,2],100*p[2,2])
# if (fs$p.value$<$0.05) {
#   line = paste(line,'\\textbf{*}\\\\',sep='')
# } else {
#   line = paste(line,'\\\\',sep='')
# }
# writeLines(line,ff)


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
# if (fs$p.value<0.05) {
#   line = paste(line,'\\textbf{*} & ~ & ~\\\\',sep='')
# } else {
#   line = paste(line,'& ~ & ~\\\\',sep='')
# }
writeLines(line,ff)
for ( j in seq(1,length(ll)) ) {
  line = sprintf('~~%s&%d (%.0f \\%s)&%d (%.0f \\%s)&\\\\',ll[j],
                 tn[j,1],100*p[j,1],'%',tn[j,2],100*p[j,2],'%')
  writeLines(line,ff)  
}

# Time from ICU intime to ECHO report
cnt_analysis_p("ECHO_DT",dep,ff,"Time to echo (days)")

# Elixhauser co-morbidities
# fix proportions
writeLines("\\multicolumn{3}{l}{Co-morbidities by ICD9 \\& DRG Codes}\\\\",ff);
lapply(vars_elix_cm,elix_analysis_p,dep,ff)

# SAPS
writeLines("Illness & ~ & ~ &\\\\",ff);
cnt_analysis_p("SAPSI",dep,ff,"~~SAPS-I")
prop_analysis_p("SEPSIS",dep,ff,"~~Septic")

# Labs
writeLines(sprintf("Labs & ~ & ~ &\\\\"), ff)
lapply(vars_labs,labs_analysis_p,dep,ff)

# Treatments
# fix proportions/numbers
writeLines(sprintf("Treatments & ~ & ~ &\\\\"), ff)
lapply(vars_treat,treatment_analysis_p,dep,ff)

# Fluids
cnt_analysis_p("FI_1D_ML",dep,ff,"~~IVF first 24hr (ml)")

close(ff)

detach(COHORT)


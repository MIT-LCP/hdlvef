detach(COHORT)
attach(DATA)

dep="SEPSIS"
y = eval(parse(text=dep))

ff = file(sprintf("%s/report/tex/table3_normal-%s.tex",path,tolower(dep)),open="wt")
line = sprintf("~ & \\textbf{Non-Septic} (N=%d) & \\textbf{Septic} (N=%d) & $P$-value\\\\",sum(y==0),sum(y==1))
writeLines(line,ff)
writeLines('~ & N (\\%)&N (\\%) &\\\\ \\hline',ff)

tn = table(LVEF_GROUP,y)
p = prop.table(tn,2)
fs = fisher.test(tn)
for ( j in seq(1,nrow(tn)) ) {
  line = sprintf('%s&%d (%.2f)&%d (%.2f)', lvef_labels[j],
                 tn[j,1],100*p[j,1],tn[j,2],100*p[j,2])
  if (fs$p.value<0.01) {
    line = sprintf('%s&\\textbf{$<$ 0.01}\\\\',line,fs$p.value)
  } else if (fs$p.value<0.05) {
    line = sprintf('%s&\\textbf{%.2f}\\\\',line,fs$p.value)
  } else {
    line = sprintf('%s& \\textbf{%.1f}\\\\',line,fs$p.value)
  }
  writeLines(line,ff)
}
close(ff)

detach(DATA)
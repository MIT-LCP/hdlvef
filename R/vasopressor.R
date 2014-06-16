attach(COHORT)

dep = "HDLVEF"
y = eval(parse(text=dep))
filename = sprintf("%s/report/tex/table1_vasopressors-%s.tex",path,tolower(dep)); 
ff = file(filename,open="wt")

line = sprintf(" & \\textbf{NLVEF} (N=%d) & \\textbf{HDLVEF} (N=%d) & $P$-value\\\\",sum(y==0),sum(y==1))
writeLines(line,ff)
writeLines(' & N (\\%) & N (\\%) &\\\\ \\hline',ff)

lapply(vars_vsps,treatment_analysis_p,dep,ff)

close(ff)

detach(COHORT)
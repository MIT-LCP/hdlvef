attach(VASOPRESSORS)

dep = "HDLVEF"
y = eval(parse(text=dep))
filename = sprintf("%s/report/table5_vasopressors-%s.tex",path,tolower(dep)); 
ff = file(filename,open="wt")

line = sprintf(" & \\textbf{NLVEF} (N=%d) & \\textbf{HDLVEF} (N=%d) & $P$-value\\\\",sum(y==0),sum(y==1))
writeLines(line,ff)
writeLines(' & Median [IQR] & Median [IQR] &\\\\ \\hline',ff)
lapply(vars_vasopressors,vasopressor_analysis_p,dep,ff)

close(ff)

detach(VASOPRESSORS)
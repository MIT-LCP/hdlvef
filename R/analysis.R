#-------------------------------------------------------------------------
# FUNCTIONS

cnt_analysis <- function(var, dep, ff, label) {
  x = eval(parse(text=var))
  y = eval(parse(text=dep))
  
  m = aggregate(COHORT[var],COHORT[dep],median,na.rm=T)
  s = aggregate(COHORT[var],COHORT[dep],IQR,na.rm=T)
  #tt = t.test(x~y)
  tt = wilcox.test(x~y,conf.int=T)
  if (label=='') {
    label = gsub("CM_","",var)
    label = gsub("_"," ",tolower(label))
  }
  line = sprintf('%s&%.2f (%.2f)&%.2f (%.2f)',label,
                 m[1,2],s[1,2],m[2,2],s[2,2])
  if (tt$p.value<0.05) {
    line = paste(line,'\\textbf{*}\\\\',sep='')
  } else {
    line = paste(line,'\\\\',sep='')
  }
  writeLines(line, ff)
}

cnt_analysis_p <- function(var, dep, ff, label) {
  x = eval(parse(text=var))
  y = eval(parse(text=dep))

  m = aggregate(COHORT[var],COHORT[dep],median,na.rm=T)
  s = aggregate(COHORT[var],COHORT[dep],quantile,na.rm=T)
  
  #tt = t.test(x~y)
  tt = wilcox.test(x~y,conf.int=T)
  if (label=='') {
    label = gsub("CM_","",var)
    label = gsub("_"," ",tolower(label))
  }
  if (var=="AGE" | var=="SOFA" | var=="FI_1D_ML" | var=="FI_3D_ML") {
    line = sprintf('%s & %.0f [%.0f - %.0f] & %.0f [%.0f - %.0f]',label,
                  m[1,2],s[1,2][2],s[1,2][4],m[2,2],s[2,2][2],s[2,2][4])
  }
  else {
    line = sprintf('%s & %.1f [%.1f - %.1f] & %.1f [%.1f - %.1f]',label,
                 m[1,2],s[1,2][2],s[1,2][4],m[2,2],s[2,2][2],s[2,2][4])
  }
  if (tt$p.value<0.01) {
    line = sprintf('%s&\\textbf{$<$ 0.01}\\\\',line,tt$p.value)
  } else if (tt$p.value<0.05) {
    line = sprintf('%s&%.2f\\\\',line,tt$p.value)
  } else {
    line = sprintf('%s&%.1f\\\\',line,tt$p.value)
  }
  writeLines(line, ff)
}


labs_analysis <- function(var, dep, ff) {
  x = eval(parse(text=var))
  y = eval(parse(text=dep))
  m = aggregate(COHORT[var],COHORT[dep],median,na.rm=T)
  s = aggregate(COHORT[var],COHORT[dep],IQR,na.rm=T)
  #tt = t.test(x~y)
  tt = wilcox.test(x~y,conf.int=T)
  label = gsub("_"," ",tolower(var))
  if (label == 'max wbc') {
    label = 'Max WBC'
  } else if (label == 'wbc') {
    label = 'WBC'
  } else {
    label = capitalize(label)
  }
  line = sprintf('~~%s&%.2f (%.2f)&%.2f (%.2f)',label,
                 m[1,2],s[1,2],m[2,2],s[2,2])
  if (tt$p.value<0.05) {
    line = paste(line,'\\textbf{*}\\\\',sep='')
  } else {
    line = paste(line,'\\\\',sep='')
  }
  writeLines(line, ff)
}

labs_analysis_p <- function(var, dep, ff) {
  x = eval(parse(text=var))
  y = eval(parse(text=dep))
  m = aggregate(COHORT[var],COHORT[dep],median,na.rm=T)
  s = aggregate(COHORT[var],COHORT[dep],quantile,na.rm=T)
  #tt = t.test(x~y)
  tt = wilcox.test(x~y,conf.int=T)
  label = gsub("_"," ",tolower(var))
  if (label == 'max wbc') {
    label = 'Max WBC'
  } else if (label == 'wbc') {
    labe = 'WBC'
  } else {
    label = capitalize(label)
  }
  
  line = sprintf('~~%s&%.1f [%.1f - %.1f]&%.1f [%.1f - %.1f]',label,
                 m[1,2],s[1,2][2],s[1,2][4],m[2,2],s[2,2][2],s[2,2][4])
  
  if (tt$p.value<0.01) {
    line = sprintf('%s&\\textbf{$<$ 0.01}\\\\',line,tt$p.value)
  } else if (tt$p.value<0.05) {
    line = sprintf('%s&%.2f\\\\',line,tt$p.value)
  } else {
    line = sprintf('%s&%.1f\\\\',line,tt$p.value)
  }
  writeLines(line, ff)
}

prop_analysis = function(var, dep, ff) {
  x = eval(parse(text=var))
  y = eval(parse(text=dep))
  tn = table(x,y)
  p = prop.table(tn,2)
  
  fs = fisher.test(tn)

  line = sprintf('%s&%d (%.2f)&%d (%.2f)',gsub("_"," ",capitalize(var)),
                 tn[2,1],100*p[2,1],tn[2,2],100*p[2,2])
  
  if (fs$p.value<0.05) {
    line = paste(line,sprintf('\\textbf{*}\\\\'),sep='')
  } else {
    line = paste(line,sprintf('\\\\'),sep='')
  }
  writeLines(line,ff)
}

prop_analysis_p = function(var, dep, ff, label) {
  x = eval(parse(text=var))
  y = eval(parse(text=dep))
  
  tn = table(x,y)
  p = prop.table(tn,2)
  
  fs = fisher.test(tn)
  
  line = sprintf('%s&%.0f (%.0f \\%s) & %.0f (%.0f \\%s)',label,
                 tn[2,1],100*p[2,1],'%',tn[2,2],100*p[2,2],'%')
  
  if (fs$p.value<0.01) {
    line = sprintf('%s&\\textbf{$<$ 0.01}\\\\',line,fs$p.value)
  } else if (fs$p.value<0.05) {
    line = sprintf('%s&%.2f\\\\',line,fs$p.value)
  } else {
    line = sprintf('%s&%.1f\\\\',line,fs$p.value)
  }
  
  writeLines(line,ff)
}

# fix proportion bug
treatment_analysis = function(var, dep, ff) {
  
  x = eval(parse(text=var))
  y = eval(parse(text=dep))
  
  tn = table(x,y)
  p = prop.table(tn,2)
  fs = fisher.test(tn)
  label = tolower(var)
  if (label == 'rrt') {
    label = 'RRT'
  } else {
    if (label == 'dobutamine_flg') {
      label = 'Received Dobutamine'
    } else {
      label = capitalize(label)
    }
  }

  line = sprintf('~~%s&%d (%.0f \\%s)&%d (%.0f \\%s)',label,
                 tn[2,1],100*p[2,1],'%',tn[2,2],100*p[2,2],'%')
  if (fs$p.value<0.05) {
    line = paste(line,'\\textbf{*}\\\\',sep='')
  } else {
    line = paste(line,'\\\\',sep='')
  }
  writeLines(line,ff)
}

treatment_analysis_p = function(var, dep, ff) {
  
  x = eval(parse(text=var))
  y = eval(parse(text=dep))
  
  tn = table(x,y)
  p = prop.table(tn,2)
  fs = fisher.test(tn)
  
  label = tolower(var)
  if (label == 'rrt') {
    label = 'RRT'
  } else {
    if (label == 'dobutamine_flg') {
      label = 'Received Dobutamine'
    } else {
      label = capitalize(label)
    }
  }
  line = sprintf('~~%s&%d (%.0f \\%s)&%d (%.0f \\%s)',label,
                 tn[2,1],100*p[2,1],'%',tn[2,2],100*p[2,2],'%')
  
  if (fs$p.value<0.01) {
    line = sprintf('%s&\\textbf{$<$ 0.01}\\\\',line,fs$p.value)
  } else if (fs$p.value<0.05) {
    line = sprintf('%s&%.2f\\\\',line,fs$p.value)
  } else {
    line = sprintf('%s&%.1f\\\\',line,fs$p.value)
  }
  writeLines(line,ff)
}

vasopressor_analysis_p = function(var, dep, ff) {
  
  x = eval(parse(text=var))
  y = eval(parse(text=dep))
  m = aggregate(VASOPRESSORS[var],VASOPRESSORS[dep],median,na.rm=T)
  s = aggregate(VASOPRESSORS[var],VASOPRESSORS[dep],quantile,na.rm=T)
  #tt = t.test(x~y)
  tt = wilcox.test(x~y,conf.int=T)
  
  label = tolower(var)
  if (label == 'max_vasopressor_adjusteddose') {
    label = 'Adjusted Vasopressor Dose'
  } else if (label == 'auc_vasopressor_dose') {
    label = 'Total Volume of Vasopressor'
  } else if (label == 'vasopressor_dt') {
    label = 'Time to Vasopressors (days)'
  } else if (label == 'no_vasopressors') {
    label = 'No. Vasopressors'
  } else label = tolower(var)
  line = sprintf('%s&%.2f [%.2f - %.2f]&%.2f [%.2f - %.2f]',label,
                 m[1,2],s[1,2][2],s[1,2][4],m[2,2],s[2,2][2],s[2,2][4])

  if (tt$p.value<0.01) {
    line = sprintf('%s&\\textbf{$<$ 0.01}\\\\',line,tt$p.value)
  } else if (tt$p.value<0.05) {
    line = sprintf('%s&%.2f\\\\',line,tt$p.value)
  } else {
    line = sprintf('%s&%.1f\\\\',line,tt$p.value)
  }
  writeLines(line, ff)
}

elix_analysis = function(var, dep, ff) {
  x = eval(parse(text=var))
  y = eval(parse(text=dep))
  
  tn = table(x,y)
  p = prop.table(tn,2)
  fs = fisher.test(tn)
  label = gsub("CM_","",var)
  label = gsub("_"," ",tolower(label))
  if (label == "chf") {
    label = toupper(label)
  } else {
    label = capitalize(label)
  }
  line = sprintf('~~%s&%d (%.2f)&%d (%.2f)',label,
                 tn[2,1],100*p[2,1],tn[2,2],100*p[1,2])
  
  if (fs$p.value<0.05) {
    line = sprintf('%s\\textbf{*}\\\\',line)
  } else {
    line = sprintf('%s\\\\',line)
  }
  writeLines(line,ff)
}

elix_analysis_p = function(var, dep, ff) {
  x = eval(parse(text=var))
  y = eval(parse(text=dep))
  
  tn = table(x,y)
  p = prop.table(tn,2)
  p
  fs = fisher.test(tn)
  
  label = gsub("CM_","",var)
  label = gsub("_"," ",tolower(label))
  if (label == "chf") {
    label = toupper(label)
  } else {
    label = capitalize(label)
  }
  line = sprintf('~~%s&%d (%.0f \\%s)&%d (%.0f \\%s)',label,
                 tn[2,1],100*p[2,1],'%',tn[2,2],100*p[2,2],'%')
  
  if (fs$p.value<0.01) {
    line = sprintf('%s&\\textbf{$<$ 0.01}\\\\',line,fs$p.value)
  } else if (fs$p.value<0.05) {
    line = sprintf('%s&%.2f\\\\',line,fs$p.value)
  } else {
    line = sprintf('%s&%.1f\\\\',line,fs$p.value)
  }
  writeLines(line,ff)
}

vitals_analysis_p <- function(var, dep, ff) {

  x = eval(parse(text=var))
  y = eval(parse(text=dep))
  m = aggregate(COHORT[var],COHORT[dep],median,na.rm=T)
  s = aggregate(COHORT[var],COHORT[dep],quantile,na.rm=T)

  tt = wilcox.test(x~y,conf.int=T)
  label = gsub("_"," ",tolower(var))
  if (label == 'temp highest') {
    label = 'Max Temperature (C)'
    line = sprintf('~~%s&%.1f [%.1f - %.1f]&%.1f [%.1f - %.1f]',label,
                   m[1,2],s[1,2][2],s[1,2][4],m[2,2],s[2,2][2],s[2,2][4])

    } else if (label == 'hr highest') {
    label = 'Max HR (bpm)'
    line = sprintf('~~%s&%.0f [%.0f - %.0f]&%.0f [%.0f - %.0f]',label,
                   m[1,2],s[1,2][2],s[1,2][4],m[2,2],s[2,2][2],s[2,2][4])
    
    } else if (label == 'hr median d1') {
      label = 'Median HR Day1 (bpm)'
      line = sprintf('~~%s&%.0f [%.0f - %.0f]&%.0f [%.0f - %.0f]',label,
                     m[1,2],s[1,2][2],s[1,2][4],m[2,2],s[2,2][2],s[2,2][4])
      
  } else if (label == 'map lowest') {
    label = 'Min MAP'
    line = sprintf('~~%s&%.0f [%.0f - %.0f]&%.0f [%.0f - %.0f]',label,
                   m[1,2],s[1,2][2],s[1,2][4],m[2,2],s[2,2][2],s[2,2][4])
    
  } 
  
  if (tt$p.value<0.01) {
    line = sprintf('%s&\\textbf{$<$ 0.01}\\\\',line,tt$p.value)
  } else if (tt$p.value<0.05) {
    line = sprintf('%s&%.2f\\\\',line,tt$p.value)
  } else {
    line = sprintf('%s&%.1f\\\\',line,tt$p.value)
  }
  writeLines(line, ff)
}

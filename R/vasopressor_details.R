#Clear Workspace
rm(list=ls())

## INPUT DATA
filename = c("data/export_020614_vasopressors.csv")                  # UPDATE FILENAME
filename = c("data/export_020614.csv")                  # UPDATE FILENAME
#path = c("/Users/tpb/Dropbox/Research/Projects/Hyperdynamic")   # UPDATE PATH
path = c("/data/Projects/Dropbox/Projects/Hyperdynamic")   # UPDATE PATH
DATA = read.csv(paste(path,filename,sep="/"))
attach(DATA)

##Create vector with total number of patients 
# who were given each one of the vasopressors
DATA$DOPAMINE <- as.numeric(DATA$DOPAMINE)
DATA$DOBUTAMINE <- as.numeric(DATA$DOBUTAMINE)
DATA$EPINEPHRINE <- as.numeric(DATA$EPINEPHRINE)
DATA$VASOPRESSIN <- as.numeric(DATA$VASOPRESSIN)
DATA$LEVOPHED <- as.numeric(DATA$LEVOPHED)
DATA$MILRINONE <- as.numeric(DATA$MILRINONE)
DATA$NEOSYNEPHRINE <- as.numeric(DATA$NEOSYNEPHRINE)
DATA$HPEF <- as.numeric(DATA$HPEF)

dop0 = DATA$DOPAMINE[DATA$HPEF==1]





vec <- numeric(0) # empty vector
vec <- c(vec, sum(DATA$DOBUTAMINE), sum(DATA$DOPAMINE),
         sum(DATA$EPINEPHRINE), sum(DATA$EPINEPHRINE_K), 
         sum(DATA$VASOPRESSIN), sum(DATA$LEVOPHED_K), 
         sum(DATA$MILRINONE), sum(DATA$NEOSYNEPHRINE), sum(DATA$NEOSYNEPHRINE_K))


# Plot Results
labels = c("DOBUTAMINE", "DOPAMINE", "EPINEPHRINE",
          "EPINEPHRINE_K", "VASOPRESSIN", "LEVOPHED_K", 
          "MILRINONE", "NEOSYNEPHRINE", "NEOSYNEPHRINE_K")

labels = labels[order(vec)]
vec = sort(vec)

# Fitting Labels 

# Plot Results
pdf(sprintf('%s/report/figure/fig-vasopressors.pdf',path))
par(las=2)
par(mar=c(10,10,4,2)) # increase y-axis margin.
barplot(vec, main="Prescribed Vasopressors", horiz=TRUE,
        names.arg=c(labels),las=2,mar=c(5,8,4,2))
dev.off()

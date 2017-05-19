# set arguments
args=commandArgs(T)
input=args[1]
output=args[2]
widtharg=as.numeric(args[3])
heightarg=as.numeric(args[4])
rm(args)

mydata <- read.table(input)

pdf(file=paste(output, ".pdf", sep=""), width = widtharg, height = heightarg)

par(tcl=0.4)
plot(mydata[,1], type = "n", xlab = "windows", ylab = "CLRT")
axis(3, labels = FALSE)
axis(4, labels = FALSE)
points(mydata[,1], pch = 19)
lines(mydata[,1])

dev.off()

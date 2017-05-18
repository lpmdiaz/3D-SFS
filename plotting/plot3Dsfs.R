# install and load the plot3D package to easily plot 3D
# data with an additional dimension as colour variable
if(!require(plot3D)) {install.packages("plot3D"); require(plot3D)}

# install and load packages for interactive plotting
if(!require(rgl)) {install.packages("rgl"); require(rgl)}
if(!require(plot3Drgl)) {install.packages("plot3Drgl"); require(plot3Drgl)}

#set arguments
args=commandArgs(T)
input=args[1]
output=args[2]
phiarg=as.numeric(args[3])
thetaarg=as.numeric(args[4])
rm(args)

# load 3D SFS data
mydata <- read.table("parsed.3D.SFS")
x <- mydata$V1
y <- mydata$V2
z <- mydata$V3
sfs <- mydata$V4

# ignore first and last SFS values
sfs[1] <- sfs[length(sfs)] <- NA

# remove null SFS values
sfs[sfs == 0] <- NA

# remove values under 0.1
sfs[sfs <= 0.1] <- NA

pdf(file=paste(output, "pdf", sep=""))

# 3D SFS PLOTTING
# colvar = NULL prevents colouring from z var
# add "alpha = 0.5, " for transparency, slower
scatter3D(x, y, z, colvar = log10(sfs), NAcol = rgb(1,1,1, alpha = 0), pch = 15, phi = phiarg,
          theta = thetaarg, xlab = "population 1", ylab = "population 2", zlab = "population 3")

dev.off()

# interactive plotting
#plotrgl()
#scatter3Drgl()

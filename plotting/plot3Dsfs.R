# this program plots a parsed 3D SFS in a pdf (parsed 3D SFS as an output of parse3Dsfs)

#set arguments
args=commandArgs(T)
input=args[1]
output=args[2]
phiarg=as.numeric(args[3])
thetaarg=as.numeric(args[4])

if (length(args) < 1) { # help printout

  cat("Required arguments:\n")
  cat("\tInput parsed 3D SFS file path\n")
  cat("\tOutput file name without extension\n")
  cat("Optional arguments:\n")
  cat("\t3D plot angles phi and theta (default 40 and 40)\n")

} else { # rest of the program

  # install and load the plot3D package to easily plot 3D data with an additional dimension as colour variable
  if(!require(plot3D)) {install.packages("plot3D", repos = "http://cran.us.r-project.org"); require(plot3D)}
  
  if (!file.exists(input)) { # checking that input file exists
    stop("Error: input file does not exist")
  }

  if (length(args) <= 3) { # setting default angle values for the plot
    phiarg=40
    thetaarg=40
  }

  # load 3D SFS data
  mydata <- read.table(input)
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

  pdf(file=paste(output, ".pdf", sep=""))

  # 3D SFS PLOTTING
  # colvar = NULL prevents colouring from z var
  # can add an alpha paramter between 0 and 1 for controlling transparency
  scatter3D(x, y, z, colvar = log10(sfs), NAcol = rgb(1,1,1, alpha = 0), pch = 15, phi = phiarg,
          theta = thetaarg, xlab = "population 1", ylab = "population 2", zlab = "population 3")

  dev.off()

  # option to produce an interactive plot of the 3D SFS
  cat("Produce an interactive 3D SFS plot? [y/n] ")
  choice <- readLines(n=1)

  if (choice == "y") {

    # install and load packages for interactive plotting
    if(!require(rgl)) {install.packages("rgl"); require(rgl)}
    if(!require(plot3Drgl)) {install.packages("plot3Drgl", repos = "http://cran.us.r-project.org"); require(plot3Drgl)}

    # interactive plotting
    plotrgl()

    }

}


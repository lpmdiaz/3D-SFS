# this program takes the CLRT output of pop3Dclrt as an input and plots it in a pdf

# set arguments
args=commandArgs(T)
input=args[1]
output=args[2]
widtharg=as.numeric(args[3])
heightarg=as.numeric(args[4])

if (length(args) == 1) { # help printout

  print("Required arguments:\n")
  print("\tInput CLRT file path\n")
  print("\tOutput file name without extension\n")
  print("Optional arguments:\n")
  print("\tpdf output width and height (recommended: 14 and 7)\n")

} else { # rest of the program
  
  if (!file.exists(input)) { # checking that input file exists
    stop("Error: input file does not exist")
  }

  if (length(args) == 3) { # setting default pdf size values
    widtharg=14
    heightarg=7
  }

  mydata <- read.table(input) # read data

  pdf(file=paste(output, ".pdf", sep=""), width = widtharg, height = heightarg)

  # plotting instructions
  par(tcl=0.4)
  plot(mydata[,1], type = "n", xlab = "windows", ylab = "CLRT")
  axis(3, labels = FALSE)
  axis(4, labels = FALSE)
  points(mydata[,1], pch = 19)
  lines(mydata[,1])

  dev.off()
  
}


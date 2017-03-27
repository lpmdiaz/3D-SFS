
# input parameters
args <- commandArgs(T)
fwins <- args[1] # file with windows scan
fglobal <- args[2] # file with global SFS

# example of files:
# fwins="Data/ms.3d.windows.sfs"
# fglobal="Data/ms.3d.sfs"

# read files
global <- as.numeric(scan(fglobal, what="char", quiet=T))
wins <- read.table(fwins)

# Composite Likelihood for the global sfs
calcCL <- function(sfs, helpFact=1) {

	# Composite Likelihood for the global sfs
	# ATTENTION: you need to ignore values which correspond to a total frequency of 0, so they are in the first and last entry of the array
	sfs[1] <- sfs[length(sfs)] <- NA

	# how many SNPs (polymorphic sites) you have in the global SFS?
	nrSnps <- sum(sfs, na.rm=T)

	# these are the p^k values in log scale
	pk <- log((sfs/nrSnps)^(sfs/helpFact))
	# note that I have numerical instability because of small numbers to high power; I use a factor to rescale these powers 
	# the Composite Likelihood is just the sum
	CL <- sum(pk, na.rm=T)

	c(nrSnps, CL)

}

# values of Composite Likelihood for each window
CLs <- apply(FUN=calcCL, X=wins, MAR=1)
# in C you will have a loop here

# we need to scale the global SFS to have the same number of entries of the average SFS per window
CL_global <- calcCL(sfs=global)
# we do this by scaling the global SFS by a factor of the ratio between the total nr of SNPs and the average nr of SNPs per window
CL_global <- calcCL(sfs=global, helpFact=CL_global[1]/mean(CLs[1,]))

# this is the statistic
CLRT <- 2*(CLs[2,]-CL_global[2])

# print in stdout
cat(CLRT, sep="\n")

# p-values, these are distributed as a 50:50 mixture of point mass 0 and a chisquare with degrees of freedom equal to the size of the SFS -1
# therefore this is the 0.05 significance level
# qchisq(0.95, length(global)-3)*2




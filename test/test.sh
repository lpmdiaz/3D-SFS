
# test whetherCLRT correlates with selection and with PBS signal

# calculate genome-wide SFS (no selection)
# simulate selection ina short region and record CLRT and PBS

# programs

SAMTOOLS=~/Software/samtools/samtools
ANGSD=~/Software/angsd
MSMS=~/Software/msms/bin/msms

# variables

N_SAM=20
N_SAMS=$((N_SAM * 3))
N_IND=$((N_SAM / 2))
N_INDS=$((N_SAMS / 2))
N_REPS=1
# 4*12500*1.5e-8*1e7=7500
THETA=7500
RHO=7500
N_SITES=10000000
ERR_RATE=0.0075
DEPTH=10

# reference sequence

Rscript -e 'cat(">reference\n",paste(rep("A",1e7),sep="", collapse=""),"\n",sep="")' > Test/reference.fa 
$SAMTOOLS faidx Test/reference.fa

# genome-wide with no selection (use Schaffner model)

> Test/neutral.txt
$MSMS -N 12500 -ms $N_SAMS $N_REPS -t $THETA -r $RHO $N_SITES -I 3 $N_SAM $N_SAM $N_SAM -n 1 8 -n 2 8 -n 3 8 -ma x 1.6 0.4 1.6 x 0 0.4 0 x -en 0.004 1 1.92 -en 0.007 2 0.616 -en 0.008 3 0.616 -ej 0.04 3 2 -ej 0.7 2 1 -en 0.34 1 1 -seed 12345 > Test/neutral.txt

$ANGSD/misc/msToGlf -in Test/neutral.txt -out Test/neutral -regLen 0 -singleOut 1 -depth $DEPTH -err $ERR_RATE -pileup 0 -Nsites 1
# or use -regLen 0 for only SNPs, faster, otherwise use $N_SITES

# split into 3 populations

$ANGSD/misc/splitgl Test/neutral.glf.gz $N_INDS 1 10 > Test/neutral.1.glf.gz
$ANGSD/misc/splitgl Test/neutral.glf.gz $N_INDS 11 20 > Test/neutral.2.glf.gz
$ANGSD/misc/splitgl Test/neutral.glf.gz $N_INDS 21 30 > Test/neutral.3.glf.gz

# calculate SAF file for each population

for i in `seq 1 3`;
do
	echo $i
	$ANGSD/angsd -glf Test/neutral.$i.glf.gz -fai Test/reference.fa.fai -nInd $N_IND -doSaf 1 -P 2 -isSim 1 -out Test/neutral.$i 2> /dev/null
done

# estimate the global 3D-SFS

$ANGSD/misc/realSFS Test/neutral.1.saf.idx Test/neutral.2.saf.idx Test/neutral.3.saf.idx -P 2 > Test/neutral.3d.sfs

## 2) simulate small windows with selection and redo the sfs estimation, appending to a file

# 4*12500*1.5e-8*2e5=7500
THETA2=150
RHO2=150
N_SITES2=200000


> Test/selcoeffs.txt
> Test/selection.3d.sfs

for SC in `seq 0 25 2500`;
do

	echo $SC
	echo $SC >> Test/selcoeffs.txt

	> Test/sel.txt
	$MSMS -N 12500 -ms $N_SAMS $N_REPS -t $THETA2 -r $RHO2 $N_SITES2 -I 3 $N_SAM $N_SAM $N_SAM -n 1 8 -n 2 8 -n 3 8 -ma x 1.6 0.4 1.6 x 0 0.4 0 x -en 0.004 1 1.92 -en 0.007 2 0.616 -en 0.008 3 0.616 -ej 0.04 3 2 -ej 0.7 2 1 -en 0.34 1 1 -seed 12345 -SI 0.035 3 0.00 0.00 0.01 -Sc 0 1 0 0 0 -Sc 0 2 0 0 0 -Sc 0 3 $((SC * 2)) $SC 0 > Test/sel.txt

	$ANGSD/misc/msToGlf -in Test/sel.txt -out Test/sel -regLen 0 -singleOut 1 -depth $DEPTH -err $ERR_RATE -pileup 0 -Nsites 1 2> /dev/null

	$ANGSD/misc/splitgl Test/sel.glf.gz $N_INDS 1 10 > Test/sel.1.glf.gz 2> /dev/null
	$ANGSD/misc/splitgl Test/sel.glf.gz $N_INDS 11 20 > Test/sel.2.glf.gz 2> /dev/null
	$ANGSD/misc/splitgl Test/sel.glf.gz $N_INDS 21 30 > Test/sel.3.glf.gz 2> /dev/null

	for i in `seq 1 3`;
	do
        	$ANGSD/angsd -glf Test/sel.$i.glf.gz -fai Test/reference.fa.fai -nInd $N_IND -doSaf 1 -P 2 -isSim 1 -out Test/sel.$i 2> /dev/null
	done

	$ANGSD/misc/realSFS Test/sel.1.saf.idx Test/sel.2.saf.idx Test/sel.3.saf.idx -P 2 >> Test/selection.3d.sfs 2> /dev/null

	trash-put Test/sel.*
	
done

## 3) calculate CLRT

CLRT=/home/mfumagal/Documents/Students/Leo_Diaz/pop3D/pop3Dclrt

$CLRT Test/neutral.3d.sfs Test/selection.3d.sfs Test/clrt.txt

















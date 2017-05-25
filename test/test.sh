
# test whetherCLRT correlates with selection and with PBS signal

# calculate genome-wide SFS (no selection)
# simulate selection ina short region and record CLRT and PBS

# programs

SAMTOOLS=~/Software/samtools/samtools
ANGSD=~/Software/angsd
MSMS=~/Software/msms/bin/msms
CLRT=/home/mfumagal/Documents/Students/Leo_Diaz/pop3D/bin/pop3Dclrt

# variables

N_SAM=20
N_SAMS=$((N_SAM * 3))
N_IND=$((N_SAM / 2))
N_INDS=$((N_SAMS / 2))
N_REPS=1
# 4*10000*1.5e-8*1e7=6000
THETA=6000
RHO=6000
N_SITES=10000000
ERR_RATE=0.0075

# reference sequence

Rscript -e 'cat(">reference\n",paste(rep("A",1e7),sep="", collapse=""),"\n",sep="")' > Test/reference.fa 
$SAMTOOLS faidx Test/reference.fa

echo simulating genome-wide data
for DEPTH in 2 10 20;
do

	if [ ! -f Test/neutral.$DEPTH.txt ]
	then

		echo $DEPTH
		# genome-wide with no selection
		> Test/neutral.$DEPTH.txt
		#$MSMS -N 12500 -ms $N_SAMS $N_REPS -t $THETA -r $RHO $N_SITES -I 3 $N_SAM $N_SAM $N_SAM -n 1 8 -n 2 8 -n 3 8 -ma x 1.6 0.4 1.6 x 0 0.4 0 x -en 0.004 1 1.92 -en 0.007 2 0.616 -en 0.008 3 0.616 -ej 0.04 3 2 -ej 0.7 2 1 -en 0.34 1 1 -seed 12345 > Test/neutral.txt
		# msms model
		$MSMS -N 10000 -ms $N_SAMS 1 -I 4 $N_SAM $N_SAM $N_SAM 0 0 -t $THETA -r $RHO $N_SITES -es 0 3 0.5 -ej 0 4 5 -g 2 10 -g 3 100 -g 5 200 -n 2 0.9 -n 3 2 -n 5 11 -m 1 3 5 -m 3 1 5 -m 1 2 2 -m 2 1 2 -ej 0.04 5 3 -ej 0.05 3 2 -en 0.05 2 5 -em 0.05 1 2 12 -em 0.05 2 1 12 -ej 0.15 2 1 -en 0.2 1 0.5 > Test/neutral.$DEPTH.txt

		$ANGSD/misc/msToGlf -in Test/neutral.$DEPTH.txt -out Test/neutral.$DEPTH -regLen 0 -singleOut 1 -depth $DEPTH -err $ERR_RATE -pileup 0 -Nsites 1 2> /dev/null
		# or use -regLen 0 for only SNPs, faster, otherwise use $N_SITES
	
		$ANGSD/misc/splitgl Test/neutral.$DEPTH.glf.gz $N_INDS 1 10 > Test/neutral.$DEPTH.1.glf.gz 2> /dev/null
		$ANGSD/misc/splitgl Test/neutral.$DEPTH.glf.gz $N_INDS 11 20 > Test/neutral.$DEPTH.2.glf.gz 2> /dev/null
		$ANGSD/misc/splitgl Test/neutral.$DEPTH.glf.gz $N_INDS 21 30 > Test/neutral.$DEPTH.3.glf.gz 2> /dev/null

		for i in `seq 1 3`;
		do
			$ANGSD/angsd -glf Test/neutral.$DEPTH.$i.glf.gz -fai Test/reference.fa.fai -nInd $N_IND -doSaf 1 -P 2 -isSim 1 -out Test/neutral.$DEPTH.$i 2> /dev/null
		done

		$ANGSD/misc/realSFS Test/neutral.$DEPTH.1.saf.idx Test/neutral.$DEPTH.2.saf.idx Test/neutral.$DEPTH.3.saf.idx -P 2 > Test/neutral.$DEPTH.3d.sfs 2> /dev/null
	fi
done

## 2) simulate small windows with selection and redo the sfs estimation, appending to a file

# 4*10000*1.5e-8*5e4=30
THETA2=30
RHO2=30
N_SITES2=50000

echo \##ST SC MD PBS1 PBS2 PBS3 CLRT > results.txt

echo simulating windows of selection

for ST in 0.1 0.25 0.5; 
do
	for SC in `seq 0 5 2000`;
	do

		> Test/sim.txt
#		$MSMS -N 12500 -ms $N_SAMS $N_REPS -t $THETA2 -r $RHO2 $N_SITES2 -I 3 $N_SAM $N_SAM $N_SAM -n 1 8 -n 2 8 -n 3 8 -ma x 1.6 0.4 1.6 x 0 0.4 0 x -en 0.004 1 1.92 -en 0.007 2 0.616 -en 0.008 3 0.616 -ej 0.04 3 2 -ej 0.7 2 1 -en 0.34 1 1 -SI 0.03 3 0 0 0 -Sp 0.5 -Sc 0 3 $((SC * 2)) $SC 0 > Test/sel.txt

		$MSMS -N 10000 -ms $N_SAMS 1 -I 4 $N_SAM $N_SAM $N_SAM 0 0 -t $THETA2 -r $RHO2 $N_SITES2 -es 0 3 0.5 -ej 0 4 5 -g 2 10 -g 3 100 -g 5 200 -n 2 0.9 -n 3 2 -n 5 11 -m 1 3 5 -m 3 1 5 -m 1 2 2 -m 2 1 2 -ej 0.04 5 3 -ej 0.05 3 2 -en 0.05 2 5 -em 0.05 1 2 12 -em 0.05 2 1 12 -ej 0.15 2 1 -en 0.2 1 0.5 -SI $ST 5 0 0 0 0 0 -Sc 0 3 $((SC * 2)) $SC 0 -Smu 0.1 > Test/sim.txt

		for MD in 2 10 20;
		do

			$ANGSD/misc/msToGlf -in Test/sim.txt -out Test/sel -regLen 0 -singleOut 1 -depth $MD -err $ERR_RATE -pileup 0 -Nsites 1 2> /dev/null

			$ANGSD/misc/splitgl Test/sel.glf.gz $N_INDS 1 10 > Test/sel.1.glf.gz 2> /dev/null
			$ANGSD/misc/splitgl Test/sel.glf.gz $N_INDS 11 20 > Test/sel.2.glf.gz 2> /dev/null
			$ANGSD/misc/splitgl Test/sel.glf.gz $N_INDS 21 30 > Test/sel.3.glf.gz 2> /dev/null

			for i in `seq 1 3`;
			do
        			$ANGSD/angsd -glf Test/sel.$i.glf.gz -fai Test/reference.fa.fai -nInd $N_IND -doSaf 1 -P 2 -isSim 1 -out Test/sel.$i 2> /dev/null
				$ANGSD/misc/realSFS Test/sel.$i.saf.idx > Test/selection.$i.sfs 2> /dev/null
			done

			# 3D-SFS
			$ANGSD/misc/realSFS Test/sel.1.saf.idx Test/sel.2.saf.idx Test/sel.3.saf.idx -P 2 > Test/selection.3d.sfs 2> /dev/null

			# all 2D-SFS
			$ANGSD/misc/realSFS Test/sel.1.saf.idx Test/sel.2.saf.idx -P 2 > Test/selection.12d.sfs 2> /dev/null
			$ANGSD/misc/realSFS Test/sel.1.saf.idx Test/sel.3.saf.idx -P 2 > Test/selection.13d.sfs 2> /dev/null
			$ANGSD/misc/realSFS Test/sel.2.saf.idx Test/sel.3.saf.idx -P 2 > Test/selection.23d.sfs 2> /dev/null

			# pbs
			$ANGSD/misc/realSFS fst index Test/sel.1.saf.idx Test/sel.2.saf.idx Test/sel.3.saf.idx -whichFst 1 -sfs Test/selection.12d.sfs -sfs Test/selection.13d.sfs -sfs Test/selection.23d.sfs -fstout Test/sel 2> /dev/null

			> tmp
			$ANGSD/misc/realSFS fst stats2 Test/sel.fst.idx -win $N_SITES2 -step 1 > tmp 2> /dev/null 
			PBS=`cat tmp | tail -n 1 | cut -f 8-10`
			
			# clrt
			> tmp
			$CLRT Test/neutral.$MD.3d.sfs Test/selection.3d.sfs tmp
			CLR=`cat tmp`

			echo $ST $SC $MD $PBS $CLR >> results.txt
			echo $ST $SC $MD $PBS $CLR

			\rm tmp
			\rm Test/sel*

		done
		\rm Test/sim.txt
	done
done



#sc <- as.numeric(readLines("Test/selcoeffs.txt"))
#pbs <- read.table("Test/pbs.txt")
#clrt <- read.table("Test/clrt.txt")
#res <- cbind(sc, pbs, clrt)
#colnames(res) <- c("SC","PBS1","PBS2","PBS3","CLRT")













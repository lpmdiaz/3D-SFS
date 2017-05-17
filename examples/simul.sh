
# simulate 10 Mbp

# programs

SAMTOOLS=~/Software/samtools/samtools
#MS=~/Software/msdir/ms
ANGSD=~/Software/angsd
MSMS=~/Software/msms/bin/msms

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
ERR_RATE=0.005
DEPTH=10

# reference sequence

Rscript -e 'cat(">reference\n",paste(rep("A",1e7),sep="", collapse=""),"\n",sep="")' > Data/reference.fa 
$SAMTOOLS faidx Data/reference.fa

# simulate genomes with selection in third population

> Data/msms.txt
$MSMS -N 10000 -ms $N_SAMS $N_REPS -t $THETA -r $RHO $N_SITES -I 3 $N_SAM $N_SAM $N_SAM -en 0.04945 3 0.025 -ej 0.04950 3 2 -en 0.05220 2 0.025 -ej 0.05225 2 1 -SI 0.04 3 0 0 0 -Sc 0 3 400 200 0 -Sp 0.5 -seed 1 >> Data/msms.txt

# simulate sequencing data

$ANGSD/misc/msToGlf -in Data/msms.txt -out Data/ms -regLen $N_SITES -singleOut 1 -depth $DEPTH -err $ERR_RATE -pileup 0 -Nsites 1
# or use -regLen 0 for only SNPs, faster

# split into 3 populations

$ANGSD/misc/splitgl Data/ms.glf.gz $N_INDS 1 10 > Data/ms.1.glf.gz
$ANGSD/misc/splitgl Data/ms.glf.gz $N_INDS 11 20 > Data/ms.2.glf.gz
$ANGSD/misc/splitgl Data/ms.glf.gz $N_INDS 21 30 > Data/ms.3.glf.gz

# calculate SAF file for each population

for i in `seq 1 3`;
do
	echo $i
	$ANGSD/angsd -glf Data/ms.$i.glf.gz -fai Data/reference.fa.fai -nInd $N_IND -doSaf 1 -P 2 -isSim 1 -out Data/ms.$i 2> /dev/null
done

# estimate the global 3D-SFS

$ANGSD/misc/realSFS Data/ms.1.saf.idfs -P 2 > Results/ms.12d.sfs

$ANGSD/misc/realSFS Data/ms.1.saf.idx Data/ms.2.saf.idx Data/ms.3.saf.idx -P 2 > Results/ms.3d.sfs

# estimate local 3D-SFS

> Results/ms.3d.windows.sfs
> Results/windows.txt
for i in `seq 1 10000 9900001`;
do
	j=$((i+99999))
	echo $i $j >> Results/windows.txt
	echo $i $j

	$ANGSD/misc/realSFS Data/ms.1.saf.idx Data/ms.2.saf.idx Data/ms.3.saf.idx -P 2 -sfs Results/ms.3d.sfs -r reference:$i-$j 2> log >> Results/ms.3d.windows.sfs

done



















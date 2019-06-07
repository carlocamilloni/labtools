# this tool calculates the native contacts (and other things)
# 9 should be sidechain-H (double check case by case)
#echo -e "9\n" | gmx_mpi mdmat -f traj-prot.xtc -s run.tpr -cdist 0.6 -natfrac 0.5 <--- the natfrac is the most critical parameter (at least 5-10 native contacts per aa)
#if it is too low one could select as native contacts interactions that can be broken too easily, if it is too high there could be zero atoms selected...
#in case one could also increase the cdist (then R_0 should be move also (R_0 is always 0.05 larger)


file="./used-phi.dat" 
k=2	# first useful line in file (used-phi.dat)
phicol=10 # column containing the value of phiv in file

cdist=0.60	# cdist used in gmx_mpi mdmat
DELTA=0.05	# R_0=cdist+DELTA
KAPPA=10.	# start with small kappa. It should later be increased

# parameters for the switching function. Default is N=6/M=12.
NN=6
MM=12

SCALE=y	# rescale or not computed phi-values in the range 0-1

# PRINT HEADER; optional 
echo -e "MOLINFO STRUCTURE=pr.pdb\nWHOLEMOLECULES ENTITY0=1-1571\n"

#R_0 is DELTA larger than cdist
R_0=`echo $cdist $DELTA | awk '{print $1+$2}'`
#here D_MAX is twice R_0 and NL_CUTOFF is D_MAX+0.1 to mimic the verlet list
D_MAX=`echo $R_0 | awk '{print $1*2}'`
NL_CUTOFF=`echo $D_MAX | awk '{print $1+0.1}'`

string1=""
string2=""
stringPHI=""

for i in `cat $file | grep -v \# | awk '{print $1}'`; do

	echo -e "COORDINATION ...\nPAIR NOPBC\nLABEL=allpv-$i\nSWITCH={RATIONAL R_0=$R_0 D_MAX=$D_MAX NN=$NN MM=$MM} NLIST NL_CUTOFF=$NL_CUTOFF NL_STRIDE=20"; 
	# ATT! This works for SYMMETRIC nat-all.ndx 
	awk 'BEGIN {c=1} 
		{if(($1+1)=='$i') {a[c]=$2+1; b[c]=$4+1; c++;}}
	       	END {printf("GROUPA=");for(i=1;i<c;i++) {printf("%i,",a[i])} print ""; printf("GROUPB=");for(i=1;i<c;i++) {printf("%i,",b[i])} print ""}' nat-all.ndx;
	echo -e "... COORDINATION\n";

	# ATT! This works for SYMMETRIC nat-all.ndx 
	c=`awk 'BEGIN {c=1} 
              	{if(($1+1)=='$i') {c++;}} 
          	END {print c-1}' nat-all.ndx`;

	phi=`head -n $k $file | tail -1 | awk -v phicol=$phicol '{print $phicol}'`

	if [ $SCALE == "y" ]; then 
		coeff=`echo $c | awk '{if($1>0) {print 1/$1} else {print $1}}'`
		echo -e "COMBINE  LABEL=pv-$i  ARG=allpv-$i COEFFICIENTS=$coeff PERIODIC=NO"
		echo -e "rpv-$i: RESTRAINT ARG=pv-$i SLOPE=0 KAPPA=$KAPPA AT=$phi\n"
		string1=`echo ${string1}pv-${i},`  #opt to print stat
		stringPHI=`echo ${stringPHI}${phi},`  #opt to print stat
	else
		res=`echo "$phi * $c" | bc -l`
		echo -e "rpv-$i: RESTRAINT ARG=allpv-$i SLOPE=0 KAPPA=$KAPPA AT=$res\n"
		string1=`echo ${string1}allpv-${i},` #opt to print stat
		stringPHI=`echo ${stringPHI}${res},` #opt to print stat
	fi

	string2=`echo ${string2}rpv-${i}.bias,`  #opt to print stat
	k=$(($k+1)) 
	
done 

# optional, print statistics
echo -e "stat: STATS ARG=$string1 PARAMETERS=$stringPHI\nPRINT ARG=stat.* FILE=STAT STRIDE=500\nPRINT ARG=$string1 FILE=COORDINATION STRIDE=500\nPRINT ARG=$string2 FILE=RESTRAINTS STRIDE=500"

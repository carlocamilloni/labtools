# this tool calculates the native contacts (and other things)
# 9 should be sidechain-H (double check case by case)
#echo -e "9\n" | gmx_mpi mdmat -f traj-prot.xtc -s run.tpr -cdist 0.6 -natfrac 0.5 <--- the natfrac is the most critical parameter
#if it is too low one could select as native contacts interactions that can be broken too easily, if it is too high there could be zero atoms selected...
#in case one could also increase the cdist (then R_0 should be move also (R_0 is always 0.05 larger)
k=2
#this is the list of residues
#read the list of residue from column one of the table
#for i in 4 8 9 10 11 15 16 17 25 28 32 34 38 57 60 64 76 77 86 89 99; do 
for i in `cat used-phi.dat | grep -v \# | awk '{print $1}'`; do 
#here D_MAX is twice R_0 and NL_CUTOFF is D_MAX+0.1 to mimic the verlet list
echo -e "COORDINATION ...\nPAIR\nLABEL=pv-$i\nSWITCH={RATIONAL R_0=0.65 D_MAX=1.3} NLIST NL_CUTOFF=1.4 NL_STRIDE=20"; 
awk 'BEGIN {c=1} 
           {if(($1+1)=='$i') {a[c]=$2+1; b[c]=$4+1; c++;}} 
       END {printf("GROUPA=");for(i=1;i<c;i++) {printf("%i,",a[i])} print ""; printf("GROUPB=");for(i=1;i<c;i++) {printf("%i,",b[i])} print ""}' nat-all.ndx;
echo -e "... COORDINATION\n";
c=`awk 'BEGIN {c=1} 
              {if(($1+1)=='$i') {c++;}} 
          END {print c-1}' nat-all.ndx`;
phi=`head -n $k used-phi.dat | tail -1 | awk '{print $10}'`
res=`echo "$phi * $c" | bc -l`
#kappa should later be increased to 100 at least
echo -e "rpv-$i: RESTRAINT ARG=pv-$i SLOPE=0 KAPPA=10. AT=$res\n"
k=$(($k+1)) 
done > input


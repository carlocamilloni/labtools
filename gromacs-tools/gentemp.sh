#./gentemp.sh Nrepl T0 T1
#geometric distribution
#et=$2;
#echo $et; 
#for i in `jot - 1 $1`; do   et=`echo "scale=1 ; $et*$3/$2" | bc`; echo $et; done

#parrinello distribution
et=$2;
const=`echo "scale=20; (-1/$3+1/$2)*sqrt($2)" | bc`;
#echo $const;
echo $et  | awk '{printf("%5.1lf\n", $1)}';
for i in `jot - 1 $(($1-1))`; do et=`echo "scale=20; 1/((1/$et)-($const/sqrt($et)))" | bc`; echo $et | awk '{printf("%5.1lf\n", $1)}'; done 

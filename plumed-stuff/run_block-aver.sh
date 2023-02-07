infile=$1	# input file, it must contain at least 1 CV in field $field and the last column is a weight
field=$2
NR=$3		# number of replica
temp=$4         # temperature in energy units
nbin=$5
min=$6
max=$7


scriptHOME=`pwd`

if [ ! $NR ]; then NR=1; fi
if [ ! $temp ]; then temp=2.49; fi
if [ ! $nbin ]; then nbin=41; fi

echo -e "Considering $NR replica\n"


if [ -f "err.cv$field.blocks" ]; then mv err.cv$field.blocks err.cv$field.blocks.bck; fi
if [ -f "errweight.cv$field.blocks" ]; then mv errweight.cv$field.blocks errweight.cv$field.blocks.bck; fi
if [ -f "aver.cv${field}.blocks" ]; then mv aver.cv${field}.blocks aver.cv${field}.blocks.bck ; fi

awk -v field=$field '{if($1!="#!") print $field, $NF}' $infile > cv1w
maxl=`wc -l cv1w | awk '{printf("%i\n", $1)}'`

if [ ! $min ]; then
max=`sort -k1 -g cv1w | tail -1 | awk '{print $1}'`
min=`sort -k1 -g -r cv1w | tail -1 | awk '{print $1}'`
fi

echo "fes plot from " $min " to " $max " with " $nbin " bins and " $temp " energy units " 

if [ $NR -lt 3 ]; then mininterval=2; fi
if [ $NR -gt 2 ]; then mininterval=0; fi

for ((interval=30;interval>$mininterval;interval--)); do
	i=`echo $interval | awk '{printf("%i\n", '$maxl'/($1*'$NR'))}'`
	echo -e "\nEach of the $NR replica is divided in $interval blocks, with block-length $i"
	python ${scriptHOME}/do_block_fes.py cv1w 1 $min $max $nbin $temp $i; 
	mv fes.$i.dat fes.cv$field.$i.dat;
        python  ${scriptHOME}/do_block_aver.py cv1w $i >> aver.cv${field}.blocks
	# error
	a=`awk '{tot+=$3}END{print tot/NR}' fes.cv$field.$i.dat`;
	#aa=`awk '{tot+=$4}END{print tot/NR}' fes.cv$field.$i.dat`;
       	echo $i $a  >> err.cv$field.blocks
	b=`awk -v kt=$temp '{tot+=$3*exp(-$2/kt);n+=exp(-$2/kt)}END{print tot/n}' fes.cv$field.$i.dat`; 
	#bb=`awk -v kt=$temp '{tot+=$4*exp(-$2/kt);n+=exp(-$2/kt)}END{print tot/n}' fes.cv$field.$i.dat`; 
	echo $i $b  >> errweight.cv$field.blocks
	
done
mv cv1w cv$field.dat;

infile=$1	# input file, it must contain at least 1 CV in field $field and the last column is a weight
field=$2
NR=$3		# number of replica
temp=$4 # temperature in energy units

if [ ! $NR ]; then NR=1; fi
if [ ! $temp ]; then temp=2.49; fi

echo -e "Considering $NR replica\n"


if [ -f "err.cv$field.blocks" ]; then mv err.cv$field.blocks err.cv$field.blocks.bck; fi
if [ -f "errweight.cv$field.blocks" ]; then mv errweight.cv$field.blocks errweight.cv$field.blocks.bck; fi


awk -v field=$field '{if($1!="#!") print $field, $NF}' $infile > cv1w
maxl=`wc -l cv1w | awk '{printf("%i\n", $1)}'`

max_tmp=`awk 'BEGIN {max = 0} {if ($1>max) max=$1} END {print max}' cv1w`
min=`awk -v min=$max_tmp '{if ($1 < min) min=$1} END {print min}' cv1w`
max=`awk -v max=$min '{if ($1 > max) max=$1} END {print max}' cv1w`

echo "fes plot from " $min " to " $max " with 51 bins and " $temp " energy units " 


for ((interval=20;interval>0;interval--)); do
	i=`echo $interval | awk '{printf("%i\n", '$maxl'/($1*'$NR'))}'`
	echo -e "\nEach of the $NR replica is divided in $interval blocks, with block-length $i"
	python do_block_fes.py cv1w 1 $min $max 51 $temp $i; 
	mv fes.$i.dat fes.cv$field.$i.dat;

	# error
	a=`awk '{tot+=$3}END{print tot/NR}' fes.cv$field.$i.dat`;
       	echo $i $a >> err.cv$field.blocks
	b=`awk -v kt=$temp '{tot+=$3*exp(-$2/kt);n+=exp(-$2/kt)}END{print tot/n}' fes.cv$field.$i.dat`; 
	echo $i $b >> errweight.cv$field.blocks
	
done
mv cv1w cv$field.dat;


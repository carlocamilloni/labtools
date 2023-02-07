infile=$1	# input file, it must contain at least 1 CV in field $field and the last column is a weight	# es: rmsd-w.dat or rmsd-w_SORTED.dat
field=$2
NR=$3		# number of replica
min=$4
max=$5

scriptHOME=`pwd`


echo -e "Considering $NR replica\n"

if [ -f "pop_${min}_${max}.blocks" ]; then mv pop_${min}_${max}.blocks pop_${min}_${max}.blocks.bck ; fi

more ${infile} | awk -v f=${field} '{if ($f<'${max}' && $f>'${min}') {print 1, $NF} else {print 0, $NF}}' > cv1w
maxl=`wc -l cv1w | awk '{printf("%i\n", $1)}'`

echo "Computing population of cv $field between $min and $max"

if [ $NR -lt 3 ]; then mininterval=2; fi
if [ $NR -gt 2 ]; then mininterval=0; fi

for ((interval=30;interval>$mininterval;interval--)); do
	i=`echo $interval | awk '{printf("%i\n", '$maxl'/($1*'$NR'))}'`
	echo -e "\nEach of the $NR replica is divided in $interval blocks, with block-length $i"
	python  ${scriptHOME}/do_block_aver.py cv1w $i >> pop_${min}_${max}.blocks
done

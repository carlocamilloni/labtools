#takes in input a file with n columns for N CV and the last column is a weight
temp=2.48
awk '{if($1!="#!") print $2, $7}' cv-weights.dat > cv1w
bl=`wc -l cv1w | awk '{printf("%i\n", $1/2)}'`
st=`wc -l cv1w | awk '{printf("%i\n", $1/2/100)}'`
max=`sort -k1 -n cv1w | tail -1 | awk '{print $1}'`
min=`sort -k1 -n -r cv1w | tail -1 | awk '{print $1}'`
echo "max block size " $bl
echo "block inscreased by " $st
echo "fes plot from " $min " to " $max " with 51 bins and " $temp " energy units " 
for i in `seq $st $st $bl`; do python3 do_block_fes.py cv1w 1 $min $max 51 $temp $i; mv fes.$i.dat fes.cv1w.$i.dat; done
for i in `seq $st $st $bl`; do a=`awk '{tot+=$3}END{print tot/NR}' fes.cv1w.$i.dat`; echo $i $a; done > err.cv1w.blocks

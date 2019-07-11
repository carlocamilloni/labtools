#takes in input a file with n columns for N CV and the last column is a weight
echo "processing file: " $1
bl=`wc -l $1 | awk '{printf("%i\n", $1/4)}'`
st=`wc -l $1 | awk '{printf("%i\n", $1/2/100)}'`
max=`sort -k1 -n $1 | tail -1 | awk '{print $1}'`
min=`sort -k1 -n -r $1 | tail -1 | awk '{print $1}'`
kt=$2
echo "max block size " $bl
echo "block inscreased by " $st
echo "fes plot from " $min " to " $max " with 51 bins and " $kt " energy units " 
for i in `seq 1 $st $bl`; do python3 do_block_fes.py $1 1 $min $max 51 $kt $i; done
for i in `seq 1 $st $bl`; do a=`awk '{tot+=exp(-$2/'$kt')*$3;norm+=exp(-$2/'$kt')}END{print tot/norm}' fes.$1.$i.dat`; echo $i $a; done > err.$1.blocks

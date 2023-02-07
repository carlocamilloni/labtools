import math
import sys
import numpy as np

# read FILE with CVs and weights
FILENAME_ = sys.argv[1]
# block size 
BSIZE_ = int(sys.argv[2])


# read file and store lists 
cv_list=[]; w_list=[]
for lines in open(FILENAME_, "r").readlines():
    riga = lines.strip().split()
    # check format
    if(len(riga)!=1 and len(riga)!=2):
      print (FILENAME_,"is in the wrong format!")
      exit()
    # read CVs
    cv=float(riga[0])
    # read weight, if present
    if(len(riga)==2):
      w = float(riga[1])
    else: w = 1.0
    # store into lists
    cv_list.append(cv)
    w_list.append(w) 

# total number of data points
ndata = len(cv_list)
# number of blocks
nblock = int(ndata/BSIZE_)

ww_blocco = [];
cv_blocco = [];
ww=0; ww_2=0;
# cycle on blocks
for iblock in range(0, nblock):
    ww_tmp=0; cv_tmp = 0;
    # define range in CV
    i0 = iblock * BSIZE_ 
    i1 = i0 + BSIZE_
    for i in range(i0, i1):
        ww += w_list[i]
        ww_tmp += w_list[i]
        cv_tmp += cv_list[i] * w_list[i]
    #print(iblock,ww_ok_tmp/ww_tmp,ww_tmp)
    ww_blocco.append(ww_tmp)
    cv_blocco.append(cv_tmp)
    ww_2 += ww_tmp *ww_tmp

meff= ww*ww/ww_2
#print(np.sum(ww_blocco),meff,ww)

ave=0.;s2=0;err=0.;
for iblock in range(0, nblock):
    ave += (cv_blocco[iblock]/ww_blocco[iblock])*ww_blocco[iblock]/np.sum(ww_blocco)
for iblock in range(0, nblock):
    s2  += np.power(cv_blocco[iblock]/ww_blocco[iblock]-ave,2) *ww_blocco[iblock]/np.sum(ww_blocco) * meff / ( meff - 1.0 ) 
    err = math.sqrt( s2 / meff)
print("%-8d %3.3f %3.3f" %(BSIZE_,ave,err) )

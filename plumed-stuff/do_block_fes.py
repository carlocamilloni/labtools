import math
import sys
import numpy as np

# read FILE with CVs and weights
FILENAME_ = sys.argv[1]
# number of CVs for FES
NCV_ = int(sys.argv[2])
# read minimum, maximum and number of bins for FES grid
gmin = []; gmax = []; nbin = []
for i in range(0, NCV_):
    i0 = 3*i + 3 
    gmin.append(float(sys.argv[i0]))
    gmax.append(float(sys.argv[i0+1]))
    nbin.append(int(sys.argv[i0+2]))
# read KBT_
KBT_ = float(sys.argv[3*NCV_+3])
# block size 
BSIZE_ = int(sys.argv[-1])

def get_indexes_from_index(index, nbin):
    indexes = []
    # get first index
    indexes.append(index%nbin[0])
    # loop
    kk = index
    for i in range(1, len(nbin)-1):
        kk = ( kk - indexes[i-1] ) / nbin[i-1]
        indexes.append(kk%nbin[i])
    if(len(nbin)>=2):
      indexes.append( ( kk - indexes[len(nbin)-2] ) / nbin[len(nbin) -2] )
    return indexes 

def get_indexes_from_cvs(cvs, gmin, dx):
    keys = []
    for i in range(0, len(cvs)):
        keys.append(int( round( ( cvs[i] - gmin[i] ) / dx[i] ) ))
    return tuple(keys)

def get_points(key, gmin, dx):
    xs = []
    for i in range(0, len(key)):
        xs.append(gmin[i] + float(key[i]) * dx[i])
    return xs

# define bin size
dx = []
for i in range(0, NCV_):
    dx.append( (gmax[i]-gmin[i])/float(nbin[i]-1) )

# total numbers of bins
nbins = 1
for i in range(0, len(nbin)): nbins *= nbin[i]

# read file and store lists 
cv_list=[]; w_list=[]
for lines in open(FILENAME_, "r").readlines():
    riga = lines.strip().split()
    # check format
    if(len(riga)!=NCV_ and len(riga)!=NCV_+1):
      print (FILENAME_,"is in the wrong format!")
      exit()
    # read CVs
    cvs = []
    for i in range(0, NCV_): cvs.append(float(riga[i]))
    # get indexes
    key = get_indexes_from_cvs(cvs, gmin, dx)
    # read weight, if present
    if(len(riga)==NCV_+1):
      w = float(riga[NCV_])
    else: w = 1.0
    # store into lists
    cv_list.append(key)
    w_list.append(w) 

# total number of data points
ndata = len(cv_list)
# number of blocks
nblock = int(ndata/BSIZE_)

# prepare histo dictionaries
histo_ave_block = []; histo_ave = {} ;  
ww_2=0; ww_blocco = [];
# cycle on blocks
for iblock in range(0, nblock):
    ww_tmp=0
    # define range in CV
    i0 = iblock * BSIZE_ 
    i1 = i0 + BSIZE_
    # build histo
    histo = {}
    for i in range(i0, i1):
        if cv_list[i] in histo: histo[cv_list[i]] += w_list[i]
        else:                   histo[cv_list[i]]  = w_list[i] 
        ww_tmp += w_list[i]
    ww_blocco.append(ww_tmp)
    histo_ave_block.append({})
    for i in range(0,ndata): histo_ave_block[iblock][cv_list[i]]  = 0.
    # add to global histo dictionary
    for key in histo:
        histo_ave_block[iblock][key] += histo[key]
        if key in histo_ave: 
           histo_ave[key]   += histo[key]
        else:
           histo_ave[key]   = histo[key]
    ww_2 += ww_tmp *ww_tmp

meff= np.sum(ww_blocco)*np.sum(ww_blocco)/ww_2
max_histo=max(list(histo_ave.values()))
 
# print out fes and error 
log = open("fes."+str(BSIZE_)+".dat", "w")
# this is needed to add a blank line
xs_old = []
for i in range(0, nbins):
    # get the indexes in the multi-dimensional grid
    key = tuple(get_indexes_from_index(i, nbin))
    # get CV values for that grid point
    xs = get_points(key, gmin, dx)
    # add a blank line for gnuplot
    if(i == 0):
      xs_old = xs[:] 
    else:
      flag = 0
      for j in range(1,len(xs)):
          if(xs[j] != xs_old[j]):
            flag = 1
            xs_old = xs[:] 
      if (flag == 1): log.write("\n")
    # print value of CVs
    for x in xs:
        log.write("%12.6lf " % x)
    # calculate fes
    if key in histo_ave_block[0]:
       aveh = 0.; s2h=0.;
       # average and variance
       for iblock in range(0, nblock):
           aveh += histo_ave_block[iblock][key]/ww_blocco[iblock] * ww_blocco[iblock]/np.sum(ww_blocco)
       for iblock in range(0, nblock):
           s2h  += np.power(histo_ave_block[iblock][key]/ww_blocco[iblock] -aveh,2) *ww_blocco[iblock]/np.sum(ww_blocco) * meff / ( meff - 1.0 ) 
       # error
       errh = math.sqrt( s2h / meff)
       # free energy and error
       fes = -KBT_ * math.log(aveh) + KBT_ * math.log(max_histo / np.sum(ww_blocco))
       errf = KBT_ / aveh * errh
       # printout
       log.write("   %12.6lf %12.6lf  \n" % (fes, errf))
    else:
       log.write("       Infinity\n")
log.close()

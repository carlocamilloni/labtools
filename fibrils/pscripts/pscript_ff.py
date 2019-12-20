#! /usr/bin/python

import numpy as np
import pandas as pd
import prettytable as pt
import copy

#####################################################################################
#####################################################################################
#####################################################################################
#####################################################################################

#inputs:
#atoms
#bonds
#angles
#dihedrals


print ("Reading the [atoms] file")

atoms = pd.read_csv('atoms', sep="\s+", header=None)   # header=0 ci piace ma conta il ; come colonna.
                                                        # provare a toglierlo durante l'importazione dei dati e aggiungerlo poi
                                                        # al momento si toglie tutto e vengono definite le colonne da me
atoms["charge"] = ""                                    # addition of a charge empty column
atoms.columns = ["; nr", "type", "resnr", "residue", "atom", "cgnr", "charge"]

print ("Atoms file read and columns names set")

#changing the atom type column -> patoms column 5 + 3 

atoms["type"] = atoms["atom"].apply(str) + '_' + atoms["resnr"].apply(str)


print ("Atom type defined")
#####################################################################################
#####################################################################################
#####################################################################################
#####################################################################################

print ("Reading the [bonds], [angles] and [dihedrals] files for ffbonded.itp")

bonds = pd.read_csv('bonds', sep="\s+", header=None)    # stessa cosa di prima, bisogna togliere il nome delle colonne e reinserirle
bonds.columns = [";ai", "aj", "func", "r0", "kb"]       # in attesa di un metodo piu intelligente

angles = pd.read_csv('angles', sep="\s+", header=None)
angles.columns = [";ai", "aj", "ak", "func", "th0", "Ka"]

dihedrals = pd.read_csv('dihedrals', sep="\s+", header=None)
dihedrals.columns = [";ai", "aj", "ak", "al", "func", "phi0", "Kd", "mult"]
dihedrals = dihedrals.replace(np.nan, '', regex=True)   # ci sono dei NaN che se tolti vengono messi i numeri con int normali

print ("Bonds, angles and dihedrals files read and columns names set")

print ("Dictionary creation")


dict_atomtypes = atoms.set_index("; nr")["type"].to_dict() # associazione di ["type"] a ("nr"). Per ogni nr c'e un type 
                                                           # farei atom+resnr coso del percento 11
                                                           # contatore delle chains per cancellare atoms dal top e 
                                                           # per selezionare progressivamente i bonds e altro

print ("Atom types associated to atom numbers")
print ("Replacing atom numbers with atom types")

bonds[";ai"].replace(dict_atomtypes, inplace=True)
bonds["aj"].replace(dict_atomtypes, inplace=True)
bonds.to_string(index=False)
kb_notation = bonds["kb"].map(lambda x: '{:.9e}'.format(x))
r0_notation = bonds["r0"].map(lambda x: '{:.9e}'.format(x))
bonds = bonds.assign(kb=kb_notation)
bonds = bonds.assign(r0=r0_notation)

angles[";ai"].replace(dict_atomtypes, inplace=True)
angles["aj"].replace(dict_atomtypes, inplace=True)
angles["ak"].replace(dict_atomtypes, inplace=True)
angles.to_string(index=False)
th0_notation = angles["th0"].map(lambda x: '{:.9e}'.format(x))
ka_notation = angles["Ka"].map(lambda x: '{:.9e}'.format(x))
angles = angles.assign(th0=th0_notation)
angles = angles.assign(Ka=ka_notation)

dihedrals[";ai"].replace(dict_atomtypes, inplace=True)
dihedrals["aj"].replace(dict_atomtypes, inplace=True)
dihedrals["ak"].replace(dict_atomtypes, inplace=True)
dihedrals["al"].replace(dict_atomtypes, inplace=True)
dihedrals.to_string(index=False)
phi0_notation = dihedrals["phi0"].map(lambda x: '{:.9e}'.format(x))
kd_notation = dihedrals["Kd"].map(lambda x: '{:.9e}'.format(x))
dihedrals = dihedrals.assign(phi0=phi0_notation)
dihedrals = dihedrals.assign(Kd=kd_notation)
dihedrals["func"] = dihedrals["func"].replace(1, 9)

print ("Renaming columns title for [ bondedtypes ], [ angletypes ], [ dihedraltypes ]")


bonds.columns = ["; i", "j", "func", "b0", "kb"]   #nuovi nomi delle colonne per usare direttamente il file come FF
#bonds.align = '1'              # questi due li ho messi non ricordo perche ma a quanto pare non servono. 
#bonds.border = False
angles.columns = [";    i", "j", "k", "func", "th0", "Ka"]
dihedrals.columns = [";  i", "j", "k", "l", "func", "phi", "kd", "mult"]


print ("Creation of ffbonded.itp")

file = open("ffbonded.itp", "w")
file.write("[ bondtypes ]\n")
file.write(str(bonds.to_string(index=False)))
file.write("\n")
file.write("\n")
file.write("[ angletypes ]\n")
file.write(str(angles.to_string(index=False)))
file.write("\n")
file.write("\n")
file.write("[ dihedraltypes ]\n")
file.write(str(dihedrals.to_string(index=False)))
file.close()

print ("ffbonded.itp created") 

#print (bonds)
#print (angles)
#print (dihedrals)

#####################################################################################
#####################################################################################
#####################################################################################
#####################################################################################

print ("[ atomtypes ] of ffnonbonded")

atomtypes = pd.DataFrame(atoms, columns = ['type'])
atomtypes.columns = ["; type"]
atomtypes["mass"] = '1.0000'
atomtypes.insert(1, 'at.num', 1)
atomtypes["charge"] = '0.000000'
atomtypes["ptype"] = 'A'
atomtypes["sigma"] = '0.00000e+00'
atomtypes["epsilon"] = '5.96046e-09'


print ("From [pairs] to [ nonbonded_params ]")

pairs = pd.read_csv('pairs', sep="\s+", header=None)
pairs.columns = [";ai", "aj", "type", "A", "B"]

pairs[";ai"].replace(dict_atomtypes, inplace=True)
pairs["aj"].replace(dict_atomtypes, inplace=True)
pairs.to_string(index=False)
A_notation = pairs["A"].map(lambda x: '{:.9e}'.format(x))
B_notation = pairs["B"].map(lambda x: '{:.9e}'.format(x))
pairs = pairs.assign(A=A_notation)
pairs = pairs.assign(B=B_notation)
pairs.columns = [";ai", "aj", "type", "A", "B"]

print ("Creation of ffnonbonded.itp")

file = open("ffnonbonded.itp", "w")
file.write("[ atomtypes ]\n")
file.write(str(atomtypes.to_string(index=False)))
file.write("\n")
file.write("\n")
file.write("[ nonbond_params ]\n")
file.write(str(pairs.to_string(index=False)))
file.close()

print ("ffnonbonded created")
print ("All files ready! Charlie is happy!")

These are gromacs MDP files we use for simulations of proteins in water with
charmm/amber force-fields

1) the minimization step should be repeated till convergence is reach
2) position restraint should be run for longer in case of membrane proteins
3) lincs-order=6 and lincs-iter=2 are safer options when strong restraints are applied (e.g. from Metainference)

mts: files to be used with multiple-time step algorithm 

hmr: files to be used for hydrogen mass repartitoning 


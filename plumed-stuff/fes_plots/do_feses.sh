grep -v \# cv-weights.dat | awk '{print $5, $4, $7}'  > cv-tt-d.dat
python do_fes.py cv-tt-d.dat 2 -3.1415 3.1416 50 1 5 50 2.49 fes-tt-d.dat

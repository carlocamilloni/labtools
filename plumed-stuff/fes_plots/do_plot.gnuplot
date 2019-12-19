#set xrange [0:20]
#set yrange [0.7:1.5]
set zrange [0:20]
set xtics 2
set pm3d interpolate 0,0
set palette rgbformulae 33,13,10
set contour
unset clabel
set cntrparam levels incremental 0,2.5,20
unset clabel
set pm3d map
set xlabel "# Residues in Extended"
set ylabel "Rg (nm)"
splot 'fes-tt-d.dat' u 1:2:3 w l ls 7 palette notitle
set pm3d
set term pdfcairo  
set output "fes.pdf"
rep

#run it as gnuplot do_plot.gnuplot
unset colorbox
set size ratio 1
set mxtics 1
set mytics 1
set xtics 10 font "Times-Roman, 60"
set ytics 10 font "Times-Roman, 60"
set cbtics font "Times-Roman, 60"
set grid xtics ytics front ls 12 lc rgb "black" lw 2
set palette model RGB defined ( 0 'white', 1 'dark-blue' )
plot [1:106][1:106][0:1] 'compare-maps.dat' u ($1):($2):3:3 palette pt 5 ps 1 t''
set term pdfcairo enhanced color font "Times-Roman, 60" size 20,12
set output 'map2.pdf'
rep

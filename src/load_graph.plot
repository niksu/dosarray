# Load graphing in DoSarray
# Nik Sultana, February 2018, UPenn
#
# Use of this source code is governed by the Apache 2.0 license; see LICENSE

set terminal pdfcairo
set output 'load_graph.pdf'
reset
fontsize = 12
set boxwidth 0.9
set style fill solid 1.00 border 0
set style histogram errorbars gap 2 lw 1
set style data histograms
set xlabel 'time (s)'

# FIXME uncomment for CPU and memory
#set yrange [0:1]
# FIXME uncomment depending on input
#set ylabel 'load (CPU)'
#set ylabel '% mem used'
set ylabel 'network traffic (in packets)'

# FIXME hardcoded input file called 'data'.
# FIXME hardcoded machine names.
plot 'data' using 3:2:4:xtic(1) ti "dedos01" linecolor rgb "#555555", \
        '' using 6:5:7 ti "dedos02" lt 1 lc rgb "#777777", \
        '' using 9:8:10 ti "dedos03" lt 1 lc rgb "#999999", \
        '' using 12:11:13 ti "dedos04" lt 1 lc rgb "#BBBBBB", \
        '' using 15:14:16 ti "dedos05" lt 1 lc rgb "#DDDDDD", \
        '' using 18:17:19 ti "dedos06" lt 1 lc rgb "#FFFFFF", \
        '' using 21:20:22 ti "dedos07" lt 1 lc rgb "#EEEEEE", \
        '' using 24:23:25 ti "dedos08" lt 1 lc rgb "#AAAAAA"

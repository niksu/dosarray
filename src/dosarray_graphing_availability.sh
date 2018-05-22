#/bin/sh -e
# Graphing of availability results in DoSarray.
# Nik Sultana, February 2018, UPenn

# Use of this source code is governed by the Apache 2.0 license; see LICENSE
#
# $ DOSARRAY_NHIST_RESULT=1 python ../generate_availability_chart.py '../../exp4/sl_60total_start10_last20_apache_event/c*.log' > availability.data
# $ ../dosarray_graphing_availability.sh . '' 10 30

DATA_DIR=$1
TITLE=$2
ATTACK_STARTS_AT=$3
ATTACK_ENDS_AT=$4

printf "\
set terminal pdf \n\
set xlabel 'time (s)' rotate parallel # probe number, approx one probe each second. \n\
set ylabel 'availability (%%)' rotate parallel # percentage of measurement nodes to whom the target responded. \n\
 \n\
unset key \n\
 \n\
set arrow from ${ATTACK_STARTS_AT},0 to ${ATTACK_STARTS_AT},105 nohead lc rgb 'red' \n\
set arrow from ${ATTACK_ENDS_AT},0 to ${ATTACK_ENDS_AT},105 nohead lc rgb 'red' \n\
set ytics 0,10 \n\
set yrange [0:105] \n\
 \n\
set style data lines \n\
 \n\
set xtics 0,10 \n\
#set xrange [0:60] \n\
 \n\
set title '${TITLE}' \n\
set output '${DATA_DIR}/graph_availability.pdf' \n\
plot '${DATA_DIR}/availability.data' using 1:2 title 'availability' \n\
" | gnuplot

echo "Done"

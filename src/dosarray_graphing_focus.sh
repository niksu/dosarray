#/bin/sh -e
# Graphing of "focussed" availability results in DoSarray.
#  i.e., focussing on a particular probe (in time).
# Nik Sultana, February 2018, UPenn
#
# Use of this source code is governed by the Apache 2.0 license; see LICENSE
#
# $ DOSARRAY_HIST_FOCUS=10 python ../generate_availability_chart.py '../../exp4/sl_60total_start10_last20_apache_event/c*.log' > availability.data
# $ ../dosarray_graphing_focus.sh . '' 10 30
#
# FIXME input and output filenames are hardcoded

DATA_DIR=$1
TITLE=$2

PREFIX="\
set terminal pdf \n\
set xlabel 'latency (10e-4 s)' rotate parallel # latency \"class\", since latencies are quantised. \n\
set ylabel 'instances (%%)' rotate parallel # number of instances, whose latency of that probe falls in this latency class. \n\
"

SUFFIX="\n\
set yrange [0:100] \n\
set style data lines \n\
set title '${TITLE}' \n\
set output '${DATA_DIR}/focus_graph.pdf' \n\
plot '${DATA_DIR}/availability.data' using 2:3 smooth csplines title 'availability' \n\
"

MIDDLE=""

printf "${PREFIX} ${MIDDLE} ${SUFFIX}" | gnuplot

echo "Done"

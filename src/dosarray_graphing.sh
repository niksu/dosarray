#/bin/sh -e
# Graphing of latency results in DoSarray.
# Nik Sultana, January 2018, UPenn
#
# Use of this source code is governed by the Apache 2.0 license; see LICENSE
#
# FIXME input and output filenames are hardcoded
# FIXME instead of having a bunch of different graphing scripts, could centralise them here and have parameters to influence what graph output is needed

while getopts "i:o:t:m:u" opt; do
  case ${opt} in
    i )
      INPUT_FILE=$OPTARG
      ;;
    o )
      OUTPUT_FILE=$OPTARG
      ;;
    ? )
      echo "Usage: ./dosarray_configure_network -i <input-file> -o <output-file>"
      exit 1
      ;;
  esac
done
shift $((OPTIND -1))

TITLE=$1
ATTACK_STARTS_AT=$2
ATTACK_ENDS_AT=$3

PREFIX="\
set terminal pdf \n\
set xlabel 'time (s)' rotate parallel # probe number, approx one probe each second. \n\
set ylabel 'latency (10e-4 s)' rotate parallel # latency \"class\", since latencies are quantised. \n\
set zlabel 'instances (%%)' rotate parallel # number of instances, whose latency of that probe falls in this latency class. \n\
 \n\
unset key \n\
 \n\
#set dgrid3d 50,30 hann \n\
#set dgrid3d 100,120 hann \n\
set dgrid3d 100,60 gauss \n\
 \n\
"

SUFFIX="\n\
set style data lines \n\
set contour base \n\
set hidden3d \n\
 \n\
set parametric \n\
set autoscale \n\
 \n\
# NOTE these should be fixed, to ensure consistency across presentation of different experiments \n\
#set ztics 0,10 \n\
#set ytics 0,0.1 \n\
#set zrange [0:100] \n\
#set yrange [0:1] \n\
#set cbrange [0:0.7] \n\
 \n\
#set xtics 0,5 \n\
#set xrange [0:60] \n\
 \n\
set title '${TITLE}' \n\
set output '${OUTPUT_FILE}' \n\
splot '${INPUT_FILE}' using 1:2:3 title 'availability' \n\
"

# The next two blocks are mututally exclusive, for better look.
if [ -z "${DOSARRAY_GRAPH_CONTOUR}" ]
then
MIDDLE="# Block B: coloured surface for the 3d plot \n\
set pm3d \n\
set palette \n\
unset colorbox \n\
"
else
MIDDLE="# Block A: the contour plot, showing the duration of the attack. \n\
set key box \n\
set view map \n\
unset surface \n\
unset pm3d \n\
set arrow from ${ATTACK_STARTS_AT},0 to ${ATTACK_STARTS_AT},10 nohead lc rgb 'red' \n\
set arrow from ${ATTACK_ENDS_AT},0 to ${ATTACK_ENDS_AT},10 nohead lc rgb 'red' \n\
"
fi

printf "${PREFIX} ${MIDDLE} ${SUFFIX}" | gnuplot

echo "Done"

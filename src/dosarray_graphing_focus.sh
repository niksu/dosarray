#/bin/sh -e
# Graphing of "focussed" availability results in DoSarray.
#  i.e., focussing on a particular probe (in time).
# Nik Sultana, February 2018, UPenn
#
# Use of this source code is governed by the Apache 2.0 license; see LICENSE
#
# $ export DOSARRAY_VERSION="0.3"
# $ DOSARRAY_NHIST_RESULT=1 python generate_availability_chart.py '../example_experiment/c*log' > availability_focus.data
# $ ../dosarray_graphing_focus.sh -i availability_focus.data -i focus_graph.pdf
#

while getopts "i:o" opt; do
  case ${opt} in
    i )
      INPUT_FILE=$OPTARG
      ;;
    o )
      OUTPUT_FILE=$OPTARG
      ;;
    ? )
      echo "Usage: ./dosarray_graphing_focus -i <input-file> -o <output-file>"
      exit 1
      ;;
  esac
done
shift $((OPTIND -1))

PREFIX="\
set terminal pdf \n\
set xlabel 'latency (10e-4 s)' rotate parallel # latency \"class\", since latencies are quantised. \n\
set ylabel 'instances (%%)' rotate parallel # number of instances, whose latency of that probe falls in this latency class. \n\
"

SUFFIX="\n\
set yrange [0:100] \n\
set style data lines \n\
set title '${TITLE}' \n\
set output '${OUTPUT_FILE}' \n\
plot '${INPUT_FILE}' using 1:2 smooth csplines title 'availability' \n\
"

MIDDLE=""

printf "${PREFIX} ${MIDDLE} ${SUFFIX}" | gnuplot

echo "Done"

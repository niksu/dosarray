#/bin/sh -e
# Graphing of "focussed" availability results in DoSarray.
#  i.e., focussing on a particular probe (in time).
# Nik Sultana, February 2018, UPenn
#
# Use of this source code is governed by the Apache 2.0 license; see LICENSE
#
# generate_availability_chart.py requires version to be set if this script is run separately
# $ export DOSARRAY_VERSION="0.3"
# $ DOSARRAY_HIST_FOCUS=10 python generate_availability_chart.py '../example_experiment/c*log' > availability_focus.data
# $ ./dosarray_graphing_focus.sh -i availability_focus.data -o focus_graph.pdf -t availability
#

while getopts "i:o:t:" opt; do
  case ${opt} in
    i )
      INPUT_FILE=$OPTARG
      ;;
    o )
      OUTPUT_FILE=$OPTARG
      ;;
    t )
      TITLE=$OPTARG
      ;;
    ? )
      echo "Usage: ./dosarray_graphing_focus -i <input-file> -o <output-file> -t <title>"
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
set output '${OUTPUT_FILE}' \n\
plot '${INPUT_FILE}' using 2:3 smooth csplines title '${TITLE}'\n\
"

MIDDLE=""

printf "${PREFIX} ${MIDDLE} ${SUFFIX}" | gnuplot

echo "Done"

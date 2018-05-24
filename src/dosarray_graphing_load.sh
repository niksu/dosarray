#/bin/sh -e
# Graphing of load measurements in DoSarray.
# Shilpi Bose, May 2018, UPenn

# Use of this source code is governed by the Apache 2.0 license; see LICENSE
# 
# Usage: ./dosarray_graphing_load.sh -i load_5s.data -o load_5s.pdf -t load -m dedos01:dedos02:dedos03:dedos04:dedos05:dedos06:dedos07:dedos08

while getopts ":i:o:t:m:" opt; do
  case ${opt} in
    i )
      INPUT_FILE=$OPTARG
      ;;
    o )
      OUTPUT_FILE=$OPTARG
      ;;
    t )
      TYPE=$OPTARG
      ;;
    m )
      MACHINES_STRING=$OPTARG
      ;;
    ? )
      echo "Usage: ./dosarray_configure_network -i <input-file> -o <output-file> -t load/mem/net -m <colon-separated-list-of-hosts>"
      exit 1
      ;;
  esac
done
shift $((OPTIND -1))

if [ -z ${INPUT_FILE} ]
then
  echo "Need to provide input file name"
  exit 1
fi

if [ -z ${OUTPUT_FILE} ]
then
  echo "Need to provide output file name"
  exit 1
fi

if [ -z ${TYPE} ]
then
  echo "Need to provide type of load measurement"
  exit 1
fi

IFS=':'; MACHINES=($MACHINES_STRING); unset IFS;

PREFIX="\
set terminal pdfcairo \n\
set output '${OUTPUT_FILE}' \n\
reset \n\
fontsize = 12 \n\
set boxwidth 0.9 \n\
set style fill solid 1.00 border 0 \n\
set style histogram errorbars gap 2 lw 1 \n\
set style data histograms \n\
set xlabel 'time (s)' \n\
\n\
"

if [ ${TYPE} == "load" ]
then
MIDDLE="\
set yrange [0:1] \n\
set ylabel 'load (CPU)' \n\
\n\
"
fi

if [ ${TYPE} == "mem" ]
then
MIDDLE="\
set yrange [0:1] \n\
set ylabel 'mem used' \n\
\n\
"
fi

if [ ${TYPE} == "net" ]
then 
MIDDLE="\
set ylabel 'network traffic (in packets)' \n\
\n\
"
fi

SUFFIX="\
plot '${INPUT_FILE}' using 3:2:4:xtic(1) ti '${MACHINES[0]}' linecolor rgb \"#555555\", '' using 6:5:7 ti '${MACHINES[1]}' lt 1 lc rgb \"#777777\", '' using 9:8:10 ti '${MACHINES[2]}' lt 1 lc rgb \"#999999\", '' using 12:11:13 ti '${MACHINES[3]}' lt 1 lc rgb \"#BBBBBB\", '' using 15:14:16 ti '${MACHINES[4]}' lt 1 lc rgb \"#DDDDDD\", '' using 18:17:19 ti '${MACHINES[5]}' lt 1 lc rgb \"#FFFFFF\", '' using 21:20:22 ti '${MACHINES[6]}' lt 1 lc rgb \"#EEEEEE\", '' using 24:23:25 ti '${MACHINES[7]}' lt 1 lc rgb \"#AAAAAA\" \n\
"

printf "${PREFIX} ${MIDDLE} ${SUFFIX}" | gnuplot

echo "Done"

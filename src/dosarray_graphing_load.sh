#/bin/sh -e
# Graphing of load measurements in DoSarray.
# Shilpi Bose, May 2018, UPenn

# Use of this source code is governed by the Apache 2.0 license; see LICENSE
#
# Usage: ./dosarray_graphing_load.sh -i load_5s.data -o load_5s.pdf -t load -m dedos01:dedos02:dedos03:dedos04:dedos05:dedos06:dedos07:dedos08

while getopts "i:o:t:m:u" opt; do
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
    u )
      # This only applies if "-t load", in which case the y-axis' range is limited to the range [0,1].
      UNIT_LOAD=1
      ;;
    ? )
      echo "Usage: ./dosarray_configure_network -i <input-file> -o <output-file> -t load/mem/net -m <colon-separated-list-of-hosts> [-u]"
      exit 1
      ;;
  esac
done
shift $((OPTIND -1))

if [ -z ${INPUT_FILE} ]
then
  echo "Need to provide input file name" >&2
  exit 1
fi

if [ -z ${OUTPUT_FILE} ]
then
  echo "Need to provide output file name" >&2
  exit 1
fi

if [ -z ${TYPE} ]
then
  echo "Need to provide type of load measurement" >&2
  exit 1
fi

if [ -z "${UNIT_LOAD}" ]
then
  UNIT_LOAD=0
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
  PREMIDDLE=""
  if [ "${UNIT_LOAD}" -eq "1" ]
  then
    PREMIDDLE="set yrange [0:1] \n"
  fi

  MIDDLE="${PREMIDDLE}\
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

COLORS=( '#555555' '#777777' '#999999' '#BBBBBB' '#DDDDDD' '#FFFFFF' '#EEEEEE' '#AAAAAA')
SUFFIX="plot"
COL=2

if [ "${#MACHINES[@]}" -gt "${#COLORS[@]}" ]
then
  echo "#MACHINES (${#MACHINES[@]}) > #COLORS (${#COLORS[@]}): increase the number of colours available to display the load graph correctly." >&2
  exit 1
fi

for (( IDX=0 ; IDX < ${#MACHINES[@]}; IDX++ ))
do
  PRE_COL=$(( ${COL}+1 ))
  POST_COL=$(( ${COL}+2 ))
  if [ ${IDX} -eq 0 ]
  then
    SUFFIX+=" '${INPUT_FILE}' using ${PRE_COL}:$COL:${POST_COL}:xtic(1) ti '${MACHINES[${IDX}]}' linecolor rgb \"${COLORS[${IDX}]}\" "
  else
    SUFFIX+=" , '' using ${PRE_COL}:$COL:${POST_COL} ti '${MACHINES[${IDX}]}' lt 1 lc rgb \"${COLORS[${IDX}]}\" "
  fi
  COL=$(( ${COL} + 3))
done

printf "${PREFIX} ${MIDDLE} ${SUFFIX}" | gnuplot

echo "Done"

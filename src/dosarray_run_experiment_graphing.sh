#/bin/sh -e
# DoSarray Graphing for HTTP Experiment
# Shilpi Bose, October 2018, UPenn
#
# This script is uses collected logs to generate availability and load measurement graphs
#
# Usage: ./dosarray_run_experiment_graphing.sh <destination-dir>
# 
# Use of this source code is governed by the Apache 2.0 license; see LICENSE

if [ -z "${DOSARRAY_SCRIPT_DIR}" ]
then
  echo "\$DOSARRAY_SCRIPT_DIR needs to be defined" >&2
  exit 2
fi

source ${DOSARRAY_SCRIPT_DIR}/src/dosarray_http_experiment_options.sh

DESTINATION_DIR=$1
if [ -z "${DESTINATION_DIR}" ]
then
  echo "\$DESTINATION_DIR needs to be defined" >&2
  exit 2
fi

cd ${DESTINATION_DIR}
command time ${DOSARRAY_SCRIPT_DIR}/src/generate_availability_chart.py "${DOSARRAY_LOG_NAME_PREFIX}*.log" > ${DESTINATION_DIR}/availability.data

#generate availability data for 'availability over time' plot
DOSARRAY_NHIST_RESULT=1 python ${DOSARRAY_SCRIPT_DIR}/src/generate_availability_chart.py "${DOSARRAY_LOG_NAME_PREFIX}*.log" > ${DESTINATION_DIR}/availability_filtered.data

# And finally we graph it to produce the summary plot, contour plot and availability plot respectively
${DOSARRAY_SCRIPT_DIR}/src/dosarray_graphing.sh -i "${DESTINATION_DIR}/availability.data" -o "${DESTINATION_DIR}/graph.pdf" "${TITLE}" "${DOSARRAY_ATTACK_STARTS_AT}" "$((DOSARRAY_ATTACK_STARTS_AT+DOSARRAY_ATTACK_LASTS_FOR))"

DOSARRAY_GRAPH_CONTOUR=1 ${DOSARRAY_SCRIPT_DIR}/src/dosarray_graphing.sh -i "${DESTINATION_DIR}/availability.data" -o "${DESTINATION_DIR}/graph_contour.pdf" "${TITLE}" "${DOSARRAY_ATTACK_STARTS_AT}" "$((DOSARRAY_ATTACK_STARTS_AT+DOSARRAY_ATTACK_LASTS_FOR))"
${DOSARRAY_SCRIPT_DIR}/src/dosarray_graphing_availability.sh "${DESTINATION_DIR}" "${TITLE}" "${DOSARRAY_ATTACK_STARTS_AT}" "$((DOSARRAY_ATTACK_STARTS_AT+DOSARRAY_ATTACK_LASTS_FOR))"

#Graphing load measurements
${DOSARRAY_SCRIPT_DIR}/src/dosarray_graphing_load.sh -i ${DESTINATION_DIR}/load.data -o ${DESTINATION_DIR}/load.pdf -t load -m $(echo ${DOSARRAY_PHYSICAL_HOSTS_PUB[@]} | tr " " ":")
${DOSARRAY_SCRIPT_DIR}/src/dosarray_graphing_load.sh -i ${DESTINATION_DIR}/net_tx.data -o ${DESTINATION_DIR}/net_tx.pdf -t net -m $(echo ${DOSARRAY_PHYSICAL_HOSTS_PUB[@]} | tr " " ":")
${DOSARRAY_SCRIPT_DIR}/src/dosarray_graphing_load.sh -i ${DESTINATION_DIR}/net_rx.data -o ${DESTINATION_DIR}/net_rx.pdf -t net -m $(echo ${DOSARRAY_PHYSICAL_HOSTS_PUB[@]} | tr " " ":")
${DOSARRAY_SCRIPT_DIR}/src/dosarray_graphing_load.sh -i ${DESTINATION_DIR}/net_rxerrors.data -o ${DESTINATION_DIR}/net_rxerrors.pdf -t net -m $(echo ${DOSARRAY_PHYSICAL_HOSTS_PUB[@]} | tr " " ":")
${DOSARRAY_SCRIPT_DIR}/src/dosarray_graphing_load.sh -i ${DESTINATION_DIR}/net_txerrors.data -o ${DESTINATION_DIR}/net_txerrors.pdf -t net -m $(echo ${DOSARRAY_PHYSICAL_HOSTS_PUB[@]} | tr " " ":")
${DOSARRAY_SCRIPT_DIR}/src/dosarray_graphing_load.sh -i ${DESTINATION_DIR}/mem.data -o ${DESTINATION_DIR}/mem.pdf -t mem -m $(echo ${DOSARRAY_PHYSICAL_HOSTS_PUB[@]} | tr " " ":")

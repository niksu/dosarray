#/bin/sh -e
# Main support functions for running DoSarray experiments
# Nik Sultana, February 2018, UPenn

if [ -z "${DOSARRAY_SCRIPT_DIR}" ]
then
  echo "Need to configure DoSarray -- set \$DOSARRAY_SCRIPT_DIR" >&2
  exit 1
elif [ ! -e "${DOSARRAY_SCRIPT_DIR}/config/dosarray_config.sh" ]
then
  echo "Need to configure DoSarray -- could not find dosarray_config.sh at \$DOSARRAY_SCRIPT_DIR/config (${DOSARRAY_SCRIPT_DIR}/config)" >&2
  exit 1
fi
source "${DOSARRAY_SCRIPT_DIR}/config/dosarray_config.sh"

# FIXME insert a manifest in the RESULT_DIR, describing the date at which the experiment was made, and a full dump of all configuration variables.

function dosarray_tmp_file() {
  TAG="${1}"
  TMPFILE=`mktemp -q /tmp/dosarray.${TAG}.XXXXXX`
  if [ $? -ne 0 ]; then
    echo "DoSarray: Could not create temporary file"
    exit 1
  fi
  echo "${TMPFILE}"
}

function dosarray_http_experiment() {
  TARGET=$1
  ATTACK=$2
  EXPERIMENT_SET=$3
  export DESTINATION_DIR=$4

  source "${DOSARRAY_SCRIPT_DIR}/src/dosarray_http_experiment_options.sh"

  echo "Started HTTP experiment at $(date): ${TARGET}, ${ATTACK}, ${EXPERIMENT_SET}"
  STD_OUT=`dosarray_tmp_file stdout`
  STD_ERR=`dosarray_tmp_file stderr`
  echo "  Writing to ${DESTINATION_DIR}"

  TITLE="$(target_str ${TARGET}), $(attack_str ${ATTACK}), ${EXPERIMENT_SET}" \
  ${DOSARRAY_SCRIPT_DIR}/src/dosarray_run_http_experiment.sh ${TARGET} ${ATTACK} \
  > ${STD_OUT} \
  2> ${STD_ERR}

  # Move simulation logs to RESULTS directory
  mv ${STD_OUT} ${DESTINATION_DIR}/stdout
  mv ${STD_ERR} ${DESTINATION_DIR}/stderr

  echo "Finished at $(date)"
}
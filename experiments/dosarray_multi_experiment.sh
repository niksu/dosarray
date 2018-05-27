#/bin/sh -e
# Example of using DoSarray
# Nik Sultana, February 2018, UPenn
#
# Targetting Apache using various attacks
# NOTE we can also easily change this to target Nginx and others.

dosarray_execute_on "${HOST_NAME}" "${EXPERIMENT_RESET_CMD}"
sleep ${INTER_EXPERIMENT_GAP}

export EXPERIMENT_TAG=ge
echo "Running ${EXPERIMENT_TAG} at $(date)"
echo "  Writing to ${RESULT_DIR_PREFIX}${EXPERIMENT_TAG}${RESULT_DIR_SUFFIX}" # FIXME repeated below
DESTINATION_DIR=${RESULT_DIR_PREFIX}${EXPERIMENT_TAG}${RESULT_DIR_SUFFIX} \
TITLE="Apache worker, GoldenEye, ${EXPERIMENT_SET}" \
${DOSARRAY_SCRIPT_DIR}/src/dosarray_run_experiment.sh apache_worker goldeneye \
> ${EXPERIMENT_TAG}${RESULT_DIR_SUFFIX}_output.stdout \
2> ${EXPERIMENT_TAG}${RESULT_DIR_SUFFIX}_output.stderr

dosarray_execute_on "${HOST_NAME}" "${EXPERIMENT_RESET_CMD}"
sleep ${INTER_EXPERIMENT_GAP}

export EXPERIMENT_TAG=th
echo "Running ${EXPERIMENT_TAG} at $(date)"
echo "  Writing to ${RESULT_DIR_PREFIX}${EXPERIMENT_TAG}${RESULT_DIR_SUFFIX}" # FIXME repeated below
DESTINATION_DIR=${RESULT_DIR_PREFIX}${EXPERIMENT_TAG}${RESULT_DIR_SUFFIX} \
TITLE="Apache worker, Tors Hammer, ${EXPERIMENT_SET}" \
${DOSARRAY_SCRIPT_DIR}/src/dosarray_run_experiment.sh apache_worker torshammer \
> ${EXPERIMENT_TAG}${RESULT_DIR_SUFFIX}_output.stdout \
2> ${EXPERIMENT_TAG}${RESULT_DIR_SUFFIX}_output.stderr

dosarray_execute_on "${HOST_NAME}" "${EXPERIMENT_RESET_CMD}"
sleep ${INTER_EXPERIMENT_GAP}

export EXPERIMENT_TAG=baseline
echo "Running ${EXPERIMENT_TAG} at $(date)"
echo "  Writing to ${RESULT_DIR_PREFIX}${EXPERIMENT_TAG}${RESULT_DIR_SUFFIX}" # FIXME repeated below
DESTINATION_DIR=${RESULT_DIR_PREFIX}${EXPERIMENT_TAG}${RESULT_DIR_SUFFIX} \
TITLE="Apache worker, baseline, ${EXPERIMENT_SET}" \
${DOSARRAY_SCRIPT_DIR}/src/dosarray_run_experiment.sh apache_worker none \
> ${EXPERIMENT_TAG}${RESULT_DIR_SUFFIX}_output.stdout \
2> ${EXPERIMENT_TAG}${RESULT_DIR_SUFFIX}_output.stderr

dosarray_execute_on "${HOST_NAME}" "${EXPERIMENT_RESET_CMD}"

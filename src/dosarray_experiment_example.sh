#/bin/sh -e
# Example of using DoSarray
# Nik Sultana, February 2018, UPenn
# FIXME remove hardcoded paths? export path to config file   

echo "Started at $(date)"

HOST_NAME=demo01

INTER_EXPERIMENT_GAP=20
EXPERIMENT_RESET_CMD="/home/nik/src/prefix/bin/apachectl -k restart"

# FIXME use DOSARRAY_VIRT_INSTANCES instead of NO_OF_INSTANCES
export NO_OF_INSTANCES=10
export EXPERIMENT_DURATION=65
export ATTACK_STARTS_AT=10
export ATTACK_LASTS_FOR=20

# FIXME insert a manifest in the RESULT_DIR, describing the date at which the experiment was made, and a full dump of all configuration variables.

EXPERIMENT_SET="test"
RESULT_DIR_PREFIX=/Users/shilpi/Documents/repo/results/apache_worker_
RESULT_DIR_SUFFIX=_10inst_2attackers
# NOTE to vary no. of attackers, edit dosarray_run_http_experiment.sh

export EXPERIMENT_TAG=sl
echo "Running ${EXPERIMENT_TAG} at $(date)"
echo "  Writing to ${RESULT_DIR_PREFIX}${EXPERIMENT_TAG}${RESULT_DIR_SUFFIX}" # FIXME repeated below
DESTINATION_DIR=${RESULT_DIR_PREFIX}${EXPERIMENT_TAG}${RESULT_DIR_SUFFIX} \
TITLE="Apache worker, Slowloris, ${EXPERIMENT_SET}" \
./dosarray_run_http_experiment.sh apache_worker slowloris \
> /tmp/${EXPERIMENT_TAG}${RESULT_DIR_SUFFIX}_output.stdout \
2> /tmp/${EXPERIMENT_TAG}${RESULT_DIR_SUFFIX}_output.stderr

echo "Finished at $(date)"

ls -d ${RESULT_DIR_PREFIX}*${RESULT_DIR_SUFFIX}

# Move simulation logs to RESULTS directory
mv /tmp/${EXPERIMENT_TAG}${RESULT_DIR_SUFFIX}_output.std* ${RESULT_DIR_PREFIX}${EXPERIMENT_TAG}${RESULT_DIR_SUFFIX}/

echo "Now do: open ${RESULT_DIR_PREFIX}*${RESULT_DIR_SUFFIX}/graph.png"

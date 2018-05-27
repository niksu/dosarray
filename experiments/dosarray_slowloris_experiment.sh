#/bin/sh -e
# Example of using DoSarray
# Nik Sultana, February 2018, UPenn

source "${DOSARRAY_SCRIPT_DIR}/experiments/dosarray_experiment.sh"

export EXPERIMENT_DURATION=65
export ATTACK_STARTS_AT=10
export ATTACK_LASTS_FOR=20
export GAP_BETWEEN_ROUNDS=5

# FIXME to vary no. & placement of attackers must edit dosarray_run_http_experiment.sh
#       Centralise the experiment config here.

dosarray_http_experiment apache_worker slowloris "Default config" "$(pwd)/example_experiment"

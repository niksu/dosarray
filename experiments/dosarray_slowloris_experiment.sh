#/bin/sh -e
# Example of using DoSarray
# Nik Sultana, February 2018, UPenn
#
# Using DoSarray consists of setting the experiment's parameters
# (such as the experiment's duration, and the attack interval), and then
# calling the functions that applies an attack to a target.
#
# In this example the experiment consists of applying Slowloris
# to the Apache web server.

source "${DOSARRAY_SCRIPT_DIR}/experiments/dosarray_experiment.sh"

export EXPERIMENT_DURATION=65
export ATTACK_STARTS_AT=10
export ATTACK_LASTS_FOR=20
export GAP_BETWEEN_ROUNDS=5

# FIXME to vary no. & placement of attackers must edit dosarray_run_http_experiment.sh
#       Centralise the experiment config here.

dosarray_http_experiment apache_worker slowloris "Default config" "$(pwd)/example_experiment"


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

export DOSARRAY_EXPERIMENT_DURATION=65
export DOSARRAY_ATTACK_STARTS_AT=10
export DOSARRAY_ATTACK_LASTS_FOR=20
export INTERVAL_BETWEEN_LOAD_POLLS=5

# NOTE uncomment this to run the attack over SSL.
#export DOSARRAY_HTTP_SSL=1

# This function picks the containers from where the attacks are made.
dosarray_evenly_distribute_attackers 5

# NOTE you can make multiple runs of an experiment by appending a number
#       e.g., dosarray_http_experiment apache_worker slowloris "Default config" "$(pwd)/example_experiment_X4" 4
dosarray_http_experiment apache_worker slowloris "Default config" "$(pwd)/example_experiment"

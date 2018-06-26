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

# NOTE uncomment this to run the attack over SSL.
#export DOSARRAY_HTTP_SSL=1

# We run an attack script in these containers.
# NOTE don't include whitepace before newline.
# NOTE this example can only have one attack at a time -- edit "dosarray_http_experiment" to mix attacks.
export ATTACKERS="is_attacker() { \n\
    grep -F -q -x \"\$1\" <<EOF\n\
c3.2\n\
c4.3\n\
c5.4\n\
c6.5\n\
c7.6\n\
NOc8.7\n\
NOc6.4\n\
NOc7.4\n\
NOc8.4\n\
NOc3.6\n\
NOc4.2\n\
NOc5.3\n\
EOF\n\
}\n"

# NOTE you can make multiple runs of an experiment by appending a number
#       e.g., dosarray_http_experiment apache_worker slowloris "Default config" "$(pwd)/example_experiment_X4" 4
dosarray_http_experiment apache_worker slowloris "Default config" "$(pwd)/example_experiment"

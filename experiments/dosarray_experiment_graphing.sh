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

while getopts "a:d:t:" opt; do
  case ${opt} in
    a )
      ATTACK=$OPTARG
      ;;
    t )
      TARGET=$OPTARG
      ;;
    d )
      DESTINATION=$OPTARG
      ;;
    ? )
      echo "Usage: ./dosarray_experiment_graphing -a <attack> -d <destination-dir> -t <target>"
      exit 1
      ;;
  esac
done
shift $((OPTIND -1))

source "${DOSARRAY_SCRIPT_DIR}/experiments/dosarray_experiment.sh"

EXPERIMENT_SET='Default config'

export EXPERIMENT_DURATION=65
export ATTACK_STARTS_AT=10
export ATTACK_LASTS_FOR=20
export INTERVAL_BETWEEN_LOAD_POLLS=5
export TITLE="${TARGET}, ${ATTACK}, ${EXPERIMENT_SET}"
# NOTE uncomment this to run the attack over SSL.
#export DOSARRAY_HTTP_SSL=1

${DOSARRAY_SCRIPT_DIR}/src/dosarray_run_experiment_graphing.sh ${DESTINATION}

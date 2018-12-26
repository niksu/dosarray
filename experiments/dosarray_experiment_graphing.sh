#/bin/sh -e
# Example of using DoSarray Graphing
# Shilpi Bose, October 2018, UPenn
#
# Using DoSarray graphing consists of setting the experiment's parameters
# (such as the experiment's duration, and the attack interval), and then
# calling the experiment graphing script with the destination directory of 
# container logs
#
# Usage: ./dosarray_experiment_graphing -a <attack> -d <destination-dir> -t <target>

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

export DOSARRAY_EXPERIMENT_DURATION=65
export DOSARRAY_ATTACK_STARTS_AT=10
export DOSARRAY_ATTACK_LASTS_FOR=20
export DOSARRAY_INTERVAL_BETWEEN_LOAD_POLLS=5
export TITLE="${TARGET}, ${ATTACK}, ${EXPERIMENT_SET}"

${DOSARRAY_SCRIPT_DIR}/src/dosarray_run_experiment_graphing.sh ${DESTINATION}

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

## We run an attack script in these containers.
## NOTE don't include whitepace before newline.
## NOTE this example can only have one attack at a time -- edit "dosarray_http_experiment" to mix attacks.
#export ATTACKERS="is_attacker() { \n\
#    grep -F -q -x \"\$1\" <<EOF\n\
#c3.2\n\
#c4.3\n\
#c5.4\n\
#c6.5\n\
#c7.6\n\
#NOc8.7\n\
#NOc6.4\n\
#NOc7.4\n\
#NOc8.4\n\
#NOc3.6\n\
#NOc4.2\n\
#NOc5.3\n\
#EOF\n\
#}\n"

# Evenly allocate attackers among the virtual nodes on physical hosts.
function dosarray_evenly_distribute_attackers() {
  NO_ATTACKERS=$1
  # One of the physical nodes is reserved for the target, and the rest for measurement/attack.
  SKIP=1
  NONTARGET_PHYS_NODES=$(( ${#DOSARRAY_PHYSICAL_HOSTS_PUB[@]} - ${SKIP} ))
  AVAILABLE_NODES=$(( ${NONTARGET_PHYS_NODES} * ${DOSARRAY_VIRT_INSTANCES} ))

  #echo "NO_ATTACKERS=${NO_ATTACKERS}"
  #echo "NONTARGET_PHYS_NODES=${NONTARGET_PHYS_NODES}"
  #echo "AVAILABLE_NODES=${AVAILABLE_NODES}"

  if [ "${NO_ATTACKERS}" -gt "${AVAILABLE_NODES}" ]
  then
    echo "\$NO_ATTACKERS(${NO_ATTACKERS}) > \$AVAILABLE_NODES(${AVAILABLE_NODES})" >&2
    exit 1
  fi

  FN='export ATTACKERS="is_attacker() { \ngrep -F -q -x \"\$1\" <<EOF\n'
  VIRT_IDX=${DOSARRAY_MIN_VIP}
  while [ "${NO_ATTACKERS}" -gt 0 ]
  do
    for PHYS_IDX in `seq ${SKIP} $(( ${#DOSARRAY_VIRT_NET_SUFFIX[@]} - 1 ))` # FIXME should the "- 1" be "- ${SKIP}"?
    do
      if [ "${NO_ATTACKERS}" -gt 0 ]
      then
        FN+="c${PHYS_IDX}.${VIRT_IDX}\n"
        NO_ATTACKERS=$(( ${NO_ATTACKERS} - 1 ))
      else
        break
      fi
    done

    VIRT_IDX=$(( ${VIRT_IDX} + 1 ))
  done

  FN+='EOF\n}\n"'
  echo "FN=${FN}"
  eval "${FN}"
}

dosarray_evenly_distribute_attackers 5

# NOTE you can make multiple runs of an experiment by appending a number
#       e.g., dosarray_http_experiment apache_worker slowloris "Default config" "$(pwd)/example_experiment_X4" 4
dosarray_http_experiment apache_worker slowloris "Default config" "$(pwd)/example_experiment"

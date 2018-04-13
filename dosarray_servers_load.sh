#/bin/sh -e
# Experimental setup for the Winnow project.
# Nik Sultana, February 2018, UPenn
#
# Downloads load indicators from a collection of machines for $NUM_ROUNDS times,
# sleeping $GAP_BETWEEN_ROUNDS between downloads.

if [ -z "${NUM_ROUNDS}" ]
then
  echo "Need to define \$NUM_ROUNDS" >&2
  exit 1
fi

echo "NUM_ROUNDS=${NUM_ROUNDS}"

if [ -n "${EXPERIMENT_DURATION}" ]
then
  echo "EXPERIMENT_DURATION=${EXPERIMENT_DURATION}"
  GAP_BETWEEN_ROUNDS=$(echo "${EXPERIMENT_DURATION} / ${NUM_ROUNDS}" | bc -l)
fi

if [ -z "${GAP_BETWEEN_ROUNDS}" ]
then
  echo "Need to define \$GAP_BETWEEN_ROUNDS or \$EXPERIMENT_DURATION" >&2
  exit 1
fi
echo "GAP_BETWEEN_ROUNDS=${GAP_BETWEEN_ROUNDS}"

function logname_of_load() {
  HOST_NAME="$1"
  echo "${HOST_NAME}_load.log"
}

function logname_of_mem() {
  HOST_NAME="$1"
  echo "${HOST_NAME}_mem.log"
}

function logname_of_net() {
  HOST_NAME="$1"
  echo "${HOST_NAME}_net.log"
}

# FIXME hardcoded list of machines
for HOST_NAME in dedos01 dedos02 dedos03 dedos04 dedos05 dedos06 dedos07 dedos08
do
  rm -f $(logname_of_load ${HOST_NAME})
  rm -f $(logname_of_mem ${HOST_NAME})
  rm -f $(logname_of_net ${HOST_NAME})
done

for ROUND in `seq 0 ${NUM_ROUNDS}`
do
# FIXME hardcoded list of machines
  for HOST_NAME in dedos01 dedos02 dedos03 dedos04 dedos05 dedos06 dedos07 dedos08
  do
# FIXME various hardcodings
    ssh -n -i ~/.ssh/dedos_cluster_rsa nsultana@${HOST_NAME}.cis.upenn.edu -p 2324 \
    bash -c "true
    eval H='\$(hostname)'
    eval D='\$(date +%s)'
    eval C='\$(cat /proc/loadavg)'
    eval echo "\$H \$D \$C"
    " >> $(logname_of_load ${HOST_NAME}) &

# FIXME various hardcodings
    ssh -n -i ~/.ssh/dedos_cluster_rsa nsultana@${HOST_NAME}.cis.upenn.edu -p 2324 \
    bash -c "true
    eval H='\$(hostname)'
    eval D='\$(date +%s)'
    eval C='\$(grep Mem /proc/meminfo)'
    eval echo "\$H \$D \$C"
    " >> $(logname_of_mem ${HOST_NAME}) &

# FIXME various hardcodings
    ssh -n -i ~/.ssh/dedos_cluster_rsa nsultana@${HOST_NAME}.cis.upenn.edu -p 2324 \
    cat /proc/net/dev >> $(logname_of_net ${HOST_NAME}) &
  done

  if [ "${ROUND}" -ne "${NUM_ROUNDS}" ]
  then
    sleep ${GAP_BETWEEN_ROUNDS}
  fi
done

echo "Done"

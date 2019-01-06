#/bin/bash -e
# Checking whether server is up, in the HTTP experiment setup for DoSarray.
# Nik Sultana, January 2018, UPenn
#
# Use of this source code is governed by the Apache 2.0 license; see LICENSE

set -e

if [ -z "${DOSARRAY_SCRIPT_DIR}" ]
then
  echo "Need to configure DoSarray -- set \$DOSARRAY_SCRIPT_DIR" >&2
  exit 1
elif [ ! -e "${DOSARRAY_SCRIPT_DIR}/config/dosarray_config.sh" ]
then
  echo "Need to configure DoSarray -- could not find dosarray_config.sh at \$DOSARRAY_SCRIPT_DIR/config (${DOSARRAY_SCRIPT_DIR}/config)" >&2
  exit 1
fi
source "${DOSARRAY_SCRIPT_DIR}/config/dosarray_config.sh"

SERVER_CHOICE=$1

# This is where we probe from.
HOST_NAME="${DOSARRAY_PHYSICAL_HOSTS_PUB[${DOSARRAY_TARGET_SERVER_INDEX}]}"

if [ "${SERVER_CHOICE}" == "nginx" ]
then
  PORT=8012
elif [ "${SERVER_CHOICE}" == "apache_worker" ]
then
  PORT=8011
elif [ "${SERVER_CHOICE}" == "apache_event" ]
then
  PORT=8013
elif [ "${SERVER_CHOICE}" == "lighttpd" ]
then
  PORT=8014
elif [ "${SERVER_CHOICE}" == "haproxy" ]
then
  PORT=8016
elif [ "${SERVER_CHOICE}" == "varnish" ]
then
  PORT=8015
elif [ "${SERVER_CHOICE}" == "dedos_web" ]
then
  PORT=8081
else
  echo "Unknown server choice: '${SERVER_CHOICE}'" >&2
  exit 1
fi

if [ -z "${DOSARRAY_HTTP_SSL}" ]
then
  CMD="curl --silent -o /dev/null -w \"%{http_code}\" http://${DOSARRAY_PHYSICAL_HOSTS_PRIV[${DOSARRAY_TARGET_SERVER_INDEX}]}:${PORT}"
else
  # FIXME hardcoded URL below -- "index.html"
  # FIXME using "--insecure", might want to make this configurable.
  CMD="curl --insecure --silent -o /dev/null -w \"%{http_code}\" https://${DOSARRAY_PHYSICAL_HOSTS_PRIV[${DOSARRAY_TARGET_SERVER_INDEX}]}:${PORT}/index.html"
fi

RESULT=$(dosarray_execute_on "${HOST_NAME}" "${CMD}")

# A success code 200 is returned when the server is up. However, some environments involving multiple hops to the server machine may return an output "200Connection to host@xzy.com is closed". This trims away the appended message and returns 200
RESULT=${RESULT/Connection to * closed*/}

# A success code 200 is returned when the server is up. However, some environments involving multiple hops to the server machine may return an output "200Connection to host@xzy.com is closed". This trims away the appended message and returns 200
RESULT=${RESULT/Connection to * closed*/}

echo $RESULT

exit $RESULT

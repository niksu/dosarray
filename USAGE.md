
### Prerequisites
* Python3
* sudo privileges in the physical hosts
* docker service in the physical hosts
* gnuplot with pdf terminal support (install using --with-cairo option)

###Setting up DoSArray

The first and foremost step is to set the DosArray Script directory. Every script in DoSArray checks this variable on startup and is certain to exit with an error if this variable is not set.
 `export DOSARRAY_SCRIPT_DIR=<path-to-dosarray-scripts>`

Next, we need to configure DoSArray to simulate experiments using the available resources (physical hosts). That involves setting the following variables in `dosarray_config.sh`
* `DOSARRAY_PHYSICAL_HOSTS_PRIV`: Populate this list with the IP addresses of all the physical hosts. Please ensure the target physical host is the first element of the list (this will be elaborated on when discussing `DOSARRAY_CONTAINER_HOST_IDXS`) 

* `DOSARRAY_VIRT_NET_SUFFIX`: Populate this list with the last octet of every IP address in `DOSARRAY_PHYSICAL_HOSTS_PRIV`, in the same order as they appear in there.

* `DOSARRAY_PHYSICAL_HOSTS_PUB`: Populate this list with the host names of all the physical machines, again in the same order as they appear in the former variable.

* `DOSARRAY_VIRT_NET_PREFIX`: This is a string specifying the first two octets of your physical host IPs, eg - "192.168."

* `DOSARRAY_VIRT_NETS`: This list is populated based on the previous entries to form the prefix of each containers' IP in the physical hosts

* `DOSARRAY_VIRT_INSTANCES`: This number specifies the number of containers to be created on each physical host.

* `DOSARRAY_MIN_VIP`: All containers have a predefined name and this variable sets the starting index for a container name.

* `DOSARRAY_MIN_VIP` : This specifies the last index for a container and its calculated for based on the previous two values.

* `DOSARRAY_CONTAINER_PREFIX`: This is a string specifying the prefix for a container name.

* `DOSARRAY_LOG_NAME_PREFIX`: Each container log is the same as the container name, which calls for the same container prefix. This could be changed to suit your needs.

* `DOSARRAY_LOG_PATH_PREFIX`: This variable specified the location of all container logs within the physical hosts  

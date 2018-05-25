## Prerequisites
* Python3
* sudo privileges in the physical hosts
* docker service in the physical hosts
* gnuplot with pdf terminal support (install using --with-cairo option)

## Setting up DoSarray
The first and foremost step is to set the DoSarray Script directory. Every script in DoSarray checks this variable on startup and is certain to exit with an error if this variable is not set.
```
export DOSARRAY_SCRIPT_DIR=<path-to-dosarray-scripts>
```

Next, we need to configure DoSarray to simulate experiments using the available resources (physical hosts). That involves setting the following variables in `dosarray_config.sh`
* `DOSARRAY_PHYSICAL_HOSTS_PRIV`: Populate this list with the IP addresses of all the physical hosts. Please ensure the target physical host is the first element of the list

* `DOSARRAY_VIRT_NET_SUFFIX`: Populate this list with the last octet of every IP address in `DOSARRAY_PHYSICAL_HOSTS_PRIV`, in the same order as they appear in there.

* `DOSARRAY_PHYSICAL_HOSTS_PUB`: Populate this list with the host names of all the physical machines, again in the same order as they appear in the former variable.

* `DOSARRAY_HOST_INTERFACE_MAP`: Populate this list with the network interface to be measured for each physical host, in the same order as the former list
 
* `DOSARRAY_VIRT_NET_PREFIX`: This is a string specifying the first two octets of your physical host IPs, eg - "192.168."

* `DOSARRAY_VIRT_NETS`: This list is populated based on the previous entries to form the prefix of each containers' IP in the physical hosts

* `DOSARRAY_VIRT_INSTANCES`: This number specifies the number of containers to be created on each physical host.

* `DOSARRAY_MIN_VIP`: All containers have a predefined name and this variable sets the starting index for a container name.

* `DOSARRAY_MIN_VIP` : This specifies the last index for a container and its calculated for based on the previous two values.

* `DOSARRAY_CONTAINER_PREFIX`: This is a string specifying the prefix for a container name.

* `DOSARRAY_LOG_NAME_PREFIX`: Each container log is the same as the container name, which calls for the same container prefix. This could be changed to suit your needs.

* `DOSARRAY_LOG_PATH_PREFIX`: This variable specified the location of all container logs within the physical hosts

## Using DoSarray
An important consideration in DoSarray is to achieve address diversity in order to simulate larger networks in these experiments. This involves configuring each host in the physical network with the network info of the virtual network by modifying the rules for iptables, routes or for both, by using the -r option.

```
./dosarray_configure_network [-r] <physical-host-name>
```

After configuring the network, the next step is creating and starting docker containers in each of the physical hosts except the target. The following invokation of scripts creates containers in each of these host based on the values set in `dosarray_config.sh`

```
./dosarray_create_containers.sh
./dosarray_start_containers.sh
```

Once we have the configuration in place, simulating the a DoS attack is just a few steps away. For starters, DoSarray also has a sample experiment which goes through the entire lifecycle of the experiment, starting from measurements before, after and during the attack and ending with graphing the data gathered during the experiment.
```
./dosarray_experiment_example.sh
```

This script simulates the slowloris attack on apache and compiles all the container logs, .stdout and .stderr logs and the final graph generated from the availability data in the results directory. This is a good starting point for first-time users and we encourage you to adapt this script to suit your specific needs. For instance, `dosarray_setup_http_experiment.sh` can be further modified to configure various parameters such as type of server and attack, duration of attack and experiment and various measurement commmands.

Once we have gathered all our logs and results, DoSarray also facilitates clearing out the docker containers which we created for conducting the experiment. The following scripts stop and delete the containers we created in each phyical host except for the target.

```
./dosarray_stop_containers.sh
./dosarray_delete_containers.sh
```

## Load graphing
Load data is gathered automatically during experiments, for offline analysis and graphing. These logs can be accessed within the results dorectory. 
To generate graphs using the various load measurements, we must first generate the graph data and then use this data to generate the graphs.

To generate graphing data, the following script is invoked with parameters for logfile directory, load measurement duration, load type, chart type and list of machines. 
```
python generate_load_chart.py -p testdata/1 testdata/2 -i 5 -t load -o column -m dedos01 dedos02 dedos03 dedos04 dedos05 dedos06 dedos07 dedos08
```

The generated data files are input to the graphing script along with the measurement type (load, net, mem) followed by a colon seperated list of machines.
```
./dosarray_graphing_load.sh -i load_5s.data -o load_5s.pdf -t load -m dedos01:dedos02:dedos03:dedos04:dedos05:dedos06:dedos07:dedos08
```

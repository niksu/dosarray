## Setting up the environment
First you need to set up Docker and configure the network.
This is explained in DoSarray's [setup instructions](SETUP.md).

## Preparing the target
The target consists of software whose availability will
be challenged during the DoS experiment.
Our approach to organising targets is documented in our [target
preparation](TARGET.md).

## Configuring DoSarray
The first and foremost step is to set the DoSarray Script directory. Every script in DoSarray checks this variable on startup and is certain to exit with an error if this variable is not set.
```
export DOSARRAY_SCRIPT_DIR=<path-to-dosarray-scripts>
```

Next, we need to configure DoSarray to simulate experiments using the available resources (physical hosts). That involves setting the following variables in `config/dosarray_config.sh`
* `DOSARRAY_PHYSICAL_HOSTS_PRIV`: Populate this list with the IP addresses of all the physical hosts.

* `DOSARRAY_VIRT_NET_SUFFIX`: Populate this list with the last octet of every IP address in `DOSARRAY_PHYSICAL_HOSTS_PRIV`, in the same order as they appear in there.

* `DOSARRAY_PHYSICAL_HOSTS_PUB`: Populate this list with the host names of all the physical machines, again in the same order as they appear in the former variable.

* `DOSARRAY_HOST_INTERFACE_MAP`: Populate this list with the network interface to be measured for each physical host, in the same order as the former list.

* `DOSARRAY_TARGET_SERVER_INDEX` : This is the index of the machine which will act as the target for DoS attacks

* `DOSARRAY_HOST_COLORS` : Populate this list with different colors to view a comparison of load on all machines.

* `DOSARRAY_VIRT_NET_PREFIX`: This is a string specifying the first two octets of your physical host IPs, eg - "192.168."

* `DOSARRAY_VIRT_NETS`: This list is populated based on the previous entries to form the prefix of each containers' IP in the physical hosts

* `DOSARRAY_VIRT_INSTANCES`: This number specifies the number of containers to be created on each physical host.

* `DOSARRAY_MIN_VIP`: All containers have a predefined name and this variable sets the starting index for a container name.

* `DOSARRAY_MIN_VIP` : This specifies the last index for a container and its calculated for based on the previous two values.

* `DOSARRAY_CONTAINER_PREFIX`: This is a string specifying the prefix for a container name. Please ensure that container prefix is not a prefix for any physical host name as it may intefere with the collection of container logs at the end of the experiment.

* `DOSARRAY_LOG_NAME_PREFIX`: Each container log is the same as the container name, which calls for the same container prefix. This could be changed to suit your needs.

* `DOSARRAY_LOG_PATH_PREFIX`: This variable specified the location of all container logs within the physical hosts

## Optional parameters
* `DOSARRAY_INCLUDE_MANIFEST`: Setting this to any value (e.g., "1") will generate a file containing a dump of your environment variables. This is disabled by default to avoid potential unwanted disclosures of those variables' values, but it can be useful to activate during testing or to make the experiments more reproducible.

* `DOSARRAY_INCLUDE_STDOUTERR`: Setting this to any value (e.g., "1") will generate a file containing the stdout and stderr output that takes place during the experiment. This is disabled by default but it can be useful to activate during testing or to make the experiments more reproducible.

## Using DoSarray

### Configuring network
An important consideration in DoSarray is to achieve address diversity in order
to simulate larger networks in these experiments. This involves configuring
each host in the physical network with the network info of the virtual network
by modifying the rules for iptables, and additionally the route configuration
by using the `-r` option. This script needs to be run only once during setup.
However multiple re-runs of this script are harmless and should simply produce
a message 'iptables: No chain/target/match by that name.' indicating the the
unnecessary rules have already been deleted.

```
./src/dosarray_configure_networking.sh [-r] <physical-host-name>
```

NOTE: Configure network on the target machine with the -r option to route packets correctly 

The output of the network configuration script displays all the commands executed in the host. Changes applied to iptables and routes can be viewed by running `sudo iptable -S`. Similarly, the newly added routes can be viewed by running `ip route show`

Take for example the following route modification command: `sudo route add -net 192.168.1.0 netmask 255.255.255.0 gw 192.168.0.1`. On executing `ip route show`, this new route will be displayed as follows in the output:

```
192.168.1.0/24 via 192.168.0.1 dev em1
```
Alternatively, if you run `ip route get 192.168.1.0` on the host, a correct output without any cache entry would look like:
```
192.168.1.0 via 192.168.0.1 dev eno1  src 192.168.0.11
    cache
```

If the route has been cached, the route would also show cache details as follows:
```
192.168.1.0 via 192.168.0.1 dev eno1  src 192.168.0.11
    cache users 1 used 326 age 12sec mtu 1500 advmss 1460
```

However, if you see something like the following output:
```
192.168.1.0 via 209.148.46.1 dev eno4  src 209.148.46.30
    cache
```
the required routes haven't been added because we aren't routing packets via 192.168.0.1 as specified by the route we intended to add. For more details on how routes are configures, refer to [this useful link](http://linux-ip.net/html/tools-ip-route.html)

Even iptable modifications such as `sudo iptables -A FORWARD -o docker_bridge -j ACCEPT` can be viewed by executing `sudo iptables -S` to output the following::

```
-A FORWARD -o docker_bridge -j ACCEPT
```
 
### Container setup
After configuring the network, the next step is creating and starting docker containers in each of the physical hosts except the target. The following invokation of scripts creates containers in each of these host based on the values set in `dosarray_config.sh`

```
./src/dosarray_create_containers.sh
./src/dosarray_start_containers.sh
```

### Running the example experiment
Once we have the configuration in place, simulating the a DoS attack is just a few steps away. For starters, DoSarray also has a sample experiment which goes through the entire lifecycle of the experiment, starting from measurements before, after and during the attack and ending with graphing the data gathered during the experiment. To run the example experiment scirpt make sure to change to `RESULT_DIR` to store the location of the generated results.

```
./experiments/dosarray_experiment_example.sh
```

This script simulates the slowloris attack on apache and compiles all the container logs, .stdout and .stderr logs and the final graph generated from the availability data in the results directory. It also collects load measurements on each physical host and plots them as column charts. An elaborate discussion on load graphing is included in the next section.This script is a good starting point for first-time users and we encourage you to adapt this script to suit your specific needs. For instance, `src/dosarray_setup_http_experiment.sh` can be further modified to configure various parameters such as type of server and attack, duration of attack and experiment and various measurement commmands.

Another useful feature of DoSArray is the ability to run the attack, extract logs and generate graphs independently. When `src/dosarray_run_http_experiment` is invoked without any parameter, it runs the experiment and exits after extracting all the container logs. These logs can later be used to generate graphs using `experiments/dosarray_experiment_graphing.sh`. Alternately, we can also run the entire workflow comprising of the attack, logs extraction and graphing using `src/dosarray_run_http_experiment -g`. Note the use of '-g' to control the extent of the experiment run. 

### Container removal
Once we have gathered all our logs and results, DoSarray also facilitates clearing out the docker containers which we created for conducting the experiment. The following scripts stop and delete the containers we created in each phyical host except for the target.

```
./src/dosarray_stop_containers.sh
./src/dosarray_delete_containers.sh
```

Along with container deletion, DoSArray also supports host-based logging. After deleting the containers, these logs are copied out of the hosts into ` ${DOSARRAY_SCRIPT_DIR}/host_logs/`to detect issues with deletion, if any.

## Load graphing
Load data is gathered automatically during experiments, for offline analysis and graphing. These logs and their corresponding graphs can be accessed within the results dorectory after the experiment has ended. The graphing scripts are flexible enough to produce diiferent types of graphs for different sampling intervals. To manually generate these graphs using the various load measurements, we must first generate the graph data and then use this data to plot the graphs.

To generate graphing data, the following script is invoked with parameters for logfile directory, load measurement duration, load type, chart type and list of machines (host names). Based on the parameter to '-t' option (eg. load), this script collects the corresponding logs (\*\_load.log) from the specified directory and outputs the plot data. It also accepts command-line parameters for the sampling intervals and order of the physical hosts on the graph.
```
python generate_load_chart.py -p testdata/1 -i 5 -t load -o column -m dedos01 dedos02 dedos03 dedos04 dedos05 dedos06 dedos07 dedos08 > load.data
```

The generated data files are input to the graphing script along with the measurement type (load, net, mem) followed by a colon seperated list of machines (host names). The order of physical host names provided to '-m' option must be the same used to generate plot data to maintain consistent results.
```
./dosarray_graphing_load.sh -i load.data -o load.pdf -t load -m dedos01:dedos02:dedos03:dedos04:dedos05:dedos06:dedos07:dedos08
```

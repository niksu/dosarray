# Troubleshoot Checklist

If DoSarray doesn't work then try running the  [configuration
checker](../src/dosarray_check_hosts.sh) for an [informative
break-down](dosarray_check_hosts.png) of checks.
The script's output can be made more detailed by tweaking
it as described in the [FAQ](FAQ.md).

For more in-depth troubleshooting try the following:

1. Has DoSarray worked previously on this setup? If not then make sure you've followed our [setup instructions](SETUP.md) and that the [target](TARGET.md) has been started.
2. Is the host network configured correctly?
3. Is docker running?
Run `service docker status`
4. Is the image installed?
Run `docker images`.
For example, on one of the clusters DoSarray was installed upon docker images disappeared. The cluster is shared, and one cannot always account for what other users get up to.
5. Is the container network configured correctly?
Run `ifconfig` and look for `docker_bridge`.
Make sure you've run the `dosarray_configure_networking.sh` script.
This script must also be run against physical machines that don't run docker (e.g., running the targets) otherwise they won't be able to send packets back to the DoSarray containers.
6. Are the containers created & started?
Run `docker ps`
7. Are the containers interacting over the network with each other?
Try sending packets from inside to outside and vice versa.
For example, use `tcpdump` and `ping` within a container. See the [setup advice](SETUP.md#manual-running) on how to run commands in containers.

Finally, look for clues in the DoSarray stdout and stderr logs, and the raw logs.

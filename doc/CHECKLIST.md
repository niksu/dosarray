# Troubleshoot Checklist

Try the following when DoSarray doesn't work.

1. Has DoSarray worked previously on this setup? If not then make sure you've followed our [setup instructions](doc/SETUP.md) and that the [target](doc/TARGET.md) has been started.
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
For example, use `tcpdump` and `ping` within a container. See the [setup advice](https://github.com/niksu/dosarray/blob/master/doc/SETUP.md#manual-running) on how to run commands in containers.


Finally, look for clues in the DoSarray stdout and stderr logs, and the raw logs.

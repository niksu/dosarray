# FAQ

1. I run a cluster. Can I exclude DoSarray from running on some machines?

Yes. Remove those machines from the appropriate fields in
[dosarray_config.sh](../config/dosarray_config.sh), then restart images
(`src/dosarray_stop_containers.sh` then `src/dosarray_delete_containers.sh`,
followed by `src/dosarray_create_containers.sh` then
`src/dosarray_start_containers.sh`), then `sudo service docker stop` on the
affected machines if DoSarray is the only Docker-using system that's running
on those machines.

2. My servers have single NICs and they're assigned public IP addresses. Do I need a separate NIC to set up the private network between them for DoSarray?

No. You can assign additional IPs to that NIC. On Ubuntu this would be done as follows:
```
$ sudo vim /etc/network/interfaces
```
Let's say your NIC is called `eno49`. Then make an entry aliasing that NIC but providing a new address on a fresh network to be used for (physical) hosts using DoSarray.
```
auto eno49:1
iface eno49:1 inet static
address 192.168.0.1
netmask 255.255.255.0
```
Save your changes and restart the interface:
```
/etc/init.d/networking restart
```
And you should see the new interface:
```
$ ifconfig
...
eno49:1   Link encap:Ethernet  HWaddr XX:XX:XX:XX:XX:XX
          inet addr:192.168.0.1  Bcast:192.168.0.255  Mask:255.255.255.0
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
...
```

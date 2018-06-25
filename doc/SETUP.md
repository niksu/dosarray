## Prerequisites
* GNU bash (tested with version 3.2.57)
* Python3
* sudo privileges in the physical hosts
* docker service in the physical hosts
* gnuplot with pdf terminal support (install using --with-cairo option)
* bc

## Installing Docker
Docker is installed on each _host_ in the _network_ to create
a cluster of _containers_ on that host, and _bridge_ them to
the physical network. The host has an _interface_ (usually *em3*)
through which it is connected to the other hosts in the
*192.168.0.0/24* network. Containers in the host form another
network 192.168.N.0/24 (where 192.168.0.N is the address of
the host).

To install Docker, follow the instructions [on installing Docker CE](https://docs.docker.com/engine/installation/linux/docker-ce/ubuntu/#install-using-the-repository). After installing Docker:
```
sudo docker info
sudo usermod -aG docker USERID # where USERID is your username
docker run hello-world
```

## Configuring Docker
```
docker network create --subnet SUBNET \
   --driver bridge \
   --attachable \
   --opt com.docker.network.bridge.name=docker_bridge \
   --opt com.docker.network.bridge.enable_icc=true \
   --opt com.docker.network.bridge.enable_ip_masquerade=true \
   --opt com.docker.network.bridge.host_binding_ipv4=0.0.0.0 \
   --opt com.docker.network.driver.mtu=1500 \
   docker_bridge
```
where SUBNET is of the form `192.168.9.0/24`

## Manual running
### Start containers
```
docker run -dti --name NAME --net=docker_bridge --ip=IP ubuntu:14.04
```
where IP is of the form `192.168.NAME` and NAME is of the form `8.2`.
Then use `docker attach 8.2` when you want to poke around it (remember to
detach it with CTRL-p+CTRL-q, you might need to `docker start 8.2` first
otherwise).

Using our image saves time installing stuff. Run this in `client_image`:
```
docker build -t dosarray_image .
```
Instead of building the image each time we can load a saved built image:
```
docker load -i dosarray_image.tar
```
after having saved the image:
```
docker save -o dosarray_image.tar dosarray_image
```
If you change the image, remember to update the `DOSARRAY_IMAGE`
variable in `dosarray_config.sh`.

Run commands in containers by using this syntax:
```
docker exec 3.3 ping 192.168.8.1 # ran on 192.168.0.3 aka dedos2
```

### Update host's networking
Check current config with `sudo iptables -L -t nat` and then I modified as follows:
```
sudo iptables -t nat -D POSTROUTING -s SUBNET ! -o docker_bridge -j MASQUERADE
```
where SUBNET is of the form `192.168.9.0/24`.
Checke base config with `sudo iptables -S`, and if have `-P FORWARD DROP` then run:
```
sudo iptables -D FORWARD -o docker_bridge -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
sudo iptables -A FORWARD -o docker_bridge -j ACCEPT
```

### Update routing for other hosts in the network
```
sudo route add -net NETWORK netmask 255.255.255.0 gw GATEWAY
```
where NETWORK is of the form `192.168.9.0`,
and GATEWAY `192.168.0.9`

This step and the previous one can be done at one by go using the script `dosarray_configure_networking.sh`.

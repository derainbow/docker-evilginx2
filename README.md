# Docker container for running Evilginx2

[Evilginx2](https://github.com/kgretzky/evilginx2) - Standalone man-in-the-middle attack framework used for phishing login credentials along with session cookies, allowing for the bypass of 2-factor authentication protection.

***This container runs without any IOCs or Evilginx Eggs + custom IP blacklist to block access to vendor sandboxes (Original from [YCSM](https://github.com/infosecn1nja/ycsm/blob/master/maps/ip_blacklist.conf))***

## Usage

### modify_systemd_resolved for better autocert 
```shell
modify_systemd_resolved() {
    echo "Modifying systemd-resolved configuration..."
    sudo sed -i 's/#DNSStubListener=yes/DNSStubListener=no/' /etc/systemd/resolved.conf
    sudo systemctl restart systemd-resolved
}
```

### Start/Stop Evilginx2 container
```shell
docker run -it --name derainbow -p 443:443 -p 80:80 -p 53:53/udp evilginx2
```
or
```shell
docker run -it --name derainbow -p 443:443 -p 80:80 -p 53:53/udp evilginx2 /bin/bash
```

### Display Evilginx2 container logs

```shell
docker logs evilginx2
```

### Clean up unused images
```shell
docker image prune -f
```

### evilginx additonal command when running
```
-p Phishlets directory path
-t HTML redirector pages directory path
-debug Enable debug output
-developer Enable developer mode (generates self-signed certificates for all hostnames)
-c Configuration directory path
-v Show evilginx version
```

### Remove all containers + images (clean install)

```shell
./docker-evilginx2/clean.sh
```

### additional
### How to deattach from inside running container on tmux

```shell
Ctrl + P, lalu Ctrl + Q
```

###  How to reattach from existing running container
```shell
docker attach <container_id_or_name>
```

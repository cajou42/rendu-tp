# TP3 : Progressons vers le réseau d'infrastructure

## I. (mini)Architecture réseau

on créer la vm `router.tp3` : 

une ip dans chaque réseaux : 

```
[louis@bastion-ovh1fr network-scripts]$ ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
2: enp0s3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 08:00:27:77:21:c4 brd ff:ff:ff:ff:ff:ff
    inet 10.0.2.15/24 brd 10.0.2.255 scope global dynamic noprefixroute enp0s3
       valid_lft 86232sec preferred_lft 86232sec
    inet6 fe80::a00:27ff:fe77:21c4/64 scope link noprefixroute
       valid_lft forever preferred_lft forever
3: enp0s8: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 08:00:27:1f:15:13 brd ff:ff:ff:ff:ff:ff
    inet 10.3.0.62/26 brd 10.3.0.63 scope global noprefixroute enp0s8
       valid_lft forever preferred_lft forever
    inet6 fe80::a00:27ff:fe1f:1513/64 scope link noprefixroute
       valid_lft forever preferred_lft forever
4: enp0s9: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 08:00:27:ff:c3:59 brd ff:ff:ff:ff:ff:ff
    inet 10.3.0.254/25 brd 10.3.0.255 scope global noprefixroute enp0s9
       valid_lft forever preferred_lft forever
    inet6 fe80::a00:27ff:feff:c359/64 scope link
       valid_lft forever preferred_lft forever
5: enp0s10: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 08:00:27:6f:95:b9 brd ff:ff:ff:ff:ff:ff
    inet 10.3.0.78/28 brd 10.3.0.79 scope global noprefixroute enp0s10
       valid_lft forever preferred_lft forever
    inet6 fe80::a00:27ff:fe6f:95b9/64 scope link
       valid_lft forever preferred_lft forever
```

accès internet : 
```
[louis@bastion-ovh1fr network-scripts]$ ping 8.8.8.8
PING 8.8.8.8 (8.8.8.8) 56(84) bytes of data.
64 bytes from 8.8.8.8: icmp_seq=1 ttl=114 time=19.6 ms
64 bytes from 8.8.8.8: icmp_seq=2 ttl=114 time=18.7 ms
^C
--- 8.8.8.8 ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1003ms
rtt min/avg/max/mdev = 18.681/19.137/19.594/0.477 ms
```

résolution des noms : 
```
[louis@bastion-ovh1fr network-scripts]$ ping google.com
PING google.com (216.58.198.206) 56(84) bytes of data.
64 bytes from par10s27-in-f206.1e100.net (216.58.198.206): icmp_seq=1 ttl=114 time=20.5 ms
64 bytes from par10s27-in-f206.1e100.net (216.58.198.206): icmp_seq=2 ttl=114 time=19.2 ms
^C
--- google.com ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1002ms
rtt min/avg/max/mdev = 19.186/19.826/20.466/0.640 ms
```

nom du routeur : 
```
[louis@router ~]$ hostname
router.tp3
```

activation du routage : 
```
[louis@router ~]$ sudo firewall-cmd --list-all
[sudo] password for louis:
public (active)
  target: default
  icmp-block-inversion: no
  interfaces: enp0s10 enp0s3 enp0s8 enp0s9
  sources:
  services: cockpit dhcpv6-client ssh
  ports:
  protocols:
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
  rich rules:
[louis@router ~]$ sudo firewall-cmd --get-active-zone
public
  interfaces: enp0s10 enp0s3 enp0s8 enp0s9
[louis@router ~]$ sudo firewall-cmd --add-masquerade --zone=public
success
[louis@router ~]$ sudo firewall-cmd --add-masquerade --zone=public --permanent
success
```

## II. Services d'infra

configuration de dhcp sur dhcp.client1.tp3 : 

```
[louis@dhcp ~]$ sudo cat /etc/dhcp/dhcpd.conf
#
# DHCP Server Configuration file.
#   see /usr/share/doc/dhcp-server/dhcpd.conf.example
#   see dhcpd.conf(5) man page

default-lease-time 600;
max-lease-time 7200;
authoritative;
# specify network address and subnetmask
subnet 10.3.0.0 netmask 255.255.255.192 {
    # specify the range of lease IP address
    range dynamic-bootp 10.3.0.7 10.3.0.61;
    # specify broadcast address
    option broadcast-address 10.3.0.63;
    # specify gateway
    option routers 10.3.0.62;
    option domain-name-servers 1.1.1.1;
}
[louis@dhcp ~]$ sudo systemctl enable --now dhcpd
Created symlink /etc/systemd/system/multi-user.target.wants/dhcpd.service → /usr/lib/systemd/system/dhcpd.service.
[louis@dhcp ~]$ sudo firewall-cmd --runtime-to-permanent
success

[louis@dhcp ~]$ systemctl status NetworkManager
● NetworkManager.service - Network Manager
   Loaded: loaded (/usr/lib/systemd/system/NetworkManager.service; enabled;>
   Active: active (running) since Mon 2021-09-27 16:27:24 CEST; 6min ago
     Docs: man:NetworkManager(8)
 Main PID: 820 (NetworkManager)
    Tasks: 3 (limit: 4945)
   Memory: 9.9M
   CGroup: /system.slice/NetworkManager.service
           └─820 /usr/sbin/NetworkManager --no-daemon

Sep 27 16:27:25 dhcp.client1.tp3 NetworkManager[820]: <info>  [1632752845.4>
Sep 27 16:27:25 dhcp.client1.tp3 NetworkManager[820]: <info>  [1632752845.4>
Sep 27 16:27:25 dhcp.client1.tp3 NetworkManager[820]: <info>  [1632752845.4>
Sep 27 16:27:25 dhcp.client1.tp3 NetworkManager[820]: <info>  [1632752845.4>
Sep 27 16:27:25 dhcp.client1.tp3 NetworkManager[820]: <info>  [1632752845.4>
Sep 27 16:27:25 dhcp.client1.tp3 NetworkManager[820]: <info>  [1632752845.4>
Sep 27 16:27:25 dhcp.client1.tp3 NetworkManager[820]: <info>  [1632752845.4>
Sep 27 16:27:25 dhcp.client1.tp3 NetworkManager[820]: <info>  [1632752845.4>
Sep 27 16:27:25 dhcp.client1.tp3 NetworkManager[820]: <info>  [1632752845.4>
Sep 27 16:27:25 dhcp.client1.tp3 NetworkManager[820]: <info>  [1632752845.4>

```
on met le client marcel en dhcp : 
```
[louis@marcel network-scripts]$ cat ifcfg-enp0s8
TYPE=Ethernet
PROXY_METHOD=none
BROWSER_ONLY=no
BOOTPROTO=dhcp
DEFROUTE=yes
IPV4_FAILURE_FATAL=no
IPV6INIT=yes
IPV6_AUTOCONF=yes
IPV6_DEFROUTE=yes
IPV6_FAILURE_FATAL=no
NAME=enp0s8
UUID=c3c4080d-75a5-47d9-a6b3-2aa0d3dc705a
DEVICE=enp0s8
ONBOOT=yes
DNS=1.1.1.1
```
et on obtient la première ip disponible (soit 10.3.0.7) : 
```
[louis@marcel network-scripts]$ ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
2: enp0s8: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 08:00:27:dc:c8:90 brd ff:ff:ff:ff:ff:ff
    inet 10.3.0.7/26 brd 10.3.0.63 scope global dynamic noprefixroute enp0s8
       valid_lft 452sec preferred_lft 452sec
    inet6 fe80::a00:27ff:fedc:c890/64 scope link noprefixroute
       valid_lft forever preferred_lft forever
```
marcel possède donc internet ainsi que la résolution de nom : 
```
[louis@marcel ~]$ ping google.com
PING google.com (172.217.171.238) 56(84) bytes of data.
64 bytes from mrs09s07-in-f14.1e100.net (172.217.171.238): icmp_seq=1 ttl=111 time=26.0 ms
64 bytes from mrs09s07-in-f14.1e100.net (172.217.171.238): icmp_seq=2 ttl=111 time=26.0 ms
^C
--- google.com ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1003ms
rtt min/avg/max/mdev = 26.034/26.039/26.044/0.005 ms
[louis@marcel ~]$ ping 8.8.8.8
PING 8.8.8.8 (8.8.8.8) 56(84) bytes of data.
64 bytes from 8.8.8.8: icmp_seq=1 ttl=113 time=15.3 ms
64 bytes from 8.8.8.8: icmp_seq=2 ttl=113 time=18.2 ms
^C
--- 8.8.8.8 ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1028ms
rtt min/avg/max/mdev = 15.315/16.762/18.209/1.447 ms
```
marcel passe par le router pour aller sur internet : 
```
[louis@marcel ~]$ traceroute 8.8.8.8
traceroute to 8.8.8.8 (8.8.8.8), 30 hops max, 60 byte packets
 1  _gateway (10.3.0.62)  0.527 ms  0.570 ms  0.567 ms
 2  10.0.2.2 (10.0.2.2)  0.573 ms  0.563 ms  0.584 ms
 3  * * *
 4  * * *
 5  * * *
 6  * * *
 7  * * *
 8  *^C
```

## 2. Serveur DNS


### B. SETUP copain

on ajoute un dns connue à la machine : 
```
[louis@dns1 ~]$ sudo cat /etc/resolv.conf
# Generated by NetworkManager
search auvence.co
nameserver 1.1.1.1
```

on commence par installer les packages bind et bind-utils (`sudo dnf install -y bind bind-utils`)

on modifie le fichier de conf principal (uniquement parties modifiées ici) : 
```
[louis@dns1 ~]$ sudo cat /etc/named.conf
listen-on port 53 { any; };
 recursion no;
zone "server1.tp3" IN {
        type master;
        file "server1.tp3.forward";
        allow-update { none; };
        allow-query {any; };
};

zone "server2.tp3" IN {
        type master;
        file "server2.tp3.forward";
        allow-update { none; };
        allow-query {any; };
};
```
modification du fichier server1.tp3.forward : 
```
[louis@dns1 ~]$ sudo cat /var/named/server1.tp3.forward
$TTL 86400
@ IN SOA dns1.server1.tp3 root.server1.tp3. (
    2019061800 ;Serial
    3600 ;Refresh
    1800 ;Retry
    604800 ;Expire
    86400 ;Minimum TTL
)

;Name Server Information
@ IN NS dns1.server1.tp3.

;A Record for IP address to Hostname
dns1 IN A 10.3.0.130
router IN A 10.3.0.254
```

modification du fichier server2.tp3.forward :
```
[louis@dns1 ~]$ sudo cat /var/named/server2.tp3.forward
$TTL 86400
@ IN SOA dns1.server2.tp3 root.server2.tp3. (
    2019061800 ;Serial
    3600 ;Refresh
    1800 ;Retry
    604800 ;Expire
    86400 ;Minimum TTL
)

;Name Server Information
@ IN NS dns1.server1.tp3.

;A Record for IP address to Hostname
router IN A 10.3.0.78
```

le service est est actif : 
```
[louis@dns1 ~]$ systemctl status named.service
● named.service - Berkeley Internet Name Domain (DNS)
   Loaded: loaded (/usr/lib/systemd/system/named.service; disabled; vendor preset: disabled)
   Active: active (running) since Thu 2021-09-30 09:57:39 CEST; 25s ago
  Process: 1569 ExecStart=/usr/sbin/named -u named -c ${NAMEDCONF} $OPTIONS (code=exited, status=0/SUCCESS)
  Process: 1565 ExecStartPre=/bin/bash -c if [ ! "$DISABLE_ZONE_CHECKING" == "yes" ]; then /usr/sbin/named-checkconf -z>
 Main PID: 1571 (named)
    Tasks: 5 (limit: 4945)
   Memory: 59.0M
   CGroup: /system.slice/named.service
           └─1571 /usr/sbin/named -u named -c /etc/named.conf
```

on ouvre le port 53 en udp : 
```
[louis@dns1 ~]$ sudo firewall-cmd --add-port=53/udp --permanent
[sudo] password for louis:
success
```

test sur marcel : 
```
[louis@marcel ~]$ sudo cat /etc/sysconfig/network-scripts/ifcfg-enp0s8
DNS=10.3.0.130

[louis@marcel ~]$ dig dns1.server1.tp3 @10.3.0.130

; <<>> DiG 9.11.26-RedHat-9.11.26-4.el8_4 <<>> dns1.server1.tp3 @10.3.0.130
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 39170
;; flags: qr aa rd; QUERY: 1, ANSWER: 1, AUTHORITY: 1, ADDITIONAL: 1
;; WARNING: recursion requested but not available

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 1232
; COOKIE: da66f23392c2069158da968261557caa1ff8fa6ea4175783 (good)
;; QUESTION SECTION:
;dns1.server1.tp3.              IN      A

;; ANSWER SECTION:
dns1.server1.tp3.       86400   IN      A       10.3.0.130

;; AUTHORITY SECTION:
server1.tp3.            86400   IN      NS      dns1.server1.tp3.

;; Query time: 2 msec
;; SERVER: 10.3.0.130#53(10.3.0.130)
;; WHEN: Thu Sep 30 10:54:45 CEST 2021
;; MSG SIZE  rcvd: 103
```


## 3. Get deeper

### A. DNS forwarder

on active la clause `recursion` :
```
recursion yes;
```

on teste depuis marcel : 
```
[louis@marcel ~]$ dig google.com @10.3.0.130

; <<>> DiG 9.11.26-RedHat-9.11.26-4.el8_4 <<>> google.com @10.3.0.130
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 47335
;; flags: qr rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 4, ADDITIONAL: 9

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 1232
; COOKIE: 895ebc2fe7b9b06b8f2018b561558e61c3a2eed43615b0b1 (good)
;; QUESTION SECTION:
;google.com.                    IN      A

;; ANSWER SECTION:
google.com.             300     IN      A       172.217.18.206

;; AUTHORITY SECTION:
google.com.             172799  IN      NS      ns2.google.com.
google.com.             172799  IN      NS      ns4.google.com.
google.com.             172799  IN      NS      ns3.google.com.
google.com.             172799  IN      NS      ns1.google.com.

;; ADDITIONAL SECTION:
ns2.google.com.         172799  IN      A       216.239.34.10
ns1.google.com.         172799  IN      A       216.239.32.10
ns3.google.com.         172799  IN      A       216.239.36.10
ns4.google.com.         172799  IN      A       216.239.38.10
ns2.google.com.         172799  IN      AAAA    2001:4860:4802:34::a
ns1.google.com.         172799  IN      AAAA    2001:4860:4802:32::a
ns3.google.com.         172799  IN      AAAA    2001:4860:4802:36::a
ns4.google.com.         172799  IN      AAAA    2001:4860:4802:38::a

;; Query time: 921 msec
;; SERVER: 10.3.0.130#53(10.3.0.130)
;; WHEN: Thu Sep 30 12:09:46 CEST 2021
;; MSG SIZE  rcvd: 331
```

### B. On revient sur la conf du DHCP

on créer la vm johnny.client1.tp3

dans le serveur dhcp on modifie le DNS : 
```
option domain-name-servers 10.3.0.130;
```

le client johnny récupère toutes les nouvelle infos via le dhcp : 
```
[louis@johnny ~]$ ip a
2: enp0s8: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 08:00:27:65:b1:76 brd ff:ff:ff:ff:ff:ff
    inet 10.3.0.8/26 brd 10.3.0.63 scope global dynamic noprefixroute enp0s8
       valid_lft 579sec preferred_lft 579sec
    inet6 fe80::a00:27ff:fe65:b176/64 scope link noprefixroute
       valid_lft forever preferred_lft forever

[louis@johnny ~]$ cat /etc/resolv.conf
# Generated by NetworkManager
search client1.tp3
nameserver 10.3.0.130

[louis@johnny ~]$ dig ynov.com @10.3.0.130

; <<>> DiG 9.11.26-RedHat-9.11.26-4.el8_4 <<>> ynov.com @10.3.0.130
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 34506
;; flags: qr rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 3, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 1232
; COOKIE: 709e89f12fe5e9019a7f514e615705d7aec0f13dbd9e1d5d (good)
;; QUESTION SECTION:
;ynov.com.                      IN      A

;; ANSWER SECTION:
ynov.com.               10800   IN      A       92.243.16.143

;; AUTHORITY SECTION:
ynov.com.               172799  IN      NS      ns-78-c.gandi.net.
ynov.com.               172799  IN      NS      ns-177-a.gandi.net.
ynov.com.               172799  IN      NS      ns-111-b.gandi.net.

;; Query time: 410 msec
;; SERVER: 10.3.0.130#53(10.3.0.130)
;; WHEN: Fri Oct 01 14:57:59 CEST 2021
;; MSG SIZE  rcvd: 158
```

## III. Services métier

### 1. Serveur Web

on configure la vm web1.server2.tp3 et ouvre le port 80 pour nginx : 
```
[louis@web1 ~]$ sudo cat /etc/nginx/nginx.conf
listen       80 default_server;
listen       [::]:80 default_server;

[louis@web1 ~]$ sudo firewall-cmd --add-port=80/tcp --permanent
success
[louis@web1 ~]$ sudo firewall-cmd --reload
success
[louis@web1 ~]$ sudo systemctl start nginx
[louis@web1 ~]$ sudo systemctl enable nginx
Created symlink /etc/systemd/system/multi-user.target.wants/nginx.service → /usr/lib/systemd/system/nginx.service.
[louis@web1 ~]$ sudo ss -l -p -n -t
State           Recv-Q          Send-Q                   Local Address:Port                   Peer Address:Port
Process
LISTEN          0               128                            0.0.0.0:80                          0.0.0.0:*
 users:(("nginx",pid=16231,fd=8),("nginx",pid=16230,fd=8),("nginx",pid=16229,fd=8))
LISTEN          0               128                            0.0.0.0:22                          0.0.0.0:*
 users:(("sshd",pid=830,fd=5))
LISTEN          0               128                               [::]:80                             [::]:*
 users:(("nginx",pid=16231,fd=9),("nginx",pid=16230,fd=9),("nginx",pid=16229,fd=9))
LISTEN          0               128                               [::]:22                             [::]:*
 users:(("sshd",pid=830,fd=7))
```

on effectue une requête depuis marcel : 
```
[louis@marcel ~]$ curl web1.server2.tp3 | grep html
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  3429  100  3429    0     0   209k      0 --:--:-- --:--:-- --:--:--  223k
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en">
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
            This is the default <tt>index.html</tt> page that is distributed
            <tt>/usr/share/nginx/html</tt>.
</html>
```

### 2. Partage de fichiers


#### B. Le setup wola

on configure la vm nfs1.server2.tp3;

on installe le serveur nfs avec `sudo dnf -y install nfs-utils` et on change la configuration dans `/etc/idmapd.conf` : 
```
[louis@nfs1 ~]$ sudo cat /etc/idmapd.conf
Domain = server2.tp3
```
on s'occupe du fichier `/etc/exports` : 
```
[louis@nfs1 ~]$ sudo cat /etc/exports
/srv/nfs_share/ 10.3.0.64/28(rw,no_root_squash)
```
on créer le fichier `/srv/nfs_share/` et on démare le service : 
```
[louis@nfs1 ~]$ sudo mkdir /srv/nfs_share/
[louis@nfs1 ~]$ systemctl enable --now rpcbind nfs-server
==== AUTHENTICATING FOR org.freedesktop.systemd1.manage-unit-files ====
Authentication is required to manage system service or unit files.
Authenticating as: louis
Password:
==== AUTHENTICATION COMPLETE ====
Created symlink /etc/systemd/system/multi-user.target.wants/nfs-server.service → /usr/lib/systemd/system/nfs-server.service.
==== AUTHENTICATING FOR org.freedesktop.systemd1.reload-daemon ====
Authentication is required to reload the systemd state.
Authenticating as: louis
Password:
==== AUTHENTICATION COMPLETE ====
==== AUTHENTICATING FOR org.freedesktop.systemd1.manage-units ====
Authentication is required to start 'rpcbind.service'.
Authenticating as: louis
Password:
==== AUTHENTICATION COMPLETE ====
==== AUTHENTICATING FOR org.freedesktop.systemd1.manage-units ====
Authentication is required to start 'nfs-server.service'.
Authenticating as: louis
Password:
==== AUTHENTICATION COMPLETE ====

[louis@nfs1 ~]$ systemctl status nfs-server
● nfs-server.service - NFS server and services
   Loaded: loaded (/usr/lib/systemd/system/nfs-server.service; enabled; vendor preset: disabled)
  Drop-In: /run/systemd/generator/nfs-server.service.d
           └─order-with-mounts.conf
   Active: active (exited) since Mon 2021-10-04 11:57:20 CEST; 30s ago
  Process: 2496 ExecStart=/bin/sh -c if systemctl -q is-active gssproxy; then systemctl reload gssproxy ; fi (code=exit>
  Process: 2484 ExecStart=/usr/sbin/rpc.nfsd (code=exited, status=0/SUCCESS)
  Process: 2482 ExecStartPre=/usr/sbin/exportfs -r (code=exited, status=0/SUCCESS)
 Main PID: 2496 (code=exited, status=0/SUCCESS)

Oct 04 11:57:20 nfs1.server2.tp3 systemd[1]: Starting NFS server and services...
Oct 04 11:57:20 nfs1.server2.tp3 systemd[1]: Started NFS server and services.
```

on modifie les paramètre firewall : 
```
[louis@nfs1 ~]$ sudo firewall-cmd --add-service=nfs
[sudo] password for louis:
success
[louis@nfs1 ~]$ sudo firewall-cmd --add-service={nfs3,mountd,rpc-bind}
success
[louis@nfs1 ~]$ sudo firewall-cmd --runtime-to-permanent
success
[louis@nfs1 ~]$ sudo firewall-cmd --reload
success
```

on s'attaque au montage sur web1 : 
```
[louis@web1 ~]$ sudo cat /etc/idmapd.conf
Domain = server2.tp3

[louis@web1 srv]$ sudo mkdir nfs
[louis@web1 srv]$ ls
nfs

[louis@web1 ~]$ sudo mount -t nfs nfs1.server2.tp3:/srv/nfs_share/ /srv/nfs/

[louis@web1 ~]$ df -hT
nfs1.server2.tp3:/srv/nfs_share nfs4      6.2G  2.2G  4.1G  35% /srv/nfs
```

on teste côté web1 : 
```
[louis@web1 ~]$ cd /srv/nfs/
[louis@web1 nfs]$ ls
[louis@web1 nfs]$ sudo touch alu
[louis@web1 nfs]$ ls
alu
```

et on ça côté nfs1 : 
```
[louis@nfs1 ~]$ cd /srv/nfs_share/
[louis@nfs1 nfs_share]$ ls
alu
```

## IV. Un peu de théorie : TCP et UDP

dans le cas du ssh, on peut voir que ce dernier est suivis d'un protocole tcp, ce qui permet de sécurisé la connection à distance.

pour le html on observe qu'il est encapsulé dans du tcp, pareil, cela permet au partage web d'être sécurisé

le dns quand à lui est encapsulé dans de l'udp afin d'avoir un réponse plus rapide de ce dernier

comme les autre partage, le nfs est en tcp pour les mêmes raisons

on peut mettre en évidence un *3-way handshake* avec un simple requête http (`curl google.com`) : 

| protocol           | Adresse IP source    |Adresse IP destination|       ACK/SYN        |
|--------------------|----------------------|----------------------|----------------------|
|  tcp               | `10.3.0.50/26`       | `142.250.74.238`     |  SYN                 |
|  tcp               | `142.250.74.238`     | `10.3.0.50/26`       |  SYN , ACK           |
|  tcp               | `10.3.0.50/26`       | `142.250.74.238`     |  ACK                 |

## V. El final


tableau des réseaux : 


| Nom du réseau | Adresse du réseau | Masque          | Nombre de clients possibles | Adresse passerelle | Adresse broadcast |
|---------------|-------------------|-----------------|-----------------------------|--------------------|-------------------|
| `client1`     | `10.3.0.0`        |`255.255.255.192`| 62                          | `10.3.0.62`        | `10.3.0.63`       |
| `server1`     | `10.3.0.128`      |`255.255.255.128`| 126                         | `10.3.0.254`       | `10.3.0.255`      |
| `server2`     | `10.3.0.64`       |`255.255.255.240`| 14                          | `10.3.0.78`        | `10.3.0.79`       |

tableau d'adressage : 

| Nom machine        | Adresse IP `client1` | Adresse IP `server1` | Adresse IP `server2` | Adresse de passerelle |
|--------------------|----------------------|----------------------|----------------------|-----------------------|
| `router.tp3`       | `10.3.0.62/26`       | `10.3.0.254/25`      | `10.3.0.78/28`       | Carte NAT             |
|`dhcp.client1.tp3`  | `10.3.0.2/26`        |          X           |          X           | `10.3.0.62/26`        |
|`marcel.client1.tp3`|  DHCP                |          X           |          X           | `10.3.0.62/26`        |
|`dns1.server1.tp3`  |          X           | `10.3.0.130/25`      |          X           | `10.3.0.254/25`       |
|`johnny.client1.tp3`|  DHCP                |          X           |          X           | `10.3.0.62/26`        |
|`web1.server2.tp3`  |          X           |          X           | `10.3.0.66/28`       | `10.3.0.78/26`        |
|`nfs1.server2.tp3`  |          X           |          X           | `10.3.0.67/28`       | `10.3.0.78/26`        |

schéma du réseau : 

![Image](https://github.com/cajou42/rendu-tp/blob/main/reseau/tp3/supplements/r%C3%A9seau2%20Diagram.drawio.png)

fichier de conf supplémentaire : 

[named.conf](https://github.com/cajou42/rendu-tp/blob/main/reseau/tp3/supplements/named.conf)

[forward server1](https://github.com/cajou42/rendu-tp/blob/main/reseau/tp3/supplements/server1.tp3.forward)

[forward server2](https://github.com/cajou42/rendu-tp/blob/main/reseau/tp3/supplements/server2.tp3.forward)

[tp3_http.pcap](https://github.com/cajou42/rendu-tp/blob/main/reseau/tp3/supplements/tp3_http.pcap)

[tp3_ssh.pcap](https://github.com/cajou42/rendu-tp/blob/main/reseau/tp3/supplements/tp3_ssh.pcap)

[tp3_dns.pcap](https://github.com/cajou42/rendu-tp/blob/main/reseau/tp3/supplements/tp3_dns.pcap)

[tp3_nfs.pcap](https://github.com/cajou42/rendu-tp/blob/main/reseau/tp3/supplements/tp3_nfs.pcap)

[tp3_3way.pcap](https://github.com/cajou42/rendu-tp/blob/main/reseau/tp3/supplements/tp3_3way.pcap)

# TP2 : On va router des trucs


## I. ARP

### 1. Echange ARP

ping de node1 vers node2 : 

```
[louis@node1 ~]$ ping 10.2.1.12
PING 10.2.1.12 (10.2.1.12) 56(84) bytes of data.
64 bytes from 10.2.1.12: icmp_seq=1 ttl=64 time=1.09 ms
64 bytes from 10.2.1.12: icmp_seq=2 ttl=64 time=0.830 ms
64 bytes from 10.2.1.12: icmp_seq=3 ttl=64 time=0.867 ms
64 bytes from 10.2.1.12: icmp_seq=4 ttl=64 time=0.841 ms
^C
--- 10.2.1.12 ping statistics ---
4 packets transmitted, 4 received, 0% packet loss, time 3104ms
rtt min/avg/max/mdev = 0.830/0.906/1.086/0.104 ms
```

on affiche les tables arp : 

node 1 : 
```
[louis@node1 ~]$ ip neigh show
10.2.1.12 dev enp0s8 lladdr 08:00:27:7e:d9:34 STALE
10.2.1.1 dev enp0s8 lladdr 0a:00:27:00:00:48 DELAY
```
mac node 2 : 08:00:27:7e:d9:34

node 2 : 
```
[louis@node2 ~]$ ip neigh show
10.2.1.1 dev enp0s8 lladdr 0a:00:27:00:00:48 DELAY
10.2.1.11 dev enp0s8 lladdr 08:00:27:ce:9a:cd STALE
```
mac node 1 : 08:00:27:ce:9a:cd

avec `ip neigh show` on voit la mac de node2 depuis node1, on peut confirmer que c'est bien la mac de node2 avec `ip a`depuis cette dernière : 

l'adresse mac est entre les flèches, on peut voir qu'elle coincidence avec ce qui est dans la table arp.
```
3: enp0s8: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether ▶08:00:27:7e:d9:34◀ brd ff:ff:ff:ff:ff:ff
    inet 10.2.1.12/24 brd 10.2.1.255 scope global noprefixroute enp0s8
       valid_lft forever preferred_lft forever
    inet6 fe80::a00:27ff:fe7e:d934/64 scope link noprefixroute
       valid_lft forever preferred_lft forever
```

### 2. Analyse de trames

utilisation de `tcpdump` sur 10 trames : 
```
[louis@node2 ~]$ sudo tcpdump -i enp0s8 -c 10
dropped privs to tcpdump
tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on enp0s8, link-type EN10MB (Ethernet), capture size 262144 bytes
12:38:39.601452 IP node2.net1.tp2.ssh > 10.2.1.1.25735: Flags [P.], seq 208728813:208729033, ack 2825382108, win 295, length 220
12:38:39.601785 IP 10.2.1.1.25735 > node2.net1.tp2.ssh: Flags [.], ack 220, win 8207, length 0
12:38:39.608603 IP node2.net1.tp2.ssh > 10.2.1.1.25735: Flags [P.], seq 220:480, ack 1, win 295, length 260
12:38:39.608869 IP node2.net1.tp2.ssh > 10.2.1.1.25735: Flags [P.], seq 480:628, ack 1, win 295, length 148
12:38:39.609094 IP 10.2.1.1.25735 > node2.net1.tp2.ssh: Flags [.], ack 628, win 8212, length 0
12:38:39.609112 IP node2.net1.tp2.ssh > 10.2.1.1.25735: Flags [P.], seq 628:776, ack 1, win 295, length 148
12:38:39.609198 IP node2.net1.tp2.ssh > 10.2.1.1.25735: Flags [P.], seq 776:1020, ack 1, win 295, length 244
12:38:39.609248 IP 10.2.1.1.25735 > node2.net1.tp2.ssh: Flags [.], ack 1020, win 8210, length 0
12:38:39.609275 IP node2.net1.tp2.ssh > 10.2.1.1.25735: Flags [P.], seq 1020:1168, ack 1, win 295, length 148
12:38:39.609329 IP node2.net1.tp2.ssh > 10.2.1.1.25735: Flags [P.], seq 1168:1412, ack 1, win 295, length 244
10 packets captured
11 packets received by filter
0 packets dropped by kernel
```
on vide les tables arp avec `sudo ip neigh flush all` : 

```
[louis@node1 ~]$ sudo ip neigh flush all
[sudo] password for louis:
[louis@node1 ~]$ ip neigh show
10.2.1.1 dev enp0s8 lladdr 0a:00:27:00:00:48 REACHABLE
```
on enregistre la trame avec `[louis@node2 ~]$ sudo tcpdump -i enp0s8 -c 10 -w tp2_arp.pcap`



| ordre | type trame  | source                   | destination                |
|-------|-------------|--------------------------|----------------------------|
| 1     | Requête SSH |       `10.2.1.12`        |         `10.2.1.1`         |
| 2     | Réponse TCP |        `10.2.1.1`        |        `10.2.1.12`         |
| 3     | Requête ICMP|       `10.2.1.11`        |       `10.2.1.12`          |
| 4     | Requête ICMP|       `10.2.1.12`        |       `10.2.1.11`          |
| 5     | Requête ICMP|       `10.2.1.11`        |       `10.2.1.12`          |
| 6     | Requête ICMP|       `10.2.1.12`        |       `10.2.1.11`          |
| 7     | Requête ARP |`node1``08:00:27:ce:9a:cd`|`node2``08:00:27:7e:d9:34`  |
| 8     | Requête ARP |`node2``08:00:27:7e:d9:34`|`node1``08:00:27:ce:9a:cd`  |
| 9     | Requête ARP |`node2``08:00:27:7e:d9:34`|`node1``08:00:27:ce:9a:cd`  |
| 10    | Requête ARP |`node1``08:00:27:ce:9a:cd`|`node2``08:00:27:7e:d9:34`  |

## II. Routage

### 1. Mise en place du routage

on active le routage sur router : 
```
[louis@router ~]$ sudo firewall-cmd --list-all
[sudo] password for louis:
public (active)
  target: default
  icmp-block-inversion: no
  interfaces: enp0s3 enp0s8 enp0s9
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
  interfaces: enp0s3 enp0s8 enp0s9
  [louis@router ~]$ sudo firewall-cmd --add-masquerade --zone=public
success
[louis@router ~]$ sudo firewall-cmd --add-masquerade --zone=public --permanent
success
```

ajout des route statique sur node 1 ey marcel : 

node 1 : 
```
[louis@node1 network-scripts]$ sudo ip route add 10.2.2.0/24 via 10.2.1.11 d
ev enp0s8
[louis@node1 network-scripts]$ sudo vim /etc/sysconfig/network-scripts/route-enp0s8
🔽
10.2.2.0/24 via 10.2.1.11 dev enp0s8
[louis@node1 network-scripts]$ ping 10.2.2.12
PING 10.2.2.12 (10.2.2.12) 56(84) bytes of data.
64 bytes from 10.2.2.12: icmp_seq=1 ttl=63 time=1.11 ms
64 bytes from 10.2.2.12: icmp_seq=2 ttl=63 time=1.56 ms
^C
--- 10.2.2.12 ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1007ms
rtt min/avg/max/mdev = 1.111/1.337/1.564/0.229 ms
```

marcel : 
```
[louis@marcel network-scripts]$ sudo ip route add 10.2.1.0/24 via 10.2.2.11
dev enp0s8
[louis@marcel network-scripts]$ sudo vim /etc/sysconfig/network-scripts/route-enp0s8
🔽
10.2.1.0/24 via 10.2.2.11 dev enp0s8
[louis@marcel network-scripts]$ ping 10.2.1.11
PING 10.2.1.11 (10.2.1.11) 56(84) bytes of data.
64 bytes from 10.2.1.11: icmp_seq=1 ttl=64 time=0.657 ms
64 bytes from 10.2.1.11: icmp_seq=2 ttl=64 time=0.861 ms
^C
--- 10.2.1.11 ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1006ms
rtt min/avg/max/mdev = 0.657/0.759/0.861/0.102 ms
```

### 2. Analyse de trames

on vide les tables arp avec `sudo ip neigh flush all` et on refait un ping de node 1 vers marcel, puis on affiche les tables arp

node 1 : 
```
[louis@node1 network-scripts]$ ip neigh show
10.2.1.1 dev enp0s8 lladdr 0a:00:27:00:00:48 DELAY
10.2.1.11 dev enp0s8 lladdr 08:00:27:ba:77:b2 STALE
```

marcel : 
```
[louis@marcel network-scripts]$ ip neigh show
10.2.2.1 dev enp0s8 lladdr 0a:00:27:00:00:52 DELAY
10.2.2.11 dev enp0s8 lladdr 08:00:27:f4:3e:d3 STALE
```

router : 
```
10.2.1.12 dev enp0s8 lladdr 08:00:27:ce:9a:cd STALE
10.2.1.1 dev enp0s8 lladdr 0a:00:27:00:00:48 DELAY
10.0.2.2 dev enp0s3 lladdr 52:54:00:12:35:02 REACHABLE
10.2.2.12 dev enp0s9 lladdr 08:00:27:6a:01:c2 STALE
```
pour effectuer le ping, on peut voir que node 1 passe par router pour que ce dernier puisse envoyer le message vers marcel

on lance la capture avec`sudo tcpdump -i enp0s8 -w mon_fichier.pcap`

on revide et on reping : 

Par exemple (copiez-collez ce tableau ce sera le plus simple) :

| ordre | type trame  | IP source | MAC source                | IP destination | MAC destination            |
|-------|-------------|-----------|---------------------------|----------------|----------------------------|
| 1     | Requête ARP | X         |`node1` `08:00:27:ce:9a:cd`| x              | Broadcast `FF:FF:FF:FF:FF` |
| 2     | Réponse ARP | X         |`router``08:00:27:ba:77:b2`| x              | `node1` `08:00:27:ce:9a:cd`|
| 3     | Requête ARP | X         |`router``08:00:27:f4:3e:d3`| x              | Broadcast `FF:FF:FF:FF:FF` |
| 4     | Réponse ARP | X         |`marcel``08:00:27:6a:01:c2`| x              |`router``08:00:27:f4:3e:d3` |
| 5     | Ping        | 10.2.1.12 |`node1` `08:00:27:ce:9a:cd`| 10.2.2.12      |`marcel``08:00:27:6a:01:c2` |
| 6     | Pong        | 10.2.2.12 |`marcel``08:00:27:6a:01:c2`| 10.2.1.12      |`node1` `08:00:27:ce:9a:cd` |


### 3. Accès internet

on ajoute les routes par defaut pour node 1 et marcel et on ping 8.8.8.8 :

node 1 : 
```
[louis@node1 ~]$ sudo ip route add default via 10.2.1.11 dev enp0s8
sudo vim /etc/sysconfig/network
🔽
GATEWAY=10.2.1.11
[louis@node1 ~]$ ping 8.8.8.8
PING 8.8.8.8 (8.8.8.8) 56(84) bytes of data.
64 bytes from 8.8.8.8: icmp_seq=1 ttl=113 time=19.3 ms
64 bytes from 8.8.8.8: icmp_seq=2 ttl=113 time=19.1 ms
^C
--- 8.8.8.8 ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1074ms
rtt min/avg/max/mdev = 19.051/19.165/19.280/0.179 ms
```

marcel : 
```
[louis@marcel ~]$ sudo ip route add default via 10.2.2.11 dev enp0s8
[louis@marcel ~]$ sudo cat /etc/sysconfig/network
GATEWAY=10.2.2.11
[louis@marcel ~]$ ping 8.8.8.8
PING 8.8.8.8 (8.8.8.8) 56(84) bytes of data.
64 bytes from 8.8.8.8: icmp_seq=1 ttl=113 time=19.5 ms
64 bytes from 8.8.8.8: icmp_seq=2 ttl=113 time=21.1 ms
^C
--- 8.8.8.8 ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1058ms
rtt min/avg/max/mdev = 19.510/20.325/21.141/0.827 ms
```

utilisation du DNS 1.1.1.1 pour les deux vm : 

node 1 : 
```
[louis@node1 ~]$ sudo cat /etc/resolv.conf
# Generated by NetworkManager
search lan net1.tp2
nameserver 1.1.1.1

[louis@node1 ~]$ dig ynov.com

; <<>> DiG 9.11.26-RedHat-9.11.26-4.el8_4 <<>> ynov.com
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 20866
;; flags: qr rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 1232
;; QUESTION SECTION:
;ynov.com.                      IN      A

;; ANSWER SECTION:
ynov.com.               2476    IN      A       92.243.16.143

;; Query time: 22 msec
;; SERVER: 1.1.1.1#53(1.1.1.1)
;; WHEN: Thu Sep 23 11:51:22 CEST 2021
;; MSG SIZE  rcvd: 53
```

marcel : 
```
[louis@marcel ~]$ sudo cat /etc/resolv.conf
# Generated by NetworkManager
search lan
nameserver 1.1.1.1
[louis@marcel ~]$ dig ynov.com

; <<>> DiG 9.11.26-RedHat-9.11.26-4.el8_4 <<>> ynov.com
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 16246
;; flags: qr rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 1232
;; QUESTION SECTION:
;ynov.com.                      IN      A

;; ANSWER SECTION:
ynov.com.               9293    IN      A       92.243.16.143

;; Query time: 94 msec
;; SERVER: 1.1.1.1#53(1.1.1.1)
;; WHEN: Thu Sep 23 11:54:44 CEST 2021
;; MSG SIZE  rcvd: 53
```

dans les deux cas on voit que le serveur dans la "answer section" est bien 1.1.1.1

| ordre | type trame | IP source           | MAC source                | IP destination   | MAC destination           |
|-------|------------|---------------------|---------------------------|------------------|---------------------------|
| 1     | ping       | `node1` `10.2.1.12` |`node1` `08:00:27:ce:9a:cd`| `8.8.8.8`        |`router``08:00:27:ba:77:b2`|
| 2     | pong       | `8.8.8.8`           |`router``08:00:27:ba:77:b2`|`node1``10.2.1.12`|`node1` `08:00:27:ce:9a:cd`|

## III. DHCP

configuration du serveur dhcp sur node 1 avec `sudo dnf -y install dhcp-server` : 

```
[louis@node1 ~]$ sudo cat /etc/dhcp/dhcpd.conf
[sudo] password for louis:
#
# DHCP Server Configuration file.
#   see /usr/share/doc/dhcp-server/dhcpd.conf.example
#   see dhcpd.conf(5) man page

default-lease-time 600;
max-lease-time 7200;
authoritative;
# specify network address and subnetmask
subnet 10.2.1.0 netmask 255.255.255.0 {
    # specify the range of lease IP address
    range dynamic-bootp 10.2.1.50 10.2.1.254;
    # specify broadcast address
    option broadcast-address 10.2.1.255;
    # specify gateway
    option routers 10.2.1.11;
}
```

on autorise le service dhcp sur le parre-feu : 
```
[louis@node1 ~]$ sudo systemctl enable --now dhcpd
Created symlink /etc/systemd/system/multi-user.target.wants/dhcpd.service → /usr/lib/systemd/system/dhcpd.service.
[louis@node1 ~]$ sudo firewall-cmd --add-service=dhcp
Warning: ALREADY_ENABLED: 'dhcp' already in 'public'
success
[louis@node1 ~]$ sudo firewall-cmd --runtime-to-permanent
success
```
on peut ce connecter en ssh à node 2 : 
```
PS C:\Users\louis> ssh louis@10.2.1.50
The authenticity of host '10.2.1.50 (10.2.1.50)' can't be established.
ECDSA key fingerprint is SHA256:khTXOPIAe+psQ8lKibqm7E/wd1n3qBz90UcDvFc8FdE.
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added '10.2.1.50' (ECDSA) to the list of known hosts.
louis@10.2.1.50's password:
Activate the web console with: systemctl enable --now cockpit.socket

Last login: Thu Sep 23 17:15:05 2021
[louis@node2 ~]$ ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
2: enp0s3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 08:00:27:cc:20:e5 brd ff:ff:ff:ff:ff:ff
    inet 10.0.2.15/24 brd 10.0.2.255 scope global dynamic noprefixroute enp0s3
       valid_lft 83724sec preferred_lft 83724sec
    inet6 fe80::a00:27ff:fecc:20e5/64 scope link noprefixroute
       valid_lft forever preferred_lft forever
3: enp0s8: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 08:00:27:7e:d9:34 brd ff:ff:ff:ff:ff:ff
    inet 10.2.1.50/24 brd 10.2.1.255 scope global dynamic noprefixroute enp0s8
       valid_lft 565sec preferred_lft 565sec
    inet6 fe80::a00:27ff:fe7e:d934/64 scope link
       valid_lft forever preferred_lft forever
```

on rajoute les lignes `option domain-name-servers 1.1.1.1;` et `option route default;` dans `dhcpd.conf`

ping passerelle de node 2 : 
```
[louis@node2 ~]$ ping 10.2.1.11
PING 10.2.1.11 (10.2.1.11) 56(84) bytes of data.
64 bytes from 10.2.1.11: icmp_seq=1 ttl=64 time=1.23 ms
64 bytes from 10.2.1.11: icmp_seq=2 ttl=64 time=0.796 ms
^C
--- 10.2.1.11 ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1001ms
rtt min/avg/max/mdev = 0.796/1.011/1.226/0.215 ms
```
commande dig : 
```
[louis@node2 ~]$ dig ynov.com

; <<>> DiG 9.11.26-RedHat-9.11.26-4.el8_4 <<>> ynov.com
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 35508
;; flags: qr rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 4096
;; QUESTION SECTION:
;ynov.com.                      IN      A

;; ANSWER SECTION:
ynov.com.               9982    IN      A       92.243.16.143

;; Query time: 9 msec
;; SERVER: 192.168.1.254#53(192.168.1.254)
;; WHEN: Thu Sep 23 18:38:33 CEST 2021
;; MSG SIZE  rcvd: 53
```
(je n'ai pas réussit à avoir le bon dns)

route default : 
```
[louis@node2 ~]$ ip r s
default via 10.0.2.2 dev enp0s3 proto dhcp metric 100
default via 10.2.1.11 dev enp0s8 proto dhcp metric 101
10.0.2.0/24 dev enp0s3 proto kernel scope link src 10.0.2.15 metric 100
10.2.1.0/24 dev enp0s8 proto kernel scope link src 10.2.1.50 metric 101
```
capture depuis node 1 : 
| ordre | type trame  | IP source           | MAC source                | IP destination   | MAC destination             |
|-------|-------------|---------------------|---------------------------|------------------|-----------------------------|
| 1     | BROWER      | `10.2.1.1`          |`0a:00:27:00:00:48`        | `10.2.1.255`     |`Broadcast ff:ff:ff:ff:ff:ff`|
| 2     |DHCP(request)| `0.0.0.0`           |`08:00:27:7e:d9:34`        |`255.255.255.255` |`Broadcast ff:ff:ff:ff:ff:ff`|
| 3     | DHCP        | `10.2.1.12`         |`node1` `08:00:27:ce:9a:cd`|`10.2.1.50`       |`node2` `08:00:27:7e:d9:34`  |
| 4     | ARP         | X                   |`node2` `08:00:27:7e:d9:34`| X                |`Broadcast ff:ff:ff:ff:ff:ff`|

1) protocole brower sur tout le réseau 10.2.1.0/24
2) requête dhcp envoyer à n'importe quel utilisateur
3) offre du server dhcp pour la machine node 2
4) requête arp pour prendre connaissance du réseau


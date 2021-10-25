# TP4 : Vers un réseau d'entreprise

## I. Dumb switch

### 2. Adressage topologie 1

ip sur pc1 : 
```
PC1> ip 10.1.1.1/24
Checking for duplicate address...
PC1 : 10.1.1.1 255.255.255.0

PC1> show ip

NAME        : PC1[1]
IP/MASK     : 10.1.1.1/24
GATEWAY     : 0.0.0.0
DNS         :
MAC         : 00:50:79:66:68:00
LPORT       : 20004
RHOST:PORT  : 127.0.0.1:20005
MTU:        : 1500
```

ip sur pc2 : 
```
PC2> ip 10.1.1.2/24
Checking for duplicate address...
PC1 : 10.1.1.2 255.255.255.0

PC2> show ip

NAME        : PC2[1]
IP/MASK     : 10.1.1.2/24
GATEWAY     : 0.0.0.0
DNS         :
MAC         : 00:50:79:66:68:01
LPORT       : 20006
RHOST:PORT  : 127.0.0.1:20007
MTU:        : 1500
```

### 3. Setup topologie 1

on fait ping les deux vpcs entre eux : 
```
PC1> ping 10.1.1.2
84 bytes from 10.1.1.2 icmp_seq=1 ttl=64 time=8.212 ms
84 bytes from 10.1.1.2 icmp_seq=2 ttl=64 time=4.280 ms
```

```
PC2> ping 10.1.1.1
84 bytes from 10.1.1.1 icmp_seq=1 ttl=64 time=17.157 ms
84 bytes from 10.1.1.1 icmp_seq=2 ttl=64 time=13.964 ms
```

## II. VLAN

### 3. Setup topologie 2

on rajoute l'ip de pc3 : 
```
PC3> ip 10.1.1.3/24
Checking for duplicate address...
PC1 : 10.1.1.3 255.255.255.0

PC3> show ip

NAME        : PC3[1]
IP/MASK     : 10.1.1.3/24
GATEWAY     : 0.0.0.0
DNS         :
MAC         : 00:50:79:66:68:02
LPORT       : 20042
RHOST:PORT  : 127.0.0.1:20043
MTU:        : 1500
```

on regarde si on peut ping les 2 autes clients : 
```
PC3> ping 10.1.1.1
84 bytes from 10.1.1.1 icmp_seq=1 ttl=64 time=8.470 ms
84 bytes from 10.1.1.1 icmp_seq=2 ttl=64 time=11.056 ms
^C
PC3> ping 10.1.1.2
84 bytes from 10.1.1.2 icmp_seq=1 ttl=64 time=8.044 ms
84 bytes from 10.1.1.2 icmp_seq=2 ttl=64 time=10.282 ms

```

on configure les vlans sur le switch : 
```
Switch>enable
Switch#conf t
Enter configuration commands, one per line.  End with CNTL/Z.
Switch(config)#vlan 10
Switch(config-vlan)#name admin
Switch(config-vlan)#exit
Switch(config)#vlan 20
Switch(config-vlan)#name guests
Switch(config-vlan)#exit
Switch(config)#exit
Switch#show vlan

VLAN Name                             Status    Ports
---- -------------------------------- --------- -------------------------------
1    default                          active    Gi0/0, Gi0/1, Gi0/2, Gi0/3
                                                Gi1/0, Gi1/1, Gi1/2, Gi1/3
                                                Gi2/0, Gi2/1, Gi2/2, Gi2/3
                                                Gi3/0, Gi3/1, Gi3/2, Gi3/3
10   admin                            active
20   guests                           active
1002 fddi-default                     act/unsup
1003 token-ring-default               act/unsup
1004 fddinet-default                  act/unsup
1005 trnet-default                    act/unsup

VLAN Type  SAID       MTU   Parent RingNo BridgeNo Stp  BrdgMode Trans1 Trans2
---- ----- ---------- ----- ------ ------ -------- ---- -------- ------ ------
1    enet  100001     1500  -      -      -        -    -        0      0
10   enet  100010     1500  -      -      -        -    -        0      0
20   enet  100020     1500  -      -      -        -    -        0      0
1002 fddi  101002     1500  -      -      -        -    -        0      0
1003 tr    101003     1500  -      -      -        -    -        0      0
1004 fdnet 101004     1500  -      -      -        ieee -        0      0
1005 trnet 101005     1500  -      -      -        ibm  -        0      0
```

on attribut les vlans au interfaces : 
```
Switch#conf t
Enter configuration commands, one per line.  End with CNTL/Z.
Switch(config)#interface GigabitEthernet 0/0
Switch(config-if)#switchport mode access
Switch(config-if)#switchport access vlan 10
Switch(config-if)#exit
Switch(config)#interface GigabitEthernet 0/1
Switch(config-if)#switchport mode access
Switch(config-if)#switchport access vlan 10
Switch(config-if)#exit
Switch(config)#interface GigabitEthernet 0/2
Switch(config-if)#switchport mode access
Switch(config-if)#switchport access vlan 20
Switch(config-if)#exit

Switch#show vlan br

VLAN Name                             Status    Ports
---- -------------------------------- --------- -------------------------------
1    default                          active    Gi0/3, Gi1/0, Gi1/1, Gi1/2
                                                Gi1/3, Gi2/0, Gi2/1, Gi2/2
                                                Gi2/3, Gi3/0, Gi3/1, Gi3/2
                                                Gi3/3
10   admin                            active    Gi0/0, Gi0/1
20   guests                           active    Gi0/2
1002 fddi-default                     act/unsup
1003 token-ring-default               act/unsup
1004 fddinet-default                  act/unsup
1005 trnet-default                    act/unsup
```

on vérifie que pc1 et pc2 se ping mais pas pc3 : 
```
PC1> ping 10.1.1.2
84 bytes from 10.1.1.2 icmp_seq=1 ttl=64 time=6.620 ms
84 bytes from 10.1.1.2 icmp_seq=2 ttl=64 time=3.005 ms
^C
PC1> ping 10.1.1.3
host (10.1.1.3) not reachable
```

## III. Routing

on définie des ip statiques (ip de pc1 et pc2 reste inchangé) : 

adm1 :
```
adm1> ip 10.2.2.1
Checking for duplicate address...
PC1 : 10.2.2.1 255.255.255.0

adm1> show ip

NAME        : PC3[1]
IP/MASK     : 10.2.2.1/24
GATEWAY     : 0.0.0.0
DNS         :
MAC         : 00:50:79:66:68:02
LPORT       : 20042
RHOST:PORT  : 127.0.0.1:20043
MTU:        : 1500
```

web :
```
[louis@web ~]$ ip a
2: enp0s3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 08:00:27:fe:2e:ed brd ff:ff:ff:ff:ff:ff
    inet 10.3.3.1/24 brd 10.3.3.255 scope global noprefixroute enp0s3
       valid_lft forever preferred_lft forever
    inet6 fe80::a00:27ff:fefe:2eed/64 scope link noprefixroute
       valid_lft forever preferred_lft forever
```

on déclare les vlan : 
```
Switch>enable
Switch#conf t
Enter configuration commands, one per line.  End with CNTL/Z.
Switch(config)#vlan 11
Switch(config-vlan)#name clients
Switch(config-vlan)#exit
Switch(config)#vlan 12
Switch(config-vlan)#name admins
Switch(config-vlan)#exit
Switch(config)#vlan 13
Switch(config-vlan)#name servers
Switch(config-vlan)#exit
Switch(config)#exit
Switch#show vlan
VLAN Name                             Status    Ports
---- -------------------------------- --------- -------------------------------
1    default                          active    Gi0/3, Gi1/0, Gi1/1, Gi1/2
                                                Gi1/3, Gi2/0, Gi2/1, Gi2/2
                                                Gi2/3, Gi3/0, Gi3/1, Gi3/2
                                                Gi3/3
10   admin                            active    Gi0/0, Gi0/1
11   clients                          active
12   admins                           active
13   servers                          active
20   guests                           active    Gi0/2
1002 fddi-default                     act/unsup
1003 token-ring-default               act/unsup
1004 fddinet-default                  act/unsup
1005 trnet-default                    act/unsup

VLAN Type  SAID       MTU   Parent RingNo BridgeNo Stp  BrdgMode Trans1 Trans2
---- ----- ---------- ----- ------ ------ -------- ---- -------- ------ ------
1    enet  100001     1500  -      -      -        -    -        0      0
10   enet  100010     1500  -      -      -        -    -        0      0
11   enet  100011     1500  -      -      -        -    -        0      0
12   enet  100012     1500  -      -      -        -    -        0      0

```

on configure les vlans access : 
```
Switch(config)#interface GigabitEthernet 0/0
Switch(config-if)#switchport mode access
Switch(config-if)#switchport access vlan 11
Switch(config-if)#exit
Switch(config)#interface GigabitEthernet 0/1
Switch(config-if)#switchport mode access
Switch(config-if)#switchport access vlan 11
Switch(config-if)#exit
Switch(config)#interface GigabitEthernet 0/2
Switch(config-if)#switchport mode access
Switch(config-if)#switchport access vlan 12
Switch(config-if)#exit
Switch(config)#interface GigabitEthernet 0/3
Switch(config-if)#switchport mode access
Switch(config-if)#switchport access vlan 13
```

on configure le mode trunk pour l'intarface du router : 
```
Switch(config)#interface GigabitEthernet 1/0
Switch(config-if)#switchport trunk encapsulation dot1q
Switch(config-if)#switchport mode trunk
Switch(config-if)#switchport trunk allowed vlan 11,12,13
Switch(config-if)#exit
Switch(config)#exit
Switch#show interface trunk
Port        Mode             Encapsulation  Status        Native vlan
Gi1/0       on               802.1q         trunking      1

Port        Vlans allowed on trunk
Gi1/0       11-13

Port        Vlans allowed and active in management domain
Gi1/0       11-13

Port        Vlans in spanning tree forwarding state and not pruned
Gi1/0       11-13
```

on definie plusieur ip sur une même interface du router : 
```
R1(config)#interface fastEthernet 0/0.11
R1(config-subif)#encapsulation dot1Q 11
R1(config-subif)#ip addr 10.1.1.254 255.255.255.0
R1(config-subif)#exit
R1(config)#interface fastEthernet 0/0.12
R1(config-subif)#encapsulation dot1Q 12
R1(config-subif)#ip addr 10.2.2.254 255.255.255.0
R1(config-subif)#exit
R1(config)#interface fastEthernet 0/0.13
R1(config-subif)#encapsulation dot1Q 13
R1(config-subif)#ip addr 10.3.3.254 255.255.255.0
R1(config-subif)#exit

```

on up l'interface : 
```
R1(config)#interface fastEthernet 0/0
R1(config-if)#no shut
R1#show ip interface brief
Interface                  IP-Address      OK? Method Status                Protocol
FastEthernet0/0            unassigned      YES unset  up                    up
FastEthernet0/0.11         10.1.1.254      YES manual up                    up
FastEthernet0/0.12         10.2.2.254      YES manual up                    up
FastEthernet0/0.13         10.3.3.254      YES manual up                    up
FastEthernet1/0            unassigned      YES unset  administratively down down
FastEthernet2/0            unassigned      YES unset  administratively down down
FastEthernet3/0            unassigned      YES unset  administratively down down
```

chaque apareil peut ping le router : 
```
PC1> ping 10.1.1.254
84 bytes from 10.1.1.254 icmp_seq=1 ttl=255 time=16.409 ms
84 bytes from 10.1.1.254 icmp_seq=2 ttl=255 time=13.536 ms
84 bytes from 10.1.1.254 icmp_seq=3 ttl=255 time=13.567 ms
84 bytes from 10.1.1.254 icmp_seq=4 ttl=255 time=17.987 ms
84 bytes from 10.1.1.254 icmp_seq=5 ttl=255 time=12.160 ms

-------------------------------------------------------

adm1> ping 10.2.2.254
84 bytes from 10.2.2.254 icmp_seq=1 ttl=255 time=8.538 ms
84 bytes from 10.2.2.254 icmp_seq=2 ttl=255 time=19.154 ms
^C

-------------------------------------------------------

[louis@web ~]$ ping 10.3.3.254
PING 10.3.3.254 (10.3.3.254) 56(84) bytes of data.
64 bytes from 10.3.3.254: icmp_seq=2 ttl=255 time=12.5 ms
64 bytes from 10.3.3.254: icmp_seq=3 ttl=255 time=14.4 ms
^C
--- 10.3.3.254 ping statistics ---
3 packets transmitted, 2 received, 33.3333% packet loss, time 2018ms
rtt min/avg/max/mdev = 12.485/13.430/14.376/0.952 ms
```
on ajoute des routes statiques pour faire communiquer les réseaux : 
```
PC1 : 10.1.1.1 255.255.255.0 gateway 10.1.1.254

PC1> show ip

NAME        : PC1[1]
IP/MASK     : 10.1.1.1/24
GATEWAY     : 10.1.1.254
DNS         :
MAC         : 00:50:79:66:68:00
LPORT       : 20038
RHOST:PORT  : 127.0.0.1:20039
MTU:        : 1500

-------------------------------------------------------

PC2> ip 10.1.1.2/24 10.1.1.254
Checking for duplicate address...
PC1 : 10.1.1.2 255.255.255.0 gateway 10.1.1.254

PC2> show ip

NAME        : PC2[1]
IP/MASK     : 10.1.1.2/24
GATEWAY     : 10.1.1.254
DNS         :
MAC         : 00:50:79:66:68:01
LPORT       : 20040
RHOST:PORT  : 127.0.0.1:20041
MTU:        : 1500

-------------------------------------------------------

adm1> ip 10.2.2.1/24 10.2.2.254
Checking for duplicate address...
PC1 : 10.2.2.1 255.255.255.0 gateway 10.2.2.254

adm1> show ip

NAME        : PC3[1]
IP/MASK     : 10.2.2.1/24
GATEWAY     : 10.2.2.254
DNS         :
MAC         : 00:50:79:66:68:02
LPORT       : 20042
RHOST:PORT  : 127.0.0.1:20043
MTU:        : 1500

-------------------------------------------------------

[louis@web ~]$ sudo ip route add default via 10.3.3.254 dev enp0s3
[sudo] password for louis:
[louis@web ~]$ sudo cat /etc/sysconfig/network
# Created by anaconda
GATEWAY=10.3.3.254
```

on fait des ping entre les réseaux : 
```
PC1> ping 10.2.2.1
84 bytes from 10.2.2.1 icmp_seq=1 ttl=63 time=23.174 ms
84 bytes from 10.2.2.1 icmp_seq=2 ttl=63 time=31.899 ms
^C

PC1> ping 10.3.3.1
84 bytes from 10.3.3.1 icmp_seq=1 ttl=63 time=24.406 ms
84 bytes from 10.3.3.1 icmp_seq=2 ttl=63 time=30.255 ms
^C
```

## IV. NAT

### 3. Setup topologie 4

on définit une adresse danamique sur l'interface du router relié au cloud : 
```
R1#conf t
Enter configuration commands, one per line.  End with CNTL/Z.
R1(config)#interface fastEthernet 1/0
R1(config-if)#ip address dhcp
R1(config-if)#no shut
R1(config-if)#
*Mar  1 01:18:05.899: %LINK-3-UPDOWN: Interface FastEthernet1/0, changed state to up
*Mar  1 01:18:06.899: %LINEPROTO-5-UPDOWN: Line protocol on Interface FastEthernet1/0, changed state to up
R1(config-if)#exit
R1(config)#exit
R1#show ip interface brief
Interface                  IP-Address      OK? Method Status                Protocol
FastEthernet1/0            10.0.3.16       YES DHCP   up                    up
```

on peut à présent ping : 
```
R1#ping 1.1.1.1

Type escape sequence to abort.
Sending 5, 100-byte ICMP Echos to 1.1.1.1, timeout is 2 seconds:
!!!!!
Success rate is 100 percent (5/5), round-trip min/avg/max = 64/92/108 ms
```

on configure le nat : 
```
R1#conf t
Enter configuration commands, one per line.  End with CNTL/Z.
R1(config)#interface fastEthernet 0/0
R1(config-if)#ip nat inside

*Mar  1 01:26:32.431: %LINEPROTO-5-UPDOWN: Line protocol on Interface NVI0, changed state to up
R1(config-if)#exit
R1(config)#interface fastEthernet 1/0
R1(config-if)#ip nat outside
R1(config-if)#exit
R1(config)#access-list 1 permit any
R1#ip nat inside source list 1 interface fastEthernet 0/0 overload
```

pour tester on ajoute un dns au vpcs et à la vm : 
```
[louis@web ~]$ sudo cat /etc/sysconfig/network
[sudo] password for louis:
# Created by anaconda
GATEWAY=10.3.3.254
[louis@web ~]$ cd /etc/sysconfig/network-scripts/
[louis@web network-scripts]$ cat ifcfg-enp0s3
BOOTPROTO=static
NAME=enp0s8
DEVICE=enp0s8
ONBOOT=yes
IPADDR=10.3.3.1
NETMASK=255.255.255.0
DNS=1.1.1.1

-------------------------------------------------------

PC1> ip dns 1.1.1.1

PC1> show ip

NAME        : PC1[1]
IP/MASK     : 10.1.1.1/24
GATEWAY     : 10.1.1.254
DNS         : 1.1.1.1
MAC         : 00:50:79:66:68:00
LPORT       : 20038
RHOST:PORT  : 127.0.0.1:20039
MTU:        : 1500

-------------------------------------------------------

PC2> ip dns 1.1.1.1

PC2> show ip

NAME        : PC2[1]
IP/MASK     : 10.1.1.2/24
GATEWAY     : 10.1.1.254
DNS         : 1.1.1.1
MAC         : 00:50:79:66:68:01
LPORT       : 20040
RHOST:PORT  : 127.0.0.1:20041
MTU:        : 1500

-------------------------------------------------------

PC3> ip dns 1.1.1.1

PC3> show ip

NAME        : PC3[1]
IP/MASK     : 10.2.2.1/24
GATEWAY     : 10.2.2.254
DNS         : 1.1.1.1
MAC         : 00:50:79:66:68:02
LPORT       : 20042
RHOST:PORT  : 127.0.0.1:20043
MTU:        : 1500
```

on peut maintenant résoudre des noms de domaines : 
```
PC1> ping google.com
google.com resolved to 172.217.22.142
84 bytes from 172.217.22.142 icmp_seq=1 ttl=114 time=32.469 ms
84 bytes from 172.217.22.142 icmp_seq=2 ttl=114 time=35.012 ms
```

## V. Add a building

fichier runnig-config : 

sw1 : 
```
Switch#show running-config
Building configuration...

Current configuration : 3685 bytes
!
! Last configuration change at 14:06:43 UTC Thu Oct 21 2021
!
version 15.2
service timestamps debug datetime msec
service timestamps log datetime msec
no service password-encryption
service compress-config
!
hostname Switch
!
boot-start-marker
boot-end-marker
!
!
!
no aaa new-model
!
!
!
!
!
!
!
!
ip cef
no ipv6 cef
!
!
!
spanning-tree mode pvst
spanning-tree extend system-id
!
vlan internal allocation policy ascending
!
!
!
!
!
!
!
!
!
!
!
!
!
!
interface GigabitEthernet0/0
 switchport trunk encapsulation dot1q
 switchport mode trunk
 media-type rj45
 negotiation auto
!
interface GigabitEthernet0/1
 switchport trunk encapsulation dot1q
 switchport mode trunk
 media-type rj45
 negotiation auto
!
interface GigabitEthernet0/2
 switchport trunk encapsulation dot1q
 switchport mode trunk
 media-type rj45
 negotiation auto
!
interface GigabitEthernet0/3
 media-type rj45
 negotiation auto
!
interface GigabitEthernet1/0
 media-type rj45
 negotiation auto
!
interface GigabitEthernet1/1
 media-type rj45
 negotiation auto
!
interface GigabitEthernet1/2
 media-type rj45
 negotiation auto
!
interface GigabitEthernet1/3
 media-type rj45
 negotiation auto
!
interface GigabitEthernet2/0
 media-type rj45
 negotiation auto
!
interface GigabitEthernet2/1
 media-type rj45
 negotiation auto
!
interface GigabitEthernet2/2
 media-type rj45
 negotiation auto
!
interface GigabitEthernet2/3
 media-type rj45
 negotiation auto
!
interface GigabitEthernet3/0
 media-type rj45
 negotiation auto
!
interface GigabitEthernet3/1
 media-type rj45
 negotiation auto
!
interface GigabitEthernet3/2
 media-type rj45
 negotiation auto
!
interface GigabitEthernet3/3
 media-type rj45
 negotiation auto
!
ip forward-protocol nd
!
no ip http server
no ip http secure-server
!
!
!
!
!
!
control-plane
!
banner exec ^C
**************************************************************************
* IOSv is strictly limited to use for evaluation, demonstration and IOS  *
* education. IOSv is provided as-is and is not supported by Cisco's      *
* Technical Advisory Center. Any use or disclosure, in whole or in part, *
* of the IOSv Software or Documentation to any third party for any       *
* purposes is expressly prohibited except as otherwise authorized by     *
* Cisco in writing.                                                      *
**************************************************************************^C
banner incoming ^C
**************************************************************************
* IOSv is strictly limited to use for evaluation, demonstration and IOS  *
* education. IOSv is provided as-is and is not supported by Cisco's      *
* Technical Advisory Center. Any use or disclosure, in whole or in part, *
* of the IOSv Software or Documentation to any third party for any       *
* purposes is expressly prohibited except as otherwise authorized by     *
* Cisco in writing.                                                      *
**************************************************************************^C
banner login ^C
**************************************************************************
* IOSv is strictly limited to use for evaluation, demonstration and IOS  *
* education. IOSv is provided as-is and is not supported by Cisco's      *
* Technical Advisory Center. Any use or disclosure, in whole or in part, *
* of the IOSv Software or Documentation to any third party for any       *
* purposes is expressly prohibited except as otherwise authorized by     *
* Cisco in writing.                                                      *
**************************************************************************^C
!
line con 0
line aux 0
line vty 0 4
!
!
end
```

sw2 : 
```
Switch#show running-config
Building configuration...

Current configuration : 3811 bytes
!
! Last configuration change at 13:44:35 UTC Thu Oct 21 2021
!
version 15.2
service timestamps debug datetime msec
service timestamps log datetime msec
no service password-encryption
service compress-config
!
hostname Switch
!
boot-start-marker
boot-end-marker
!
!
!
no aaa new-model
!
!
!
!
!
!
!
!
ip cef
no ipv6 cef
!
!
!
spanning-tree mode pvst
spanning-tree extend system-id
!
vlan internal allocation policy ascending
!
!
!
!
!
!
!
!
!
!
!
!
!
!
interface GigabitEthernet0/0
 switchport access vlan 11
 switchport mode access
 media-type rj45
 negotiation auto
!
interface GigabitEthernet0/1
 switchport access vlan 11
 switchport mode access
 media-type rj45
 negotiation auto
!
interface GigabitEthernet0/2
 switchport access vlan 12
 switchport mode access
 media-type rj45
 negotiation auto
!
interface GigabitEthernet0/3
 switchport access vlan 13
 switchport mode access
 media-type rj45
 negotiation auto
!
interface GigabitEthernet1/0
 switchport trunk allowed vlan 11-13
 switchport trunk encapsulation dot1q
 switchport mode trunk
 media-type rj45
 negotiation auto
!
interface GigabitEthernet1/1
 media-type rj45
 negotiation auto
!
interface GigabitEthernet1/2
 media-type rj45
 negotiation auto
!
interface GigabitEthernet1/3
 media-type rj45
 negotiation auto
!
interface GigabitEthernet2/0
 media-type rj45
 negotiation auto
!
interface GigabitEthernet2/1
 media-type rj45
 negotiation auto
!
interface GigabitEthernet2/2
 media-type rj45
 negotiation auto
!
interface GigabitEthernet2/3
 media-type rj45
 negotiation auto
!
interface GigabitEthernet3/0
 media-type rj45
 negotiation auto
!
interface GigabitEthernet3/1
 media-type rj45
 negotiation auto
!
interface GigabitEthernet3/2
 media-type rj45
 negotiation auto
!
interface GigabitEthernet3/3
 media-type rj45
 negotiation auto
!
ip forward-protocol nd
!
no ip http server
no ip http secure-server
!
!
!
!
!
!
control-plane
!
banner exec ^C
**************************************************************************
* IOSv is strictly limited to use for evaluation, demonstration and IOS  *
* education. IOSv is provided as-is and is not supported by Cisco's      *
* Technical Advisory Center. Any use or disclosure, in whole or in part, *
* of the IOSv Software or Documentation to any third party for any       *
* purposes is expressly prohibited except as otherwise authorized by     *
* Cisco in writing.                                                      *
**************************************************************************^C
banner incoming ^C
**************************************************************************
* IOSv is strictly limited to use for evaluation, demonstration and IOS  *
* education. IOSv is provided as-is and is not supported by Cisco's      *
* Technical Advisory Center. Any use or disclosure, in whole or in part, *
* of the IOSv Software or Documentation to any third party for any       *
* purposes is expressly prohibited except as otherwise authorized by     *
* Cisco in writing.                                                      *
**************************************************************************^C
banner login ^C
**************************************************************************
* IOSv is strictly limited to use for evaluation, demonstration and IOS  *
* education. IOSv is provided as-is and is not supported by Cisco's      *
* Technical Advisory Center. Any use or disclosure, in whole or in part, *
* of the IOSv Software or Documentation to any third party for any       *
* purposes is expressly prohibited except as otherwise authorized by     *
* Cisco in writing.                                                      *
**************************************************************************^C
!
line con 0
line aux 0
line vty 0 4
 login
!
!
end
```

sw 3 : 
```
Switch#show running-config
Building configuration...

Current configuration : 3744 bytes
!
! Last configuration change at 13:51:51 UTC Thu Oct 21 2021
!
version 15.2
service timestamps debug datetime msec
service timestamps log datetime msec
no service password-encryption
service compress-config
!
hostname Switch
!
boot-start-marker
boot-end-marker
!
!
!
no aaa new-model
!
!
!
!
!

Switch#show running-config
Switch#show running-config
Building configuration...

Current configuration : 3744 bytes
!
! Last configuration change at 13:51:51 UTC Thu Oct 21 2021
!
version 15.2
service timestamps debug datetime msec
service timestamps log datetime msec
no service password-encryption
service compress-config
!
hostname Switch
!
boot-start-marker
boot-end-marker
!
!
!
no aaa new-model
!
!
!
!
!
!
!
!
ip cef
no ipv6 cef
!
!
!
spanning-tree mode pvst
spanning-tree extend system-id
!
vlan internal allocation policy ascending
!
!
!
!
!
!
!
!
!
!
!
!
!
!
interface GigabitEthernet0/0
 switchport trunk encapsulation dot1q
 media-type rj45
 negotiation auto
!
interface GigabitEthernet0/1
 switchport access vlan 11
 switchport mode access
 media-type rj45
 negotiation auto
!
interface GigabitEthernet0/2
 switchport access vlan 11
 switchport mode access
 media-type rj45
 negotiation auto
!
interface GigabitEthernet0/3
 switchport access vlan 11
 switchport mode access
 media-type rj45
 negotiation auto
!
interface GigabitEthernet1/0
 switchport access vlan 13
 switchport mode access
 media-type rj45
 negotiation auto
!
interface GigabitEthernet1/1
 media-type rj45
 negotiation auto
!
interface GigabitEthernet1/2
 media-type rj45
 negotiation auto
!
interface GigabitEthernet1/3
 media-type rj45
 negotiation auto
!
interface GigabitEthernet2/0
 media-type rj45
 negotiation auto
!
interface GigabitEthernet2/1
 media-type rj45
 negotiation auto
!
interface GigabitEthernet2/2
 media-type rj45
 negotiation auto
!
interface GigabitEthernet2/3
 media-type rj45
 negotiation auto
!
interface GigabitEthernet3/0
 media-type rj45
 negotiation auto
!
interface GigabitEthernet3/1
 media-type rj45
 negotiation auto
!
interface GigabitEthernet3/2
 media-type rj45
 negotiation auto
!
interface GigabitEthernet3/3
 media-type rj45
 negotiation auto
!
ip forward-protocol nd
!
no ip http server
no ip http secure-server
!
!
!
!
!
!
control-plane
!
banner exec ^C
**************************************************************************
* IOSv is strictly limited to use for evaluation, demonstration and IOS  *
* education. IOSv is provided as-is and is not supported by Cisco's      *
* Technical Advisory Center. Any use or disclosure, in whole or in part, *
* of the IOSv Software or Documentation to any third party for any       *
* purposes is expressly prohibited except as otherwise authorized by     *
* Cisco in writing.                                                      *
**************************************************************************^C
banner incoming ^C
**************************************************************************
* IOSv is strictly limited to use for evaluation, demonstration and IOS  *
* education. IOSv is provided as-is and is not supported by Cisco's      *
* Technical Advisory Center. Any use or disclosure, in whole or in part, *
* of the IOSv Software or Documentation to any third party for any       *
* purposes is expressly prohibited except as otherwise authorized by     *
* Cisco in writing.                                                      *
**************************************************************************^C
banner login ^C
**************************************************************************
* IOSv is strictly limited to use for evaluation, demonstration and IOS  *
* education. IOSv is provided as-is and is not supported by Cisco's      *
* Technical Advisory Center. Any use or disclosure, in whole or in part, *
* of the IOSv Software or Documentation to any third party for any       *
* purposes is expressly prohibited except as otherwise authorized by     *
* Cisco in writing.                                                      *
**************************************************************************^C
!
line con 0
line aux 0
line vty 0 4
!
!
end
```

router : 
```
R1#show running-config
Building configuration...

Current configuration : 1356 bytes
!
version 12.4
service timestamps debug datetime msec
service timestamps log datetime msec
no service password-encryption
!
hostname R1
!
boot-start-marker
boot-end-marker
!
!
no aaa new-model
memory-size iomem 5
no ip icmp rate-limit unreachable
!
!
ip cef
no ip domain lookup
!
!
!
!
!
!
!
!
!
!
!
!
!
!
!
!
ip tcp synwait-time 5
!
!
!
interface FastEthernet0/0
 no ip address
 ip nat inside
 ip virtual-reassembly
 duplex auto
 speed auto
!
interface FastEthernet0/0.11
 encapsulation dot1Q 11
 ip address 10.1.1.254 255.255.255.0
!
interface FastEthernet0/0.12
 encapsulation dot1Q 12
 ip address 10.2.2.254 255.255.255.0
!
interface FastEthernet0/0.13
 encapsulation dot1Q 13
 ip address 10.3.3.254 255.255.255.0
!
interface FastEthernet1/0
 ip address dhcp
 ip nat outside
 ip virtual-reassembly
 duplex auto
 speed auto
!
interface FastEthernet2/0
 no ip address
 shutdown
 duplex auto
 speed auto
!
interface FastEthernet3/0
 no ip address
 shutdown
 duplex auto
 speed auto
!
!
no ip http server
ip forward-protocol nd
!
!
ip nat inside source list 1 interface FastEthernet0/0 overload
!
access-list 1 permit any
no cdp log mismatch duplex
!
!
!
control-plane
!
!
!
!
!
!
!
!
!
line con 0
 exec-timeout 0 0
 privilege level 15
 logging synchronous
line aux 0
 exec-timeout 0 0
 privilege level 15
 logging synchronous
line vty 0 4
 login
!
!
end
```

on modifie le fichier `dhcpd.conf` : 
```
[louis@dhcp dhcp]# sudo cat dhcpd.conf
#
# DHCP Server Configuration file.
#   see /usr/share/doc/dhcp-server/dhcpd.conf.example
#   see dhcpd.conf(5) man page

default-lease-time 600;
max-lease-time 7200;
authoritative;
# specify network address and subnetmask
subnet 10.3.3.0 netmask 255.255.255.0 {
    # specify the range of lease IP address
    range dynamic-bootp 10.3.3.7 10.3.3.253;
    # specify broadcast address
    option broadcast-address 10.3.3.255;
    # specify gateway
    option routers 10.3.3.254;
    option domain-name-servers 1.1.1.1;
}
```



on met en place le dhcp et on récupère une ip en dhcp depuis les vpcs

je n'ai pas réussit à faire cette partie.

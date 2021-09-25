# TP1 : (re)Familiaration avec un système GNU/Linux

## 0. Préparation de la machine

__accès internet__
```
[louis@node1 ~]$ ip r s
default via 10.0.2.2 dev enp0s3 proto dhcp metric 100
10.0.2.0/24 dev enp0s3 proto kernel scope link src 10.0.2.15 metric 100
10.101.1.0/24 dev enp0s8 proto kernel scope link src 10.101.1.11 metric 101
```
avec ip r s on peut voir que l'hôte est la carte enp0s3 et quelle nous permet une connexion internet

ping de 8.8.8.8 : 

```
[louis@node1 ~]$ ping 8.8.8.8
PING 8.8.8.8 (8.8.8.8) 56(84) bytes of data.
64 bytes from 8.8.8.8: icmp_seq=1 ttl=114 time=19.1 ms
64 bytes from 8.8.8.8: icmp_seq=2 ttl=114 time=18.10 ms
^C
--- 8.8.8.8 ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1002ms
rtt min/avg/max/mdev = 18.961/19.022/19.083/0.061 ms
```

ping google.com : 
```
[louis@node1 ~]$ ping google.com
PING google.com (172.217.22.142) 56(84) bytes of data.
64 bytes from par21s12-in-f14.1e100.net (172.217.22.142): icmp_seq=1 ttl=114 time=18.5 ms
64 bytes from par21s12-in-f14.1e100.net (172.217.22.142): icmp_seq=2 ttl=114 time=18.3 ms
64 bytes from par21s12-in-f14.1e100.net (172.217.22.142): icmp_seq=3 ttl=114 time=19.5 ms
^C
--- google.com ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2013ms
rtt min/avg/max/mdev = 18.329/18.769/19.452/0.489 ms
```

__un accès à un réseau local (les deux machines peuvent se ping)__

on a definie au préalable des ip statiques sur node 1 et node 2 sur la carte enp0s8 : 

node 1 : 
```
[louis@node1 ~]$ ip a
3: enp0s8: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 08:00:27:98:9c:1d brd ff:ff:ff:ff:ff:ff
    inet 10.101.1.11/24 brd 10.101.1.255 scope global noprefixroute enp0s8
       valid_lft forever preferred_lft forever
    inet6 fe80::a00:27ff:fe98:9c1d/64 scope link noprefixroute
       valid_lft forever preferred_lft forever
```
node 2 : 
```
[louis@node2 ~]$ ip a
3: enp0s8: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 08:00:27:63:2f:20 brd ff:ff:ff:ff:ff:ff
    inet 10.101.1.12/24 brd 10.101.1.255 scope global noprefixroute enp0s8
       valid_lft forever preferred_lft forever
    inet6 fe80::a00:27ff:fe63:2f20/64 scope link noprefixroute
       valid_lft forever preferred_lft forever
```

ping node 1 vers node 2 : 

```
[louis@node1 ~]$ ping 10.101.1.12
PING 10.101.1.12 (10.101.1.12) 56(84) bytes of data.
64 bytes from 10.101.1.12: icmp_seq=1 ttl=64 time=1.53 ms
64 bytes from 10.101.1.12: icmp_seq=2 ttl=64 time=0.901 ms
64 bytes from 10.101.1.12: icmp_seq=3 ttl=64 time=0.829 ms
^C
--- 10.101.1.12 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2003ms
rtt min/avg/max/mdev = 0.829/1.085/1.526/0.314 ms
```

__les machines doivent avoir un nom__
pour definir le nom d'une machine on utilise `sudo hostname node1.tp1.b2` ou `sudo hostname node2.tp1.b2` suivi de la commande `echo 'node1.tp1.b2' | sudo tee /etc/hostname` ou
`echo 'node1.tp1.b2' | sudo tee /etc/hostname`

on peut voir le nom via la commande `hostname` : 

node 1 : 
`[louis@node1 ~]$ hostname
node1.tp1.b2`

node 2 : 
`[louis@node2 ~]$ hostname
node2.tp1.b2`

__utiliser 1.1.1.1 comme serveur DNS__

on regarde si le dns 1.1.1.1 est utilisé: 
```
[louis@node1 ~]$ sudo cat /etc/resolv.conf
nameserver 1.1.1.1
```
on teste le bon fonctionnement avec une requête http:
```
[louis@node1 ~]$ curl ynov.com
<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML 2.0//EN">
<html><head>
<title>301 Moved Permanently</title>
</head><body>
<h1>Moved Permanently</h1>
<p>The document has moved <a href="https://ynov.com/">here</a>.</p>
<hr>
<address>Apache/2.4.38 (Debian) Server at ynov.com Port 80</address>
</body></html>
```

on fait un dig sur ynov.com : 
```
[louis@node1 ~]$ dig ynov.com

; <<>> DiG 9.11.26-RedHat-9.11.26-4.el8_4 <<>> ynov.com
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 61500
;; flags: qr rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 1232
;; QUESTION SECTION:
;ynov.com.                      IN      A

;; ANSWER SECTION:
ynov.com.               9456    IN      A       92.243.16.143

;; Query time: 18 msec
;; SERVER: 1.1.1.1#53(1.1.1.1)
;; WHEN: Wed Sep 22 12:16:27 CEST 2021
;; MSG SIZE  rcvd: 53
```

ip correspondant au nom demandé : 
```
;; ANSWER SECTION:
ynov.com.               9456    IN      A       92.243.16.143
```

ip du serveur qui à répondu : 
```
;; Query time: 18 msec
;; SERVER: 1.1.1.1#53(1.1.1.1)
;; WHEN: Wed Sep 22 12:16:27 CEST 2021
;; MSG SIZE  rcvd: 53
```


**les machines doivent pouvoir se joindre par leurs noms respectifs**

on definie un nom via le fichier `/etc/host` : 

node 1 : 
```
[louis@node1 ~]$ sudo nano /etc/hosts
10.101.1.12 node2.tp1.b2
10.101.1.11 node1.tp1.b2
```

node 2 : 
```
[louis@node2 ~]$ sudo nano /etc/hosts
10.101.1.11 node1.tp1.b2
10.101.1.12 node2.tp1.b2
```

ping : 

node 1 vers node 2 : 
```
[louis@node1 ~]$ ping node2.tp1.b2
PING node2.tp1.b2 (10.101.1.12) 56(84) bytes of data.
64 bytes from node2.tp1.b2 (10.101.1.12): icmp_seq=1 ttl=64 time=0.717 ms
64 bytes from node2.tp1.b2 (10.101.1.12): icmp_seq=2 ttl=64 time=0.926 ms
64 bytes from node2.tp1.b2 (10.101.1.12): icmp_seq=3 ttl=64 time=1.01 ms
^C
--- node2.tp1.b2 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2054ms
rtt min/avg/max/mdev = 0.717/0.885/1.013/0.126 ms
```

node 2 vers node 1 : 
```
[louis@node2 ~]$ ping node1.tp1.b2
PING node1.tp1.b2 (10.101.1.11) 56(84) bytes of data.
64 bytes from node1.tp1.b2 (10.101.1.11): icmp_seq=1 ttl=64 time=0.389 ms
64 bytes from node1.tp1.b2 (10.101.1.11): icmp_seq=2 ttl=64 time=0.764 ms
^C
--- node1.tp1.b2 ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1136ms
rtt min/avg/max/mdev = 0.389/0.576/0.764/0.189 ms
```

**le pare-feu est configuré pour bloquer toutes les connexions exceptées celles qui sont nécessaires**
```
[louis@node1 ~]$ sudo firewall-cmd --list-all
public (active)
  target: default
  icmp-block-inversion: no
  interfaces: enp0s3 enp0s8
  sources:
  services: cockpit dhcpv6-client ssh
  ports:
  protocols:
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
  rich rules:
```
on peux voir ici les connexions autorisées


## I. Utilisateurs

### 1. Création et configuration

on crée un user avec la commande `useradd -s /bin/bash` : 
```
[louis@node1 ~]$ sudo useradd -s /bin/bash admin
[sudo] password for louis:
[louis@node1 ~]$
```

et on definie son mot de passe avec `passwd admin` : 
```
[louis@node1 ~]$ sudo passwd admin
Changing password for user admin.
New password:
BAD PASSWORD: The password is shorter than 8 characters
Retype new password:
passwd: all authentication tokens updated successfully.
```
on voir le repertoire /home de l'utilisateur : 
```
[louis@node1 ~]$ cd /home
[louis@node1 home]$ ls
admin  louis
```

on créer le groupe admins : 
```
[louis@node1 /]$ sudo groupadd admins
```

modification avec `sudo visudo /etc/sudoers`  :
```
Same thing without a password
%admins        ALL=(ALL)       NOPASSWD: ALL
```

on ajoute l'utilisateur admin dans le groupe admins : 
```
[louis@node1 /]$ sudo usermod -aG admins admin
```

### 2. SSH

on génère un clé ssh : 
```
PS C:\Users\louis> ssh-keygen -t rsa -b 4096
Generating public/private rsa key pair.
Enter file in which to save the key (C:\Users\louis/.ssh/id_rsa):
Enter passphrase (empty for no passphrase):
Enter same passphrase again:
Your identification has been saved in C:\Users\louis/.ssh/id_rsa.
Your public key has been saved in C:\Users\louis/.ssh/id_rsa.pub.
The key fingerprint is:
SHA256:RJqD/TTTLOteLsFk6VZdM4nPN01DNmHXx8LUYlE6CfY louis@LAPTOP-AJSLEU9I
The key's randomart image is:
+---[RSA 4096]----+
|        .   o++%=|
|     o + o ..o%+O|
|    . = *.o. =E*+|
|       =+=. . ooo|
|       =S.     ..|
|       .=        |
|       ....      |
|       ..o       |
|        ...      |
+----[SHA256]-----+
```

on récupère la clé publique (copie faite à la main) : 
```
PS C:\Users\louis\.ssh> cat .\id_rsa.pub
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDCgKHH8pb6HDcY2z2KjzVjI0PEBPnpw8LPKCFJrEqNLKQXl7fvR7AMH94c0anWQ7m5JejY36Y5XZ1n59IOGxAZqY3L7fQCAC3PfKd5j3mURoDxGUlm0qARnGxJQNSN/Xh0r59vwaJxtbMCJMeiIx4E9wWlr7w6vr4ahN0xQcdU4ey+febiYItPRN+rHK/vRp5IZpM8Hh6uYLk93lg6sLkC45S3tIHBotd4CWbsZ3AUNN0DGnK1kUWpUv0u5/1aIlvCoda06yiY5F9Mx1SB5FTQvNy7vdIX9uzIn1r1zzyL4m3j9xgdHfwv44M4CM/hSt3sMTqF9gW8BG/fAO/197YdQoi2SKgNAWwdpGK8Pa4LyB7RaEjqS0ZLsNBj9XSPQUVjMoISP7MHoLR8khxa1jgvIuNbHNGrLrNXgOJsbPnIS4+CtMcmH9cCWJEvswjSDv9K4sT72E1K8S9prqMIH6zcvcK5kBHsUEKM00LuWjHjK4v720bHIV63/SSFJ1RGbccn555n9qJARarCc96HtXQjC4BOvnMgcfLH3OdXHB4aQbO6ni2MPeOIxuyjHeRky68TaKqKFRWSS5qdHF6RbCqqP3EagriRkJiV65/wVUkk2mvbDzRiJiNx1WTjXBZeffTXVs/ouOz5792N3BLhcdTaqW3bj5WrZyD8LNo3ZJvWaQ== louis@LAPTOP-AJSLEU9I
```
on copie la clé dans le fichier `/home/user/.ssh/authorized_keys`de la vm et on définie les permission : 

```
[louis@node1 .ssh]$ sudo chmod 600 authorized_keys
[louis@node1 .ssh]$ ls
authorized_keys
[louis@node1 .ssh]$ ls -al
total 4
drwxrwxr-x. 2 louis louis  29 Sep 22 18:01 .
drwx------. 3 louis louis  74 Sep 22 17:58 ..
-rw-------. 1 root  root  747 Sep 22 18:01 authorized_keys
```
```
[louis@node1 ~]$ sudo chmod 700 .ssh/
[louis@node1 ~]$ ls -al
total 12
drwx------. 3 louis louis  74 Sep 22 17:58 .
drwxr-xr-x. 4 root  root   32 Sep 22 17:00 ..
-rw-r--r--. 1 louis louis  18 Jun 17 01:42 .bash_logout
-rw-r--r--. 1 louis louis 141 Jun 17 01:42 .bash_profile
-rw-r--r--. 1 louis louis 376 Jun 17 01:42 .bashrc
drwx------. 2 louis louis  29 Sep 22 18:01 .ssh
```

## II. Partitionnement

### 1. Préparation de la VM

on créée deux disque dur de 3 Go via l'interface de configuration de virtual box sur node 1 : 
```
[louis@node1 ~]$ sudo fdisk -l
Disk /dev/sdb: 3 GiB, 3221225472 bytes, 6291456 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes


Disk /dev/sda: 8 GiB, 8589934592 bytes, 16777216 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: dos
Disk identifier: 0x7242d4f7

Device     Boot   Start      End  Sectors Size Id Type
/dev/sda1  *       2048  2099199  2097152   1G 83 Linux
/dev/sda2       2099200 16777215 14678016   7G 8e Linux LVM


Disk /dev/sdc: 3 GiB, 3221225472 bytes, 6291456 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
```

### 2. Partitionnement


on ajoute nos deux disque(sdb et sdc) en tant que physiqual volume via lvm : 
```
[louis@node1 ~]$ sudo pvcreate /dev/sdb
  Physical volume "/dev/sdb" successfully created.
[louis@node1 ~]$ sudo pvcreate /dev/sdc
  Physical volume "/dev/sdc" successfully created.
[louis@node1 ~]$ sudo pvs
  PV         VG Fmt  Attr PSize  PFree
  /dev/sda2  rl lvm2 a--  <7.00g    0
  /dev/sdb      lvm2 ---   3.00g 3.00g
  /dev/sdc      lvm2 ---   3.00g 3.00g
```
on crée un volume groupe avec les deux disques : 
```
[louis@node1 ~]$ sudo vgcreate data /dev/sdb
  Volume group "data" successfully created
[louis@node1 ~]$ sudo vgextend data /dev/sdc
  Volume group "data" successfully extended
[louis@node1 ~]$ sudo vgs
  VG   #PV #LV #SN Attr   VSize  VFree
  data   2   0   0 wz--n-  5.99g 5.99g
  rl     1   2   0 wz--n- <7.00g    0
```

on créée les logicals volume : 
```
[louis@node1 ~]$ sudo lvcreate -L 1G data -n data1
  Logical volume "data1" created.
[louis@node1 ~]$ sudo lvcreate -L 1G data -n data2
  Logical volume "data2" created.
[louis@node1 ~]$ sudo lvcreate -L 1G data -n data3
  Logical volume "data3" created.
[louis@node1 ~]$ sudo lvs
  LV    VG   Attr       LSize   Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
  data1 data -wi-a-----   1.00g

  data2 data -wi-a-----   1.00g

  data3 data -wi-a-----   1.00g

  root  rl   -wi-ao----  <6.20g

  swap  rl   -wi-ao---- 820.00m
```
on formate les partitions en `ext4` : 
```
[louis@node1 ~]$ sudo mkfs -t ext4 /dev/data/data1
mke2fs 1.45.6 (20-Mar-2020)
Creating filesystem with 262144 4k blocks and 65536 inodes
Filesystem UUID: 7e3a15fd-7803-460d-bf83-a999236bcc40
Superblock backups stored on blocks:
        32768, 98304, 163840, 229376

Allocating group tables: done
Writing inode tables: done
Creating journal (8192 blocks): done
Writing superblocks and filesystem accounting information: done

[louis@node1 ~]$ sudo mkfs -t ext4 /dev/data/data2
mke2fs 1.45.6 (20-Mar-2020)
Creating filesystem with 262144 4k blocks and 65536 inodes
Filesystem UUID: 5f99a2e6-e2e5-4c1d-acaf-097edeba55ec
Superblock backups stored on blocks:
        32768, 98304, 163840, 229376

Allocating group tables: done
Writing inode tables: done
Creating journal (8192 blocks): done
Writing superblocks and filesystem accounting information: done

[louis@node1 ~]$ sudo mkfs -t ext4 /dev/data/data3
mke2fs 1.45.6 (20-Mar-2020)
Creating filesystem with 262144 4k blocks and 65536 inodes
Filesystem UUID: 700c08c8-4828-42a6-b5e0-ddaccf083d71
Superblock backups stored on blocks:
        32768, 98304, 163840, 229376

Allocating group tables: done
Writing inode tables: done
Creating journal (8192 blocks): done
Writing superblocks and filesystem accounting information: done
```
montage des partition : 
```
[louis@node1 ~]$ sudo mkdir /mnt/data1
[louis@node1 ~]$ sudo mount /dev/data/data1 /mnt/data1/
[louis@node1 ~]$ sudo mkdir /mnt/data2
[louis@node1 ~]$ sudo mount /dev/data/data2 /mnt/data2/
[louis@node1 ~]$ sudo mkdir /mnt/data3
[louis@node1 ~]$ sudo mount /dev/data/data3 /mnt/data3/
[louis@node1 ~]$ df -h
Filesystem              Size  Used Avail Use% Mounted on
devtmpfs                891M     0  891M   0% /dev
tmpfs                   909M     0  909M   0% /dev/shm
tmpfs                   909M  8.6M  901M   1% /run
tmpfs                   909M     0  909M   0% /sys/fs/cgroup
/dev/mapper/rl-root     6.2G  2.0G  4.3G  33% /
/dev/sda1              1014M  241M  774M  24% /boot
tmpfs                   182M     0  182M   0% /run/user/1000
/dev/mapper/data-data1  976M  2.6M  907M   1% /mnt/data1
/dev/mapper/data-data2  976M  2.6M  907M   1% /mnt/data2
/dev/mapper/data-data3  976M  2.6M  907M   1% /mnt/data3
```
montage au démarage : 
```
[louis@node1 ~]$ sudo cat /etc/fstab

#
# /etc/fstab
# Created by anaconda on Wed Sep 15 08:37:10 2021
#
# Accessible filesystems, by reference, are maintained under '/dev/disk/'.
# See man pages fstab(5), findfs(8), mount(8) and/or blkid(8) for more info.
#
# After editing this file, run 'systemctl daemon-reload' to update systemd
# units generated from this file.
#
/dev/mapper/rl-root     /                       xfs     defaults        0 0
UUID=76a8b45f-5735-4c8f-808c-e1c17ca1cc31 /boot                   xfs     defaults        0 0
/dev/mapper/rl-swap     none                    swap    defaults        0 0
/dev/data/data1         /mnt/data1              ext4    defaults         0 0
[louis@node1 ~]$ sudo umount /mnt/data1
[louis@node1 ~]$ sudo mount -av
/                        : ignored
/boot                    : already mounted
none                     : ignored
mount: /mnt/data1 does not contain SELinux labels.
       You just mounted an file system that supports labels which does not
       contain labels, onto an SELinux box. It is likely that confined
       applications will generate AVC messages and not be allowed access to
       this file system.  For more details see restorecon(8) and mount(8).
/mnt/data1               : successfully mounted
```
## III. Gestion de services

### 1. Interaction avec un service existant

on regarde si firewalld est démarré : 
```
[louis@node1 ~]$ systemctl is-active firewalld
active
```

on regarde si il est activé : 
```
[louis@node1 ~]$ systemctl is-enabled firewalld
enabled
```
firewalld est donc bien démarré et activé.

### 2. Création de service

#### A. Unité simpliste

on créer et on écrit dans le fichier `web.service`
(on télécharge également python 3 : `[louis@node1 ~]$ sudo dnf install python3`)
```
[louis@node1 ~]$ sudo cat /etc/systemd/system/web.service
[Unit]
Description=Very simple web service

[Service]
ExecStart=/bin/python3 -m http.server 8888

[Install]
WantedBy=multi-user.target
```
on ouvre le port 8888 : 
```
[louis@node1 ~]$ sudo firewall-cmd --add-port=8888/tcp --permanent
success
[louis@node1 ~]$ sudo firewall-cmd --reload
success
```
relecture des fichiers de confugurations : 
```
[louis@node1 ~]$ sudo systemctl daemon-reload
```

interraction avec l'unité : 
```
[louis@node1 ~]$ sudo systemctl status web
● web.service - Very simple web service
   Loaded: loaded (/etc/systemd/system/web.service; enabled; vendor preset: disabled)
   Active: failed (Result: exit-code) since Sat 2021-09-25 16:59:30 CEST; 3min 25s ago
  Process: 881 ExecStart=/bin/python3 -m http.server 8888 (code=exited, status=203/EXEC)
 Main PID: 881 (code=exited, status=203/EXEC)

Sep 25 16:59:30 node1.tp1.b2 systemd[1]: Started Very simple web service.
Sep 25 16:59:30 node1.tp1.b2 systemd[881]: web.service: Failed to execute command: No such file or directory
Sep 25 16:59:30 node1.tp1.b2 systemd[881]: web.service: Failed at step EXEC spawning /bin/python3: No such file or dire>
Sep 25 16:59:30 node1.tp1.b2 systemd[1]: web.service: Main process exited, code=exited, status=203/EXEC
Sep 25 16:59:30 node1.tp1.b2 systemd[1]: web.service: Failed with result 'exit-code'.

[louis@node1 ~]$ sudo systemctl start web
[louis@node1 ~]$ sudo systemctl enable web
[louis@node1 ~]$ sudo systemctl status web
● web.service - Very simple web service
   Loaded: loaded (/etc/systemd/system/web.service; enabled; vendor preset: disabled)
   Active: active (running) since Sat 2021-09-25 17:03:17 CEST; 10s ago
 Main PID: 23662 (python3)
    Tasks: 1 (limit: 11396)
   Memory: 9.5M
   CGroup: /system.slice/web.service
           └─23662 /bin/python3 -m http.server 8888

Sep 25 17:03:17 node1.tp1.b2 systemd[1]: Started Very simple web service.
```

connection avec `curl` : 

port inactif : 
```
[louis@node2 ~]$ curl 10.101.1.11
curl: (7) Failed to connect to 10.101.1.11 port 80: No route to host
```

port 8888 que l'on a activé : 
```
[louis@node2 ~]$ curl 10.101.1.11:8888
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<title>Directory listing for /</title>
</head>
<body>
<h1>Directory listing for /</h1>
<hr>
<ul>
<li><a href="bin/">bin@</a></li>
<li><a href="boot/">boot/</a></li>
<li><a href="dev/">dev/</a></li>
<li><a href="etc/">etc/</a></li>
<li><a href="home/">home/</a></li>
<li><a href="lib/">lib@</a></li>
<li><a href="lib64/">lib64@</a></li>
<li><a href="media/">media/</a></li>
<li><a href="mnt/">mnt/</a></li>
<li><a href="opt/">opt/</a></li>
<li><a href="proc/">proc/</a></li>
<li><a href="root/">root/</a></li>
<li><a href="run/">run/</a></li>
<li><a href="sbin/">sbin@</a></li>
<li><a href="srv/">srv/</a></li>
<li><a href="sys/">sys/</a></li>
<li><a href="tmp/">tmp/</a></li>
<li><a href="usr/">usr/</a></li>
<li><a href="var/">var/</a></li>
</ul>
<hr>
</body>
</html>
```
#### B. Modification de l'unité

création de l'utilisateur web : 
```
[louis@node1 ~]$ sudo useradd web
[louis@node1 ~]$ cd /home/
[louis@node1 home]$ ls
admin  louis  web
[louis@node1 home]$ sudo passwd web
Changing password for user web.
New password:
BAD PASSWORD: The password is shorter than 8 characters
Retype new password:
passwd: all authentication tokens updated successfully.
```

création d'un fichier `testweb` dans `/srv`: 
```
[web@node1 srv]$ sudo mkdir testweb
[web@node1 srv]$ ls
testweb
[web@node1 srv]$ cd testweb
```

modifications des clausses : 
```
[louis@node1 ~]$ sudo cat /etc/systemd/system/web.service
[Unit]
Description=Very simple web service

[Service]
ExecStart=/bin/python3 -m http.server 8888
User=web
WorkingDirectory=/srv/testweb

[Install]
WantedBy=multi-user.target
```

création du fichier dans `/srv/testweb` : 
```
[web@node1 testweb]$ sudo touch mon_super_fichier
[web@node1 testweb]$ ls
mon_super_fichier
```
on fait en sorte que le fichier appartienne à web : 
```
[web@node1 srv]$ sudo chown web testweb/
[web@node1 srv]$ ls -al
total 0
drwxr-xr-x.  3 root root  21 Sep 25 17:24 .
dr-xr-xr-x. 17 root root 224 Sep 15 10:37 ..
drwxr-xr-x.  2 web  root  31 Sep 25 17:24 testweb
[web@node1 srv]$ cd testweb/
[web@node1 testweb]$ sudo chown web mon_super_fichier
[web@node1 testweb]$ ls -al
total 0
drwxr-xr-x. 2 web  root 31 Sep 25 17:24 .
drwxr-xr-x. 3 root root 21 Sep 25 17:24 ..
-rw-r--r--. 1 web  root  0 Sep 25 17:24 mon_super_fichier
```

vérification avec `curl` : 
```
[web@node1 testweb]$ curl 10.101.1.11:8888
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<title>Directory listing for /</title>
</head>
<body>
<h1>Directory listing for /</h1>
<hr>
<ul>
<li><a href="bin/">bin@</a></li>
<li><a href="boot/">boot/</a></li>
<li><a href="dev/">dev/</a></li>
<li><a href="etc/">etc/</a></li>
<li><a href="home/">home/</a></li>
<li><a href="lib/">lib@</a></li>
<li><a href="lib64/">lib64@</a></li>
<li><a href="media/">media/</a></li>
<li><a href="mnt/">mnt/</a></li>
<li><a href="opt/">opt/</a></li>
<li><a href="proc/">proc/</a></li>
<li><a href="root/">root/</a></li>
<li><a href="run/">run/</a></li>
<li><a href="sbin/">sbin@</a></li>
<li><a href="srv/">srv/</a></li>
<li><a href="sys/">sys/</a></li>
<li><a href="tmp/">tmp/</a></li>
<li><a href="usr/">usr/</a></li>
<li><a href="var/">var/</a></li>
</ul>
<hr>
</body>
</html>
```



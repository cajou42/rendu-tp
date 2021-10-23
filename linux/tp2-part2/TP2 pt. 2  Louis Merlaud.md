# TP2 pt. 2 : Maintien en condition opérationnelle

## I. Monitoring

### 2. Setup

on conmence par installé netdata sur les les machines que l'on veut monitoré (l'intalle est racourcit dans ce rendu) : 
```
[louis@web ~]$ sudo su -
[sudo] password for louis:
Sorry, try again.
[sudo] password for louis:
Last login: Wed Sep 15 10:43:46 CEST 2021 on tty1
[root@web ~]# bash <(curl -Ss https://my-netdata.io/kickstart-static64.sh)

  ^
  |.-.   .-.   .-.   .-.   .  netdata
  |   '-'   '-'   '-'   '-'   real-time performance monitoring, done right!
  +----+-----+-----+-----+-----+-----+-----+-----+-----+-----+-----+-----+--->



  ^
  |.-.   .-.   .-.   .-.   .-.   .  netdata              .-.   .-.   .-.   .-
  |   '-'   '-'   '-'   '-'   '-'   is installed now!  -'   '-'   '-'   '-'
  +----+-----+-----+-----+-----+-----+-----+-----+-----+-----+-----+-----+--->

[root@web ~]# logout
[louis@web ~]$
```

on vérifie que netdata est actif au démarage ainsi que son port + on l'ouvre : 
```
[louis@web ~]$ sudo systemctl is-enabled netdata
enabled
[louis@web ~]$ sudo ss -l -p -n -t
State          Recv-Q          Send-Q                   Local Address:Port                    Peer Address:Port         Process
LISTEN         0               128                            0.0.0.0:22                           0.0.0.0:*             users:(("sshd",pid=851,fd=5))
LISTEN         0               128                          127.0.0.1:8125                         0.0.0.0:*             users:(("netdata",pid=2242,fd=64))
LISTEN         0               128                            0.0.0.0:19999                        0.0.0.0:*             users:(("netdata",pid=2242,fd=5))
LISTEN         0               128                                  *:80                                 *:*             users:(("httpd",pid=1690,fd=4),("httpd",pid=879,fd=4),("httpd",pid=878,fd=4),("httpd",pid=877,fd=4),("httpd",pid=848,fd=4))
LISTEN         0               128                               [::]:22                              [::]:*             users:(("sshd",pid=851,fd=7))
LISTEN         0               128                              [::1]:8125                            [::]:*             users:(("netdata",pid=2242,fd=63))
LISTEN         0               128                               [::]:19999                           [::]:*             users:(("netdata",pid=2242,fd=6))

[louis@web ~]$ sudo firewall-cmd --add-port=19999/tcp --permanent
[sudo] password for louis:
success
[louis@web ~]$ sudo firewall-cmd --add-port=19999/tcp
success
```

on peut accéder à l'interface web de netdata en entrant dans un navigateur `http://web.tp2.linux:19999/` (dans le cas de la vm web.tp2.linux)


on met en place l'alerting via discord : 

dans un serveur discort, on créer un webhook via option > intégration > webhooks

on créer le fichier : `[louis@db netdata]$ sudo /opt/netdata/etc/netdata/edit-config health_alarm_notify.conf`

dans ce fichier on modifie : 
```
SEND_DISCORD="YES"
DISCORD_WEBHOOK_URL="https://discord.com/api/webhooks/897039750752509982/S4h7H3MFmxsb_Rvc20s0hxBtN448vs7-OuB_6FRFGQSXDabyeEZ0F-mB7tFIShjzViyD"
DEFAULT_RECIPIENT_DISCORD="alarms"
```

on vérifie avec `bash -x /opt/netdata/usr/libexec/netdata/plugins.d/alarm-notify.sh test "sysadmin"`

et on obtient bien les notif

on effectue la commande `sudo sed -i 's/curl=""/curl="\/opt\/netdata\/bin\/curl -k"/' /opt/netdata/etc/netdata/health_alarm_notify.conf` afin de permettre le bon fonctionnement de l'alerting

on configure une alerte pour lancer une alarte à 50% de remplissage de la RAM : 
```
[louis@web health.d]$ sudo cat ram-usage.conf
 alarm: ram_usage
    on: system.ram
lookup: average -1m percentage of used
 units: %
 every: 1m
  warn: $this > 50
  crit: $this > 90
  info: The percentage of RAM being used by the system.
```
on effectue un stress test sur la ram avec `stress --vm 2 --timeout 30` pour testé le system de notification

suite à ce test on reçois bien l'alerte via discord

## II. Backup


### 2. Partage NFS

on créer les dossiers necéssaire pour le bon fonctionnement du partage nfs : 
```
[louis@backup ~]$ sudo mkdir /srv/backup/
[sudo] password for louis:
[louis@backup ~]$ ls /srv/
backup
[louis@backup ~]$ cd /srv/backup/
[louis@backup backup]$ sudo mkdir web.tp2.linux db.tp2.linux
[louis@backup backup]$ ls
db.tp2.linux  web.tp2.linux
```

on installe le packet `nfs-utils` : `sudo dnf -y install nfs-utils`

on entre notre domaine dans le fichier `/etc/idmapd.conf` : 
```
[louis@backup ~]$ sudo cat /etc/idmapd.conf
Domain = tp2.linux
```

on créer un nouvel export dans `/etc/exports` : 
```
[louis@backup ~]$ sudo cat /etc/exports
/srv/backup/web.tp2.linux/ 10.102.1.0/24(rw,no_root_squash)
/srv/backup/db.tp2.linux/ 10.102.1.0/24(rw,no_root_squash)
```

on active le service : 
```
[louis@backup ~]$ systemctl enable --now rpcbind nfs-server
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
```

on modifie les paramètre du firewall : 
```
[louis@backup ~]$ sudo firewall-cmd --add-service=nfs
success
[louis@backup ~]$ sudo firewall-cmd --add-service={nfs3,mountd,rpc-bind}
success
[louis@backup ~]$ sudo firewall-cmd --runtime-to-permanent
success
```
on s'attaque au côté client sur `web.tp2.linux` : 

on installe aussi `nfs-utils` sur cette machine

comme sur sur `backup.tp2.linux` on change le domaine dans `/etc/idmapd.conf` : `Domain = tp2.linux`

et on créer aussi un dossier `/srv/backup`

on peut maintenant créer un point de montage depuis le dossier backup : 
```
[louis@web backup]$ sudo mount -t nfs backup.tp2.linux:/srv/backup/web.tp2.linux/ /srv/backup/
[sudo] password for louis:
[louis@web backup]$ df -hT
backup.tp2.linux:/srv/backup/web.tp2.linux nfs4      6.2G  2.4G  3.9G  38% /srv/backup
```

on vérifie si les fichiers sont partagé : 

sur `web.tp2.linux` : 
```
[louis@web ~]$ cd /srv/backup/
[louis@web backup]$ ls
[louis@web backup]$ sudo touch alu
[louis@web backup]$ ls
alu
```

sur` backup.tp2.linux` : 
```
[louis@backup ~]$ cd /srv/backup/web.tp2.linux/
[louis@backup web.tp2.linux]$ ls
alu
```
on fait en sorte que le montage ce fasse au démarage : 
```
[louis@web backup]$ sudo cat /etc/fstab
backup.tp2.linux:/srv/backup/web.tp2.linux /srv/backup          nfs     defaults        0 0
```

**BONUS**

on ajoute un disque dur à la vm `backup.tp2.linux` et créer un physical volume : 
```
[louis@backup ~]$ lsblk
sdb           8:16   0    8G  0 disk

[louis@backup ~]$ sudo pvcreate /dev/sdb
[sudo] password for louis:
  Physical volume "/dev/sdb" successfully created.
[louis@backup ~]$ sudo pvs
/dev/sdb      lvm2 ---   8.00g 8.00g
[louis@backup ~]$ sudo pvdisplay
 "/dev/sdb" is a new physical volume of "8.00 GiB"
  --- NEW Physical volume ---
  PV Name               /dev/sdb
  VG Name
  PV Size               8.00 GiB
  Allocatable           NO
  PE Size               0
  Total PE              0
  Free PE               0
  Allocated PE          0
  PV UUID               qmGGjw-ERsc-c65s-gnnn-o4CH-urvr-EX6GUC
```
on fait un volume group : 
```
[louis@backup ~]$ sudo vgcreate bonus /dev/sdb
[sudo] password for louis:
  Volume group "bonus" successfully created
[louis@backup ~]$ sudo vgs
  VG    #PV #LV #SN Attr   VSize  VFree
  bonus   1   0   0 wz--n- <8.00g <8.00g
[louis@backup ~]$ sudo vgdisplay
  --- Volume group ---
  VG Name               bonus
  System ID
  Format                lvm2
  Metadata Areas        1
  Metadata Sequence No  1
  VG Access             read/write
  VG Status             resizable
  MAX LV                0
  Cur LV                0
  Open LV               0
  Max PV                0
  Cur PV                1
  Act PV                1
  VG Size               <8.00 GiB
  PE Size               4.00 MiB
  Total PE              2047
  Alloc PE / Size       0 / 0
  Free  PE / Size       2047 / <8.00 GiB
  VG UUID               bnYeeV-o91V-JUl4-ER72-qorV-V0kj-VpltMW
```
on créer un logical volume de 5Go : 
```
[louis@backup ~]$ sudo lvcreate -L 5G bonus -n data_bonus
[sudo] password for louis:
  Logical volume "data_bonus" created.
[louis@backup ~]$ sudo lvs
  LV         VG    Attr       LSize   Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
  data_bonus bonus -wi-a-----   5.00g
[louis@backup ~]$ sudo lvdisplay
  --- Logical volume ---
  LV Path                /dev/bonus/data_bonus
  LV Name                data_bonus
  VG Name                bonus
  LV UUID                ciAHWF-lwG9-spX4-Idco-vI81-dphz-IGe2uh
  LV Write Access        read/write
  LV Creation host, time backup.tp2.linux, 2021-10-12 15:36:27 +0200
  LV Status              available
  # open                 0
  LV Size                5.00 GiB
  Current LE             1280
  Segments               1
  Allocation             inherit
  Read ahead sectors     auto
  - currently set to     8192
  Block device           253:2
```

on formate : 
```
[louis@backup ~]$ sudo mkfs -t ext4 /dev/bonus/data_bonus
mke2fs 1.45.6 (20-Mar-2020)
Creating filesystem with 1310720 4k blocks and 327680 inodes
Filesystem UUID: abe96b04-e53a-4ce2-a25e-b43713665d45
Superblock backups stored on blocks:
        32768, 98304, 163840, 229376, 294912, 819200, 884736

Allocating group tables: done
Writing inode tables: done
Creating journal (16384 blocks): done
Writing superblocks and filesystem accounting information: done
```

on monte la partition sur `/srv/backup` : 
```
[louis@backup ~]$ sudo mount /dev/bonus/data_bonus /srv/backup
[louis@backup ~]$ df -h
/dev/mapper/bonus-data_bonus  4.9G   20M  4.6G   1% /srv/backup
```
on monte cette partition automatiquement depuis `/etc/fstab`
```
[louis@backup ~]$ sudo cat /etc/fstab
/dev/bonus/data_bonus /srv/backup ext4 defaults 0 0
[louis@backup ~]$ sudo umount /srv/backup/
[louis@backup ~]$ sudo mount -av
/                        : ignored
/boot                    : already mounted
none                     : ignored
mount: /srv/backup does not contain SELinux labels.
       You just mounted an file system that supports labels which does not
       contain labels, onto an SELinux box. It is likely that confined
       applications will generate AVC messages and not be allowed access to
       this file system.  For more details see restorecon(8) and mount(8).
/srv/backup              : successfully mounted
```

### 3. Backup de fichiers

on fait le script de backup : 
```
[louis@backup srv]$ sudo cat tp2_backup.sh
#!/bin/bash
# backup.tp2.linux backup script
# louis - 13/10/2021

dest=$1
cible=$2
backup_name=$(date +backup_tp2_%y%m%d_%H%M%S.tar.gz)
backup_fullpath="$(pwd)/${backup_name}"

echo "${backup_name}"
echo "${backup_fullpath}"

if [[ ! -d ${dest} ]]; then
        echo "first argument is not a directory"
        exit 1
fi

if [[ $(id -u) -ne 0 ]]; then
        echo "sudo permission requiered"
        exit 1
fi

compresion(){
        tar cfz "${backup_fullpath}" "${dest}"
        rsync -av --remove-source-files "${backup_fullpath}" "${dest}"
}

compresion "${target}"
```

ensuite on teste ça (on créer le fichier "oui" au préalable simplement pour testé l'algo) : 
```
[louis@backup srv]$ cd backup/
[louis@backup backup]$ ls
[louis@backup backup]$ cd ..
[louis@backup srv]$ ls
backup  oui  tp2_backup.sh  z
[louis@backup srv]$ sudo ./tp2_backup.sh /srv/backup/ oui
backup_tp2_211014_150225.tar.gz
/srv/backup_tp2_211014_150225.tar.gz
tar: Removing leading `/' from member names
sending incremental file list
backup_tp2_211014_150225.tar.gz

sent 232 bytes  received 43 bytes  550.00 bytes/sec
total size is 115  speedup is 0.42
[louis@backup srv]$ cd backup/
[louis@backup backup]$ ls
backup_tp2_211014_150225.tar.gz
```
(aussi, le backup marche sur les dossiers) : 
```
[louis@backup srv]$ sudo ./tp2_backup.sh /srv/backup/ srv/oui
backup_tp2_211014_150416.tar.gz
/srv/backup_tp2_211014_150416.tar.gz
tar: Removing leading `/' from member names
sending incremental file list
backup_tp2_211014_150416.tar.gz

sent 437 bytes  received 43 bytes  960.00 bytes/sec
total size is 320  speedup is 0.67
[louis@backup srv]$ cd backup/
[louis@backup backup]$ ls
backup_tp2_211014_150225.tar.gz  backup_tp2_211014_150416.tar.gz    #ici on a donc le backup de "oui" et de "/srv/oui"
```
[script](https://github.com/cajou42/rendu-tp/blob/main/linux/tp2-part2/supplement/backup_web/tp2_backup.sh)

### 4. Unité de service

#### A. Unité de service

on créer une unité de service : 
```
[louis@backup ~]$ sudo cat /etc/systemd/system/tp2_backup.service
[Unit]
Description=Our own lil backup service (TP2)

[Service]
ExecStart=/srv/tp2_backup.sh /srv/backup /srv/oui
Type=oneshot
RemainAfterExit=no

[Install]
WantedBy=multi-user.target
[louis@backup ~]$ sudo systemctl daemon-reload
```

c'est l'heure du test : 
```
[louis@backup system]$ sudo systemctl enable tp2_backup
Created symlink /etc/systemd/system/multi-user.target.wants/tp2_backup.service → /etc/systemd/system/tp2_backup.service.
[louis@backup ~]$ sudo systemctl start tp2_backup
[louis@backup ~]$ cd /srv/backup/
[louis@backup backup]$ ls
backup_tp2_211014_150225.tar.gz  backup_tp2_211014_150416.tar.gz  backup_tp2_211014_152851.tar.gz
```
on constate un troisième archive dans le dossier backup, le service à donc bien fonctioné


#### B. Timer

on créer le timer : 
```
[louis@backup ~]$ sudo cat /etc/systemd/system/tp2_backup.timer
[Unit]
Description=Periodically run our TP2 backup script
Requires=tp2_backup.service

[Timer]
Unit=tp2_backup.service
OnCalendar=*-*-* *:*:00

[Install]
WantedBy=timers.target
```

on active le timer : 
```
[louis@backup ~]$ sudo systemctl start tp2_backup.timer
[louis@backup ~]$ sudo systemctl enable tp2_backup.timer
Created symlink /etc/systemd/system/timers.target.wants/tp2_backup.timer → /etc/systemd/system/tp2_backup.timer.
[louis@backup ~]$ sudo systemctl is-active tp2_backup.timer
active
[louis@backup ~]$ sudo systemctl is-enabled tp2_backup.timer
enabled
```

le test ! : 
```
[louis@backup ~]$ cd /srv/backup/
[louis@backup backup]$ ls
backup_tp2_211014_150225.tar.gz  backup_tp2_211014_152851.tar.gz
backup_tp2_211014_150416.tar.gz  backup_tp2_211014_153704.tar.gz
```

on obtient encore une nouvelle archive et quelque minutes plus tard on a ça : 
```
[louis@backup backup]$ ls
backup_tp2_211014_150225.tar.gz  backup_tp2_211014_152851.tar.gz  backup_tp2_211014_153836.tar.gz
backup_tp2_211014_150416.tar.gz  backup_tp2_211014_153704.tar.gz  backup_tp2_211014_153936.tar.gz
```

#### C. Contexte

(jusqu'à présent les test était effectué sur la machine `backup.tp2.linux`; le script, le service et le timer sont déplacer par conséquent sur la machine `web.tp2.linux`)

fichier du service : 
```
[louis@web backup]$ sudo cat /etc/systemd/system/tp2_backup.service
[Unit]
Description=Our own lil backup service (TP2)

[Service]
ExecStart=/srv/tp2_backup.sh /srv/backup/web.tp2.linux /var/www/sub-domains/com.web.nextcloud
Type=oneshot
RemainAfterExit=no

[Install]
WantedBy=multi-user.target
```
[tp2_backup.service](https://github.com/cajou42/rendu-tp/blob/main/linux/tp2-part2/supplement/backup_web/tp2_backup.service)

fichier du timer : 
```
[louis@web backup]$ sudo cat /etc/systemd/system/tp2_backup.timer
[sudo] password for louis:
[Unit]
Description=Periodically run our TP2 backup script
Requires=tp2_backup.service

[Timer]
Unit=tp2_backup.service
OnCalendar=Mon-Sun *-1-31 03:15:00

[Install]
WantedBy=timers.target
```
[tp2_backup.timer](https://github.com/cajou42/rendu-tp/blob/main/linux/tp2-part2/supplement/backup_web/tp2_backup.timer)

véfification du timer : 
```
[Install]
WantedBy=timers.target

[louis@web backup]$ sudo systemctl list-timers
Mon 2021-10-18 03:15:00 CEST  11h left   n/a                        n/a       tp2_backup.timer          tp2_backup.service
```
on retrouve bien les backups via le nfs : 
```
[louis@backup web.tp2.linux]$ ls
alu  backup_tp2_211017_155751.tar.gz
```

### 5. Backup de base de données

script du backup de la bdd : 
```
[louis@db srv]$ sudo cat tp2_backup_db.sh
#!/bin/bash
# db.tp2.linux db backup script
# louis - 17/10/2021

dest=$1
cible=$2

if [[ ! -d ${dest} ]]; then
        echo "first argument is not a directory"
        exit 1
fi

if [[ $(id -u) -ne 0 ]]; then
        echo "sudo permission requiered"
        exit 1
fi


mysqldump -u root --password=root ${cible} | tar cfz > backup_db_tp2_linux.sql.tar.gz
mv backup_db_tp2_linux.sql.tar.gz ${dest}
```

[script_db](https://github.com/cajou42/rendu-tp/blob/main/linux/tp2-part2/supplement/backup_db/tp2_backup_db.sh)

faisons un petit test afin de vérifier son bon fonctionement : 
```
[louis@db backup]$ ls
[louis@db backup]$ cd ..
[louis@db srv]$ sudo ./tp2_backup_db.sh /srv/backup/ nextcloud
tar: Old option 'f' requires an argument.
Try 'tar --help' or 'tar --usage' for more information.
mysqldump: Got errno 32 on write
[louis@db srv]$ cd backup/
[louis@db backup]$ ls
backup_db_tp2_linux.sql.tar.gz
```

on peut restaurer les donnés du fichiers en tapant cette commande : `mysql -h localhost -u root --password=root nextcloud < backup_db_tp2_linux.sql.tar.gz`

création du service : 
```
[louis@db ~]$ sudo cat /etc/systemd/system/tp2_backup_db.service
[Unit]
Description=backup for the database (TP2)

[Service]
ExecStart=/srv/tp2_backup_db.sh /srv/backup nextcloud
Type=oneshot
RemainAfterExit=no

[Install]
WantedBy=multi-user.target
```

[tp2_backup_db.service](https://github.com/cajou42/rendu-tp/blob/main/linux/tp2-part2/supplement/backup_db/tp2_backup_db.service)

on start le service : 
```
[louis@db ~]$ sudo systemctl daemon-reload
[louis@db ~]$ sudo systemctl start tp2_backup_db
[louis@db ~]$ sudo systemctl status tp2_backup_db
● tp2_backup_db.service - backup for the database (TP2)
   Loaded: loaded (/etc/systemd/system/tp2_backup_db.service; disabled; vendor preset: disabled)
   Active: inactive (dead)

Oct 18 17:26:33 db.tp2.linux systemd[1]: Starting backup for the database (TP2)...
Oct 18 17:26:33 db.tp2.linux tp2_backup_db.sh[3021]: tar: Old option 'f' requires an argument.
Oct 18 17:26:33 db.tp2.linux tp2_backup_db.sh[3021]: Try 'tar --help' or 'tar --usage' for more information.
Oct 18 17:26:33 db.tp2.linux tp2_backup_db.sh[3021]: mysqldump: Got errno 32 on write
Oct 18 17:26:33 db.tp2.linux systemd[1]: tp2_backup_db.service: Succeeded.
Oct 18 17:26:33 db.tp2.linux systemd[1]: Started backup for the database (TP2).
```

on s'occupe à présent du timer : 
```
[louis@db ~]$ sudo cat /etc/systemd/system/tp2_backup_db.timer
[Unit]
Description=Periodically run our TP2 database backup script
Requires=tp2_backup_db.service

[Timer]
Unit=tp2_backup_db.service
OnCalendar=Mon-Sun *-1-31 03:30:00

[Install]
WantedBy=timers.target
```

[tp2_backup_db.timer](https://github.com/cajou42/rendu-tp/blob/main/linux/tp2-part2/supplement/backup_db/tp2_backup_db.timer)

et on le start : 
```
[louis@db ~]$ sudo systemctl daemon-reload
[louis@db ~]$ sudo systemctl start tp2_backup_db.timer
[louis@db ~]$ sudo systemctl status tp2_backup_db.timer
● tp2_backup_db.timer - Periodically run our TP2 database backup script
   Loaded: loaded (/etc/systemd/system/tp2_backup_db.timer; disabled; vendor preset: disabled)
   Active: active (waiting) since Mon 2021-10-18 17:32:50 CEST; 11s ago
  Trigger: Mon 2022-01-31 03:30:00 CET; 3 months 13 days left

Oct 18 17:32:50 db.tp2.linux systemd[1]: Started Periodically run our TP2 database backup script.
```

on regarde quand le service va s'executer la prochaine fois : 
```
[louis@db ~]$ sudo systemctl list-timers
Tue 2021-10-19 03:30:00 CEST  9h left       n/a                    n/a          tp2_backup_db.timer      tp2_backup_db.service
```

## III. Reverse Proxy

### 2. Setup simple

on setup la nouvelle vm `front.tp2.linux`

Pour installer nginx, on télécharge d'abord le paquet epel-release (`sudo dnf install epel-release`) 
puis on fait un `sudo dnf install -y nginx`

on lance nginx : 
```
[louis@front ~]$ sudo systemctl start nginx
[louis@front ~]$ sudo systemctl status nginx
● nginx.service - The nginx HTTP and reverse proxy server
   Loaded: loaded (/usr/lib/systemd/system/nginx.service; disabled; vendor preset: disabled)
   Active: active (running) since Fri 2021-10-22 18:05:26 CEST; 14s ago
```

on fait en sorte qu'il ce lance au boot de la machine : 
```
[louis@front ~]$ sudo systemctl enable nginx
Created symlink /etc/systemd/system/multi-user.target.wants/nginx.service → /usr/lib/systemd/system/nginx.service.
[louis@front ~]$ sudo systemctl is-enabled nginx
enabled
```

on repère son port : 
```
[louis@front ~]$ sudo ss -l -p -n -t
LISTEN         0               128                            0.0.0.0:80                           0.0.0.0:*
 users:(("nginx",pid=5136,fd=8),("nginx",pid=5135,fd=8),("nginx",pid=5134,fd=8))
 
LISTEN         0               128                               [::]:80                              [::]:*
 users:(("nginx",pid=5136,fd=9),("nginx",pid=5135,fd=9),("nginx",pid=5134,fd=9))
 
[louis@front ~]$ sudo firewall-cmd --add-port=80/tcp
success
[louis@front ~]$ sudo firewall-cmd --add-port=80/tcp --permanent
success
```

on peut curl sur le pc ou depuis une autre vm le serveur : 
```
[louis@web ~]$ curl 10.102.1.14 | grep html
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  3429  100  3429    0     0  1674k      0 --:--:-- --:--:-- --:--:-- 3348k
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en">
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
            This is the default <tt>index.html</tt> page that is distributed
            <tt>/usr/share/nginx/html</tt>.
</html>
```

on explore la conf nginx  : 

utilisateur par défault : 
```
user nginx;
```

on repère le bloc `serveur` : 
```
    server {
        listen       80 default_server;
        listen       [::]:80 default_server;
        server_name  _;
        root         /usr/share/nginx/html;

        # Load configuration files for the default server block.
        include /etc/nginx/default.d/*.conf;

        location / {
        }

        error_page 404 /404.html;
            location = /40x.html {
        }

        error_page 500 502 503 504 /50x.html;
            location = /50x.html {
        }
    }
```

on repère les lignes d'inclusions : 
```
include /usr/share/nginx/modules/*.conf;

include /etc/nginx/mime.types;

include /etc/nginx/conf.d/*.conf;

include /etc/nginx/default.d/*.conf;
```

------------------------------------------------------

on s'attaque à la config d'nginx : 

on check le fichier host : 
```
[louis@front ~]$ cat /etc/hosts
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
10.102.1.11     web.tp2.linux
10.102.1.12     db.tp2.linux
10.102.1.13     backup.tp2.linux
```

on supprime le bloc `server` de la conf d'nginx : 
```
[louis@front ~]$ sudo cat /etc/nginx/nginx.conf
# For more information on configuration, see:
#   * Official English Documentation: http://nginx.org/en/docs/
#   * Official Russian Documentation: http://nginx.org/ru/docs/

user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log;
pid /run/nginx.pid;

# Load dynamic modules. See /usr/share/doc/nginx/README.dynamic.
include /usr/share/nginx/modules/*.conf;

events {
    worker_connections 1024;
}

http {
    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';

    access_log  /var/log/nginx/access.log  main;

    sendfile            on;
    tcp_nopush          on;
    tcp_nodelay         on;
    keepalive_timeout   65;
    types_hash_max_size 2048;

    include             /etc/nginx/mime.types;
    default_type        application/octet-stream;

    # Load modular configuration files from the /etc/nginx/conf.d directory.
    # See http://nginx.org/en/docs/ngx_core_module.html#include
    # for more information.
    include /etc/nginx/conf.d/*.conf;


# Settings for a TLS enabled server.
#
#    server {
#        listen       443 ssl http2 default_server;
#        listen       [::]:443 ssl http2 default_server;
#        server_name  _;
#        root         /usr/share/nginx/html;
#
#        ssl_certificate "/etc/pki/nginx/server.crt";
#        ssl_certificate_key "/etc/pki/nginx/private/server.key";
#        ssl_session_cache shared:SSL:1m;
#        ssl_session_timeout  10m;
#        ssl_ciphers PROFILE=SYSTEM;
#        ssl_prefer_server_ciphers on;
#
#        # Load configuration files for the default server block.
#        include /etc/nginx/default.d/*.conf;
#
#        location / {
#        }
#
#        error_page 404 /404.html;
#            location = /40x.html {
#        }
#
#        error_page 500 502 503 504 /50x.html;
#            location = /50x.html {
#        }
#    }

}
```

on créer le fichier `/etc/nginx/conf.d/web.tp2.linux.conf` et on le remplit : 
```
[louis@front conf.d]$ cat web.tp2.linux.conf
server {

    listen 80;

    server_name web.tp2.linux;

    location / {
        proxy_pass http://web.tp2.linux;
    }
}
```

## IV. Firewalling

### 2. Mise en place

#### A. Base de données

on configure la zone drop par defaut : 
```
[louis@db ~]$ sudo firewall-cmd --get-default-zone
public
[louis@db ~]$ sudo firewall-cmd --set-default-zone=drop
success
[louis@db ~]$ sudo firewall-cmd --zone=drop --add-interface=enp0s8 --permanent
Warning: ZONE_ALREADY_SET: 'enp0s8' already bound to 'drop'
success
```

on configure une zone pour le ssh : 
```
[louis@db ~]$ sudo firewall-cmd --new-zone=ssh --permanent
success
[louis@db ~]$ sudo firewall-cmd --reload
success
[louis@db ~]$ sudo firewall-cmd --zone=ssh --add-source=10.102.1.10/32 --permanent
success
[louis@db ~]$ sudo firewall-cmd --zone=ssh --add-port=22/tcp --permanent
success
```

on fait de même pour la db : 
```
[louis@db ~]$ sudo firewall-cmd --new-zone=db --permanent
success
[louis@db ~]$ sudo firewall-cmd --reload
success
[louis@db ~]$ sudo firewall-cmd --zone=db --add-source=10.102.1.11/32 --permanent
success
[louis@db ~]$ sudo firewall-cmd --zone=db --add-port=3306/tcp --permanent
success
```

on procède aux vérifications : 
```
[louis@db ~]$ sudo firewall-cmd --get-active-zones
db
  sources: 10.102.1.11/32
drop
  interfaces: enp0s8 enp0s3
ssh
  sources: 10.102.1.10/32

[louis@db ~]$ sudo firewall-cmd --get-default-zone
drop

[louis@db ~]$ sudo firewall-cmd --list-all --zone=drop
drop (active)
  target: DROP
  icmp-block-inversion: no
  interfaces: enp0s3 enp0s8
  sources:
  services:
  ports:
  protocols:
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
  rich rules:
[louis@db ~]$ sudo firewall-cmd --list-all --zone=db
db (active)
  target: default
  icmp-block-inversion: no
  interfaces:
  sources: 10.102.1.11/32
  services:
  ports: 3306/tcp
  protocols:
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
  rich rules:
[louis@db ~]$ sudo firewall-cmd --list-all --zone=ssh
ssh (active)
  target: default
  icmp-block-inversion: no
  interfaces:
  sources: 10.102.1.10/32
  services:
  ports: 22/tcp
  protocols:
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
  rich rules:
```

#### B. Serveur Web

pareil, on définie par defaut la zone drop : 
```
[louis@web ~]$ sudo firewall-cmd --get-default-zone
public
[louis@web ~]$ sudo firewall-cmd --set-default-zone=drop
success
[louis@web ~]$ sudo firewall-cmd --zone=drop --add-interface=enp0s8
Warning: ZONE_ALREADY_SET: 'enp0s8' already bound to 'drop'
success
```

zone pour le ssh : 
```
[louis@web ~]$ sudo firewall-cmd --new-zone=ssh --permanent
success
[louis@web ~]$ sudo firewall-cmd --reload
success
[louis@web ~]$ sudo firewall-cmd --zone=ssh --add-source=10.102.1.10/32 --permanent
success
[louis@web ~]$ sudo firewall-cmd --zone=ssh --add-port=22/tcp --permanent
success
```

zone pour le reverse proxy : 
```
[louis@web ~]$ sudo firewall-cmd --new-zone=reverse_proxy --permanent
success
[louis@web ~]$ sudo firewall-cmd --reload
success
[louis@web ~]$ sudo firewall-cmd --zone=reverse_proxy --add-source=10.102.1.14/32 --permanent
success
[louis@web ~]$ sudo firewall-cmd --zone=reverse_proxy --add-port=80/tcp --permanent
success
```

vérifications : 
```
[louis@web ~]$ sudo firewall-cmd --get-active-zones
drop
  interfaces: enp0s8 enp0s3
reverse_proxy
  sources: 10.102.1.14/32
ssh
  sources: 10.102.1.10/32
[louis@web ~]$ sudo firewall-cmd --get-default-zone
drop
[louis@web ~]$ sudo firewall-cmd --list-all --zone=drop
drop (active)
  target: DROP
  icmp-block-inversion: no
  interfaces: enp0s3 enp0s8
  sources:
  services:
  ports:
  protocols:
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
  rich rules:
[louis@web ~]$ sudo firewall-cmd --list-all --zone=ssh
ssh (active)
  target: default
  icmp-block-inversion: no
  interfaces:
  sources: 10.102.1.10/32
  services:
  ports: 22/tcp
  protocols:
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
  rich rules:
[louis@web ~]$ sudo firewall-cmd --list-all --zone=reverse_proxy
reverse_proxy (active)
  target: default
  icmp-block-inversion: no
  interfaces:
  sources: 10.102.1.14/32
  services:
  ports: 80/tcp
  protocols:
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
  rich rules:
```

#### C. Serveur de backup

zone drop par defaut : 
```
[louis@backup ~]$ sudo firewall-cmd --get-default-zone
[sudo] password for louis:
public
[louis@backup ~]$ sudo firewall-cmd --set-default-zone=drop
success
[louis@backup ~]$ sudo firewall-cmd --zone=drop --add-interface=enp0s8
Error: ZONE_CONFLICT: 'enp0s8' already bound to a zone
```

zone ssh : 
```
[louis@backup ~]$ sudo firewall-cmd --new-zone=ssh --permanent
success
[louis@backup ~]$ sudo firewall-cmd --reload
success
[louis@backup ~]$ sudo firewall-cmd --zone=ssh --add-source=10.102.1.10/32 --permanent
success
[louis@backup ~]$ sudo firewall-cmd --zone=ssh --add-port=22/tcp --permanent
success
```

zone nfs (accès uniquement par les machine effectuant un backup) : 
```
[louis@backup ~]$ sudo firewall-cmd --new-zone=nfs --permanent
success
[louis@backup ~]$ sudo firewall-cmd --zone=nfs --add-source=10.102.1.11/32 --permanent
success
[louis@backup ~]$ sudo firewall-cmd --zone=nfs --add-source=10.102.1.12/32 --permanent
success
```

vérifications : 
```
[louis@backup ~]$ sudo firewall-cmd --get-active-zones
drop
  interfaces: enp0s3
nfs
  sources: 10.102.1.11/32 10.102.1.12/32
public
  interfaces: enp0s8
ssh
  sources: 10.102.1.10/32
[louis@backup ~]$ sudo firewall-cmd --get-default-zone
drop
[louis@backup ~]$ sudo firewall-cmd --list-all --zone=drop
drop (active)
  target: DROP
  icmp-block-inversion: no
  interfaces: enp0s3
  sources:
  services:
  ports:
  protocols:
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
  rich rules:
[louis@backup ~]$ sudo firewall-cmd --list-all --zone=ssh
ssh (active)
  target: default
  icmp-block-inversion: no
  interfaces:
  sources: 10.102.1.10/32
  services:
  ports: 22/tcp
  protocols:
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
  rich rules:
[louis@backup ~]$ sudo firewall-cmd --list-all --zone=nfs
nfs (active)
  target: default
  icmp-block-inversion: no
  interfaces:
  sources: 10.102.1.11/32 10.102.1.12/32
  services:
  ports:
  protocols:
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
  rich rules:
```

#### D. Reverse Proxy

zone drop par defaut : 
```
[louis@front ~]$ sudo firewall-cmd --get-default-zone
[sudo] password for louis:
public
[louis@front ~]$ sudo firewall-cmd --set-default-zone=drop
success
[louis@front ~]$ sudo firewall-cmd --zone=drop --add-interface=enp0s8
Warning: ZONE_ALREADY_SET: 'enp0s8' already bound to 'drop'
success
```

zone ssh : 
```
[louis@front ~]$ sudo firewall-cmd --new-zone=ssh --permanent
success
[louis@front ~]$ sudo firewall-cmd --reload
success
[louis@front ~]$ sudo firewall-cmd --zone=ssh --add-source=10.102.1.10/32 --permanent
success
[louis@front ~]$ sudo firewall-cmd --zone=ssh --add-port=22/tcp --permanent
success
```

zone proxy (toute les machines du réseaux peuvent accéder au proxy) : 
```
[louis@front ~]$ sudo firewall-cmd --new-zone=proxy --permanent
success
[louis@front ~]$ sudo firewall-cmd --reload
success
[louis@front ~]$ sudo firewall-cmd --zone=proxy --add-source=10.102.1.0/24 --permanent
success
```

vérif : 
```
[louis@front ~]$ sudo firewall-cmd --get-active-zones
drop
  interfaces: enp0s8 enp0s3
proxy
  sources: 10.102.1.0/24
ssh
  sources: 10.102.1.10/32
[louis@front ~]$ sudo firewall-cmd --get-default-zone
drop
[louis@front ~]$ sudo firewall-cmd --list-all --zone=drop
drop (active)
  target: DROP
  icmp-block-inversion: no
  interfaces: enp0s3 enp0s8
  sources:
  services:
  ports:
  protocols:
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
  rich rules:
[louis@front ~]$ sudo firewall-cmd --list-all --zone=ssh
ssh (active)
  target: default
  icmp-block-inversion: no
  interfaces:
  sources: 10.102.1.10/32
  services:
  ports: 22/tcp
  protocols:
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
  rich rules:
[louis@front ~]$ sudo firewall-cmd --list-all --zone=proxy
proxy (active)
  target: default
  icmp-block-inversion: no
  interfaces:
  sources: 10.102.1.0/24
  services:
  ports:
  protocols:
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
  rich rules:
```

#### E. Tableau récap

| Machine            | IP            | Service                 | Port ouvert         | IPs autorisées                |
|--------------------|---------------|-------------------------|---------------------|-------------------------------|
| `web.tp2.linux`    | `10.102.1.11` | Serveur Web             | 80/tcp 19999/tcp    | 10.102.1.14/32                |
| `db.tp2.linux`     | `10.102.1.12` | Serveur Base de Données | 3306/tcp 19999/tcp  | 10.102.1.11/32                |
| `backup.tp2.linux` | `10.102.1.13` | Serveur de Backup (NFS) | 19999/tcp           | 10.102.1.11/32  10.102.1.12/32|
| `front.tp2.linux`  | `10.102.1.14` | Reverse Proxy           | 80/tcp 19999/tcp    | 10.102.1.0/24                 |

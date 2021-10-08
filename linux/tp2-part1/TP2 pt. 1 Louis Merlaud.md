# TP2 pt. 1 : Gestion de service

| Machine         | IP            | Service                 | Port ouvert | IP autorisées |
|-----------------|---------------|-------------------------|-------------|---------------|
| `web.tp2.linux` | `10.102.1.11` | Serveur Web             | 80/tcp      | X             |
| `db.tp2.linux`  | `10.102.1.12` | Serveur Base de Données | 3306/tcp    | `10.102.1.11` |


## I. Un premier serveur web

### 1. Installation


on installe le paquet httpd : `[louis@web ~]$ sudo dnf install -y httpd`

et on va dans le fichier de conf principal : 
```
[louis@web ~]$ sudo cat /etc/httpd/conf/httpd.conf

ServerRoot "/etc/httpd"

Listen 80

Include conf.modules.d/*.conf

User apache
Group apache


ServerAdmin root@localhost


<Directory />
    AllowOverride none
    Require all denied
</Directory>


DocumentRoot "/var/www/html"

<Directory "/var/www">
    AllowOverride None
    Require all granted
</Directory>

<Directory "/var/www/html">
    Options Indexes FollowSymLinks

    AllowOverride None

    Require all granted
</Directory>

<IfModule dir_module>
    DirectoryIndex index.html
</IfModule>

<Files ".ht*">
    Require all denied
</Files>

ErrorLog "logs/error_log"

LogLevel warn

<IfModule log_config_module>
    LogFormat "%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\"" combined
    LogFormat "%h %l %u %t \"%r\" %>s %b" common

    <IfModule logio_module>
      LogFormat "%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\" %I %O" combinedio
    </IfModule>


    CustomLog "logs/access_log" combined
</IfModule>

<IfModule alias_module>


    ScriptAlias /cgi-bin/ "/var/www/cgi-bin/"

</IfModule>

<Directory "/var/www/cgi-bin">
    AllowOverride None
    Options None
    Require all granted
</Directory>

<IfModule mime_module>
    TypesConfig /etc/mime.types

    AddType application/x-compress .Z
    AddType application/x-gzip .gz .tgz



    AddType text/html .shtml
    AddOutputFilter INCLUDES .shtml
</IfModule>

AddDefaultCharset UTF-8

<IfModule mime_magic_module>
    MIMEMagicFile conf/magic
</IfModule>


EnableSendfile on

IncludeOptional conf.d/*.conf
```

on démarre et on fait en sorte qu'il ce lance au  httpd : 
```
[louis@web ~]$ sudo systemctl start httpd
[louis@web ~]$ systemctl is-active httpd
active
[louis@web ~]$ sudo systemctl enable httpd
Created symlink /etc/systemd/system/multi-user.target.wants/httpd.service → /usr/lib/systemd/system/httpd.service.
[louis@web ~]$ sudo systemctl is-enabled httpd
enabled
```

on ouvre le port 80 en tcp : 
```
[louis@web ~]$ sudo firewall-cmd --add-port=80/tcp --permanent
[sudo] password for louis:
success
[louis@web ~]$ sudo firewall-cmd --reload
success
```

on effectue un test avec `[louis@web ~]$ sudo curl localhost | grep http` (on utilise grep pour condenser un peu le résultat) : 
```
[louis@web ~]$ sudo curl localhost | grep http
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  7621  100  7621    0     0  3721k      0 --:--:-- --:--:-- --:--:-- 3721k
          <a href="https://rockylinux.org/"><strong>Rocky Linux
        <a href="https://httpd.apache.org/">Apache Webserver</strong></a>:
        <code>/etc/httpd/conf.d/welcome.conf</code>.</p>
        <a href="https://nginx.org">Nginx</strong></a>:
          <a href="https://rockylinux.org/" id="rocky-poweredby"><img src= "icons/poweredby.png" alt="[ Powered by Rocky Linux ]" /></a> <!-- Rocky -->
      <a href="https://apache.org">Apache&trade;</a> is a registered trademark of <a href="https://apache.org">the Apache Software Foundation</a> in the United States and/or other countries.<br />
      <a href="https://nginx.org">NGINX&trade;</a> is a registered trademark of <a href="https://">F5 Networks, Inc.</a>.
```

on tape l'ip de la vm dans un navigateur web, et on remarque que la page s'affiche bien.

### 2. Avancer vers la maîtrise du service

on peut activer apache automatiquement au démarrage de la machine avec la commande `sudo systemctl enable httpd` et on peut vérifier avec `sudo systemctl is-enabled httpd` (*ces commandes figurent dans leurs intégralité plus haut dans le rendu*)

on affiche le fichier `httpd.service` : 
```
[louis@web ~]$ cat /usr/lib/systemd/system/httpd.service
# See httpd.service(8) for more information on using the httpd service.

# Modifying this file in-place is not recommended, because changes
# will be overwritten during package upgrades.  To customize the
# behaviour, run "systemctl edit httpd" to create an override unit.

# For example, to pass additional options (such as -D definitions) to
# the httpd binary at startup, create an override unit (as is done by
# systemctl edit) and enter the following:

#       [Service]
#       Environment=OPTIONS=-DMY_DEFINE

[Unit]
Description=The Apache HTTP Server
Wants=httpd-init.service
After=network.target remote-fs.target nss-lookup.target httpd-init.service
Documentation=man:httpd.service(8)

[Service]
Type=notify
Environment=LANG=C

ExecStart=/usr/sbin/httpd $OPTIONS -DFOREGROUND
ExecReload=/usr/sbin/httpd $OPTIONS -k graceful
# Send SIGWINCH for graceful stop
KillSignal=SIGWINCH
KillMode=mixed
PrivateTmp=true

[Install]
WantedBy=multi-user.target
```

on trouve dans `/etc/httpd/conf/httpd.conf` ou ce trouve l'user qui est utilisé par le service : 
```
User apache
Group apache
```

on regarde que le processus apache tourne bien avec l'utilisateur définie dans `/etc/httpd/conf/httpd.conf` : 
```
[louis@web ~]$ ps -ef
apache       872     847  0 16:43 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
apache       873     847  0 16:43 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
apache       874     847  0 16:43 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
apache       875     847  0 16:43 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
```

on vérifie que l'user apache à accès au document dans `/var/www/` : 
```
[louis@web ~]$ cd /var/www/
[louis@web www]$ ls -al
total 4
drwxr-xr-x.  4 root root   33 Sep 29 11:57 .
drwxr-xr-x. 22 root root 4096 Sep 29 11:57 ..
drwxr-xr-x.  2 root root    6 Jun 11 17:35 cgi-bin
drwxr-xr-x.  2 root root    6 Jun 11 17:35 html
```

avec les permission affiché à gauche on peut voir `r-x` qui concerne l'user apache, ce qui veut dire qu'il peut lire le fichier et l'executer, mais pas le modifier.

on change l'utilisateur apache : 
```
[louis@web ~]$ cat /etc/passwd
apache:x:48:48:Apache:/usr/share/httpd:/sbin/nologin

[louis@web ~]$ sudo useradd -u 5230 -d /usr/share/httpd webadmin
useradd: warning: the home directory already exists.
Not copying any file from skel directory into it.
[louis@web ~]$ sudo passwd webadmin
Changing password for user webadmin.
New password:
BAD PASSWORD: The password contains the user name in some form
Retype new password:
passwd: all authentication tokens updated successfully.

[louis@web ~]$ sudo usermod -aG apache webadmin
```

on change d'user dans `/etc/httpd/conf/httpd.conf` : 
```
[louis@web ~]$ sudo cat /etc/httpd/conf/httpd.conf
User webadmin
```
on regarde si le changement c'est effectué : 
```
[louis@web ~]$ sudo systemctl restart httpd
[louis@web ~]$ ps -ef
webadmin    1977    1975  0 13:16 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
webadmin    1978    1975  0 13:16 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
webadmin    1979    1975  0 13:16 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
webadmin    1980    1975  0 13:16 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
```

on change de port et on ouvre le nouveau : 
```
[louis@web ~]$ sudo cat /etc/httpd/conf/httpd.conf
Listen 456
[louis@web ~]$ sudo firewall-cmd --add-port=456/tcp --permanent
success
[louis@web ~]$ sudo firewall-cmd --remove-port=80/tcp --permanent
success
[louis@web ~]$ sudo ss -l -p -n -t
State           Recv-Q          Send-Q                   Local Address:Port                   Peer Address:Port         Process
LISTEN          0               128                            0.0.0.0:22                          0.0.0.0:*             users:(("sshd",pid=845,fd=5))
LISTEN          0               128                                  *:456                               *:*             users:(("httpd",pid=2225,fd=4),("httpd",pid=2224,fd=4),("httpd",pid=2223,fd=4),("httpd",pid=2219,fd=4))
LISTEN          0               128                               [::]:22                             [::]:*             users:(("sshd",pid=845,fd=7))
```
apache est bien ouvert sur le nouveau port

on test : 
```
[louis@web ~]$ sudo curl localhost:456 | grep html
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  7621  100  7621    0     0  7442k      0 --:--:-- --:--:-- --:--:-- 7442k
<!doctype html>
<html>
      html {
        You can add content to the directory <code>/var/www/html/</code>.
</html>
```

[premier fichier de conf httpd](https://github.com/cajou42/rendu-tp/blob/main/linux/tp2-part1/fichier_de_conf/httpd.conf)

## II. Une stack web plus avancée

### 2. Setup

#### A. Serveur Web et NextCloud

on ajoute le ligne `IncludeOptional sites-enabled/*` dans `/etc/httpd/conf/httpd.conf` sur le serveur web

on commence par installer EPEL avec `dnf install epel-release`
on comtinue à installer les package nécessaire (la plupart des ces packages sont des package php) :
```
sudo dnf install https://rpms.remirepo.net/enterprise/remi-release-8.rpm
sudo dnf module list php
sudo dnf module enable php:remi-7.4
sudo dnf install wget zip unzip libxml2 openssl php74-php php74-php-ctype php74-php-curl php74-php-gd php74-php-iconv php74-php-json php74-php-libxml php74-php-mbstring php74-php-openssl php74-php-posix php74-php-session php74-php-xml php74-php-zip php74-php-zlib php74-php-pdo php74-php-mysqlnd php74-php-intl php74-php-bcmath php74-php-gmp
```
on vérifie que httpd est actif au démarage : 
```
[louis@web ~]$ sudo systemctl is-enabled httpd
enabled
```
on créer le fichier de configuration dans `/etc/httpd/sites-available/com.yourdomain.nextcloud` : 
```
[louis@web httpd]$ sudo cat com.web.nextcloud
<VirtualHost *:80>
  DocumentRoot /var/www/sub-domains/com.web.nextcloud/html/
  ServerName  nextcloud.web.com

  <Directory /var/www/sub-domains/com.web.nextcloud/html/>
    Require all granted
    AllowOverride All
    Options FollowSymLinks MultiViews

    <IfModule mod_dav.c>
      Dav off
    </IfModule>
  </Directory>
</VirtualHost>
```
on créer un lien dans le nouveau dossier `/etc/httpd/sites-enabled/` créer au préalable : 
```
[louis@web httpd]$ sudo ln -s /etc/httpd/sites-available/com.web.nextcloud /etc/httpd/sites-enabled/
[louis@web httpd]$ cd sites-enabled/
[louis@web sites-enabled]$ ls
com.web.nextcloud
```
on créer le dossier où l'instance de nextcloud va être installé : 
```
[louis@web sites-enabled]$ sudo mkdir -p /var/www/sub-domains/com.web.nextcloud/html
```

on récupère la timezone : 
```
[louis@web sites-enabled]$ timedatectl
               Local time: Wed 2021-10-06 10:59:32 CEST
           Universal time: Wed 2021-10-06 08:59:32 UTC
                 RTC time: Wed 2021-10-06 08:59:32
                ▶Time zone: Europe/Paris (CEST, +0200)
System clock synchronized: no
              NTP service: inactive
          RTC in local TZ: no
```

on modifie les paramètres php : 
```
[louis@web ~]$ sudo cat /etc/opt/remi/php74/php.ini | grep date.timezone
date.timezone = Europe/Paris
```

on récupère l'install de nextcloud en .zip : 
```
[louis@web ~]$ sudo wget https://download.nextcloud.com/server/releases/nextcloud-22.2.0.zip
```

on le dézip ensuite : 
```
[louis@web ~]$ unzip nextcloud-22.2.0.zip
```
on copie l'ensemble du dossier nexcloud dans le dossier d'instance créer plus tôt (`/var/www/sub domains/com.web.nextcloud/html`) : 
```
[louis@web nextcloud]$ sudo cp -Rf * /var/www/sub-domains/com.web.nextcloud/html/
```
on fait en sorte que ce dossier appartient à l'user gérant apache : 
```
[louis@web ~]$ sudo chown -Rf apache.apache /var/www/sub-domains/com.web.nextcloud/html
[louis@web ~]$ ls -al /var/www/sub-domains/com.web.nextcloud/html
total 120
drwxr-xr-x. 13 webadmin apache  4096 Oct  6 11:26 .
drwxr-xr-x.  3 root     root      18 Oct  6 11:24 ..
drwxr-xr-x. 43 webadmin apache  4096 Oct  6 11:26 3rdparty
drwxr-xr-x. 48 webadmin apache  4096 Oct  6 11:26 apps
-rw-r--r--.  1 webadmin apache 19327 Oct  6 11:26 AUTHORS
drwxr-xr-x.  2 webadmin apache    67 Oct  6 11:26 config
-rw-r--r--.  1 webadmin apache  3924 Oct  6 11:26 console.php
-rw-r--r--.  1 webadmin apache 34520 Oct  6 11:26 COPYING
drwxr-xr-x. 22 webadmin apache  4096 Oct  6 11:26 core
-rw-r--r--.  1 webadmin apache  5163 Oct  6 11:26 cron.php
-rw-r--r--.  1 webadmin apache   156 Oct  6 11:26 index.html
-rw-r--r--.  1 webadmin apache  3454 Oct  6 11:26 index.php
drwxr-xr-x.  6 webadmin apache   125 Oct  6 11:26 lib
-rw-r--r--.  1 webadmin apache   283 Oct  6 11:26 occ
drwxr-xr-x.  2 webadmin apache    23 Oct  6 11:26 ocm-provider
drwxr-xr-x.  2 webadmin apache    55 Oct  6 11:26 ocs
drwxr-xr-x.  2 webadmin apache    23 Oct  6 11:26 ocs-provider
-rw-r--r--.  1 webadmin apache  3139 Oct  6 11:26 public.php
-rw-r--r--.  1 webadmin apache  5340 Oct  6 11:26 remote.php
drwxr-xr-x.  4 webadmin apache   133 Oct  6 11:26 resources
-rw-r--r--.  1 webadmin apache    26 Oct  6 11:26 robots.txt
-rw-r--r--.  1 webadmin apache  2452 Oct  6 11:26 status.php
drwxr-xr-x.  3 webadmin apache    35 Oct  6 11:26 themes
drwxr-xr-x.  2 webadmin apache    43 Oct  6 11:26 updater
-rw-r--r--.  1 webadmin apache   422 Oct  6 11:26 version.php
```
on met le fichier `com.web.nextcloud` dans `sites-available/` : 
```
[louis@web httpd]$ sudo mv com.web.nextcloud sites-available/
```

on restart httpd : 
```
[louis@web html]$ systemctl restart httpd
==== AUTHENTICATING FOR org.freedesktop.systemd1.manage-units ====
Authentication is required to restart 'httpd.service'.
Authenticating as: louis
Password:
==== AUTHENTICATION COMPLETE ====
```

si on ce connecte sur l'ip de la vm, on tombe sur l'interface de log de nextcloud.

[second fichier de conf httpd](https://github.com/cajou42/rendu-tp/blob/main/linux/tp2-part1/fichier_de_conf/httpd2.conf(part2))
[fichier de conf nextcloud](https://github.com/cajou42/rendu-tp/blob/main/linux/tp2-part1/fichier_de_conf/web.tp2.linux.nextcloud)

#### B. Base de données

sur la vm `db.tp2.linux` on installe la base de donnée mariadb avec `sudo dnf install mariadb-server`
et on la démare :`sudo systemctl enable mariadb` + `sudo systemctl restart mariadb`

on effectue la commande `sudo mysql_secure_installation` et on défine un password pour le root : 
```
[louis@db ~]$ sudo mysql_secure_installation

NOTE: RUNNING ALL PARTS OF THIS SCRIPT IS RECOMMENDED FOR ALL MariaDB
      SERVERS IN PRODUCTION USE!  PLEASE READ EACH STEP CAREFULLY!

In order to log into MariaDB to secure it, we'll need the current
password for the root user.  If you've just installed MariaDB, and
you haven't set the root password yet, the password will be blank,
so you should just press enter here.

Enter current password for root (enter for none):
OK, successfully used password, moving on...

Setting the root password ensures that nobody can log into the MariaDB
root user without the proper authorisation.

Set root password? [Y/n] y
New password:
Re-enter new password:
Password updated successfully!
Reloading privilege tables..
 ... Success!


By default, a MariaDB installation has an anonymous user, allowing anyone
to log into MariaDB without having to have a user account created for
them.  This is intended only for testing, and to make the installation
go a bit smoother.  You should remove them before moving into a
production environment.

Remove anonymous users? [Y/n]
 ... Success!

Normally, root should only be allowed to connect from 'localhost'.  This
ensures that someone cannot guess at the root password from the network.

Disallow root login remotely? [Y/n]
 ... Success!

By default, MariaDB comes with a database named 'test' that anyone can
access.  This is also intended only for testing, and should be removed
before moving into a production environment.

Remove test database and access to it? [Y/n]
 - Dropping test database...
 ... Success!
 - Removing privileges on test database...
 ... Success!

Reloading the privilege tables will ensure that all changes made so far
will take effect immediately.

Reload privilege tables now? [Y/n]
 ... Success!

Cleaning up...

All done!  If you've completed all of the above steps, your MariaDB
installation should now be secure.

Thanks for using MariaDB!
```

on récupère le port utilisé par mariadb : 
```
[louis@db ~]$ sudo ss -l -p -n -t
State      Recv-Q     Send-Q         Local Address:Port         Peer Address:Port    Process
LISTEN     0          128                  0.0.0.0:22                0.0.0.0:*        users:(("sshd",pid=840,fd=5))
LISTEN     0          128                     [::]:22                   [::]:*        users:(("sshd",pid=840,fd=7))
LISTEN     0          80                         *:3306                    *:*        users:(("mysqld",pid=38476,fd=21))
```
on voit que le service tourne sous le port 3306

on ce connecte à la base de donné avec `sudo mysql -u root -p` et on entre les commandes suivantes : 
```
MariaDB [(none)]> CREATE USER 'nextcloud'@'10.102.1.11' IDENTIFIED BY 'meow';
Query OK, 0 rows affected (0.000 sec)

MariaDB [(none)]> CREATE DATABASE IF NOT EXISTS nextcloud CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
Query OK, 1 row affected (0.001 sec)

MariaDB [(none)]> GRANT ALL PRIVILEGES ON nextcloud.* TO 'nextcloud'@'10.102.1.11';
Query OK, 0 rows affected (0.000 sec)

MariaDB [(none)]> FLUSH PRIVILEGES;
Query OK, 0 rows affected (0.000 sec)
```
on teste le bon fonctionnement de la base de donné : 
```
[louis@web ~]$ sudo firewall-cmd --add-port=3306/tcp --permanant
[sudo] password for louis:
success
[louis@web ~]$ sudo firewall-cmd --reload
success
[louis@web ~]$ mysql -u nextcloud -h 10.102.1.12 -p
Enter password:
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 18
Server version: 5.5.5-10.3.28-MariaDB MariaDB Server

Copyright (c) 2000, 2021, Oracle and/or its affiliates.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.
```

exploration de la bdd : 
```
mysql> SHOW DATABASES;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| nextcloud          |
+--------------------+
2 rows in set (0.00 sec)

mysql> USE nextcloud;
Database changed
mysql> SHOW TABLES;
Empty set (0.00 sec)

```

commande permetant de lister tous les user : 
```
MariaDB [(none)]> SELECT User FROM mysql.user;
+-----------+
| User      |
+-----------+
| nextcloud |
| root      |
| root      |
| root      |
+-----------+
4 rows in set (0.001 sec)
```


#### C. Finaliser l'installation de NextCloud

sur le pc on fait correspondre l'ip de la vm à un url (`10.102.1.11 web.tp2.linux`) dans le fichier `C:\Windows\ System32\drivers\etc\hosts`

on peut ainsi ce connecter à nextcloud via l'url `http://web.tp2.linux` : 
```
PS C:\WINDOWS\system32\drivers\etc> cat hosts
# Copyright (c) 1993-2009 Microsoft Corp.
#
# This is a sample HOSTS file used by Microsoft TCP/IP for Windows.
#
# This file contains the mappings of IP addresses to host names. Each
# entry should be kept on an individual line. The IP address should
# be placed in the first column followed by the corresponding host name.
# The IP address and the host name should be separated by at least one
# space.
#
# Additionally, comments (such as these) may be inserted on individual
# lines or following the machine name denoted by a '#' symbol.
#
# For example:
#
#      102.54.94.97     rhino.acme.com          # source server
#       38.25.63.10     x.acme.com              # x client host

# localhost name resolution is handled within DNS itself.
#       127.0.0.1       localhost
#       ::1             localhost

▶10.102.1.11 web.tp2.linux
```

on remplie la section base de donné avec les information précédament entré : 

> nom : nextcloud
> password : meow
> nom de la bdd : nextcloud
> host : 10.102.1.12:3306

on regarde dans la base de donnée le nombre de tables qui ont été créer : 
```
mysql> USE nextcloud
Reading table information for completion of table and column names
You can turn off this feature to get a quicker startup with -A

Database changed
mysql> SHOW FULL TABLES;
+-----------------------------+------------+
| Tables_in_nextcloud         | Table_type |
+-----------------------------+------------+
| oc_accounts                 | BASE TABLE |
| oc_accounts_data            | BASE TABLE |
| oc_activity                 | BASE TABLE |
| oc_activity_mq              | BASE TABLE |
| oc_addressbookchanges       | BASE TABLE |
| oc_addressbooks             | BASE TABLE |
| oc_appconfig                | BASE TABLE |
| oc_authtoken                | BASE TABLE |
| oc_bruteforce_attempts      | BASE TABLE |
| oc_calendar_invitations     | BASE TABLE |
| oc_calendar_reminders       | BASE TABLE |
| oc_calendar_resources       | BASE TABLE |
| oc_calendar_resources_md    | BASE TABLE |
| oc_calendar_rooms           | BASE TABLE |
| oc_calendar_rooms_md        | BASE TABLE |
| oc_calendarchanges          | BASE TABLE |
| oc_calendarobjects          | BASE TABLE |
| oc_calendarobjects_props    | BASE TABLE |
| oc_calendars                | BASE TABLE |
| oc_calendarsubscriptions    | BASE TABLE |
| oc_cards                    | BASE TABLE |
| oc_cards_properties         | BASE TABLE |
| oc_circles_circle           | BASE TABLE |
| oc_circles_event            | BASE TABLE |
| oc_circles_member           | BASE TABLE |
| oc_circles_membership       | BASE TABLE |
| oc_circles_mount            | BASE TABLE |
| oc_circles_mountpoint       | BASE TABLE |
| oc_circles_remote           | BASE TABLE |
| oc_circles_share_lock       | BASE TABLE |
| oc_circles_token            | BASE TABLE |
| oc_collres_accesscache      | BASE TABLE |
| oc_collres_collections      | BASE TABLE |
| oc_collres_resources        | BASE TABLE |
| oc_comments                 | BASE TABLE |
| oc_comments_read_markers    | BASE TABLE |
| oc_dav_cal_proxy            | BASE TABLE |
| oc_dav_shares               | BASE TABLE |
| oc_direct_edit              | BASE TABLE |
| oc_directlink               | BASE TABLE |
| oc_federated_reshares       | BASE TABLE |
| oc_file_locks               | BASE TABLE |
| oc_filecache                | BASE TABLE |
| oc_filecache_extended       | BASE TABLE |
| oc_files_trash              | BASE TABLE |
| oc_flow_checks              | BASE TABLE |
| oc_flow_operations          | BASE TABLE |
| oc_flow_operations_scope    | BASE TABLE |
| oc_group_admin              | BASE TABLE |
| oc_group_user               | BASE TABLE |
| oc_groups                   | BASE TABLE |
| oc_jobs                     | BASE TABLE |
| oc_known_users              | BASE TABLE |
| oc_login_flow_v2            | BASE TABLE |
| oc_mail_accounts            | BASE TABLE |
| oc_mail_aliases             | BASE TABLE |
| oc_mail_attachments         | BASE TABLE |
| oc_mail_classifiers         | BASE TABLE |
| oc_mail_coll_addresses      | BASE TABLE |
| oc_mail_mailboxes           | BASE TABLE |
| oc_mail_message_tags        | BASE TABLE |
| oc_mail_messages            | BASE TABLE |
| oc_mail_provisionings       | BASE TABLE |
| oc_mail_recipients          | BASE TABLE |
| oc_mail_tags                | BASE TABLE |
| oc_mail_trusted_senders     | BASE TABLE |
| oc_migrations               | BASE TABLE |
| oc_mimetypes                | BASE TABLE |
| oc_mounts                   | BASE TABLE |
| oc_notifications            | BASE TABLE |
| oc_notifications_pushhash   | BASE TABLE |
| oc_oauth2_access_tokens     | BASE TABLE |
| oc_oauth2_clients           | BASE TABLE |
| oc_preferences              | BASE TABLE |
| oc_privacy_admins           | BASE TABLE |
| oc_properties               | BASE TABLE |
| oc_ratelimit_entries        | BASE TABLE |
| oc_recent_contact           | BASE TABLE |
| oc_richdocuments_assets     | BASE TABLE |
| oc_richdocuments_direct     | BASE TABLE |
| oc_richdocuments_wopi       | BASE TABLE |
| oc_schedulingobjects        | BASE TABLE |
| oc_share                    | BASE TABLE |
| oc_share_external           | BASE TABLE |
| oc_storages                 | BASE TABLE |
| oc_storages_credentials     | BASE TABLE |
| oc_systemtag                | BASE TABLE |
| oc_systemtag_group          | BASE TABLE |
| oc_systemtag_object_mapping | BASE TABLE |
| oc_talk_attendees           | BASE TABLE |
| oc_talk_bridges             | BASE TABLE |
| oc_talk_commands            | BASE TABLE |
| oc_talk_internalsignaling   | BASE TABLE |
| oc_talk_rooms               | BASE TABLE |
| oc_talk_sessions            | BASE TABLE |
| oc_text_documents           | BASE TABLE |
| oc_text_sessions            | BASE TABLE |
| oc_text_steps               | BASE TABLE |
| oc_trusted_servers          | BASE TABLE |
| oc_twofactor_backupcodes    | BASE TABLE |
| oc_twofactor_providers      | BASE TABLE |
| oc_user_status              | BASE TABLE |
| oc_user_transfer_owner      | BASE TABLE |
| oc_users                    | BASE TABLE |
| oc_vcategory                | BASE TABLE |
| oc_vcategory_to_object      | BASE TABLE |
| oc_webauthn                 | BASE TABLE |
| oc_whats_new                | BASE TABLE |
+-----------------------------+------------+
108 rows in set (0.00 sec)
```
# TP2 pt. 1 : Gestion de service

| Machine         | IP            | Service                 | Port ouvert | IP autorisées |
|-----------------|---------------|-------------------------|-------------|---------------|
| `web.tp2.linux` | `10.102.1.11` | Serveur Web             | 80/456      | ?             |


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

## II. Une stack web plus avancée

### 1. Intro
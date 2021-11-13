# TP3 : Your own shiet

## sommaire : 
- présentation du projet 
- installation du serveur web avec apache 
- installation du proxy avec nginx 
    * conf principale d'nginx
    * mise en place du protocole https
    * amélioration du https
    * Loadbalancing
- monitoring 
- firewall
- script

## présentation du projet : 
Ce projet à pour but d'éberger un serveur web générant simplement un mot de passe. 

pour ce faire : 

* on va mettre en place un serveur web via apache
* on va faire un proxy via nginx qui proposera les fonctions suivantes :
    *  connection sécurisé via https
    *  loadbalancing avec répartition des charge et tolérance de panne
    *  les machines sont monitorié via netdata
    *  on configurera les firewalls selon le principe du moindre privilège

---

## installation du serveur web avec apache : 
on commence par créer un nouvelle vm `web1.tp3.linux`

on y installe le service apache avec la commande `sudo dnf install httpd`
- on active le service avec `sudo systemctl start httpd`
- on l'active au démarage de la machine avec `sudo systemctl enable httpd` 
- on ouvre le port sous lequel apache tourne (port 80 par defaut) avec `sudo firewall-cmd --add-port=80/tcp --permanent`
- on peut maintenant se connecter à la vm avec l'ip de cette dernière

jusque là nous avons un service apache fonctionel, faisons en sorte qu'il héberge notre page web : 

pour ce faire on va dans `sudo vim /etc/httpd/conf/httpd.conf` et on modifie la ligne suivante : 

```
DocumentRoot "/var/www/html/gen-pwd"
```
ici `gen-pwd` est le nom de mon dossier contenant mon fichier html.

---
## installation du proxy avec nginx : 
on créer une nouvelle vm `proxy.tp3.linux`

### conf principale d'nginx
on installe nginx, pour ce faire on doit d'abord installer le package epel-release : `sudo dnf install epel-release` `sudo dnf install nginx`
- comme pour apache, on active le service `sudo systemctl start nginx`
- et on l'actoive au démarage `sudo systemctl enable nginx`
- on ouvre le port d'nginx (port 80 par default) : `sudo firewall-cmd --add-port=80/tcp --permanent`

pour mettre en place le reverse proxy, on modifie des fichiers de conf nginx : 

dans un premier temps on vas supprimer le bloc serveur dans `/etc/nginx/nginx.conf`, cela va nous permettre de ne plus présenter la page d'accueil d'nginx par default

on créer un fichier `/etc/nginx/conf.d/web.tp2.linux.conf` : 
```
[louis@proxy ~]$ sudo cat /etc/nginx/conf.d/web.tp2.linux.conf
server {
    listen 80;

    server_name web1.tp3.linux;

    location / {
        proxy_pass http://web1.tp3.linux;
    }
}
```
pour décortiquer un peu le fichier : 
- "listen 80" correspond au port sur lequel nginx va écouter pour notre serveur web
- "server_name web1.tp3.linux" correspond au nom de domaine du serveur web
- le bloc "location" permet de renvoyer le trafic sur notre serveur web

### mise en place du protocole https

avant de modifier la conf nginx, on va générer un clé et un certificat via la commande `openssl`
```
[louis@proxy ~]$ sudo openssl req -new -newkey rsa:2048 -days 365 -nodes -x509 -keyout server.key -out server.crt
[...]
Country Name (2 letter code) [XX]:FR
State or Province Name (full name) []:Nouvelle_Aquitaine
Locality Name (eg, city) [Default City]:Bordeaux
Organization Name (eg, company) [Default Company Ltd]:
Organizational Unit Name (eg, section) []:
Common Name (eg, your name or your server's hostname) []:web1.tp3.linux
Email Address []:
```

on déplace la clé et le certificat obtenue : 
```
[louis@proxy ~]$ sudo mv server.key /etc/pki/tls/private/web.tp2.linux.key
[louis@proxy ~]$ sudo mv server.crt /etc/pki/tls/certs/web.tp2.linux.crt
```
enfin on change les permissions de ces fichiers : 
```
[louis@proxy ~]$ sudo chown root:root /etc/pki/tls/private/web.tp2.linux.key
[louis@proxy ~]$ sudo chown root:root /etc/pki/tls/certs/web.tp2.linux.crt
[louis@proxy ~]$ sudo chmod 400 /etc/pki/tls/private/web.tp2.linux.key
[louis@proxy ~]$ sudo chmod 644 /etc/pki/tls/certs/web.tp2.linux.crt
```

on rajoute dans `web.tp2.linux.conf` la clé et le certificat, on change le port sur écoute et on ajoute du chiffrement : 
```
[louis@proxy ~]$ sudo cat /etc/nginx/conf.d/web.tp2.linux.conf
server {
    listen 443 ssl;
    ssl_certificate /etc/pki/tls/certs/web.tp2.linux.crt;
    ssl_certificate_key /etc/pki/tls/private/web.tp2.linux.key;
    server_name web1.tp3.linux;
    location / {
        proxy_pass http://web1.tp3.linux;
    }
}
```

étant donné que l'on a changé le port, on l'ouvre : `sudo firewall-cmd --add-port=443/tcp --permanent`

on ajoute la ligne `10.15.1.3 web1.tp3.linux` au fichier host du pc, ensuite via un navigateur, on peut s'y connecté avec l'url : `https://web1.tp3.linux`

### amélioration du https : 

on génère de la conf depuis le site de [digital ocean](https://www.digitalocean.com/community/tools/nginx?domains.0.server.domain=toto.com&domains.0.https.certType=custom&domains.0.https.sslCertificate=%2Ftoto%2Fuu.crt&domains.0.https.sslCertificateKey=%2Ftoto%2Fuu.key&domains.1.server.domain=web1.tp3.linux&global.https.letsEncryptRoot=%2Fetc%2Fpki%2Ftls%2Fprivate%2Fweb.tp2.linux.key&global.https.letsEncryptCertRoot=%2Fetc%2Fpki%2Ftls%2Fcerts%2Fweb.tp2.linux.crt&global.app.lang=fr) : 

dans `nginx.conf` on rajoute les ligne suivantes : 
```
 # Mozilla Intermediate configuration (permet de définir les algos de chiffrements)
    ssl_protocols          TLSv1.2 TLSv1.3;
    ssl_ciphers            ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384;
```
```
    # SSL (permet de définir le protocole ssl)
    ssl_session_timeout    1d;
    ssl_session_cache      shared:SSL:10m;
    ssl_session_tickets    off;
```
une fois ces changements fait, on redémare le service avec `sudo systemctl restart nginx` 

---

### Loadbalancing

on créer un clone de la vm `web1.tp3.linux` que l'on appelle `web2.tp3.linux` elle est sous l'ip `10.15.1.4`

commence par créer un fichier `/etc/nginx/conf.d/load-balancer.conf` : 

```
[louis@proxy conf.d]$ sudo cat load-balancer.conf
   upstream backend {
      least_conn;        # cette ligne permet de rédiriger l'utilisateur vers le serveur possédant le moins de connexions
      server 10.15.1.2;
      server 10.15.1.4;
   }


server {
   listen 443 ssl;
   server_name web1.tp3.linux;
   ssl_certificate /etc/pki/tls/certs/web.tp2.linux.crt;
   ssl_certificate_key /etc/pki/tls/private/web.tp2.linux.key;
   ssl_protocols TLSv1.2 TLSv1.3;

   location / {
      proxy_pass http://backend;
   }
}
```
et on restart nginx

maintenant, même si `web1.tp3.linux` est down, `web2.tp3.linux` peut prendre le relais et inversement

---

### monitoring : 

pour le monotoring on va utiliser un simple netdata que l'on installe avec`bash <(curl -Ss https://my-netdata.io/kickstart-static64.sh)` (il faut ouvrir une session sudo avec `sudo su -` pour pouvoir l'executer)

on ouvre le port 19999, c'est le port sous lequel tourne netdata : `sudo firewall-cmd --add-port=19999/tcp --permanent`

on peut accéder à l'interface netdata depuis un navigateur en rajoutant `:1999` à la fin de cette dernière
exemple : `https://web1.tp3.linux:19999/`
on peut aussi le voir avec une requête curl : `curl 10.15.1.3:19999`

maintenant on met en place un alerting via discord : 

dans un serveur discord, on créer un webhook via option > intégration > webhooks

on créer le fichier : `sudo /opt/netdata/etc/netdata/edit-config health_alarm_notify.conf`

dans ce fichier on modifie : 
```
SEND_DISCORD="YES"
DISCORD_WEBHOOK_URL="https://discord.com/api/webhooks/897039750752509982/S4h7H3MFmxsb_Rvc20s0hxBtN448vs7-OuB_6FRFGQSXDabyeEZ0F-mB7tFIShjzViyD"
DEFAULT_RECIPIENT_DISCORD="alarms"
```

on peut vérifier le bon fonctinement des alertes avec `bash -x /opt/netdata/usr/libexec/netdata/plugins.d/alarm-notify.sh test "sysadmin"`

on effectue la commande `sudo sed -i 's/curl=""/curl="\/opt\/netdata\/bin\/curl -k"/' /opt/netdata/etc/netdata/health_alarm_notify.conf` afin de permettre le bon fonctionnement de l'alerting

on configure une alerte pour lancer une alarte à 50% de remplissage de la RAM(on doit créer un fichier dans `/opt/netdata/etc/netdata/health.d/ram-usage.conf`) : 
```
[louis@proxy health.d]$ sudo cat ram-usage.conf
 alarm: ram_usage
    on: system.ram
lookup: average -1m percentage of used
 units: %
 every: 1m
  warn: $this > 50
  crit: $this > 90
  info: The percentage of RAM being used by the system.
```

on peut maintenant faire des test avec `stress --vm 2 --timeout 30` (stress est un package contenue dans epel-release)

---

### firewall : 

Comme dit dans l'introduction, les firewalls des machines seront configurées selon le principe du moindre privilège,
ce qui veut que l'on ne va autorisé uniquement les flux essentiels entres les machines et rien d'autres.

dans ce cas ci : 
* La zone par defaut sera la zone drop et non la zone public, cela nous permet de rejeté tous les packets indésirables (uniquement pour les serveurs webs) : `sudo firewall-cmd --set-default-zone=drop`
* Sur toute les machines on autorise le ssh en créant une zone adéquate : 
```
[louis@proxy ~]$ sudo firewall-cmd --new-zone=ssh --permanent
success
[louis@proxy ~]$ sudo firewall-cmd --reload
success
[louis@proxy ~]$ sudo firewall-cmd --zone=ssh --add-source=10.15.1.1/32 --permanent
success
[louis@proxy ~]$ sudo firewall-cmd --zone=ssh --add-port=22/tcp --permanent
success
```
* ensuite on créer une autre zone qui permetera de definir les connexions autorisées, pour le reverse proxy on autorise donc les ip du réseau, et sur les serveurs webs celle du reverse proxy (dans le cas des serveurs rajoutera le port du reverse proxy) :
```
#exemple sur le reverse proxy
[louis@proxy ~]$ sudo firewall-cmd --new-zone=proxy --permanent
success
[louis@proxy ~]$ sudo firewall-cmd --reload
success
[louis@proxy ~]$ sudo firewall-cmd --zone=proxy --add-source=10.15.1.0/24 --permanent
success
# uniquement pour les serveurs
[louis@web1 ~]$ sudo firewall-cmd --zone=reverse_proxy --add-port=80/tcp --permanent
success
``` 
* ensuite on vérifie tout ça (et on oublie pas de faire `sudo firewall-cmd --reload` pour appliquer les changements) : 
```
#exemple sur le reverse proxy
[louis@proxy ~]$ sudo firewall-cmd --get-active-zones
drop
  interfaces: enp0s8 enp0s3
proxy
  sources: 10.15.1.0/24
ssh
  sources: 10.15.1.1/32
[louis@proxy ~]$ sudo firewall-cmd --get-default-zone
drop
[louis@proxy ~]$ sudo firewall-cmd --list-all --zone=drop
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
[louis@proxy ~]$ sudo firewall-cmd --list-all --zone=proxy
proxy (active)
  target: default
  icmp-block-inversion: no
  interfaces:
  sources: 10.15.1.0/24
  services:
  ports:
  protocols:
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
  rich rules:
[louis@proxy ~]$ sudo firewall-cmd --list-all --zone=ssh
ssh (active)
  target: default
  icmp-block-inversion: no
  interfaces:
  sources: 10.15.1.1/32
  services:
  ports: 22/tcp
  protocols:
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
  rich rules:
```

---

### script : 

[script reverse proxy](https://github.com/cajou42/rendu-tp/blob/main/linux/tp3/supplement/script_proxy.sh)

[script serveur web](https://github.com/cajou42/rendu-tp/blob/main/linux/tp3/supplement/script_serveur_web.sh)

---

## tableau du reseau

| Machine            | IP            | Service                 | Port ouvert         | IPs autorisées                |
|--------------------|---------------|-------------------------|---------------------|-------------------------------|
| `web1.tp3.linux`   | `10.15.1.2/24`| Serveur Web             | 80/tcp 19999/tcp    | 10.15.1.3/32                  |
| `proxy.tp3.linux`  | `10.15.1.3/24`| Reverse Proxy           | 443/tcp 19999/tcp   | 10.15.1.0/24                  |
| `web2.tp3.linux`   | `10.15.1.4/24`| Serveur Web             | 80/tcp 19999/tcp    | 10.15.1.3/32                  |



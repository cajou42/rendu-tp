# I) Exploration locale en solo

### 1) Affichage d'informations sur la pile TCP/IP locale

en ligne de commande :

commande : ```PS C:\Users\louis> ipconfig /all```

Carte Wifi : 
```Carte réseau sans fil Wi-Fi :

   Suffixe DNS propre à la connexion. . . : auvence.co
   Description. . . . . . . . . . . . . . : Intel(R) Wireless-AC 9461
   Adresse physique . . . . . . . . . . . : 9C-FC-E8-36-7B-EE
   DHCP activé. . . . . . . . . . . . . . : Oui
   Configuration automatique activée. . . : Oui
   Adresse IPv6 de liaison locale. . . . .: fe80::cce6:f28:9d:6311%41(préféré)
   Adresse IPv4. . . . . . . . . . . . . .: 10.33.1.41(préféré)
   Masque de sous-réseau. . . . . . . . . : 255.255.252.0
   Bail obtenu. . . . . . . . . . . . . . : lundi 13 septembre 2021 08:52:57
   Bail expirant. . . . . . . . . . . . . : lundi 13 septembre 2021 12:43:13
   Passerelle par défaut. . . . . . . . . : 10.33.3.253
   Serveur DHCP . . . . . . . . . . . . . : 10.33.3.254
   IAID DHCPv6 . . . . . . . . . . . : 161283304
   DUID de client DHCPv6. . . . . . . . : 00-01-00-01-27-DE-88-C6-9C-FC-E8-36-7B-EE
   Serveurs DNS. . .  . . . . . . . . . . : 10.33.10.2
                                       10.33.10.148
                                       10.33.10.155
   NetBIOS sur Tcpip. . . . . . . . . . . : Activé
   ```
   ici, l'adresse ip est 10.33.1.41, 
   l'adresse mac est 9C-FC-E8-36-7B-EE,
   les nom est "Carte réseau sans fil Wi-Fi"

mon pc ne possède pas de carte éthernet, donc pas d'information lier à cette dernière.

la gateway de la carte wifi est : 10.33.3.253 (information accessible avec "ipconfig /all" )

en interface graphique : 

chemin : ```Panneau de configuration\Réseau et Internet\Connexions réseau > carte WIFI```

![](https://i.imgur.com/9yZPpY1.png)

l'ip est 10.33.1.41
la MAC est 9C-FC-E8-36-7B-EE
la gateway est 10.33.3.253

dans le réseau d'YNOV la gateway sert de point de passage d'un réseau à un autre

### 2. Modifications des informations

#### _A. Modification d'adresse IP (part 1)_

chemin :(depuis ```Panneau de configuration\Réseau et Internet\Connexions réseau > carte WIFI```) ```propriété > protocole internet version 4 (TCP/ipv4)```

![](https://i.imgur.com/zeJW6Kx.png)

il est possible de perdre la connection durant cette opération si l'adresse entré n'est pas présente sur le réseau, ou déjà attribué.

#### _B. Table ARP_

commande : ```arp -a```

```
Interface : 10.33.1.41 --- 0x29
  Adresse Internet      Adresse physique      Type
  10.33.1.3             94-e6-f7-95-6a-87     dynamique
  10.33.1.122           14-f6-d8-e6-67-48     dynamique
  10.33.2.46            80-30-49-cb-43-8f     dynamique
  10.33.2.84            e4-b3-18-48-36-68     dynamique
  10.33.2.173           34-2e-b7-47-f9-28     dynamique
  10.33.2.199           c8-e2-65-69-56-a4     dynamique
  10.33.2.208           a4-b1-c1-72-13-98     dynamique
  10.33.2.219           70-66-55-27-0e-49     dynamique
  10.33.2.223           74-df-bf-8e-50-13     dynamique
  10.33.3.5             74-d8-3e-0d-06-b0     dynamique
  10.33.3.253           00-12-00-40-4c-bf     dynamique
  10.33.3.255           ff-ff-ff-ff-ff-ff     statique
  224.0.0.22            01-00-5e-00-00-16     statique
  224.0.0.251           01-00-5e-00-00-fb     statique
  224.0.0.252           01-00-5e-00-00-fc     statique
  239.255.255.250       01-00-5e-7f-ff-fa     statique
  255.255.255.255       ff-ff-ff-ff-ff-ff     statique

  ```
  
  la mac de la gateway est 00-12-00-40-4c-bf, on peut l'identifier grace à son addresse ip (ici 10.33.3.253) et à l'ip de l'interface (ici 10.33.1.41)
  
  trois ping :
  
  ```PS C:\Users\louis> ping 10.33.1.76

Envoi d’une requête 'Ping'  10.33.1.76 avec 32 octets de données :
Réponse de 10.33.1.76 : octets=32 temps=81 ms TTL=64
Réponse de 10.33.1.76 : octets=32 temps=9 ms TTL=64
Réponse de 10.33.1.76 : octets=32 temps=287 ms TTL=64
Réponse de 10.33.1.76 : octets=32 temps=99 ms TTL=64

Statistiques Ping pour 10.33.1.76:
    Paquets : envoyés = 4, reçus = 4, perdus = 0 (perte 0%),
Durée approximative des boucles en millisecondes :
    Minimum = 9ms, Maximum = 287ms, Moyenne = 119ms
    
    PS C:\Users\louis> ping 10.33.1.103

Envoi d’une requête 'Ping'  10.33.1.103 avec 32 octets de données :
Réponse de 10.33.1.41 : Impossible de joindre l’hôte de destination.
Réponse de 10.33.1.41 : Impossible de joindre l’hôte de destination.
Réponse de 10.33.1.41 : Impossible de joindre l’hôte de destination.
Réponse de 10.33.1.41 : Impossible de joindre l’hôte de destination.

Statistiques Ping pour 10.33.1.103:
    Paquets : envoyés = 4, reçus = 4, perdus = 0 (perte 0%),
    
    
    PS C:\Users\louis> ping 10.33.2.8

Envoi d’une requête 'Ping'  10.33.2.8 avec 32 octets de données :
Réponse de 10.33.2.8 : octets=32 temps=48 ms TTL=64
Réponse de 10.33.2.8 : octets=32 temps=60 ms TTL=64
Réponse de 10.33.2.8 : octets=32 temps=77 ms TTL=64
Réponse de 10.33.2.8 : octets=32 temps=87 ms TTL=64

Statistiques Ping pour 10.33.2.8:
    Paquets : envoyés = 4, reçus = 4, perdus = 0 (perte 0%),
Durée approximative des boucles en millisecondes :
    Minimum = 48ms, Maximum = 87ms, Moyenne = 68ms
  ```  
on affichement maintenant la table arp : "arp -a"

```

Interface : 10.33.1.41 --- 0x29
  Adresse Internet      Adresse physique      Type
  10.33.1.3             94-e6-f7-95-6a-87     dynamique
  10.33.1.76            e0-cc-f8-7a-4f-4a     dynamique
  10.33.1.90            d0-ab-d5-18-55-f6     dynamique
  10.33.1.103           18-65-90-ce-f5-63     dynamique
  10.33.1.122           14-f6-d8-e6-67-48     dynamique
  10.33.2.8             a4-5e-60-ed-0b-27     dynamique
  10.33.2.62            b0-7d-64-b1-98-d3     dynamique
  10.33.2.84            e4-b3-18-48-36-68     dynamique
  10.33.2.173           34-2e-b7-47-f9-28     dynamique
  10.33.2.199           c8-e2-65-69-56-a4     dynamique
  10.33.2.209           a4-b1-c1-72-13-98     dynamique
  10.33.2.219           70-66-55-27-0e-49     dynamique
  10.33.2.223           74-df-bf-8e-50-13     dynamique
  10.33.3.33            c8-58-c0-63-5a-92     dynamique
  10.33.3.81            3c-58-c2-9d-98-38     dynamique
  10.33.3.139           34-cf-f6-37-2c-fb     dynamique
  10.33.3.249           58-96-1d-17-43-f5     dynamique
  10.33.3.253           00-12-00-40-4c-bf     dynamique
  10.33.3.255           ff-ff-ff-ff-ff-ff     statique
  224.0.0.22            01-00-5e-00-00-16     statique
  224.0.0.251           01-00-5e-00-00-fb     statique
  224.0.0.252           01-00-5e-00-00-fc     statique
  239.255.255.250       01-00-5e-7f-ff-fa     statique
  255.255.255.255       ff-ff-ff-ff-ff-ff     statique

  ```
  on remarque que les trois valeur pingé (10.33.1.76, 10.33.1.103, 10.33.2.8) sont dans l'interface 10.33.1.41
  
  mac de 10.33.1.76 : e0-cc-f8-7a-4f-4a 
  mac de 10.33.1.103 : 18-65-90-ce-f5-63
  mac de 10.33.2.8 : a4-5e-60-ed-0b-27
  
####  *C.nmap*
  
  On effectue un scan ping avec la commande ` nmap -sP -v  10.33.0.0/22`, le "-v" nous permet de voir si une addresse est libre 
  
  output : 
  ```
    Nmap scan report for 10.33.0.2 [host down]
  ```  
  chaque addresse ayant un "[host down]" à côté est une addresse libre, l'addresse 10.33.0.2 est un exemple
  
  on affiche ensuite la table arp avec `arp -a`
  
  output : 
  ```
Interface : 10.33.1.41 --- 0x18
  Adresse Internet      Adresse physique      Type
  10.33.0.1             3c-58-c2-9d-98-38     dynamique
  10.33.0.7             9c-bc-f0-b6-1b-ed     dynamique
  10.33.0.43            2c-8d-b1-94-38-bf     dynamique
  10.33.0.60            e2-ee-36-a5-0b-8a     dynamique
  10.33.0.96            ca-4f-f4-af-8f-0c     dynamique
  10.33.0.119           18-56-80-70-9c-48     dynamique
  10.33.0.148           e6-aa-26-ee-23-b7     dynamique
  10.33.0.211           e8-d0-fc-ef-9e-af     dynamique
  10.33.0.228           7c-5c-f8-2d-40-42     dynamique
  10.33.1.70            30-57-14-94-de-fb     dynamique
  10.33.1.166           1a-41-0b-54-a5-a0     dynamique
  10.33.1.238           50-76-af-88-6c-0b     dynamique
  10.33.1.242           34-7d-f6-5a-20-da     dynamique
  10.33.1.243           34-7d-f6-5a-20-da     dynamique
  10.33.2.3             e0-2b-e9-42-5e-91     dynamique
  10.33.2.151           10-32-7e-38-50-c3     dynamique
  10.33.2.173           34-2e-b7-47-f9-28     dynamique
  10.33.2.182           f4-4e-e3-c0-ed-29     dynamique
  10.33.2.188           d8-f3-bc-c2-f5-39     dynamique
  10.33.2.216           08-d2-3e-35-00-a2     dynamique
  10.33.3.59            02-47-cd-3d-d4-e9     dynamique
  10.33.3.74            40-ec-99-f0-81-b0     dynamique
  10.33.3.80            3c-58-c2-9d-98-38     dynamique
  10.33.3.89            f0-9e-4a-52-94-f0     dynamique
  10.33.3.105           54-14-f3-b5-aa-36     dynamique
  10.33.3.146           7c-50-79-f1-7c-9b     dynamique
  10.33.3.148           bc-76-5e-d2-75-86     dynamique
  10.33.3.168           12-88-c1-71-b7-a0     dynamique
  10.33.3.187           96-fd-87-13-4b-ee     dynamique
  10.33.3.206           78-31-c1-cf-cb-26     dynamique
  10.33.3.218           8c-85-90-65-6a-52     dynamique
  10.33.3.248           34-7d-f6-5a-89-99     dynamique
  10.33.3.253           00-12-00-40-4c-bf     dynamique
  10.33.3.255           ff-ff-ff-ff-ff-ff     statique
  224.0.0.2             01-00-5e-00-00-02     statique
  224.0.0.22            01-00-5e-00-00-16     statique
  224.0.0.251           01-00-5e-00-00-fb     statique
  224.0.0.252           01-00-5e-00-00-fc     statique
  239.255.255.250       01-00-5e-7f-ff-fa     statique
  255.255.255.255       ff-ff-ff-ff-ff-ff     statique
  ```
####  *D. Modification d'adresse IP (part 2)*
  
  On a répéré au préalable l'ip 10.33.0.46 qui est libre
  
  On refait un `nmap -sP -v 10.33.0.0/22`
```
Warning: The -sP option is deprecated. Please use -sn
Starting Nmap 7.92 ( https://nmap.org ) at 2021-09-16 09:53 Paris, Madrid (heure dÆÚtÚ)
Initiating ARP Ping Scan at 09:53
Scanning 1023 hosts [1 port/host]
Completed ARP Ping Scan at 09:54, 31.12s elapsed (1023 total hosts)
Initiating Parallel DNS resolution of 103 hosts. at 09:54
Completed Parallel DNS resolution of 103 hosts. at 09:54, 0.20s elapsed
Nmap scan report for 10.33.0.0 [host down]
Nmap scan report for 10.33.0.1 [host down]
Nmap scan report for 10.33.0.2 [host down]
Nmap scan report for 10.33.0.3 [host down]
Nmap scan report for 10.33.0.4 [host down]
Nmap scan report for 10.33.0.5 [host down]
Nmap scan report for 10.33.0.6
Host is up (0.13s latency).
MAC Address: 84:5C:F3:80:32:07 (Intel Corporate)
Nmap scan report for 10.33.0.7
Host is up (0.31s latency).
MAC Address: 9C:BC:F0:B6:1B:ED (Xiaomi Communications)
Nmap scan report for 10.33.0.8 [host down]
Nmap scan report for 10.33.0.9 [host down]
Nmap scan report for 10.33.0.10 [host down]
Nmap scan report for 10.33.0.11 [host down]
Nmap scan report for 10.33.0.12 [host down]
Nmap scan report for 10.33.0.13 [host down]
Nmap scan report for 10.33.0.14 [host down]
Nmap scan report for 10.33.0.15 [host down]
Nmap scan report for 10.33.0.16 [host down]
Nmap scan report for 10.33.0.17 [host down]
Nmap scan report for 10.33.0.18 [host down]
Nmap scan report for 10.33.0.19
Host is up (0.52s latency).
MAC Address: D4:A3:3D:C8:CA:67 (Apple)
Nmap scan report for 10.33.0.20 [host down]
Nmap scan report for 10.33.0.21
Host is up (0.041s latency).
MAC Address: B0:FC:36:CE:9C:89 (CyberTAN Technology)
Nmap scan report for 10.33.0.22 [host down]
Nmap scan report for 10.33.0.23 [host down]
Nmap scan report for 10.33.0.24 [host down]
Nmap scan report for 10.33.0.25 [host down]
Nmap scan report for 10.33.0.26 [host down]
Nmap scan report for 10.33.0.27
Host is up (0.058s latency).
MAC Address: A8:64:F1:8B:1D:4D (Intel Corporate)
Nmap scan report for 10.33.0.28 [host down]
Nmap scan report for 10.33.0.29 [host down]
Nmap scan report for 10.33.0.30 [host down]
Nmap scan report for 10.33.0.31
Host is up (0.68s latency).
MAC Address: FA:C5:6D:60:4B:4C (Unknown)
Nmap scan report for 10.33.0.32 [host down]
Nmap scan report for 10.33.0.33 [host down]
Nmap scan report for 10.33.0.34
Host is up (0.086s latency).
MAC Address: AC:67:5D:83:9F:E6 (Intel Corporate)
Nmap scan report for 10.33.0.35 [host down]
Nmap scan report for 10.33.0.36 [host down]
Nmap scan report for 10.33.0.37 [host down]
Nmap scan report for 10.33.0.38 [host down]
Nmap scan report for 10.33.0.39 [host down]
Nmap scan report for 10.33.0.40 [host down]
Nmap scan report for 10.33.0.41 [host down]
Nmap scan report for 10.33.0.42 [host down]
Nmap scan report for 10.33.0.43
Host is up (0.056s latency).
MAC Address: 2C:8D:B1:94:38:BF (Intel Corporate)
Nmap scan report for 10.33.0.44 [host down]
Nmap scan report for 10.33.0.45 [host down]
Nmap scan report for 10.33.0.47 [host down]
Nmap scan report for 10.33.0.48 [host down]
Nmap scan report for 10.33.0.49 [host down]
Nmap scan report for 10.33.0.50 [host down]
Nmap scan report for 10.33.0.51 [host down]
Nmap scan report for 10.33.0.52 [host down]
Nmap scan report for 10.33.0.53 [host down]
Nmap scan report for 10.33.0.54 [host down]
Nmap scan report for 10.33.0.55 [host down]
Nmap scan report for 10.33.0.56 [host down]
Nmap scan report for 10.33.0.57
Host is up (0.17s latency).
MAC Address: F0:18:98:8C:6F:CD (Apple)
Nmap scan report for 10.33.0.58 [host down]
Nmap scan report for 10.33.0.59
Host is up (0.21s latency).
MAC Address: E4:0E:EE:73:73:96 (Huawei Technologies)
Nmap scan report for 10.33.0.60 [host down]
Nmap scan report for 10.33.0.61 [host down]
Nmap scan report for 10.33.0.62 [host down]
Nmap scan report for 10.33.0.63 [host down]
Nmap scan report for 10.33.0.64 [host down]
Nmap scan report for 10.33.0.65 [host down]
Nmap scan report for 10.33.0.66 [host down]
Nmap scan report for 10.33.0.67 [host down]
Nmap scan report for 10.33.0.68 [host down]
Nmap scan report for 10.33.0.69 [host down]
Nmap scan report for 10.33.0.70 [host down]
Nmap scan report for 10.33.0.71
Host is up (0.036s latency).
MAC Address: F0:03:8C:35:FE:47 (AzureWave Technology)
Nmap scan report for 10.33.0.72 [host down]
Nmap scan report for 10.33.0.73 [host down]
Nmap scan report for 10.33.0.74 [host down]
Nmap scan report for 10.33.0.75 [host down]
Nmap scan report for 10.33.0.76 [host down]
Nmap scan report for 10.33.0.77 [host down]
Nmap scan report for 10.33.0.78 [host down]
Nmap scan report for 10.33.0.79 [host down]
Nmap scan report for 10.33.0.80 [host down]
Nmap scan report for 10.33.0.81 [host down]
Nmap scan report for 10.33.0.82 [host down]
Nmap scan report for 10.33.0.83 [host down]
Nmap scan report for 10.33.0.84 [host down]
Nmap scan report for 10.33.0.85 [host down]
Nmap scan report for 10.33.0.86 [host down]
Nmap scan report for 10.33.0.87 [host down]
Nmap scan report for 10.33.0.88 [host down]
Nmap scan report for 10.33.0.89 [host down]
Nmap scan report for 10.33.0.90 [host down]
Nmap scan report for 10.33.0.91 [host down]
Nmap scan report for 10.33.0.92 [host down]
Nmap scan report for 10.33.0.93 [host down]
Nmap scan report for 10.33.0.94 [host down]
Nmap scan report for 10.33.0.95 [host down]
Nmap scan report for 10.33.0.96
Host is up (0.10s latency).
MAC Address: CA:4F:F4:AF:8F:0C (Unknown)
Nmap scan report for 10.33.0.97 [host down]
Nmap scan report for 10.33.0.98 [host down]
Nmap scan report for 10.33.0.99 [host down]
Nmap scan report for 10.33.0.100
Host is up (0.073s latency).
MAC Address: E8:6F:38:6A:B6:EF (Chongqing Fugui Electronics)
Nmap scan report for 10.33.0.101 [host down]
Nmap scan report for 10.33.0.102 [host down]
Nmap scan report for 10.33.0.103 [host down]
Nmap scan report for 10.33.0.104 [host down]
Nmap scan report for 10.33.0.105 [host down]
Nmap scan report for 10.33.0.106 [host down]
Nmap scan report for 10.33.0.107 [host down]
Nmap scan report for 10.33.0.108 [host down]
Nmap scan report for 10.33.0.109 [host down]
Nmap scan report for 10.33.0.110 [host down]
Nmap scan report for 10.33.0.111
Host is up (0.070s latency).
MAC Address: D2:41:F0:DC:6A:ED (Unknown)
Nmap scan report for 10.33.0.112 [host down]
Nmap scan report for 10.33.0.113 [host down]
Nmap scan report for 10.33.0.114 [host down]
Nmap scan report for 10.33.0.115 [host down]
Nmap scan report for 10.33.0.116 [host down]
Nmap scan report for 10.33.0.117
Host is up (0.33s latency).
MAC Address: 8A:D8:25:FF:2E:A6 (Unknown)
Nmap scan report for 10.33.0.118 [host down]
Nmap scan report for 10.33.0.119
Host is up (0.047s latency).
MAC Address: 18:56:80:70:9C:48 (Intel Corporate)
Nmap scan report for 10.33.0.120 [host down]
Nmap scan report for 10.33.0.121 [host down]
Nmap scan report for 10.33.0.122 [host down]
Nmap scan report for 10.33.0.123 [host down]
Nmap scan report for 10.33.0.124 [host down]
Nmap scan report for 10.33.0.125 [host down]
Nmap scan report for 10.33.0.126 [host down]
Nmap scan report for 10.33.0.127 [host down]
Nmap scan report for 10.33.0.128 [host down]
Nmap scan report for 10.33.0.129 [host down]
Nmap scan report for 10.33.0.130 [host down]
Nmap scan report for 10.33.0.131 [host down]
Nmap scan report for 10.33.0.132 [host down]
Nmap scan report for 10.33.0.133 [host down]
Nmap scan report for 10.33.0.134 [host down]
Nmap scan report for 10.33.0.135
Host is up (0.021s latency).
MAC Address: F8:5E:A0:06:40:D2 (Intel Corporate)
Nmap scan report for 10.33.0.136 [host down]
Nmap scan report for 10.33.0.137 [host down]
Nmap scan report for 10.33.0.138 [host down]
Nmap scan report for 10.33.0.139 [host down]
Nmap scan report for 10.33.0.140
Host is up (0.052s latency).
MAC Address: 40:EC:99:8B:11:C2 (Intel Corporate)
Nmap scan report for 10.33.0.141 [host down]
Nmap scan report for 10.33.0.142 [host down]
Nmap scan report for 10.33.0.143
Host is up (0.13s latency).
MAC Address: F0:18:98:41:11:07 (Apple)
Nmap scan report for 10.33.0.144 [host down]
Nmap scan report for 10.33.0.145 [host down]
Nmap scan report for 10.33.0.146 [host down]
Nmap scan report for 10.33.0.147 [host down]
Nmap scan report for 10.33.0.148
Host is up (0.074s latency).
MAC Address: E6:AA:26:EE:23:B7 (Unknown)
Nmap scan report for 10.33.0.149 [host down]
Nmap scan report for 10.33.0.150 [host down]
Nmap scan report for 10.33.0.151 [host down]
Nmap scan report for 10.33.0.152 [host down]
Nmap scan report for 10.33.0.153 [host down]
Nmap scan report for 10.33.0.154 [host down]
Nmap scan report for 10.33.0.155 [host down]
Nmap scan report for 10.33.0.156 [host down]
Nmap scan report for 10.33.0.157 [host down]
Nmap scan report for 10.33.0.158 [host down]
Nmap scan report for 10.33.0.159 [host down]
Nmap scan report for 10.33.0.160 [host down]
Nmap scan report for 10.33.0.161 [host down]
Nmap scan report for 10.33.0.162 [host down]
Nmap scan report for 10.33.0.163 [host down]
Nmap scan report for 10.33.0.164 [host down]
Nmap scan report for 10.33.0.165 [host down]
Nmap scan report for 10.33.0.166 [host down]
Nmap scan report for 10.33.0.167 [host down]
Nmap scan report for 10.33.0.168 [host down]
Nmap scan report for 10.33.0.169 [host down]
Nmap scan report for 10.33.0.170 [host down]
Nmap scan report for 10.33.0.171 [host down]
Nmap scan report for 10.33.0.172 [host down]
Nmap scan report for 10.33.0.173 [host down]
Nmap scan report for 10.33.0.174 [host down]
Nmap scan report for 10.33.0.175 [host down]
Nmap scan report for 10.33.0.176 [host down]
Nmap scan report for 10.33.0.177 [host down]
Nmap scan report for 10.33.0.178 [host down]
Nmap scan report for 10.33.0.179 [host down]
Nmap scan report for 10.33.0.180
Host is up (0.75s latency).
MAC Address: 26:91:29:98:E2:9D (Unknown)
Nmap scan report for 10.33.0.181 [host down]
Nmap scan report for 10.33.0.182 [host down]
Nmap scan report for 10.33.0.183 [host down]
Nmap scan report for 10.33.0.184 [host down]
Nmap scan report for 10.33.0.185 [host down]
Nmap scan report for 10.33.0.186 [host down]
Nmap scan report for 10.33.0.187 [host down]
Nmap scan report for 10.33.0.188 [host down]
Nmap scan report for 10.33.0.189 [host down]
Nmap scan report for 10.33.0.190 [host down]
Nmap scan report for 10.33.0.191 [host down]
Nmap scan report for 10.33.0.192 [host down]
Nmap scan report for 10.33.0.193 [host down]
Nmap scan report for 10.33.0.194 [host down]
Nmap scan report for 10.33.0.195 [host down]
Nmap scan report for 10.33.0.196 [host down]
Nmap scan report for 10.33.0.197 [host down]
Nmap scan report for 10.33.0.198 [host down]
Nmap scan report for 10.33.0.199 [host down]
Nmap scan report for 10.33.0.200 [host down]
Nmap scan report for 10.33.0.201 [host down]
Nmap scan report for 10.33.0.202 [host down]
Nmap scan report for 10.33.0.203 [host down]
Nmap scan report for 10.33.0.204 [host down]
Nmap scan report for 10.33.0.205 [host down]
Nmap scan report for 10.33.0.206 [host down]
Nmap scan report for 10.33.0.207 [host down]
Nmap scan report for 10.33.0.208 [host down]
Nmap scan report for 10.33.0.209 [host down]
Nmap scan report for 10.33.0.210 [host down]
Nmap scan report for 10.33.0.211 [host down]
Nmap scan report for 10.33.0.212
Host is up (0.17s latency).
MAC Address: 48:2C:A0:C8:F1:DC (Xiaomi Communications)
Nmap scan report for 10.33.0.213 [host down]
Nmap scan report for 10.33.0.214 [host down]
Nmap scan report for 10.33.0.215
Host is up (0.12s latency).
MAC Address: D8:F8:83:A6:59:2D (Intel Corporate)
Nmap scan report for 10.33.0.216 [host down]
Nmap scan report for 10.33.0.217
Host is up (0.80s latency).
MAC Address: 76:8F:9C:ED:EC:B1 (Unknown)
Nmap scan report for 10.33.0.218 [host down]
Nmap scan report for 10.33.0.219 [host down]
Nmap scan report for 10.33.0.220 [host down]
Nmap scan report for 10.33.0.221
Host is up (0.081s latency).
MAC Address: 84:C5:A6:EB:C3:A5 (Intel Corporate)
Nmap scan report for 10.33.0.222 [host down]
Nmap scan report for 10.33.0.223 [host down]
Nmap scan report for 10.33.0.224 [host down]
Nmap scan report for 10.33.0.225 [host down]
Nmap scan report for 10.33.0.226 [host down]
Nmap scan report for 10.33.0.227 [host down]
Nmap scan report for 10.33.0.228
Host is up (0.099s latency).
MAC Address: 7C:5C:F8:2D:40:42 (Intel Corporate)
Nmap scan report for 10.33.0.229 [host down]
Nmap scan report for 10.33.0.230 [host down]
Nmap scan report for 10.33.0.231 [host down]
Nmap scan report for 10.33.0.232 [host down]
Nmap scan report for 10.33.0.233 [host down]
Nmap scan report for 10.33.0.234 [host down]
Nmap scan report for 10.33.0.235 [host down]
Nmap scan report for 10.33.0.236 [host down]
Nmap scan report for 10.33.0.237 [host down]
Nmap scan report for 10.33.0.238 [host down]
Nmap scan report for 10.33.0.239 [host down]
Nmap scan report for 10.33.0.240 [host down]
Nmap scan report for 10.33.0.241 [host down]
Nmap scan report for 10.33.0.242
Host is up (0.090s latency).
MAC Address: 74:4C:A1:51:1E:61 (Liteon Technology)
Nmap scan report for 10.33.0.243 [host down]
Nmap scan report for 10.33.0.244 [host down]
Nmap scan report for 10.33.0.245
Host is up (0.052s latency).
MAC Address: 84:FD:D1:F1:23:7C (Intel Corporate)
Nmap scan report for 10.33.0.246 [host down]
Nmap scan report for 10.33.0.247 [host down]
Nmap scan report for 10.33.0.248 [host down]
Nmap scan report for 10.33.0.249 [host down]
Nmap scan report for 10.33.0.250
Host is up (0.015s latency).
MAC Address: 28:CD:C4:DD:DB:73 (Chongqing Fugui Electronics)
Nmap scan report for 10.33.0.251
Host is up (0.012s latency).
MAC Address: 48:E7:DA:41:BF:E1 (AzureWave Technology)
Nmap scan report for 10.33.0.252 [host down]
Nmap scan report for 10.33.0.253 [host down]
Nmap scan report for 10.33.0.254 [host down]
Nmap scan report for 10.33.0.255 [host down]
Nmap scan report for 10.33.1.0 [host down]
Nmap scan report for 10.33.1.1 [host down]
Nmap scan report for 10.33.1.2
Host is up (0.28s latency).
MAC Address: 32:6D:B1:F2:D2:4D (Unknown)
Nmap scan report for 10.33.1.3 [host down]
Nmap scan report for 10.33.1.4 [host down]
Nmap scan report for 10.33.1.5 [host down]
Nmap scan report for 10.33.1.6 [host down]
Nmap scan report for 10.33.1.7 [host down]
Nmap scan report for 10.33.1.8 [host down]
Nmap scan report for 10.33.1.9
Host is up (0.068s latency).
MAC Address: 2C:8D:B1:D9:55:3F (Intel Corporate)
Nmap scan report for 10.33.1.10 [host down]
Nmap scan report for 10.33.1.11
Host is up (0.23s latency).
MAC Address: A0:78:17:7E:0B:57 (Apple)
Nmap scan report for 10.33.1.12 [host down]
Nmap scan report for 10.33.1.13 [host down]
Nmap scan report for 10.33.1.14 [host down]
Nmap scan report for 10.33.1.15 [host down]
Nmap scan report for 10.33.1.16
Host is up (0.27s latency).
MAC Address: 00:E9:3A:F2:FE:39 (AzureWave Technology)
Nmap scan report for 10.33.1.17 [host down]
Nmap scan report for 10.33.1.18 [host down]
Nmap scan report for 10.33.1.19 [host down]
Nmap scan report for 10.33.1.20 [host down]
Nmap scan report for 10.33.1.21 [host down]
Nmap scan report for 10.33.1.22 [host down]
Nmap scan report for 10.33.1.23
Host is up (0.15s latency).
MAC Address: 4C:50:77:DC:A7:1D (Huawei Device)
Nmap scan report for 10.33.1.24 [host down]
Nmap scan report for 10.33.1.25 [host down]
Nmap scan report for 10.33.1.26 [host down]
Nmap scan report for 10.33.1.27 [host down]
Nmap scan report for 10.33.1.28 [host down]
Nmap scan report for 10.33.1.29 [host down]
Nmap scan report for 10.33.1.30 [host down]
Nmap scan report for 10.33.1.31 [host down]
Nmap scan report for 10.33.1.32 [host down]
Nmap scan report for 10.33.1.33 [host down]
Nmap scan report for 10.33.1.34 [host down]
Nmap scan report for 10.33.1.35 [host down]
Nmap scan report for 10.33.1.36 [host down]
Nmap scan report for 10.33.1.37 [host down]
Nmap scan report for 10.33.1.38 [host down]
Nmap scan report for 10.33.1.39 [host down]
Nmap scan report for 10.33.1.40 [host down]
Nmap scan report for 10.33.1.41 [host down]
Nmap scan report for 10.33.1.42 [host down]
Nmap scan report for 10.33.1.43 [host down]
Nmap scan report for 10.33.1.44 [host down]
Nmap scan report for 10.33.1.45 [host down]
Nmap scan report for 10.33.1.46 [host down]
Nmap scan report for 10.33.1.47 [host down]
Nmap scan report for 10.33.1.48
Host is up (0.80s latency).
MAC Address: 34:42:62:23:F7:3C (Apple)
Nmap scan report for 10.33.1.49 [host down]
Nmap scan report for 10.33.1.50 [host down]
Nmap scan report for 10.33.1.51 [host down]
Nmap scan report for 10.33.1.52 [host down]
Nmap scan report for 10.33.1.53 [host down]
Nmap scan report for 10.33.1.54 [host down]
Nmap scan report for 10.33.1.55 [host down]
Nmap scan report for 10.33.1.56 [host down]
Nmap scan report for 10.33.1.57 [host down]
Nmap scan report for 10.33.1.58 [host down]
Nmap scan report for 10.33.1.59 [host down]
Nmap scan report for 10.33.1.60 [host down]
Nmap scan report for 10.33.1.61 [host down]
Nmap scan report for 10.33.1.62 [host down]
Nmap scan report for 10.33.1.63 [host down]
Nmap scan report for 10.33.1.64 [host down]
Nmap scan report for 10.33.1.65
Host is up (0.11s latency).
MAC Address: A4:B1:C1:98:65:DE (Intel Corporate)
Nmap scan report for 10.33.1.66 [host down]
Nmap scan report for 10.33.1.67 [host down]
Nmap scan report for 10.33.1.68 [host down]
Nmap scan report for 10.33.1.69 [host down]
Nmap scan report for 10.33.1.70 [host down]
Nmap scan report for 10.33.1.71 [host down]
Nmap scan report for 10.33.1.72 [host down]
Nmap scan report for 10.33.1.73 [host down]
Nmap scan report for 10.33.1.74 [host down]
Nmap scan report for 10.33.1.75 [host down]
Nmap scan report for 10.33.1.76 [host down]
Nmap scan report for 10.33.1.77 [host down]
Nmap scan report for 10.33.1.78 [host down]
Nmap scan report for 10.33.1.79
Host is up (0.081s latency).
MAC Address: 90:CC:DF:09:80:A8 (Intel Corporate)
Nmap scan report for 10.33.1.80 [host down]
Nmap scan report for 10.33.1.81 [host down]
Nmap scan report for 10.33.1.82 [host down]
Nmap scan report for 10.33.1.83 [host down]
Nmap scan report for 10.33.1.84 [host down]
Nmap scan report for 10.33.1.85 [host down]
Nmap scan report for 10.33.1.86 [host down]
Nmap scan report for 10.33.1.87 [host down]
Nmap scan report for 10.33.1.88 [host down]
Nmap scan report for 10.33.1.89 [host down]
Nmap scan report for 10.33.1.90 [host down]
Nmap scan report for 10.33.1.91
Host is up (0.053s latency).
MAC Address: 28:D0:EA:6B:3D:F2 (Intel Corporate)
Nmap scan report for 10.33.1.92 [host down]
Nmap scan report for 10.33.1.93 [host down]
Nmap scan report for 10.33.1.94 [host down]
Nmap scan report for 10.33.1.95 [host down]
Nmap scan report for 10.33.1.96 [host down]
Nmap scan report for 10.33.1.97 [host down]
Nmap scan report for 10.33.1.98 [host down]
Nmap scan report for 10.33.1.99 [host down]
Nmap scan report for 10.33.1.100
Host is up (0.16s latency).
MAC Address: E4:5E:37:D2:85:25 (Intel Corporate)
Nmap scan report for 10.33.1.101 [host down]
Nmap scan report for 10.33.1.102 [host down]
Nmap scan report for 10.33.1.103 [host down]
Nmap scan report for 10.33.1.104 [host down]
Nmap scan report for 10.33.1.105 [host down]
Nmap scan report for 10.33.1.106 [host down]
Nmap scan report for 10.33.1.107 [host down]
Nmap scan report for 10.33.1.108
Host is up (0.055s latency).
MAC Address: D6:A8:14:09:97:73 (Unknown)
Nmap scan report for 10.33.1.109 [host down]
Nmap scan report for 10.33.1.110 [host down]
Nmap scan report for 10.33.1.111 [host down]
Nmap scan report for 10.33.1.112 [host down]
Nmap scan report for 10.33.1.113 [host down]
Nmap scan report for 10.33.1.114 [host down]
Nmap scan report for 10.33.1.115 [host down]
Nmap scan report for 10.33.1.116 [host down]
Nmap scan report for 10.33.1.117 [host down]
Nmap scan report for 10.33.1.118 [host down]
Nmap scan report for 10.33.1.119 [host down]
Nmap scan report for 10.33.1.120 [host down]
Nmap scan report for 10.33.1.121 [host down]
Nmap scan report for 10.33.1.122 [host down]
Nmap scan report for 10.33.1.123
Host is up (0.13s latency).
MAC Address: 48:E7:DA:29:9F:E1 (AzureWave Technology)
Nmap scan report for 10.33.1.124 [host down]
Nmap scan report for 10.33.1.125 [host down]
Nmap scan report for 10.33.1.126 [host down]
Nmap scan report for 10.33.1.127 [host down]
Nmap scan report for 10.33.1.128 [host down]
Nmap scan report for 10.33.1.129 [host down]
Nmap scan report for 10.33.1.130 [host down]
Nmap scan report for 10.33.1.131 [host down]
Nmap scan report for 10.33.1.132 [host down]
Nmap scan report for 10.33.1.133 [host down]
Nmap scan report for 10.33.1.134 [host down]
Nmap scan report for 10.33.1.135 [host down]
Nmap scan report for 10.33.1.136 [host down]
Nmap scan report for 10.33.1.137 [host down]
Nmap scan report for 10.33.1.138 [host down]
Nmap scan report for 10.33.1.139 [host down]
Nmap scan report for 10.33.1.140 [host down]
Nmap scan report for 10.33.1.141 [host down]
Nmap scan report for 10.33.1.142 [host down]
Nmap scan report for 10.33.1.143 [host down]
Nmap scan report for 10.33.1.144 [host down]
Nmap scan report for 10.33.1.145 [host down]
Nmap scan report for 10.33.1.146 [host down]
Nmap scan report for 10.33.1.147 [host down]
Nmap scan report for 10.33.1.148 [host down]
Nmap scan report for 10.33.1.149 [host down]
Nmap scan report for 10.33.1.150 [host down]
Nmap scan report for 10.33.1.151 [host down]
Nmap scan report for 10.33.1.152 [host down]
Nmap scan report for 10.33.1.153 [host down]
Nmap scan report for 10.33.1.154 [host down]
Nmap scan report for 10.33.1.155 [host down]
Nmap scan report for 10.33.1.156 [host down]
Nmap scan report for 10.33.1.157 [host down]
Nmap scan report for 10.33.1.158 [host down]
Nmap scan report for 10.33.1.159 [host down]
Nmap scan report for 10.33.1.160 [host down]
Nmap scan report for 10.33.1.161 [host down]
Nmap scan report for 10.33.1.162 [host down]
Nmap scan report for 10.33.1.163 [host down]
Nmap scan report for 10.33.1.164 [host down]
Nmap scan report for 10.33.1.165 [host down]
Nmap scan report for 10.33.1.166
Host is up (0.22s latency).
MAC Address: 1A:41:0B:54:A5:A0 (Unknown)
Nmap scan report for 10.33.1.167 [host down]
Nmap scan report for 10.33.1.168 [host down]
Nmap scan report for 10.33.1.169 [host down]

```
  on utilise la gateway 10.33.3.253
  
  avec `ipconfig /all` on peut voir si l'ip est statique ainsi que la gateway 
  
  output (depuis la carte wifi) : 
  
  ip statique :
   ```
   DHCP activé. . . . . . . . . . . . . . : Non
   ```
   ip gateway : 
   ```
   Passerelle par défaut. . . . . . . . . : 10.33.3.253
   ```
   
   
  on ping le DNS 1.1.1.1 pour prouvé un accès internet : 
  
  ```
  PS C:\Users\louis> ping 1.1.1.1

Envoi d’une requête 'Ping'  1.1.1.1 avec 32 octets de données :
Réponse de 1.1.1.1 : octets=32 temps=51 ms TTL=58
Réponse de 1.1.1.1 : octets=32 temps=113 ms TTL=58
Réponse de 1.1.1.1 : octets=32 temps=107 ms TTL=58
Réponse de 1.1.1.1 : octets=32 temps=61 ms TTL=58

Statistiques Ping pour 1.1.1.1:
    Paquets : envoyés = 4, reçus = 4, perdus = 0 (perte 0%),
Durée approximative des boucles en millisecondes :
    Minimum = 51ms, Maximum = 113ms, Moyenne = 83ms
  ```
  
  # II. Exploration locale en duo

### 1. Modification d'adresse IP

Configuration des machines :
Le premier aura 192.168.0.1 et le 2ème 192.168.0.2.
![](https://i.imgur.com/ods44w3.png)

Les changements ont bien pris effet :
```
PS C:\Users\DIRECTEUR_PC2> ipconfig

Configuration IP de Windows
[...]
Carte Ethernet Ethernet :

   Suffixe DNS propre à la connexion. . . :
   Adresse IPv6 de liaison locale. . . . .: fe80::f166:4347:db54:1052%10
   Adresse IPv4. . . . . . . . . . . . . .: 192.168.0.1
   Masque de sous-réseau. . . . . . . . . : 255.255.255.252
   Passerelle par défaut. . . . . . . . . :
[...]
```

Ping de la 2ème machine :
```
PS C:\Users\DIRECTEUR_PC2> ping 192.168.0.2

Envoi d’une requête 'Ping'  192.168.0.2 avec 32 octets de données :
Réponse de 192.168.0.2 : octets=32 temps=1 ms TTL=128
Réponse de 192.168.0.2 : octets=32 temps=1 ms TTL=128
Réponse de 192.168.0.2 : octets=32 temps<1ms TTL=128
Réponse de 192.168.0.2 : octets=32 temps=2 ms TTL=128

Statistiques Ping pour 192.168.0.2:
    Paquets : envoyés = 4, reçus = 4, perdus = 0 (perte 0%),
Durée approximative des boucles en millisecondes :
    Minimum = 0ms, Maximum = 2ms, Moyenne = 1ms
```
### 2. Utilisation d'un des deux comme gateway

Depuis la 2ème machine :

Ping 8.8.8.8 ->
```
PS C:\Users\nicol> ping 8.8.8.8

Envoi d’une requête 'Ping'  8.8.8.8 avec 32 octets de données :
Réponse de 8.8.8.8 : octets=32 temps=25 ms TTL=114
Réponse de 8.8.8.8 : octets=32 temps=34 ms TTL=114

Statistiques Ping pour 8.8.8.8:
    Paquets : envoyés = 2, reçus = 2, perdus = 0 (perte 0%),
Durée approximative des boucles en millisecondes :
    Minimum = 25ms, Maximum = 34ms, Moyenne = 29ms
```

tracert vers www.google.com ->
```
PS C:\Users\nicol> tracert www.google.com

Détermination de l’itinéraire vers www.google.com [142.250.179.68]
avec un maximum de 30 sauts :

  1     3 ms     2 ms     2 ms  DIRECTEUR-PC2 [192.168.0.1]
  2     *        *        *     Délai d’attente de la demande dépassé.
  3     4 ms     5 ms     4 ms  10.33.3.253
  4     5 ms     6 ms     7 ms  10.33.10.254
  5     4 ms     3 ms     4 ms  reverse.completel.net [92.103.174.137]
  6    11 ms     9 ms     8 ms  92.103.120.182
  7    21 ms    19 ms    21 ms  172.19.130.113
  8    19 ms    19 ms    19 ms  46.218.128.78
  9    21 ms    21 ms    21 ms  186.144.6.194.rev.sfr.net [194.6.144.186]
 10    22 ms    21 ms    22 ms  186.144.6.194.rev.sfr.net [194.6.144.186]
 11    22 ms    22 ms    23 ms  72.14.194.30
 12    23 ms    22 ms    22 ms  108.170.231.111
 13    22 ms    21 ms    21 ms  142.251.49.133
 14    21 ms    21 ms    21 ms  par21s19-in-f4.1e100.net [142.250.179.68]

Itinéraire déterminé.
```

### 3. Petit chat privé

Serveur :
```
PS C:\Users\DIRECTEUR_PC2\Desktop\Ynov> .\nc.exe -l -p 8888
Salut !
Hola ! Ca va ?
Super et toi ?
Je sais pas mettre de GIF dans ce truc... Donc ca va pas !
gifdechat.gif
=(
```

Client :
```
PS C:\Users\nicol\Downloads> .\nc.exe 192.168.0.1 8888
Salut !
[...]
```
Si on veut préciser sur quelle ip écouter (en mode serveur) : `.\nc.exe -l -p 8888 192.168.0.2`

### 4. Firewall

Pour activer les ping, il faut autoriser les règles `File and Printer Sharing (Echo Request - ICMPv4-In)` dans le pare feu.
Pour NETCAT, il faut ajouter une règle avec le programme et ajouter les ports voulus.

![](https://i.imgur.com/xy1TLTH.png)

![](https://i.imgur.com/A8WW3Kt.png)

# III. Manipulations d'autres outils/protocoles côté client

### 1. DHCP

on peut obtenir l'adresse et le bail du serveur dhcp depuis un `ipconfig /all`

output (depuis la carte wifi) : 

ip : 
```
Serveur DHCP . . . . . . . . . . . . . : 10.33.3.254
```

date d'aquisition / d'expiration : 
```
Bail obtenu. . . . . . . . . . . . . . : jeudi 16 septembre 2021 10:26:23
Bail expirant. . . . . . . . . . . . . : jeudi 16 septembre 2021 13:00:41
```

### 2. DNS
 on peut trouver l'ip du DNS que l'oninateur connais grâce à `ipconfig /all`

output (depuis la carte wifi) : 

```
   Serveurs DNS. . .  . . . . . . . . . . : 10.33.10.2
                                       10.33.10.148
                                       10.33.10.155
```
il y a donc 3 serveur DNS

ns lookup : 

google.com : 
```
PS C:\Users\louis> nslookup google.com
Serveur :   UnKnown
Address:  10.33.10.2

Réponse ne faisant pas autorité :
Nom :    google.com
Addresses:  2a00:1450:4007:80e::200e
          142.250.179.78
```

ynov.com : 
```
PS C:\Users\louis> nslookup ynov.com
Serveur :   UnKnown
Address:  10.33.10.2

Réponse ne faisant pas autorité :
Nom :    ynov.com
Address:  92.243.16.143
```

ici on peut interpréter que l'addresse ip de google est 142.33.10.2 et celle d'ynov est 92.243.16.143 en passant par ce DNS, on remarque de plus que l'adresse de requête est celle d'un des DNS du réseau

reverse lookup : 

78.74.21.21 : 
```
PS C:\Users\louis> nslookup 78.74.21.21
Serveur :   UnKnown
Address:  10.33.10.2

Nom :    host-78-74-21-21.homerun.telia.com
Address:  78.74.21.21
```

92.146.54.88 : 
```
PS C:\Users\louis> nslookup 92.146.54.88
Serveur :   UnKnown
Address:  10.33.10.2

Nom :    apoitiers-654-1-167-88.w92-146.abo.wanadoo.fr
Address:  92.146.54.88
```
Grâce au reverse lookup, on peut voir le nom de domaine lié à une addresse avec une requête DNS

# IV. Wireshark

ping de la passerelle : 

![](https://i.imgur.com/zDSLUZF.png)

sur ce screen on peut voir le ping de mon pc vers la passerelle, on peut le reconnaitre via plusieurs éléments : 
le protocole ICMP, les deux adresse ip 10.33.1.41 (pc) et 10.33.3.253 (passerelle), les mots-clés resquest et reply

netcat : 
![](https://i.imgur.com/KppMa15.png)

on peut voir les échange entre les deux même addresse ip et le protocole TCP

requête DNS : 
![](https://i.imgur.com/nzOV6lG.png)

on peut voir que la requête est envoyé depuis le pc (10.33.1.41) vers le DNS (10.33.10.2) ainsi que le protocole DNS
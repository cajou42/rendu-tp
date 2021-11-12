#!/bin/bash
#11/11/2021
#reverse proxy script deployment
if [[ $(id -u) -ne 0 ]]; then
        echo "sudo permission requiered"
        exit 1
fi

#nginx installation
dnf update
dnf install epel-release -y
dnf install nginx -y
systemctl start nginx
systemctl enable nginx
firewall-cmd --add-port=80/tcp
firewall-cmd --add-port=80/tcp --permanent
firewall-cmd --add-port=443/tcp
firewall-cmd --add-port=443/tcp --permanent
sed -i '38,57d' /etc/nginx/nginx.conf

#key and certificate creation
openssl req -new -newkey rsa:2048 -days 365 -nodes -x509 -keyout server.key -out server.crt
mv server.key /etc/pki/tls/private/web.tp3.linux.key
mv server.crt /etc/pki/tls/certs/web.tp3.linux.crt
chown root:root /etc/pki/tls/private/web.tp3.linux.key
chown root:root /etc/pki/tls/certs/web.tp3.linux.crt
chmod 400 /etc/pki/tls/private/web.tp3.linux.key
chmod 644 /etc/pki/tls/certs/web.tp3.linux.crt

#server configuration
touch /etc/nginx/conf.d/web.tp3.linux.conf
echo "server {" >> /etc/nginx/conf.d/web.tp3.linux.conf
echo "    listen 443 ssl;" >> /etc/nginx/conf.d/web.tp3.linux.conf
echo "    ssl_certificate /etc/pki/tls/certs/web.tp3.linux.crt;" >> /etc/nginx/conf.d/web.tp3.linux.conf
echo "    ssl_certificate_key /etc/pki/tls/private/web.tp3.linux.key;" >> /etc/nginx/conf.d/web.tp3.linux.conf
echo "    server_name web1.tp3.linux;" >> /etc/nginx/conf.d/web.tp3.linux.conf
echo "    location / {" >> /etc/nginx/conf.d/web.tp3.linux.conf
echo "        proxy_pass http://web1.tp3.linux;" >> /etc/nginx/conf.d/web.tp3.linux.conf
echo "    }" >> /etc/nginx/conf.d/web.tp3.linux.conf
echo "}" >> /etc/nginx/conf.d/web.tp3.linux.conf

#https configuration
echo "" >> /etc/nginx/nginx.conf
echo "    ssl_protocols          TLSv1.2 TLSv1.3;" >> /etc/nginx/nginx.conf
echo "ssl_ciphers            ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384;" >> /etc/nginx/nginx.conf
echo "" >> /etc/nginx/nginx.conf
echo "    ssl_session_timeout    1d;" >> /etc/nginx/nginx.conf
echo "    ssl_session_cache      shared:SSL:10m;" >> /etc/nginx/nginx.conf
echo "    ssl_session_tickets    off;" >> /etc/nginx/nginx.conf
systemctl restart nginx

#loadbalancing configuration
echo "   upstream backend {" >>/etc/nginx/conf.d/load-balancer.conf
echo "      least_conn;" >>/etc/nginx/conf.d/load-balancer.conf
echo "      server 10.15.1.2;" >>/etc/nginx/conf.d/load-balancer.conf
echo "      server 10.15.1.4;" >>/etc/nginx/conf.d/load-balancer.conf
echo "   }" >>/etc/nginx/conf.d/load-balancer.conf
echo "" >>/etc/nginx/conf.d/load-balancer.conf
echo "server {" >> /etc/nginx/conf.d/load-balancer.conf
echo "    listen 443 ssl;" >> /etc/nginx/conf.d/load-balancer.conf
echo "    ssl_certificate /etc/pki/tls/certs/web.tp3.linux.crt;" >> /etc/nginx/conf.d/load-balancer.conf
echo "    ssl_certificate_key /etc/pki/tls/private/web.tp3.linux.key;" >> /etc/nginx/conf.d/load-balancer.conf
echo "    server_name web1.tp3.linux;" >> /etc/nginx/conf.d/load-balancer.conf
echo "    ssl_protocols TLSv1.2 TLSv1.3;" >> /etc/nginx/conf.d/load-balancer.conf
echo "    location / {" >> /etc/nginx/conf.d/load-balancer.conf
echo "      proxy_pass http://backend;" >> /etc/nginx/conf.d/load-balancer.conf
echo "    }" >> /etc/nginx/conf.d/load-balancer.conf
echo "}" >> /etc/nginx/conf.d/load-balancer.conf
systemctl restart nginx

#firewall setup
firewall-cmd --new-zone=ssh --permanent
firewall-cmd --reload
firewall-cmd --zone=ssh --add-source=10.15.1.1/32 --permanent
firewall-cmd --zone=ssh --add-port=22/tcp --permanent
firewall-cmd --new-zone=proxy --permanent
firewall-cmd --reload
firewall-cmd --zone=proxy --add-source=10.15.1.0/24 --permanent
firewall-cmd --reload

#netdata monitoring
bash <(curl -Ss https://my-netdata.io/kickstart-static64.sh)
firewall-cmd --add-port=19999/tcp
firewall-cmd --add-port=19999/tcp --permanent
firewall-cmd --reload
/opt/netdata/etc/netdata/edit-config health_alarm_notify.conf
sed -i 's/SEND_DISCORD=""/SEND_DISCORD="YES"/' /opt/netdata/etc/netdata/health_alarm_notify.conf
sed -i 's/DISCORD_WEBHOOK_URL=""/DISCORD_WEBHOOK_URL="http\s:\/\/di\scord.com\/api\/webhook\s\/897039750752509982\/\S4h7H3MFmx\sb_Rvc20\s0hxBtN448v\s7-OuB_6FRFGQ\SXDabyeEZ0F-mB7tFI\ShjzViyD"/' /opt/netdata/etc/netdata/health_alarm_notify.conf
sed -i 's/DEFAULT_RECIPIENT_DISCORD=""/DEFAULT_RECIPIENT_DISCORD="alarms"/' /opt/netdata/etc/netdata/health_alarm_notify.conf
sed -i 's/curl=""/curl="\/opt\/netdata\/bin\/curl -k"/' /opt/netdata/etc/netdata/health_alarm_notify.conf

touch /opt/netdata/etc/netdata/health.d/ram-usage.conf
echo " alarm: ram_usage" >> /opt/netdata/etc/netdata/health.d/ram-usage.conf
echo "    on: system.ram" >> /opt/netdata/etc/netdata/health.d/ram-usage.conf
echo "lookup: average -1m percentage of used" >> /opt/netdata/etc/netdata/health.d/ram-usage.conf
echo " units: %" >> /opt/netdata/etc/netdata/health.d/ram-usage.conf
echo " every: 1m">> /opt/netdata/etc/netdata/health.d/ram-usage.conf
echo "  warn: $this > 50" >> /opt/netdata/etc/netdata/health.d/ram-usage.conf
echo "  crit: $this > 90" >> /opt/netdata/etc/netdata/health.d/ram-usage.conf
echo "  info: The percentage of RAM being used by the system." >> /opt/netdata/etc/netdata/health.d/ram-usage.conf

echo "INSTALLATION COMPLETE"

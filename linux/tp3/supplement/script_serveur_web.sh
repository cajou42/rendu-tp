#!/bin/bash
#12/11/2021
#webh serveur script deployment

if [[ $(id -u) -ne 0 ]]; then
        echo "sudo permission requiered"
        exit 1
fi

dnf update
dnf install httpd
systemctl start httpd
systemctl enable httpd
firewall-cmd --add-port=80/tcp
firewall-cmd --add-port=80/tcp --permanent

#firewall setup
firewall-cmd --set-default-zone=drop
firewall-cmd --new-zone=ssh --permanent
firewall-cmd --reload
firewall-cmd --zone=ssh --add-source=10.15.1.1/32 --permanent
firewall-cmd --zone=ssh --add-port=22/tcp --permanent
firewall-cmd --new-zone=reverse_proxy --permanent
firewall-cmd --reload
firewall-cmd --zone=proxy --add-source=10.15.1.3/32 --permanent
firewall-cmd --zone=reverse_proxy --add-port=80/tcp --permanent
firewall-cmd --reload

#netdata monitoring
su -
bash <(curl -Ss https://my-netdata.io/kickstart-static64.sh)
logout
firewall-cmd --add-port=19999/tcp
firewall-cmd --add-port=19999/tcp --permanent
firewall-cmd --reload
sed -i 's/SEND_DISCORD=""/SEND_DISCORD="YES"/' /opt/netdata/etc/netdata/health_alarm_notify.conf
sed -i 's/DISCORD_WEBHOOK_URL=""/DISCORD_WEBHOOK_URL="https://discord.com/api/webhooks/897039750752509982/S4h7H3MFmxsb_Rvc20s0hxBtN448vs7-OuB_6FRFGQSXDabyeEZ0F-mB7tFIShjzViyD"/' /opt/netdata/etc/netdata/health_alarm_notify.conf
sed -i 's/DEFAULT_RECIPIENT_DISCORD=""/DEFAULT_RECIPIENT_DISCORD="alarms"/' /opt/netdata/etc/netdata/health_alarm_notify.conf
sed -i 's/curl=""/curl="\/opt\/netdata\/bin\/curl -k"/' /opt/netdata/etc/netdata/health_alarm_notify.conf

touch /opt/netdata/etc/netdata/health.d/ram-usage.conf
" alarm: ram_usage" >> /opt/netdata/etc/netdata/health.d/ram-usage.conf
"    on: system.ram" >> /opt/netdata/etc/netdata/health.d/ram-usage.conf
"lookup: average -1m percentage of used" >> /opt/netdata/etc/netdata/health.d/ram-usage.conf
" units: %" >> /opt/netdata/etc/netdata/health.d/ram-usage.conf
" every: 1m">> /opt/netdata/etc/netdata/health.d/ram-usage.conf
"  warn: $this > 50" >> /opt/netdata/etc/netdata/health.d/ram-usage.conf
"  crit: $this > 90" >> /opt/netdata/etc/netdata/health.d/ram-usage.conf
"  info: The percentage of RAM being used by the system." >> /opt/netdata/etc/netdata/health.d/ram-usage.conf

echo "INSTALLATION COMPLETE"

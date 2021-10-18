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

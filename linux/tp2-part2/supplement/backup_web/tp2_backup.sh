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

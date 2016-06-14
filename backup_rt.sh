#!/bin/bash

# Pull a database backup (mysqldump) 
# Pull a copy of the RT_Siteconfig.pm
# Archive both in $bk_test/$tar_full to be yanked by Bacula

bk_dest="/rt_backup/"
cur_stamp=$(date +%Y%m%0d.%H%M%S)
db_bk_full="${bk_dest}rt4_db_backup_${cur_stamp}"
conf_source="/etc/rt4/"
conf_name="RT_SiteConfig.pm"
conf_bk_full="${bk_dest}${conf_name}_${cur_stamp}"
tar_full="${bk_dest}rt_backup_${cur_stamp}.tar.gz"
password=""

/bin/mysqldump --opt --add-drop-table --single-transaction \
    -udb_backup -p${password}\
    -h localhost rt4 > "${db_bk_full}"

/bin/cp "${conf_source}${conf_name}" "${conf_bk_full}"

/bin/tar -czf ${tar_full} ${conf_bk_full} ${db_bk_full} >/dev/null 2&>1

if [[ -s "${tar_full}" ]]; then
    /bin/rm ${conf_bk_full};
    /bin/rm ${db_bk_full};
    /bin/find /rt_backup/ -type f -mtime +7 -exec rm {} \;
else
    echo "Didn't find ${tar_full} with data";
    exit 1;
fi


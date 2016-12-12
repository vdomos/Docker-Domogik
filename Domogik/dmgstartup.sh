#!/bin/bash 

sleep 3

function clean_up {
	echo "Domogik stopping ..."
	/etc/init.d/domoweb stop
	/etc/init.d/domogik stop
	killall sshd
	exit
}

trap clean_up SIGINT SIGTERM


if [ ! -f /opt/dmg/configured ]
then
    echo "Create mysql database"
    mysql -u root -p"${MYSQLROOTPWD}" -h ${MYSQLHOST} -e "CREATE DATABASE IF NOT EXISTS domogik;"
    mysql -u root -p"${MYSQLROOTPWD}" -h ${MYSQLHOST} -e "GRANT ALL PRIVILEGES ON domogik.* TO \"${USERNAME}\"@'%' IDENTIFIED BY \"${MYSQLUSERPWD}\" WITH GRANT OPTION; FLUSH PRIVILEGES"
    if [ $? -ne 0 ]
    then
        echo "Mysql 'GRANT ALL PRIVILEGES' error"
        exit 1
    fi
    echo "Install. Domogik with user ${USERNAME}"
    cd /opt/dmg/domogik-mq && python install.py --daemon --user ${USERNAME} --command-line --mq_ip 127.0.0.1

    cd /opt/dmg/domogik \
        && python install.py --user ${USERNAME} --command-line --no-test \
        --database_user ${USERNAME}  --database_password "${MYSQLUSERPWD}"  --database_host ${MYSQLHOST} --no-db-backup \
        --domogik_bind_interface "eth0" --admin_interfaces "eth0,lo"  --hub_interfaces "eth0"  --metrics_id ${DOMOGIKID}

    echo "Install. Domoweb"
    cd /opt/dmg/domoweb \
        && python install.py --user ${USERNAME} --notest

    # Using link to enable/disable plugins for tests
    cd /var/lib/domogik/domogik_packages
    ln -s /opt/dmg/plugins/plugin_weather
    ln -s /opt/dmg/plugins/plugin_mqtt
    ln -s /opt/dmg/plugins/plugin_script
    ln -s /opt/dmg/plugins/plugin_vdevice
    ln -s /opt/dmg/plugins/plugin_rfxbnz
    ln -s /opt/dmg/plugins/plugin_ping
    ln -s /opt/dmg/plugins/plugin_diskfree
 
    touch "/opt/dmg/configured"
else
    echo "Domogik still configured"
fi

# start Domogik 
echo "Domogik starting ..."
rm -f /var/run/domogik/*
/etc/init.d/domogik start && /etc/init.d/domoweb start

# run a sshd
/usr/sbin/sshd -D -e &
wait    # To kill properly Domogik with "docker stop -t nn" !

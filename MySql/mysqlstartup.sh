#!/bin/bash

sleep 3

function clean_up {
	echo "Stopping mysqld_safe ..."
	killall mysqld_safe
	exit
}

trap clean_up SIGINT SIGTERM

echo "Starting MySql ..."
if [ ! -f /var/lib/mysql/configured ]
then
    echo "Configuring MySql"
	mysql_install_db

	/usr/bin/mysqld_safe &
	sleep 10s

	echo "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY \"${MYSQLROOTPWD}\" WITH GRANT OPTION; FLUSH PRIVILEGES"  | mysql
	touch "/var/lib/mysql/configured"

	killall mysqld
	sleep 10s
fi

/usr/bin/mysqld_safe &
wait    # To kill properly mysqld_safe with "docker stop" !

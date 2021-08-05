#!/bin/bash
echo "---Checking if UID: ${UID} matches user---"
usermod -u ${UID} ${USER}
echo "---Checking if GID: ${GID} matches user---"
usermod -g ${GID} ${USER}
echo "---Adding user: ${USER} to www-data---"
adduser ${USER} www-data
echo "---Setting umask to ${UMASK}---"
umask ${UMASK}

echo "---Checking for optional scripts---"
if [ -f /opt/scripts/user.sh ]; then
	echo "---Found optional script, executing---"
	chmod +x /opt/scripts/user.sh
	/opt/scripts/user.sh
else
	echo "---No optional script found, continuing---"
fi

echo "---Starting cron---"
export PATH=/bin:/usr/bin:${DATA_DIR}:$PATH
/usr/sbin/cron -- p

echo "---Starting apache2---"
chown -R ${UID}:${GID} /var/www
sed -i '0,/Listen.*/s//Listen '${APACHE2_PORT}'/' /etc/apache2/ports.conf
sed -i '/<VirtualHost \*:.*/s//<VirtualHost \*:'${APACHE2_PORT}'>/' /etc/apache2/sites-enabled/000-default.conf
/usr/sbin/apache2ctl start

echo "---Starting...---"
if [ ! -f ${DATA_DIR}/config/mirror.list ]; then
  cp /etc/apt/mirror.list ${DATA_DIR}/config/mirror.list
fi
chown -R root:${GID} /opt/scripts
chmod -R 750 /opt/scripts
chown -R ${UID}:${GID} ${DATA_DIR}
if [ -f /var/run/crond.pid ]; then
	rm -rf /var/run/crond.pid
fi

term_handler() {
	kill -SIGTERM "$killpid" 2>/dev/null
	wait "$killpid" -f 2>/dev/null
	exit 143;
}

trap 'kill ${!}; term_handler' SIGTERM
/opt/scripts/start-server.sh &
killpid="$!"
while true
do
	wait $killpid
	exit 0;
done
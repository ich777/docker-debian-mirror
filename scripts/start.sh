#!/bin/bash
echo "---Ensuring UID: ${UID} matches user---"
usermod -u ${UID} ${USER}
echo "---Ensuring GID: ${GID} matches user---"
groupmod -g ${GID} ${USER} > /dev/null 2>&1 ||:
usermod -g ${GID} ${USER}
echo "---Setting umask to ${UMASK}---"
umask ${UMASK}

echo "---Checking for optional scripts---"
cp -f /opt/custom/user.sh /opt/scripts/start-user.sh > /dev/null 2>&1 ||:
cp -f /opt/scripts/user.sh /opt/scripts/start-user.sh > /dev/null 2>&1 ||:

if [ -f /opt/scripts/start-user.sh ]; then
    echo "---Found optional script, executing---"
    chmod -f +x /opt/scripts/start-user.sh ||:
    /opt/scripts/start-user.sh || echo "---Optional Script has thrown an Error---"
else
    echo "---No optional script found, continuing---"
fi

echo "---Starting cron---"
if [ -f /var/run/crond.pid ]; then
	rm -rf /var/run/crond.pid
fi
export PATH=/bin:/usr/bin:${DATA_DIR}:$PATH
/usr/sbin/cron -- p

echo "---Starting apache2---"
chown -R ${UID}:${GID} /var/www
sed -i '0,/Listen.*/s//Listen '${APACHE2_PORT}'/' /etc/apache2/ports.conf
sed -i '/<VirtualHost \*:.*/s//<VirtualHost \*:'${APACHE2_PORT}'>/' /etc/apache2/sites-enabled/000-default.conf
/usr/sbin/apache2ctl start

echo "---Taking ownership of data...---"
if [ ! -f ${CONFIG_DIR}/mirror.list ]; then
  cp /etc/apt/mirror.list ${CONFIG_DIR}/mirror.list
fi
chown -R root:${GID} /opt/scripts
chmod -R 750 /opt/scripts
chown -R ${UID}:${GID} ${DATA_DIR}

echo "---Starting...---"
term_handler() {
	kill -SIGTERM "$killpid" 2>/dev/null
	wait "$killpid" -f 2>/dev/null
	exit 143;
}

trap 'kill ${!}; term_handler' SIGTERM
su ${USER} -c "/opt/scripts/start-server.sh" &
killpid="$!"
while true
do
	wait $killpid
	exit 0;
done
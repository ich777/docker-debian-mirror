#!/bin/bash
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

echo "---Starting...---"
if [ ! -f ${DATA_DIR}/config/mirror.list ]; then
  cp /etc/apt/mirror.list ${DATA_DIR}/config/mirror.list
fi
chown -R root:${GID} /opt/scripts
chmod -R 750 /opt/scripts
chown -R ${UID}:${GID} ${DATA_DIR}

term_handler() {
	kill -SIGTERM "$killpid"
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
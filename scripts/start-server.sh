#!/bin/bash
if [ "$(grep -E "# set base_path    /var/spool/apt-mirror" ${CONFIG_DIR}/mirror.list)" ]; then
  sed -i "/# set base_path    \/var\/spool\/apt-mirror/c\set base_path    ${MIRROR_DIR}" ${CONFIG_DIR}/mirror.list
  echo "---Please edit your 'mirror.list' file in your conig directory and restart the container when done!---"
  sleep infinity
fi
if [ -z "$(ls -A ${MIRROR_DIR})" ]; then
  echo "---Starting first mirror---"
  apt-mirror ${CONFIG_DIR}/mirror.list
  exit 0
fi
if [ ! "$(crontab -l 2>/dev/null)" ]; then
  echo "${CRON_SCHEDULE}  /usr/bin/apt-mirror ${CONFIG_DIR}/mirror.list" > /tmp/cron
  sleep 1
  crontab /tmp/cron
fi
echo "---'apt-mirror' will be run on the following cron schedule: ${CRON_SCHEDULE}---"
sleep infinity
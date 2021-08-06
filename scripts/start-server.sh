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
if [ ! -d ${MIRROR_DIR}/mirror/$(ls ${MIRROR_DIR}/mirror/)/debian ]; then
  echo "---Something went horribly wrong, can't find the mirror directory!---"
  sleep infinity
else
  if [ ! -d /var/www/debian ]; then
    ln -s ${MIRROR_DIR}/mirror/$(ls ${MIRROR_DIR}/mirror/)/debian /var/www/debian
  fi
fi

if [ "${FORCE_UPDATE}" == "true" ]; then
  crontab -r 2>/dev/null
  echo "---Force update enabled!---"
  apt-mirror ${CONFIG_DIR}/mirror.list
fi
echo "${CRON_SCHEDULE} /usr/bin/apt-mirror ${CONFIG_DIR}/mirror.list  1> /dev/null" > ${CONFIG_DIR}/cron
sleep 1
crontab ${CONFIG_DIR}/cron
echo "---'apt-mirror' will be run on the following cron schedule: ${CRON_SCHEDULE}---"
echo
echo "---Mirror started!---"
echo
echo "---Add the following line to your '/etc/apt/sources.list' file on your Debian installation:---"
echo "deb http://IPFROMTECONTAINER:${APACHE2_PORT}/debian stable main contrib non-free"
echo
echo "---Don't forget to change 'IPFROMTECONTAINER' and also change the repositories to match your config!---"
sleep infinity
#!/bin/bash
if [ ! -f ${CONFIG_DIR}/postmirror.sh ]; then
  echo "${MIRROR_DIR}/var/clean.sh" > ${CONFIG_DIR}/postmirror.sh
  if [ ! -d ${MIRROR_DIR}/var ]; then
    mkdir -p ${MIRROR_DIR}/var
  fi
  cp ${CONFIG_DIR}/postmirror.sh  ${MIRROR_DIR}/var/postmirror.sh
  chmod +x ${MIRROR_DIR}/var/postmirror.sh
else
  if [ ! -d ${MIRROR_DIR}/var ]; then
    mkdir -p ${MIRROR_DIR}/var
  fi
  cp ${CONFIG_DIR}/postmirror.sh  ${MIRROR_DIR}/var/postmirror.sh
  chmod +x ${MIRROR_DIR}/var/postmirror.sh
fi
if [ "$(grep -E "# set base_path    /var/spool/apt-mirror" ${CONFIG_DIR}/mirror.list)" ]; then
  sed -i "/# set base_path    \/var\/spool\/apt-mirror/c\set base_path    ${MIRROR_DIR}" ${CONFIG_DIR}/mirror.list
  chmod -R 777 ${CONFIG_DIR}/
  chown -R ${UID}:${GID} ${CONFIG_DIR}/
  echo "---Please edit your 'mirror.list' file in your conig directory and restart the container when done!---"
  sleep infinity
fi
chmod -R 777 ${CONFIG_DIR}/
chown -R ${UID}:${GID} ${CONFIG_DIR}/
if [ -z "$(ls -I "var" -A ${MIRROR_DIR})" ]; then
  echo "---Starting first mirror---"
  apt-mirror ${CONFIG_DIR}/mirror.list
  exit 0
fi
if [ ! -d ${MIRROR_DIR}/mirror/$(ls ${MIRROR_DIR}/mirror/ 2>/dev/null)/debian ]; then
  echo "---Something went horribly wrong, can't find the mirror directory!---"
  sleep infinity
else
  for directory in $(ls -1 ${MIRROR_DIR}/mirror/)
  do
    for subdir in $(ls -1 ${MIRROR_DIR}/mirror/$directory)
    do
      if [ ! -d /var/www/$subdir ]; then
        echo "Creating softlink for \".../$directory/$subdir\" in \"/var/www/\""
        ln -s ${MIRROR_DIR}/mirror/$directory/$subdir /var/www/$subdir
      else
        if [ $(readlink -f /var/www/$subdir) == "${MIRROR_DIR}/mirror/$directory/$subdir" ]; then
          echo "Nothing to do, directory: \"$subdir\" already found in \"/var/www/\""
        else
          echo "ERROR: Found \"$subdir\" already in \"/var/www/\", please check you configuration for \"$directory\"!"
        fi
      fi
    done
  done
fi

if [ "${FORCE_UPDATE}" == "true" ]; then
  crontab -r 2>/dev/null
  echo "---Force update enabled!---"
  apt-mirror ${CONFIG_DIR}/mirror.list
fi
echo "${CRON_SCHEDULE} /usr/bin/apt-mirror ${CONFIG_DIR}/mirror.list" > ${CONFIG_DIR}/cron
sleep 1
crontab ${CONFIG_DIR}/cron
echo "---'apt-mirror' will be run on the following cron schedule: ${CRON_SCHEDULE}---"
echo "---Mirror started!---"
echo "---Add the following line to your '/etc/apt/sources.list' file on your Debian installation:---"
echo "deb http://IPFROMTECONTAINER:${APACHE2_PORT}/debian stable main contrib non-free"
echo "---Don't forget to change 'IPFROMTECONTAINER' and also change the repositories to match your config!---"
sleep infinity
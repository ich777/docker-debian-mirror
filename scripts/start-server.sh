#!/bin/bash
if [ $(grep -E "# set base_path    /var/spool/apt-mirror" ${CONFIG_DIR}/mirror.list) ]; then
  sed -i "/# set base_path    \/var\/spool\/apt-mirror/c\set base_path    ${MIRROR_DIR}\/apt-mirror" ${CONFIG_DIR}/mirror.list
  echo "---Please edit your mirror.list file in your conig dir and restart the container when done!---"
fi
if [ -z "$(ls -A ${MIRROR_DIR})" ]; then
  echo "---Starting first mirror---"
  apt-mirror ${CONFIG_DIR}/mirror.list
fi
echo "---Container under Construction!---"
sleep infinity
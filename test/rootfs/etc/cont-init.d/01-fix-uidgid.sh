#!/usr/bin/with-contenv sh

if [ -n "${PGID}" ] && [ "${PGID}" != "$(id -g rrdcached)" ]; then
  echo "Switching to PGID ${PGID}..."
  sed -i -e "s/^rrdcached:\([^:]*\):[0-9]*/rrdcached:\1:${PGID}/" /etc/group
  sed -i -e "s/^rrdcached:\([^:]*\):\([0-9]*\):[0-9]*/rrdcached:\1:\2:${PGID}/" /etc/passwd
fi
if [ -n "${PUID}" ] && [ "${PUID}" != "$(id -u rrdcached)" ]; then
  echo "Switching to PUID ${PUID}..."
  sed -i -e "s/^rrdcached:\([^:]*\):[0-9]*:\([0-9]*\)/rrdcached:\1:${PUID}:\2/" /etc/passwd
fi

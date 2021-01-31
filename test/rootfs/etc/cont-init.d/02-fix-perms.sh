#!/usr/bin/with-contenv sh

echo "Fixing perms..."
mkdir -p /data/db \
  /data/journal \
  /var/run/rrdcached
chown rrdcached. \
  /data/db \
  /data/journal
chown -R rrdcached. \
  /var/run/rrdcached

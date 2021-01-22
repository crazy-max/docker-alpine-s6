#!/usr/bin/with-contenv bash

LOG_LEVEL=${LOG_LEVEL:-LOG_INFO}
WRITE_TIMEOUT=${WRITE_TIMEOUT:-300}
WRITE_JITTER=${WRITE_JITTER:-0}
WRITE_THREADS=${WRITE_THREADS:-4}
FLUSH_DEAD_DATA_INTERVAL=${FLUSH_DEAD_DATA_INTERVAL:-3600}

JITTER=""
if [ "${WRITE_JITTER}" -gt "0" ]; then
  JITTER="-z ${WRITE_JITTER}"
fi

mkdir -p /etc/services.d/rrdcached
cat > /etc/services.d/rrdcached/run <<EOL
#!/usr/bin/execlineb -P
with-contenv
/usr/sbin/rrdcached \
  -g \
  -L \
  -F \
  -B \
  -R \
  -l /var/run/rrdcached/rrdcached.sock \
  -p /var/run/rrdcached/rrdcached.pid \
  -b /data/db \
  -j /data/journal \
  -U rrdcached \
  -G rrdcached \
  -w "${WRITE_TIMEOUT}" \
  ${JITTER} \
  -f "${FLUSH_DEAD_DATA_INTERVAL}" \
  -t "${WRITE_THREADS}" \
  -V "${LOG_LEVEL}"
EOL
chmod +x /etc/services.d/rrdcached/run

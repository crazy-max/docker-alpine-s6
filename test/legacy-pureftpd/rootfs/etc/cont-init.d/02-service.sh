#!/usr/bin/with-contenv sh
# shellcheck shell=sh

mkdir -p /etc/services.d/pure-ftpd

env|sort

cat >/etc/services.d/pure-ftpd/run <<EOL
#!/usr/bin/execlineb -P
with-contenv
pure-ftpd ${PUREFTPD_FLAGS}
EOL
chmod +x /etc/services.d/pure-ftpd/run

cat >/etc/services.d/pure-ftpd/finish <<EOL
#!/usr/bin/with-contenv sh
echo >&2 "pure-ftpd exited. code=${1}"
exec s6-svscanctl -t /run/service
EOL
chmod +x /etc/services.d/pure-ftpd/finish

#!/usr/bin/env bash
set +e
HDI=$(getent hosts host.docker.internal | awk '{print $1}')
echo "hdi=$HDI"
for PORT in 65508 8443; do
  CODE=$(curl -sk --max-time 4 -o /dev/null -w "%{http_code}" "https://${HDI}:${PORT}/" 2>/dev/null)
  echo "port $PORT → http=$CODE"
done
# Try Win port-forward bridge: launch kubectl.exe pf bg from Win side via cmd

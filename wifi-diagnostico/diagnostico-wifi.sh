#!/usr/bin/env bash
# Diagnostico de Wi-Fi para Mac o Linux:  bash diagnostico-wifi.sh
# Genera reporte-wifi.txt en esta carpeta. Tarda unos 3 minutos.
out="$(cd "$(dirname "$0")" && pwd)/reporte-wifi.txt"
s(){ printf '\n===== %s =====\n' "$1" | tee -a "$out"; }
echo "Reporte Wi-Fi $(date)" > "$out"

if [[ "$(uname)" == "Darwin" ]]; then
  gw=$(route -n get default 2>/dev/null | awk '/gateway/{print $2}')
  s "1-2. Conexion Wi-Fi y redes vecinas (senal, ruido, canal)"
  system_profiler SPAirPortDataType 2>/dev/null | tee -a "$out"
  s "6. Desconexiones recientes"
  log show --last 3d --predicate 'subsystem == "com.apple.wifi"' 2>/dev/null | grep -iE "disassoc|deauth|link down" | tail -30 | tee -a "$out"
else
  gw=$(ip route | awk '/^default/{print $3; exit}')
  s "1. Conexion Wi-Fi actual"
  (iw dev 2>/dev/null; for i in $(iw dev 2>/dev/null | awk '/Interface/{print $2}'); do iw dev "$i" link; done) | tee -a "$out"
  s "2. Redes vecinas y canales"
  nmcli -f SSID,CHAN,FREQ,SIGNAL,RATE dev wifi list 2>/dev/null | tee -a "$out"
  s "6. Desconexiones recientes"
  journalctl --since "3 days ago" 2>/dev/null | grep -iE "disassoc|deauth|link becomes not ready|CTRL-EVENT-DISCONNECTED" | tail -30 | tee -a "$out"
fi

s "3. Ping al modem ($gw) - 100 paquetes"
ping -c 100 -i 0.5 "$gw" | tail -3 | tee -a "$out"
s "4. Ping a Internet (8.8.8.8) - 100 paquetes"
ping -c 100 -i 0.5 8.8.8.8 | tail -3 | tee -a "$out"
s "5. Tiempo de respuesta DNS"
for d in google.com youtube.com microsoft.com; do
  t0=$(python3 -c 'import time;print(time.time())'); host "$d" >/dev/null 2>&1 || nslookup "$d" >/dev/null 2>&1
  t1=$(python3 -c 'import time;print(time.time())'); echo "$d : $(python3 -c "print(int(($t1-$t0)*1000))") ms" | tee -a "$out"
done
echo; echo "Listo. Reporte guardado en: $out"

# Diagnostico de Wi-Fi para Windows. Ejecutar en PowerShell:
#   powershell -ExecutionPolicy Bypass -File .\diagnostico-wifi.ps1
# Genera el archivo reporte-wifi.txt en esta carpeta. Tarda unos 3 minutos.
$out = Join-Path $PSScriptRoot "reporte-wifi.txt"
function S($t){ "`n===== $t =====" | Tee-Object -FilePath $out -Append }
"Reporte Wi-Fi $(Get-Date)" | Out-File $out

S "1. Conexion Wi-Fi actual (senal, canal, banda, velocidad)"
netsh wlan show interfaces | Tee-Object -FilePath $out -Append

S "2. Redes vecinas y sus canales (interferencia)"
netsh wlan show networks mode=bssid | Select-String "SSID|Signal|Se.al|Channel|Canal|Band|Banda|Radio" | Tee-Object -FilePath $out -Append

$gw = (Get-NetRoute -DestinationPrefix "0.0.0.0/0" | Sort-Object RouteMetric | Select-Object -First 1).NextHop
S "3. Ping al modem ($gw) - 100 paquetes"
ping -n 100 $gw | Select-Object -Last 4 | Tee-Object -FilePath $out -Append

S "4. Ping a Internet (8.8.8.8) - 100 paquetes"
ping -n 100 8.8.8.8 | Select-Object -Last 4 | Tee-Object -FilePath $out -Append

S "5. Tiempo de respuesta DNS"
foreach($d in "google.com","youtube.com","microsoft.com"){
  $ms = (Measure-Command { Resolve-DnsName $d -DnsOnly -ErrorAction SilentlyContinue | Out-Null }).TotalMilliseconds
  "$d : $([int]$ms) ms" | Tee-Object -FilePath $out -Append }
ipconfig /all | Select-String "DNS Servers|Servidores DNS" | Tee-Object -FilePath $out -Append

S "6. Desconexiones de Wi-Fi en los ultimos 7 dias (WLAN-AutoConfig 8003)"
try {
  $ev = Get-WinEvent -FilterHashtable @{LogName='Microsoft-Windows-WLAN-AutoConfig/Operational'; Id=8003; StartTime=(Get-Date).AddDays(-7)} -ErrorAction Stop
  "Total de desconexiones: $($ev.Count)" | Tee-Object -FilePath $out -Append
  $ev | Select-Object -First 15 TimeCreated, @{n='Motivo';e={($_.Message -split "`n" | Select-String "Reason|Motivo")}} | Format-Table -AutoSize | Out-String | Tee-Object -FilePath $out -Append
} catch { "Sin desconexiones registradas (o sin permiso para leer el registro)." | Tee-Object -FilePath $out -Append }

S "7. Adaptador y driver"
Get-NetAdapter -Physical | Where-Object {$_.MediaType -match "802.11|Native"} | Format-List Name,InterfaceDescription,DriverVersion,DriverDate,LinkSpeed | Out-String | Tee-Object -FilePath $out -Append

"`nListo. Reporte guardado en: $out"

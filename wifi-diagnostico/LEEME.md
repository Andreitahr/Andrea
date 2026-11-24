# Diagnóstico de Wi-Fi lento y con caídas

1. Conéctate por Wi-Fi en el lugar donde más falla.
2. Ejecuta el script:
   - **Windows:** abre PowerShell en esta carpeta → `powershell -ExecutionPolicy Bypass -File .\diagnostico-wifi.ps1`
   - **Mac/Linux:** `bash diagnostico-wifi.sh`
3. Comparte el archivo `reporte-wifi.txt` que se genera.

## Cómo leer el resultado

| Lo que muestra el reporte | Significa | Qué hacer |
|---|---|---|
| Ping al **módem** con pérdida >1 % o picos >20 ms | El problema es el **Wi-Fi** (señal/interferencia), no tu proveedor | Ver filas siguientes |
| Módem bien, pero **8.8.8.8** con pérdida o >100 ms | El problema es tu **proveedor (ISP)** o la línea | Reiniciar módem; si sigue, reportarlo al ISP con el reporte |
| Señal < 60 % (o RSSI < -70 dBm) | Estás muy lejos del módem o hay paredes/obstáculos | Acercar o subir el módem, centrarlo en la casa, repetidor/mesh |
| Banda 2.4 GHz y muchas redes vecinas en tu mismo canal | Interferencia de vecinos | Usar 5 GHz; en 2.4 GHz fijar canal 1, 6 u 11 (el menos ocupado) |
| Velocidad de enlace (Receive/Transmit rate) baja, p. ej. < 50 Mbps | Mala calidad de enlace | Igual que señal baja; actualizar driver Wi-Fi |
| Muchas desconexiones (evento 8003) | Caídas reales del Wi-Fi | Actualizar firmware del módem y driver; desactivar ahorro de energía del adaptador |
| DNS > 150 ms | Resolución de nombres lenta (páginas “tardan en arrancar”) | Cambiar DNS a 1.1.1.1 / 8.8.8.8 |

## Revisión del módem (panel web, normalmente http://192.168.0.1 o http://192.168.1.1)
- Tiempo encendido (*uptime*): si se reinicia solo → falla de energía/sobrecalentamiento o del módem.
- Niveles de señal de la línea (DSL: SNR > 10 dB; cable: Downstream −7 a +7 dBmV, SNR > 35 dB; fibra: Rx entre −8 y −27 dBm).
- Registro de eventos: muchos “T3/T4 timeout”, “LOS” o reconexiones PPPoE → problema de la línea, toca llamar al ISP.
- Número de dispositivos conectados y si hay alguno desconocido consumiendo ancho de banda.
- Firmware actualizado; separar nombres de red de 2.4 y 5 GHz si “band steering” causa cortes.

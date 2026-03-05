España:

📝 README.md (Versión v1.4 Estable)
Signal-Simulator-Demo-Mode 🛰️📶
¡FUNCIONA EN KERNELSU Y MAGISK!

Módulo que simula la señal y la red aprovechando el modo de demostración de Android.

AVISO: ESTE MÓDULO NO PROPORCIONA UNA RED NI SEÑAL REAL.

🚀 Comandos en Termux
Ejecuta su -c minenet -h para ver la ayuda. Aquí tienes los principales:

Activar SIM 2: su -c minenet -s 2

Nivel Sincronizado (Ambas SIMs): su -c minenet -l [0-4]

Cambiar Red SIM 1: su -c minenet -t1 [tipo]

Cambiar Red SIM 2: su -c minenet -t2 [tipo]

Modo Satélite (Android 16+): su -c minenet -sat

📡 Tipos de datos soportados:
1x, e, g, h, h+, 3g, 3g+, 4g, 4g+, 5g, 5g+, 5ge, satellite.
(Nota: 5g y superiores requieren ROMs modernas como Android 16).


English:

📝 README.md (Version v1.4 Stable)
Signal-Simulator-Demo-Mode 🛰️📶
WORKS ON KERNELSU AND MAGISK!

Module that simulates the signal and network using Android's demo mode.

NOTICE: THIS MODULE DOES NOT PROVIDE A REAL NETWORK OR SIGNAL.

🚀 Commands in Termux
Run `su -c minenet -h` for help. Here are the main commands:

Activate SIM 2: `su -c minenet -s 2`

Sync Level (Both SIMs): `su -c minenet -l [0-4]`

Change SIM 1 Network: `su -c minenet -t1 [type]`

Change SIM 2 Network: `su -c minenet -t2 [type]`

Satellite Mode (Android 16+): `su -c minenet -sat`

📡 Supported data types:
1x, e, g, h, h+, 3g, 3g+, 4g, 4g+, 5g, 5g+, 5ge, satellite.

(Note: 5g and higher require modern ROMs such as Android 16).

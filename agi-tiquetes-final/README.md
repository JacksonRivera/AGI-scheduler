# AGI Tiquetes - Colombia Express

Proyecto desarrollado para la clase de Seminario Voz IP.

## Descripción

Este proyecto implementa un sistema AGI en Asterisk para consultar disponibilidad de tiquetes a diferentes trayectos dentro de Colombia.

El usuario llama a una extensión virtual, el sistema contesta con una asistente de voz, ofrece varios destinos, consulta horarios y precios disponibles, permite seleccionar una opción, resume la reserva y permite confirmarla o corregirla.

## Flujo del sistema

1. El usuario llama a la extensión 1050.
2. Asterisk contesta la llamada.
3. Asterisk ejecuta el AGI `tiquetes.php`.
4. El sistema ofrece destinos disponibles.
5. El usuario selecciona un destino usando el teclado del teléfono.
6. El sistema consulta horarios, precios y cupos disponibles.
7. El usuario selecciona un horario.
8. El sistema informa el resumen de la reserva.
9. El usuario confirma o corrige.
10. Si confirma, la reserva se guarda en la base de datos.

## Tecnologías usadas

- Ubuntu Server
- Asterisk
- PHP
- MariaDB / MySQL
- AGI
- Edge TTS
- FFmpeg
- PJSIP

## Estructura del proyecto

```text
agi-tiquetes-final/
├── agi-bin/
│   └── tiquetes.php
├── config/
│   └── definiciones.inc
├── sql/
│   ├── cargar.sql
│   └── backup_agi_tiquetes_actual.sql
├── asterisk-config/
│   ├── extensions.conf
│   ├── pjsip.conf
│   └── modules.conf
├── sounds/
│   └── agi-tiquetes/
└── README.md

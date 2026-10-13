#!/bin/sh
# Fecha en espanol para la pantalla de bloqueo, sin depender del idioma del sistema.
set -- domingo lunes martes miércoles jueves viernes sábado
shift "$(date +%w)"; dia=$1
set -- enero febrero marzo abril mayo junio julio agosto septiembre octubre noviembre diciembre
shift $(( $(date +%-m) - 1 )); mes=$1
echo "$dia $(date +%-d) de $mes"

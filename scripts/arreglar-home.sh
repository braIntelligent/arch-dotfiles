#!/bin/sh
# Mueve el home de matias a amnesia despues del cambio de nombre. Correr con sudo.
set -e
if [ "$(id -u)" != 0 ]; then
    echo "hay que correrlo con sudo"
    exit 1
fi
if [ -d /home/amnesia ]; then
    echo "/home/amnesia ya existe, no hago nada:"
    ls -ld /home/amnesia
    exit 0
fi
if [ ! -d /home/matias ]; then
    echo "no existe /home/matias; esto es lo que hay en /home:"
    ls -l /home
    exit 1
fi
getent group amnesia >/dev/null || groupmod -n amnesia matias
mv /home/matias /home/amnesia
chown -R amnesia:amnesia /home/amnesia
echo "listo:"
ls -ld /home/amnesia

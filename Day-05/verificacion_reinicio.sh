#!/bin/bash

SERVICIO="apache2"

if ! systemctl is-active --quiet $SERVICIO; then
    echo "El servicio $SERVICIO no está activo. Reiniciando..."
    sudo systemctl restart $SERVICIO

    if systemctl is-active --quiet $SERVICIO; then
        echo "El servicio $SERVICIO se ha reiniciado correctamente."
    else
        echo "No se pudo reiniciar el servicio $SERVICIO."
    fi
else
    echo "El servicio $SERVICIO ya está activo."
fi
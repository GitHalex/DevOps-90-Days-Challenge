#!/bin/bash
declare -A colores
colores[rojo]="#FF0000"
colores[verde]="#00FF00"
colores[azul]="#0000FF"
for color in "${!colores[@]}"; do
    echo "El color $color tiene el código ${colores[$color]}"
done

json='{"nombre": "Ana", "edad": 28, "ciudad": "Madrid"}'
nombre=$(echo "$json" | jq -r '.nombre')
edad=$(echo "$json" | jq -r '.edad')
echo "Nombre: $nombre, Edad: $edad"
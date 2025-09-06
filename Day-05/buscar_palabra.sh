#!/bin/bash

# verificar que se hayan proporcionado exactamente dos argumentos
if [ $# -ne 2 ]; then
    echo "Eror:  Debes proposrcionar exactamente dos argumentos: una palabra y un archivo."
    echo "Uso: $0 <archivo> <palabra>"
    exit 1
fi

#Asignar los argumentos a variables
ARCHIVO=$1
PALABRA=$2

# Verificar que el archivo existe
if [ ! -f "$ARCHIVO" ]; then
    echo "Error: El archivo '$ARCHIVO' no existe."
    exit 1
fi

# Verifcar si el archivo es legible
if [ ! -r "$ARCHIVO" ]; then
    echo "Error: El archivo '$ARCHIVO' no tiene permisos de lectura."
    exit 1
fi

# Buscar la palabra en el archivo usando grep
# -q: nodo silecioso, -w: palabra completa, -i: ignorar mayusculas/minusculas

if grep -q -w -i "$PALABRA" "$ARCHIVO"; then
    echo "La palabra '$PALABRA' fue encontrada en el archivo '$ARCHIVO'."
else
    echo "La palabra '$PALABRA' no fue encontrada en el archivo '$ARCHIVO'."
fi
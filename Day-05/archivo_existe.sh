#!/bin/bash
ARCHIVO="mi_archivo.txt"
if [ -f "$ARCHIVO" ]; then
    echo "El archivo $ARCHIVO existe."
else
    echo "El archivo $ARCHIVO no existe."
fi
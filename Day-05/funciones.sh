#!/bin/bash
saludar_usuario() {
    echo "Hola, $1! Bienvenido al sistema."
}
saludar_usuario "Carlos"

archivos=("archivo1.txt" "archivo2.txt" "archivo3.txt")
for archivo in "${archivos[@]}"; do
    echo "Procesando $archivo"
done

archivo="datos.csv"
if [[ -f "$archivo" ]]; then
    echo "Leyendo $archivo"
    cat "$archivo"
else
    echo "Error: $archivo no encontrado."
    exit 1
fi

if [[ $# -ne 1 ]]; then
    echo "Uso: $0 <nombre_de_usuario>"
    exit 1
fi
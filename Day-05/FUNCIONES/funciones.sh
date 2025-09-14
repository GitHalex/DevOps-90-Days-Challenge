#!/bin/bash

# funciones.sh - Funciones para gestión de usuarios

crear_usuario() {
    local usuario="$1"
    
    # Validar que se proporcionó un nombre de usuario
    if [[ -z "$usuario" ]]; then
        echo "Error: No se proporcionó nombre de usuario"
        return 1
    fi
    
    # Validar si el usuario ya existe
    if id "$usuario" &>/dev/null; then
        echo "El usuario '$usuario' ya existe."
        echo "$(date '+%Y-%m-%d %H:%M:%S') - Intento fallido: usuario '$usuario' ya existe" >> usuarios.log
        return 1
    else
        # Crear el usuario
        if sudo useradd -m "$usuario" 2>/dev/null; then
            echo "Usuario '$usuario' creado exitosamente."
            echo "$(date '+%Y-%m-%d %H:%M:%S') - Usuario '$usuario' creado exitosamente" >> usuarios.log
            return 0
        else
            echo "Error: No se pudo crear el usuario '$usuario'"
            echo "$(date '+%Y-%m-%d %H:%M:%S') - Error al crear usuario '$usuario'" >> usuarios.log
            return 1
        fi
    fi
}

# Función adicional para mostrar ayuda
mostrar_ayuda() {
    echo "Uso: gestion_usuarios.sh <nombre_usuario>"
    echo ""
    echo "Ejemplos:"
    echo "  gestion_usuarios.sh juan"
    echo "  gestion_usuarios.sh maria"
    echo ""
    echo "El script crea usuarios y registra las acciones en usuarios.log"
}
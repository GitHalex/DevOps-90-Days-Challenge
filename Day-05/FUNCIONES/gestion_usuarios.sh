#!/bin/bash

# gestion_usuarios.sh - Script para gestión de usuarios
# Uso: ./gestion_usuarios.sh <nombre_usuario>

# Configuración
SCRIPT_DIR="$(dirname "$0")"
FUNCIONES_FILE="$SCRIPT_DIR/funciones.sh"
LOG_FILE="$SCRIPT_DIR/usuarios.log"

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Función para mostrar mensajes de error
error() {
    echo -e "${RED}Error: $1${NC}" >&2
}

# Función para mostrar mensajes de éxito
exito() {
    echo -e "${GREEN}$1${NC}"
}

# Función para mostrar advertencias
advertencia() {
    echo -e "${YELLOW}$1${NC}"
}

# Validar que existe el archivo de funciones
if [[ ! -f "$FUNCIONES_FILE" ]]; then
    error "No se encuentra el archivo de funciones: $FUNCIONES_FILE"
    echo "Creando archivo de funciones..."
    
    # Crear archivo de funciones básico
    cat > "$FUNCIONES_FILE" << 'EOF'
#!/bin/bash

crear_usuario() {
    if id "$1" &>/dev/null; then
        echo "El usuario $1 ya existe."
        echo "$(date '+%Y-%m-%d %H:%M:%S') - Intento fallido: usuario $1 ya existe" >> usuarios.log
        return 1
    else
        if sudo useradd -m "$1" 2>/dev/null; then
            echo "Usuario $1 creado."
            echo "$(date '+%Y-%m-%d %H:%M:%S') - Usuario $1 creado exitosamente" >> usuarios.log
            return 0
        else
            echo "Error: No se pudo crear el usuario $1"
            echo "$(date '+%Y-%m-%d %H:%M:%S') - Error al crear usuario $1" >> usuarios.log
            return 1
        fi
    fi
}
EOF
    
    chmod +x "$FUNCIONES_FILE"
    exito "Archivo de funciones creado exitosamente"
fi

# Cargar funciones
source "$FUNCIONES_FILE"

# Validación de argumentos
if [[ $# -ne 1 ]]; then
    error "Número incorrecto de argumentos"
    echo "Uso: $0 <nombre_usuario>"
    echo ""
    echo "Ejemplos:"
    echo "  $0 juan"
    echo "  $0 maria"
    exit 1
fi

USUARIO="$1"

# Validar formato del nombre de usuario (solo letras, números y guiones)
if [[ ! "$USUARIO" =~ ^[a-z][-a-z0-9_]*$ ]]; then
    error "Nombre de usuario inválido: $USUARIO"
    echo "El nombre de usuario debe:"
    echo "  - Comenzar con una letra minúscula"
    echo "  - Contener solo letras minúsculas, números, guiones y underscores"
    exit 1
fi

# Validar permisos de sudo
if ! sudo -n true 2>/dev/null; then
    advertencia "Se necesitan permisos de sudo para crear usuarios"
    echo "Por favor ingresa tu contraseña de administrador cuando se te solicite"
fi

echo "=== Gestión de Usuarios ==="
echo "Usuario: $USUARIO"
echo "Fecha: $(date)"
echo "==========================="

# Crear usuario
crear_usuario "$USUARIO"

# Verificar si se creó exitosamente
if [[ $? -eq 0 ]]; then
    exito "✅ Operación completada exitosamente"
else
    error "❌ Operación fallida"
    exit 1
fi

# Mostrar información del usuario creado (si existe)
if id "$USUARIO" &>/dev/null; then
    echo ""
    echo "=== Información del usuario ==="
    grep "^$USUARIO:" /etc/passwd
    echo "Directorio home: /home/$USUARIO"
fi

echo ""
echo "📝 Log guardado en: $LOG_FILE"
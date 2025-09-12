# 📅 Día 05/90 - Automatizando Tareas con Bash Scripting

> "La mejor forma de aprender DevOps... es haciéndolo." - Roxs.

## ✅ Desafíos del Día 5:

### 1️⃣ 🌎 ¿Qué es script Bash?

Es un archivo de texto con instrucciones que ejecutás en una terminal Linux, como si las escribieras vos misma

### 🔁 Estructura básica de un script

```bash
#!/bin/bash

# Comentario
echo "Hola Mundo"

# Variables
NOMBRE="Cloudlex"
echo "Hola $NOMBRE"

# Condicionales
if [ "$NOMBRE" == "Roxs" ]; then
    echo "¡Sos vos!"
else
    echo "¿Y vos quién sos?"
fi

# Bucle
for i in {1..3}; do
    echo "Iteración $i"
done
```

### 📌 Guardalo con la extencion .sh, dale permisos y ejecutalo:

```text
chmod +x script.sh
./script.sh
```

### 🧪 Buenas prácticas

- Usá #!/bin/bash siempre en la primera línea
- Usá set -e para salir si ocurre un error
- Comentá tu código con #
- Probá scripts en entornos controlados (como Vagrant o online)

### 📚 Tareas Opcionales del Día 4

#### Nivel 1: Calentando motores

```bash
#!/bin/bash
echo "¿Cual es tu nombre?"
read NOMBRE
echo "¿Cuantos años tenes boludo?"
read EDAD

echo "Hola $NOMBRE, tenes $EDAD años, bienvenido al mundo DevOps"
```

```bash
#!/bin/bash
PRIMERO=$1
SEGUNDO=$2
RESULTADO=$((PRIMERO * SEGUNDO))
echo "El resultado de multiplicar $PRIMERO x $SEGUNDO = $RESULTADO"
```

```bash
#!/bin/bash
for i in {1..5}; do
  echo "DevOps es 🔥 - iteración $i"
done
```

#### Nivel 2: Automatización útil

##### script que crear backups

```bash
#!/bin/bash

# configuracion
USER=$(whoami)
BACKUP_DIR="/home/$USER/backups"
LOG_DIR="/var/log"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_NAME="logs_backup_$TIMESTAMP.tar.gz"

# Crear direcotrio de backups si no existe
mkdir -p $BACKUP_DIR

# verificar permiso para leer /var/log
if [ ! -r $LOG_DIR ]; then
    echo "No tienes permiso para leer $LOG_DIR"
    echo "Ejecuta el script con sudo o cmo root"
    exit 1
fi

# crear el backup comprimido
echo "Creando backupo de logs"
if tar -cvf "$BACKUP_DIR/$BACKUP_NAME" -C $LOG_DIR . 2>/dev/null; then
  echo "Backup creado exitosamente en $BACKUP_DIR/$BACKUP_NAME"

  # Verificar el tamaño del backup
  BACKUP_SIZE=$(du -h "$BACKUP_DIR/$BACKUP_NAME" | cut -f1)
  echo "Tamaño del backup: $BACKUP_SIZE"
else
    echo "Error: No se pudo crear el backup. Verifica los permisos."
    exit 1
fi

# Elimar backups antiguos (mas de 7 dias)
echo "Eliminado backups antiguos (mas de 7 dias)..."
find $BACKUP_DIR -name "logs_backup_*.tar.gz" -type f -mtime +7 -delete

# Mostrar backups restantes
echo "Backups actuales en el directorio de backups:"
ls -la $BACKUP_DIR/*.tar.gz 2>/dev/null || echo "No hay backups en el directorio."

echo "Proceso de backup completado."
```

#### script que busca palabras

```bash
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
```

#### Nivel 3: Reto DevOps PRO

##### script para guardar el historial en un archivo log incluyendo la fecha

```bash
#!/bin/bash

# Configuración - Usando /tmp para testing
EMAIL_LOG="/tmp/alertas_email.log"
LOG_FILE="/tmp/monitor_disco.log"

# Obtener fecha y hora
FECHA=$(date "+%Y-%m-%d %H:%M:%S")
HOSTNAME=$(hostname)

# Monitoreo de discos
USO_RAIZ=$(df / | awk '/\/$/ {print $5}' | sed 's/%//g')
TAMANO_HOME=$(du -sh /home 2>/dev/null | awk '{print $1}') || TAMANO_HOME="N/A"

# Guardar en log principal
echo "[$FECHA] Host: $HOSTNAME | /: ${USO_RAIZ}% | /home: $TAMANO_HOME" >> "$LOG_FILE"

# Guardar "emails" localmente si hay alertas
if [ "$USO_RAIZ" -ge 90 ]; then
    echo "=== ALERTA DE EMAIL ===" >> "$EMAIL_LOG"
    echo "Fecha: $FECHA" >> "$EMAIL_LOG"
    echo "Para: admin@ejemplo.com" >> "$EMAIL_LOG"
    echo "Asunto: Alerta Partición / en $HOSTNAME" >> "$EMAIL_LOG"
    echo "Cuerpo: ¡Alerta: Partición / al ${USO_RAIZ}%!" >> "$EMAIL_LOG"
    echo "======================" >> "$EMAIL_LOG"
    echo "📧 Alerta de / guardada en $EMAIL_LOG"
fi

if [ "$TAMANO_HOME" != "N/A" ]; then
    TAMANO_GB=$(echo "$TAMANO_HOME" | sed 's/G//g')
    if (( $(echo "$TAMANO_GB > 2" | bc -l 2>/dev/null) )); then
        echo "=== ALERTA DE EMAIL ===" >> "$EMAIL_LOG"
        echo "Fecha: $FECHA" >> "$EMAIL_LOG"
        echo "Para: admin@ejemplo.com" >> "$EMAIL_LOG"
        echo "Asunto: Alerta /home en $HOSTNAME" >> "$EMAIL_LOG"
        echo "Cuerpo: ¡Alerta: /home ocupa ${TAMANO_HOME}!" >> "$EMAIL_LOG"
        echo "======================" >> "$EMAIL_LOG"
        echo "📧 Alerta de /home guardada en $EMAIL_LOG"
    fi
fi

echo "✅ Monitoreo completado!"
echo "📊 Historial: $LOG_FILE"
echo "📧 Alertas: $EMAIL_LOG"
echo "💡 Los archivos están en /tmp/ y se borrarán al reiniciar"
```

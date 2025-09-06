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

echo "Proceso de backup completado."cd 
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